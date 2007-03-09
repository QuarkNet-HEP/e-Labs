<HTML>
<HEAD>
<TITLE>Student Intro Web Features</TITLE>
<!-- include css style file -->
<!-- include css style file -->
<%@ include file="include/style.css" %>
<%@ include file="include/jdbc_userdb.jsp" %>

<!-- header/navigation -->
 <div align="center">


<table width="819" style='align:center;position:varible; background-image: 
     url("graphics/cms_poster_horizontal_final.jpg"); background-repeat: no-repeat; border: 
       2 ' cellpadding=0 cellspacing=0 border=0>
 <tr height="150">
        <td valign="top" align="right"><%
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
                    out.write("<font color=red>Unable to update first time status.  Please contact Quarknet administrator.</font>");
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

  <table border="0" cellpadding="0" width="784">
    <tr>
      <td><table border="0" cellpadding="4" width="800">
          
          <tr>
            <td class="home_header">Join a national collaboration of high school students to study CMS test beam data.</td>
          </tr>
          
        </table>
        <P>
        <P>
        <table border="0" cellpadding="0" width="800">
          <tr>
            <td width="100" valign="top" bgcolor="black"><p> <img width="100" height="448"
    src="graphics/collision.gif"> </p></td>
            <td width="20">&nbsp;</td>
            
            <td valign="top">
            <FONT FACE=ARIAL Size=-1>
            <FONT SIZE=+1 >
            How to
                use the website. What you'll find on the next pages.</FONT>
       
              <hr size="2" width="350" style='width:262.5pt' noshade="noshade" color="orange" align="left">
          
              
               <P STYLE="margin-left: 10px"> 
             
              <b>Log in/Log out:</b>Check the upper right hand corner to see the current status. 


          <P STYLE="margin-left: 10px">    
          <B>Getting Around:</b> Use the navigation bar. <img
    src="graphics/navigation_bar.jpg">
           
            <P STYLE="margin-left: 20px">
           <a href="site-map-anno.jsp" target="map">Navigation
                Overview</a>
                
           <P STYLE="margin-left: 10px">     
           <B>Special icons and links:</b> Click on these.
    
     <P STYLE="margin-left: 20px">
              <img 
    src="graphics/question.gif"> and links in the text for explanations of terms in the
                glossary and variables in the analyses. 
                
                <P STYLE="margin-left: 20px">
 <IMG SRC="graphics/Tright.gif"> and <IMG SRC="graphics/Tdown.gif"> to show and hide analysis controls.

            <P STYLE="margin-left: 20px"> 
            <b>
            Popup Windows:</b> Be sure that you are not blocking popup windows in your browser. 
            <P STYLE="margin-left: 20px">

              <b>Resources:</b> Explore tutorials, online resources, slideshows and study notes.
<P STYLE="margin-left: 20px">
              <b>Study Guide - A List of Milestones:</b> Concepts you need to know. Skills you need to use. Tasks you need to
                accomplish. 
             <P STYLE="margin-left: 20px">   
             To access resources associated with milestones, click 
   on  <img border="0" width="19" height="13"
    src="graphcs/ref.gif">. 
    
               <P STYLE="margin-left: 20px"> 
               
               <TABLE>
<TR><TD><FONT FACE=ARIAL SIZE=-1>For review, go through the milestones in The Basics.</FONT></TD></TR>
<TR><TD><FONT FACE=ARIAL SIZE=-1>Work your way through the list of milestones in the Study Guide.</FONT></TD></TR>
</TABLE>
 <P STYLE="margin-left: 20px"> 
<B>Log Book:</b> Check the upper right hand corner to get to your logbook. Click on these. 

 <P STYLE="margin-left: 20px"> 
<img border="0" width="24" height="22"
    src="graphics/logbook_pencil.gif" v:shapes="_x0000_i1042" /> <span
  and &quot;<b>Log it!</b> to</span> 
  
  add
                notes to your log book related to the milestones<br />
                <img 
    src="graphics/logbook_view_comments_small.gif"> to access
                teacher comments in your logbook.
                
                 </span></p></td>
            <td width="110" valign="top"><div align="center"><a
    href="milestones_map.jsp"><img 
    src="graphics/lets_go.gif"></a>
    </div></td>
          </tr>
        </table>
        <div align="center" style='text-align:center'>
          <hr size="2" width="100%" align="center" />
        </div></td>
    </tr>
  </table>
</div>
</body>
<%
if (s != null)
    s.close();
if (conn != null)
    conn.close();
%>
</html>
