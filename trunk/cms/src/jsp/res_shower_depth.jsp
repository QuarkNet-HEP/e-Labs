
<%@ page import="java.util.*" %>
<HTML>
<HEAD>
<TITLE>Shower Depth Study Background</TITLE>

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
        <B>Shower Depth Study Background</b></FONT></td>
      </tr>
    </table>

<table width="800" border="0" align="center"  cellpadding="4"  cellspacing="4">
  <!--DWLayoutTable-->
  
  <tr>
    <td align="center" bgcolor="#99FFCC">
      <p align="left">In a shower depth study one would like to characterize how  deeply in the calorimeter a particle&rsquo;s energy is deposited.</p>
      <p align="left">The deposition of  energy in a calorimeter is often called a shower because its shape is similar  to that of a shower (i.e. begins narrowly and spreads out with increasing depth).</p>
      <p align="left"> In the calorimeter, particles pass first through the electromagnetic calorimeter  (Ecal) and then through the hadronic calorimeter (Hcal). Particle&rsquo;s that  deposit most of their energy in Ecal are said to have a lesser shower depth, and  those that deposit most of their energy in Hcal are said to have a greater  shower depth.</p>
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
              <div align="left">Review <a href="javascript:showRefLink('http://cmsinfo.cern.ch/outreach/CMSdocuments/DetectorDrawings/Slice/CMS_Slice.swf',900,500)">how particles interact with the calorimeter</a>.</div>

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
  </tr>
</table>

<hr>
</div>
</BODY>
</HTML>


