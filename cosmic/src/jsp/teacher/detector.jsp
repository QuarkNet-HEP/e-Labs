<%@ include file="../include/elab.jsp" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
	<head>
		<title>QuarkNet Cosmic Ray Detector</title>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	</head>

	<body id="community">
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
 <h1>Introduction to the QuarkNet cosmic ray detector.</h1>

<p><img alt="200 Series - Pre 2005 Model" src="../graphics/detector.jpg" width="576" height="397" />
<br />200 Series - Pre 2005 Model
</p><p><img alt="5000 Series - 2006 Model" src="../graphics/detector5000.jpg" width="576" height="432" />
<br />5000 Series - 2006 Model
</p><p><img alt="6000 Series - 2007 Model" src="../graphics/detector6000.jpg" width="499" height="375" />
<br />6000 Series - 2007 Model
</p>
<table width="800" align="left">

<tr><td width="50%" valign="TOP">
<p>1. Counters-scintillators, light guides, photomultiplier tubes and bases (two shown)<br />
2. QuarkNet DAQ board<br />
3. 5 VDC adapter<br />
4. GPS receiver
</p>
</td><td valign="TOP" width="50%">
<p>5. GPS extension cable<br />
6. RS-232 cable (to link to computer serial port)<br />
7. Optional RS-232 to USB adapter (to link to computer USB port instead of serial port)<br />
8. Lemo signal cables<br />
9. Daisy-chained power cables
</p>
</td></tr>
<tr><td colspan="2">
<p>For this setup, the DAQ board takes the signals from the counters and provides signal processing 
and logic basic to most nuclear and particle physics experiments. The DAQ board can anlyze signals 
from up to four PMTs. (We show two in the photo.) The board produces a record of output data 
whenever the PMT signal meets a pre-defined trigger criterion (for example, when two or more 
PMTs have signals above some predetermined threshold voltage, within a certain time window). 
The output data record, which can be sent via a standard RS-232 serial interface to any PC, 
contains temporal information about the PMT signals. This information includes: how many channels 
had above-threshold signals, their relative arrival times (precise to 0.75 ns), and the starting 
and stopping times for each detected pulse. In addition, an external GPS receiver module provides 
the absolute <a href="/cosmic/library/body.php?title=UTC" title="UTC">UTC Time</a> of each trigger, accurate to about 50 ns. 
This allows counter arrays using separate DAQ boards such as different schools in a wide-area 
array or two sets of counters at the same site to correlate their timing data. Keyboard commands 
allow you to define trigger criteria and retrieve additional data, such as counting rates, 
auxiliary GPS data, and environmental sensor data (temperature and pressure). 
</p>
<p>
<b>Want more information?</b>
</p>
<p>
<a href="http://www18.i2u2.org/elab/cosmic/jsp/data.jsp" class="external text" rel="nofollow">Explanation of the Data</a>
</p>
<p>
User Manuals: <a href="http://www18.i2u2.org/cosmic/library/upload/b/ba/6000CRMDUserManual.pdf" title="6000CRMDUserManual.pdf">Series "6000"</a> - <a href="http://quarknet.fnal.gov/toolkits/ati/det-user.pdf" class="external text" rel="nofollow">Series "200" &amp; "5000"</a>
</p>
<p>
Assembly Instructions: <a href="http://www18.i2u2.org/cosmic/library/upload/6/60/6000CRMDAssemblyInstructions.pdf" title="6000CRMDAssemblyInstructions.pdf">Series "6000"</a> - <a href="http://www18.i2u2.org/cosmic/library/upload/b/bd/CRMDAssemblyInstructionsV1.3.pdf" title="CRMDAssemblyInstructionsV1.3.pdf">Series "5000"</a>
</p>
<p>
Series "6000" CRMD Plateauing Instructions: <a href="http://www18.i2u2.org/cosmic/library/upload/3/3f/6000CRMD_How_to_Plateau.ppt" title="6000CRMD How to Plateau.ppt">PowerPoint HOWTO</a> - <a href=""http://www18.i2u2.org/cosmic/library/upload/1/1b/6000Plateau_Template.xls" title="6000Plateau Template.xls">Spreadsheet</a>
</p>
</td></tr>
</table>

			</div>
			<!-- end content -->

			<div id="footer">

			</div>
		
		</div>
		<!-- end container -->
	</body>
</html>
