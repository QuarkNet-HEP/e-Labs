<%@ include file="../include/elab.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>${elab.properties.formalName} e-Lab Home</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/home.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
	</head>
	
	<body id="home" class="home">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<c:choose>
							<c:when test="${user != null}">
								<%@ include file="../include/nav.jsp" %>
							</c:when>
							<c:otherwise>
								<h1>Build Your Own Research Project Using Professional Science Data</h1>
							</c:otherwise>
						</c:choose>
					</div>
				</div>
			</div>
			
			<div id="content">

<!-- There is no way to do this without tables?  I DOUBT IT -EAM -->
<table border="0" id="main">
  <tr>
	<td id="left">
	  <%@ include file="../include/left.jsp" %>
	</td>
	<td id="center">
	  <div class="float-right bordered">
		<%@ include file="../include/newsbox.jsp" %>
		<jsp:include page="../login/login-control.jsp">
		  <jsp:param name="prevPage" value="../home/login-redir.jsp"/>
		</jsp:include>
	  </div>

	  <h2>Welcome to the LIGO I2U2 e-Lab!</h2>

	  <p>
		At this Web site you are invited to work with scientific data from  
		<a href="http://www.ligo.caltech.edu">LIGO</a>, the 
		Laser Interferometer Gravitational-wave Observatory.  Using your 
		computer and the Internet, you can graph data from LIGO's 
		seismometers and weather stations.  You can perform a short study 
		or build a long-term research project.  The tools at this site will 
		guide you through the process.  Use our data to research your 
		questions about how and why the ground shakes.  We've got plenty of 
		data waiting for you, so feel free to log in and get started!
	  </p>

	  <h2>What is LIGO?</h2>
	  <p>
		LIGO's huge laser interferometers in 
		<a href="http://www.ligo-wa.caltech.edu">Washington State</a> and in 
		<a href="http://www.ligo-la.caltech.edu">Louisiana</a>
		listen for the faint ripples of space-time called gravitational waves. 
		LIGO seeks to detect gravitational waves from the collisions of black 
		holes or neutron stars and from star explosions known as supernovae. 
		The data that you can view at this Web site come from instruments that 
		monitor the environment at LIGO.  Seismic events can affect the behavior 
		of LIGO's gravitational wave detectors.  You can participate in the task 
		of analyzing these environmental disturbances. 
	  </p>


	  <h2>What is I2U2?</h2>
	  <p>
		I2U2, or <i>Interactions in Understanding the Universe</i>, is a joint 
		effort by several major research projects to make professional science 
		data available to students and teachers.  Funded by the 
		<a href="http://www.nsf.gov">National Science Foundation</a> (NSF), 
		I2U2 relies on a national network of computers known as the Grid to 
		make data and analysis tools available over the Internet through virtual 
		laboratories known as e-Labs. Check the main 
		<a href="http://www.i2u2.org/index.html">I2U2</a> Web site to find 
		the cosmic ray, high energy physics and nuclear physics 
		<a href="http://www.i2u2.org/elab/list.html">e-Labs</a> that also 
		are available to you.  I2U2 provides data and software that allows students 
		and teachers to perform authentic science research in a professional-style 
		collaborative environment, brought to you by the power of the Grid.
	  </p>

	  <h2>How do I Start the LIGO e-Lab?</h2>
	  <p>
		You will need to log-in to begin the e-Lab.
		Your teacher can provide you with a research group name and
		password, or you may log in as a guest.
		Start by clicking on the <a href='../library/'>Library</a> link
		along the top of the page.
		The <a href='../library/milestones-map.jsp'>Study Guide</a>
		link on the Library menu will show you the e-Lab roadmap that you 
		will follow.
	  </p>
	</td>
  </tr>
</table>


			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
