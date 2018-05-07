<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>

<%-- Upgraded jQuery 1.4.3.min > 1.7.2.min 15Dec2017 - JG --%>
<script type="text/javascript" src="../include/jquery/js/jquery-1.12.4.min.js"></script>
<script type="text/javascript" src="../include/json2.js"></script>
<script type="text/javascript" src="../include/jquery/js/jquery-ui-1.12.1.custom.min.js"></script>
<script type="text/javascript" src="../include/jquery/js/jquery.event.hover-1.0.js"></script>
<script type="text/javascript" src="../include/jquery/js/css-gradients-via-canvas.js"></script>

<%
	boolean loggedIn = ElabGroup.isUserLoggedIn(session);
	request.setAttribute("loggedin", loggedIn);
	if (loggedIn) {
	    ElabGroup group = ElabGroup.getUser(session);
	    request.setAttribute("username", group.getName());
	}
	String environment = (String) session.getAttribute("environment");	
	request.setAttribute("environment", environment);
%>

<div id="header-image">
	<img src="../graphics/cms_logo.png" alt="CMS Logo" />
</div>
<div id="header-title">CMS e-Lab${environment}</div>
<c:choose>
	<c:when test="${loggedin}">
		<div id="header-toolbar">
			<c:if test='${user.name != "guest" }'>			
				<c:choose>
					<c:when test="${user.teacher}">
						<e:popup href="/elab/cms/teacher/forum/HelpDeskRequest.php" target="helpdesk" width="800" height="600"><img title="Helpdesk" src="../graphics/helpdesk.png" /></e:popup>
						<e:popup href="../logbook/teacher-logbook-keyword.jsp" target="log" width="900" height="800"><img id="logbook-icon" title="Logbook" src="../graphics/logbook.png" /></e:popup>
					</c:when>
					<c:otherwise>
						<e:popup href="../logbook/student-logbook.jsp" target="log" width="1000" height="800"><img id="logbook-icon" title="Logbook" src="../graphics/logbook.png" /></e:popup>
					</c:otherwise>
				</c:choose>
				<%@ include file="../notifications/header-notifications.jsp" %>		
			</c:if>
			<a id="username" href="../login/user-info.jsp"><span class="toolbar-text-link">${username}</span></a>
			<a href="../login/logout.jsp"><span id="logout" class="toolbar-text-link">Log out</span></a>
		</div>
		<span id="toolbar-error-text"></span>
		<c:set var="headerIncluded" value="true" scope="request"/>
		<% out.flush(); %>
		<%@ include file="../analysis/async-update.jsp" %>
		<script language="JavaScript" type="text/javascript">
		    var checkUpdate = 1 * 60 * 1000;
			registerUpdate("../include/toolbar-async.jsp", 
					function(data, error) {
						updateHeader(data, error, '${elab.name}');
					}, checkUpdate, checkUpdate);
		</script>
	</c:when>
</c:choose>
