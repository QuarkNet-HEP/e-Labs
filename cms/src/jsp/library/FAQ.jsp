<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="java.util.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Frequently Asked Questions</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/library.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
	</head>
	
	<body id="faq" class="library">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				
<e:transclude
 url="http://${elab.properties['elab.host']}/library/body.php?title=CMS_FAQ"
     start="<!-- start content -->"
     end="<div class=\"printfooter\">"
/>



			</div>
			<!-- end content -->			
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
