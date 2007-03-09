<%@ page import="java.util.*" %>
<%@ include file="common.jsp" %>

<HTML>
<HEAD>
<TITLE>Cosmics Study Guide (text version)</TITLE>
<%@ include file="include/javascript.jsp" %>

<!-- include css style file -->
<%@ include file="include/style.css" %>

<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Library";
%>
<%@ include file="include/navbar_common.jsp" %>
<div align="center">
<%
if (groupName.startsWith("pd_")||groupName.startsWith("PD_")) {
%>
<%@ include file="include/milestones_profdev.jsp" %>    
<%
} else {
%>
<%@ include file="include/milestones_student.jsp" %>
<%
}
%>




  <FONT FACE=ARIAL><a href="showReferences.jsp?t=glossary&f=peruse">Glossary</a> - <a href="showReferences.jsp?t=reference&f=peruse">All References for Study Guide</a><a href="showReferences.jsp?t=reference&f=peruse"> <IMG SRC="graphics/ref.gif" border="0"></A>
    </FONT>
</div>
<hr>
</CENTER>
</BODY>
</HTML>
