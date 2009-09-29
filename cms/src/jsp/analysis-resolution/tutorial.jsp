<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Detector Resolution Study</title>
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
			
<h1>Detector Resolution Study Background</h1>
<h2>Tutorial - Using OGRE to Determine Detector Resolution</h2>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
        <p align="left">In a study of the calorimeter&rsquo;s resolution one would like to  characterize how precisely the calorimeter measures a particle&rsquo;s energy. To begin such a study choose a particular beam type and energy (e.g. 50 GeV electrons or 100GeV pions). </p>
        <p align="left">A histogram of the energy should yield a bell-shaped curve or distribution. A good measure of the calorimeter's energy resolution for the selected type/energy beam is the half-width of the bell-curve at half the curve's maximum height (HWHM). The width will be in energy units.</p>
        <p align="left">A typical result would be (100&plusmn;15)GeV: where 100GeV is the mean (average) value   and 15GeV is the HWHM or precision. Another valuable (and more often used), indication of the precision is the RMS (root mean square deviation) of the distribution. </p>
        <p align="left"><strong>Research Question:</strong> How precisely does the calorimeter measure a particle's energy?</p>
        <table width="665" border="0">
          <tr>
            <th scope="col"><p align="left"><strong>Hints</strong></p>
            <p align="left">&nbsp;</p>
            <p align="left">&nbsp;&nbsp;&nbsp;&nbsp;</p></th>
            <th scope="col"><div align="left">
              <ul>
                             <li>
                Begin by  limiting your data set to a single particle with a single energy. </li>
                <li>
            It would be helpful to have done a <a href="../analysis-shower-depth/index.jsp">Shower Depth</a> study, a <a href="../analysis-lateral-size/">Lateral Size</a> study and a <a href="../analysis-beam-purity/">Beam Purity</a> study first. &nbsp;&nbsp; </li>
              </ul>
            </div></th>
          </tr>
        </table></td></tr>
</table>


			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
