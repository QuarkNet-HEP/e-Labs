<P><center>
    
<%
//form action: where does "submit" take you?
String formAction = "";

//search function
String searchFunction = request.getParameter("f");

if(searchFunction == null){
%>
  <a href="?t=reference&f=view">View References</a> -
    <a href="?t=reference&f=delete">Delete References</a> -
    <a href="?t=glossary&f=view">View Glossary Items</a> -
    <a href="?t=glossary&f=delete">Delete Glossary Items</a><br>
    <a href="controlReferences.jsp">Upload or Download ALL Reference or Glossary Items</a>
  <%
    return;
}
else if(searchFunction.equals("delete")){
    formAction = "deleteReference.jsp";
}
%>
<TABLE WIDTH=800 CELLPADDING=4>

<TR><TD   BGCOLOR="#99cccc">
<FONT SIZE=+1 FACE=ARIAL color=black><B><%=searchFunction%> <%=referenceText%>s.</B>
</TD></TR>
</TABLE>



<FONT FACE=ARIAL SIZE="-1">
<table width="800" border="0">
    <tr><td colspan="2">1) Click on the name of the <%=referenceText%> to update it.</td></tr>
    <tr><td colspan="2">2) Click <b>Add New <%=referenceText%></b> to add a new <%=referenceText%>.</td></tr>
    <tr><td colspan="2">3) Use the additional links to move between Reference and Glossary and View and Delete</td></tr>

<%
if(searchFunction.equals("delete")){
%>
    <tr><td colspan="2">4) Click the checkbox(es) next to the <%=referenceText%>s to be deleted and click <b>Delete Item(s)</b>.</td></tr>
<%
}
%>


</table>
<BR>
<a href="?t=reference&f=view">View References</a> -
    <a href="?t=reference&f=delete">Delete References</a> -
    <a href="?t=glossary&f=view">View Glossary Items</a> -
    <a href="?t=glossary&f=delete">Delete Glossary Items</a><br><Br>
    <a href="controlReferences.jsp">Upload or Download ALL Reference or Glossary Items</a> -

<A HREF="addReference.jsp?t=<%=searchType%>">Add New <%=referenceText%>s</A>
</center>



<%
String q=request.getParameter("q");
if(q==null){    //default when no search specified
//    q = "type='reference'";
      q="type=\'"+searchType+"\'";
}

//perform the metadata search
ArrayList lfnsmeta = null;
lfnsmeta = getLFNsAndMeta(out, q);
if(lfnsmeta == null){
    warn(out, "Searching <font color=blue>" + 
            searchString + 
            q + 
            "</font> did not return any results.<br>\n");
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
