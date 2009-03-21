
<%@ page import="java.util.*" %>
<HTML>
<HEAD>
<TITLE>Detector Resolution Study Background</TITLE>

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
        <B>Detector Resolution Study Background</b></FONT></td>
      </tr>
    </table>

<table width="800" border="0" align="center"  cellpadding="4"  cellspacing="4">
  <!--DWLayoutTable-->
  

    <tr>
    <td align="center" bgcolor="#99FFCC">
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
            It would be helpful to have done a <a href="res_shower_depth.jsp">Shower Depth</a> study, a <a href="res_lateral_size.jsp">Lateral Size</a> study and a <a href="res_beam_purity.jsp">Beam Purity</a> study first. &nbsp;&nbsp; </li>
              </ul>
            </div></th>
          </tr>
        </table></td></tr>
</table>

<hr>
</div>
</BODY>
</HTML>


