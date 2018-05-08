<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.cosmic.analysis.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>
<%
	String submit = request.getParameter("submit");
	String splitfilename = request.getParameter("splitfilename");
	String messages = "";
	
	if ("Create Threshold Times File".equals(submit)) {
		VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(splitfilename);
		String[] inputfile = {splitfilename};
		if (entry != null) {	
			if (splitfilename.indexOf(".") > -1) {
				String detectorid = splitfilename.substring(0, splitfilename.indexOf("."));
			    ThresholdTimes tt = new ThresholdTimes(elab, inputfile, detectorid);
				tt.createThresholdFiles();
				messages = "Request for file: "+splitfilename+" processed.\n";
			} else {
				messages = splitfilename + " is not a valid split file name\n";
			}
		} else {
			messages = "Could not find file: "+splitfilename+" in the datacatalog.\n";
		}
	}//end of submit
	
	request.setAttribute("messages", messages);
	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Create Threshold Times Files</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<script type="text/javascript" src="../include/jquery/js/jquery-1.12.4.min.js"></script>
		<link type="text/css" href="../include/jquery/css/blue/jquery-ui-1.7.2.custom.css" rel="Stylesheet" />	
		<script type="text/javascript" src="../include/jquery/js/jquery-ui-1.7.3.custom.min.js"></script>
		<script type="text/javascript" src="../include/jquery/js/jquery.event.hover-1.0.js"></script>	
		<script type="text/javascript" src="../include/jquery/js/jquery.tablesorter.min.js"></script>	
		<link type="text/css" rel="stylesheet" href="../include/jquery/css/blue/style.css" />		
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="create-threshold-times" class="teacher">
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
			<form id="thresholdtimesinfo" method="post">
			    <h2>Create the Threshold Times File for a Split.</h2>
			    <ul>
			    	<li>Enter split file name.</li>
			    	<li>Click on Create File.</li>
			    </ul>
				<table>
					<tr>
						<td>Enter split file name: <input type="text" name="splitfilename" id="splitfilename"></input></td>
					</tr>
					<tr>			
						<td><div style="width: 100%; text-align:center;"><input type="submit" name="submit" value="Create Threshold Times File"/></div>
						</td>
					</tr>
				</table>
			</form>
			<c:choose>
   				  <c:when test='${messages > "" }'> 
   				   	<div>${messages }</div>
				</c:when>
			</c:choose>
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
