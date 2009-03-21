<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ page import="gov.fnal.elab.cosmic.beans.Geometries" %>
<%@ page import="gov.fnal.elab.cosmic.beans.GeoEntryBean" %>
<%@ page import="gov.fnal.elab.cosmic.Geometry" %>
<%@ include file="../login/upload-login-required.jsp" %>

<%@ include file="init.jspf" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>New Geometry</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/upload.css"/>
		<link rel="stylesheet" type="text/css" href="../css/geo.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="new-geometry" class="upload geo">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-upload.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">

<table border="0" id="main">
	<tr>
		<td id="center">
			<div id="editor">
				<div class="title">New Detector ${param.detectorID} Entry:</div>
				<%@ include file="editor.jspf" %>
			</div>
			
			<%@ include file="list.jspf" %>
		</td>
	</tr>
</table>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
