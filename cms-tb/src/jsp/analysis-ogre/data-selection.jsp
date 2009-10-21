<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="o" uri="http://www.i2u2.org/jsp/ogretl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>


<html>
	<META HTTP-EQUIV="Pragma" content="no-cache">
	<head>
		<title>OGRE Data Selection</title>

		<c:choose>
			<c:when test="${usedb}">
				<script language="JavaScript" type="Text/JavaScript"><o:make-run-scripts.sql/></script>
			</c:when>
  			<c:otherwise>
				<script language="JavaScript" type="Text/JavaScript"><o:make-run-scripts.xml/></script>
			</c:otherwise>
  		</c:choose>
	</head>

	<body onLoad='javascript:select_current();'>

	    <form method="POST" name="getData">
			<center>
				<table border=5 cellpadding=5>
					<tr align="center" valign="baseline">
						<th>Select all runs of type</th>
						<th>Data to Plot &nbsp;&nbsp;</th>
						<th>Run Info &nbsp;&nbsp;</th>
				    </tr>
				    <tr>
						<td>
							<c:choose>
								<c:when test="${usedb}">
									<o:data-select.sql/>
								</c:when>
								<c:otherwise>
									<o:data-select.xml/>
								</c:otherwise>
							</c:choose>
						</td>
						<td><textarea name="dummy" rows="5" cols="37" readonly="true"></textarea></td>
					</tr>
				</table>
				<input type="button" value="Run Info" onClick="javascript:runData=get_rundb();">&nbsp;&nbsp;
				<input type="button" value="close" onClick="javascript:window.close();">
			</center>
		</form>
		
	</body>
</html>
