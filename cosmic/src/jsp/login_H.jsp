<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page buffer="64kb" %>

<%@ page import="gov.fnal.elab.db.*"%>
<%@ include file="include/style.css" %>

<%!
public static void warn(JspWriter out, String error){
    try{
        out.write("<font color=red><b>" + error + "</b></font>");
    }
    catch(IOException e){
        ;
    }
}
%>

<%
String prevPage = request.getParameter("prevPage");
boolean incorrectLogin = false;
if(prevPage == null){    //the page the user was previously requesting
    prevPage = "/cosmic/home.jsp";     //default redirect
}
String user = request.getParameter("user");
String pass = request.getParameter("pass");
if (user != null && pass != null){
    //hibernate lookup of username/password
    List rs = DBObject.getAll("Login", 0, 10000);
    Login me = null;
    for (Iterator i = rs.iterator(); i.hasNext();)
    {
        Login login = (Login) i.next();
        if (user.equals(login.getUsername()))
            if (pass.equals(login.getPassword()))
                me = login;
    }
    
   if(me == null){
        incorrectLogin = true;
    }
    else{
            //set some statistics
            Use use = new Use();
            use.setLogin(me);
            use.save();

            //set attributes
            session.setAttribute("login", me);
            
            // I finally found the solution to the double login problem, and it's this
            // one line.  :)  Please don't remove.
            response.addCookie(new Cookie("JSESSIONID", session.getId()));

            if (me instanceof Manager) {
                if (prevPage.endsWith("home.jsp")) {
                    response.sendRedirect(
                            response.encodeRedirectURL(
                                "http://" + System.getProperty("host") + 
                                System.getProperty("port") + "/elab/cosmic/teacher.jsp"));
                } else {
                    response.sendRedirect(
                            response.encodeRedirectURL(
                                "http://" + System.getProperty("host") + 
                                System.getProperty("port") + "/elab"+prevPage));
                }
            } else if (me.getUsername().equals("guest")) {
                response.sendRedirect(
                        response.encodeRedirectURL(
                            "http://" + System.getProperty("host") + 
                            System.getProperty("port") + "/elab/cosmic/first.jsp"));
            } else {
                response.sendRedirect(
                        response.encodeRedirectURL(
                            "http://" + System.getProperty("host") + 
                            System.getProperty("port") + "/elab"+prevPage));
            }
            return;
        }
    }
%>
<html>
<head>
<title>Login to Cosmic Application</title>
</head>

<BODY>
        <table bgcolor=000000 width="100%" border=0 cellpadding=0 cellspacing=0>
    <tr bgcolor=000000>
            <td rowspan="2" bgcolor=000000>
                <img src="graphics/blast.jpg" width=57 height=68 border=0>
            </td>
        <td bgcolor=000000 align="left">
            <font color=FFFFFF face=arial size=+3>Cosmic Ray e-Lab</font>
        </td>
     </tr>
  </table><P>
<center>
<TABLE WIDTH=500 BGCOLOR=FFFFFF>
    <TR><TD>
    <TABLE  WIDTH=500 CELLPADDING=4>
       <TR>
       <TR>
           <TD align=center BGCOLOR=99cccc>
           <FONT FACE=ARIAL SIZE=+1><B>
Please log in to proceed. </B></font>
           </TD>
       <TR>
    </TABLE>
<%
        if(incorrectLogin){
            warn(out, "<P>Incorrect username or password.");
        }
%>
        <TABLE align = center BORDER=0 WIDTH=500 CELLPADDING=4 VALIGN=TOP>
            <TR>

                <TD align=center>
                    <table CELLPADDING=0 CELLSPACING=0  VALIGN=TOP><tr><td>
                                <br>
                                <FORM method="post">
                                    <TABLE border= 0 cellpadding=2 cellspacing=10>
                                        <TR>
                                            <TD align=right><FONT color="black" face="ariel">Username: </FONT></TD>
                                            <TD><input size="16" type="text" name="user" tabindex="1"></TD>
                                        </TR>
                                        <TR>
                                            <TD align=right><FONT color="black" face="ariel">Password: </FONT></TD>
                                            <TD><INPUT size="16" type="password" name="pass" tabindex="2"></TD>
                                        </TR>
                                        <TR>
                                            <TD></TD><TD><INPUT type="submit" name="login" class="button2" value='Login' tabindex=\ "3"></TD>
                                        </TR>
                                    </TABLE>
                                </FORM>
                    </td></tr></table>
                    <TR>
                        <td align="center" colspan=3><font align="center" face="ariel"><a href=?prevPage=<%=prevPage%>&user=guest&pass=guest>Login as guest</a></font></td>
                    </TR>
                </td>
            </tr>
        </table>
</BODY>
</HTML>
