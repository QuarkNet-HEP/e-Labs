<%@ page import="java.sql.Timestamp" %> 
<%@ page buffer="1000kb" %>
<%@ include file="common.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<link rel="stylesheet"  href="include/styletut.css" type="text/css">



<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
<TITLE>Cosmics Data Interface</TITLE>
<%@ include file="include/javascript.jsp" %>
<!-- include css style file -->
<%@ include file="include/style.css" %>

<%

//type of search the user chose
String searchType = request.getParameter("t");
if (searchType==null) searchType="reference";
String referenceText="Reference";
if (searchType.equals("glossary")) {referenceText="Glossary Item";}
if (searchType.equals("FAQ")) {referenceText="FAQ Item";}
if (searchType.equals("news")) {referenceText="News Item";}

// redirect to other pages
String searchFunction = request.getParameter("f");
if (searchFunction == null)
    searchFunction = "view";
if (searchFunction!=null && searchFunction.equals("download"))
{%> 
    Loading..<br><br>if your browser does not redirect you, <a href="controlReferences.jsp?type=<%=searchType%>">click here</a>.
    <META HTTP-EQUIV="Refresh" CONTENT="0; URL=controlReferences.jsp?type=<%=searchType%>"> 
<%}
else if (searchFunction!=null && searchFunction.equals("upload"))
{%> 
    Loading...<br><br>if your browser does not redirect you, <a href="controlReferences.jsp">click here</a>.
    <META HTTP-EQUIV="Refresh" CONTENT="0; URL=controlReferences.jsp"> 
<%}
else if (searchFunction!=null && searchFunction.equals("add"))
{%> 
    Loading...<br><br>if your browser does not redirect you, <a href="addReference.jsp?t=<%=searchType%>">click here</a>.
    <META HTTP-EQUIV="Refresh" CONTENT="0; URL=addReference.jsp?t=<%=searchType%>"> 
<%}

 
else
{
    %>
<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Library";
%>
<%@ include file="include/navbar_common.jsp" %>
<body>
<%

//pre-defined searches
String searchString = "type=\'" + searchType + "\' AND project=\'" + elabName + "\'";

//include the instructions/search options and table listing based on the searchType
%>
    <P><center>
    
<%
//form action: where does "submit" take you?
String formAction = "";

//search function

if(searchFunction == null){
%>
<form name='action_form' method=get>
<select name="f"> 
<option value="view" <%if (searchFunction.equals("view")) out.print(" selected"); %> >View
<option value="delete" <%if (searchFunction.equals("delete")) out.print(" selected"); %>>Delete
<option value="upload"<%if (searchFunction.equals("upload")) out.print(" selected"); %>>Upload
<option value="download"<%if (searchFunction.equals("download")) out.print(" selected"); %>>Download
<option value="add"<%if (searchFunction.equals("add")) out.print(" selected"); %>>Add
</select>
<select name="t">
<option value="reference"<%if (searchType.equals("reference")) out.print(" selected"); %>>Reference
<option value="glossary"<%if (searchType.equals("glossary")) out.print(" selected"); %>>Glossary
<option value="FAQ"<%if (searchType.equals("FAQ")) out.print(" selected"); %>>FAQ 
<option value="news"<%if (searchType.equals("news")) out.print(" selected"); %>>News
</select>
Item(s).<br>
<input type='submit' name='submit' value='Go!'>
</form>
<% /*
  <a href="?t=reference&f=view">View References</a> -
    <a href="?t=reference&f=delete">Delete References</a> -
    <a href="?t=glossary&f=view">View Glossary Items</a> -
    <a href="?t=glossary&f=delete">Delete Glossary Items</a><br>
    <a href="controlReferences.jsp">Upload or Download ALL Reference or Glossary Items</a>
*/ %>
<%
    return;
}
else if(searchFunction.equals("delete")){
    formAction = "deleteReference.jsp";
}
// Cap first letter of searchFunction to output
char ch = searchFunction.charAt(0);
ch = Character.toUpperCase(ch);
String Up_searchFunction = ch + searchFunction.substring(1);
%>
<TABLE WIDTH=800 CELLPADDING=4>

<TR><TD   BGCOLOR="#99cccc">
<FONT SIZE=+1 FACE=ARIAL color=black><B><%=Up_searchFunction%> <%=referenceText%>s.</B>
</TD></TR>
</TABLE>



<FONT FACE=ARIAL SIZE="-1">
<table width="800" border="0">
    <tr><td colspan="2">Use the drop-down box to navigate.</td></tr>




</table>
<BR>
<form method=get action="" name='action_form'>
<select name="f"> 
<option value="view" <%if (searchFunction.equals("view")) out.print(" selected"); %> >View
<option value="delete" <%if (searchFunction.equals("delete")) out.print(" selected"); %>>Delete
<option value="upload"<%if (searchFunction.equals("upload")) out.print(" selected"); %>>Upload
<option value="download"<%if (searchFunction.equals("download")) out.print(" selected"); %>>Download
<option value="add"<%if (searchFunction.equals("add")) out.print(" selected"); %>>Add
</select>
<select name="t">
<option value="reference"<%if (searchType.equals("reference")) out.print(" selected"); %>>Reference
<option value="glossary"<%if (searchType.equals("glossary")) out.print(" selected"); %>>Glossary
<option value="FAQ"<%if (searchType.equals("FAQ")) out.print(" selected"); %>>FAQ 
<option value="news"<%if (searchType.equals("news")) out.print(" selected"); %>>News
</select>
<% /*<select name="f">
<option value="view" selected>View
<option value="delete">Delete
<option value="upload">Upload
<option value="download">Download
<option value="add">Add
</select>
<select name="t">
<option value="reference" selected>Reference
<option value="glossary">Glossary
<option value="FAQ">FAQ 
<option value="news">News
</select>*/%>
Item(s).<br>
<input type='submit' name='submit' value='Go!'>
</form>
</center>

<table width='800' border='0'>



<tr><td colspan = '2'> Click on the name of the <%=referenceText%> to update it.</td></tr>
<% if(searchFunction.equals("delete")){
%>
    <tr><td colspan="2">Click the checkbox(es) next to the <%=referenceText%>s to be deleted and click <b>Delete Item(s)</b>.</td></tr>
</table>
<%
}

String q=request.getParameter("q");
if(q==null){    //default when no search specified
      q="type=\'"+searchType+"\'";
}

//perform the metadata search
ArrayList lfnsmeta = null;
lfnsmeta = getLFNsAndMeta(out, q);
if(lfnsmeta == null){
    warn(out, "No  <font color=blue>" + 
            searchType +
            "s</font> were found in the database.<br>\n");
    out.println("<font size=-1>q = " + q);
    return;
}

String order = request.getParameter("order");
if ((order == null) || (order.equals(""))){
    order = "name";
}
MetaCompare mc = new MetaCompare();
mc.setSortKey(order);
Collections.sort(lfnsmeta, mc);

//set css class for whatever the order variable is set to
HashMap metaCSS = new HashMap();
metaCSS.put(order, "class=\"orderby\"");

//metadata formatter class instance
MetaFormat mf = new MetaFormat();
%>

<!-- Query results table -->
<form method="post" action="<%=formAction%>">
    <br>
    <table width="800" cellspacing="0" cellpadding="5" border="1">
<%
        int fileCounter = 0;
        for(Iterator i=lfnsmeta.iterator(); i.hasNext(); ){
            ArrayList pair = (ArrayList)i.next();
            String lfn = (String)pair.get(0);
            ArrayList metaTuples = (ArrayList)pair.get(1);

            //create the HashMap of metadata Tuple values
            HashMap metaValues = new HashMap();
            for(Iterator j=metaTuples.iterator(); j.hasNext(); ){
                Tuple t = (Tuple)j.next();
                String key = (String)t.getKey();
                Object value = t.getValue();

                metaValues.put(key, value);
            }
            %>
            <tr>
            <%
                //checkbox or radio:
                String selector = "";
                if(searchFunction.equals("delete")){
                    selector = "<input type=checkbox name=filename value=" + lfn + ">";
                }
%>
                <td width="220" valign="top">
                    <!-- checkbox/nothing for delete/view respectively -->
                    <%=selector%>
                        <a href="addReference.jsp?referenceName=<%=lfn%>&t=<%=searchType%>"><%=lfn%>
                        </a>
                  </td>
                        <td valign="top"><%=mf.pickMeta("description", metaValues.get("description"))%></td>
                 </tr>
<%                 
         } 
    

        //if we're deleting, output a "submit" button
        String submitButton = "";
        if(searchFunction.equals("delete")){
            submitButton = "<tr><td colspan=2 align=center>" + 
                "<input type=hidden name=type value="+searchType +">"+
                "<input type=submit value=\"Delete Item(s)\"></td></tr>";
        }
%>
    <%=submitButton%>
    </table>
</form>
</font>
    <% } %>
</body>
</html>
