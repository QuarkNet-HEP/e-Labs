<%@ page import="java.sql.Timestamp" %> 
<%@ page buffer="1000kb" %>
<%@ include file="common.jsp" %>
<link rel="stylesheet"  href="include/styletut.css" type="text/css">


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
<TITLE>Cosmics Data Interface</TITLE>
<%@ include file="include/javascript.jsp" %>

<%
//type of search the user chose
String searchType = request.getParameter("t");
if (searchType==null) searchType="reference";
String referenceText="Resources for Study Guide";
if (searchType.equals("glossary")) {referenceText="Glossary";}
%>
<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Library";
%>
<%@ include file="include/navbar_common.jsp" %>

<%

//pre-defined searches
String searchString = "type=\'" + searchType + "\' AND project=\'" + elabName + "\'";

//include the instructions/search options and table listing based on the searchType
%>
    <%@ include file="include/search_ref_peruse.jsp" %>
</body>
</html>
