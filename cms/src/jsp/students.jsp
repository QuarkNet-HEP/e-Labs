<%@ include file="common.jsp" %>
<HTML>
<HEAD>
<TITLE>Students in e-Lab</TITLE>

<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Library";
%>
<%@ include file="include/navbar_common.jsp" %>

<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>
<div align="center"
<P>    
<TABLE WIDTH=723 CELLPADDING=4>
    <TR><TD BGCOLOR=99cccc>
<FONT SIZE=+1 FACE=ARIAL><B>Collaborate with other students. Search for studies like yours.</B></FONT>
</TD></TR>
</TABLE>
<%
    if (user.equals("guest")) {
        out.write("<font size=3 color=\"red\">To ensure the privacy of our users, guests may not access this page. " +
            " Please <a href=\"login.jsp\">log in</a> as a non-guest to access this page.</font>");
        return;
    }
%>
<TABLE WIDTH=723 CELLPADDING=4>
<TR><TD VALIGN=TOP>
<FONT FACE=ARIAL SIZE=-1>
<table cellpadding="10" cellspacing="0" border="1" align="center">
    <tr>
        <td align="center"><font size=-1><b><u>Teacher</u></b></font></td>
        <td align="center"><font size=-1><b><u>School</u></b></font></td>
        <td align="center"><font size=-1><b><u>Town</u></b></font></td>
        <td align="center"><font size=-1><b><u>State</u></b></font></td>
        <td align="center"><font size=-1><b><u>Groups</u></b></font></td>
    </tr>
<%
 // Added by LQ, July 27, 2006 to support multiple e-Labs; you only want to show research groups for this e-Lab
 
     rs = s.executeQuery(
            "SELECT id as projectid from project where name='"+elabName+"';");
     int projectId=1;  // default to Cosmic
     if (rs.next()) {
         
           projectId = rs.getInt("projectid");}
 
 //    rs = s.executeQuery(
//            "SELECT teacher.name as tname, teacher.email as temail, " + 
//            "research_group.name as rgname, research_group.userarea as rguserarea " + 
//            "FROM teacher, research_group " +
//            "WHERE research_group.teacher_id = teacher.id ORDER BY tname ASC");

            
 
 rs = s.executeQuery(
            "SELECT distinct teacher.name as tname, teacher.email as temail, " + 
            "research_group.name as rgname, research_group.userarea as rguserarea " + 
            "FROM teacher, research_group " +
            "WHERE research_group.teacher_id = teacher.id " +
            "AND research_group.id in "+
            "(Select distinct research_group_id from research_group_project where " +
            " research_group_project.project_id ='" + projectId+ "') ORDER BY tname ASC;");
            
    String lastTName = "";
    boolean isStart = true;
    while (rs.next()) {
        if (!rs.getString("tname").equals(lastTName)) {
            if (!isStart) {
                out.write("</font></td></tr>");
            }
            out.write("<tr>");
            out.write("<td align=\"center\"><font size=-1><a href=\"mailto:" + 
                    rs.getString("temail").replaceAll("@", " <-at-> ").replaceAll("\\.", "  d.o.t  ") + 
                    "\">" + rs.getString("tname") + "</a></font></td>");
            if (rs.getString("rguserarea") != null && !rs.getString("rguserarea").equals("")) {
                String[] brokenSchema = rs.getString("rguserarea").split("/");
                if (brokenSchema != null) {
                    out.write("<td align=\"center\"><font size=-1>" + brokenSchema[3].replaceAll("_", " ") + "</font></td>");
                    out.write("<td align=\"center\"><font size=-1>" + brokenSchema[2].replaceAll("_", " ") + "</font></td>");
                    out.write("<td align=\"center\"><font size=-1>" + brokenSchema[1].replaceAll("_", " ") + "</font></td>");
                }
            }
            out.write("<td align=\"center\"><font size=-2>" + rs.getString("rgname") + "<br>");
        }
        else {
            out.write(rs.getString("rgname") + "<br>");
        }
        lastTName = rs.getString("tname");
        isStart = false;
    }
   rs.close();
   s.close();
   conn.close();
%>
</table>
</FONT>
</TD></TR>
</TABLE>
<hr>
</div>

</BODY>
</HTML>


