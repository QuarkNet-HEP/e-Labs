<%@ page import="java.util.*" %>
<%@ include file="common.jsp" %>

<HTML>
<HEAD>
<TITLE>Cosmics Study Guide</TITLE>
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
<P>
  <table cellpadding="4" width="800">
    <tbody>
      <tr>
        <td bgcolor="#ooff99"><font face="ARIAL" size="+1"><b>Getting started! Work as a team. Make sure each team member meets these milestones.</b></font> </td>
      </tr>
    </tbody>
  </table>
  </p>
  <table cellpadding="4" width="794">
    <tbody>
      <tr>
        <td><table>
            <tbody>
              <tr>
                <td colspan="2"><font face="ARIAL" size="-1">Follow the workflow map below to guide your work. Click on the hotspots to get references for accomplishing your milestones.</font></td>
              </tr>
              <tr>
                <td><img src="graphics/interaction_point.gif" alt="" height="33" width="33"></td>
                <td><font face="ARIAL"  size="-1">These dots in your workflow indicate where  your  teacher monitors your
                  progress by commenting on the entries you make in your logbook related
                  to each milestone.  Be sure to read the comments!</font></td>
              </tr>
            </tbody>
          </table>
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
          </td>
      </tr>
    </tbody>
  </table>
  </p>
  <p>
  <FONT FACE=ARIAL><a href="milestones.jsp">Milestones (text version)</a> - <a href="showReferences.jsp?t=glossary&f=peruse">Glossary</a> - <a href="showReferences.jsp?t=reference&f=peruse">All References for Study Guide</a><a href="showReferences.jsp?t=reference&f=peruse"> <IMG SRC="graphics/ref.gif" border="0"></A>
    </FONT>

<hr>
</DIV>
</BODY>
</HTML>
