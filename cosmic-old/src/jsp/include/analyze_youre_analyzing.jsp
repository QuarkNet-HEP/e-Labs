<table colspace=4 border="0">
<tbody>
<tr><td align="center">You're analyzing...</td>
    <td align="center">Chan1 events</td>
    <td align="center">Chan2 events</td>
    <td align="center">Chan3 events</td>
    <td align="center">Chan4 events</td>
    <td colspan="2" align="center">Raw Data</td>
</tr>
<%
HashSet detectorIDs = new HashSet();
boolean[] validChans = new boolean[4];
//strings that are used for information on the plots
String rawDataString = "Data: ";
String detectorIDString = "Detector(s): ";
String queryFilenames = "";
int chan1total = 0;
int chan2total = 0;
int chan3total = 0;
int chan4total = 0;

//number of files. Only display the top 10 initially
int num_files = 0;

//iterate over all raw data files in the rawData array
for (Iterator i=rawData.iterator(); i.hasNext(); ){
    String lfn = (String)i.next();

    java.util.List meta = getMeta(out, lfn);
    if(meta.size() == 0){
        out.write("<font color=red>No file associated with: " + lfn + "</font><br>\n");
        continue;
    }

    //create a hash of metadata
    HashMap metaMap = new HashMap();
    for(Iterator metai=meta.iterator(); metai.hasNext(); ){
        Tuple t = (Tuple)metai.next();
        metaMap.put(t.getKey(), t.getValue());
    }

    //create a string of the date for the file
    String filedate = new String();
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMM d, yyyy H:m:s z");
    sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
    filedate = sdf.format((Date)metaMap.get("startdate"));

    //create a string of filenames to send to rawanalyzeMultiple for comparison
    queryFilenames += "f=" + lfn + "&";

    //create a string of files from rawData delimited by commas
    rawDataString += filedate + ", ";

    //create a list of detector IDs delimited by commas
    detectorIDString += metaMap.get("detectorid") + ", ";

    //get metadata which will be output in the table
    String city = (String)metaMap.get("city");
    String school = (String)metaMap.get("school");
    String group = (String)metaMap.get("group");
    String detector = (String)metaMap.get("detectorid");
    String title = city + ", " + group + ", Detector: " + detector;
    int chan1 = ((Long)metaMap.get("chan1")).intValue();
    int chan2 = ((Long)metaMap.get("chan2")).intValue();
    int chan3 = ((Long)metaMap.get("chan3")).intValue();
    int chan4 = ((Long)metaMap.get("chan4")).intValue();
    chan1total += chan1;
    chan2total += chan2;
    chan3total += chan3;
    chan4total += chan4;

    if(num_files == 10){
        out.println("</tbody><tbody id=\"tog2\" style=\"display:none\">");
    }
%>
    <tr>
        <td align="center">
            <%=school%> <%=filedate%></a>
        </td>
        <td align=center><%=chan1%></td>
        <td align=center><%=chan2%></td>
        <td align=center><%=chan3%></td>
        <td align=center><%=chan4%></td>
        <td bgcolor="#EFEFFF" align=center><a title="<%=title%>" href="view.jsp?filename=<%=lfn%>&type=data&get=meta">View</a>&nbsp</td>
        <td bgcolor="#EFFEDE" align=center><a href="rawanalyzeOutput.jsp?filename=<%=lfn%>">Statistics</a></td>
    </tr>
<%
    detectorIDs.add(metaMap.get("detectorid"));
    validChans[0] = ((Long)metaMap.get("chan1")).intValue() > 0 || validChans[0] ? true : false;
    validChans[1] = ((Long)metaMap.get("chan2")).intValue() > 0 || validChans[1] ? true : false;
    validChans[2] = ((Long)metaMap.get("chan3")).intValue() > 0 || validChans[2] ? true : false;
    validChans[3] = ((Long)metaMap.get("chan4")).intValue() > 0 || validChans[3] ? true : false;

    num_files++;    //add a count
}
//trim off extra ", " in Strings
rawDataString = rawDataString.substring(0, rawDataString.length()-2);
detectorIDString = detectorIDString.substring(0, detectorIDString.length()-2);
//trim off last "&"
queryFilenames = queryFilenames.substring(0, queryFilenames.length()-1);
//get total events in all chans
int allchantotal = chan1total + chan2total + chan3total + chan4total;;

//only show "show more files" link if there's more files to show...
if(num_files > 10){
%>
</tbody>
<tbody>
<tr>
    <td colspan="7" align="right" id="tog1" 
    onclick="toggle('tog1', 'tog2', '...show more files', 'show less files...')">...show more files</td>
</tr>
<%
}
%>
<tr>
    <td align="center">
        <font color="grey">Total (<%=num_files%> files <%=allchantotal%> events)</font>
    </td>
    <td align="center">
        <font color="grey"><%=chan1total%></font>
    </td>
    <td align="center">
        <font color="grey"><%=chan2total%></font>
    </td>
    <td align="center">
        <font color="grey"><%=chan3total%></font>
    </td>
    <td align="center">
        <font color="grey"><%=chan4total%></font>
    </td>
    <td colspan="2" align="center">
        <a href="rawanalyzeMultiple.jsp?<%=queryFilenames%>">Compare files</a>
    </td>
</tr>
<tbody>
</TABLE>
<br>
