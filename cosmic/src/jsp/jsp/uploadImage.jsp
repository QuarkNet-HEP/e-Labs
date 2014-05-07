<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ include file="common.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ include file="../include/elab.jsp" %>

<%
String name = "";           //user-input name of file, stored in metadata
String filename = "";       //unique name to be generated and saved in rc.data
String thumbFilename = "";  //thumbnail of "filename"
String origName = "";       //name of file on user's local machine
String ret = "";            //string which is returned to the user after an attempted file upload
boolean valid = true;       //false if there's any errors
String comments = "";       //optional comments on file
DiskFileUpload fu = new DiskFileUpload();
//Policy policy = Policy.getInstance(Elab.class.getClassLoader().getResource("antisamy-i2u2.xml").openStream());
//AntiSamy as = new AntiSamy();

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
            }
            if(fieldName.equals("comments")){
                comments = fi.getString();
            }
        }
        else{   //it's the uploaded file
            uploadedImage = fi;
            origName = fi.getName();
            if(fi.getSize() <= 0){
                ret = "Your image is 0 bytes in size. You must upload an image which contains some data!";
                valid = false;
            }
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

        filename = "uploadedimage-" + groupName + "-" + date + "." + extension;
        thumbFilename = "uploadedimage-" + groupName + "-" + date + "_thm." + extension;

        boolean added = addRC(filename, plotDir + filename);
        /*
           org.griphyn.vdl.annotation.Tuple t = getMetaKey(filename, "name");
           boolean isFile = (t == null) ? false : true;
           */
        int collision = 0;
        while(added == false && collision < 50){
            collision++;
            filename = "uploadedimage-" + groupName + "-" + date + "-" + collision + "." + extension;
            thumbFilename = "uploadedimage-" + groupName + "-" + date + "-" + collision + "_thm." + extension;
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

            /*
             * FIXME NoClassDefFoundError when trying to use ImageInfo
            //create & write thumbnail image
            try{
            ImageInfo info = new ImageInfo(plotDir + filename);
            MagickImage image = new MagickImage(info);
            MagickImage thumbImage = image.scaleImage(150, 150);
            thumbImage.setFileName(plotDir + thumbFilename);
            thumbImage.writeImage(info);
            } catch(Exception e){
                e.printStackTrace();
                out.write("except: " + e + " " + e.getMessage());
            }
            */
            //FIXME this is a big hack to get around the above error...
            /*
             * except I can't for the life of me get it to work from the web....only the terminal
            String[] cmd = new String[]{"bash", "-c", "'cd " + home + "/cosmic; " + 
                "env CLASSPATH=.:/usr/local/quarknet-dev/jakarta-tomcat-5.0.18/webapps/elab/WEB-INF/lib/jmagick.jar LD_LIBRARY_PATH=/home/nepywoda/JM/lib " + 
                    "java magickmake " + 
                    plotDir+filename + " " + plotDir+thumbFilename + "'"};
            Process p = Runtime.getRuntime().exec(cmd);
            int ret_val = p.waitFor();
            if(ret_val != 0) {
                out.write("wasn't able to create the thumbnail with: " + cmd[0] + cmd[1] + cmd[2]);
            }
            */


            ArrayList meta = new ArrayList();
            meta.add("origname string " + origName);
            meta.add("type string uploadedimage");
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
          	comments=ElabUtil.stringSanitization(comments, elab, "Upload Images");
          	/*
          	ArrayList checkDirtyInput = as.scan(comments,policy).getErrorMessages();
          	if (!checkDirtyInput.isEmpty()) {
    			String userInput = comments;
    			int errors = as.scan(userInput, policy).getNumberOfErrors();
    			ArrayList actualErrors = as.scan(userInput, policy).getErrorMessages();
    			Iterator iterator = actualErrors.iterator();
    			String errorMessages = "";
    			while (iterator.hasNext()) {
    				errorMessages = (String) iterator.next() + ",";
    			}
    			comments = as.scan(comments, policy).getCleanHTML();
		    	//send email with warning
		    	String to = elab.getProperty("notifyDirtyInput");
	    		String emailmessage = "", subject = "Add comments: user sent dirty input";
	    		String emailBody =  "User input: "+userInput+"\n" +
 						   			"Number of errors: "+String.valueOf(errors)+"\n" +
 				   					"Error messages: "+ errorMessages + "\n" +
 				   					"Validated input: "+comments + "\n";
			    try {
			    	String result = elab.getUserManagementProvider().sendEmail(to, subject, emailBody);
			    } catch (Exception ex) {
	                System.err.println("Failed to send email");
	                ex.printStackTrace();
			    }		    		
		  	}//end of sanitization
            */
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
%>

<html>
<head>
<title>Upload Image</title>
    
<!-- include css style file -->
<%@ include file="include/style.css" %>

<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Posters";
%>
<%@ include file="include/navbar_common.jsp" %>

<body>
<center>
<P>
<!-- instruction table -->
<TABLE BORDER=0 WIDTH=800 CELLPADDING=4>
    <TR>
        <TD BGCOLOR="#408C66">
            <FONT COLOR=000000 face=arial SIZE=+1>
                <B>Upload Image: Upload images to use with Posters.</B>
            </FONT>
        </TD>
    </TR>
    <tr><td> </td></tr>
    <tr>
        <td>
            <font face="arial" size="-1">
                <ul>
                    <li>Click <b>Choose File/Browse</b> to locate the data file on your computer.
                    <li>Give your file a <b>name to save as</b>.
                    <li>Click <b>Upload</b> to upload the file.
                </ul>
            </font>
        </td>
    </tr>
</TABLE>

<br>
<HR>
<%
if(fu.isMultipartContent(request)){
    if(valid == false){
%>
        <font color="red"><%=ret%></font>
<%
    }
    else{
%>
        You've successfully uploaded your image <i>
        <a href="../plots/view.jsp?filename=<%=filename%>&get=data"><%=name%></a></i>
<%
    }
}
else{
%>
    <span class="displayArial">
        <FORM name="uploadform" method="post" enctype="multipart/form-data">
        <TABLE BORDER=0 WIDTH=500 CELLPADDING=4>
            <TR>
                <TD align=center>
                <%=ret%>
                </TD>
            </TR>
            <tr>
                <td align="center">
                    Image File: <input name="image" type="file" size="40">
                </td>
            </tr>
            <tr>
                <td align="center">
                    Name to save as: <input name="name" type="text" size="20" maxlength="30">
                </td>
            </tr>
            <tr>
                <td align="center">
                    Optional comments on image:
                </td>
            </tr>
            <tr>
                <td align="center">
                    <textarea name="comments" rows="8" cols="50"></textarea>
                </td>
            </tr>
            <tr>
                <td align="right">
                    <input name="load" type="submit" value="Upload">
                </td>
            </tr>
        </TABLE>
        </FORM>
    </span>
<%
}
%>
</center>
</body>
</html>
