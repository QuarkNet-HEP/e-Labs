<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="java.io.*"  %>
<%@ include file="common.jsp" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD><TITLE>Save Plot</TITLE>
<META http-equiv=Content-Type content="text/html; charset=iso-8859-1">
</HEAD>
<BODY>
<FONT face=ARIAL>
<CENTER>
<TABLE width="100%" cellpadding="0" cellspacing="0" align=center>

<%
//boolean error = false;
String scratchFile = request.getParameter("pngFile");           //original file to copy
String thumbnail  = request.getParameter("pngThumb");           //original thumbnail file to copy
String userFilename = request.getParameter("permanentFile");    //filename from user input
String fullFile = "";                                           //full image filesystem name
String fileType = request.getParameter("fileType");             //file extension
//this is the full output dir, see below.
String outputDir = request.getParameter("outputDir");           //output directory
String fullOutputDir ;// = runDir + outputDir;  //FIXME: trailing "/" in runDir

if ( userFilename == null || userFilename.equals("") ) {
%>
    <TR><TD>You forgot to specify the name of your file. Please close this window and enter it.<TD></TR>
<%
}
else{
	
    GregorianCalendar gc = new GregorianCalendar();
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy.MMdd.HHmmss.SSSS");
    String date = sdf.format(gc.getTime());
    
    fullFile = "savedimage-" + groupName + "-" + date + "." + fileType;
    String thumbnailFile = "savedimage-" + groupName + "-" + date + "_thm." + fileType;
    String provenanceFile = "savedimage-" + groupName + "-" + date + "_provenance." + fileType;

	out.println("Save file: "+fullFile+" from "+outputDir);

	//TODO: make plotdir different from the standard output dir ?
	//out.println("<br>Old plotDir="+plotDir);
	//out.println("<br>Old outputDir="+outputDir);
	//out.println("<br>Old userArea="+userArea);
	//out.println("<br>Old userDir="+userDir);

	fullOutputDir=outputDir+"/"+userArea;
	
	File f = new File(plotDir + fullFile);
    if (f.exists()) {
%>
        <TR><TD>Error: A unix file by that name already exists. (this should never happen). Please contact the administrator with this text:<TD></TR>
        <tr><td>Unix file exists when trying to save plot: <%=plotDir+fullFile%> </td></tr>
<%
    }
    String cpCmd = "cp " + scratchFile + " " + plotDir + fullFile;    
    String[] cmd = new String[] {"bash", "-c", "cd " + fullOutputDir + ";" + cpCmd + " >out 2>&1"};

    try{
	    Process p = Runtime.getRuntime().exec(cmd);
	    int c = p.waitFor();
	    if (c != 0) {
%>
        <TR><TD>Error: Failed to copy image file in shell!<TD></TR>
        <TR><TD>Commands: <%=cpCmd%><TD></TR>
        <br>
		<a href=# onclick="window.close()">Close</A>        
<%
        return;
	    }
    }catch(IOException ioe){
    	out.println(ioe.getLocalizedMessage());	
    }
	//out.println("Done copying final destination file");

	
    //THUMBNAILS
   // convert savedimage-cmsguest-2007.0124.154151.0633.png -thumbnail 150x150 savedimage-cmsguest-2007.0124.154151.0633_thm.png
    String convertCmd = "/usr/bin/convert " + fullFile + " -thumbnail 150x150 " + thumbnailFile;
    String[] cvcmd = new String[] {"bash", "-c", "cd " + plotDir+ ";" + convertCmd + " >out 2>&1"};

    //out.println("in "+fullOutputDir +"/"+ plotDir+ " executed: "+convertCmd);

    try{
	    Process p2 = Runtime.getRuntime().exec(cvcmd);
	    int c = p2.waitFor();
	    if (c != 0) {
%>
        <TR><TD>Error: Failed to generate thumbnail file in shell!<TD></TR>
        <TR><TD>Commands: <%=convertCmd%><TD></TR>
        <br>
		Work dir: <%=fullOutputDir +"/"+ plotDir%><br>
		<a href=# onclick="window.close()">Close</A>
        
<%
        return;
	    }
    }catch(IOException ioe){
    	out.println(ioe.getLocalizedMessage());	
    }
        
	//boolean added = addRC(fullFile, plotDir + fullFile);
	boolean added=false;
	if (added) {
		out.println("Successfully added "+fullFile+ " to the VDC");		
	} else {
		out.println("FAILED adding "+fullFile+ " to the VDC");				
	}
	
	
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
    //meta.add("provenance string " + provenanceFile);
    meta.add("thumbnail string " + thumbnailFile);
        
    //meta.add("dvname string " + newDVName);
    
    //out.println("city string " + groupCity); 
    //out.println("group string " + groupName);
    //out.println("name string " + userFilename);
    //out.println("project string " + eLab);
    //out.println("school string " + groupSchool);
    //out.println("state string " + groupState);
    //out.println("teacher string " + groupTeacher);
    //out.println("year string " + groupYear);
    //out.println("thumbnail string " + thumbnailFile);

    String[] metadata = request.getParameterValues("metadata");
    if(metadata!=null){
       meta.addAll(Arrays.asList(metadata));
       out.println("<p> More Metadata: "+metadata[0]);
    }else {
               out.println("No extra Metadata");
    }    
    
    boolean metaUpdated=false;
    metaUpdated = setMeta(fullFile,meta);
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

%>
</TABLE>
<br>
<a href=# onclick="window.close()">Close</A>
</CENTER>
</FONT>
</BODY>
</HTML>
    