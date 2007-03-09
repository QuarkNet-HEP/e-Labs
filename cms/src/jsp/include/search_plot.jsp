<P><center>
<script language='javascript'>
<!--
function Send(url, link)
{
    var count = parseInt(opener.document.log.count.value);
    opener.document.log.log_text.value += "(--Image " + count + "--)";
    opener.document.log.count.value = (count + 1)+"";
    opener.document.log.img_src.value += "<a href='" + link + "' target='_blank'>";
    opener.document.log.img_src.value += "<IMG height='100' width='100' SRC='";
    opener.document.log.img_src.value += url;
    opener.document.log.img_src.value += "' border=0></a>,";
    self.close();
    opener.focus();
    return false;
};
// -->
</script>   
<%
//form action: where does "submit" take you?
String formAction = "";

//search function
String searchFunction = request.getParameter("f");

if(searchFunction == null){
%>
    <b>What would you like to do?</b><br>
    <a href="?t=plot&f=view">View Plots</a><br>
    <a href="?t=plot&f=delete">Delete Plots</a><br>
<%
    return;
}
else if(searchFunction.equals("delete")){
    formAction = "delete.jsp";
}
%>
<TABLE WIDTH=800 CELLPADDING=4>
<TR><TD   BGCOLOR="#4382BB">
<% if (searchFunction.equals("viewgroup")) { 
    String GroupName = request.getParameter("input1");
    if (GroupName == null) GroupName = "";%>
    <FONT SIZE=+1 FACE=ARIAL color=black><B>View <%=GroupName%> group plots.</B>
<% } else { %>
<FONT SIZE=+1 FACE=ARIAL color=black><B>Search for and <%=searchFunction%> plots.</B>
    <% } %>
</TD></TR>
</TABLE>



<%

//variables used in metadata searches:
String aname1 = request.getParameter("aname1");
if (aname1 == null) aname1="name";
String input1 = request.getParameter("input1");
if (input1 == null) input1="";
String input2 = request.getParameter("input2");
if (input2 == null) input2="1/1/2004";
String input3 = request.getParameter("input3");
if (input3 == null) input3="12/30/2050";
%>
<FONT FACE=ARIAL SIZE="-1">
<% if (!searchFunction.equals("viewgroup"))
{
%>
<table width="700" border="0">
<tr><td align="center" colspan="2" nowrap>
Show plots by:&nbsp; 
<a href="?t=plot&f=<%=searchFunction%>&q=<%=groupQuery%>&aname1=group&input1=<%=groupName%>"><%=groupName%></a> -
<a href="?t=plot&f=<%=searchFunction%>&q=<%=teacherQuery%>&aname1=teacher&input1=<%=groupTeacher%>"><%=groupTeacher%></a> - 
<a href="?t=plot&f=<%=searchFunction%>&q=<%=schoolQuery%>&aname1=school&input1=<%=groupSchool%>"><%=groupSchool%></a> - 
<a href="?t=plot&f=<%=searchFunction%>&q=<%=cityQuery%>&aname1=city&input1=<%=groupCity%>"><%=groupCity%></a> - 
<a href="?t=plot&f=<%=searchFunction%>&q=<%=stateQuery%>&aname1=state&input1=<%=groupState%>"><%=groupState%></a> - 
<a href="?t=plot&f=<%=searchFunction%>&q=<%=allQuery%>">Everyone</a>
<br><br><br>
</td></tr>
<tr><td colspan="2" align="center">or Search Plots by</td></tr>
<tr colspan=2>

<td align="center">
<form name="search" method="get">
<input type="hidden" name="t" value="plot">
<input type="hidden" name="f" value="<%=searchFunction%>">
<INPUT type="hidden" name="q">
<INPUT type="hidden" name="order" value="">

<select name="aname1">
    <OPTION value="city"<%if (aname1.equals("city")) {%> selected<%}%>>City</OPTION>	
    <OPTION value="group"<%if (aname1.equals("group")) {%> selected<%}%>>Group</OPTION>	
    <OPTION value="name"<%if (aname1.equals("name")) {%> selected<%}%>>Name</OPTION>	
    <OPTION value="school"<%if (aname1.equals("school")) {%> selected<%}%>>School</OPTION>	
    <OPTION value="state"<%if (aname1.equals("state")) {%> selected<%}%>>State</OPTION>	
    <OPTION value="teacher"<%if (aname1.equals("teacher")) {%> selected<%}%>>Teacher</OPTION>	
</SELECT>
<input type="hidden" name="op1" value="CONTAINS">
<input name="input1" size="20" maxlength="30" value="<%=input1%>">
<input type="submit" name="submit1" value="Search Plots" onClick="javascript:
if(search.input1.value == '' && search.input2.value == '' && search.input3.value == ''){
    return false;
}
else{
    var qChoice='type=\'plot\' AND project=\'<%=eLab%>\'';
    if (search.input1.value != ''){
        var iname1 = search.aname1.selectedIndex;
        var op1 = search.op1.value;
        //var value1 = search.input1.value.toUpperCase();
        //qChoice = qChoice + ' AND UPPER(' + search.aname1[iname1].value + ') ' + op1 + ' \'' + value1 + '\'';
        var value1 = search.input1.value;
        qChoice = qChoice + ' AND ' + search.aname1[iname1].value + ' ' + op1 + ' \'' + value1 + '\'';
    }
    if(search.input2.value != '' && search.input3.value != ''){
        var iname2 = search.aname2.value;
        var value2 = search.input2.value;
        var value3 = search.input3.value;
        qChoice = qChoice + ' AND ' + iname2 + ' BETWEEN \'' + value2 + '\' AND \'' + value3 + ' 23:59:59\'';
    }
    if (search.input2.value != '' && search.input3.value == '') {
        var iname2 = search.aname2.value;
        var value2 = search.input2.value;
        qChoice = qChoice + ' AND ' + iname2 + ' > \'' + value2 + '\'';
    }
    if (search.input2.value == '' && search.input3.value != '') {
        var iname2 = search.aname2.value;
        var value3 = search.input3.value;
        qChoice = qChoice + ' AND ' + iname2 + ' < \'' + value3 + '\'';
    }
    search.q.value = qChoice;
}
">
</td></tr>
<tr colspan=2><td align="center"><FONT SIZE="-1">States include provinces and foreign countries.  Enter the <A HREF="javascript:openPopup('showStates.jsp','states',400,700)">abbreviation.</A></FONT></td></tr>

<tr>
<td colspan="2" align="center">
<font size="-1">(Optional) Limit search by creation date:</font>
<br>
<font size="-1">Date:</font> 
<input name="aname2" type="hidden" value="creationdate">
<input name="input2" size="10" maxlength="15" value="<%=input2%>">
 <font size="-1">to</font> 
<input name="input3" size="10" maxlength="15" value="<%=input3%>">
</td>
</tr>

</table>
</form>
<HR width="400">
</div>
<%
} // end of search bar that 'viewgroup' doesnt see

String q=request.getParameter("q");
if(q==null){    //default when no search specified
    q = "type='plot'";
    aname1 = "group";
    input1 = groupName;
}
else {
//perform the metadata search
ArrayList lfnsmeta = null;
lfnsmeta = getLFNsAndMeta(out, q);
if(lfnsmeta == null){
    String searchString = "";
    if(!input1.equals("")){
        searchString = aname1 + 
            "</font> for <font color=blue>" + 
            input1;
    }
    String betweenString = "";
    if(!input2.equals("") && !input3.equals("")){
        betweenString = "</font> between <font color=blue>" + 
            input2 + 
            "</font> and <font color=blue>" + 
            input3;
    }
    warn(out, "<div align=\"center\">Searching <font color=blue>" + 
            searchString + 
            betweenString + 
            "</font> did not return any results.<br>\n");
    out.println("<font size=-1>q = " + q+ "</div>");
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
<% if (!searchFunction.equals("choose")) { %>
<form method="post" action="<%=formAction%>">
<% } %>
    <br>
    <table width="800" cellspacing="0" cellpadding="5" border="0">
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
            if (fileCounter % 4 == 0) {
                if (fileCounter != 0) {
                    if (fileCounter % 8 == 0) {
                        out.write("</tr><tr>");
                    } else {
                        out.write("</tr><tr bgcolor=\"#e7eefc\">");
                    }
                } else {
                    out.write("<tr>");
                }
            }       
            
                //checkbox or radio:
                String selector = "";
                if(searchFunction.equals("delete")){
                    selector = "<input type=checkbox name=filename value=" + lfn + ">";
                }
%>
                <td valign=bottom align=center>
                    <!-- checkbox/nothing for delete/view respectively -->
                    <%=selector%>
<%
                    String thumbNailLFN = (String)metaValues.get("thumbnail");
                    String thumbNailPFN = null;
                    if (thumbNailLFN != null)
                        thumbNailPFN = getPFN(out, thumbNailLFN);
                    
                    //TODO: (TIBI) We remove here the dependency on the RLS
                    
                    //TODO: change "/cms/plots" to elabName+"/plots"
                    String metaPlotPath=""+metaValues.get("year")+"/"+metaValues.get("state")+"/"+metaValues.get("city")+"/"+         
                            metaValues.get("school")+"/"+metaValues.get("teacher")+"/"+metaValues.get("group")+"/cms/plots/";
					metaPlotPath=metaPlotPath.replaceAll(" ","_");
                    
                    //thumbNailPFN = "/elab/cms/output/AY2006/IN/notre_dame/ND_QN_Center/Beth_Marchant/cmsguest/cms/plots/"+thumbNailLFN;
                    thumbNailPFN = "/elab/cms/output/"+metaPlotPath+thumbNailLFN;
                    
                    
                    if (thumbNailPFN == null) {
%>
                    
                        <br><a href="view.jsp?filename=<%=lfn%>&type=plot&get=data">
                            <font size=-1><%=mf.pickMeta("name", metaValues.get("name"))%>
                        </a><br>
<%                  } else {
                        //not relevant any more, see change TIBI above
						//thumbNailPFN = thumbNailPFN.substring(thumbNailPFN.indexOf("users"));
%>
                        <br><a href="view.jsp?filename=<%=lfn%>&type=plot&get=data">
                            <img src="<%=thumbNailPFN%>" border=0 height="150" width="150"></a><br>
                            <br><font size=-1><%=mf.pickMeta("name", metaValues.get("name"))%><br>
<%
                    }
%>
                </font>
                <font size=-2>Group: <%=mf.pickMeta("group", metaValues.get("group"))%></font><br>
                <font size=-2>Created: <%=mf.pickMeta("creationdate", metaValues.get("creationdate"))%></font><br>
<%              if (searchFunction.equals("choose")) { 
                    String my_pfn = getPFN(lfn);
                    if (my_pfn == null)
                        warn(out,"<font color='red'>No Physical file associated with it.</font>");
                    else
                    {
                        String URL = my_pfn.substring(my_pfn.indexOf("users"));
                        String LINK = "view.jsp?filename="+lfn+"&type=plot&get=data";
%>
                        <form onSubmit="return Send('<%=URL%>','<%=LINK%>');">
                        <input type='submit' value='Add This Plot'>
                        </form>
<%                  } 
                }
                else { %>
                <font color=black size="-2"><a href="addComments.jsp?fileName=<%=lfn%>&t=plot">View/Add Comments</a></font><br><br>
<%              }
        fileCounter++;
        }

        //if we're deleting, output a "submit" button
        String submitButton = "";
        if(searchFunction.equals("delete")){
            submitButton = "<tr><td colspan=10 align=right>" + 
                "<input type=hidden name=type value=plot>" +
                "<input type=submit value=\"Delete File(s)\"></td></tr>";
        }
%>
    <%=submitButton%>
    </table>
    <% if (!searchFunction.equals("choose")) { %>
    </form>
        <% } 
} // end if for disabling results without search%>
</font>
