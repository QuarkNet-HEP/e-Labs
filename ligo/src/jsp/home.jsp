<HTML>
<HEAD>
<TITLE>e-Lab Home</TITLE>
<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%
String project="ligo";
String action = "https://" + System.getProperty("host") + System.getProperty("sslport") + 
    "/elab/"+project+"/login.jsp";

if (session.getAttribute("login") == null ) {
%> 
 </head>
 <body>
 <div align="center">
<table bgcolor=000000 width="100%" border=0 cellpadding=0 cellspacing=0>
    <tr bgcolor=000000>
            <td rowspan="2" bgcolor=000000>
                <img src="graphics/ligo_logo.gif" width=94 height=68 border=0>
            </td>
        <td bgcolor=000000 align="left">
            <font color=FFFFFF face=arial size=+3>LIGO e-Lab</font>
        </td>
     </tr>
  </table></div>



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
<TABLE WIDTH=784 BGCOLOR=FFFFFF>
    <TR><TD>
    <TABLE  WIDTH=784 CELLPADDING=4>
       <TR>
           <TD BGCOLOR=FF6600>
           <FONT FACE=ARIAL SIZE=+1><B>
Join a national collaboration of high school students to study environmental data from LIGO, the Laser Interferometer Gravitational-wave Observatory</B></font>
           </TD>
       <TR>
    </TABLE>
    <P>
<P>

<TABLE WIDTH=784>
<tr><td width="100" valign="top" align="left" bgcolor="#000000"><IMG SRC="graphics/sidepanel.jpg" width="100" height="467"></td><TD width="20">&nbsp;</td><TD VALIGN=top><FONT FACE=ARIAL SIZE=-1><FONT SIZE=+1>What is LIGO?</FONT>
<hr color=orange height=6 width=300 align="left">
<P STYLE="margin-left: 10px">
LIGO is the Laser Interferometer Gravitational-wave Observatory.  LIGO facilities in Louisiana and in Washington State house 4-kilometer laser interferometers that listen for the faint ripples of space-time called gravitational waves.  LIGO seeks to detect gravitational waves from the collisions of black holes or neutron stars and from star explosions known as supernovae.  The California Institute of Technology (Caltech) and the Massachusetts Institute of Technology (MIT) operate LIGO for the National Science Foundation.</P>
</FONT>
 <FONT FACE=ARIAL SIZE=-1>
 <FONT SIZE=+1 >Why LIGO?</FONT>
<hr color=orange height=6 width=300 align="left">
<P STYLE="margin-left: 10px">LIGO measures thousands of data channels at each Observatory in addition to the gravitational wave channels.  The large interferometers are sensitive to a variety of environmental conditions, so LIGO measures and records seismic data, weather data, magnetic field data and a host of other effects.  The data in these environmental channels must be studied and characterized in order for LIGO scientists to operate the gravitational wave detectors as sensitively as possible. </P>
</FONT>

 <FONT FACE=ARIAL SIZE=-1> <FONT SIZE=+1 >How can you help?</FONT>
<hr color=orange height=6 width=300 align="left">
<P STYLE="margin-left: 10px"> 
You can assist in the analysis of LIGO environmental data.  Build a study on seismic waves or on fluctuations in the earth's magnetic field.  Measure the effects of earthquakes.  Analyze the relationships between sunspot activity and magnetic field fluctuations in LIGO's sensors.  The possibilities are numerous, and there is plenty of data to go around!</P>
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
                            <td align="center" colspan=3><font face="arial" size="-1"><br>To explore our website,<BR><a href="login.jsp?prevPage=/<%=project%>/home.jsp&login=Login&user=ligoguest&pass=guest&project=<%=project%>">log in as guest</a>.</font>
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
