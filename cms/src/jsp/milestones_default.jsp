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
<div align="center">

<P>
<TABLE WIDTH=794 CELLPADDING=4>
<TR><TD BGCOLOR=99FFCC>
<FONT FACE=ARIAL SIZE=+1><B>Getting started! Work as a team. Make sure each team member meets these milestones.</B></FONT>
</TD></TR>
</TABLE>
<P>
<TABLE WIDTH=794 CELLPADDING=4>
<TR><TD>
<FONT FACE=ARIAL SIZE=+1><B>Click on <IMG border="0" SRC="graphics/ref.gif"> for references to help you meet each milestone.</B></FONT>  
</TD></TR>
</TABLE>
<P>
<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>
</div>
<div align="center">
    <table width="600"><tr><td align="left">

<%
String role = (String)session.getAttribute("role");
if (role.equals("teacher")) { 
    out.write("This page is only available to student research groups.");
    return;
    }
String query="";
String queryItems="";
String querySort="";
String queryWhere="";
String keyword_milestone="";
String keyword_text="";
String section_intro="";
String linksToEach="";
String reference_link;
String keyword_loop="";
String keyword_id="";
String newList="<UL><LI>";
String newInnerList="<UL>";
String typeConstraint=" AND keyword.type in ('SW','S')";
if (groupName.startsWith("pd_")||groupName.startsWith("PD_")) {typeConstraint=" AND keyword.type in ('SW','W')";}

   String keyword = request.getParameter("keyword");
   if (keyword==null) {keyword="";} // note - display all entries

    
     // get project ID
                //eLab defined in common.jsp
     String project_id="";
     query="select id from project where name=\'"+eLab+"\';";
     rs = s.executeQuery(query);
     if (rs.next()){
       project_id=rs.getString("id");}
      if (project_id.equals("")) {%> Problem with id for project <%=eLab%><BR><% return;}

//Get the milestones
     query="select id,keyword,milestone,section,section_id from keyword where keyword.project_id in (0,"+project_id+") " + typeConstraint + " order by section,section_id;";
     String current_section="";
     rs = s.executeQuery(query);
     while (rs.next()){
       keyword_id=rs.getString("id");
       keyword_loop=rs.getString("keyword");
       keyword_text=keyword_loop.replaceAll("_"," ");
       keyword_milestone=rs.getString("milestone");
       String this_section=(String)(rs.getString("section"));

      if (!keyword_loop.equals("general") && (!this_section.startsWith("A"))){
               if (!this_section.equals(current_section))
               {
                  String section_text="";
                  char this_section_char = this_section.charAt(0);
                   switch( this_section_char ) {
                   case 'B': section_text="A: Get Started";section_intro="<I>Prepares the team to design the investigation.</I>";break;
                   case 'C': section_text="B: Figure it Out";section_intro="<I>Prepares the team to analyze data.</I>";break;      
                   case 'D': section_text="C: Tell Others";section_intro="<I>Prepares the team to enter into scientific discourse with other researchers.</I>";break;    
                      }
                    linksToEach=linksToEach + newList + "<b>"+section_text+"</b><BR> " + section_intro + newInnerList;
                   current_section=this_section;
                   newList="</UL><P><LI>";
                 }

 
    
      
      
                 reference_link=" <A HREF=\"javascript:reference('"+  keyword_text +"')\"><IMG border=\"0\" SRC=\"graphics/ref.gif\"></A>";
                 linksToEach=linksToEach + "<LI>"+ keyword_milestone + reference_link +"</LI>";  }

      }
     
    linksToEach=linksToEach + "</UL></UL>";
        %>
    <%=linksToEach%>

</td></tr></table>
</div>
<HR>
<div align="center">


  <FONT FACE=ARIAL><A HREF="milestones_map.jsp">Milestones Map</A> - <a href="showReferences.jsp?t=glossary&f=peruse">Glossary</a> - <a href="showReferences.jsp?t=reference&f=peruse">All References for Study Guide</a><a href="showReferences.jsp?t=reference&f=peruse"> <IMG SRC="graphics/ref.gif" border="0"></A>
    </FONT>


</div>
</BODY>
<%
if (s != null)
    s.close();
if (conn != null)
    conn.close();
%>

</HTML>
