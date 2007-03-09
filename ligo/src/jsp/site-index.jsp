<%@ page import="java.util.*" %>
<HTML>
<HEAD>
<TITLE>Cosmics Site Index</TITLE>
<!-- include css style file -->
<%@ include file="include/style.css" %>
<style>
<!--
.indent1 {margin-left: 0px;font-size: 10 pt;font-weight: bold}
.indent2 {margin-left: 0px;font-size: 10 pt}
.indent3 {margin-left: 10px;font-size: 10 pt}
.indent4 {margin-left: 20px;font-size: 10 pt}
-->
</style>

<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Site Index";
%>
<%@ include file="include/navbar_common.jsp" %>
<center>
<TABLE WIDTH=723>
<TR><TD>
<TABLE WIDTH=723 CELLPADDING=4>
<TR><TD WIDTH=723 BGCOLOR=FF3300 VALIGN=TOP align="left">
<FONT SIZE=+1 FACE=ARIAL COLOR=000000><B>Lost? You can go to any of the pages on this site from this list.</B></FONT>
</TD></TR>
</TABLE>
<center>
<FONT face=arial>
<TABLE WIDTH=723 CELLPADDING=4>
<TR><TD>
<SPAN class="indent1"><A HREF="home.jsp" >Home</A></SPAN><BR>
</TD><TD>
<SPAN class="indent1"><A HREF="library.jsp" >Library</A></SPAN><BR>
</TD>
<TD>
<SPAN class="indent1"><A HREF="search.jsp" >Data</A></SPAN><BR>
</TD><TD>
<SPAN class="indent1"><A HREF="poster.jsp" >Posters</A></SPAN><BR>
</TD><TD>
<SPAN class="indent1"><A HREF="rubric.html" >Assessment</A></SPAN><BR>
</TD></TR>

<TR><TD VALIGN=TOP>
<SPAN class="indent2"><A HREF="first.jsp" >The Big Picture</A></SPAN><BR>
<SPAN class="indent2"><A HREF="first_web.jsp" >The Website</A></SPAN><BR>

</TD><TD VALIGN=TOP>
<SPAN class="indent2"><A HREF="milestones_map.jsp" >Study Guide</A> and <A HREF="milestones.jsp"><B>text version</B></A></SPAN><BR>
<SPAN class="indent3"><a href="showReferences.jsp?t=reference&f=peruse">View Resources for Study Guide</a><BR>
<SPAN class="indent3"><a href="showReferences.jsp?t=glossary&f=peruse">View Glossary</a></BR>
<SPAN class="indent2"><A HREF="resources.jsp" >Resources</A></SPAN><BR>
<SPAN class="indent2">Online Links</A></SPAN><BR>
<SPAN class="indent3">Contacts</A></SPAN><BR>
<SPAN class="indent4"><A HREF="students.jsp" >Students</A></SPAN><BR>
<SPAN class="indent3">Tutorials</SPAN><BR>
<SPAN class="indent3">Animations</SPAN><BR>
</TD><TD VALIGN=TOP>
<SPAN class="indent2"><B>Analysis</B></SPAN><BR>
<SPAN class="indent3"><A HREF="http://tekoa.ligo-wa.caltech.edu/tla/" >Ligo Analysis Tool</A></SPAN><BR>
<SPAN class="indent2"><B>View</B></SPAN><BR>
<SPAN class="indent3"><A HREF="search.jsp?t=plot&f=view" >Plots</A></SPAN><BR>
<SPAN class="indent3"><A HREF="search.jsp?t=poster&f=view" >Posters</A></SPAN><BR>
<SPAN class="indent2"><B>Delete</B></SPAN><BR>
<SPAN class="indent3"><A HREF="search.jsp?t=plot&f=delete" >Plots</A></SPAN><BR>
<SPAN class="indent3"><A HREF="search.jsp?t=poster&f=delete" >Posters</A></SPAN><BR>
<SPAN class="indent2"><A HREF="search.jsp?t=plot&f=view">View My Plots</A></SPAN>
</TD><TD VALIGN=TOP>
<SPAN class="indent2"><A HREF="makePoster.jsp" >New Poster</A></SPAN><BR>
<SPAN class="indent2"><A HREF="editPosters.jsp" >Edit Posters</A></SPAN><BR>
<SPAN class="indent2"><A HREF="search.jsp?t=poster&f=view" >View Posters</A></SPAN><BR>
<SPAN class="indent2"><A HREF="search.jsp?t=poster&f=delete" >Delete Posters</A></SPAN><BR>
<%        // No better way...we parse...userArea...sad...
        String groupName2 = null;
        String userArea2 = (String) session.getAttribute("userArea");
        String eLab2 = (String) session.getAttribute("appName");
        if (userArea2 != null){
            String[] sp2 = userArea2.split("/");
            groupName2 = sp2[5];
            String query="type='plot'+AND+project='"+eLab2+"'+AND+group+CONTAINS+'"+groupName2+"'";
            %>
            
<SPAN class="indent2"><A HREF="search.jsp?t=plot&f=view&q=<%=query%>" >View My Plots</A></SPAN><BR>
<%

        }
        else
        {
        %>
<SPAN class="indent2"><A HREF="search.jsp?t=plot&f=view">View My Plots</A></SPAN><BR>
        <%
        }
        %>
<TD VALIGN=TOP>
</TD>
</TR>
</TABLE>

</font></TD></TR>
</TABLE>
<hr>
</CENTER>
</CENTER>
</BODY>
</HTML>
