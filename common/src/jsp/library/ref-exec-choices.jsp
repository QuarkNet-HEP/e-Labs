<HTML>    
<head><title>Reference Question</title>
<link rel="stylesheet"  href="include/styletut.css" type="text/css">
</head>
<body onLoad="focus()">

<h2>How to choose how and where your analysis is executed </h2>
<p />
<div style="margin-left: 10px;">
When running an analysis, you get to choose how and where the analysis is run.
<p />
<h3><a name="How"></a><a name="How_"></a> How: </h3>
There are two systems to express, execute and track results of analysis workflows.
<p />
VDS &#8211; the GriPhyN Virtual Data System that uses the Virtual Data Language to describe workflows.
<p />
SWIFT- the successor to VDS that uses Swiftscript to describe workflows.
<p />
<h3><a name="Where"></a><a name="Where_"></a> Where: </h3>
<p />
VDS currently runs the analysis on the local machine.  It provides the fastest results if there is only one analysis running.
<p />
 SWIFT can run in three places: <ul>
<li> Local machine,
</li> <li> I2U2 cluster,
</li> <li> Grid (initially the Teraport cluster at the Computation Institute, University of Chicago)
</li></ul> 
<p />
If you choose Automatic, the Swift scheduler will decide the best place to run the analysis.
<p />
This diagram shows the choices you will see on your computer screen and the configuration of the computers you can access.<br />
<p />
   <img src="../graphics/i2u2-execution.jpg" alt="Execution Choices" width='620' height='576'  border="1" />
<p />
<p />
<p />
This table summarizes the features of the different choices you can make. The term "job" means an analysis you have submitted.
<p />
<p />
<table border="1" cellspacing="1" cellpadding="3" >
  <tr bgcolor="white">
    <td width="50" valign="top"><p align="center"><b>How</b></p></td>
    <td width="69" valign="top"><p align="center"><b>Where</b></p></td>
    <td width="69" valign="top"><p align="center"><b>Speed</b></p></td>
    <td width="68" valign="top"><p align="center"><b>Reliability</b></p></td>
    <td width="118" valign="top"><p align="center"><b>Pros</b></p></td>
    <td width="95" valign="top"><p align="center"><b>Cons</b></p></td>
    <td width="173" valign="top"><p align="center"><b>Best For</b></p></td>
  </tr>
  <tr bgcolor="#d5d7eb">
    <td width="50" valign="top"><p>VDS</p></td>
    <td width="69" valign="top"><p>Local</p></td>
    <td width="69" valign="top"><p>Fast</p></td>
    <td width="68" valign="top"><p>High</p></td>
    <td width="118" valign="top"><p>Immediate results for short jobs</p></td>
    <td width="95" valign="top"><p>Ties up the CPU and slows down other local analyses</p></td>
    <td width="173" valign="top"><p>Fast jobs involving small datasets</p></td>
  </tr>
  <tr  bgcolor="#FFFF66">
    <td width="50" valign="top"><p>Swift</p></td>
    <td width="69" valign="top"><p>Local</p></td>
    <td width="69" valign="top"><p>Fast</p></td>
    <td width="68" valign="top"><p>High</p></td>
    <td width="118" valign="top"><p>Immediate results for short jobs</p></td>
    <td width="95" valign="top"><p>Ties up the CPU and slows down other local analyses</p></td>
    <td width="173" valign="top"><p>Fast jobs involving small datasets</p></td>
  </tr>
  <tr  bgcolor="#FFFF66">
    <td width="50" valign="top"><p>&nbsp;</p></td>
    <td width="69" valign="top"><p>i2u2 cluster</p></td>
    <td width="69" valign="top"><p>Half as fast as local</p></td>
    <td width="68" valign="top"><p>Still in testing</p></td>
    <td width="118" valign="top"><p>Larger analyses can be run without affecting local analyses</p></td>
    <td width="95" valign="top"><p>Slower; still being tested <br />
    </p>
    </td>
    <td width="173" valign="top" bgcolor="#FFFF66"><p>Intermediate size jobs with medium data sets</p></td>
  </tr>
  <tr   bgcolor="#FFFF66">
    <td width="50" valign="top"><p>&nbsp;</p></td>
    <td width="69" valign="top"><p>Grid<br />
    (Cutting-Edge Tool Still in Development)</p></td>
    <td width="69" valign="top"><p>Slow</p></td>
    <td width="68" valign="top"><p>Least reliable</p></td>
    <td width="118" valign="top"><p>Ability to run large CPU and data intensive jobs</p></td>
    <td width="95" valign="top"><p>Slowest and sometimes unreliable</p></td>
    <td width="173" valign="top"><p>CPU-intensive jobs with large datasets</p></td>
  </tr>
</table>
<p />
<p />
<h2><a name="Screens_Encountered_After_Submit"></a> Screens Encountered After Submitting a Job to i2u2 Cluster or the Grid. </h2>
You can watch the progress and queue an analysis so you can go work on something else.  You will see the following on your screen once you have started the analysis:
<p />
<br />
   <img src="../graphics/in-progress.jpg" alt="in-progress.jpg" width='593' height='313' border="1" />
<p />
Later you can click on the Analysis submenu on the Data Menu and see a list showing how your submitted analyses are doing and click on the results when they are done:
<strong>The submitted analyses only stay on this queue for a set period of time, so it is important to get your results and save them as plots if you want to keep them.</strong>
<p />
<br />
   <img src="../graphics/analysis-list.jpg" alt="analysis_list.jpg" width='700' height='231'  border="1" />
<p />Good luck with your study!<p />
</div>
</body>
</html>