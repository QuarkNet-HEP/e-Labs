<%@ include file="../include/elab.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>CMS Rubric</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/assessment.css"/>
		<link rel="stylesheet" type="text/css" media="print" href="../css/assessment-print.css" />
	</head>
	
	<body id="assessment" class="assessment">
		<!-- entire page container -->
		<div id="container">	
			<div id="top"">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			<div id="content">

			<h1>Objectives: Assessing Your Work (CMS e-Lab)</h1>
				  <div id="objectives">
			
			<p>
				The following objectives outline what you will learn and be able 
				to do during this study of CMS data. For assessment follow 
				the guidance your teacher gave you at the beginning of the project.
			</p>
				
			<ul>
				<li>
					Content and Investigation Objectives:
					<ul>
						<li>Describe particles colliding in and emerging from collisions detected by CMS as predicted by the Standard Model.</li>
						<li>List in order and describe the CMS subdetectors in terms of the properties of the particles they detect.</li>
						<li>Explain the role that conservation of mass/energy, momentum, and charge play in analyzing events detected at CMS.</li>
						<li>Design, conduct and report on an investigation of a testable hypothesis for which evidence can be provided using CMS data.</li>
					</ul>
				</li>
							<%@ include file="../teacher/learner-outcomes.jsp" %>
		 	</ul>
			
				</div>  <!-- end objectives -->	
				</div>  <!-- end content -->	
					
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>

