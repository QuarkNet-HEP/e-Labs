
<body link=0000FF vlink=0000FF> 
<div align="center"><%
//form action: where does "submit" take you?
String plotURLvalue=""; // use to pass the URL of the plots to displayPoster for papers.
String formAction = "";

//search function
String searchFunction = request.getParameter("f");
if(searchFunction == null){
%>
    <b>What would you like to do?</b><br>
    <a href="?t=poster&f=view">View/Edit/Delete Posters</a><br>
    <a href="?t=poster&f=delete">Delete Poster</a><br>
<%
    return;
}
else if(searchFunction.equals("delete")){
    formAction = "delete.jsp";
}

%>

<TABLE WIDTH=800 CELLPADDING=4>
<TR><TD   BGCOLOR="#66CC33">
<FONT SIZE=+1 FACE=ARIAL color=black><B>Search for and <%=searchFunction%> posters.</B>
</TD></TR>
</TABLE>



<%




//variables used in metadata searches:
String aname1 = request.getParameter("aname1");
if (aname1 == null) aname1="title";
String input1 = request.getParameter("input1");
if (input1 == null) input1="";
String input2 = request.getParameter("input2");
if (input2 == null) input2="1/1/2004";
String input3 = request.getParameter("input3");
if (input3 == null) input3="12/30/2050";

//extra pre-defined searches for posters:
//String groupQuery = "type=\'poster\' AND project=\'" + eLab + "\' AND group=\'" + groupName + "\'";
//String teacherQuery = "type=\'poster\' AND project=\'" + eLab + "\' AND teacher=\'" + groupTeacher + "\'";
//String allQuery = "type=\'poster\' AND project=\'" + eLab + "\'";
%>
<FONT FACE=ARIAL>
<table width="600" border="0">
<tr><td align="center" colspan="2">
Find a group of posters:</td></tr> 
<td align="center" colspan="2">
<a href="?t=poster&f=<%=searchFunction%>&q=<%=groupQuery%>&aname1=group&input1=<%=groupName%>"><%=groupName%>'s posters</a> -
<a href="?t=poster&f=<%=searchFunction%>&q=<%=teacherQuery%>&aname1=teacher&input1=<%=groupTeacher%>"><%=groupTeacher%>'s posters</a> - 
<a href="?t=poster&f=<%=searchFunction%>&q=<%=schoolQuery%>&aname1=school&input1=<%=groupSchool%>"><%=groupSchool%>'s posters</a> - 
<a href="?t=poster&f=<%=searchFunction%>&q=<%=allQuery%>">All posters</a>
</td></tr>
<tr><td colspan="2" align="center"> or Search all posters by</td></tr>
<tr>
<td  colspan="2" align="center">
<form name="search" method="get">
<input type="hidden" name="t" value="poster">
<input type="hidden" name="f" value="<%=searchFunction%>">
<INPUT type="hidden" name="q">
<INPUT type="hidden" name="order" value="">
<select name="aname1">
    <OPTION value="title"<%if (aname1.equals("title")) {%> selected<%}%>>Title</OPTION>	
    <OPTION value="group"<%if (aname1.equals("group")) {%> selected<%}%>>Group</OPTION>	
    <OPTION value="teacher"<%if (aname1.equals("teacher")) {%> selected<%}%>>Teacher</OPTION>	
    <OPTION value="school"<%if (aname1.equals("school")) {%> selected<%}%>>School</OPTION>	
    <OPTION value="city"<%if (aname1.equals("city")) {%> selected<%}%>>City</OPTION>	
    <OPTION value="state"<%if (aname1.equals("state")) {%> selected<%}%>>State</OPTION>	
    <OPTION value="year"<%if (aname1.equals("year")) {%> selected<%}%>>Year</OPTION>	
</SELECT>
<input type="hidden" name="op1" value="CONTAINS">
<input name="input1" size="20" maxlength="30" value="<%=input1%>">
<input type="submit" name="submit1" value="Search Posters" onclick="javascript:
if(search.input1.value == '' && search.input2.value == '' && search.input3.value == ''){
    return false;
}
else{
    var qChoice='type=\'poster\' AND project=\'<%=eLab%>\'';
    search.q.value = qChoice;
    if (search.input1.value != ''){
        var iname1 = search.aname1.selectedIndex;
        var op1 = search.op1.value;
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
<%
if(searchFunction.equals("delete")){
%>
    <tr><td colspan="2">2) Click the column headings to sort on that property.</td></tr>
    <tr><td colspan="2">3) Click the checkbox(es) next to the Title(s) of posters to be deleted and click <b>Delete</b>.</td></tr>
<%
}
%>
<tr colspan=2><td align="center"><FONT SIZE="-1">States include provinces and foreign countries.  Enter the <A HREF="javascript:openPopup('showStates.jsp','states',400,700)">abbreviation.</A></FONT></td></tr>

<tr>
<td colspan="2" align="center">
<font size="-1">(Optional) Limit search by date:</font>
<br>
<font size="-1">Date:</font> 
<input name="aname2" type="hidden" value="date">
<input name="input2" size="10" maxlength="15" value="<%=input2%>">
 <font size="-1">to</font> 
<input name="input3" size="10" maxlength="15" value="<%=input3%>">
</td>
</tr>

</table>
</form>
<HR width="400">


<%
String q=request.getParameter("q");
if(q==null){    //default when no search specified
//    q = "type='poster'" + groupName + "'";
    q = allQuery;
    aname1 = "group";
    input1 = groupName;
}

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
    warn(out, "Searching <font color=blue>" + 
            searchString + 
            betweenString + 
            "</font> did not return any results.<br>\n</div>");
    //out.println("<font size=-1>q = " + q);
    return;
}

String order = request.getParameter("order");
if ((order == null) || (order.equals(""))){
    order = "title";
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
    <table cellspacing="10" border="0">
        <!-- Table header -->
        <tr>
            <td colspan="10" align="center">Posters Found</td>
        </tr>
        <tr>
            <td width="90" align="center"><a href="?t=poster&f=<%=searchFunction%>&q=<%=q%>&order=title" <%=metaCSS.get("title")%>>Title</a></td>
            <td align="center"><a href="?t=poster&f=<%=searchFunction%>&q=<%=q%>&order=date" <%=metaCSS.get("date")%>>Date</a></td>
            <td align="center"><a href="?t=poster&f=<%=searchFunction%>&q=<%=q%>&order=group" <%=metaCSS.get("group")%>>Group</a></td>
            <td align="center"><a href="?t=poster&f=<%=searchFunction%>&q=<%=q%>&order=teacher" <%=metaCSS.get("teacher")%>>Teacher</a></td>
            <td align="center"><a href="?t=poster&f=<%=searchFunction%>&q=<%=q%>&order=school" <%=metaCSS.get("school")%>>School</a></td>
            <td align="center"><a href="?t=poster&f=<%=searchFunction%>&q=<%=q%>&order=city" <%=metaCSS.get("city")%>>City</a></td>
            <td align="center"><a href="?t=poster&f=<%=searchFunction%>&q=<%=q%>&order=state" <%=metaCSS.get("state")%>>State</a></td>
            <td align="center"><a href="?t=poster&f=<%=searchFunction%>&q=<%=q%>&order=year" <%=metaCSS.get("year")%>>Year</a></td>
        </tr>
<%
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
                
                <td width="90">
                    <!-- checkbox/nothing for delete/view respectively -->
                    <% plotURLvalue = mf.pickMeta("plotURL", metaValues.get("plotURL")); %>
                    <%=selector%>
                    <a href="displayPoster.jsp?type=poster&posterName=<%=lfn%>&plotURL=<%=plotURLvalue%>">
                        <font size="-1"><%=mf.pickMeta("title", metaValues.get("title"))%></font>
                    </a>
                </td>
               
                <td align="center"><font size="-1"><%=mf.pickMeta("date", metaValues.get("date"))%></font></td>
                <td align="center"><font size="-1"><%=mf.pickMeta("group", metaValues.get("group"))%></font></td>
                <td align="center"><font size="-1"><%=mf.pickMeta("teacher", metaValues.get("teacher"))%></font></td>
                <td align="center"><font size="-1"><%=mf.pickMeta("school", metaValues.get("school"))%></font></td>
                <td align="center"><font size="-1"><%=mf.pickMeta("city", metaValues.get("city"))%></font></td>
                <td align="center"><font size="-1"><%=mf.pickMeta("state", metaValues.get("state"))%></font></td>
                <td align="center"><font size="-1"><%=mf.pickMeta("year", metaValues.get("year"))%></font></td>
                <td align="center">
                    <font color=black size="-2">
                    <font color=black size="-2">
			<% plotURLvalue = mf.pickMeta("plotURL", metaValues.get("plotURL")); %>
                        <a href="addComments.jsp?fileName=<%=lfn%>&t=poster&plotURL=<%=plotURLvalue%>">
                        View/Add<br>Comments
                        </a>
                    </font>
                </td>
                <td align="center">
                    <font color=black size="-2">
                    <% plotURLvalue = mf.pickMeta("plotURL", metaValues.get("plotURL")); %>
                        <a target="paper" href="displayPoster.jsp?type=paper&posterName=<%=lfn%>&plotURL=<%=plotURLvalue%>">
                        View as<br>Paper
                        </a>
                    </font>
                </td>
                <td align="center">
                    <font color=black size="-2">
                        <a href="javascript: void(window.open('viewPosterMeta.jsp?posterFile=<%=lfn%>','Metadata','width=250,height=350,scrollbars=yes,toolbar=no,menubar=no,status=yes,resizable=yes'))">
                        View<br>Metadata
                        </a>
                    </font>
                </td>
                
            </tr>
<%
        }
        

        //if we're deleting, output a "submit" button
        String submitButton = "";
        if(searchFunction.equals("delete")){
            submitButton = "<tr><td colspan=10 align=right>" + 
                "<input type=hidden name=type value=poster>" +
                "<input type=hidden name=pfn value="+plotURLvalue+">"+
                "<input type=submit value=\"Delete Poster(s)\"></td></tr>";
        }
%>
    <%=submitButton%>
    </table>
    </div>
</form>
</font>
