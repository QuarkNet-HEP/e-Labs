<P><div align="center">

<%
//form action: where does "submit" take you?
String itemName="";

//search function
String searchFunction = request.getParameter("f");

if(searchFunction == null){
%>
  <a href="?t=reference&f=peruse">View Resources for Study Guide</a> -
    <a href="?t=glossary&f=peruse">View Glossary</a>
  <%
    return;
}
%>
<TABLE WIDTH=800 CELLPADDING=4>

<TR><TD class="library_header">View <%=referenceText%>.
</TD></TR>
</TABLE>



</table>
<BR>
<a href="?t=reference&f=peruse">View References for Study Guide</a> -
    <a href="?t=glossary&f=peruse">View Glossary</a>
</center>



<%
String q=request.getParameter("q");
if(q==null){    //default when no search specified
//    q = "type='reference'";
      q="type=\'"+searchType+"\'";
}
q=q+ " and ( project=\'"+eLab+"\' or project=\'all\')";

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
    <br>
    <table width="800" cellspacing="5" cellpadding="5" border="1">
<%
        int fileCounter = 0;
        for(Iterator i=lfnsmeta.iterator(); i.hasNext(); ){
            ArrayList pair = (ArrayList)i.next();
            String lfn = (String)pair.get(0);
            itemName=lfn.substring(lfn.indexOf("_")+1,lfn.length());
            itemName=itemName.replaceAll("_"," ");
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
 
                <td width="180" valign="top">
                    <!-- checkbox/nothing for delete/view respectively -->
                         <%=itemName%>
                        </a>
                  </td>
                        <td valign="top" bgcolor="white"><%=mf.pickMeta("description", metaValues.get("description"))%></td>
                 </tr>
<%                 
         } 
    
%>
    </table>
</form>
</font>

</div>
