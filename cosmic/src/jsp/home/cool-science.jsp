<%@ include file="../include/elab.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>${elab.properties.formalName} e-Lab Home</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/home.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column-home.css"/>
	</head>
	
	<body id="home" class="home">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<c:if test="${user != null}">
							<%@ include file="../include/nav.jsp" %>
						</c:if>
					</div>
				</div>
			</div>
			
			<div id="content">
				
<h1>Studying cosmic rays; solving scientific mysteries!</h1>
 	 <c:if test="${user != null}">
	   <div id="links"><table align="center"><tr>
	   <td width="150" align="center"><A href="cool-science.jsp"><img src="../graphics/cool-science-button.gif" border="0"><br>Cool Science</a></td>
	   <td width="150" align="center"><a href="../site-index/site-map-anno.jsp"><img src="../graphics/site-map-button.gif" border="0"><br>Explore!</a></td>
	   <td width="150"align="center"><a href="about-us.jsp"><img src="../graphics/about-us-button.gif" border="0"><br>About Us</a></td></tr></table></div>
	  </c:if>  

<!-- there is no way to do this without tables unfortunately -->
			<div id="content">
				
				<table border="0" id="main">
					<tr>
					  <td>
	  		           <div id="left-column">
			        	<%@ include file="../include/left.jsp" %>
			          </div>
			          </td>
						<td>
							<div id="right-column">
								<b>
									Cosmic rays are streaming through you at this very moment. Find out what they are and how you can learn about them.
								</b>
								<blockquote>
									<p>
										<i>
											Scientists love a mystery, because solving a mystery in nature means the opportunity to learn something new about the universe. High-energy cosmic rays are just such a mystery.
										</i>
									</p>
									
									<p>
										<i>
											Something out there &mdash; no one knows what &mdash; is hurling incredibly energetic particles around the universe. Do these particles come from some unknown superpowerful cosmic explosion? From a huge black hole sucking stars to their violent deaths? From colliding galaxies? From the collapse of massive invisible relics from the origin of the universe? We don't yet know the answers, but we do know that solving this mystery will take scientists another step forward in understanding the universe."
										</i>
									</p>
									<p align=right>
										<font size=-1>
											(Pierre Auger Project www.auger.org/cosmic_rays)
										</font>
									</p>
								</blockquote>

								<p>
									When distant stars explode, charged particles are ejected into space. These nuclei (mostly protons) drift through the universe; some collide with Earth's atmosphere and become "cosmic rays." These collisions create showers of lower energy particles. Some you may know &mdash; protons, neutrons, smaller nuclei. Some are more exotic &mdash; pions, kaons, muons. Some of the exotic particles decay in the upper atmosphere; longer-lived particles reach  Earth's surface. Each second, about 100 of these secondary cosmic rays pass though your body.
								</p>
								
								<p>
									The particles that reach the earth are very easy to detect. One way is to use our <a href="../flash/daq_only_standalone.html"> setup</a> of counters, photomiltiplier tubes (PMT) and a data acquisition card (DAQ). Together, these represent a simple system that records indirect evidence of cosmic ray activity. 
								</p>

								<p>
									The DAQ records this evidence in local computer files; detector owners can upload these files to our server, and you can investigate the data. We provide analysis tools and even connect to the Grid, giving you access to computing resources for number crunching. The raw data, analysis tools and other features are collectively known as the <b>Cosmic Ray e-Lab</b>. Using it requires some guidance for asking good research questions and understanding the entire research process.
								</p>
							</div>
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