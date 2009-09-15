<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>CMS Data Interface</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
	</head>
	
	<body id="search_default" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-data.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">
				
<h1>What can you learn? Choose a study.</h1>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
				<div class="tab">
					<span class="tab-title">Analysis</span>
					<div class="tab-contents">
						<p>
							<a href="../analysis-shower-depth">Shower Depth</a> -
							Determine shower length in the detector.
						</p>
						<p>
							<a href="../analysis-lateral-size">Lateral Shower Size</a> -
							Determine shower width in the detector.
						</p>
						<p>
							<a href="../analysis-beam-purity">Beam Purity</a> -
							Determine beam composition.
						</p>
						<p>
							<a href="../analysis-resolution">Detector Resolution</a> -
							Determine the precision of the energy measurements.
						</p>
						<p>
							<a href="http://www-root.fnal.gov/root/">ROOT Tutorial</a> - 
							Learn how to use ROOT (the underpinnings of OGRE) to analyze
							any aspect of the data directly
						</p>
					</div>
				</div>		
			</div>
		</td>
		<td>
			<div id="right">
				<div class="tab">
					<span class="tab-title">Management</span>
					<div class="tab-contents">
						<h2>VIEW</h2>
						<p>
							<a href="../data/view.jsp">Data Files</a>
							- See what data has been uploaded into the system.
						</p>
						<p> 
							<a href="../plots/?submit=true&key=all&uploaded=true">Plots</a>
							- Look at what you and other groups have uploaded! Coming soon - plots saved from OGRE...
						</p>
						<h2>DELETE</h2>
						<p>
							<a href="../plots/delete.jsp">Plots</a>
							- Delete plots your group owns.
						</p>
					</div>
				</div>
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
