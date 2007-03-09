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
<%
out.write("Research group is: "+groupName + groupName.startsWith("pd_") + groupName.startsWith("PD_") );
if (groupName.startsWith("pd_")||groupName.startsWith("PD_")) {
out.write("Professional dev<BR>");
%>
<%@ include file="include/milestones_profdev.jsp" %>    
<%
} else {
%>
<%@ include file="include/milestones_student.jsp" %>
<%
}
%>




  <FONT FACE=ARIAL><a href="showReferences.jsp?t=glossary&f=peruse">Glossary</a> - <a href="showReferences.jsp?t=reference&f=peruse">All Resources for Study Guide</a><a href="showReferences.jsp?t=reference&f=peruse"> <IMG SRC="graphics/ref.gif" border="0"></A>
    </FONT>

<hr>
</CENTER>
</BODY>
</HTML>
