<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Shower Depth Study Tutorial</title>
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
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-data.jsp" %>
						</div>
					</div>
				</div>
			</div>
			<div id="content">
			
<h1>Shower Depth Study Background</h1>
<h2>Tutorial - Using OGRE to Determine Shower Depth</h2>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
      <p align="left">In a shower depth study one would like to characterize how  deeply in the calorimeter a particle&rsquo;s energy is deposited.</p>
      <p align="left">The deposition of  energy in a calorimeter is often called a shower because its shape is similar  to that of a shower (i.e. begins narrowly and spreads out with increasing depth).</p>
      <p align="left"> In the calorimeter, particles pass first through the electromagnetic calorimeter  (Ecal) and then through the hadronic calorimeter (Hcal). Particles that  deposit most of their energy in Ecal are said to have a lesser shower depth, and  those that deposit most of their energy in Hcal are said to have a greater  shower depth.</p>
      <p align="left"> One might imagine that the location of the energy (whether it&rsquo;s  in Ecal or Hcal) might depend on the type of beam (e.g. electron, muon or pion)  and the energy of the beam (e.g. 30GeV, 100GeV or 300GeV).</p>
      <p align="left"> To simplify your  study we suggest you begin by investigating data sets that have a common  particle identity and energy (e.g. either 50GeV electrons or 100GeV pions).</p>
      <p align="left"><strong>Research Question: </strong>Does the particle I am studying deposit most of its energy in Ecal or Hcal? </p>
      <table width="665" border="0" align="left">
        <tr>
          <th scope="col"><p><strong>Hints</strong></p>
            <p>&nbsp;</p>
          <p>&nbsp;</p></th>
          <th scope="col"><ul>
            <li>
               <div align="left">Review <a href="#" onclick="javascript:window.open('http://cmsinfo.cern.ch/outreach/CMSdocuments/DetectorDrawings/Slice/CMS_Slice.swf', 'cms', 'width=800,height=600, resizable=1, scrollbars=1');return false;">how particles interact with the calorimeter</a>.
              </div>

            </li>
            <li>
              <div align="left">Begin by  limiting your data set to a single particle with a single energy. </div>
            </li>
            <li>
              <div align="left">This study is a good introduction to the other studies and should probably be done first. </div>
            </li>
          </ul>          </th>
        </tr>
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
