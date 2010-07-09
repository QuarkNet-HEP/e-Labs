<%@ page import="java.io.*" %>
<%@ page import="java.util.regex.*" %>
<%@ include file="common.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<html>
    <head>
        <title>Show States and Abbreviations for Searching</title>
    </head>
<!-- include css style file -->
<%@ include file="include/styletut.css" %>
<%@ include file="include/javascript.jsp" %>
    <body>
        <div align="center">

<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>

    <table width="400">
    <tr><th colspan="2" align="left">Abbreviations for Searching<BR>States, <A HREF="#province">Provinces</A> or <A HREF="#country">Countries</A></th></tr>
<%
     String query="SELECT name,abbreviation,type from state order by type,name;";
     int curType=0;

     rs = s.executeQuery("SELECT name,abbreviation,type from state order by type,name;");
     while(rs.next()){
       String name=rs.getString(1);
       String abbreviation=rs.getString(2);
       int type = rs.getInt("type");
       if (type!=curType)
       {
       if (type==1) {out.write("<tr><th>Abbrev</th><th align=\"left\">State</th>");curType=type;}
       if (type==2) {out.write("<tr><th>Abbrev</th><th align=\"left\"><A name=\"province\">Province</A></th>");curType=type;}
       if (type==3) {out.write("<tr><th>Abbrev</th><th align=\"left\"><A name=\"country\">Country</A></th>");curType=type;}
        }
     %>
	<tr><td><%=abbreviation%></td><td><%=name%></td></tr>
    <%
     } //while
     %>

  </table></div>
</body>
<%
if (s != null)
    s.close();
if (conn != null)
    conn.close();
%>
</html>

