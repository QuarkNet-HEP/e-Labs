<HTML>
<HEAD>
<TITLE>e-Lab Home</TITLE>
<!-- include css style file -->
<%@ include file="include/style.css" %>
<%@ include file="include/login_url_base.jsp" %>
<!-- include file with name of the current eLab -->
<%@ include file="include/elab_name.jsp" %>
<!-- header/navigation -->
<%
String project="cms";
String action = loginURLBase + "/elab/" + project + "/login.jsp";

if (session.getAttribute("login") == null ) {
%> 
 </head>
 <body>
 <div align="center">
    <table border="0" cellpadding="0" width="827">
      <tr>
        <td bgcolor="#FFFFFFF"><img src="graphics/cms_poster_horizontal_final.jpg" width="819" height="132"></td></tr></table></div>



<%
}
else {
//be sure to set this before including the navbar
String headerType = "Home";
%>
<%@ include file="include/navbar_common.jsp" %>
<%
}
%>

<P>
<center>
<TABLE WIDTH=800 BGCOLOR=FFFFFF>
    <TR><TD>
    <TABLE  WIDTH=800 CELLPADDING=4>
       <TR>
           <TD class="home_header">
Join a national collaboration of high school students to study CMS test beam data.
           </TD>
       <TR>
    </TABLE>
    <P>
<P>
</table>

<TABLE WIDTH=800>
<tr><td width="100" valign="top" align="left" bgcolor="#000000"><img src="graphics/final_animation_small.gif" /></td><TD width="20">&nbsp;</td><TD VALIGN=top><FONT FACE=ARIAL SIZE=-1><FONT SIZE=+1>How small is small?</FONT>
<hr color=orange height=6 width=300 align="left">
<P STYLE="margin-left: 10px">
<B>How small is so small that we can
        get no smaller?</B></P>
      
        <P STYLE="margin-left: 10px">
<B>Why do objects have mass? </B></P>
<P STYLE="margin-left: 10px">
<B>How do scientists "see" particles much smaller than an   atom? </B></P>
        
<P STYLE="margin-left: 10px">

<B>Understand how a 12,000 ton detector &quot;sees&quot; electrons, muons and other particles. </B>
<P>


 <FONT FACE=ARIAL SIZE=-1>
 <FONT SIZE=+1 >Who are we?</FONT>
<hr color=orange height=6 width=300 align="left">
<P STYLE="margin-left: 10px">We're a collaboration of high school students and teachers analyzing data
        from the <I>Compact Muon Solenoid Collaboration,</I> CMS, experiment at CERN in Geneva, Switzerland to answer some of these questions. We're
        working with computer scientists to provide cutting edge tools that use <b>grid techniques</b> to help you share data, graphs, and posters and collaborate with other students nationwide.</P>
</FONT>

 <FONT FACE=ARIAL SIZE=-1> <FONT SIZE=+1 >Who can join?</FONT>
<hr color=orange height=6 width=300 align="left">
<P STYLE="margin-left: 10px"><B>You</B>! 
Think about steps you'd take to investigate particle collisions at the highest
        accelerator energies. How would you get started? What do you need to know?
        Can you analyze data?</P>
</FONT>
</FONT>

</TD>
            <% if (session.getAttribute("login") == null ) { %>

<td valign="top">
         <CENTER>
            <TABLE BORDER=0 WIDTH=200>
                <TR>
                    <TD align=center><FONT FACE=ARIAL><B>Log in</B></FONT> 
                        <br>
                        <FORM method="post" action="<%=action%>">
                        <TABLE border=0 cellpadding=2 cellspacing=0>
                            <TR>
                                <TD align=right><FONT color="black" size="-1" FACE=ARIAL>Username:                </FONT>
                               </TD>
                               <TD><input size="16" type="text" name="user" tabindex="1">
                               </TD></TR>
                           <TR>
                               <TD align=right>
                                   <FONT color="black" FACE=ARIAL size="-1">Password: </FONT>
                              </TD>
                              <TD><INPUT size="16" type="password" name="pass" tabindex="2"><INPUT type="hidden" name="project" value="<%=project%>">
                              </TD></tr><tr>
                              <TD colspan="2" align="center"><INPUT type="submit" name="login" class="button2" value='Login' tabindex=\ "3">
                              </TD>
                           </TR>
                        <TR>
                            <td align="center" colspan=3><font face="arial" size="-1"><br>To explore our website,<BR><a href="login.jsp?prevPage=/<%=project%>/home.jsp&login=Login&user=<%=elabGuestUser%>&pass=guest&project=<%=project%>">log in as guest</a>.</font>
                            </td>
                        </TR>
                           <tr><td align="center" colspan="2">
                           <table><tr><td><FONT FACE=ARIAL SIZE="-1"><br><b>Need a student login?</b><BR>Ask your teacher.</FONT></td></tr><tr><td><FONT FACE=ARIAL SIZE="-1"><br><b>Need a teacher login?</b><BR>Contact <A HREF="mailto:e-labs@fnal.gov?Subject=Please%20register%20me%20as%20an%20e-Labs%20teacher.&Body=Please%20complete%20each%20of%20the%20fields%20below%20and%20send%20this%20email%20to%20be%20registered%20as%20an%20e-Labs%20teacher.%20You%20will%20receive%20a%20response%20from%20the%20e-Labs%20team%20by%20the%20end%20of%20the%20business%20day.%0D%0DFirst%20Name:%0D%0DLast%20Name:%0D%0DCity:%0D%0DState:%0D%0DSchool:%0D">e-labs@fnal.gov</a>.</FONT></td></tr></table>
                        </TABLE>
                        </FORM>

                    </td>
                 </tr>

            </TABLE>


            </CENTER>
           <% }
else
{
%>
<td valign="top">
         <CENTER>
            <TABLE BORDER=0 WIDTH=200>
               <TR><TD align="center"><FONT FACE=ARIAL><B>Logout</b></FONT><br>
                  <FONT FACE=ARIAL SIZE="-1">If you are not
                  <B><%= session.getAttribute("login") %></B>,</FONT>
                   <BR><FORM method="post" action="logout.jsp">
                   <INPUT type="submit" name="logout" class="button2" value="Logout"></FONT>
                 </FORM></td></tr></table>
<%



}           
            %>
</td>




</TR>
</TABLE>
<hr>
</CENTER>
</body>
</html>