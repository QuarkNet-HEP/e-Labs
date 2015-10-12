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
		<title>View Geometry</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/upload.css"/>
		<link rel="stylesheet" type="text/css" href="../css/geo.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="edit-geometry" class="upload geo">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">

<table border="0" id="main">
	<tr>
		<td><%@ include file="list.jspf" %></td>
		<td id="left">
			<div id="editor">
				<div id="title" style="float: left; width:200px;">Please choose an action to your left.</div>
	        	<div style="background-color: #CC99CC; font-size:xx-small; float:right; width: 200px; padding: 10px;">
					<div><strong>Help</strong></div><br />
					<div style="vertical-align: top;"><img border="0" src="../graphics/geo_new.gif" />Add a new entry for a detector</div>
					<div style="vertical-align: top;"><img border="0" src="../graphics/geo_pencil.gif" />Edit Entry</div>
					<div style="vertical-align: top;"><img border="0" src="../graphics/delete_x.gif" />Delete Entry</div>
					<div style="vertical-align: top;"><img border="0" src="../graphics/saveas.gif" />Duplicate</div>	
          <div style="vertical-align: top;"><img border="0" src="../graphics/world.png" height="15px" width="15px" /> View Map</div>  
				</div>				
				<br /><br /><br /><br /><br /><br /><br /><br />
				<div id="tutorial" style="float: left;">
	                    Confused? Seeing errors? Please consult the <a href="tutorial.jsp">tutorial</a>.
	            </div>
            </div>
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
