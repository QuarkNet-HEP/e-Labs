<%@ include file="../include/elab.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Classroom Notes</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
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


<h1>Learn how to do cosmic rays studies in your classroom.</h1>

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
				<p> 
					<a href="../jsp/detector.jsp">The QuarkNet Detector</a>
				</p>
				
				<h2>Experiments Students Can Perform</h2>
				<ol> 
					<li>Calibrations and performance studies</li>
					<li>Flux experiments</li>
					<li>Muon lifetime experiments</li>
					<li>Shower studies</li>
					<li>Other studies devised by students</li>
				</ol> 

				<h2>Calibrations and Performance Studies</h2>
				<p>
					Before students can "trust" the cosmic ray equipment, they 
					should do some calibrations to study the response of the 
					counters and the board. Calibration studies include 
					plateauing the counters, threshold selection and barometer 
					calibration. In addition, the QuarkNet online analysis 
					tools include a "system performance" study for uploaded data.
				</p>

				<h2>Flux Experiments</h2>
				<p>
					Your students can do a variety of flux experiments 
					investigating such things as cosmic ray flux as a function of 
					time of day, solar activity, angle from vertical, barometric 
					pressure, altitude. The list goes on. This can be an exciting 
					set of experiments as students study the factors that they 
					want to test.
				</p>

				<h2>Muon Lifetime Experiment to Verify Time Dilation</h2>
				<p>
					A classic modern physics experiment to verify time dilation 
					is the measurement of the muon mean lifetime. Since nearly all 
					of the cosmic ray muons are created in the upper part of the 
					atmosphere (>>30 km above the earth's surface), the time of 
					flight for these muons as they travel to earth should be at 
					least 100 microseconds:
				</p>
				<p>
					<img src="../graphics/tof_equation.gif"/>
				</p>
				<p>
					This calculation assumes that muons are traveling at the speed 
					of light - anything slower would require even more time. If a 
					student can determine the muon lifetime and show that it is 
					significantly less than this time, they are presented with the 
					wonderful dilemma that the muon's time of flight is longer than 
					its lifetime! 
				</p>
				<p>
					This time dilation "proof" assumes that all muons are created in 
					the upper atmosphere. Although this is actually a good 
					approximation, your students cannot test it. However, by using 
					the mean lifetime value and by measuring flux rates at two 
					significantly different elevations, you can develop experimental 
					proof for time dilation. This experiment requires you to have 
					access to a mountain, an airplane, or collaboration with a team 
					from another school that is at a significantly different altitude! 
					Here is a wonderful opportunity for schools to work together 
					proving time dilation. A very thorough explanation of this 
					experiment is outlined in the 1962 classroom movie titled, "Time 
					Dilation: An Experiment with Mu Mesons." (This 30 minute movie 
					can be ordered on CD for $10 from www.physics2000.com/.)   This 
					movie helps you (and your students) understand how the muon 
					lifetime measurement (along with flux measurements at two 
					different altitudes) can be used to verify time dilation.
				</p>

				<h2>Shower Studies</h2>
				<p>
					With the GPS device connected to your DAQ board, the absolute 
					time stamp allows a network of detectors (at the same site or at 
					different schools) to study cosmic ray showers. Your students 
					can look for small showers or collaborate with other schools in 
					your area to look for larger showers. 
				</p>
				<p>
					The QuarkNet online analysis tools allow students to not only 
					look for showers but to calculate the direction from which the 
					shower (and thus the primary cosmic ray) originated.
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
