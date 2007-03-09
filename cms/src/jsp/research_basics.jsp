<%@ page import="java.util.*" %>
<HTML>
<HEAD>
<TITLE>Cosmics Resources: Study Guide</TITLE>
<%@ include file="include/javascript.jsp" %>

<!-- include css style file -->
<%@ include file="include/style.css" %>

<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Library";
%>
<%@ include file="include/navbar_common.jsp" %>
<CENTER>
<P>
<TABLE WIDTH=794 CELLPADDING=4>
<TR><TD BGCOLOR=99FFCC>
<FONT FACE=ARIAL SIZE=+1><B>Review research skills you need for this project.</B></FONT>
</TD></TR>
</TABLE>
<P>
<TABLE WIDTH=794 CELLPADDING=4>
<TR><TD>
<FONT FACE=ARIAL SIZE=+1><b>Click on <IMG border="0" SRC="graphics/ref.gif"> for resources to help you meet each milestone below.</B></FONT>  
</TD></TR>
</TABLE>
<P>
<TABLE WIDTH=786>
<TR><TD VALIGN=TOP><TABLE  CELLPADDING=0 CELLSPACING=0 BGCOLOR=99FFCC VALIGN=TOP>
<TR><TD WIDTH=388><IMG border="0" SRC="graphics/research_basics.gif">

<FONT FACE=ARIAL size=-1>

<P STYLE="margin-left: 10px">

<I>Use these milestones if you need background on:</I>
<P STYLE="margin-left: 20px">
<IMG border="0" SRC="graphics/ref_dot.gif"> Simple Measurements. <A HREF="javascript:reference('simple measurement')"><IMG border="0" SRC="graphics/ref.gif" border="0"></A><br>
<IMG border="0" SRC="graphics/ref_dot.gif"> Simple Calculations. <A HREF="javascript:reference('simple calculations')"><IMG border="0" SRC="graphics/ref.gif" border="0"></A><br>
<IMG border="0" SRC="graphics/ref_dot.gif"> Simple Graphs. <A HREF="javascript:reference('simple graphs')"><IMG border="0" SRC="graphics/ref.gif" border="0"></A><br>
<IMG border="0" SRC="graphics/ref_dot.gif"> Scatter Plots. <A HREF="javascript:reference('scatter plots')"><IMG border="0" SRC="graphics/ref.gif" border="0"></A><br>
<IMG border="0" SRC="graphics/ref_dot.gif"> Research Questions. <A HREF="javascript:reference('research question')"><IMG border="0" SRC="graphics/ref.gif" border="0"></A><br>
<IMG border="0" SRC="graphics/ref_dot.gif"> Research Plans. <A HREF="javascript:reference('research plan')"><IMG border="0" SRC="graphics/ref.gif"></A><br>
<P>&nbsp;
</TD></TR>
</TABLE>

</TD>
</TR>
</TABLE>

  <FONT FACE=ARIAL><a href="showReferences.jsp?t=glossary&f=peruse">Glossary</a> - <a href="showReferences.jsp?t=reference&f=peruse">All Resources for Study Guide</a><a href="showReferences.jsp?t=reference&f=peruse"> <IMG SRC="graphics/ref.gif" border="0"></A> - <A HREF="showLogbook.jsp">Student Logbook <IMG SRC="graphics/logbook_small.gif" border="0"></A>
    </FONT>

<hr>
</CENTER>
</BODY>
</HTML>
