<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.vds.*" %>
<%@ page import="gov.fnal.elab.cosmic.beans.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.beans.*" %>
<%@ page contentType="text/html" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="x" uri="http://java.sun.com/jsp/jstl/xml" %>
<%@ include file="common.jsp" %>
<%@ include file="include/javascript.jsp" %>

<html>
<head>
<title>Raw Datafile Analysis</title>

    <!-- include css style file -->
    <%@ include file="include/style.css" %>
    <!-- header/navigation -->
    <%
    //be sure to set this before including the navbar
    String headerType = "Data";
    %>
    <%@ include file="include/navbar_common.jsp" %>
    <%-- navbar_common closes the <head> tag --%>

<body>
<br>

<jsp:useBean id="analyze" scope="request" class="gov.fnal.elab.cosmic.beans.RawAnalyze" />

<%
String lfn = request.getParameter("filename");

if((analyze.getGatewidth()).equals("")){
    analyze.setGatewidth("240");
}

//get metadata for input file
java.util.List lfnmeta = getMeta(lfn);
if(lfnmeta.size() == 0){
    out.write("<font color=red>No file associated with: " + lfn + "</font><br>\n");
}
HashMap metaMap = new HashMap();
for(Iterator metai=lfnmeta.iterator(); metai.hasNext(); ){
    Tuple t = (Tuple)metai.next();
    metaMap.put(t.getKey(), t.getValue());
}

String dataOutputDir = dataDir + metaMap.get("detectorid");
analyze.setInFile(lfn);

//set .analyze output file
String lfnAnalyze = lfn + ".analyze";
String analyzeFile = dataOutputDir + "/" + lfnAnalyze;
analyze.setOutFile(analyzeFile);

//determine if the .analyze file already exists
File f = new File(analyzeFile);
if(f.exists()){
    //don't recalculate
}
else{
    ElabTransformation et = new ElabTransformation("Quarknet.Cosmic::RawAnalyzeStudy");

    runDir = runDir.substring(0, runDir.length()-1);    //FIXME: runDir has a trailing / on it
    et.generateOutputDir(runDir);
    et.createDV(analyze);
    java.util.List nulllist = et.getNullKeys();
    if(!nulllist.isEmpty()){
        out.println("There are keys which you must define before running the Derivation:<br>\n");
        for(Iterator i = nulllist.iterator(); i.hasNext(); ){
            String ss = (String)i.next();
            out.println("null keys: " + ss);
        }
        out.println("<br><br>bailing out!");
        return;
    }


    //run the actual shell scripts
    try{
        et.run();
    } catch (ElabException e){
        out.println("rawanalyzeOutput Exception: " + e.getMessage());
        return;
    }
    et.dump();

    et.close();

    //Metadata section
    //there seems to be an unwritten rule to use lowercase for metadata...
    //pass any arguments to write as metadata in the "metadata" form variable as tuple strings

    //add entry into rc.data
    boolean RCUpdated = addRC(lfnAnalyze, analyzeFile);
    if(RCUpdated){
        ArrayList meta = new ArrayList();

        Date now = new Date();
        long millisecondsSince1970 = now.getTime();
        java.sql.Timestamp timestamp = new java.sql.Timestamp(millisecondsSince1970);
        meta.add("transformation string Quarknet.Cosmic::RawAnalyzeStudy");
        meta.add("creationdate date " + timestamp.toString());
        meta.add("source string " + lfn);
        meta.add("gatewidth int " + analyze.getGatewidth());
        meta.add("name string " + lfnAnalyze);

        //path data
        meta.add("city string " + groupCity);
        meta.add("group string " + groupName);
        meta.add("project string " + eLab);
        meta.add("school string " + groupSchool);
        meta.add("state string " + groupState);
        meta.add("teacher string " + groupTeacher);
        meta.add("year string " + groupYear);

        boolean metaUpdated = setMeta(lfnAnalyze, meta);
        if(!metaUpdated){
%>
            <b>Something's awry! Metadata was not saved for <%=lfnAnalyze%></b><br>
<%
        }
        else{
            //add name to metadata of lfn the raw data was derived from
            ArrayList meta2 = new ArrayList();
            meta2.add("rawanalyze string " + lfnAnalyze);
            boolean metaUpdated2 = setMeta(lfn, meta2);
            if(!metaUpdated2){
%>
                <b>Something's awry! Metadata was not saved for <%=lfn%></b><br>
<%
            }
        }
    }
}
%>

<c:import url="rawanalyze.xsl" var="stylesheet" />
<x:transform xslt="${stylesheet}">
<%
f = new File(analyzeFile);
BufferedReader br = new BufferedReader(new FileReader(f));
String str = null;
while((str = br.readLine()) != null){
    out.println(str);
}
%>
</x:transform>

<p align="center">
</p>

</body>
</html>
