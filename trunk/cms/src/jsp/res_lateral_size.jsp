
<%@ page import="java.util.*" %>
<HTML>
<HEAD>
<TITLE>Lateral Size Study Background</TITLE>

<%@ include file="include/javascript.jsp" %>

<!-- include css style file -->
<%@ include file="include/style.css" %>

<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Library";
%>
<%@ include file="include/navbar_common.jsp" %>
<div align="center">    <table border="0" cellpadding="4" width="800" align=center>
      <tr>
        <td bgcolor="#00FF99">
        <FONT FACE=ARIAL SIZE=+1>
        <B>Lateral Size Study Background</b></FONT></td>
      </tr>
    </table>

<table width="800" border="0" align="center"  cellpadding="4"  cellspacing="4">
  <!--DWLayoutTable-->
  

    <tr>
    <td align="center" bgcolor="#99FFCC">
        <p align="left">In a lateral size study one would like to characterize the  lateral spread of a shower. By lateral we mean the plane perpendicular to the  particle&rsquo;s trajectory. The CMS test beam set-up only supports HCAL shower identification, since only one ECAL element was used.</p>
        <p align="left"> As a particle&rsquo;s shower develops with depth it at first  becomes broader, then it reaches shower maximum and then it becomes narrower.  One might imagine that the broadness of a shower might depend on the type of  beam (e.g. electron, muon or pion) and the energy of the beam (e.g. 30GeV,  100GeV or 300GeV). </p>
        <p align="left">Narrower showers will have a greater ratio of (1x1) to (3x3 and 5x5) HCAL energies; in broader showers, this ratio will be smaller.</p>
        <p align="left"> To simplify your study we suggest you begin by investigating  data sets that have a common particle identity and energy (e.g. either 50GeV  electrons or 100GeV pions). We also recommend you do the Shower Depth study  first if you have not yet done it.</p>
        <p align="left"><strong>Research Question: </strong>What is a lateral study? Why do showers spread out? What parameters effect a shower's shape? Are there any indicators a shower has occurred? </p>
        <table width="665" border="0" align="left">
          <tr>
            <th height="135" scope="col"><div align="center">
              <p><strong>Hints:</strong></p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
            </div></th>
            <th scope="col"><ul><li>
              <div align="left"><strong>Review <a href="javascript:openPopup('http://cmsinfo.cern.ch/outreach/CMSdocuments/DetectorDrawings/Slice/CMS_Slice.swf')">how particles interact with the CMS calorimeter</a> </strong></div>
            </li>
                <li>
                  <div align="left">What types of particles produce showers? Where do the showers occur (Ecal/Hcal)? What effect does a particle's energy have on the shape of the shower it produces? </div>
                </li>
                <li>
                  <div align="left">What does the ratio of (1x1) to (3x3 plus 5x5) HCAL energies tell us about showers?</div>
                </li>
                <li>
                  <div align="left">Begin by  limiting your data set to a single particle with a single energy. </div>
                </li>
                <li>
                  <div align="left">It would be helpful to have done the <a href="res_shower_depth.jsp">Shower Depth</a> study first.&nbsp;&nbsp;</div>
                </li>
            </ul>            </th>
          </tr>
</table>
</td></tr></table>

<hr>
</div>
</BODY>
</HTML>


