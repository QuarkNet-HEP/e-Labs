<HTML>    
<head><title>Execution Choices</title>
<link rel="stylesheet"  href="../include/styletut.css" type="text/css">
</head>
<body onLoad="focus()">
<div style="margin-left: 10px;">

<h2>How to choose where your analysis is executed </h2>

<p>When running an analysis, you get to choose where the analysis is run.</p>

<p> The analysis can run in three places:</p> <ul>
<li> Local machine
</li> <li> I2U2 cluster
</li> <li> Grid (initially the Teraport cluster at the Computation Institute, University of Chicago)
</li></ul> 
<p />
If you choose Automatic, the scheduler will decide the best place to run the analysis.
<p />
This diagram shows the choices you will see on your computer screen and the configuration of the computers you can access.<br />
<p />
   <img src="../graphics/i2u2-execution.jpg" alt="Execution Choices" width='596' height='596'  border="1" />
<p />
<p />
<p />
This table summarizes the features of the different choices you can make. The term "job" means an analysis you have submitted.
<p />
<p />
<table border="1" cellspacing="1" cellpadding="3" style="font-size: 12px">
  <tr bgcolor="white">
    <th width="69" valign="top" align="center">Where</th>
    <th width="69" valign="top" align="center">Speed</th>
    <th width="68" valign="top" align="center">Reliability</th>
    <th width="118" valign="top" align="center">Pros</th>
    <th width="95" valign="top" align="center">Cons</th>
    <th width="173" valign="top" align="center">Best for</th>
  </tr>
  <tr  bgcolor="#FFFF66">
    <td width="69" valign="top">Local</td>
    <td width="69" valign="top">Fast</td>
    <td width="68" valign="top">High</td>
    <td width="118" valign="top">Immediate results for short jobs</td>
    <td width="95" valign="top">Ties up the CPU and slows down other local analyses</td>
    <td width="173" valign="top">Fast jobs involving small datasets</td>
  </tr>
  <tr  bgcolor="#FFFF66">
    <td width="69" valign="top">I2U2 cluster</td>
    <td width="69" valign="top">Half as fast as local</td>
    <td width="68" valign="top">Still in testing</td>
    <td width="118" valign="top">Larger analyses can be run without affecting local analyses.</td>
    <td width="95" valign="top">Slower; still being tested     </td>
    <td width="173" valign="top">Intermediate size jobs with medium data sets</td>
  </tr>
  <tr   bgcolor="#FFFF66">
    <td width="69" valign="top">Grid<br />
    (Cutting-edge tool in development)</td>
    <td width="69" valign="top">Slow</td>
    <td width="68" valign="top">Least reliable</td>
    <td width="118" valign="top">Ability to run large CPU and data intensive jobs</td>
    <td width="95" valign="top">Slowest and sometimes unreliable</td>
    <td width="173" valign="top">CPU-intensive jobs with large datasets</td>
  </tr>
</table>
<p />
<p />
<h2><a name="Screens_Encountered_After_Submit"></a> Screens Encountered after Submitting a Job to I2U2 Cluster or the Grid</h2>
<p>You can watch the progress and queue an analysis so you can go work on something else.  You will see the following on your screen once you have started the analysis:</p>
<p />
<br />
   <img src="../graphics/in-progress.jpg" alt="in-progress.jpg" width='593' height='313' border="1" />
<p />
<p>Later you can click on the Analyses submenu on the Data Menu and see a list showing how your submitted analyses are doing and click on the results when they are done:
<strong>The submitted analyses only stay on this queue for a set period of time, so it is important to get your results and save them as plots if you want to keep them.</strong></p>
<p />
<br />
   <img src="../graphics/analysis-list.jpg" alt="analysis_list.jpg" width='700' height='231'  border="1" />
<p>Good luck with your study!</p>
</div>

</body>
