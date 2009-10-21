<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="o" uri="http://www.i2u2.org/jsp/ogretl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>


<html>
	<head>
		<title>CMS TB Run Information</title>
	</head>

	<body>
		<center>
			<table border="5" cellpadding="10">
				<c:choose>
					<c:when test="${usedb}">
						<o:get-run-data.sql/>
					</c:when>
					<c:otherwise>
						<o:get-run-data.xml/>
					</c:otherwise>
				</c:choose>
			</table>
			<input type="button" value="close" onClick="javascript:window.close();">
		</center>
	</body>
</html>
