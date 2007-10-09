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
		<title>Analysis Results</title>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body>
		<p>
			Output is in <a href="${results.outputDirURL}/${results.analysis.parameters.output}">${results.outputDir}/${results.analysis.parameters.output}</a>			
		</p>
		<p>
			Continuation is <a href="${param.continuation}">${param.continuation}</a>
		</p>
		<p>
			<e:rerun type="embedded" analysis="${results.analysis}" label="Rerun Workflow"/>
		</p>
	</body>
</html>
