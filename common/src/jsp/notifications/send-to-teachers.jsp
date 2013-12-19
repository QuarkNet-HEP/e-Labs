<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%@ page import="org.owasp.validator.html.*" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%
	Collection teachers = elab.getUserManagementProvider().getTeachers();
	String send = request.getParameter("send");
	if ("Send".equals(send)) {
		String[] recipients = request.getParameterValues("destination"); 
	    boolean all = StringUtils.isNotBlank(request.getParameter("allteachers")); 
	    if ((recipients == null || recipients.length == 0) && !all) {
	        throw new ElabJspException("Please select at least one teacher.");
	    }
	    List<ElabGroup> eg = new ArrayList<ElabGroup>();
	    if (all) {
	    	for (Object t : teachers) {
	    		ElabGroup teach = (ElabGroup) t;
		        eg.add(teach);
	    	}
	    }
	    else {
	    	for (Object t : teachers) {
	    		ElabGroup teach = (ElabGroup) t;
	        	for (String s : recipients) {
	        		if (teach.getName().equals(s)) {
	        			eg.add(teach);
	        		}
	        	}
	        }
	    }
	        
	    String message = request.getParameter("message");
	    if (StringUtils.isBlank(message)) {
	        throw new ElabJspException("Please write a message");
	    }
	    message = message.trim();
		message = message.replaceAll("<p>", "");
		message = message.replaceAll("</p>", "");

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
        n.setBroadcast(false);
        if (expirestoggle) {
            n.setExpirationDate(System.currentTimeMillis() + 1000 * 3600 * expval * ("day".equals(expiresunit) ? 1 : 24));
        }
        else {
        	GregorianCalendar gc = new GregorianCalendar(); 
        	gc.add(Calendar.YEAR, 1);
        	n.setExpirationDate(gc.getTimeInMillis());
        }
        n.setType(Notification.MessageType.fromCode(2)); 
        np.addTeacherNotification(eg, n);
        request.setAttribute("notification", n);
	}
	request.setAttribute("teachers", teachers);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>${elab.properties.formalName} e-Lab Home</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>		
	</head>
	
	<body id="send-to-teachers" class="home send-notifications">
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
<form action="../notifications/send-to-teachers.jsp" method="post">
<c:if test="${notification != null }">
	<p>Notification "${notification.message}" was added successfully.</p>
</c:if>
	<table border="0" id="form-table" width="100%">
		<tr>
			<td class="label">
				Send to:
			</td>
			<td>
				<select name="destination" multiple="true" id="destination" size="8">
					<c:forEach var="e" items="${teachers}">
						<option value="${e.name}">${e.name}</option>
					</c:forEach>
				</select>
				<br />
				<input type="checkbox" name="allteachers" id="allteachers" 
					onclick="javascript: toggleField('allteachers', 'destination', false)"/> All Teachers
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
				<input type="submit" name="send" value="Send" onClick="javascript: validate()"/>
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