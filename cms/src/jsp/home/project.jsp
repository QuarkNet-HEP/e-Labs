<%@ include file="../include/elab.jsp" %>
<%
	String viewOnly = "?options=project";
	request.setAttribute("viewOnly",viewOnly);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>CMS Project Page</title>
		<link rel="stylesheet" type="text/css" href="../css/project.css"/>
		<link rel="stylesheet" type="text/css" href="../css/three-column.css"/>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
	</head>

	<body id="project">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav-project.jsp" %>
					</div>
				</div>
			</div>

			<div id="content">

<h1>High school students use cutting-edge tools to do scientific investigations.</h1>


<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
				<img src="../graphics/CMS-sidebar2.png"/><br><div style="font-size: 11px; color: white; width: 100px; text-align:center">Real Event<br>Superimposed on Detector</div>
			</div>
		</td>

		<td>
			<div id="center">
				<p>
                    Particle physics aims to answer two questions: What are the elementary constituents of matter?
                    What are the fundament forces that control their behavior at the most basic level? CERN's Large
                    Hadron Collider (LHC) and its experiments will probe deeper into matter than ever before.
                    The Compact Muon Solenoid (CMS) detector is designed to detect fundamental particles:
                    electrons, muons, tau leptons, photons, and quark jets and missing energy due to very
                    weakly interacting particles such as neutrinos. Massive particles such as the Higgs boson
                    will decay into these fundamental objects, the properties of which will be measured in
                    the CMS detector's many subsystems.</p>
				<p>
                    The CMS e-Lab provides students with an opportunity to analyze data to calibrate the detector
                    and participate in discovery science (as particle physicists do). Calibrating the detector to
                    "rediscover" previous measured results is an important part of the early scientific activity at
                    CMS. Later students will probe data where physicists expect to find answers to questions at
                    the heart of 21st century particle physics. The CMS e-Lab addresses ALL science practices in
                    the Next Generation Science Standards.</p>
                   <p>
                    Join our learning community. Go to the teacher pages to find learner objectives and assessment
                    tools, standards, classroom notes and more. Your students begin the e-Lab at the Student Home
                    and cannot access this page or teacher pages from the student pages.</p>

				<a href="/elab" target="common"><strong>Information common for all e-Labs</strong></a><br />
				<a href="../library/resources.jsp<%=viewOnly %>" ><strong>Check out our online resources</strong></a>
				<br/><br/><br/><br/><br/><br/><br/><br/>
				<table width="700"><tr><td  class="annotPict"><img src="../graphics/big-left.jpg" border="1"><br><div >Inner tracking barrel</div></td>
						<td class="annotPict"><img src="../graphics/dimuon_logo.png" border="1"><br>Event in CMS with two muons</td>
						<td class="annotPict"><img src="../graphics/big-center2.jpg" border="1"><br>Detector before closure 2008</td>
						<td class="annotPict"><img src="../graphics/eemm_run195099_evt137440354_ispy_3d.png" border="1"><br>Higgs candidate detected by CMS</td>
						</td></tr></table>
			</div>
		</td>

	</tr>
</table>

			</div>
			<!-- end content -->

			<div id="footer">
				<div id="footertext">
					<p>
						This project is supported in part by the National Science Foundation and
						the Office of High Energy Physics in the Office of Science , U.S.
						Department of Energy. Opinions expressed are those of the authors and
						not necessarily those of the Foundation or Department.
					</p>
				</div>

				<div class="logogroup">
					<img src="../graphics/logo1sm.gif"/>
					<img src="../graphics/seal.gif"/>
				</div>
			</div>

		</div>
		<!-- end container -->
	</body>
</html>
