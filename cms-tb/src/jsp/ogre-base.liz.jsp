<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
    <META HTTP-EQUIV="Pragma" content="no-cache">
    <head>
      <title>OGRE CMS HCAL TB04 Page</title>

      <Script Language="JavaScript" Type="Text/JavaScript" SRC="http://129.74.67.184/~ogre/run_utilities.js"></SCRIPT>
      <Script Language="JavaScript" Type="Text/JavaScript" SRC="http://129.74.67.184/~ogre/utilities.js"></Script>

    </head>
<%@ include file="include/javascript.jsp" %>

  <body onLoad="javascript:document.getData.gcut.checked=true;">
  <%
  // put proper header depending on analysis
  String analysis=request.getParameter("analysis");
  String studyResource=""; // file where resource for this study is.
  String studyTitle="";
  String studyText="";
  String studySubtext="";
  if (analysis == null) analysis="shower_depth";
  if (analysis.equals("shower_depth")) {
  studyResource="res_shower_depth.jsp";
  studyTitle="Shower Depth";
  studyText="Using OGRE to Determine Shower Depth";
  studySubtext="How deep in the calorimeter is the energy of the particles deposited?";
  
  }
  else if (analysis.equals("lateral_size")) {
  studyResource="res_lateral_size.jsp";
  studyTitle="Lateral Size";
  studyText="Using OGRE to Determine Lateral Size";
  studySubtext="Determine the shower's width in the detector.";
  }
  else if (analysis.equals("beam_purity")) {
  studyResource="res_beam_purity.jsp";
  studyTitle="Beam Purity";
  studyText="Using OGRE to Determine the Purity of the Beam";
  studySubtext="Determine the composition of the beam.";
  }
  
  else if (analysis.equals("resolution")) {
  studyResource="res_detector_resolution.jsp";
  studyTitle="Detector Resolution";
  studyText="Using OGRE to Determine the Resolution of the Detector.";
  studySubtext="Determine the determine the precision of the energy measurements.";
  }
  
  
  
  
  %>
   <h2  align="center" >OGRE <%=studyTitle%> Study</h2>
  <h3 align="center" class="style2" style='text-align:center'><%=studySubtext%> Need <A HREF="javascript:showRefLink('<%=studyResource%>',930,700)"> Background</a>?</h3>

<iframe src=http://129.74.67.184/~ogre/test4/ width=100% height=1300>

<%--    <CENTER>

    <!-- Change CGI path on moving! -->
    <form method="POST" name="getData" 
      action="http://129.74.67.184/~ogre/cgi-bin/get_histo.pl.cgi" target="graphics"
      onsubmit="javascript:popGraphics();">

	<H2>CMS HCal Testbeam 04 Data</H2>

	<Script Language="JavaScript" Type="Text/JavaScript">setNumberOfVariables();</Script>

	<table border=5 cellpadding=5>
	  <!-- Put up the table header -->
	    <tr align="center" valign="baseline">
	      <td><FONT color="blue"><H4>Select Variable</H4></FONT></td>
	      <td><FONT color="blue"><H4>Selection Criteria</H4></FONT></td>
	      <td><FONT color="blue"><H4>Plot Style</FONT></H4></td>
	      <td><FONT color="blue"><H4>Histogram Fill Color</H4></FONT></td>
	    </tr>

	    <!-- Put up the table of variables that can be plotted -->
	    <Script Language="JavaScript" Type="Text/JavaScript">createLeafTable();</Script>

	    <!-- Put up a text box for entering formula directly into ROOT -->
	    <tr>
	      <td>Formula&nbsp;&nbsp<input type="text" name="formula"></td>
	      <td><input type="text" name="cutf" size="17"></td>
	      <td>
		<input type="checkbox" name="logxf" value="1">logx
		<input type="checkbox" name="logyf" value="1">logy
		<input type="checkbox" name="logzf" value="1">logz
	      </td>
	      <td>
		<select name="colorf">
		  <option value=0>None
		  <option value=1>Black
		  <option value=2>Red
		  <option value=3>Green
		  <option value=4>Blue
		  <option value=5>Yellow
		  <option value=6>Purple
		</select>
		<input type="checkbox" name="intensityf" value=1> Use Dark Colors<BR>
	      </td>
	    </tr>

	    <tr>
	      <td><input type="checkbox" name="gcut" value="beam==1">Apply Beam Cut</td>
	      <td align="center"><input type="checkbox" name="savedata" value=1>Save Raw Data</td>
	      <td>Start with event: <input type="text" name="first" size="4" value="1"></td>
	      <td>Number of events to plot: <input type="text" name="nEntries" size="4"></td>
	    </tr>

	</table>

	<H2>Data Options</H2>
	<table border=5 cellpadding=5>
	    <tr align="center" valign="baseline">
	      <td><FONT color="blue"><H4>Select all runs of type</FONT></H4></td>
	      <td><FONT color="blue"><H4>Data to Plot</FONT></H4></td>
	      <td><FONT color="blue"><H4>Run Info</FONT> &nbsp;&nbsp;
		  <a href="http://pcephc356.cern.ch:8000/%7Edaq/searchForm.php" target=_blank>
		    (Search the CMS HCal TB Run DataBase)</a></H4>
	      </td>
	    </tr>
	    <tr>
	    <td>
	      <input type="checkbox" name="muon_runs" onClick="javascript:select_runs();">&nbsp;muons<BR>
	      <input type="checkbox" name="pion_runs" onClick="javascript:select_runs();">&nbsp;pions<BR>
	      <input type="checkbox" name="elec_runs" onClick="javascript:select_runs();">&nbsp;electron<BR>
	      <input type="checkbox" name="cal_runs"  onClick="javascript:select_runs();" >&nbsp;Calibration<BR>
	      <input type="checkbox" name="all_runs"  onClick="javascript:select_runs();" >&nbsp;All
	    </td>
            <Script Language="JavaScript" Type="Text/JavaScript">setRunList();</Script>
	    </tr>
	</table>

	<H2>Graphics Options</H2>
	<table border=5 cellpadding=5>
	    <tr align="center" valign="baseline">
	      <td><FONT color="blue"><H4>Graphics Size</FONT></H4></td>
	      <td><FONT color="blue"><H4>Output Graphics Type</FONT></H4></td>
	      <td><FONT color="blue"><H4>All Plots on One Histogram</FONT></H4></td>
	    </tr>

	    <tr>
	      <td>
		Width &nbsp;&nbsp;<input type="text" value=800 name=gWidth  size=4 onBlur="javascript:checkgSize();">
		Height      &nbsp;<input type="text" value=600 name=gHeight size=4 onBlur="javascript:checkgSize();">
	      </td>
	      <td>
		<input type="radio" name="type" value=1 checked>PNG
		<input type="radio" name="type" value=2        >JPG
		<input type="radio" name="type" value=4        >EPS
	      </td>
	      <td align="center"><input type="checkbox" name="allonone" value=1>&nbsp;Yes</td>
	    </tr>
	</table>

      <BR>

      <input type=SUBMIT value="Plot">&nbsp;&nbsp;
      <input type="button" value="Previous Results" onclick="javascript:showPrevious();">
      <input type=RESET  value="Reset Values">&nbsp;&nbsp;
      <input type="button" value="Close Popups" onclick="javascript:closePopUps();">
    </form>

    </CENTER>

    <hr>
    <address><a href="mailto:karmgard.1@nd.edu">Bug the OGRE</a></address>
<!-- Created: Thu May 20 13:17:23 EST 2004 -->
<!-- hhmts start -->
Last modified: Sat Nov 13 14:48:08 EST 2004
<!-- hhmts end -->
--%>
  </body>
</html>
