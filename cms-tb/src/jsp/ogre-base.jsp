<html>
  <body onLoad="javascript:document.getData.gcut.checked=true;">

<%@ include file="include/javascript.jsp" %>
			<!-- header/navigation -->
			<%
				//be sure to set this before including the navbar
				String headerType = "Data";
			%>
<%@ include file="include/navbar_common.jsp" %>


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
    
  <iframe src=ogre-base.php width=100% height=1200>
  </body></html>