<%@ include file="../include/elab.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>CMS Project Page</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/project.css"/>
		<link rel="stylesheet" type="text/css" href="../css/three-column.css"/>
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
				<img src="../graphics/collision.gif"/>
			</div>
		</td>
		
		<td>
			<div id="center">
				<p>
                    The CMS Test Beam e-Lab provides an opportunity for students to conduct studies of high-energy
                    particle collisions from CERN's Large Hadron Collider (LHC) which will probe deeper into matter
                    than ever before. This e-Lab provides students with the opportunity to study
                    (as particle physicists do) the properties of the CMS Calorimeter (electronic and hadronic)
                    subsystems as they are exposed to test beams consisting of particles of known particle types and energies.
                    These test beam studies provide background for students and CMS scientists to better understand the operation
                    of the CMS detector when deployed around the LHC beam line, where the particle types and energies are not known
                    in advance. Students can probe the same data, using the same analysis tools that CMS scientists use, though the
                    access to those tools has been made much easier through the Online Graphical Root Environment (OGRE).				</p>
				<a href="/elab"><strong>Information common for all e-Labs</strong></a>
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
