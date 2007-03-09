<%@ page import="java.util.*" %>
<%@ include file="common.jsp" %>
<%@ include file="include/javascript.jsp" %>

<HTML>
<HEAD>
<TITLE>Cosmics Resources</TITLE>
<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%@ include file="include/javascript.jsp" %>
</HEAD>
<body bgcolor=FFFFFF  vlink=ff6600>
<%
//be sure to set this before including the navbar
String headerType = request.getParameter("header");
if (headerType==null) headerType="Library";
//String headerType = "Library";
%>
<%@ include file="include/navbar_display.jsp" %>



</BODY>
</HTML>


