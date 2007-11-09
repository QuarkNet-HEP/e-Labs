<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/session-control.jsp" %>
<%@ include file="../login/login-required.jsp" %>

	
<e:analysis name="analysis" type="Plot1Chan">
	<c:set var="id" value="0"/>
	<e:trdefault name="outputs" value="${id}_1.eps ${id}_1.jpg ${id}_1.svg ${id}_1.C"/>
	<e:trdefault name="stdout" value="stdout.txt"/>
	<e:trdefault name="stderr" value="stderr.txt"/>
	<e:trdefault name="id" value="${id}"/>
	<e:trdefault name="dataDir" value="${elab.properties['data.dir']}"/>
	
	<e:ifAnalysisIsOk>
		<jsp:include page="../analysis/start.jsp?continuation=../analysis-plot1chan/output.jsp?continuation=${param.continuation}&onError=${param.onError}"/>
	</e:ifAnalysisIsOk>
	<e:ifAnalysisIsNotOk>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Sample Analysis</title>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>

	<body>
		
	    <%@ include file="controls.jsp" %>
	    
	</body>
</html>

	</e:ifAnalysisIsNotOk>
</e:analysis>
