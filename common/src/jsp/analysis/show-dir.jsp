<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ include file="../analysis/results.jsp" %>
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
					<c:out value="hello world"/>
					
					<%-- testing
					<script type="text/javascript">
    						function copy()
    						{
						window.alert("hello");
        					var fileOne, fileTwo; 
						fileOne = `${results.outputDirURL}/eventCandidates`; window.alert(fileOne);
						fileTwo = `${results.outputDirURL}/eclipseFormat`; window.alert(fileTwo);
    						}
    					</script>					
					<script type="text/javascript">copy();</script>
				        end testing --%>

					<%
						String srcDir = "${results.outputDirURL}";
						String dstDir = "${results.outputDirURL}";
						System.out.println("Source file name:  "+ srcDir  + "/eventCandidates");
						System.out.println("Destination file name:  "+ dstDir + "/eclipseFormat");
						 
						File srcFile = FileUtils.getFile(srcDir + "/eventCandidates");
                                                File dstFile = FileUtils.getFile(dstDir + "/eclipseFormat");
						//FileUtils.copyFile(srcFile, dstFile); 
					%>
				</c:if>
			</td>
		</tr>
	</c:forEach>

</table>

<%-- SB, 4/5/17:  Add link for eclipseFormat --%>
        <br />
        <a href="${results.outputDirURL}/eclipseFormat">eclipseFormat</a> 
	
	</div> <%-- close <div id="content"> --%>
	</div> <%-- close <div id="container"> --%>
	</body>
</html>
