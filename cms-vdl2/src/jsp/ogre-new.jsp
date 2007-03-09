<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>


<Script Language="JavaScript" Type="Text/JavaScript" SRC="utilities.js"></Script>
<Script Language="JavaScript" Type="Text/JavaScript" SRC="run_utilities.js"></Script>

<jsp:useBean id="formHandler" class="gov.fnal.elab.cms.beans.OgreBean" scope="session"/>
<jsp:useBean id="tbData" class="gov.fnal.elab.cms.beans.TBDataBean" scope="session"/>
<jsp:useBean id="runData" class="gov.fnal.elab.cms.beans.RunDataBean" scope="session"/>


<%
out.println("<Script Language=\"JavaScript\" Type=\"Text/JavaScript\">");
out.println("var number_of_runs = 71;");
out.println("var runType;");

out.println(runData.getRunListArray());
out.println(runData.getMuonArray());
out.println(runData.getPionArray());
out.println(runData.getElecArray());
out.println(runData.getCalArray());
out.println(runData.getRunDataArray());

out.println("function getRunData() {");
//out.println(" alert(\"Get Run Data\");");
out.println("	var text = \"\";");
out.println("	for (var i=0; i<number_of_runs; i++) {");
out.println("		if (document.getData.run_number[i].selected) {");
out.println("			text = text + runData[i];");
out.println("	}}document.getData.dummy.value = text;return true;}");

out.println("");

out.println("function select_muons() {");
//out.println(" alert(\"Execute MUONS\");");
out.println("  if ( document.getData.all_runs.checked ) {");
out.println("		document.getData.all_runs.checked = false;");
out.println("		select_all();");
out.println("	}");

out.println("  for ( var i=0; i<number_of_runs; i++ ) {");
out.println("    document.getData.run_number[i].selected = false;");
out.println("  }");

out.println("  if ( document.getData.muon_runs.checked ) {");
//out.println(" alert(\"Checked MUONS box\");");
out.println("    var j = 0;");
out.println("    for ( var i=0; i<number_of_runs; i++ ) {");
out.println("      if ( muonRuns[j] == runList[i] ) {");
out.println("			document.getData.run_number[i].selected = true;");
out.println("			j++;");
out.println("      	}");
out.println("    }");
out.println("  } else {");
//out.println(" alert(\"Unchecked Muon Runs\");");
out.println("    var j = 0;");
out.println("    for ( var i=0; i<number_of_runs; i++ ) {");
out.println("      if ( muonRuns[j] == runList[i] ) {");
out.println("	document.getData.run_number[i].selected = false;");
out.println("	j++;");
out.println("      }");
out.println("    }");
out.println("  }");
out.println("  getRunData();");
out.println("  return true;");
out.println("}");


out.println("</script>");
%>


<!-- header/navigation -->
<%	//be sure to set this before including the navbar
String headerType = "Data";
%>
<%@ include file="include/navbar_common-new.jsp" %>

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



    <CENTER>
    
      <img src="graphics/ogre_small.png"></img>
    <FONT color="red"><H2>OGRE is an Online Graphical ROOT Environment</FONT></H2>
      Visit the <a href="http://root.cern.ch" target=_blank>Root</a> Homepage. (Creates a new window.)
    </CENTER>
    <HR>

    <CENTER>
    <form method="POST" name="getData" 
      action="ogreProcess.jsp?process=true" target="graphics"
      onsubmit="javascript:graphicsWin=popWindow('',document.getData.target,document.getData.
                                                    gWidth.value,document.getData.gHeight.value);">

      <!-- Store some basic bootstrap data for ogre.pl -->
      <input type="hidden" name="xmlfile" value="tb_data.xml">
      <input type="hidden" name="dataset" value="tb04">

	<H2>CMS HCal Testbeam '04 Data</H2>

        <table border=5 cellpadding=1>
          <!-- Put up the table header -->
          <tr align="center" valign="baseline">
            <td><FONT color="blue"><H4>Variable</H4></FONT></td>
            <td><FONT color="blue"><H4>Selection</H4></FONT></td>
            <td><FONT color="blue"><H4>Color</H4></FONT></td>
          </tr>

          <!-- Put up the table of variables that can be plotted -->
<%

String configFile = getServletContext().getRealPath("/cms/xml/tb_data.xml");      
//out.println("configFile: "+configFile);   

tbData.populateFromFile(configFile);

//out.println(tbData.getDataLocation());
out.println("<input type=hidden name=dataset_location value=\""+tbData.getDataLocation()+"\" /><tr>");

Vector leaves=tbData.getLeaves();

int leafEntryID=0;

//out.println("LEAVES SIZE "+leaves.size());

for (int i=0;i<leaves.size();i++){
	String[] leafEntry=(String[])leaves.get(i);
	
	try{
		Integer integerLeafEntryID=Integer.decode(leafEntry[0]);
		//out.println("INT: "+integerLeafEntryID);
		leafEntryID=integerLeafEntryID.intValue();
	}catch(NumberFormatException nfe){
		System.out.println(nfe.getLocalizedMessage());
		break;
	}
	
	out.println();
	out.println();
	out.println("<td><input type=\"checkbox\" name=\"leaf\" value=\""+(leafEntryID-1)+"\">&nbsp;"+leafEntry[2]); 
	out.println("<input type=\"hidden\" name=\"root_leaf\"  value=\""+leafEntry[1]+"\"></td>");
	out.println("<input type=\"hidden\" name=\"labelx\"  value=\""+leafEntry[3]+"\"></td>");
	out.println("<input type=\"hidden\" name=\"labely\"  value=\""+leafEntry[4]+"\"></td>");
	out.println("<input type=\"hidden\" name=\"title\"  value=\""+leafEntry[2]+"\"></td>");
	out.println();
	out.println("<td><input type=\"checkbox\" name=\"cuttype\" multiselect value=0 id="+((leafEntryID-1)*3)+" checked onClick=\"javascript:uncheckOthers(this);\">&nbsp; None &nbsp;");
	out.println("<input type=\"checkbox\" name=\"cuttype\" multiselect value=1 id="+((leafEntryID-1)*3+1)+" onClick=\"javascript:uncheckOthers(this);\" >&nbsp; > &nbsp;");
	out.println("<input type=\"checkbox\" name=\"cuttype\" multiselect value=2 id="+((leafEntryID-1)*3+2)+" onClick=\"javascript:uncheckOthers(this);\">&nbsp; < &nbsp;");
	out.println("<input type=\"text\" name=\"cut\" size=\"5\" maxlength=\"5\" id="+(leafEntryID-1)+"  onBlur=\"javascript:isNumeric(this.value,this);\"></td>");
	out.println();
	out.println("<td align=\"center\"><select name=\"color\" id="+(leafEntryID-1)+">");
	out.println("<option value=0>None<option value=1>Black<option value=2>Red");
	out.println("<option value=3>Green<option value=4>Blue<option value=5>Yellow<option value=6>Purple</select></td></tr>");
	
}

Vector formulas=tbData.getFormulas();
	
int formulaEntryID=0;

//	out.println("LEAVES SIZE "+leaves.size());

for (int i=0;i<formulas.size();i++){
		String[] formulaEntry=(String[])formulas.get(i);
		
		try{
			Integer integerFormulaEntryID=Integer.decode(formulaEntry[0]);
			//out.println("INT: "+integerLeafEntryID);
			formulaEntryID=integerFormulaEntryID.intValue();
		}catch(NumberFormatException nfe){
			System.out.println(nfe.getLocalizedMessage());
			break;
		}
		
		out.println();
		out.println();
		out.println("<td><input type=\"checkbox\" name=\"formula\" value=\""+(formulaEntryID-1)+"\">&nbsp;"+formulaEntry[2]); 
		out.println("</td><td><input type=\"text\" name=\"cutf\"  value=\""+formulaEntry[1]+"\"></td>");
		out.println("<input type=\"hidden\" name=\"labelx\"  value=\""+formulaEntry[3]+"\"></td>");
		out.println("<input type=\"hidden\" name=\"labely\"  value=\""+formulaEntry[4]+"\"></td>");
		out.println("<input type=\"hidden\" name=\"title\"  value=\""+formulaEntry[2]+"\"></td>");
		out.println();
		out.println("<td align=\"center\"><select name=\"colorf\" id="+(formulaEntryID-1)+">");
		out.println("<option value=0>None<option value=1>Black<option value=2>Red");
		out.println("<option value=3>Green<option value=4>Blue<option value=5>Yellow<option value=6>Purple</select></td></tr>");
		
}
	

%>
          <tr></tr>
            <td></td>
            <td align="center"><input type="checkbox" name="savedata" value=1>Save Raw Data</td>
            <td align="center">
              <input type="checkbox" name="logx" value=1>logx
              <input type="checkbox" name="logy" value=1>logy
            </td>

          </tr>

	</table>          
	
	
	
	<!-- Now add the runs table from the database -->
	
	
	<H3>Data Selection</H3>
	<table border=5 cellpadding=5>
	    <tr align="center" valign="baseline">
	      <td><FONT color="blue"><H4>Select all runs of type</FONT></H4></td>
	      <td><FONT color="blue"><H4>Data to Plot</FONT></H4></td>
	      <td><FONT color="blue"><H4>Run Info</FONT> &nbsp;&nbsp;

<!--
		  <a href="http://pcephc356.cern.ch:8000/%7Edaq/searchForm.php" target=_blank>
		    (Search the CMS HCal TB Run DataBase)</a></H4>
-->
	      </td>
	    </tr>
	    <tr>
	      <td>
		<input type="checkbox" name="muon_runs" onClick="javascript:select_muons();">     &nbsp;muons<BR>
		<input type="checkbox" name="pion_runs" onClick="javascript:select_pions();">     &nbsp;pions<BR>

		<input type="checkbox" name="elec_runs" onClick="javascript:select_electrons();"> &nbsp;electron<BR>
		<input type="checkbox" name="cal_runs"  onClick="javascript:select_calib();">     &nbsp;Calibration<BR>
		<input type="checkbox" name="all_runs"  onClick="javascript:select_all();">       &nbsp;All
	      </td>

	<!-- Access the runDB and generate a list of available runs -->
	<td>

<select name="run_number" multiple size=5 onChange="javascript:select_single_run();">
	
	<% 
	
	out.println(runData.getRunOptionsArray());
	
	%>
      
</select>
</td>
<td><textarea name='dummy' rows=5 cols=37 readonly></textarea></td>
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
		<input type="radio" name="type" value="png" checked>PNG
		<input type="radio" name="type" value="jpg"        >JPG
		<input type="radio" name="type" value="eps"        >EPS
	      </td>
	      <td align="center"><input type="checkbox" name="allonone" value=1>&nbsp;Yes</td>
	    </tr>
	</table>
         
         
         
      <input type=SUBMIT value="Plot">&nbsp;&nbsp;
      <input type="button" value="Previous Results" 
        onclick="javascript:previousResults=popWindow('results/','previousResults',500,600);">
      <input type=RESET  value="Reset Values">&nbsp;&nbsp;
      <input type="button" value="Close Popups" onclick="javascript:closePopUps();">
    </form>

    </CENTER>

    <hr>
    <address><a href="mailto:karmgard.1@nd.edu">Bug the OGRE</a></address>
  </body>
</html>
