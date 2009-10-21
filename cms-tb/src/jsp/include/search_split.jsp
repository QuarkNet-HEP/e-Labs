<P>
<% 
String study = request.getParameter("s");
String searchFunction = request.getParameter("f");
String startRecord = request.getParameter("sr");
String tutorialName = "";

// Bug fix.  We should set a default if the user ever reaches this point.
if (searchFunction == null)
    searchFunction = "analyze";
if (study == null)
    study = "performance";
    
if (study.equals("performance")) {
  tutorialName="dpstutorial.jsp";}
  else if (study.equals("lifetime")) {
    tutorialName="ltimetutorial.jsp";}
  else if (study.equals("shower")) {
    tutorialName="eshtutorial.jsp";}
 else if (study.equals("flux")) {
    tutorialName="fluxtutorial.jsp";}


if(study != null && searchFunction.equals("analyze"))
{

%>

<TABLE WIDTH=800 CELLPADDING=4>
<TR><TD  BGCOLOR="#4382BB">
<FONT SiZE=+1 FACE=ARIAL color=black><B>Choose data for the <%=study%> study.</B>
</TD></TR>
</TABLE>

</center>
<div id="search">
<%
}
if(searchFunction.equals("view") )
{
%>
<TABLE WIDTH=800 CELLPADDING=4>
<TR><TD   BGCOLOR="#4382BB">
<FONT SIZE=+1 FACE=ARIAL color=black><B>Search for and view uploaded data.</B>
</TD></TR>
</TABLE>
</center>
<div id="search">
<%
}
if(searchFunction.equals("delete") )
{
%>
<TABLE WIDTH=800 CELLPADDING=4>
<TR><TD   BGCOLOR="#4382BB">
<FONT FACE=ARIAL SIZE=+1 color=black><B>Search for and delete data files.</B>
</TD></TR>
</TABLE>
</center>
<div id="search">
<%
}




%>
<center>
    
<%
//form action: where does "submit" take you?
String formAction = "";

//study type (only applicable if function is "analyze")
if (study==null) study = "";
     
//search function
if(searchFunction == null){
%>
    <b>What would you like to do?</b><br>
    <a href="?t=split&f=view">View</a><br>
    <a href="?t=split&f=analyze">Analyze</a><br>
    <a href="?t=split&f=delete">Delete</a><br>
<%
    return;
}
else if(searchFunction.equals("delete")){
    formAction = "delete.jsp";
}
else if(searchFunction.equals("analyze")){
    if(study == null){
%>
        <p align="center"><b>Choose one of the following studies:</b></p>
        <center>
            <a href="search.jsp?t=split&f=analyze&s=performance">Performance Study</a><br>
            <a href="search.jsp?t=split&f=analyze&s=shower">Shower Study</a><br>
            <a href="search.jsp?t=split&f=analyze&s=">Flux Study</a><br>
            <a href="search.jsp?t=split&f=analyze&s=lifetime">Lifetime Study</a><br>
        </center>
<%
        return;
    }
    else{
        formAction = study + ".jsp";
    }
}


//variables used in metadata searches:
String aname1 = request.getParameter("aname1");
if (aname1 == null) aname1="name";
String input1 = request.getParameter("input1");
if (input1 == null) input1="";
String input2 = request.getParameter("input2");
if (input2 == null) input2="1/1/2004";
String input3 = request.getParameter("input3");
if (input3 == null) input3="12/30/2050";
String sortDirection = request.getParameter("sort_direction");
if (sortDirection == null) sortDirection = "sort_asc";
String q=request.getParameter("q");
String order = request.getParameter("sort_field");
if ((order == null) || (order.equals(""))){
    order = "startdate";
}
%>
<div class="search_quick_links">
    <a href="?t=split&f=<%=searchFunction%>&s=<%=study%>&q=<%=schoolQuery%>&aname1=school&input1=<%=groupSchool%>"><%=groupSchool%></a>
    &nbsp;
    <a href="?t=split&f=<%=searchFunction%>&s=<%=study%>&q=<%=cityQuery%>&aname1=city&input1=<%=groupCity%>"><%=groupCity%></a>
    &nbsp;
    <a href="?t=split&f=<%=searchFunction%>&s=<%=study%>&q=<%=stateQuery%>&aname1=state&input1=<%=groupState%>"><%=groupState%></a>
    &nbsp;
    <a href="?t=split&f=<%=searchFunction%>&s=<%=study%>&q=<%=allQuery%>">Everyone</a>
</div>
<form name="search" method="get">
<input type="hidden" name="t" value="split">
<input type="hidden" name="f" value="<%=searchFunction%>">
<input type="hidden" name="s" value="<%=study%>">
<input type="hidden" name="last_q" value="<%=(q == null ? "" : q)%>">
<INPUT type="hidden" name="q">
<INPUT type="hidden" name="order" value="">


<select name="aname1" onChange="javascript:
if (this.form.aname1.options[this.form.aname1.selectedIndex].value == 'blessed' || 
    this.form.aname1.options[this.form.aname1.selectedIndex].value == 'stacked') {
    this.form.input1.value = 'yes';
} else {
    if (this.form.input1.value == 'yes') {
        this.form.input1.value = '';
    }
}">
    <OPTION value="city"<%if (aname1.equals("city")) {%> selected<%}%>>City</OPTION>	
    <OPTION value="group"<%if (aname1.equals("group")) {%> selected<%}%>>Group</OPTION>	
    <OPTION value="school"<%if (aname1.equals("school")) {%> selected<%}%>>School</OPTION>	
    <OPTION value="state"<%if (aname1.equals("state")) {%> selected<%}%>>State</OPTION>	
    <OPTION value="teacher"<%if (aname1.equals("teacher")) {%> selected<%}%>>Teacher</OPTION>	
    <OPTION value="stacked"<%if (aname1.equals("stacked")) {%> selected<%}%>>Stacked</OPTION>	
    <OPTION value="blessed"<%if (aname1.equals("blessed")) {%> selected<%}%>>Blessed</OPTION>	
    <OPTION value="detectorid"<%if (aname1.equals("detectorid")) {%> selected<%}%>>Detector ID</OPTION>	
</SELECT>
<input type="hidden" name="op1" value="CONTAINS">
<input type="hidden" name="op2" value="=">
<input name="input1" size="40" maxlength="40" value="<%=input1%>">
<input type="submit" name="submit1" value="Search Data" onClick="javascript:
if(search.input1.value == '' && search.input2.value == '' && search.input3.value == ''){
    return false;
}
else{
    var qChoice='type=\'split\' AND project=\'<%=eLab%>\'';
    if (search.input1.value != ''){
        var iname1 = search.aname1.selectedIndex;
        var op1 = search.op1.value;
        var op2 = search.op2.value;
        //var value1 = search.input1.value.toUpperCase();
        //qChoice = qChoice + ' AND UPPER(' + search.aname1[iname1].value + ') ' + op1 + ' \'' + value1 + '\'';
        var value1 = search.input1.value;
        
        if (search.aname1[iname1].value == 'blessed' || search.aname1[iname1].value == 'stacked') {
            if (value1 == 'true' || value1 == 'yes' || value1 == 'YES') value1 = 't';
            if (value1 == 'false' || value1 == 'no' || value1 == 'NO') value1 = 'f';
            qChoice = qChoice + ' AND ' + search.aname1[iname1].value + ' ' + op2 + ' \'' + value1 + '\'';
        } else {
            qChoice = qChoice + ' AND ' + search.aname1[iname1].value + ' ' + op1 + ' \'' + value1 + '\'';
        }
    }
    if(search.input2.value != '' && search.input3.value != ''){
        var iname2 = search.aname2.selectedIndex;
        var value2 = search.input2.value;
        var value3 = search.input3.value;
        qChoice = qChoice + ' AND ' + search.aname2[iname2].value + ' BETWEEN \'' + value2 + '\' AND \'' + value3 + ' 23:59:59\'';
    }
    if (search.input2.value != '' && search.input3.value == '') {
        var iname2 = search.aname2.selectedIndex;
        var value2 = search.input2.value;
        qChoice = qChoice + ' AND ' + search.aname2[iname2].value + ' > \'' + value2 + '\'';
    }
    if (search.input2.value == '' && search.input3.value != '') {
        var iname2 = search.aname2.selectedIndex;
        var value3 = search.input3.value;
        qChoice = qChoice + ' AND ' + search.aname2[iname2].value + ' < \'' + value3 + '\'';
    }
    search.q.value = qChoice;
}
">

<br>
<div id="controlap0" style="visibility:visible; display:">
    <a href="javascript:void(0);" onclick="HideShow('advsearch0');HideShow('controlap0');HideShow('controlap1')">
        <img src="graphics/Tright.gif" alt="" border="0"></a>
        Advanced Search 
</div>
<div id="controlap1" style="visibility:hidden; display:none">
    <a href="javascript:void(0);" onclick="HideShow('advsearch0');HideShow('controlap1');HideShow('controlap0')">
        <img src="graphics/Tdown.gif" alt="" border="0"></a>
        Advanced Search
</div>
<div id="advsearch0" style="visibility:hidden; display:none">
<div id="adv_search">
<table><tr><td align="right">
<select name="aname2">
    <option value="startdate" selected>Start Date</option>
    <option value="creationdate">Upload Date</option>
</select>
</td><td>
<input name="input2" size="10" maxlength="15" value="<%=input2%>">
<font size ="-2">to</font> 
<input name="input3" size="10" maxlength="15" value="<%=input3%>">
</tr><tr><td align="right">
<select name="sort_direction">
    <option value="sort_asc"<%if (sortDirection.equals("sort_asc")) {%> selected<%}%>>Sort Ascending</option>
    <option value="sort_desc"<%if (sortDirection.equals("sort_desc")) {%> selected<%}%>>Sort Descending</option>
</select>
</td><td>
<font size ="-2">by</font>
<select name="sort_field">
    <option value="city"<%if (order.equals("city")) {%> selected<%}%>>City</option>
    <option value="state"<%if (order.equals("state")) {%> selected<%}%>>State</option>
    <option value="stacked"<%if (order.equals("stacked")) {%> selected<%}%>>Geometry</option>
    <option value="blessed"<%if (order.equals("blessed")) {%> selected<%}%>>Blessed</option>
    <option value="group"<%if (order.equals("group")) {%> selected<%}%>>Group</option>
    <option value="year"<%if (order.equals("year")) {%> selected<%}%>>Academic Year</option>
    <option value="detectorid"<%if (order.equals("detectorid")) {%> selected<%}%>>Detector ID</option>
    <option value="creationdate"<%if (order.equals("creationdate")) {%> selected<%}%>>Upload Date</option>
    <option value="chan1"<%if (order.equals("chan1")) {%> selected<%}%>>Channel 1 events</option>
    <option value="chan2"<%if (order.equals("chan2")) {%> selected<%}%>>Channel 2 events</option>
    <option value="chan3"<%if (order.equals("chan3")) {%> selected<%}%>>Channel 3 events</option>
    <option value="chan4"<%if (order.equals("chan4")) {%> selected<%}%>>Channel 4 events</option>
</select> 
</td></tr>
<td align="right" valign="middle">
    <font size="-1">Search:</font>
</td><td>
    <input type="radio" name="searchIn" value="all" checked><font size="-1">All data</font> 
    <input type="radio" name="searchIn" value="within"><font size="-1">Within results</font>
</td><tr>
</table>
</div>
</div>
</form>
</center>


<form id="files_to_analyze" name="analyzeData" method="post" action="<%=formAction%>">
<%
        //if we're analyzing or deleting, output a "submit" button
        String submitButton = "";
        if(searchFunction.equals("analyze")){
            submitButton =  
                "<input type=submit value=\"Run " + study + " study\">";
        }
        else if(searchFunction.equals("delete")){
            submitButton =  
                "<input type=hidden name=type value=" + searchType + ">" +
                "<input type=submit value=\"Delete File(s)\">";
        }

// Display the status message and no analyze button when there is no query.
if(q==null){    //default when no search specified
    String status = (String)application.getAttribute("status_message");
%>
    <div class="status_message">
        <%=status%>
    </div>
<%
}
else {

String searchIn = request.getParameter("searchIn");
if (searchIn != null && searchIn.equals("within")) {
    String lastSearch = request.getParameter("last_q");
    if (lastSearch != null) {
        // Take off redundant information.
        lastSearch = lastSearch.replaceAll("type=\'split\' AND project=\'" + eLab + "\'", "");
        q += lastSearch;
    }
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
            "</font> did not return any results.<br>\n");
    //out.println("<font size=-1>q = " + q);
    return;
}


MetaCompare mc = new MetaCompare();
if (sortDirection != null && sortDirection.equals("sort_desc"))
    mc.setSortDescending();

mc.setSortKey(order);
Collections.sort(lfnsmeta, mc);

//set css class for whatever the order variable is set to
HashMap metaCSS = new HashMap();
metaCSS.put(order, "class=\"orderby\"");

//metadata formatter class instance
MetaFormat mf = new MetaFormat();
%>

<!-- Query results table -->
<%
int schoolCount = 0;
        Integer firstRec = null;
        Integer endRec = null;
        boolean isDisplayPrev = false;
        boolean isDisplayMore = false;
        if(lfnsmeta != null){
            int totalFiles = 0;
            HashMap metaValues = null;
            TreeMap schools = new TreeMap();
            for(Iterator i=lfnsmeta.iterator(); i.hasNext(); ){
                ArrayList pair = (ArrayList)i.next();
                String lfn = (String)pair.get(0);

               totalFiles++;
                        ArrayList metaTuples = (ArrayList)pair.get(1);

                        //create the HashMap of metadata Tuple values
                        metaValues = new HashMap();
                        for(Iterator j=metaTuples.iterator(); j.hasNext(); ){
                            Tuple t = (Tuple)j.next();
                            String key = (String)t.getKey();
                            Object value = t.getValue();

                            metaValues.put(key, value);
                        }
                        metaValues.put("lfnName", lfn);

                        // Get the summary info if we have it, otherwise create it.
                        HashMap schoolSummary = (HashMap)schools.get(metaValues.get("school"));
                        if (schoolSummary == null) { 
                            schoolCount++;
                            schoolSummary = new HashMap();
                            schools.put(metaValues.get("school"), schoolSummary);
                            schoolSummary.put("totalFiles", new Integer(0));
                            schoolSummary.put("blessedFiles", new Integer(0));
                            schoolSummary.put("events", new Integer(0));
                            schoolSummary.put("stackedFiles", new Integer(0));
                            schoolSummary.put("files", new TreeMap());
                        }

                        // Add this file and its associated metadata (by month) to our school list.
                        String [] dateSplitted = ((Date)metaValues.get("startdate")).toString().split("-");
                        String dateCache = dateSplitted[0] + "-" + dateSplitted[1];
                        Vector filesVec = (Vector)((TreeMap)schoolSummary.get("files")).get(dateCache);
                        if (filesVec == null) {
                            filesVec = new Vector();
                            ((TreeMap)schoolSummary.get("files")).put(dateCache, filesVec);
                        }
                        filesVec.add(metaValues);

                        // Increase the total files for this school.
                        schoolSummary.put(
                                "totalFiles",
                                new Integer(((Integer)schoolSummary.get("totalFiles")).intValue() + 1));


                        // Increase the number of blessed files for this school.
                        Boolean blessedState = (Boolean)metaValues.get("blessed"); 
                        if (blessedState != null && blessedState.booleanValue()) {
                            schoolSummary.put(
                                    "blessedFiles",
                                    new Integer(((Integer)schoolSummary.get("blessedFiles")).intValue() + 1));
                        }

                        // Increase the number of events for this school.
                        Long chan1State = (Long)metaValues.get("chan1");
                        Long chan2State = (Long)metaValues.get("chan2");
                        Long chan3State = (Long)metaValues.get("chan3");
                        Long chan4State = (Long)metaValues.get("chan4");
                        if (chan1State != null && chan2State != null && chan3State != null && chan4State != null) {
                            schoolSummary.put(
                                    "events",
                                    new Integer(((Integer)schoolSummary.get("events")).intValue() + 
                                        chan1State.intValue() + //can't wait for autoboxing... 
                                        chan2State.intValue() + 
                                        chan3State.intValue() + 
                                        chan4State.intValue()));
                        }

                        // Increase the number of stacked files for this school.
                        Boolean stackedState = (Boolean)metaValues.get("stacked");
                        if (stackedState != null && stackedState.booleanValue()) {
                            schoolSummary.put(
                                    "stackedFiles",
                                    new Integer(((Integer)schoolSummary.get("stackedFiles")).intValue() + 1));
                        }

                        // Set the city once.
                        if (!schoolSummary.containsKey("city"))
                            schoolSummary.put("city", metaValues.get("city"));
                        // Set the state once.
                        if (!schoolSummary.containsKey("state"))
                            schoolSummary.put("state", metaValues.get("state"));
            } // end lfn files for-loop
            Set keyset = schools.keySet();
            Locale enLocale = new Locale("en", "US");
            if (startRecord != null)
                firstRec = new Integer(startRecord);
            else
                firstRec = new Integer(1);
            endRec = (keyset.size() < firstRec.intValue() + 9) ? 
                new Integer(keyset.size()) : new Integer(firstRec.intValue() + 9);
            isDisplayPrev = firstRec.intValue() > 1;
            isDisplayMore = endRec.intValue() < keyset.size();
            String searchString = null;
            if (input1 == null || input1.equals("")) 
                searchString = "All Data";
            else
                searchString = input1;
            
            Double searchTime = new Double((double)(System.currentTimeMillis() - pageStartTime)/(double)1000);
%>
            <div class="search_result_bar">
                Results <strong><%=firstRec%> - <%=endRec%></strong> 
                of <strong><%=keyset.size()%></strong> for <%=schools.size()%> Schools <strong><%=searchString%></strong> 
                (Searched <strong><%=totalFiles%></strong> files in <strong><%=searchTime%></strong> seconds)
            </div>
<%
            // Iterate through the schools list and display pertinent information.
            int counter = 0;
            int selectAllFileCounter = 0;
            Iterator it = keyset.iterator();
            while (it.hasNext()) {
                counter++;

                if (counter < firstRec.intValue()) {
                    it.next();
                    continue;
                }
                else if (counter > endRec.intValue())
                    break;

                String schoolName = (String)it.next();    
                HashMap schoolSummary = (HashMap)schools.get(schoolName); 

                Object blessed, stacked, events;
                blessed = schoolSummary.get("blessedFiles") == null ? new Integer(0) : schoolSummary.get("blessedFiles");
                stacked = schoolSummary.get("stackedFiles") == null ? new Integer(0) : schoolSummary.get("stackedFiles");
                events = schoolSummary.get("events") == null ? new Integer(0) : schoolSummary.get("events");
%>
                <!-- checkbox/radio/nothing for shower-flux-lifetime/performance/view respectively -->
                <div class="search_top_result">
                    <div id="<%=schoolName.replaceAll(" ","")%>_closed" style="visibility:visible; display:">
                        <a href="javascript:void(0);" onclick="HideShow('<%=schoolName.replaceAll(" ","")%>_files');HideShow('<%=schoolName.replaceAll(" ","")%>_closed');HideShow('<%=schoolName.replaceAll(" ","")%>_open')">
                            <img src="graphics/Tright.gif" alt="" border="0"></a>
                            <%=schoolName%> 
                    </div>
                    <div id="<%=schoolName.replaceAll(" ","")%>_open" style="visibility:hidden; display:none">
                        <a href="javascript:void(0);" onclick="HideShow('<%=schoolName.replaceAll(" ","")%>_files');HideShow('<%=schoolName.replaceAll(" ","")%>_open');HideShow('<%=schoolName.replaceAll(" ","")%>_closed')">
                            <img src="graphics/Tdown.gif" alt="" border="0"></a>
                            <%=schoolName%>
                    </div>
                </div>
                <div class="search_sub_results">
                    <%=schoolSummary.get("city")%>, <%=schoolSummary.get("state")%><br>
                </div>
                <div class="search_files_results">
                    <%=schoolSummary.get("totalFiles")%> data files: <%=blessed%> blessed, <%=stacked%> stacked, 
                    <%=java.text.NumberFormat.getNumberInstance(enLocale).format(events)%> total events.<br><br>
                <div id="<%=schoolName.replaceAll(" ","")%>_files" style="visibility:hidden; display:none">
                    <div class="search_files_results_choose">
<%
                        TreeMap files = (TreeMap)schoolSummary.get("files");
                        Iterator i = files.keySet().iterator();
                        while (i.hasNext()) {
                            String date = (String)i.next();
                            String[] dateSplit = date.split("-");
                            String monthYear = month_name(Integer.parseInt(dateSplit[1])) + " " + dateSplit[0];
                            Vector individualFiles = (Vector)files.get(date);
                            date = date.replaceAll("-", "");
%>                             
                            <div class="search_month_group">
                                <div id="<%=schoolName.replaceAll(" ","")+date%>_closed" style="visibility:visible; display:">
                                    <a href="javascript:void(0);" onclick="HideShow('<%=schoolName.replaceAll(" ","")+date%>_files');HideShow('<%=schoolName.replaceAll(" ","")+date%>_closed');HideShow('<%=schoolName.replaceAll(" ","")+date%>_open')">
                                        <img src="graphics/Tright.gif" alt="" border="0"></a>
                                        <%=monthYear%> <font style="padding-left:5px; font-size:x-small;"><%=individualFiles.size()%> file<%if (individualFiles.size() > 1){%>s<%}%> </font>
                                </div>
                                <div id="<%=schoolName.replaceAll(" ","")+date%>_open" style="visibility:hidden; display:none">
                                    <a href="javascript:void(0);" onclick="HideShow('<%=schoolName.replaceAll(" ","")+date%>_files');HideShow('<%=schoolName.replaceAll(" ","")+date%>_open');HideShow('<%=schoolName.replaceAll(" ","")+date%>_closed')">
                                        <img src="graphics/Tdown.gif" alt="" border="0"></a>
                                        <%=monthYear%>
<%
                                        // We can only select all if the study is not performance.
                                        if (!study.equals("performance") && individualFiles.size() > 1) {
%>
                                        <font style="text-align:right; padding-left:5px; font-size:x-small;"><input type="checkbox" name="selectall" onclick="selectAll(this.form,0,<%=selectAllFileCounter%>,<%=selectAllFileCounter+individualFiles.size()+1%>);">select all <%=individualFiles.size()%> files</font>
<%
                                            selectAllFileCounter += individualFiles.size() + 1;
                                        } else {
                                            selectAllFileCounter++;
%>
                                            <font style="color:#000; padding-left:5px; font-size:x-small;"><%=individualFiles.size()%> file<%if (individualFiles.size() > 1){%>s<%}%> </font>
<%
                                        }
%>
                                </div>
                            </div>
                            <div id="<%=schoolName.replaceAll(" ","")+date%>_files" style="visibility:hidden; display:none">
                                <div class="search_month_group_files">
                                    <table width="420" cellspacing="0" cellpadding="5" border="0">
<%                            
                            Iterator ii = individualFiles.iterator();
                            int fileNum = 0;
                            while (ii.hasNext()) {
                                HashMap meta = (HashMap)ii.next();
                                //checkbox or radio:
                                String selector = "";
                                if(searchFunction.equals("delete")){
                                    selector = "<input type=checkbox name='filename' value=" + meta.get("lfnName") + ">";
                                }
                                else if(!searchFunction.equals("view")){
                                    if(study.equals("performance")){
                                        selector = "<input type=radio name=f value=" + meta.get("lfnName") + ">";
                                    }
                                    else{
                                        selector = "<input type=checkbox name=f value=" + meta.get("lfnName") + ">";
                                    }
                                }
                                if (fileNum % 3 == 0) {
                                    if (fileNum != 0) {
                                        if (fileNum % 6 == 0) {
                                            out.write("</tr><tr>");
                                        } else {
                                            out.write("</tr><tr bgcolor=\"#edf4ff\">");
                                        }
                                    } else {
                                        out.write("<tr>");
                                    }
                                }
                                
                                String colSpan = "";
                                if (fileNum == individualFiles.size() - 1) {
                                    int leftOver = fileNum % 3;
                                    if (leftOver != 2)
                                        colSpan = " colspan=\"" + (3-leftOver) + "\""; 
                                }
                                else {
                                    colSpan = " width=\"140\"";
                                }
                                String titleText = 
                                    "Group: " + meta.get("group") +
                                    " -  Start Time: " + ((Date)meta.get("startdate")).toString().substring(11, 16) +
                                    " -  Upload Date: " + mf.pickMeta("creationdate", meta.get("creationdate"));
                                    //(((Long)meta.get("chan1")).intValue() > 0 ? " | Channel 1: " + meta.get("chan1") + " events" : "") +
                                    //(((Long)meta.get("chan2")).intValue() > 0 ? " | Channel 2: " + meta.get("chan2") + " events" : "") +
                                    //(((Long)meta.get("chan3")).intValue() > 0 ? " | Channel 3: " + meta.get("chan3") + " events" : "") +
                                    //(((Long)meta.get("chan4")).intValue() > 0 ? " | Channel 4: " + meta.get("chan4") + " events" : ""); 

                                out.write(
                                    "<td align=\"left\" valign=\"center\"" + colSpan + ">" +
                                    "<table width=\"140\"><tr><td width=\"70\" align=\"left\"><font style=\"font-size:x-small; color:#666;\">" + 
                                    selector + " " + 
                                    "<a href=\"view.jsp?filename=" + meta.get("lfnName")+ "&type=data&get=data\"" +
                                    " title=\"" + titleText + "\">" + mf.pickMeta("startdate", meta.get("startdate")) + 
                                    "</a></font></td><td width=\"70\" align=\"left\" valign=\"center\">" + 
                                    "<a href=\"addComments.jsp?fileName=" + meta.get("lfnName") + "&t=split\" title=\"Add/View comments\">" + 
                                    "<img src=\"graphics/balloon_talk_gray.gif\" border = \"0\"></a>" +   
                                    "<A HREF=\"javascript:glossary('geometry',200)\" title=\"Stacked/Unstacked\">"+
                                    mf.pickMeta("stacked", meta.get("stacked")) + "</a><a title=\"Blessed\">" +
                                    mf.pickMeta("blessed", meta.get("blessed")) + "</a></td></tr></table>");  
                                fileNum++;
                            }
                            out.write("</tr></table></div>\n</div>");
                        }
%>
                    </div>
                </div>
            </div>
<%
            }   //for loop
        }   //lfns not null

%>
        <table>
            <tr width="600">
                <td width="300" align="left">
                    <p align="left">
                        <font size="-1">
<%
                        if (isDisplayPrev) {
%>
                        <br>
                        <a href="?t=split&f=<%=searchFunction%>&s=<%=study%>&q=<%=q%>&sr=<%=firstRec.intValue() - 10%>">&lt;&lt;previous results</a>
<%
                        } else {
%>                      
                        &nbsp;
<%
                        }
%>
                        </font>
                    </p>
                </td>
                <td width="300" align="right">
                    <p align="right">
                        <font size="-1">
<%
                        if (isDisplayMore) {
%>
                        <br>
                        <a href="?t=split&f=<%=searchFunction%>&s=<%=study%>&q=<%=q%>&sr=<%=endRec.intValue() + 1%>">more results>></a>
<%
                        } else {
%>                      
                        &nbsp;
<%
                        }
%>
                        </font>
                    </p>
                </td>
            </tr>
        </table>
<%
} // end massive else statement when checking for null query.
%>
</div>
<div id="help">
    <strong>Help</strong><br><br>
    <A HREF="<%=tutorialName%>">Tutorial on <%=study%> study</A><br>
    <br>
    <A HREF="tryit_<%=study%>.html" onclick="javascript:openPopup('tryit_<%=study%>.html','TryIt',520,600); return false;">Step-by-Step Instructions</A>
    <br>
    <br>
    <strong>Analyze</strong>
    <br>
    <p align="left"><%=submitButton%></p>
    <br>
    <strong>Legend</strong><br>
    <br>
    <table border=0 cellpadding=3><tr><td align="right">
    <img src="graphics/unstacked.gif" border=0></td><td align="left"><div class="help_text">Unstacked data</div></td></tr>
    <tr><td align="right"><img src="graphics/stacked.gif" border=0></td><td align="left"><div class="help_text">Stacked data</div></td></tr>
    <tr><td align="right"><img src="graphics/star.gif" border=0></td><td align="left"><div class="help_text">Blessed data</div></td></tr>
    <tr><td align="right"><img src="graphics/balloon_talk_gray.gif" border=0></td><td align="left"><div class="help_text">Add/View comments</div></td></tr>
    </table>
    <br>
    </div>
</form>
