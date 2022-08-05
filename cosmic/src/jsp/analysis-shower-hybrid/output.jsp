<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ include file="../analysis/results.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Hybrid Study Analysis Results</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="hybrid-study-output" class="data, analysis-output">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
<%
	String outputDir = results.getOutputDirURL();
    String userDirectory = outputDir.substring(outputDir.indexOf("/scratch"), outputDir.length());
   	request.setAttribute("userDirectory",userDirectory);
%>

<p>
	<br /><br />
	<a href="${results.outputDirURL}/hybridOut">Analysis output file</a> <br /> <br /><br />
	The link above will open the file on the browser. <br /><br />
	To download the file to your computer, right click on the link and select "Download Linked File as..." <br /> <br /><br />
</p>
<p>-------------------------------</p>
<p>
	Analysis run time: ${results.formattedRunTime}; estimated: ${results.formattedEstimatedRunTime}
</p>
<p>
	Show <e:popup href="../analysis/show-dir.jsp?id=${results.id}" target="analysisdir" 
		width="800" height="600" toolbar="true">analysis directory</e:popup>
</p>
<p>
	<e:rerun type="shower-hybrid" id="${results.id}" label="Change"/> your parameters
</p>

			</div>
			<!-- end content -->	
	
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
