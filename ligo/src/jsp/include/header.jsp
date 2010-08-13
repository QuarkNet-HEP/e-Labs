<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.*" %>

<script type="text/javascript" src="../include/jquery/js/jquery-1.4.2.min.js"></script>
<script type="text/javascript" src="../include/json2.js"></script>
<script type="text/javascript" src="../include/jquery/js/jquery-ui-1.7.2.custom.min.js"></script>
<script type="text/javascript" src="../include/jquery/js/jquery.event.hover-1.0.js"></script>
<script type="text/javascript" src="../include/jquery/js/css-gradients-via-canvas.js"></script>

<%
	boolean loggedIn = ElabGroup.isUserLoggedIn(session);
	request.setAttribute("loggedin", loggedIn);
	if (loggedIn) {
	    ElabGroup group = ElabGroup.getUser(session);
	    request.setAttribute("username", group.getName());
	}
%>

<div id="header-image">
	<img src="../graphics/ligo_logo.gif" alt="LIGO Logo" />
</div>
<div id="header-title">LIGO e-Lab</div>
<c:choose>
	<c:when test="${loggedin}">
		<div id="header-toolbar">
			<c:choose>
				<c:when test="${user.teacher}">
					<e:popup href="/elab/ligo/teacher/forum/HelpDeskRequest.php" target="helpdesk" width="800" height="600"><img title="Helpdesk" src="../graphics/helpdesk.png" /></e:popup>
					<e:popup href="../jsp/showLogbookT.jsp" target="log" width="800" height="600"><img title="Logbook" src="../graphics/logbook.png" /></e:popup>
				</c:when>
				<c:otherwise>
					<e:popup href="../jsp/showLogbook.jsp" target="log" width="800" height="600"><img title="Logbook" src="../graphics/logbook.png" /></e:popup>
				</c:otherwise>
			</c:choose>
			<a id="username" href="../login/user-info.jsp"><span class="toolbar-text-link">${username}</span></a>
			<a href="../login/logout.jsp"><span id="logout" class="toolbar-text-link">Log out</span></a>
		</div>
		<span id="toolbar-error-text"></span>
		<c:set var="headerIncluded" value="true" scope="request"/>
		<% out.flush(); %>
	</c:when>
</c:choose>