<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/teacher-login-required.jsp" %>
<%@ page import="org.owasp.validator.html.*" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%
	String send = request.getParameter("send");
	List<ElabGroup> researchGroups = new ArrayList<ElabGroup>();
	for (Iterator ite = user.getGroups().iterator(); ite.hasNext();) {
		ElabGroup group = (ElabGroup) ite.next();
		if (group.getActive() && !group.getName().equals(user.getName())) {
			researchGroups.add(group);
		}
	}
	request.setAttribute("researchGroups", researchGroups);
	
	if ("Send".equals(send)) {
	    String[] recipients = request.getParameterValues("destination");
	    boolean all = StringUtils.isNotBlank(request.getParameter("allgroups")); 
	    if ((recipients == null || recipients.length == 0) && !all) {
	        throw new ElabJspException("Please select at least one recipient");
	    }
	    List<ElabGroup> groupsToNotify = new ArrayList();
	    if (all) {
	        for (ElabGroup eg : user.getGroups()) {
	        	if (eg.getActive() && !eg.getName().equals(user.getName())) {
	        		groupsToNotify.add(eg);
	        	}
	        }
	    }
	    else {
	        for (String rec : recipients) {
	            if (!user.getGroupNames().contains(rec)) {
	                throw new ElabJspException(rec + " is not one of your groups");
	            }
	            else {
	            	groupsToNotify.add(user.getGroup(rec));
	            }
	        }
	    }
	    
	    String message = request.getParameter("message");
	    if (StringUtils.isBlank(message)) {
	        throw new ElabJspException("Message is empty");
	    }
	    message = message.trim();
		message = message.replaceAll("<p>", "");
		message = message.replaceAll("</p>", "");
	
	    //message = message.substring("<p>".length(), message.length() - "</p>".length());
	    Policy policy = Policy.getInstance(Elab.class.getClassLoader().getResource("antisamy-i2u2.xml").openStream());
		AntiSamy as = new AntiSamy();
		message = as.scan(message, policy).getCleanHTML();
	    boolean expirestoggle = request.getParameter("expirestoggle") != null 
	    	&& request.getParameter("expirestoggle").length() > 0;
	    String expiresvalue = request.getParameter("expiresvalue");
	    String expiresunit = request.getParameter("expiresunit");
	    int expval = 0;
	    if (expirestoggle) {
	    	try {
	    		expval = Integer.parseInt(expiresvalue);
	    	}
	    	catch (NumberFormatException e) {
	    	    throw new ElabJspException("Expiration value not numeric: " + expiresvalue); 
	    	}
	    	if (expval < 0) {
	    	    throw new ElabJspException("Expiration value must be positive");
	    	}
	    	if (!"day".equals(expiresunit) && !"hour".equals(expiresunit)) {
	    	    throw new ElabJspException("Expiration unit is invalid: " + expiresunit);
	    	}
	    }
	    
	    ElabNotificationsProvider np = ElabFactory.getNotificationsProvider((Elab) session.getAttribute("elab"));
        Notification n = new Notification();
        n.setCreatorGroupId(user.getId());
        n.setMessage(message);
        if (expirestoggle) {
            n.setExpirationDate(System.currentTimeMillis() + 1000 * 3600 * expval * ("day".equals(expiresunit) ? 1 : 24));
        }
        else {
        	GregorianCalendar gc = new GregorianCalendar(); 
        	gc.add(Calendar.YEAR, 1);
        	n.setExpirationDate(gc.getTimeInMillis());
        }
        List<Integer> projectIds = new ArrayList<Integer>();
        projectIds.add(elab.getId());
        np.addNotification(groupsToNotify, projectIds, n);

        request.setAttribute("notification", n);
	}
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>${elab.properties.formalName} e-Lab Home</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<script type="text/javascript" src="../include/notifications.js"></script>
	</head>
	
	<body id="send-to-groups" class="home send-notifications">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav-teacher.jsp" %>
					</div>
				</div>
			</div>
		
			<div id="content">
<script type="text/javascript" src="../include/tiny_mce/jquery.tinymce.js"></script>
<script>
	$().ready(function() {
		$('textarea.tinymce').tinymce({
			script_url : '../include/tiny_mce/tiny_mce.js',
			theme : 'advanced',
			plugins : 'tabfocus',

			theme_advanced_buttons1 : "bold,italic,underline,|,link,unlink,image,|,bullist,numlist,|,sub,sup",
			theme_advanced_buttons2 : "",
			theme_advanced_buttons3 : "", 
			theme_advanced_toolbar_location : "top",
			theme_advanced_toolbar_align : "left"
		});
	});
</script>
<h1>Send notifications</h1>
<script language="JavaScript">
	function toggleField(checkboxid, fieldid, mask) {
		var checkbox = document.getElementById(checkboxid);
		var field = document.getElementById(fieldid);
		if (checkbox && field) {
			field.disabled = mask != checkbox.checked;
		}
	}	
</script>
<form action="../notifications/send-to-groups.jsp" method="post">
<c:if test="${notification != null }">
	<p>Notification "${notification.message}" was added successfully.</p>
</c:if>
<ul>
	<li>SYSTEM messages are messages that go into the newsbox, either for all or individual e-Labs.</li>
	<li>NORMAL messages are messages that go to all research groups in all e-Labs or individual e-Labs (these do not show in the newsbox).</li>
</ul>
	<table border="0" id="form-table" width="100%">
		<tr>
			<td class="label">
				Send to:
			</td>
			<td>
				<select name="destination" multiple="true" id="destination" size="8">
					<c:forEach var="group" items="${researchGroups}">
						<option value="${group.name}">${group.name}</option>
					</c:forEach>
				</select>
				<br />
				<input type="checkbox" name="allgroups" id="allgroups"
					onclick="javascript: toggleField('allgroups', 'destination', false)"/> All your groups
			</td>
		</tr>
		<tr>
			<td class="label">
				Message:
			</td>
			<td>
				<textarea cols="36" rows="8" name="message" class="tinymce"></textarea>
			</td>
		</tr>
		<tr>
			<td class="label">
				<input type="checkbox" name="expirestoggle" id="expirestoggle" 
					onclick="javascript: toggleField('expirestoggle', 'expiresvalue', true);toggleField('expirestoggle', 'expiresunit', true)"/>
				Expires in:
			</td>
			<td>
				<input type="text" size="20" name="expiresvalue" id="expiresvalue" disabled="true"/>
				<select name="expiresunit" id="expiresunit" disabled="true">
					<option value="hour">hour(s)</option>
					<option value="day">day(s)</option>
				</select>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<input type="submit" name="send" value="Send" />
			</td>
		</tr>
	</table>
</form>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>