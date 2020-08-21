<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">   
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>Administration Reports</title>
    <link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
    <link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
    <link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
  </head>
  
  <body id="administration-reports" class="teacher">
    <!-- entire page container -->
    <div id="container">
      <div id="top">
        <div id="header">
          <%@ include file="../include/header.jsp" %>
          <div id="nav">
            <%@ include file="../include/nav-teacher.jsp" %>
          </div>
        </div>
      </div>
      
      <div id="content">
        <table id="main" cellpadding="10" cellspacing="10">
          <tr><th colspan="2" >Reports</th><th></th></tr>
          <tr>
            <td>&#8226; <a href="../reports/uploads-report.jsp">Uploads Report</a></td>
            <td>Retrieve information about cosmic uploaded files.</td>
          </tr>
          <tr>
            <td>&#8226; <a href="../reports/plots-report.jsp">Plots Report</a></td>
            <td>Retrieve information about plots.</td>
          </tr>
          <tr>
            <td>&#8226; <a href="../reports/posters-report.jsp">Posters Report</a></td>
            <td>Retrieve information about posters.</td>
          </tr>
           <tr>
            <td>&#8226; <a href="../reports/performance-report.jsp">Elab Performance Report</a></td>
            <td>Retrieve information about splits and analyses.</td>
          </tr>

        </table>
      </div>
      <!-- end content -->  
      <div id="footer">
      </div>
    </div>
    <!-- end container -->
  </body>
</html>