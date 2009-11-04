<%@ include file="../include/elab.jsp" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
	<head>
		<title> CMS e-Lab Teacher - Add Glossary Item</title>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	</head>

	<body id="community">
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
<h1>Community: Add to the Glossary.</h1>
<p>Help others by contributing to the CMS Glossary. Before you add anything, check that it is not already in the glossary.<br />Staff will review it before it will appear in the Glossary.</p>

<br>
<div align="center"><a href="/library/index.php/Add_CMS_Glossary_Item">Add a Glossary Item</a>
<hr>
<h2>Current Glossary</h2>
</div>
<e:transclude
 url="http://${elab.properties['elab.host']}/library/body.php/CMS_Glossary"
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
