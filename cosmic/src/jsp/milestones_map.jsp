<%@ page import="java.util.*" %>
<%@ include file="common.jsp" %>

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

<P>
<TABLE WIDTH=800 CELLPADDING=4>
<TR><TD BGCOLOR=99cccc>
<FONT FACE=ARIAL SIZE=+1><B>Getting started! Work as a team. Make sure each team member meets these milestones.</B></FONT>
</TD></TR>
</TABLE>
<P>
<TABLE WIDTH=794 CELLPADDING=4>
<TR><TD>
<table><tr><td colspan="2"><FONT FACE=ARIAL>Follow the workflow map below to guide your work. Click on the hotspots to get references for accomplishing your milestones.</FONT></td></tr>
<tr><td width="40"  valign="top"><IMG SRC="graphics/interaction_point.gif" WIDTH=33 HEIGHT=33 ALT=""></td><td><FONT FACE=ARIAL>These dots in your workflow indicate where  your  teacher monitors your
progress by commenting on the entries you make in your logbook related
to each milestone.  Be sure to read the comments!</FONT></td></tr></table>
</TD></TR>
</TABLE>
<P>
<%
if (groupName.startsWith("pd_")||groupName.startsWith("PD_")) {
%>
<%@ include file="include/milestones_map_profdev.jsp" %>    
<%
} else {
%>
<%@ include file="include/milestones_map_student.jsp" %>
<%
}
%>
<P>


</TD></TR>
</TABLE>

  <FONT FACE=ARIAL><a href="milestones.jsp">Milestones (text version)</a> - <a href="showReferences.jsp?t=glossary&f=peruse">Glossary</a> - <a href="showReferences.jsp?t=reference&f=peruse">All References for Study Guide</a><a href="showReferences.jsp?t=reference&f=peruse"> <IMG SRC="graphics/ref.gif" border="0"></A>
    </FONT>

<hr>
</CENTER>
</BODY>
</HTML>
