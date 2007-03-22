<%@ include file="include/elab.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Cosmic Project Page</title>
		<%= elab.css(request, "css/style2.css") %>
		<%= elab.css(request, "css/project.css") %>
		<%= elab.css(request, "css/three-column.css") %>
	</head>

	<body id="project">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="include/header.jsp" %>
					<div id="nav">
						<%@ include file="include/nav_project.jsp" %>
					</div>
				</div>		
			</div>
			
			<div id="content">

<h1>High school students use cutting-edge tools to do scientific investigations.</h1>


<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
				<img src="graphics/crop.jpg"/>
			</div>
		</td>
		
		<td>
			<div id="center">
				<p>
					The Cosmic Ray e-Lab provides an opportunity for students to:
				</p>
				
				<ul>
					<li>
						Do authentic research to access, process and publish data, report 
						and share their results as online posters, and have online discussions 
						with one another about their work. 
					</li>
					<li>
						Experience the environment of scientific collaborations.
					</li>
					<li>
						Possibly to make real contributions to a burgeoning scientific field.
					</li>
				</ul>

				<p>
					The project explores the potential of using the Internet and a new type of 
					distributed computing called the Grid  in high school physics classes.
				</p>
	
				<p>
					Schools with cosmic ray detectors upload data to a "virtual data grid" 
					portal where ALL the data resides. This approach allows students to analyze 
					a much larger body of data and to share analysis code. Also, it allows schools 
					that do not have cosmic ray detectors to participate in research by analyzing 
					shared data. 
				</p>

				<p>
					The website provides a place for students to:
				</p>
				<ul>
					<li>Organize their research.</li>
					<li>Access and analyze the cosmic ray data from schools around the country.</li>
					<li>Write a poster to summarize their research.</li>
					<li>Communicate with other school groups doing similar research.</li>
				</ul>
	
	
				<p>
					We also plan two levels of  data analysis: the science-based interface and 
					a more advanced interface for students interested in learning about and 
					working with the Grid environment. <strong>STAY TUNED!</strong> 
				</p>
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
					<img src="graphics/logo1sm.gif"/>
					<img src="graphics/seal.gif"/>
					<img src="graphics/logoos.jpg"/>
				</div>
			</div>
		
		</div>
		<!-- end container -->
	</body>
</html>
