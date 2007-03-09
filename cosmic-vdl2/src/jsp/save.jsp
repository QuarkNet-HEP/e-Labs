<%@ page import="java.io.*" %>
<%@ page import="org.apache.batik.transcoder.image.PNGTranscoder" %>
<%@ page import="org.apache.batik.transcoder.TranscoderInput" %>
<%@ page import="org.apache.batik.transcoder.TranscoderOutput" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.vds.*" %>
<%@ include file="common.jsp" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD><TITLE>Save Plot</TITLE>
<META http-equiv=Content-Type content="text/html; charset=iso-8859-1">
</HEAD>
<BODY>
<FONT face=ARIAL>
<CENTER>
<TABLE width="100%" cellpadding="0" cellspacing="0" align=center>

<%!
public static void dumpStream(InputStream is, JspWriter out) throws IOException {
	int c;
	StringWriter sw = new StringWriter();
	while(true) {
		c = is.read();
		if (c == -1) {
			break;
		}
		else {
			sw.write(c);
		}
	}
	out.write(sw.toString());
}
%>

<%!
public static boolean shellRun(String[] cmd, String errorMsg, JspWriter out) throws IOException, InterruptedException {
	Process p = Runtime.getRuntime().exec(cmd);
	int c = p.waitFor();
	
	if (c != 0) {
		out.write("<tr><td align=\"left\">Error: " + errorMsg + "</td></tr>\n");
		out.write("<tr><td align=\"left\">Commands: ");
		for (int i = 0; i < cmd.length; i++) {
			out.write(cmd[i]);
			out.write(' ');
		}
		out.write("</td></tr>\n");
		out.write("<tr><td align=\"left\">Exit code: " + c + "</td></tr>\n");
		out.write("<tr><td align=\"left\">STDOUT: ");
		dumpStream(p.getInputStream(), out);
		out.write("</td></tr>\n");
		out.write("<tr><td align=\"left\">STDERR: ");
		dumpStream(p.getErrorStream(), out);
		out.write("</td></tr>\n");
		return false;
	}
	else {
		return true;
	}
}
%>

<%
//boolean error = false;
String scratchFile = request.getParameter("pngFile");           //original file to copy
String thumbnail  = request.getParameter("pngThumb");           //original thumbnail file to copy
String userFilename = request.getParameter("permanentFile");    //filename from user input
String fullFile = "";                                           //full image filesystem name
String fileType = request.getParameter("fileType");             //file extension
String outputDir = request.getParameter("outputDir");           //output directory
String fullOutputDir = runDir + outputDir;  //FIXME: trailing "/" in runDir

if ( userFilename == null || userFilename.equals("") ) {
%>
    <TR><TD>You forgot to specify the name of your file. Please close this window and enter it.<TD></TR>
<%
}
else{
    //generate a unique filename to save as (savedimage-group-date.extension format)
    //NOTE: this timestamp is also used for the Derivation name
    GregorianCalendar gc = new GregorianCalendar();
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy.MMdd.HHmmss.SSSS");
    String date = sdf.format(gc.getTime());

    fullFile = "savedimage-" + groupName + "-" + date + "." + fileType;
    String thumbnailFile = "savedimage-" + groupName + "-" + date + "_thm." + fileType;
    String provenanceFile = "savedimage-" + groupName + "-" + date + "_provenance." + fileType;

    boolean added = addRC(fullFile, plotDir + fullFile);
    int collision = 0;
    while(added == false && collision < 50){
        collision++;
        fullFile = "savedimage-" + groupName + "-" + date + "-" + collision + "." + fileType;
        thumbnailFile = "savedimage-" + groupName + "-" + date + "-" + collision +"_thm." + fileType;
        provenanceFile = "savedimage-" + groupName + "-" + date + "-" + collision + "_provenance." + fileType;
        added = addRC(fullFile, plotDir + fullFile);
    }
    if(added == false){
%>
        <tr><td>Too many users using the system at the moment. Please try your request again in a few seconds.</td></tr>
<%
    }
    else{
        //add thumbnail and provenance file to Catalog as well
        added = addRC(thumbnailFile, plotDir + thumbnailFile);
        added = addRC(provenanceFile, plotDir + provenanceFile);
    }

    File f = new File(plotDir + fullFile);
    if (f.exists()) {
%>
        <TR><TD>Error: A unix file by that name already exists. (this should never happen). Please contact the administrator with this text:<TD></TR>
        <tr><td>Unix file exists when trying to save plot: <%=plotDir+fullFile%> </td></tr>
<%
    }
    else{
		//[m] making sure the directory exists
		File fpdir = new File(plotDir);
		fpdir.mkdirs();
        //copy the full image to the user's plot directory
        String cpCmd = "cp " + scratchFile + " " + plotDir + fullFile;
        String[] cmd = new String[] {"bash", "-c", "cd " + fullOutputDir + ";" + cpCmd};
		if (!shellRun(cmd, "Failed to copy image file in shell!", out)) {
			return;
		}
        
        //copy the thumbnail to the user's plot directory
        cpCmd = "cp " + thumbnail + " " + plotDir + thumbnailFile;
        cmd = new String[] {"bash", "-c", "cd " + fullOutputDir + ";" + cpCmd + " >out 2>&1"};
		if (!shellRun(cmd, "Failed to copy thumbnail file in shell!", out)) {
			return;
		}
        
        //copy the provenance image to the user's plot directory
        String provenanceDir = fullOutputDir;

        //FIXME This exists to clean out a bug in the DAX2DOT routine.
		//TODO [m] disabled with VDL2 for now
        //cmd = new String[] {"bash", "-c", "/usr/bin/perl -pi -e 's/^.*\"\".*$//g' " + provenanceDir + "/dv.dot"};
		//shellRun(cmd, "Failed to run fix code for dax in shell!", out);
        
		// Transform the provenance information stored by doAnalysis_TR_call.jsp.
        // Start by making the SVG image using dot.
        
        String dotCmd = 
            "/export/d1/yongzh/graphviz-1.10/dotneato/dot -Tsvg -o " + provenanceDir + "/dv.svg " + 
            provenanceDir + "/dv.dot";
        
        /*String dotCmd = "/usr/bin/dot -Tsvg -o" + provenanceDir + "/dv.svg " + 
            provenanceDir + "/dv.dot";*/
        cmd = new String[] {"bash", "-c", dotCmd};
		//TODO [m] disabled: VDL2
		//if (shellRun(cmd, "Failed to transform dot to svg in shell!", out)) {
		if (false) {
            try {
                // Now convert the SVG image to PNG using the Batik toolkit.
                // Thanks to the Batik website's tutorial for this code (http://xml.apache.org/batik/rasterizerTutorial.html).
                PNGTranscoder t = new PNGTranscoder();
                t.addTranscodingHint(PNGTranscoder.KEY_HEIGHT, new Float(800));
                TranscoderInput input = new TranscoderInput(
                        (new File(provenanceDir + "/dv.svg")).toURL().toString());
                OutputStream ostream = new FileOutputStream(plotDir + provenanceFile);
                TranscoderOutput output = new TranscoderOutput(ostream);
                t.transcode(input, output);
                ostream.flush();
                ostream.close();
            } catch (Exception e) {
                out.write("<tr><td>Error: Failed to create provenance information. " + e.getMessage() + "</tr></td>");
                return;
            }
		}
            
        //use previously computed timestamp to create a Derivation name
        String newDVName = groupName + "-" + sdf.format(gc.getTime());

        //save Derivation used to create this plot
        String beanName = request.getParameter("beanName");
        if(beanName != null){
            if(beanName.matches("flux")){
                %>
                    <jsp:useBean id="flux" scope="session" class="gov.fnal.elab.cosmic.beans.FluxBean" />
                <%
                ElabTransformation storeOnly = new ElabTransformation("Quarknet.Cosmic::FluxStudy");
                storeOnly.setDVName("Quarknet.Cosmic.Users::" + newDVName);
                storeOnly.createDV(flux);
                storeOnly.storeDV();
                storeOnly.close();
                out.println("<!-- flux Derivation stored " + newDVName + " -->");
            }
            else if(beanName.matches("shower")){
                %>
                    <jsp:useBean id="shower" scope="session" class="gov.fnal.elab.cosmic.beans.ShowerBean" />
                <%
                ElabTransformation storeOnly = new ElabTransformation("Quarknet.Cosmic::ShowerStudy");
                storeOnly.setDVName("Quarknet.Cosmic.Users::" + newDVName);
                storeOnly.createDV(shower);
                storeOnly.storeDV();
                storeOnly.close();
                out.println("<!-- shower Derivation stored " + newDVName + " -->");
            }
            else if(beanName.matches("lifetime")){
                %>
                    <jsp:useBean id="lifetime" scope="session" class="gov.fnal.elab.cosmic.beans.LifetimeBean" />
                <%
                ElabTransformation storeOnly = new ElabTransformation("Quarknet.Cosmic::LifetimeStudy");
                storeOnly.setDVName("Quarknet.Cosmic.Users::" + newDVName);
                storeOnly.createDV(lifetime);
                storeOnly.storeDV();
                storeOnly.close();
                out.println("<!-- lifetime Derivation stored " + newDVName + " -->");
            }
            else if(beanName.matches("performance")){
                %>
                    <jsp:useBean id="performance" scope="session" class="gov.fnal.elab.cosmic.beans.PerformanceBean" />
                <%
                ElabTransformation storeOnly = new ElabTransformation("Quarknet.Cosmic::PerformanceStudy");
                storeOnly.setDVName("Quarknet.Cosmic.Users::" + newDVName);
                storeOnly.createDV(performance);
                storeOnly.storeDV();
                storeOnly.close();
                out.println("<!-- performance Derivation stored " + newDVName + " -->");
            }

            // *** Metadata section ***

            ArrayList meta = new ArrayList();

            // Default metadata for all files saved
            meta.add("city string " + groupCity);
            meta.add("group string " + groupName);
            meta.add("name string " + userFilename);
            meta.add("project string " + eLab);
            meta.add("school string " + groupSchool);
            meta.add("state string " + groupState);
            meta.add("teacher string " + groupTeacher);
            meta.add("year string " + groupYear);
            meta.add("provenance string " + provenanceFile);
            meta.add("thumbnail string " + thumbnailFile);
                
            meta.add("dvname string " + newDVName);

            //additional metadata should be passed in the metadata parameter (of course this can have multiple values)
            String[] metadata = request.getParameterValues("metadata");
            meta.addAll(Arrays.asList(metadata));

            boolean metaUpdated = setMeta(fullFile, meta);
            if(metaUpdated){
%>
                <TR><TD>You saved your plot permanently as file 
                <%=userFilename%> <!--filesystem name: <%=plotDir+fullFile%> --></TD></TR>
<%
            }
            else{
%>
                <TR><TD><font color="red">Error saving metadata for your plot</TD></TR>
                <TR><TD>(setMeta returned false)</TD></TR>
<%
            }
        }
        else{
%>
            <TR><TD><font color="red">Beanname unspecified</TD></TR>
<%
        }   //rc updated
    }   //file existance chech
}   //save name not null
%>
</TABLE>
<br>
<a href=# onclick="window.close()">Close</A>
</CENTER>
</FONT>
</BODY>
</HTML>
