<%@ page import="java.util.*" %>
<HTML>
<HEAD>
<TITLE>Cosmics Site Overview</TITLE>
<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%

// display set to "static" allows showing a site overview without a real menu
String display = request.getParameter("display");
if(display != null && display.equals("static")){
%>
<table width="100%" bgcolor="black" border="0"><tr><td><img src="graphics/sample_navbar.gif"></td></tr></table>
<%
}
    else
    {
     String headerType = "Site Index";
%>
<%@ include file="include/navbar_common.jsp" %>
<%
}
%>


<TABLE WIDTH=723>
<TR><TD>
<TABLE WIDTH=723 CELLPADDING=4>
<TR><TD WIDTH=723 BGCOLOR=FF3300 VALIGN=TOP align="left">
<FONT SIZE=+1 FACE=ARIAL COLOR=000000><B>Find out what you can do under each tab.</B></FONT>
</TD></TR>
</TABLE>
<TABLE WIDTH=800>
<TR><TD VALIGN=TOP>

<TABLE  CELLPADDING=0 CELLSPACING=0 BGCOLOR=FFB27F VALIGN=TOP>
<TR><TD WIDTH=388>
<A HREF="home.jsp"><IMG SRC="graphics/home.gif" border="0"></A>

<FONT FACE=ARIAL size=-1>
<P STYLE="margin-left: 10px">
<B>Homepage</B>
<P>
<LI STYLE="margin-left: 10px">Research topic.
<P>


</TD></TR>
</TABLE>
<P>
<TABLE CELLPADDING=0 CELLSPACING=0 BGCOLOR=C782BC VALIGN=TOP>
<TR><TD WIDTH=388>
<a href="upload.jsp" border=0><IMG SRC="graphics/upload.gif" border="0"></A>


<FONT FACE=ARIAL SIZE=-1>
<P STYLE="margin-left: 10px">
<B>Upload</B></P>
<P>
<LI STYLE="margin-left: 10px">Data
<P>
<LI STYLE="margin-left: 10px">Geometry
<P>
</FONT>
</TD></TR>
</TABLE>

<P>
<TABLE CELLPADDING=0 CELLSPACING=0 BGCOLOR=7FB299 VALIGN=TOP>

<TR><TD WIDTH=388>
<a href="poster.jsp" border=0><IMG SRC="graphics/posters.gif"  border="0"></A>
<FONT FACE=ARIAL SIZE=-1>
<P STYLE="margin-left: 10px">
<B>Share Your Reseach</B></P>
<P>
<LI STYLE="margin-left: 10px">Create a Poster - Post results including graphs, notes, calculations.
<P>
<LI STYLE="margin-left: 10px">Edit a Poster
<P>
<LI STYLE="margin-left: 10px">View Posters - Review the work of others.
<P>
<LI STYLE="margin-left: 10px"> Search for Studies - Participate in a scientific dialog.
<P>

</FONT>
</TD></TR>
</TABLE>
<P>



</TD><TD WIDTH=8>
&nbsp;
</TD><TD VALIGN=TOP>

<TABLE  CELLPADDING=0 CELLSPACING=0 BGCOLOR=99cccc VALIGN=TOP>


<TR><TD WIDTH=388>
<a href="resources.jsp" border=0><IMG SRC="graphics/resources.gif" border="0"></A>
<FONT FACE=ARIAL size=-1>
<P STYLE="margin-left: 10px">
<B>Look for Links</B></P>
<P>
<LI STYLE="margin-left: 10px">Online resources -  If you find a really good resource not listed, let us know.
<P>
<LI STYLE="margin-left: 10px">Physicists -  Contacts at QuarkNet</LI>
<P>
<LI STYLE="margin-left: 10px">Student Research Groups - Other studies in the field</LI>
<P>
<LI STYLE="margin-left: 10px">Tutorials - Practice new skills</LI>
<P> 
<LI STYLE="margin-left: 10px">Animations - How the comsic ray project works</LI>
<P>  
</TD></TR>
</TABLE>
<P>
<TABLE CELLPADDING=0 CELLSPACING=0 BGCOLOR=99CCff VALIGN=TOP>
<TR><TD WIDTH=388>
<a href="search.jsp" border=0><IMG SRC="graphics/data.gif"  border="0"></A>


<FONT FACE=ARIAL SIZE=-1>
<P STYLE="margin-left: 10px">
<B>Analyze and Manage Data</B></P>
<P>
<LI STYLE="margin-left: 10px">Analysis - Physics studies.
<P>
<LI STYLE="margin-left: 10px"> Management - View and delete files.</LI>
<P>
</FONT>
</TD></TR>
</TABLE>

<P>
<TABLE CELLPADDING=0 CELLSPACING=0 BGCOLOR=FFE57F VALIGN=TOP>

<TR><TD WIDTH=388>
<a href="rubric.html" border=0><IMG SRC="graphics/assess.gif"  border="0"></A>
<FONT FACE=ARIAL SIZE=-1>
<P STYLE="margin-left: 10px">
<B>Assess your work</B></P>
<P>
<LI STYLE="margin-left: 10px">Rubric

<P>

</FONT>
</TD></TR>
</TABLE>
</TD></TR>
</TABLE>
</TD></TR>
<% if(display != null && display.equals("static")){
%>
  <tr><td align="center"><A HREF="javascript:window.close();"><FONT SIZE=-1>Close Window and Go Back to Getting Started Page</FONT></A></td></tr></FONT></td></tr>
<% 
}
%>


</TABLE>

</font></TD></TR>
</TABLE>
<hr>
</CENTER>
</BODY>
</HTML>
