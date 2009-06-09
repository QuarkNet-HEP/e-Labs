<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.cosmic.util.*" %>
	
<%
	String file = (String) request.getParameter("filename");
	String did = AnalysisParameterTools.getDetectorId(file);
	File analyze = new File(new File(elab.getProperties().getDataDir(), did), file + ".analyze");
	//should this happen at the exact same time that file is being created, the whole thing would break
	//should this fail as another such analysis is started, the resulting file would end up being corrupted
	if (analyze.exists()) {
	    request.setAttribute("done", Boolean.TRUE);
	}
	else {
	    request.setAttribute("done", Boolean.FALSE);
	}
	request.setAttribute("outFile", analyze.getAbsolutePath());
%>

<c:choose>
	<c:when test="${done}">
		<jsp:include page="output.jsp?filename=${outFile}"/>
	</c:when>
	<c:otherwise>
		<e:paramAlias from="filename" to="inFile"/>
		<e:analysis name="analysis" type="I2U2.Cosmic::RawAnalyzeStudy">
			<e:trinput type="hidden" name="gatewidth" default="100"/>
			<e:trinput type="hidden" name="inFile"/>
			<e:trdefault name="outFile" value="${outFile}"/>
			<e:ifAnalysisIsOk>
				<jsp:include page="../analysis/start.jsp?continuation=../analysis-raw-single/output.jsp&onError=../analysis-raw-single/analysis.jsp"/>
			</e:ifAnalysisIsOk>
			<e:ifAnalysisIsNotOk>
			
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Data file analysis error</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="raw-analysis-single" class="data">
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
		<td id="center">
			<p>
				<span class="error">An error has occurred.</span>
			</p>
								
		    <c:if test="${!(empty analysis.invalidParameters)}">
		    	<h2>Invalid keys:</h2>
		        <ul class="errors">
		            <c:forEach var="f" items="${analysis.invalidParameters}">
		                <li><c:out value="${f}"/></li>
		            </c:forEach>
		        </ul>
		    </c:if>
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

			</e:ifAnalysisIsNotOk>
		</e:analysis>
	</c:otherwise>
</c:choose>
