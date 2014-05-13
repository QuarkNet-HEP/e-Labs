<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ include file="common.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<%
/***********************************************************************
 *  Form to allow users to upload images created outside of our analysis
 *  system.
 * 
 *  This form is also used by Bluestone to "save" plots.   
 *  They are uploaded via HTTP POST, but to the user and our
 *  archive they are treated as a "plot" rather than an "uploadedimage"
 */

String name = "";           //user-input name of file, stored in metadata
String filename = "";       //unique name to be generated and saved in rc.data
String thumbFilename = "";  //thumbnail of "filename"
String origName = "";       //name of file on user's local machine
String ret = "";            //string which is returned to the user after an attempted file upload
boolean valid = true;       //false if there's any errors
String comments = "";       //optional comments on file
String upload_type = "uploadedimage";   // uploaded (external) or saved (internal)?

DiskFileUpload fu = new DiskFileUpload();
ArrayList meta = new ArrayList();
if (fu.isMultipartContent(request)) {
    fu.setSizeMax(10 * 1024 * 1024);    //10MB max

    FileItem uploadedImage = null;  //to be set in the loop

    java.util.List fileItems = fu.parseRequest(request);
    for (Iterator i = fileItems.iterator(); i.hasNext();) {
        FileItem fi = (FileItem) i.next();

        if (fi.isFormField()) {
            String fieldName = fi.getFieldName();

            if(fieldName.equals("name")){
                name = fi.getString();
                if(name.equals("")){
                    ret = "Please enter the name of your file.";
                    valid = false;
                }
		continue;		
            }
            if(fieldName.equals("comments")){
                comments = fi.getString();
		continue;
            }

	    if( fieldName.equals("upload_type") ){
	        upload_type = "savedimage";	// new default
		String x = fi.getString();  // only certain values are allowed  
		if( x.equals("savedimage") )    upload_type = x;
		if( x.equals("uploadedimage") ) upload_type = x;
		if( x.equals("plot") )          upload_type = "savedimage";
		continue;
	    }

	    if( fieldName.startsWith("metadata") ){
		String fieldValue = fi.getString();      
		meta.add(fieldValue);
		continue;
	    }

        }
        else{   //it's the uploaded file
            uploadedImage = fi;
            origName = fi.getName();
            if(fi.getSize() <= 0){
                ret = "Your image is 0 bytes in size. You must upload an image which contains some data!";
                valid = false;
            }
            // TODO: check MIME/type not filename extension.
            //      (or extension only if MIME/type fails.)
            if (!origName.toLowerCase().endsWith(".jpg") && !origName.toLowerCase().endsWith(".jpeg") 
            	&& !origName.toLowerCase().endsWith(".png") && !origName.toLowerCase().endsWith(".gif")) {
            	ret = "Invalid image type. Valid extensions are: .jpg, .jpeg, .png, .gif";
            	valid = false;
            }
            if(fi.getSize() > 5*1024*1024){
                ret = "Images must be 5MB or less in size.";
                valid = false;
            }
        }
    }
    if(valid){
        //generate a unique filename to save as (uploadedimage-group-date.extension format)
        GregorianCalendar gc = new GregorianCalendar();
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy.MMdd.HHmmss.SSSS");
        String extension = origName.substring(origName.lastIndexOf(".")+1);
        extension = extension.toLowerCase();
        String date = sdf.format(gc.getTime());

        filename = upload_type+"-" + groupName + "-" + date + "." + extension;
        thumbFilename = upload_type+"-" + groupName + "-" + date + "_thm." + extension;

        boolean added = addRC(filename, plotDir + filename);
        /*
           org.griphyn.vdl.annotation.Tuple t = getMetaKey(filename, "name");
           boolean isFile = (t == null) ? false : true;
           */
        int collision = 0;
        while(added == false && collision < 50){
            collision++;
            filename = upload_type+"-" + groupName + "-" + date + "-" + collision + "." + extension;
            thumbFilename = upload_type+"-" + groupName + "-" + date + "-" + collision + "_thm." + extension;
            added = addRC(plotDir + filename, filename);
            //t = getMetaKey(filename, "name");
            //isFile = (t == null) ? false : true;
        }
        if (added == false) {
            ret = "Too many users using the system at the moment. Please try your request again in a few seconds.";
            valid = false;
        }

        //register thumbnail image as well in the Catalog
        added = addRC(thumbFilename, plotDir + thumbFilename);

        //write the file
        if (valid) {
            File pdir = new File(plotDir);
            pdir.mkdirs();
            File f = new File(pdir, filename);
            uploadedImage.write(f);

            meta.add("origname string " + origName);
	    //TODO: allow 'savedimage' as synonym for 'plot'
            //      I consider this a workaround -EAM 20Apr2009
	    if( upload_type.equals("savedimage") ) upload_type = "plot";
	    	meta.add("type string "+ upload_type);
            meta.add("name string " + name);
            meta.add("group string " + groupName);
            meta.add("teacher string " + groupTeacher);
            meta.add("school string " + groupSchool);
            meta.add("city string " + groupCity);
            meta.add("state string " + groupState);
            meta.add("year string " + groupYear);
            meta.add("project string " + eLab);
            meta.add("filename string " + filename);
            
            //the reason for this is because the thumbnail does not get created
            //meta.add("thumbnail string " + thumbFilename);
            meta.add("thumbnail string " + filename);
            
            comments = comments.replaceAll("\r\n?", "\\\\n");   //replace new lines from text box with "\n"
          	//EPeronja-04/28/2014: do some sanitization
          	comments =ElabUtil.stringSanitization(comments, elab, "Upload Images");
            meta.add("comments string " + comments);       
            Date now = new Date();
            long millisecondsSince1970 = now.getTime();
            java.sql.Timestamp timestamp = new java.sql.Timestamp(millisecondsSince1970);
            meta.add("creationdate date " + timestamp.toString());

            boolean metaSuccess = setMeta(filename, meta);
            if(metaSuccess = false){
                ret = "There was an error while saving metadata.";
                valid = false;
            }
        }
    }
}
request.setAttribute("eLab", eLab);
%>
<html>
<head>
<title>Upload Image</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/posters.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
    
	<body id="posters" class="posters">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
<% if (user.isGuest()) { %>
	<h2>Guest User Message:</h2>
	<p>The 'guest' user account allows a tour of the e-labs and simple functions.</p>
	<p>If you are interested in full functionality, please request an account by filling
	   out this <a href="mailto:e-labs@fnal.gov?Subject=Please%20register%20me%20as%20an%20e-Labs%20teacher.&Body=Please%20complete%20each%20of%20the%20fields%20below%20and%20send%20this%20email%20to%20be%20registered%20as%20an%20e-Labs%20teacher.%20You%20will%20receive%20a%20response%20from%20the%20e-Labs%20team%20by%20the%20end%20of%20the%20business%20day.%0D%0DFirst%20Name:%0D%0DLast%20Name:%0D%0DCity:%0D%0DState:%0D%0DSchool:%0D%0De-Lab Name(s):%0D%0DDAQ%20board%20ID%20numbers%20(leave%20blank%20if%20not%20applicable;):%0D%0D">Email Form</a>. 
	</p>
<% } else { %>
<table border="0" id="main">
	<tr>
		<td id="left">
			<c:if test='${eLab == "ligo" }'>
				<%@ include file="../include/left-alt.jsp" %>
			</c:if>
		</td>
		<td id="center">
			<h1>Upload Image: Upload Images to use with Posters.</h1>
	        <br /><strong>Instructions</strong><br />
              <ul>
                  <li>Click <b>Choose File/Browse</b> to locate the data file on your computer.
                  <li>Give your file a <b>name to save as</b>.
                  <li>Click <b>Upload</b> to upload the file.
              </ul>
	        
	<hr>
	<% if(fu.isMultipartContent(request)) {
	   		 if(valid == false) { %>
				<font color="red"><%=ret%></font>
			<% } else { %>
	        You've successfully uploaded your image <i>
	        <a href="../plots/view.jsp?filename=<%=filename%>&get=data"><%=name%></a></i>
	<% } } else { %>
	    <span class="displayArial">
	        <form name="uploadform" method="post" enctype="multipart/form-data">
	        <table BORDER=0 WIDTH=500 CELLPADDING=4>
	            <tr><td align=center><%=ret%></td></tr>
	            <tr><td align="center">Image File: <input name="image" type="file" size="40"></td></tr>
	            <tr><td align="center">Name to save as: <input name="name" type="text" size="20" maxlength="30"></td></tr>
	            <tr><td align="center">Optional comments on image:</td></tr>
	            <tr><td align="center"><textarea name="comments" rows="8" cols="50"></textarea></td></tr>
	            <tr><td align="right"><input name="load" type="submit" value="Upload"></td></tr>
	        </table>
	        </form>
	    </span>
	<% } %>
</td></tr></table>

<% } %>	
			</div>
			<!-- end content -->	
		
			<div id="footer">
				<%@ include file="../include/nav-footer.jsp" %>
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
