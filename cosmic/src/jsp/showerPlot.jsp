<%@ page buffer="1000kb" %>
<%@ page import="org.griphyn.vdl.toolkit.VizDAX" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="org.apache.batik.transcoder.image.PNGTranscoder" %>
<%@ page import="org.apache.batik.transcoder.TranscoderInput" %>
<%@ page import="org.apache.batik.transcoder.TranscoderOutput" %>
<%@ page import="gov.fnal.elab.vds.*" %>
<%@ page import="gov.fnal.elab.cosmic.beans.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.beans.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
//redirect if page is called and the shower bean is not already setup
Object o = pageContext.getAttribute("shower", PageContext.SESSION_SCOPE);
if(o == null){ 
    response.sendRedirect("http://" + System.getProperty("host")+System.getProperty("port") + "/elab/cosmic/search.jsp");
    return;
}
%>
<%@ include file="common.jsp" %>
<jsp:useBean id="shower" scope="session" class="gov.fnal.elab.cosmic.beans.ShowerBean" />

<html>
<head>
<title>Shower Study Analysis Results</title>

<!-- include javascript, css, and Apple popup code -->
<%@ include file="include/javascript.jsp" %>
<%@ include file="include/style.css" %>
<script src="include/apple_utility.txt"></script>
<script src="include/apple_popup.txt"></script>

<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Data";
%>
<%@ include file="include/navbar_common.jsp" %>
<body>

<%
//parameter variables
String outputDir = request.getParameter("outputDir");
String fullOutputDir = runDir + outputDir;
String eventCandidates = request.getParameter("eventCandidates");
String eventNum = request.getParameter("eventNum");
//sorting variables...
String sortCol = request.getParameter("sort");
String sort_ascS = request.getParameter("sort_asc");
boolean sort_asc = false;
if(sort_ascS != null && !sort_ascS.equals("")){
    sort_asc = sort_ascS.equals("true") ? true : false;
}
//default sort column by number of events (starts at 0)
if(sortCol == null){
    sortCol = "1";
}

//bean needs to be updated if the user chooses a new eventNum
shower.setEventFile("eventNum" + eventNum);
shower.setPlot_outfile_image("outsvg" + eventNum + ".svg");
shower.setEventNum(eventNum);

//first event to list
String eventStart = request.getParameter("eventStart");
if(eventStart == null){
    eventStart = "1";
}

String pixelHeight = request.getParameter("plot_size");
String thumbHeight = "150";

String plotName = shower.getPlot_outfile_image();                       //event specific plot
String plotDataName = shower.getEventFile();;                           //event specific plot datapoints
String pngPlotName = plotName.replaceAll("\\.svg", "\\.png");           //for metadata
String thumbPngPlotName = plotName.replaceAll("\\.svg", "_thm.png");    //for metadata
//String fullSizeURL = runDirURL + outputDir + "/" + pngPlotName;         //unused
String fullSizePath = fullOutputDir + "/" + pngPlotName;                //for svg2png
String thumbPath = fullOutputDir + "/" + thumbPngPlotName;              //for svg2png
String thumbPathURL = runDirURL + outputDir + "/" + thumbPngPlotName;   //for img src

ElabTransformation et = null;

//only run the EventPlot TR if it needs to create a new image
File plotFile = new File(fullSizePath);
if(!plotFile.exists()){
    //I certainly could have used a Bean here, but decided not to...
    HashMap h = new HashMap();
    h.put("eventCandidates", fullOutputDir + "/" + eventCandidates);    //should be the same name as the Shower Bean
    h.put("eventFile", "eventNum" + eventNum);
    h.put("eventNum", eventNum);
    h.put("geoDir", dataDir);
    h.put("plot_caption", shower.getPlot_caption());
    h.put("extraFun_out", shower.getExtraFun_out());
    h.put("plot_highX", shower.getPlot_highX());
    h.put("plot_highY", shower.getPlot_highY());
    h.put("plot_highZ", shower.getPlot_highZ());
    h.put("plot_lowX", shower.getPlot_lowX());
    h.put("plot_lowY", shower.getPlot_lowY());
    h.put("plot_lowZ", shower.getPlot_lowZ());
    h.put("plot_outfile_param", shower.getPlot_outfile_param());
    h.put("plot_outfile_image", plotName);
    h.put("plot_plot_type", shower.getPlot_plot_type());
    h.put("plot_title", shower.getPlot_title());
    h.put("plot_xlabel", shower.getPlot_xlabel());
    h.put("plot_ylabel", shower.getPlot_ylabel());
    h.put("plot_zlabel", shower.getPlot_zlabel());
    h.put("zeroZeroZeroID", shower.getZeroZeroZeroID());

    et = new ElabTransformation("Quarknet.Cosmic::EventPlot");

    et.setOutputDir(fullOutputDir);

    et.createDV(h);
    java.util.List nulllist = et.getNullKeys();
    if(!nulllist.isEmpty()){
        out.println("There are still keys in the Transformation which must be defined:<br>\n");
        for(Iterator i = nulllist.iterator(); i.hasNext(); ){
            String ss = (String)i.next();
            out.println("null keys: " + ss + "<br>");
        }
        out.println("<br><br>bailing out! (you should contact the administrator about this error)");
        return;
    }


    //run the actual shell scripts
    et.run();
    et.dump();

    et.close();


    out.println("<!-- rundir: " + fullOutputDir + "-->");


    // Convert svg image to png, also create a png thumbnail image

    svg2png(fullOutputDir + "/" + plotName, fullSizePath, thumbPath, pixelHeight, thumbHeight);
}
%>


<%
//event candidate file
File ecFile = new File(fullOutputDir + "/" + eventCandidates);
BufferedReader br = new BufferedReader(new FileReader(ecFile));

//get the list of datafiles we're analyzing
java.util.List rawData = shower.getRawData();
String filenames = "";
for(Iterator i=rawData.iterator(); i.hasNext(); ){
    String s = (String)i.next();
    filenames += "filename=" + s + "&";
}

java.util.Date eventDate = new java.util.Date();   //date of event currently displayed in the image/plot
//date/time formatter
java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMM d, yyyy H:m:s z");
sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
//link to view the raw data
String viewRawData = "";
//save the list of IDs which participated in any event for the creation of popup javascript windows
HashSet participating_ids = new HashSet();
//save all events from eventStart into an array
ArrayList event_table = new ArrayList();
int start = Integer.parseInt(eventStart);
String str = null;
int line = 0;   //number of lines in the event candidates file
int BLARGH = 0;
while((str = br.readLine()) != null){
    if(str.matches("^.*#.*")){
        continue;   //ignore comments in the file
    }
    line++;
    if(line < start){
        continue;
    }
    String[] arr = str.split("\\s");
    String currEventNum = arr[0];
    Integer eventCoincidence = Integer.valueOf(arr[1]);
    String numDetectors = arr[2];
    String jd = arr[4];
    String partial = arr[5];
    
    //make a list of detector ids which hit in this shower
    HashSet ids = new HashSet();
    for(int i=3; i<arr.length; i = i+3){
        String[] IDChan = arr[i].split("\\.");
        ids.add(IDChan[0]);
        participating_ids.add(IDChan[0]);
    }
    String idList = "";
    for(Iterator i=ids.iterator(); i.hasNext(); ){
        String id = (String)i.next();
        idList += "<a href=\"id_info_no_page.html\" class=popupLink onclick=\"return !showPopup('" + id + "Popup', event);\">" + id + "</a> ";
    }
    idList = idList.trim();
    
    //get the date and time of the shower
    int date[] = jd_to_gregorian(Integer.parseInt(jd), Double.valueOf(partial).doubleValue());
    GregorianCalendar gc = new GregorianCalendar(TimeZone.getTimeZone("GMT"));
    gc.set(date[2], date[1]-1, date[0], date[3], date[4], date[5]);
    //chop the decimal place off INSTEAD OF rounding to nearest second (makes times look off)
    if(/*(date[5] == 50) && (date[4] == 46) && (date[3] == 3)*/BLARGH == 0){BLARGH = date[6];}
    //int secRounded = Math.round((float)date[6]/1000);
    //gc.add(Calendar.SECOND, secRounded);
    Date d = gc.getTime();

    //create the array of the current row and add to the table array
    //elements 0-2 are data
    //elements 3-5 are other data to print as well, but are not part of the sorting algorithm
    //element 6 is the event number (string)
    ArrayList row = new ArrayList(7);
    row.add(0, d);
    row.add(1, eventCoincidence);
    row.add(2, numDetectors);
    row.add(3, "<a href=showerPlot.jsp?sort=" + sortCol + "&sort_asc=" + sort_asc + "&outputDir=" + outputDir + "&eventCandidates=" + eventCandidates + "&eventNum=" + currEventNum + "&plot_size=" + pixelHeight + "&eventStart=" + start + ">");
    row.add(4, "");
    row.add(5, " (" + idList + ")");
    row.add(6, currEventNum);
    
    event_table.add(row);

    //setup variables needed for showing raw data of current plot
    if(currEventNum.equals(eventNum)){
        eventDate = d;
        viewRawData = "<font size=-1>view raw data for " + sdf.format(d) +" for<br>detector ID: ";
        for(Iterator i=ids.iterator(); i.hasNext(); ){
            String id = (String)i.next();

            String event_lfn = lfn_from_date(Integer.parseInt(id), d);
            if(event_lfn != null){
                Calendar c = new GregorianCalendar(TimeZone.getTimeZone("GMT"));
                c.setTime(d);
                int hour = c.get(Calendar.HOUR_OF_DAY);
                int min = c.get(Calendar.MINUTE);
                int sec = c.get(Calendar.SECOND) - 1; //quick kludge to fix the offset problems that happen going from the shower event to the raw data (see Mantis entry)

                viewRawData += "(<a href=view.jsp?filename=" + event_lfn + "&type=data&get=data&h=" + hour + "&m=" + min + "&s=" + sec + ">" + id + "</a>) ";
            }
        }
    }
}

SortByColumn sbc = new SortByColumn(Integer.parseInt(sortCol));
if(!sort_asc){
    sbc.sortDescending();
}
Collections.sort(event_table, sbc);

//passthrough variable needed when linking from this page back to itself for different sort columns
String pt = "outputDir=" + outputDir + "&eventCandidates=" + eventCandidates + "&eventNum=" + eventNum + "&plot_size=" + pixelHeight + "&eventStart=" + start;
%>

<center>
<font size="+1">Shower Study Candidates (<%=BLARGH%>)</font><br><br>
<table cellspacing="0" cellpadding="2" border="1">
    <tr>
        <td valign="top">
            <table cellspacing="0" cellpadding="2" border="0">
                <tr>
                    <td align="center">
                        <a href="?sort=0&sort_asc=<%=!sort_asc%>&<%=pt%>">Event Date</a>
                    </td>
                    <td align="center">
                        <a href="?sort=1&sort_asc=<%=!sort_asc%>&<%=pt%>">Event Coincidence</a>
                    </td>
                    <td align="center">
                        <a href="?sort=1&sort_asc=<%=!sort_asc%>&<%=pt%>">Detector Coincidence</a>
                    </td>
                </tr>
<%
//list top 30 events
int j;
for(j=0;j<event_table.size() && j<30; j++){
    ArrayList curr = (ArrayList)event_table.get(j);
    String col1 = (String)curr.get(3) + sdf.format((Date)curr.get(0)) + "</a>";
    String col2 = ((Integer)curr.get(1)).toString();
    String col3 = (String)curr.get(2) + (String)curr.get(5);
    String currEventNum = (String)curr.get(6);
    String color;
    //Alternating Row Colors (http://time-tripper.com/uipatterns/index.php?page=Alternating_Row_Colors)
    if(currEventNum.equals(eventNum)){
        color = "#aaaafc";
    }
    else if(line%2 == 0){
        color = "#e7eefc";
    }
    else{
        color = "#ffffff";
    }
%>
                    <td align="center" bgcolor="<%=color%>">
                        <%=col1%>
                    </td>
                    <td align="center" bgcolor="<%=color%>">
                        <%=col2%>
                    </td>
                    <td align="center" bgcolor="<%=color%>">
                        <%=col3%>
                    </td>
                </tr>
<%
}
//read the rest of the file to obtain the total number of lines
while((str = br.readLine()) != null){
    line++;
}
%>
                <tr>
                    <td align="left">
                        <c:if test="${param.eventStart > 30}">
                            <a href="showerPlot.jsp?outputDir=<%=outputDir%>&eventCandidates=<%=eventCandidates%>&eventNum=<%=eventNum%>&plot_size=<%=pixelHeight%>&eventStart=<%=start-30%>">
                                previous 30 events
                            </a>
                        </c:if>
                    </td>
                    <td>
                    </td>
                    <td align="right">
                        <%
                        if(line > start+30){
                        %>
                            <a href="showerPlot.jsp?outputDir=<%=outputDir%>&eventCandidates=<%=eventCandidates%>&eventNum=<%=eventNum%>&plot_size=<%=pixelHeight%>&eventStart=<%=start+30%>">
                                next 30 events
                            </a>
                        <%
                        }
                        %>
                    </td>
            </table>
        </td>
        <td align="center" valign="top">
            <font size="-1">Click on the image for a larger view</font><br>
            <a href="javascript:openPopup('showerPopup.jsp?outputDir=<%=outputDir%>&eventNum=<%=eventNum%>','',650, 750);" >
                <img src="<%=thumbPathURL%>"></a>
            <table cellspacing="0" cellpadding="2" border="0">
                <tr>
                    <td align="center" colspan="5">
                        <%=viewRawData%>
                    </td>
                </tr>
                <tr>
                <tr>
                    <td align="center" colspan="5">
                        Plot Datapoints:
                    </td>
                </tr>
                    <td align="center">
                        East/West<br>
                        (meters)
                    </td>
                    <td align="center">
                        North/South<br>(meters)
                    </td>
                    <td align="center">
                        Time<br>(nanosec)
                    </td>
                    <td align="center">
                        Detector
                    </td>
                    <td align="center">
                        Channel
                    </td>
                </tr>
<%
String eventFile = shower.getEventFile();
File eFile = new File(fullOutputDir + "/" + eventFile);
br = new BufferedReader(new FileReader(eFile));

str = null;
int count=1;
while((str = br.readLine()) != null){
    if(str.matches("^.*#.*")){
        continue;   //ignore comments in the file
    }
    String arr[] = str.split("\\s");
    String IDChan[] = arr[3].split("\\.");
    String x = arr[0];
    String y = arr[1];
    String z = arr[2];
    String id = IDChan[0];
    String chan = IDChan[1];

    String id_str = "<a href=\"id_info_no_page.html\" class=popupLink onclick=\"return !showPopup('" + id + "Popup', event);\">" + id + "</a> ";

    //Alternating Row Colors (http://time-tripper.com/uipatterns/index.php?page=Alternating_Row_Colors)
    if(count%2 == 0){
        out.println("<tr bgcolor=\"#CCFFBB\">");
    }
    else{
        out.println("<tr>");
    }
%>
                    <td align="center">
                        <%=x%>
                    </td>
                    <td align="center">
                        <%=y%>
                    </td>
                    <td align="center">
                        <%=z%>
                    </td>
                    <td align="center">
                        <%=id_str%>
                    </td>
                    <td align="center">
                        <%=chan%>
                    </td>
                </tr>
<%
    count++;
}
%>
            </table>
        </td>
    </tr>
</table>
<br>

<!-- hidden divs which are shown as popups for each detector ID in the table -->
<%
for(Iterator i=participating_ids.iterator(); i.hasNext(); ){    //for every id participating in the image/plot
    String id = (String)i.next();

    //get hash of metadata for the raw data file
    HashMap metaMap = new HashMap();
    String event_lfn = lfn_from_date(Integer.parseInt(id), eventDate);
    if(event_lfn != null){
        java.util.List meta = getMeta(event_lfn);
        if(meta != null){
            for(Iterator metai=meta.iterator(); metai.hasNext(); ){
                Tuple t = (Tuple)metai.next();
                metaMap.put(t.getKey(), t.getValue());
            }
        }
    }

    out.println("<div onclick='event.cancelBubble = true;' class=popup id=" + id + "Popup>" + metaMap.get("school") + " [<a class=closeLink href='#' onclick='hideCurrentPopup(); return false;'>close</a>]</div>");
}
%>

 


<p align="center">
<a href="shower.jsp?submit=change">Change</a> your parameters.
</p>
<p align="center">
<b>OR</b>
</p>
<p align="center">To save this plot permanently, enter the new name you want.<br>
Then click <b>Save Plot</b>.<br>

<center>
<form name="SaveForm" ACTION="save.jsp"  method="post" target="saveWindow" onSubmit='return openPopup("",this.target,500,200);' align="center">
<%
    //Metadata section
    //there seems to be an unwritten rule to use lowercase for metadata...
    //pass any arguments to write as metadata in the "metadata" form variable as tuple strings
%>

<%
//set rawData List variable before calling common_metadata_to_save
java.util.List rawDataReference = shower.getRawData();
rawData = new java.util.ArrayList(rawDataReference.size());
for(Iterator i=rawDataReference.iterator(); i.hasNext(); ){
    rawData.add(new String((String)i.next()));
}
%>

<%@ include file="include/common_metadata_to_save.jsp" %>

    <input type="hidden" name="beanName" value="shower">
    <input type="hidden" name="metadata" value="transformation string Quarknet.Cosmic::ShowerStudy" >

    <input type="hidden" name="metadata" value="detectorcoincidence int <%=shower.getDetectorCoincidence() %>" >
    <input type="hidden" name="metadata" value="eventcoincidence int <%=shower.getEventCoincidence() %>" >
    <input type="hidden" name="metadata" value="eventnum int <%=shower.getEventNum() %>" >
    <input type="hidden" name="metadata" value="gate int <%=shower.getGate() %>" >
    <input type="hidden" name="metadata" value="radius int -1" >
    <input type="hidden" name="metadata" value="study string shower" >
    <input type="hidden" name="metadata" value="type string plot" >

    <input type="hidden" name="metadata" value="title string <%=shower.getPlot_title()%>" >
    <input type="hidden" name="metadata" value="caption string <%=shower.getPlot_caption()%>">

    <input type="hidden" name="outputDir" value="<%=outputDir%>" >
    <input type="hidden" name="pngFile" value="<%=pngPlotName%>" >
    <input type="hidden" name="pngThumb" value="<%=thumbPngPlotName%>" >
    <input type="text" name="permanentFile"  size="20" maxlength="30">.png
    <input type="hidden" name="fileType" value="png" >
    <input name="save" type="submit" value="Save Plot">
</form>
</center>

</body>
</html>
