<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
	
<e:analysis name="analysis" type="SampleAnalysis">
	<e:trdefault name="output" value="message.txt"/>
	
	<e:ifAnalysisIsOk>
		<jsp:include page="../analysis/start.jsp?continuation=../analysis-embedded/output.jsp?continuation=${param.continuation}&onError=${param.onError}"/>
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
