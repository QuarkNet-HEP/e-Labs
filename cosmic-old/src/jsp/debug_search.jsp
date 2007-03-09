<%@ page buffer="1000kb" %>
<%@ include file="common.jsp" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
<TITLE>Cosmics Data Interface</TITLE>

<% 
//q = type='split' AND project='cosmic' AND city='Batavia'

String q = request.getParameter("q");
String qq = "";
if(q == null){
    q = "city='Batavia' AND state='IL'";
}
if(q.equals("")){
    qq = "type='split' AND project='cosmic'";
}
else{
    qq = "type='split' AND project='cosmic' AND " + q;
}
String study = request.getParameter("study");
if(study == null){
    study = "flux";
}
String checked1 = "";
if(study == "performance"){
    checked1 = "checked ";
}
String checked2 = "";
if(study == "flux"){
    checked2 = "checked ";
}
String checked3 = "";
if(study == "lifetime"){
    checked3 = "checked ";
}
String checked4 = "";
if(study == "shower"){
    checked4 = "checked ";
}

%>

Current Study: <font color="red"><%=study%></font><br>
<form method="get">
<input type=radio name=study value="performance" <%=checked1%>>Performance
<input type=radio name=study value="flux" <%=checked2%>>Flux
<input type=radio name=study value="lifetime" <%=checked3%>>Lifetime
<input type=radio name=study value="shower" <%=checked4%>>Shower
<input type="text" name="q" value="<%=q%>" size="100"><br>
Other possible search additions: city='Batavia', state='IL', group='fermigroup', school='Fermilab', startdate >= '2003-08-08'<br>
<input type="submit">
</form>

<br>
<font color="green">Select below, and click "submit files for analysis" at the bottom<br><br></font>
<%

//perform the metadata search
ArrayList lfnsmeta = null;
lfnsmeta = getLFNsAndMeta(out, qq);
if(lfnsmeta == null){
    out.println("No results <font size=-1>q = " + q);
    return;
}

//dead files, don't display
File file = new File("/home/nepywoda/debug_deadfiles.txt");
BufferedReader br = new BufferedReader(new FileReader(file));
HashSet set = new HashSet();
String str;
while((str = br.readLine()) != null){
    set.add(str);
}

%>

<form method="get" action="<%=study%>.jsp">

<%


for(Iterator i=lfnsmeta.iterator(); i.hasNext(); ){
    ArrayList pair = (ArrayList)i.next();
    String lfn = (String)pair.get(0);

    //sanity testing
    /*
     * the following takes a LONG time for disk access
     */
    /*
    String pfn = getPFN(lfn);
    if(pfn == null){
        out.println("null-lfn:" + lfn + "<br>");
        continue;
    }
    File test_file = new File(pfn);
    if(!test_file.canRead()){
        out.println("nophysical-lfn:" + lfn + "<br>");
        continue;
    }
    */
    //the following is a hack fix
    if(set.contains(lfn)){
        out.println("blah" + lfn);
        continue;
    }

    //create the HashMap of metadata Tuple values
    ArrayList metaTuples = (ArrayList)pair.get(1);
    HashMap metaValues = new HashMap();
    for(Iterator j=metaTuples.iterator(); j.hasNext(); ){
        Tuple t = (Tuple)j.next();
        String key = (String)t.getKey();
        Object value = t.getValue();

        metaValues.put(key, value);
    }
    metaValues.put("lfnName", lfn);

    //out.print("lfn: " + lfn + " ");
    out.print("<input type=checkbox name=f value=" + lfn + ">");
    out.print("school: " + metaValues.get("school") + " ");
    out.print("date: " + metaValues.get("startdate") + " ");
    out.print("city/state: " + metaValues.get("city") + "," + metaValues.get("state") + " ");
    out.println("<br>");
}
%>

<input type="submit" value="submit files for analysis">
</form>

</body>
</html>
