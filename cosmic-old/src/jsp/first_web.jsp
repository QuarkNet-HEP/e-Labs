<HTML>
<HEAD>
<TITLE>Quarknet Grid Student Intro 2</TITLE>
<!-- include css style file -->
<!-- include css style file -->
<%@ include file="include/style.css" %>
<%@ include file="common.jsp" %>
<%@ include file="include/jdbc_userdb.jsp" %>

<!-- header/navigation -->
<table bgcolor=000000 width="100%" border=0 cellpadding=0 cellspacing=0>
    <tr bgcolor=000000>
            <td rowspan="2" bgcolor=000000>
                <img src="graphics/blast.jpg" width=57 height=68 border=0>
            </td>
        <td bgcolor=000000 align="left">
            <font color=FFFFFF face=arial size=+3>Cosmic Ray e-Lab</font>
        </td>        <td valign="top" align="right">
        <td valign="top" align="right">
<%
            if (session.getAttribute("login") != null ) {
%>
                <font color=FFFFFF  face="arial">
                    Logged in as group: <a href="" class="log"><FONT color=#99CCFF>Research Group</FONT></a>
                    <img src="graphics/spacer.png" width="70" height="1" valign="top"><a href="first_web.jsp" class="log"><FONT color=#99CCFF>Logout</FONT></a>
                    <IMG SRC="graphics/spacer.png" width="10" height="2"><br>
<a href="first_web.jsp">
                    <FONT color=#99CCFF>My Logbook</FONT></a><IMG SRC="graphics/spacer.png" width="10" height="2">
                </font>

 <%
                // Update the first_time status in the database.
                try {
                    int rows = s.executeUpdate(
                        "UPDATE research_group SET first_time = false WHERE name='" + session.getAttribute("login") + "'");
                } catch (SQLException e) {
                    warn(out,"Unable to update first time status.  Please contact Quarknet administrator.");
                }
		    }
            //do not show the "Login" message in the navbar on the home page
		    else {
		    %>
                <font color=99CCFF size=-1>
                    <a class="log" href="first_web.jsp" >Login</a>
                </font><IMG SRC="graphics/spacer.png" width="10" height="2">
<%
		    }
%>
<BR><BR><font color=FFFFFF  face="arial">Logbook/Login/Logout inactive on this page.</FONT>
        </td>
    </tr>

     </tr>
  </table>

<P>
<center>
<TABLE WIDTH=784 BGCOLOR=FFFFFF>
    <TR><TD>
    <TABLE  WIDTH=784 CELLPADDING=4>
       <TR>
       <TR>
           <TD BGCOLOR=FF6600>
           <FONT FACE=ARIAL SIZE=+1><B>
Join a national collaboration of high school students to study cosmic rays. </B></font>
           </TD>
       <TR>
    </TABLE>
    <P>
<P>

<TABLE WIDTH=784>
<tr><td width="100" valign="top" align="left" bgcolor="#000000">
<IMG SRC="graphics/crop.jpg">
</td><TD width="20">&nbsp;</td>

<TD VALIGN=top>
<FONT FACE=ARIAL SIZE=-1>
<FONT SIZE=+1 >How to use the website. What you'll find on the next pages.</FONT>
<hr color=orange height=6 width=350 align="left">
<P STYLE="margin-left: 10px">
<B>Log in/Log out:</B> Check the upper right hand corner to see the current status.
<P STYLE="margin-left: 10px">
<B>Getting Around:</B> Use the navigation bar.
<IMG SRC="graphics/nav.jpg">
<P STYLE="margin-left: 20px">
<A target="map" HREF="site-map-anno.jsp?display=static">Navigation Overview</A>

<P STYLE="margin-left: 10px">
<B>Special icons and links:</B> Click on these. 
<P STYLE="margin-left: 20px">
 <IMG SRC="graphics/question.gif"> and links in the text for explanations of terms in the glossary and variables in the analyses.
<P STYLE="margin-left: 20px">
 <IMG SRC="graphics/Tright.gif"> and <IMG SRC="graphics/Tdown.gif"> to show and hide analysis controls.

<P STYLE="margin-left: 10px">
<B>Popup Windows:</b> Be sure that you are not blocking popup windows in your browser.

<P STYLE="margin-left: 10px">
<B>References:</b> Explore tutorials, online resources, animations and contacts.
<P STYLE="margin-left: 10px">
<B>Study Guide - A List of Milestones:</B> 
<P STYLE="margin-left: 20px">
Concepts you need to know. Skills you need to use. Tasks you need to accomplish.

<P STYLE="margin-left: 20px">
To access resources associated with milestones, click on <IMG SRC="graphics/ref.gif">.
<P STYLE="margin-left: 20px">
<TABLE>
<TR><TD><FONT FACE=ARIAL SIZE=-1>For review, go through the milestones in The Basics.</FONT></TD></TR>
<TR><TD><FONT FACE=ARIAL SIZE=-1>Work your way through the list of milestones in the Study Guide.</FONT></TD></TR>
</TABLE>

<P STYLE="margin-left: 10px">
<B>Log Book:</b> Check the upper right hand corner to get to your logbook. Click on these.
<P STYLE="margin-left: 20px"><IMG SRC="graphics/logbook_pencil.gif" align="middle" border="0"> and "<B>Log it!</B> to add notes to your log book related to the milestones<BR> 
<IMG SRC="graphics/logbook_view_comments_small.gif" align="middle" border="0"> to access teacher comments in your logbook.
</FONT>

</TD>
            
<td height="220" width="110" valign="top"><A HREF="milestones_map.jsp"><IMG border="0" SRC="graphics/lets_go.gif"></A></td>


</TR>
</TABLE>
<hr>
</CENTER>
