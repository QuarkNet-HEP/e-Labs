<HTML>
<HEAD>
<TITLE>Quarknet Grid Home</TITLE>
<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%
String action = "http://" + System.getProperty("host") + System.getProperty("port") + 
    "/elab/cosmic/login.jsp";

if (session.getAttribute("login") == null ) {
%> 
<table bgcolor=000000 width="100%" border=0 cellpadding=0 cellspacing=0>
    <tr bgcolor=000000>
            <td rowspan="2" bgcolor=000000>
                <img src="graphics/blast.jpg" width=57 height=68 border=0>
            </td>
        <td bgcolor=000000 align="left">
            <font color=FFFFFF face=arial size=+3>Cosmic Ray e-Lab</font>
        </td>
     </tr>
  </table><%
}
else {
//be sure to set this before including the navbar
String headerType = "Home";%>
<%@ include file="include/navbar_common.jsp" %>
<%
}
%>

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
<tr><td width="100" valign="top" align="left" bgcolor="#000000"><IMG SRC="graphics/crop.jpg"></td><TD width="20">&nbsp;</td><TD VALIGN=top><FONT FACE=ARIAL SIZE=-1><FONT SIZE=+1>Why cosmic rays?</FONT>
<hr color=orange height=6 width=300 align="left">
<P STYLE="margin-left: 10px">
<B>Spending all your time in a shower?</B></P>
<P STYLE="margin-left: 10px">
When you're sleeping or sitting in class, cosmic rays shower the earth and everything on it.</P>
<P STYLE="margin-left: 20px">
<B>What are cosmic rays?</B></P>
<P STYLE="margin-left: 20px">
<B>Where do they come from?</B></P>
<P STYLE="margin-left: 20px">
<B>Where do they hit?</B></P>

<P STYLE="margin-left: 10px">
Some cosmic rays have so much energy that scientists are not sure where they come from. A number of reseach projects are looking at this question.</P>
</FONT>


 <FONT FACE=ARIAL SIZE=-1>
 <FONT SIZE=+1 >Who are we?</FONT>
<hr color=orange height=6 width=300 align="left">
<P STYLE="margin-left: 10px">We're a collaboration of high school students and teachers collecting and analyzing cosmic ray data to answer some of these questions. We're working with
computer scientists to provide cutting edge tools that use <b>grid techniques</b> to help you share data, graphs, and posters and collaborate with other students nationwide.</P>
</FONT>

 <FONT FACE=ARIAL SIZE=-1> <FONT SIZE=+1 >Who can join?</FONT>
<hr color=orange height=6 width=300 align="left">
<P STYLE="margin-left: 10px"><B>You</B>! 
Think about steps you'd take to investigate cosmic rays. How would you get started? 
What do you need to know? Can you collect and use data?</P>
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
                              <TD><INPUT size="16" type="password" name="pass" tabindex="2">
                              </TD></tr><tr>
                              <TD colspan="2" align="center"><INPUT type="submit" name="login" class="button2" value='Login' tabindex=\ "3">
                              </TD>
                           </TR>
                        <TR>
                            <td align="center" colspan=3><font face="arial" size="-1"><br>To explore our website,<BR><a href="login.jsp?prevPage=/cosmic/home.jsp&login=Login&user=guest&pass=guest">log in as guest</a>.</font>
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
