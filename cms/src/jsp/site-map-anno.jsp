<%@ page import="java.util.*" %>
<HTML>
<HEAD>
<TITLE>Cosmics Site Overview</TITLE>
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

// display set to "static" allows showing a site overview without a real menu
String headerType = "Site Index";
 String display = request.getParameter("display");
if(display != null && display.equals("static")){
%>
<table width="100%" bgcolor="black" border="0"><tr><td><img src="graphics/sample_navbar.gif"></td></tr></table>
<%
}
    else
    {
%>
<%@ include file="include/navbar_common.jsp" %><%
}
%>

<div align="center">

 <table width=800 align="center">
    <tr><td>
    
    <table width-=800 cellpadding=4>
          <tr>
            <td width=792 WIDTH=723 BGCOLOR=FF3300 VALIGN=TOP align="left">
         
         <FONT SIZE=+1 FACE=ARIAL COLOR=000000><B>Find out what you can do under each tab.</b></FONT>
         </td></tr>
        </table>
        





        <table width="792" VALIGN=TOP>
          <tr><td valign="top">
          
          <table CELLPADDING=0 CELLSPACING=0 VALIGN=TOP bgcolor="#FFB27F">
<TR><td width=388>
<a href="home.htm"><img border="0" 
      src="graphics/home.gif"></a>
      
                 <FONT FACE=ARIAL SIZE=-1>
                  <P STYLE="margin-left: 10px">
                  <B>Homepage</B>
                    <P>
                   <LI STYLE="margin-left: 10px">Research topic
                    <P>
                    </FONT>
                    </td></tr>
                    </TABLE>
                
                <P>
                <TABLE CELLPADDING=0 CELLSPACING=0 VALIGN=TOP bgcolor="#99FFCC">
                   <tr><td><img border="0" 
      src="graphics/library.gif"></a>

<FONT FACE=ARIAL SIZE=-1>
<P STYLE="margin-left: 10px">
                  <B>Look for Links</B>
                  <P>
                   <LI STYLE="margin-left: 10px">
                   Online resources - If you find a really 
                      good resource not listed, let us know. </p>
                    <P>
                   <LI STYLE="margin-left: 10px">Physicists - Contacts at CMS </p>
                    <P>
                   <LI STYLE="margin-left: 10px">Student Research Groups - Other studies 
                      in the field </p>
                   <P>
                   <LI STYLE="margin-left: 10px">Tutorials - Practice new skills </p>
                   <P>
                   <LI STYLE="margin-left: 10px">Animations - How the CMS project works</p>
<P></td>
                </tr>
                </TABLE>
                <P>
                <TABLE CELLPADDING=0 CELLSPACING=0 VALIGN=TOP bgcolor="#FFE57F">
                
              <tr>
                  <td><a href="rubric.htm"><img border="0" 
      src="graphics/assessment.gif"></a>
      
                  <FONT FACE=ARIAL SIZE=-1>
                  <P STYLE="margin-left: 10px">
                  <b>Assess your work</b>
                   <P>
                   <LI STYLE="margin-left: 10px">
                   Rubric
                   <P></td>
                </tr>
              </table>
              </TD>
            
              
              
            <td width="12">&nbsp;</td>
            
            <td width="389" valign="top">
            
            <TABLE CELLPADDING=0 CELLSPACING=0 VALIGN=TOP  BGCOLOR=8BA4F5>
                <tr>
                  <td><a href="data.htm"><img border="0" 
      src="graphics/data.gif"></a>
     
      
                        <FONT FACE=ARIAL SIZE=-1>
                  <P STYLE="margin-left: 10px">
                  <b>Analyze and Manage Data</b>
                    <P>
                   <LI STYLE="margin-left: 10px">Physics studies </p>
                    <P>
                   <LI STYLE="margin-left: 10px">View and delete files </p>
                   
                    <P>
                   <LI STYLE="margin-left: 10px">Get data to analyze</p>
                    <P>
                   <LI STYLE="margin-left: 10px"> Practice skills </p>
                   <P></td>
                </tr>
                </TABLE>
                
                <P>
                
                 <TABLE CELLPADDING=0 CELLSPACING=0 VALIGN=TOP bgcolor="#CCFF66">
              <tr>
                  <td><a href="poster.htm"><img border="0" 
      src="graphics/posters.gif"></a>
      
                  <FONT FACE=ARIAL SIZE=-1>
                  <P STYLE="margin-left: 10px"><b>Share Your Research</b>
                    <P>
                   <LI STYLE="margin-left: 10px">Create a Poster - Post results including 
                      graphs, notes, calculations </p>
                    <P>
                   <LI STYLE="margin-left: 10px">Edit a Poster 
                   <P>
                   <LI STYLE="margin-left: 10px">View Posters - Review the work of others <P>
                   <LI STYLE="margin-left: 10px">Search for Studies - Participate in  a scientific dialog
<P></td>
                </tr>
                <tr>
                  <td height="21">&nbsp;</td>
                </tr>
                
              </table></td>
            <td width="3" valign="top">&nbsp;</td>
          </tr>
        </table></td>
    </tr>
    
  </table>

<hr>
</div>
</BODY>
</HTML>
