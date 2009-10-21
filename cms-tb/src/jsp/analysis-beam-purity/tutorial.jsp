<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Beam Purity Study Backgrounde</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
	</head>
	
	<body id="search_default" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			<div id="content">
			
<h1>Beam Purity Study Background</h1>
<h2>Tutorial - Using OGRE to Determine Beam Purity</h2>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
        <p align="justify">In a beam purity study one would like to characterize  the fraction of the  particles in the beam that correspond to the particle type requested for  each type of beam (e.g. 50GeV electrons or 100GeV pions).</p>
        <p align="justify"> For  example, if electrons are requested, are all the particles in the beam  electrons? In general, the beam&rsquo;s purity is not 100%. A purer beam can often be  produced, but an increase in purity usually comes at the expense of luminosity  (the number of beam particles).</p>
        <p align="justify"> A scatterplot of Ecal vs Hcal is useful in this  study. To simplify your study we suggest you begin by investigating data sets  that have a common particle identity and energy (e.g. either 50GeV electrons or  100GeV pions). We also recommend you do the Shower Depth and Lateral Size  studies first if you have not yet done them.</p>
        <p align="justify"><strong>Research Question: </strong>How much of he beam I am using for my study is actually the type of beam particle I requested? </p>
        <table width="665" border="0">
          <tr>
            <th scope="col"><p><strong>Hints</strong></p>
            <p>&nbsp;</p>
            <p>&nbsp;</p></th>
            <th scope="col"><ul>
              <li>
                <div align="left">Review how to make <a href="#" onclick="javascript:window.open('http://www.shodor.org/interactivate/activities/scatterplot/index.html', 'cms', 'width=900,height=700, resizable=1, scrollbars=1');return false;">scatter plots</a> from the  basics.</div>
                         </li>
              <li>
                <div align="left">Begin by  limiting your data sets to those that claim to be the same particles 
                  and only  ones  at the same energy.&nbsp; </div>
              </li>
            </ul>            </th></tr>
</table>
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
