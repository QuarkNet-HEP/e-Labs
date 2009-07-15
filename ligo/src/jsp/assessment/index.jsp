<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Assessment</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/assessment.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
		<link rel="stylesheet" type="text/css" media="print" href="../css/assessment-print.css" />
	</head>
		
	<body id="assessment" class="assessment">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jsp" %>
				</div>
			</div>

			<div id="content">

<table border="0" id="main">
	<tr>
		<td id="left">
			<%@ include file="../include/left-alt.jsp" %>
		</td>
		<td id="center">
			<h1>Assessment: Measure your work against these objectives.</h1>
				
			<p>
				The following objectives outline what you will learn and be able 
				to do during this study of seismic waves. For assessment follow 
				the guidance your teacher gave you at the beginning of the project.
			</p>
				
			<ul>
				<li>
					Content and Investigation Objectives:
					<ul>
						<li>Define and describe frequency in the context of wave 
							behavior.</li>
						<li>Describe causes effecting the environmental changes being measured by LIGO's environmental sensing data in your study.</li>
						<li>Explain how LIGO's measurements of seismic waves 
							contributes to the project's effort to detect 
							gravitational waves.</li>
						<li>Design an investigation that asks a testable hypothesis, can be answered from seismic data and provides an explanation of what you learn about seismic data.</li>
					</ul>
				</li>
							<%@ include file="../teacher/learner-outcomes.jsp" %>
			</ul>
		</td>
	</tr>
</table>


			</div>
			<!-- end content -->	

			<div id="footer">
				<%@ include file="../include/nav-footer.jsp" %>
			</div>
		</div>
		<!-- end container -->
</body>
</html>
