
<%@ page import="java.util.*" %>
<HTML>
<HEAD>
<TITLE>Beam Purity Study Background</TITLE>

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
        <B>Beam Purity Study Background</b></FONT></td>
      </tr>
    </table>

<table width="800" border="0" align="center"  cellpadding="4"  cellspacing="4">
  <!--DWLayoutTable-->
  

    <tr>
    <td align="center" bgcolor="#99FFCC">
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
                <div align="left">Review how to make <a href="javascript:reference('scatter plots')">scatter plots</a> from the  basics.</div>
                         </li>
              <li>
                <div align="left">Begin by  limiting your data sets to those that claim to be the same particles 
                  and only  ones  at the same energy.&nbsp; </div>
              </li>
            </ul>            </td>
          </tr>
</table>

<hr>
</div>
</BODY>
</HTML>


