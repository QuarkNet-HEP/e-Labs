<%@ page buffer="1000kb" %>
<%@ page import="org.griphyn.vdl.toolkit.VizDAX" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.vds.*" %>
<%@ page import="gov.fnal.elab.cosmic.beans.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.beans.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="common.jsp" %>

<!-- this page is for analysis ONLY. The next page which this forards to displays -->
<!-- the resulting images (so we dont need to call the full ShowerStudy TR again -->


<html>
<head>
<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Data";
%>
<%@ include file="include/navbar_common.jsp" %>

<body>

<jsp:useBean id="shower" scope="session" class="gov.fnal.elab.cosmic.beans.ShowerBean" />
<%
//replace new lines from any text boxes with "\n"
String caption = shower.getPlot_caption();
caption = caption.replaceAll("\r\n?", "\\\\n");
shower.setPlot_caption(caption);

String snen = request.getParameter("setNewEventNum");
if(snen != null && snen.equals("1")){
    shower.setEventNum("1");    //arbitrarily set to 1 here so the shower bean is valid. will choose a better value after analysis
}


ElabTransformation et = new ElabTransformation("Quarknet.Cosmic::ShowerStudy");

runDir = runDir.substring(0, runDir.length()-1);    //FIXME: runDir has a trailing / on it
et.generateOutputDir(runDir);
et.createDV(shower);

//dvName is created for passing to save.jsp
String fullOutputDir = et.getOutputDir();
String outputDir = fullOutputDir.substring(fullOutputDir.lastIndexOf("/") + 1);
//String dvName = groupName + "-" + outputDir;
//et.setDVName(dvName);

java.util.List nulllist = et.getNullKeys();
if(!nulllist.isEmpty()){
    out.println("There are still keys in the Transformation which must be defined:<br>\n");
    for(Iterator i = nulllist.iterator(); i.hasNext(); ){
        String ss = (String)i.next();
        out.println("null keys: " + ss + "<br>");
    }
    out.println("<br><br>bailing out!");
    return;
}

// Hack to get shower jobs to run on the grid for Wales.
String computeLocation = request.getParameter("compute_location");
if (computeLocation.equals("grid")) {
    //et.generateOutputDir("/usr/local/quarknet-test/portal/grid");
    et.dumpForGrid();
    String[] cmd0 = new String[] {
        "bash", 
        "-c", 
        "cp /usr/local/quarknet-test/portal/grid/qrun.sh /usr/local/quarknet-test/portal/grid/prepare_qjob.pl " +
        "/usr/local/quarknet-test/portal/grid/monitor_qjob.pl " + et.getOutputDir()};
    Process p0 = Runtime.getRuntime().exec(cmd0);
    int c0 = p0.waitFor();
    //String[] cmd = new String[] {"bash", "-c", "cd " + et.getOutputDir() + "; ./qrun.sh dv.dax " + user + " \"Shower Study\""};
    //Process p = Runtime.getRuntime().exec(cmd);
    //// should return within about 6-7 seconds. watch for standard out.
    //int c = p.waitFor();
%>
    <jsp:forward page="myJobs.jsp"/>
<%
}

//run the actual shell scripts
try{
    out.println("Running analysis...<br><br>");
    out.flush();
    et.run(out);
} catch(ElabShellException e){
%>

    <!-- TODO: remove sometime or another... -->
    <!-- fullOutputDir: <%=et.getOutputDir()%> -->

    <p align="center">Analysis error...
    <%=e.getMessage().replaceAll("\\n", "\n<br>")%>
    </p>
    <p align="center">
    Please <a href="shower.jsp?plot_size=<%=request.getParameter("plot_size")%>&submit=Change">change</a> your parameters.
<%
    return;
}
et.dump();

et.close();

//if the run completes with no exception, then it was valid

String eventNum = null;
//if we need to set a new eventNum
if(snen != null && snen.equals("1")){
    //find the "most interesting" event (one with highest event coincidence)
    String eventCandidates = et.getDVValue("eventCandidates");
    runDir = runDir.substring(0, runDir.length()-1);    //FIXME: runDir has a trailing / on it
    File ecFile = new File(fullOutputDir + "/" + eventCandidates);
    BufferedReader br = new BufferedReader(new FileReader(ecFile));

    String str = null;
    while((str = br.readLine()) != null){
        if(str.matches("^.*#.*")){
            continue;   //ignore comments in the file
        }
        String arr[] = str.split("\\s");
        eventNum = arr[0];
        break;
    }
}
else{
    eventNum = shower.getEventNum();
}

//parameter creation for next page link
String params = "";
params += "outputDir=" + outputDir;
params += "&eventCandidates=" + et.getDVValue("eventCandidates");
params += "&eventNum=" + eventNum;
params += "&eventStart=1";
params += "&plot_size=" + request.getParameter("plot_size");
params += "&groupStart=1";
%>

Analysis done. <a href="showerPlot.jsp?<%=params%>">Click for results</a>

</body>
</html>
