<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/teacher-login-required.jsp" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%@ page import="com.Ostermiller.util.*" %>
<%@ page import="org.apache.commons.lang.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Register Students</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="mass-registration" class="teacher">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav-teacher.jsp" %>
					</div>
				</div>
			</div>
			
			<div id="content">

<h1>e-Lab Mass Registration</h1>
<%
	if (ServletFileUpload.isMultipartContent(request)) {
	    try {
	    	DiskFileItemFactory factory = new DiskFileItemFactory();
	    	ServletFileUpload upload = new ServletFileUpload(factory);
	    	
	    	upload.setSizeMax(50*1024);			// 50KiB max
	    	factory.setSizeThreshold(4096);	
	    	
	    	List<FileItem> fileItems = upload.parseRequest(request);
	    	
	    	for (FileItem file : fileItems) {
	    		String regFile = file.getName();
	    		if (StringUtils.isBlank(regFile)) continue; 
	    		File f = File.createTempFile("upload", ".csv");
	    		if (file.getSize() > 0) {
	    			// write the file
	    			file.write(f);
	    			// Strip the file of Mac or MS-DOS line breaks.
	    			String[] cmd = new String[]{"bash", "-c", "/usr/bin/perl -pi -e 's/\\r\\n?/\\n/g' " + 
	    				f.getAbsolutePath()};

	    			Process p = Runtime.getRuntime().exec(cmd);
	    			if (p.waitFor() != 0) {
	    				throw new ElabJspException("Cannot clean line breaks from the file \"" + f.getAbsolutePath() 
	    					+ "\" on the filesystem. Please contact the administrator about this error.");
	    			}

	    			// Parse the registration file.
	    			LabeledCSVParser lcsvp = null;
	    			try { 
	    				String appType = request.getParameter("application_type");
	    				if (appType != null && appType.equals("other")) {
	    					lcsvp = new LabeledCSVParser(new CSVParser(new FileReader(f)));
	    				}
	    				else {
	    					lcsvp = new LabeledCSVParser(new ExcelCSVParser(new FileReader(f)));
	    				}
	    			}
	    			catch (IOException e) {
	    				throw new ElabJspException("Error reading file \"" + f.getAbsolutePath() 
	    					+ "\". Please contact the administrator about this error.");
	    			} 
	    		
	    			List students = new ArrayList();
	    	        List newGroups = new ArrayList();
	    			while (lcsvp.getLine() != null) {
	    				String last = lcsvp.getValueByLabel("Last Name");
	    				String first = lcsvp.getValueByLabel("First Name");
	    				String resName = lcsvp.getValueByLabel("Research Group Name");
	    				String upload = lcsvp.getValueByLabel("Upload");
	    				String survey = lcsvp.getValueByLabel("In Survey");
	    			
	    				if (last == null || first == null || resName == null ||
	    					last.equals("") || first.equals("") || resName.equals("")) {
	    				    throw new ElabJspException("An error has occurred while parsing row " 
	    			            + lcsvp.getLastLineNumber() + ". "
	    			            + "Please make sure your file conforms to the format shown in the example "
	    			            + "and that it was saved in the <strong>CSV</strong> format.");
	    				}
	    		
	    				ElabStudent newStudent = new ElabStudent();
	    				first = first.replaceAll(" ", "").toLowerCase();
	    				last = last.replaceAll(" ", "").toLowerCase();
	    				String studentName = first.substring(0, 1) + last.substring(0, (last.length() < 7 ? last.length() : 7));
	    		
	    				newStudent.setName(studentName);

	    				ElabGroup group = new ElabGroup(elab);
	    				newStudent.setGroup(group);
	    				group.setName(resName);
	    				if ("yes".equalsIgnoreCase(upload) || "true".equalsIgnoreCase(upload)) {
	    				    group.setRole(ElabUser.ROLE_UPLOAD);
	    				}
	    				group.setSurvey(false);
	    				group.setStudy(false);
	    				group.setNewSurvey("yes".equalsIgnoreCase(survey) || "true".equalsIgnoreCase(survey));
	    				students.add(newStudent);
	    				//as far as I understand from the old code, with the mass registration, the 
	    				//groups are always created
	    				newGroups.add(true);
	    			}
	    			List passwords = elab.getUserManagementProvider().addStudents(user, students, newGroups);
	    			List results = new ArrayList();
	    			Iterator i = students.iterator(), j = passwords.iterator();
	    			while (i.hasNext()) {
	    				String password = (String) j.next();
	    				ElabStudent u = (ElabStudent) i.next();
	    		    	if (password != null) {
	    		        	List l = new LinkedList();
	    			        l.add(u.getGroup().getName());
	    			        l.add(password);
	    			        results.add(l);
	    		    	}
	    			}
	    			request.setAttribute("valid", Boolean.TRUE);
	    			request.setAttribute("results", results);
	    			break;
	    		}
	    	}
		}
		catch (Exception e) {
			request.setAttribute("valid", Boolean.FALSE);
			request.setAttribute("error", e.getMessage());
		}

%>
			<c:choose>
				<c:when test="${valid}">
					<p class="success">Your student registration completed succesfully.</p>
					<p>
						The groups we created for you (and their associated passwords) are listed below.
					</p>
					<p>
					    If one of the groups you requested already existed in our project, your group name was altered
					    slightly to ensure uniqueness.  You may now use the File...Save feature in your browser to save
					    the information below.
					</p>
					<table border="0" id="registration-results">
						<tr>
							<th>Group Name</th>
							<th>Password</th>
						</tr>
						<c:forEach items="${results}" var="result">
							<tr>
								<td>${result[0]}</td>
								<td>${result[1]}</td>
							</tr>
						</c:forEach>
					</table>
				</c:when>
				<c:otherwise>
					<p class="error">A problem occured while registering with your students:</p>
					<p class="error">${error}</p>
				</c:otherwise>
			</c:choose>
		<%
	} //end of check for submit
	else {
		%>
			<ul>
				<li>
					Upload a comma-separated value (CSV) file based on an Excel spreadsheet you already have.
				</li>
				<li>
					Format your Excel spreadsheet like <a href="mass_registration.xls">our example</a>. 
					You may omit information in italicized columns.
				</li>
				<li>
					In Excel, choose <em>File...Save As</em>. Save as a CSV (Comma-delimited) file. Click <em>Yes</em> when Excel 
					warns about features being lost when saving to CSV format.
				</li>
				<li>
					Upload your CSV file below.  We will create the research groups for you.
				</li>
			</ul>
			<form name="register" method="post" enctype="multipart/form-data"
				action='<%= elab.secure("teacher/mass-registration.jsp") %>'>
				<p>
					<label for="csv_file">Registration file (CSV format):</label>
					<input name="csv_file" type="file" size="15"/>
        			<input name="upload" type="submit" value="Upload Registration File"/>
        		</p>
        		<p>
	        		<label for="application_type">File generated by: </label>
    	    		<input name="application_type" type="radio" value="excel" checked>Excel</input>
					<input name="application_type" type="radio" value="other">Other Application</input>
				</p>
			</form>
		<%
	}//some else up there
%>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>

