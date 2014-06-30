<%@ page import="org.griphyn.common.util.Separator" %>
<%@ page import="org.griphyn.vdl.router.*" %>
<%@ page import="org.griphyn.vdl.toolkit.VizDAX" %>
<%@ page import="java.io.*" %>
<%@ page import="org.apache.batik.transcoder.image.PNGTranscoder" %>
<%@ page import="org.apache.batik.transcoder.TranscoderInput" %>
<%@ page import="org.apache.batik.transcoder.TranscoderOutput" %>

<%!
public static void error_output(JspWriter out, String error){
    try{
        out.write("<tr><td>&nbsp;</td></tr> <tr><td><font color=red><b>Returned an error!</b></font><br>" + error + "</tr></td>");
    }
    catch(IOException e){
        ;
    }
}
%>

<%
if (tr == null || tr.equals("")) {
    error_output(out, "No tr specified. Make sure your variable name for the Transformation is set to \"tr\" and is not an empty string.");
}
else {
    String schemaName = ChimeraProperties.instance().getVDCSchemaName();

    // Connect the database.
    Connect connect = new Connect();
    DatabaseSchema dbschema = connect.connectDatabase(schemaName);
    VDC vdc = (VDC)dbschema;
    AnnotationSchema yschema = (AnnotationSchema)dbschema;
    String[] name = Separator.split(tr);
    Transformation t = (Transformation)vdc.loadDefinition(name[0], name[1], name[2], Definition.TRANSFORMATION);
    if (t == null) {
        error_output(out, "VDC returned null for the Transformation loadDefinition()");
   	}
    else {      //transformation isn't null, start vdc calculations
        //Random rand = new Random();

        String ns = name[0];
        String trname = name[1];
        String ver = name[2];
        //String label = String.valueOf(Math.abs(rand.nextInt()) );
        String label = "run";

        String detector = ""; //detector uses the first three numbers in the raw data file.
        String dvname = trname + label;
        String[] thresholdAll = request.getParameterValues("thresholdAll");
        Derivation dv = new Derivation(ns, dvname, ver, ns, trname, ver, ver);

        ArrayList filenames = new ArrayList();
        for (Iterator i=t.iterateDeclare(); i.hasNext();) {
            Declare dec = (Declare)i.next();
            String decName = dec.getName();
            int link = dec.getLink();
            String decValue = request.getParameter(decName);
            //things like the detectorID and png files are derived and are left out in the caller's form
            if ( decValue == null || decValue == "" ) {     
                if (thresholdAll == null) {
                    error = true;
                    error_output(out, "You must select at least one detector from the list.");
                    break;
                }
                else {
                    if (decName.equals("thresholdAll")) {   //this builds the list of threshold files for their respective raw data files
                        org.griphyn.vdl.classes.List list = new org.griphyn.vdl.classes.List();
                        for (int k=0; k<thresholdAll.length; k++) {
                            list.addScalar(new Scalar(new LFN(thresholdAll[k]+".thresh", link)));
                        }
                        dv.addPass(new Pass(decName, list));
                    } 
                    else if(decName.equals("detector")){ 
                        for (int k=0; k<thresholdAll.length; k++) {  //this builds the list of detectorIDs
                            detector +=  thresholdAll[k].substring(0,thresholdAll[k].indexOf(".")) + " ";
                        }
                        detector = detector.substring(0, detector.length()-1);      //get rid of last extra space
                        decValue = detector;
                    }
                }		    
                if (link == LFN.INOUT || link == LFN.OUTPUT) {
                    //int seq = Math.abs(rand.nextInt());
                    //decValue = decName + String.valueOf(seq);
                    //10-6-04: since we create unique "runs" based on directory name, this artifact of random number generation isn't needed
                    decValue = decName;
                    if (decName.endsWith("png")) {
                        decValue += ".png";
                        filenames.add(decValue);
                    }
                    if (decName.endsWith("svg")) {
                        decValue += ".svg";
                        filenames.add(decValue);
                    }
                }
                else if(decName.equals("detector") || decName.equals("thresholdAll")){
                }
                else {
                    error = true;
                    error_output(out, "Argument " + decName + " not specified!");
                    break;
                }
            }
            //build the DV
            if (!error) {
                decValue = decValue.replaceAll("\r\n?", "\\\\n");   //replace new lines from text boxes with "\n"
                switch (link) {
                    case LFN.NONE:
                        //if (decName.equals("detector"))
                        //    dv.addPass(new Pass(decName, new Scalar(  new Text(detector))));
                        //else
                            dv.addPass(new Pass(decName, new Scalar( new Text(decValue))));
                        break;
                    case LFN.INPUT:
                        if (decName.equals("thresholdAll")) {
                            org.griphyn.vdl.classes.List list = new org.griphyn.vdl.classes.List();
                            for (int k=0; k<thresholdAll.length; k++) {
                                list.addScalar(new Scalar(new LFN(thresholdAll[k]+".thresh", link)));
                            }
                            dv.addPass(new Pass(decName, list));
                        }
                        else
                            dv.addPass(new Pass(decName, new Scalar( new LFN(decValue, link))));
                        break;


                    case LFN.INOUT:
                        if (!decName.equals("thresholdAll")) 
                            dv.addPass(new Pass(decName, new Scalar( new LFN(decValue, link))));
                        break;
                    case LFN.OUTPUT:
                        dv.addPass(new Pass(decName, new Scalar( new LFN(decValue, link))));
                        // filenames.add(decValue);      //needed if non-png files are returned
                        break;
                }
            }
        }   //end iterating for DV DecNames

        if (!error) {
            Route route = new Route(dbschema);
            BookKeeper state = new BookKeeper();
            Definitions defs = new Definitions();
            defs.addDefinition(dv);
            route.addDefinitions(defs);
            StringWriter sw = new StringWriter();

            route.requestDerivation(ns, dvname, ver, state );

            if ( state == null || state.isEmpty() ) {
                error_output(out, "Failed to generate workflow for " + tr + "!");
                error = true;
            }
            else {
                state.getDAX( label==null ? "cosmic" : label ).toXML(sw, "");
                sw.close();
                StringBufferInputStream is = new StringBufferInputStream(sw.toString());	
                Derive derive = new Derive();

                //added 7-20-04 to create a temp dir for each process
                GregorianCalendar cal = new GregorianCalendar();
                String tempRunDir = "";
                String year = cal.get(Calendar.YEAR) + "";
                String month = cal.get(Calendar.MONTH) + 1 + "";
                String day = cal.get(Calendar.DAY_OF_MONTH) + "";
                String hour = cal.get(Calendar.HOUR_OF_DAY) + "";
                String min = cal.get(Calendar.MINUTE) + "";
                String sec = cal.get(Calendar.SECOND) + "";
                String msec = cal.get(Calendar.MILLISECOND) + "";
                tempRunDir = "run." + year + "." + month + day + "." + hour + min + sec + "." + msec;
                File ftempRunDir = new File(tempRunDir);
                boolean isDirectory = ftempRunDir.isDirectory();
                int collision = 0;
                while(isDirectory == true && collision < 50){
                    collision++;
                    tempRunDir += "." + collision;
                    ftempRunDir = new File(tempRunDir);
                    isDirectory = ftempRunDir.isDirectory();
                }
                if(isDirectory == true){
                    error_output(out, "Too many users on the system at once (" + collision + " max). Try again.\nError: cannot create directory: " + tempRunDir);
                    return;
                }
                runDir = runDir + tempRunDir;
                runDirURL = runDirURL + tempRunDir;
                
                int c = derive.genShellScripts(is, runDir, false, false) ? 0:1;
                if (c != 0) {
                    error_output(out, "Failed to generate shell scripts for " + tr + "!");
                    error = true;
                }
                else {	
                    // Write the DAX XML to a file in the run directory, turn
                    // the dax into a dot file, save the VDL text and XML
                    // representation.
                    try {
                        String fileNoExt = 
                            runDir + System.getProperty("file.separator", "/") + "dv";
                        // Write the dax.
                        PrintWriter pw = new PrintWriter(new FileWriter(new File(fileNoExt + ".dax")));
                        pw.println(sw.toString());
                        pw.close();

                        // Write the VDL text.
                        BufferedWriter bw = new BufferedWriter(new FileWriter(
                                    new File(fileNoExt + ".vdlt")));
                        dv.toString(bw);
                        bw.close();

                        // Write the VDL XML.
                        bw = new BufferedWriter(new FileWriter(new File(fileNoExt + ".vdlx")));
                        dv.toXML(bw, "", "");
                        bw.close();

                        // Call the Java that is called by vds.home/bin/dax2dot.
                        String [] dax2dot = new String[] 
                            {"-o" + fileNoExt + ".dot", "-f", fileNoExt + ".dax"};
                        VizDAX.main(dax2dot);
                    }
                    catch (Exception ex) {
                        error_output(out, "Not able to save the derivation to the run directory.");
                        error = true;
                    }

                    try{

                        String[] cmd = new String[] {"bash", "-c", "cd " + runDir + "; ./" + label + ".sh"};    //output captured with Process Class
                        Process p = Runtime.getRuntime().exec(cmd);

                        //Note 10-23-04: to keep jsp from hanging, read out the standard output and write it to a log file. Do this BEFORE you call waitFor()
                        BufferedReader stdOutput = new BufferedReader(new InputStreamReader(p.getInputStream()));
                        BufferedWriter outFile = new BufferedWriter(new FileWriter(runDir + "/out"));
                        String stdOutputString;
                        outFile.write("Standard output from recently run bash script (" + label + ".sh):\n\n");
                        while ((stdOutputString = stdOutput.readLine()) != null) {
                            outFile.write(stdOutputString + "\n");
                        }
                        outFile.close();

                        c = p.waitFor();

                        if (c != 0) {			
                            error = true;
                            String myError = "";

                            BufferedReader stdError = new BufferedReader(new InputStreamReader(p.getErrorStream()));
                            String stdErrorString;
                            while ((stdErrorString = stdError.readLine()) != null) {
                                myError += stdErrorString + "<br>\n";
                            }
                            /*
                               BufferedReader br = new BufferedReader(new FileReader(runDir + "/out"));
                               String line = null;
                               while((line = br.readLine()) != null){
                               myError += line + "<br>\n";
                               }
                             */
                            error_output(out, myError);
                        }
                        else{
                            String str = "", ret = "";
                            for (Iterator j=filenames.iterator(); j.hasNext(); ) {
                                String fn =  (String)j.next();
                                String fl = fn.toLowerCase();
                                //str += "<H4>" + html_title + "</H4>";   //html_title variable set in doAnalysis.jsp
                                if (fl.endsWith(".gif") || fl.endsWith(".jpg") || fl.endsWith(".png")) {
                                    str += "<img src=\"" + runDirURL + "/" + fn + "\">";
                                    scratchPlot = runDir + "/" + fn;
                                } else if (fl.endsWith(".svg")) {
                                    // We create a thumbnail and an image whose size is specified by the user.
                                    String pixelHeight = request.getParameter("plot_size");
                                    if (pixelHeight == null)
                                        pixelHeight = "500";
                                    int thumbHeight = 150;
                                    
                                    String svgPath = (new File(portal + "/" + runDirURL + "/" + fn)).toURL().toString();
                                    String fullSizePath = portal + "/" + runDirURL + "/" + fn.replaceAll(".svg", ".png");
                                    String fullSizeURL = runDirURL + "/" + fn.replaceAll(".svg", ".png");
                                    String thumbPath = portal + "/" + runDirURL + "/" + fn.replaceAll(".svg", "") + "_thm.png";
                                    String thumbURL = runDirURL + "/" + fn.replaceAll(".svg", "") + "_thm.png";

                                    try {
                                        // Convert the SVG image to PNG using the Batik toolkit.
                                        // Thanks to the Batik website's tutorial for this code (http://xml.apache.org/batik/rasterizerTutorial.html).
                                        PNGTranscoder trans = new PNGTranscoder();
                                        // Regular size image.
                                        trans.addTranscodingHint(PNGTranscoder.KEY_HEIGHT, new Float(pixelHeight));
                                        TranscoderInput input = new TranscoderInput(svgPath);
                                        OutputStream ostream = new FileOutputStream(fullSizePath);
                                        TranscoderOutput output = new TranscoderOutput(ostream);
                                        trans.transcode(input, output);
                                        ostream.flush();
                                        ostream.close();

                                        trans = new PNGTranscoder();
                                        // Thumbnail.
                                        trans.addTranscodingHint(PNGTranscoder.KEY_HEIGHT, new Float(thumbHeight));
                                        ostream = new FileOutputStream(thumbPath);
                                        output = new TranscoderOutput(ostream);
                                        trans.transcode(input, output);
                                        ostream.flush();
                                        ostream.close();
                                    } catch (Exception e) {
                                        out.write("<tr><td>Error: Failed to create plot from SVG file:<br>" + e.getMessage() + "</tr></td>");
                                        return;
                                    }
                                    str += "<img src=\"" + fullSizeURL + "\">";
                                    scratchPlot = fullSizePath;
                                    thumbnail = thumbPath;
                                }
                                else {
                                    FileReader fr = new FileReader(runDir + "/" + fn);
                                    String content = "";
                                    char[] buffer = new char[1024];
                                    int count;
                                    while ((count=fr.read(buffer, 0, 1024)) != -1) {
                                        content += String.valueOf(buffer, 0, count);
                                    }
                                    fr.close();
                                    str += "<FORM> ";
                                    str += "<TEXTAREA cols=60 rows=8 wrap=hard>";
                                    str += content;
                                    str += "</TEXTAREA>";
                                    str += "</FORM>";
                                }
                                str += "<BR>";
                            }
                            ret += "<CENTER><BR>";
                            ret += str;
                            ret += "</CENTER>";
%>
                            <TR><TD><%=ret%></TD></TR>
                            <TR><TD>&nbsp;</TD></TR>
                            <TR><TD>&nbsp;</TD></TR>
<%
                        }   //output shell scripts
                    } catch(IOException e){
                        out.println(e);
                        return;
                    }
                }   //run shell scripts
            }   //DV workflow
        }   //DV setup
    }   //Transformation setup
    if (dbschema != null)
        dbschema.close();
    if (vdc != null)
        ((DatabaseSchema)vdc).close();
    if (yschema != null)
        yschema.close();
}   //tr string
%>
