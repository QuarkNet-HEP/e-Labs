<%@ include file="../include/elab.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Classroom Notes</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
	</head>

	<body id="teacher">
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


<h1>Learn how to use seismometer data in your classroom</h1>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
			</div>
		</td>
		
		<td>
			<div id="center">
				<h2>Classroom Notes</h2>
				<p>
					<!--  this should probably be a ul -->
					<a href="notes.jsp">Notes</a>
					- <a href="strategy.jsp">Teaching Strategies</a>
					- <a href="web-guide.jsp">Research Guidance</a>
					- <a href="activities.jsp">Sample Classroom Activities</a>
				</p>
				<h2>Earthquake Studies</h2>
				<p>
					A number of earthquake studies are possible with the e-Lab 
					data. From what epicenter distance can LIGO detect earthquake 
					waves? How fast do earthquake waves travel? Are P and S waves 
					distinguishable in the data? If so, what can we learn about 
					how these waves travel through the earth?
				</p>
				<h2>Frequency Band Studies</h2>
				<p>
					LIGO's Data Monitoring Tool data channels (DMT channels) are 
					segregated by frequency ranges. Students can study similar time
					periods and/or similar seismic events by looking at different 
					frequencies of seismic vibrations.
				</p>
				<h2>Microseismic Studies</h2>
				<p>
					Microseisms provide a constant low-frequency seismic signal in 
					the ground that is related to ocean wave activity. What 
					environmental factors can cause microseisms to vary in 
					strength?
				</p>
				<h2>Studies of Human-induced Seismic Activity</h2>
				<p>
					Humans do things that make the ground shake. What types of human 
					activity can show up in LIGO data? What effect do these 
					activities exert on LIGO's interferometers?
				</p>
			</div>
		</td>
		<td>
			<div id="right">
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
