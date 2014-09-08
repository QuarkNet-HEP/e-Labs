<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ include file="../login/login-required.jsp" %>
<%@ include file="../include/elab.jsp" %>
<%

String name = "";           //user-input name of file, stored in metadata
String filename = "";       //unique name to be generated and saved in rc.data
String label = "";			//label that will be used when this data is added to a graph
String origName = "";       //name of file on user's local machine
String message = "";            //string which is returned to the user after an attempted file upload
boolean valid = true;       //false if there's any errors
String comments = "";       //optional comments on file
String xunits = "";
String yunits = "";
String xaxis = "";
String yaxis = "";
String xaxisposition = "";
String yaxisposition = "";
String upload_type = "uploadeddata";   // uploaded (external) or saved (internal)?

DiskFileUpload fu = new DiskFileUpload();
ArrayList meta = new ArrayList();

if (fu.isMultipartContent(request)) {
    fu.setSizeMax(10 * 1024 * 1024);    //10MB max
    FileItem uploadedData = null;  //to be set in the loop
    java.util.List fileItems = fu.parseRequest(request);
    for (Iterator i = fileItems.iterator(); i.hasNext();) {
        FileItem fi = (FileItem) i.next();
		String fieldName = fi.getFieldName();

        if (fi.isFormField()) {
            if(fieldName.equals("comments")){
                comments = fi.getString();
            }
            if(fieldName.equals("datalabel")){
                label = fi.getString();
            }
            if(fieldName.equals("dataname")){
                name = fi.getString();
            }
            if(fieldName.equals("dataxunits")){
                xunits = fi.getString();
            }
            if(fieldName.equals("datayunits")){
                yunits = fi.getString();
            }
            if(fieldName.equals("dataxaxis")){
                xaxis = fi.getString();
            }
            if(fieldName.equals("datayaxis")){
                yaxis = fi.getString();
            }
            if(fieldName.equals("xaxisposition")){
            	xaxisposition = fi.getString();
            }
            if(fieldName.equals("yaxisposition")){
            	yaxisposition = fi.getString();
            } 
        }
        else{   //it's the uploaded file
        	uploadedData = fi;
            origName = fi.getName();
            if(fi.getSize() <= 0){
            	message = "Your data is 0 bytes in size. You must upload an file which contains some data!";
                valid = false;
            }
//            if (!origName.toLowerCase().endsWith(".jpg") && !origName.toLowerCase().endsWith(".jpeg") 
//            	&& !origName.toLowerCase().endsWith(".png") && !origName.toLowerCase().endsWith(".gif")) {
//            	ret = "Invalid image type. Valid extensions are: .jpg, .jpeg, .png, .gif";
//           	valid = false;
//            }
            if(fi.getSize() > 5*1024*1024){
            	message = "Images must be 5MB or less in size.";
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
		String groupName = user.getGroup().getName();		
        filename = upload_type+"-" + groupName + "-" + date + "." + extension;
		String plotDir = user.getDir("plots");
        File pdir = new File(plotDir);
        pdir.mkdirs();
        File f = new File(pdir, filename);
        uploadedData.write(f);
		DataCatalogProvider dcp = elab.getDataCatalogProvider();
		
		ElabGroup group = user.getGroup();
		
		// Default metadata for all files saved
    	meta.add("type string "+upload_type);
		meta.add("name string " + name);
        meta.add("group string " + groupName);
        meta.add("teacher string " + group.getTeacher());
        meta.add("school string " + group.getSchool());
        meta.add("city string " + group.getCity());
        meta.add("state string " + group.getState());
        meta.add("year string " + group.getYear());
        meta.add("project string " + elab.getName());
        meta.add("filename string " + filename);
        meta.add("label string " + label);
        meta.add("xunits string " + xunits);
        meta.add("yunits string " + yunits);
        meta.add("xaxisposition string " + xaxisposition);
        meta.add("yaxisposition string " + yaxisposition);
        meta.add("drawxaxis boolean " + xaxis);
        meta.add("drawyaxis boolean " + yaxis);
        meta.add("label string " + label);
        comments = comments.replaceAll("\r\n?", "\\\\n");   //replace new lines from text box with "\n"
        //EPeronja-04/28/2014: do some sanitization
       	comments =ElabUtil.stringSanitization(comments, elab, "Upload Images");
		meta.add("comments string " + comments);
        Date now = new Date();
        long millisecondsSince1970 = now.getTime();
        java.sql.Timestamp timestamp = new java.sql.Timestamp(millisecondsSince1970);
        meta.add("creationdate date " + timestamp.toString());
		dcp.insert(DataTools.buildCatalogEntry(filename, meta));
    }
}
request.setAttribute("message", message);
%>
<html>
<head>
<title>Upload External Data</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<link rel="stylesheet" type="text/css" href="../css/cosmic-plots.css" />
		<script type="text/javascript" src="../include/elab.js"></script>
		<script>
	    	function checkFields() {
				var goAhead = false;	
	    		var upload = document.getElementById("datafile");
	    		var uploadFile = upload.value;
	    		if (uploadFile == "") {
	    			goAhead = false;
	    		} else {
	    			goAhead = true;
	    		}
	    		if (!goAhead) {
	    			var msg = document.getElementById("msg");
	    			msg.innerHTML ='<font color="red">Please choose a file to upload</font>';
					return false;
	    		}
	    		var name = document.getElementById("dataname");
	    		if (name.value == "") {
	    			goAhead = false;
	    		} else {
	    			goAhead = true;
	    		}
	    		if (!goAhead) {
	    			var msg = document.getElementById("msg");
	    			msg.innerHTML ='<font color="red">Please give this file a name</font>';
					return false;
	    		}
	    		var label = document.getElementById("datalabel");
	    		if (label.value == "") {
	    			goAhead = false;
	    		} else {
	    			goAhead = true;
	    		}
	    		if (!goAhead) {
	    			var msg = document.getElementById("msg");
	    			msg.innerHTML ='<font color="red">Please give this data a label</font>';
					return false;
	    		}
	    		return goAhead;
	    	}
    	</script>
</head>   
	<body id="externalData" class="posters">
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
<table border="0" id="main">
	<tr>
		<td id="center">
			<h2>Guest User Message:</h2>
			<p>The 'guest' user account allows a tour of the e-labs and simple functions.</p>
			<p>If you are interested in full functionality, please request an account by filling
		  		 out this <a href="mailto:e-labs@fnal.gov?Subject=Please%20register%20me%20as%20an%20e-Labs%20teacher.&Body=Please%20complete%20each%20of%20the%20fields%20below%20and%20send%20this%20email%20to%20be%20registered%20as%20an%20e-Labs%20teacher.%20You%20will%20receive%20a%20response%20from%20the%20e-Labs%20team%20by%20the%20end%20of%20the%20business%20day.%0D%0DFirst%20Name:%0D%0DLast%20Name:%0D%0DCity:%0D%0DState:%0D%0DSchool:%0D%0De-Lab Name(s):%0D%0DDAQ%20board%20ID%20numbers%20(leave%20blank%20if%20not%20applicable;):%0D%0D">Email Form</a>. 
			</p>
		</td>
	</tr>
</table>
<% } else { %>
<table border="0" id="main">
	<tr>
		<td id="center">
			<h1>Upload External Data: Upload files to add to analysis plots.</h1>
	        <br /><strong>Instructions</strong><br />
              <ul>
                  <li>Click <b>Choose File/Browse</b> to locate the data file on your computer.
                  <li>Give your file a <b>name to save as</b>.
                  <li>Add a <strong>Label</strong> for this data to be used when graphed.</li>
                  <li>Click <b>Upload</b> to upload the file.
              </ul>
	        
	<hr>
	<% if(fu.isMultipartContent(request)) {
	   		 if(valid) { %>
	        You've successfully uploaded your data "<%=name%>"
	<% } } else { %>
	    <span class="displayArial">
	        <form name="uploadform" method="post" enctype="multipart/form-data">
	        <table BORDER=0 WIDTH=500 CELLPADDING=4>
	            <tr><td>Data File: <input name="datafile" id="datafile" type="file" size="40"></td></tr>
	            <tr><td>Name to save as: <input name="dataname" id="dataname" type="text" size="20" maxlength="30"></td></tr>
	            <tr><td>Label for this data: <input name="datalabel" id="datalabel" type="text"></td></tr>
	            <tr><td>Draw new X axis?<select name="dataxaxis" id="dataxaxis">
	            							<option value="false" selected="selected">No</option>
	            							<option value="true">Yes</option>
	            						</select>
	            </td></tr>
	            <tr><td>X axis units: <input name="dataxunits" id="dataxunits" type="text"></td></tr>
	            <tr><td>X axis position<select name="xaxisposition" id="xaxisposition">
	            							<option value="bottom" selected="selected">Bottom</option>
	            							<option value="top">Top</option>
	            						</select>
	            </td></tr>
	            <tr><td>Draw new Y axis?<select name="datayaxis" id="datayaxis">
	            							<option value="false" selected="selected">No</option>
	            							<option value="true">Yes</option>
	            						</select>
	            </td></tr>
	            <tr><td>Y axis units: <input name="datayunits" id="datayunits" type="text"></td></tr>
	            <tr><td>Y axis position<select name="yaxisposition" id="yaxisposition">
	            							<option value="left" selected="selected">Left</option>
	            							<option value="right">Right</option>
	            						</select>
	            </td></tr>
	            <tr><td>Optional comments on this data:</td></tr>
	            <tr><td><textarea name="comments" rows="8" cols="50"></textarea></td></tr>
	            <tr><td align="center"><input name="load" type="submit" value="Upload" onclick="return checkFields();"></td></tr>
	            <tr><td align="center"><div id="msg">${message }</div></td></tr>
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
