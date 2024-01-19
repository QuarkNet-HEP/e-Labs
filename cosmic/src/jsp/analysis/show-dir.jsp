<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ include file="../analysis/results.jsp" %>

<%@ page import="java.nio.file.*" %>
<%@ page import="org.apache.commons.io.FileUtils" %>

<%
	File f = new File(results.getOutputDir());
	File[] all = f.listFiles();
	List files = new ArrayList();
	for (int i = 0; i < all.length; i++) {
		if (!all[i].isDirectory()) {
			files.add(all[i]);
		}
	}
	request.setAttribute("files", files);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Analysis files</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
		<script type="text/javascript" src="../include/jquery/js/jquery-1.6.1.min.js"></script>					
		<script>
		$(document).ready(function(){
			$("#writeAll").bind("change", function() {
				var $req = $(this);
				if ($req.prop("checked")) {
					document.getElementById("writeAllEvents").value = "yes";
				} else {
					document.getElementById("writeAllEvents").value = "no";
				}
			});
		});			
		
		</script>
	</head>

	<body id="analysis-files" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="content">
<h3>Output directory for ${results.analysis.type}</h3>
<table class="file-list">
	<c:forEach items="${files}" var="file">
		<tr>
			<td>
				<a href="${results.outputDirURL}/${file.name}">${file.name}</a>
				<%-- SB, 4/5/17:  copy eventCandidates to eclipseFormat --%> 
				
				<c:if test="${file.name == 'eventCandidates'}"> 
					<form action="eclipse_Format.jsp" method="GET">
					    <input type="checkbox" name="writeAll" id="writeAll">Write all events</input>
						<input type="hidden" name="writeAllEvents" id="writeAllEvents" value="no"/>
						<input type="hidden" name="srcD" value="${results.outputDirURL}"/>
						<input type="hidden" name="srcF" value="${file.name}"/>
          				<br /><input type="submit" value="eclipseFormat"/> 
					</form>
					<form action="delta-t.jsp" method="GET">
						<input type="hidden" name="srcD" value="${results.outputDirURL}"/>
 						<input type="hidden" name="srcF" value="${file.name}"/>
 						<label>Start Histogram at (ns): </label><input type="text" name="startHistString"/><br>
 						<label>Histogram bin width (ns): </label><input type="text" name="binWidthString"/><br>
						<input type="submit" value="delta-t"/>
					</form>
				</c:if>
			</td>
		</tr>
	</c:forEach>

</table>

	
	</div> <%-- close <div id="content"> --%>
	</div> <%-- close <div id="container"> --%>
	</body>
</html>
