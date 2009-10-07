<%@ include file="../include/elab.jsp" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
	<head>
		<title>Workshop Deliverables</title>
		<link rel="stylesheet" type="text/css" href="../../cms/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cms/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../cms/teacher.css"/>
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
<h1>Workshop Deliverables: Required Elements for an Implementation Plan</h1> 
<e:transclude
 url="http://${elab.properties['elab.host']}/cms/library/body.php/Workshop_Deliverables"
     start="<!-- start content -->"
      end="<div class=\"printfooter\">"
/>
<div align="center"><A href="http://${elab.properties['elab.host']}/elab/cms/teacher/forum/forum_thread.php?id=335">Workshop Deliverables Thread</A></div>
<e:transclude
 url="http://${elab.properties['elab.host']}/cms/library/body.php/Implementation_Plan_Section"
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
