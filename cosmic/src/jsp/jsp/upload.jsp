<%@ page buffer="1000kb" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.griphyn.vdl.util.ChimeraProperties" %>
<%@ page import="org.griphyn.vdl.dbschema.*" %>
<%@ page import="org.griphyn.vdl.directive.*" %>
<%@ page import="org.griphyn.vdl.annotation.*" %>
<%@ page import="java.sql.*" %>
<%@ include file="common.jsp" %>

<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>

<%
    //check if this group can upload (is an "upload" role or greater)
    String userRole = (String)session.getAttribute("role");
    String groupID = (String)session.getAttribute("groupID");
    ArrayList detectorIDs = new ArrayList();
    if(userRole != null && (userRole.equals("upload") || userRole.equals("teacher"))){
        //get group's detector list from postgres
        rs = s.executeQuery("SELECT detectorid FROM research_group_detectorid WHERE research_group_id='" + groupID + "' ORDER BY detectorid");
        if(rs.next() == false){
            warn(out, "Your group does not have any detector IDs associated with it.</font><br> This is done when your group is first created.<br><br>");
            out.write("<a href=home.jsp>Go Back</a>");
            return;
        }
        else{
            //create Array of detector IDs
            detectorIDs.add(rs.getString(1));
            while(rs.next() != false){
                detectorIDs.add(rs.getString(1));
            }
        }
    }
    else{
    warn(out, "Sorry, your group is not able to upload data.</font><br>\n" + groupName +" only has a " + userRole + " role.<br><br>");
        out.write("<a href=home.jsp>Go Back</a>");
        return;
    }

String lfn="";              //lfn on the USERS home computer 
String fn = "";             //filename without slashes
String ds = "";
String rawName = "";        //raw name of file we'll be writting on the system
boolean valid = true;       //false if there is any error in the page
String ret = "";            //return string if theres an error
String id = "";             //detector id
String comments = "";       //optional comments on raw data file
//HashMap dsMap = new HashMap();
ArrayList splitLFNs = new ArrayList();  //for both the split name and the channel validity information

if (FileUpload.isMultipartContent(request)) {
    DiskFileUpload fu = new DiskFileUpload();
    // maximum size before a FileUploadException will be thrown
    fu.setSizeMax(500*1024*1024);   //500MB
    // maximum size that will be stored in memory
    fu.setSizeThreshold(4096);

    java.util.List fileItems = fu.parseRequest(request);

    Iterator it = fileItems.iterator();

    while (it.hasNext()) { 
        FileItem fi = (FileItem)it.next();
        if (fi.isFormField()) {
            String field = fi.getFieldName();
            if (field.equals("detector")) {
                id = fi.getString();
                if(id.equals("")){
                    ret = "<CENTER><FONT color= red face=arial>" + 
                        "You must enter a detector number for this data." +
                        "</FONT><BR><BR></CENTER>";
                    valid = false;
                }
            }
            if(field.equals("comments")){
                comments = fi.getString();
            }
        }
        else {
            lfn = fi.getName();
            if (lfn.equals("")) {
                valid = false;
                break;
            }
            //fn is the filename without slashes (which lfn has)
            int i = lfn.lastIndexOf('\\');
            int j = lfn.lastIndexOf('/');
            i = (i>j) ? i:j;
            if (i != -1) {
                fn = lfn.substring(i+1);
            } 
            if (fi.getSize() > 0) {
                //fn=fn.replace(' ', '_');       //replace spaces with underscores
                //fn=fn.replaceAll("%20", "_");       //replace spaces with underscores
                
                //new algorithm for filenaming:
                //name the raw file id.yyyy.mmdd.index.raw and save the original name in metadata
                //index starts at 0 and increments when there are collisions with other filenames
                int index = 0;
                GregorianCalendar cal = new GregorianCalendar();
                String tempRunDir = "";
                String year = cal.get(Calendar.YEAR) + "";
                String month = 1 + cal.get(Calendar.MONTH) + "";
                if(month.length() == 1){
                    month = "0" + month;
                }
                String day = cal.get(Calendar.DAY_OF_MONTH) + "";
                if(day.length() == 1){
                    day = "0" + day;
                }
                File f = new File(dataDir + id + "." + year + "." + month + day + "." + index + ".raw");
                while(f.exists()){
                    index++;
                    f = new File(dataDir + id + "." + year + "." + month + day + "." + index + ".raw");
                }
                rawName = id + "." + year + "." + month + day + "." + index + ".raw";

                // write the file
                if(f.createNewFile()){
                    fi.write(f);
                    valid = true;
                    //add raw file to rc.data
                    boolean RCupdated = addRC(rawName, dataDir + rawName);
                    out.println("<!-- " + rawName + " added to Catalog -->");
                }
                else{
                    valid = false;
                    ret = "<CENTER><FONT color= red>" +
                        "Cannot write the file \"" + f + "\" on the filesystem...contact the administrator about this error." +
                        "</FONT><BR><BR></CENTER>";
                }

            }
            else {
                valid = false;
                ret = "<CENTER><FONT color= red>" +
                    "Your file is zero-length. You must upload a file which has some data." +
                    "</FONT><BR><BR></CENTER>";
            } 
        } 
    }

    if (valid) {
        boolean c = true;
        String splitPFNs = "";
        String threshPFNs = "";
        String threshLFNs = "";
        String cpldFrequency = "";
        //Split is in the portal.appdir along with the rest of our "Applications"
        String appDir = (String)System.getProperty("portal.appdir");
        // This command is here to clean the Mac/DOS style line breaks
        // Probably could be done better, but this works for now.
        String[] cmd0 = new String[]{"bash", "-c", "/usr/bin/perl -pi -e 's/\\r\\n?/\\n/g' " + dataDir+rawName};
        String[] cmd = new String[]{"bash", "-c", appDir + "Split.pl " + "\"" + dataDir+rawName + "\"" + " " + dataDir+id + " " + id};
        String[] cmdCompress = new String[]{"bash", "-c",  "gzip " + dataDir + rawName + " &"};
        Process p0 = Runtime.getRuntime().exec(cmd0);
        int garbage = p0.waitFor();
        Process p = Runtime.getRuntime().exec(cmd);
        garbage = p.waitFor();
        Process p1 = Runtime.getRuntime().exec(cmdCompress);
        int r = -1;
        boolean splitDone = false;
        // Reading the standard output of the process as much and as often as possible should keep us from deadlocking.
        // See http://java.sun.com/j2se/1.4.2/docs/api/java/lang/Process.html.
        BufferedReader stdout = new BufferedReader(new InputStreamReader(p.getInputStream()));
        String throwAway;
        // This while block solves the problem of browser timeout by sending a "heartbeat" back to
        // the browser in the form of a comment.
        while (!splitDone) {
            try {
                r = p.exitValue();
                splitDone = true;
                while ((throwAway = stdout.readLine()) != null) { }
            }
            catch (IllegalThreadStateException ex) {
                while ((throwAway = stdout.readLine()) != null) { } 
                out.println("<!-- Split running... -->");
                //out.write("<script>showProgress();</script>");
                out.flush(); // necessary to send to client immediately.
                Thread.sleep(500); // sleep for half of a second.  Want to change?
            }
        }
        stdout.close();
        
        if (r != 0) {
            ret = "<CENTER><FONT color= red>" +
                "Error splitting data..." +
                "</FONT><BR><BR></CENTER>";
            BufferedReader br = new BufferedReader(new InputStreamReader(p.getErrorStream()));
            String str;
            while ((str=br.readLine()) != null) {
                ret += str + "<BR>";
            }
            br.close();
            c = false;
        }
        else {      //Split.pl success!
            

            //get metadata which contains the lfns of the raw filename AND the split files
            ArrayList meta = null;
            boolean metaSuccess = false;
            boolean totalSuccess = true;        //false if there are any rc.data or meta errors
            File fmeta = new File(dataDir + rawName + ".meta");     //depends on Split.pl writing the meta to rawName.meta
            if (fmeta.canRead()) {
                BufferedReader br = new BufferedReader(new FileReader(fmeta));
                String line = null;
                String currLFN = null;
                String currPFN = null;
                while ((line = br.readLine())!=null) {
                    String[] temp = line.split("\\s", 3);

                    //if this is a new lfn to add...
                    if(temp[0].equals("[SPLIT]") || temp[0].equals("[RAW]")){
                        //add metadata if we have all the information for a previous LFN
                        if(meta != null && currLFN != null){
                            try{
                                metaSuccess = setMeta(currLFN, meta);
                            } catch(ElabException e){
                                ret = "<CENTER><FONT color= red>" +
                                    "Error setting metadata: " + e.getMessage() +
                                    "</FONT><BR><BR></CENTER>";
                            }
                            if(!metaSuccess){
                                totalSuccess = false;
                            }
                        }

                        //start a new metadata array
                        meta = new ArrayList();
                        currPFN = temp[1];
                        currLFN = temp[1].substring(temp[1].lastIndexOf('/') + 1);
                        if(temp[0].equals("[RAW]")){
                            //don't write the raw datafile to rc.data - already written above
                        }
                        else if(temp[0].equals("[SPLIT]")){
                            // Add split physical file name to array list used by ThresholdTimes.
                            splitPFNs += currPFN + " ";
                            threshPFNs += currPFN + ".thresh" + " ";
                            threshLFNs += currLFN + ".thresh" + " ";
                            //add the split file to rc.data
                            try{
                                boolean RCupdated = addRC(currLFN, currPFN);
                                out.println("<!-- " + currLFN + " added to Catalog -->");
                            } catch(ElabException e){
                                totalSuccess = false;
                                ret = "<CENTER><FONT color= red>" +
                                    "Error updating rc Catalog: " + e.getMessage() +
                                    "</FONT><BR><BR></CENTER>";
                            }
                            splitLFNs.add(currLFN);
                        }

                        //metadata for both RAW and SPLIT files
                        meta.add("origname string " + lfn); //add in the original name from the users computer to metadata
                        meta.add("blessed boolean false");
                        meta.add("group string " + groupName);
                        meta.add("teacher string " + groupTeacher);
                        meta.add("school string " + groupSchool);
                        meta.add("city string " + groupCity);
                        meta.add("state string " + groupState);
                        meta.add("year string " + groupYear);
                        meta.add("project string " + eLab);
                        comments = comments.replaceAll("\r\n?", "\\\\n");   //replace new lines from text box with "\n"
                        meta.add("comments string " + comments);
                    }
                    else{
                        meta.add(line);
                        String[] tmp = line.split("\\s", 3);
                        if (tmp[0].equals("cpldfrequency"))
                            cpldFrequency += tmp[2] + " ";
                    }
                }   //done reading file

                //do one last add at the end of reading the temp metadata file
                if(meta != null && currLFN != null){
                    metaSuccess = setMeta(currLFN, meta);
                }
            }
            else{
                metaSuccess = false;
                ret = "<CENTER><FONT color= red>" +
                    "Error reading metadata file: " + dataDir + rawName + ".meta" +
                    "</FONT><BR><BR></CENTER>";
            }

            if (totalSuccess){
                ret = "<CENTER><H3>Upload Successfull!</H3><br>";
                
                java.util.List metaList = getMeta(rawName);
                HashMap metaHash = new HashMap();
                for(Iterator i = metaList.iterator(); i.hasNext(); ){
                    Tuple t = (Tuple)i.next();
                    metaHash.put(t.getKey(), t.getValue());
                }
                
                if(geoFileExists(Integer.parseInt(id), dataDir)){
                    ret += "If you have <b>changed</b> the configuration of your detector since your last upload, please check to make sure that your <br>" + 
                        "<a href=\"geo.jsp?fromupload=1&id=" + 
                        id + 
                        "&jd=" + metaHash.get("julianstartdate") + 
                        "&latitude=" + metaHash.get("avglatitude") + 
                        "&longitude=" + metaHash.get("avglongitude") +
                        "&altitude=" + metaHash.get("avgaltitude") +
                        "\">Geometry Information</a> was updated correctly.<br>\n<br>";
                }
                else{
                    ret += "This looks like the first file you've uploaded for detector " + id + ".<br>";
                    ret += "Please check to make sure that your <a href=\"geo.jsp?fromupload=1&id=" + 
                        id + 
                        "&jd=" + metaHash.get("julianstartdate") + 
                        "&latitude=" + metaHash.get("avglatitude") + 
                        "&longitude=" + metaHash.get("avglongitude") +
                        "&altitude=" + metaHash.get("avgaltitude") +
                        "\">Geometry Information</a> was updated correctly.<br>\n<br>";
                }
                //ret += "<TABLE BORDER=0 WIDTH=500 CELLPADDING=4>";
                //ret += "<TR><TD align=center>";
                ret += "<hr>";
                ret += "<h3>File Summary:</h3><br>";
                
                ret += "Your data was split into " + splitLFNs.size() + " days spanning from:<br>";
                ret += metaHash.get("startdate") + " &nbsp to &nbsp " + metaHash.get("enddate") + "</center><br>";

                int Chan1 = 0, Chan2 = 0, Chan3 = 0, Chan4 = 0;
                for(int i=0; i<splitLFNs.size(); i++){
                    java.util.List splitMetaList = getMeta((String)splitLFNs.get(i));
                    HashMap splitMetaHash = new HashMap();
                    for(Iterator j = splitMetaList.iterator(); j.hasNext(); ){
                        Tuple t = (Tuple)j.next();
                        splitMetaHash.put(t.getKey(), t.getValue());
                    }

                    Chan1 += ((Long)splitMetaHash.get("chan1")).intValue();
                    Chan2 += ((Long)splitMetaHash.get("chan2")).intValue();
                    Chan3 += ((Long)splitMetaHash.get("chan3")).intValue();
                    Chan4 += ((Long)splitMetaHash.get("chan4")).intValue();

                    //Chan1 += c1.intValue();
                    //Chan2 += c2.intValue();
                    //Chan3 += c3.intValue();
                    //Chan4 += c4.intValue();
                }
                
                ret += "<table border=1 cellpadding=5>";
                ret += "<tr><td></td><td align=center>Chan 1</td><td align=center>Chan 2</td><td align=center>Chan 3</td><td align=center>Chan 4</td></tr>";
                ret += "<td align=center>Total Events</td><td align=center>" + Chan1 + "</td><td align=center>" + Chan2 + "</td><td align=center>" + Chan3+ "</td><td align=center>" + Chan4 + "</td></tr>";
                ret += "</table><br>";
                
                if(((String)metaHash.get("avglatitude")).equals("0")){   //if it were truly 0, it would be 0.0.0 in the metadata
                    ret += "No valid GPS information found in your data.<br>Either the \"DG\" command was not run or the GPS did not see enough satellites.<br><br>\n";
                }
                else{
                    if(((String)metaHash.get("avglatitude")).charAt(0) == '-'){
                        ret += "Average latitude: " + ((String)metaHash.get("avglatitude")).substring(1) + " S" + "<br>";
                    }
                    else{
                        ret += "Average latitude: " + metaHash.get("avglatitude") + " N" + "<br>";
                    }
                    if(((String)metaHash.get("avglongitude")).charAt(0) == '-'){
                        ret += "Average longitude: " + ((String)metaHash.get("avglongitude")).substring(1) + " W" + "<br>";
                    }
                    else{
                        ret += "Average latitude: " + metaHash.get("avglatitude") + " E" + "<br>";
                    }
                    ret += "Average altitude: " + metaHash.get("avgaltitude") + "m" + "<br><br>";
                }
            }
            else{
                ret = "<CENTER><H3>There was an error while uploading and analyzing your file...</H3></CENTER>";
            }
            //ret += "</TD></TR>";
            // Run ThresholdTimes on each split file.
            String[] tPFNs = (threshPFNs.trim()).split(" ");
            String[] tLFNs = (threshLFNs.trim()).split(" ");
            int numFiles = tPFNs.length;
            String boardIDs = "";
            for (int j = 0; j < numFiles; j++)
                boardIDs += id + " ";
            cmd = new String[]{
                "bash", 
                "-c", 
                appDir + "ThresholdTimes.pl \"" + splitPFNs.trim() + "\" \"" + 
                    threshPFNs.trim() + "\" \"" + boardIDs.trim() + "\" \"" + cpldFrequency.trim() + "\""};
            p = Runtime.getRuntime().exec(cmd);
            r = -1;
            boolean threshDone = false;
            // Reading the standard output of the process as much and as often 
            // as possible should keep us from deadlocking.  See 
            // http://java.sun.com/j2se/1.4.2/docs/api/java/lang/Process.html.
            stdout = new BufferedReader(new InputStreamReader(p.getInputStream()));
            // This while block solves the problem of browser timeout by sending a "heartbeat" back to
            // the browser in the form of a comment.
            while (!threshDone) {
                try {
                    r = p.exitValue();
                    threshDone = true;
                    while ((throwAway = stdout.readLine()) != null) {out.println("<!-- stdout from running ThresholdTimes.pl: " + throwAway + "-->"); }
                }
                catch (IllegalThreadStateException ex) {
                    while ((throwAway = stdout.readLine()) != null) {out.println("<!-- stdout from running ThresholdTimes.pl: " + throwAway + "-->"); }
                    out.println("<!-- ThresholdTimes running... -->");
                    //out.write("<script>showProgress();</script>");
                    out.flush(); // necessary to send to client immediately.
                    Thread.sleep(500); // sleep for half of a second.  Want to change?
                 }
            }
	        stdout.close();
            if (r != 0) {
                 ret = "<CENTER><FONT color= red>" +
                     "Error threshing data..." +
                     "</FONT><BR><BR></CENTER>";
                 BufferedReader br = new BufferedReader(new InputStreamReader(p.getErrorStream()));
                 String str;
                 while ((str=br.readLine()) != null) {
                     ret += str + "<BR>";
                 }
                 br.close();
                 c = false;
            }
            else {
                // Now that ThresholdTimes has completed, we can add the thresh files to rc.data.
                for (int i = 0; i < numFiles; i++) {
                    addRC(tLFNs[i], tPFNs[i]);
                    out.println("<!-- " + tLFNs[i] + " added to Catalog -->");
                }
            }
        }   //end "Split.pl perl success"
    }   //end "upload file is valid"
}   //end "if form has a file to upload"
else {
    valid = false;
}
%>
<html>
<!--Checked by Paul Nepywoda on 6-11-04 for conformance to coding-style.doc -->
<head>
<title>Upload Raw Data</title>
<script language=JavaScript>
	function showProgress()
	{
		if(progressBar) progressBar.style.visibility = 'visible';
	}
    function hideProgress()
    {
        if(progressBar) progressBar.style.visibility = 'hidden';
    }
</script>
<style>
.progressBar
{
	visibility:hidden;
	border-right: activeborder thin outset;
	border-top: activeborder thin outset;
	font-size: x-small;
	z-index: 1003;
	left: 40%;
	border-left: activeborder thin outset;
	border-bottom: activeborder thin outset;
	font-family: Verdana, Arial;
	position: absolute;
	top: 35%;
	border-collapse: collapse;
	background-color: #F0F0E9;	
	width: 200px;
	height: 50px;
	text-align: center;
}
.displayArial
{
	font-family: Arial, Verdana ;
	font-size: small;

}
</style>
<!-- include css style file -->
<%@ include file="include/style.css" %>

<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Upload";
%>
<%@ include file="include/navbar_common.jsp" %>

<BODY OnLoad="hideProgress()" onunload="hideProgress()">
    <P><CENTER>

<span class="progressBar" ID="progressBar"><p>Uploading Data. Do not leave page.</p>
	<OBJECT codeBase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,0,0"  height="7" width="78" align="middle" classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000">
		<PARAM NAME="Movie" VALUE="graphics/loading.swf"></PARAM>
		<PARAM NAME="Src" VALUE="graphics/loading.swf"></PARAM>
		<IMG SRC="graphics/loading.gif">
	</OBJECT>
</span>

    <!-- instruction table -->
   <P> <TABLE BORDER=0 WIDTH=800 CELLPADDING=4>
        <TR><TD BGCOLOR="#AB449B">
                <FONT COLOR=000000 face=arial SIZE=+1><B>Upload Raw Data Collected by Cosmic Ray Detector.</B>
        </TD></TR>
    </TABLE>

    <span class="displayArial">
    <FORM name="uploadform" method="post" enctype="multipart/form-data" onSubmit="showProgress()">
    <!-- file, detector, and upload table -->
    <TABLE BORDER=0 WIDTH=500 CELLPADDING=4>
        <TR><TD align=center>
        <%=ret%>
        </TD></TR>
<%
        if (!valid) {
%>          
   <P> <TABLE BORDER=0 WIDTH=800 CELLPADDING=4>
        <TR><TD><font face=arial size="-1">
                    <UL>
                        <LI>Select the <b>detector</b> associated with the data you are uploading.
                        <LI>Click <b>Choose File/Browse</b> to locate the data file on your computer.
                        <LI>Click <b>Upload</b> to upload the file.
                </UL>
        </TD></TR> 
        </TABLE>
        <TABLE BORDER=1 WIDTH=500 CELLPADDING=4>
            <TR><td align="center">
                Choose <b>detector:</b>
                <select name="detector">
<%
                    for(Iterator i=detectorIDs.iterator(); i.hasNext();){
                        String currID = (String)i.next();
                        out.write("<option value=\"" + currID + "\">" + currID + "</option>");
                    }
%>
                </select>
                <br><br>
            Raw Data File: <input name="ds" type="file" size="15">
            <br><br>
            Optional comments on raw data:<br>
            <textarea name="comments" rows="8" cols="50"></textarea>
            </td></tr>
            <tr><td align="right">
                <input name="load" type="submit" value="Upload">
            </td></tr>
<%
        }
if (s != null)
    s.close();
if (conn != null)
    conn.close();
%>
    </table>
</FORM></span>
</center>
</BODY>
</HTML>
