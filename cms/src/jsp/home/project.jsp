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
			        At CERN near Geneva, Switzerland, the Large Hadron Collider (LHC) collides protons at the highest 
			        energies ever achieved in the laboratory to reveal new knowledge about matter and energy. Giant detectors 
			        make careful measurements from the collisions. One of these detectors is CMS, the Compact Muon Solenoid.
			    </p>

                <p>
                    Physicists working on CMS and its sister detector, ATLAS, first calibrated their experiments by rediscovering 
                    the particles of the Standard Model. They added to that picture in 2012 with the discovery of the Higgs boson, 
                    the long-sought key to understanding the masses of fundamental particles. Yet physicists know that the Standard Model 
                    does not explain everything. The search for new physics continues beyond the Standard Model.</p>

                <p>
                    CMS e-Lab Student Home provides a guide with resources to create a research project, access to authentic CMS data and 
                    analysis tools for conducting that research, and ways to collaborate. The Teacher Home has learner objectives, 
                    assessment rubrics, standards, management tools, and more.
                </p>

                <p>
                    Join our learning community built around the CMS e-Lab and the QuarkNet CMS data thread as we probe the physics 
                    uncovered by CMS. What are the elementary constituents of matter? What are the fundamental forces that control their 
                    behavior at the most basic level?
                </p>
                

				<a href="/elab" target="common"><strong>Information common for all e-Labs</strong></a><br />
				<a href="../library/resources.jsp<%=viewOnly %>" ><strong>Check out our online resources</strong></a>
				<br/><br/><br/><br/><br/><br/><br/><br/>
				<table width="700">
				        <tr>
				        <td  class="annotPict"><img src="../graphics/big-left.jpg" border="1"><br><div >Inner tracking barrel</div></td>
						<td class="annotPict"><img src="../graphics/dimuon_logo.png" border="1"><br>Event in CMS with two muons</td>
						<td class="annotPict"><img src="../graphics/big-center2.jpg" border="1"><br>Detector before closure 2008</td>
						<td class="annotPict"><img src="../graphics/eemm_run195099_evt137440354_ispy_3d.png" border="1"><br>Higgs candidate detected by CMS</td>
						</tr>
				</table>
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
