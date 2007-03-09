<%@ page import="java.util.*" %>
<HTML>
<HEAD>
<TITLE>Cosmics Site Index</TITLE>
<!-- include css style file -->
<%@ include file="include/style.css" %>
<style type="text/css">
<!--
.style12 {font-size: 12px}
.style2 {font-size: 16px}
.style17 {font-family: Arial}
.style20 {font-size: 10pt}
.style22 {font-size: 9.5px; font-family: Arial, Helvetica, sans-serif;}
.style33 {font-size: 9.5px; font-family: Arial, Helvetica, sans-serif}
.style34 {font-family: Arial; font-size: 12px; }
-->
</style>

<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Site Index";
%>
<%@ include file="include/navbar_common.jsp" %>
<table width="820" border="0" celpadding=4 align="center" bgcolor="#ff3300">
  <tr>
    <td><b><span style="FONT-SIZE: 12pt; COLOR: black; FONT-FAMILY: Arial">Lost? 
      You can go to any of the pages on this site from this 
      list.</span></b></td>
  </tr>
</table>
<P>
<div align="center">
  <table width="800" border="0" align="center" cellpadding="4" cellspacing="0">
    <tbody>
      <tr>
        <td width="126" valign="top" class="style33"><b><a 
      href="home.jsp">Home</a></b></td>
        <td width="212" valign="top" class="style33"><b><a href="library.jsp">Library</a></b></td>
        <td width="155" valign="top" class="style33"><b><a 
      href="search.jsp" class="style33">Data</a></b></td>
        <td width="147" valign="top" class="style33"><b><a 
      href="poster.jsp" class="style33">Posters</a></b></td>
        <td width="139" valign="top" class="style33"><b><a 
      href="rubric.html" class="style33">Assessment</a></b></td>
      </tr>
      <tr>
        <td width="126" valign="top" class="style22"><a href="first.jsp">The Big 
            Picture</a><BR>
<a href="first_web.jsp">The 
            Website</a></td>
            
        <td width="212" valign="top" class="style22"><a href="research_basics.jsp">The Basics</a><BR>
<a href="milestones_map.jsp">Study Guide (Milestones)</a>
<br>
&nbsp;&nbsp;<a href="showReferences.jsp?t=reference&f=peruse">View Resources for Study Guide</A><br>
&nbsp;&nbsp;<a href="showReferences.jsp?t=glossary&f=peruse">View Glossary</a><BR>
 
<a href="resources.jsp">Resources</a><br>
Online Links<br>
&nbsp;&nbsp;Tutorials<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="ogre_tutorial_index.htm">Ogre Tutorial</a><BR>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="http://www-root.fnal.gov/root/">Root Tutoria</a><br>
&nbsp;&nbsp;Notes<BR>
&nbsp;&nbsp;Contacts<br>
&nbsp;&nbsp;Slide Shows<BR>
          
<a href="first.jsp">Big Picture</a><BR>

<a href="site-map-anno.jsp">CMS Overview</a><BR>
<a href="http://cmsinfo.cern.ch/Welcome.html">CMS Test Beam</a><BR>
<a href="first_web.jsp">Site Help</a><BR>
<a href="FAQ.jsp">FAQ</a></td>
        
        
        <td width="155" valign="top" class="style22">
         <a href="search.jsp">Test Beam Analysis</a><BR>
         &nbsp;&nbsp;<a href="ogre-base.jsp?analysis=shower_depth">Shower Depth
          </a><BR>
         &nbsp;&nbsp;<a href="ogre-base.jsp?analysis=shower_depth?analysis=lateral_size">Lateral Size</a><BR>
         
&nbsp;&nbsp;<a href="ogre-base.jsp?analysis=beam_purity">Beam Purity</a>
<br>
&nbsp;&nbsp;<a href="ogre-base.jsp?analysis=resolution">Resolution
          </a><BR>
          &nbsp;&nbsp;<a href="http://www-root.fnal.gov/root/">Root Tutorial</a><BR>

         <a href="search.jsp">Management
            </a><BR>
            &nbsp;&nbsp;View Files and Posters<BR>
          &nbsp;&nbsp;Delete Files and Posters</td>
<td width="147" valign="top" class="style22">
<a href="makePoster.jsp">New Poster</a><BR>
<a href="editPosters.jsp">Edit Poster</a><BR>
<a href="search.jsp?t=poster&f=view">View Posters</a><BR>
<a href="search.jsp?t=poster&f=delete">Delete Posters</a><BR>
<a href="search.jsp?t=plot&f=view&q=type='plot'+AND+project='cms'">View Plots</a><BR>
<a href="uploadImage.jsp">Upload Image </a></td>

<td width="139" valign="top" class="style22">&nbsp;</td>
      </tr>
    </tbody>
  </table>
</div>
<hr />
</body>
</html>
