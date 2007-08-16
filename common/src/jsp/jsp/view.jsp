<%@ include file="common.jsp" %>
<%@ include file="include/javascript.jsp" %>

<html>
<head>
    <title>View Data</title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->

<%@ include file="../include/text-colorizer.jsp" %>

<%

String menu = request.getParameter("menu");
String type = request.getParameter("type");
if (menu==null) menu="yes";
if (menu.equals("yes")){
//be sure to set this before including the navbar
String headerType = "Data";
if(type != null && type.equals("uploadedimage")){
    headerType = "Posters";
}
%>
<%@ include file="include/navbar_common.jsp" %>

<%
}
String filename = request.getParameter("filename");
if(filename == null){
%>
    <center><b>Please choose a file to view.</b></center>
<%
    return;
}

if(type == null){
%>
    <center>
    <b>Choose the type of this file.</b><br>
    <a href="view.jsp?filename=<%=filename%>&type=data">Raw Data</a><br>
    <a href="view.jsp?filename=<%=filename%>&type=plot">Plot</a><br>
<%
    return;
}

//get either the metadata or the plot
String get = request.getParameter("get");

if(get == null){
%>
    <center>
    <b>View either:</b><br>
        <a href="view.jsp?filename=<%=filename%>&type=<%=type%>&get=data">Datafile</a> for file: <%=filename%><br>
        <a href="view.jsp?filename=<%=filename%>&type=<%=type%>&get=meta">Metadata</a> for file: <%=filename%><br>
<%
    return;
}

//to highlight or not to highlight (a specific line)
String highlight = request.getParameter("highlight");
if(highlight == null){
    highlight = "no";
}

java.util.List meta = null;
String content = "";        //metadata, plot, or datafile

if(get.equals("meta")){
    if(type.equals("uploadedimage")){
        content += "<a href=view.jsp?filename=" + filename + "&type=" + type + "&menu="+ menu +"&get=data>Show Image</a> <br><br>\n";
    }
    else{
        content += "<a href=view.jsp?filename=" + filename + "&type=" + type + "&menu="+ menu +"&get=data>Show " + type + "</a> <br><br>\n";
    }
    content += "<table width=600 border=0> <tr><td colspan=2 align=center valign=top><b>Metadata for file " + filename + "</b></td></tr>\n";
    
    //get metadata
    meta = getMeta(filename);
    if(meta != null){
        for(Iterator i=meta.iterator(); i.hasNext(); ){
            Tuple t = (Tuple)i.next();
            String value = (t.getValue() + "").replaceAll("\\\\n", "<br>");
            content += "<tr><td width=50% align=right valign=top><font size=-1>" + t.getKey() + ":</font></td><td align=left><font size=-1>" + value + "</font></td></tr>\n";
        }
    }
    else{
        content += "<tr><td>No metadata associated with this file!</td></tr>\n";
    }
    content += "</table>\n";
}
else if(get.equals("data")){
    String pfn = getPFN(filename);
    if(pfn == null){
        content += "Error: no physical filename associated with the filename: " + filename + "<br>\n";
    }
    else{
        content += "<a href=view.jsp?filename=" + filename + "&type=" + type + "&menu="+ menu + "&get=meta>Show details (metadata)</a> <br><br>\n";
        content += "<b>" + type + " for file " + filename + "</b> <br>\n";
        if(type.equals("plot") || type.equals("uploadedimage")){
            String plotURL = pfn.substring(pfn.indexOf("users"));
            content += "<img src=\"" + plotURL + "\"> <br><br>\n";

            meta = getMeta(filename);
            if(meta != null){
                HashMap metaMap = new HashMap();
                for(Iterator metai=meta.iterator(); metai.hasNext(); ){
                    Tuple t = (Tuple)metai.next();
                    metaMap.put(t.getKey(), t.getValue());
                }

                // Show a link to the provenance for this plot, if we have it.
                java.sql.Timestamp ts = (java.sql.Timestamp)metaMap.get("creationdate");
                if (metaMap.containsKey("provenance")){
                    //Feb 2, 2005 20:00
                    java.sql.Timestamp goodDate = new java.sql.Timestamp(2005-1900, 2-1, 2, 20, 0, 0, 0);
                    //small hack...provinance creation was fixed after this date...
                    if(ts.compareTo(goodDate) > 0){
                        String provFile = getPFN((String)metaMap.get("provenance"));
                        if (provFile != null) {
                            content += "<a href=\"javascript:openPopup(\'" + 
                                provFile.substring(provFile.indexOf("users")) +
                                "\', \'Provenance\', 800, 850)\">Show provenance</a><br>";
                        }
                    }
                }
                // Show a link to the Derivation linked with this plot if available
                if (metaMap.containsKey("dvname")){
                    //Mar 24, 2005 11:00
                    java.sql.Timestamp goodDate = new java.sql.Timestamp(2005-1900, 3-1, 24, 11, 0, 0, 0);
                    //FIXME: this is a problem with NOT utilizing the version number on TR identifiers
                    // Whenever there's a change in the TR, previous saved DVs won't work with that TR any
                    // longer
                    if(ts.compareTo(goodDate) > 0){
                        String dvName = (String)metaMap.get("dvname");
                        String study = (String)metaMap.get("study");
                        content += "<a href=\"" + study + ".jsp?dvName=" + dvName + 
                            "\">Run this study again</a><br>";
                    }
                }
            }
        }
        else if(type.equals("data")){
            String form_h = request.getParameter("h") != null ? request.getParameter("h") : "";
            String form_m = request.getParameter("m") != null ? request.getParameter("m") : "";
            String form_s = request.getParameter("s") != null ? request.getParameter("s") : "";
            content += "<br><table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">" +
                "<tr><td colspan=2 align=center>Go to time</td></tr>" + 
                "<tr><td colspan=2 align=center><form method=get>" + 
                "Hours:<input type=text name=h size=2 maxlength=2 value=" + form_h + "> " +
                "Minutes: <input type=text name=m size=2 maxlength=2 value=" + form_m + "> " +
                "Seconds: <input type=text name=s size=2 maxlength=2 value=" + form_s + ">" + 
                "<input type=hidden name=filename value=" + filename + ">" +
                "<input type=hidden name=type value=data>" + 
                "<input type=hidden name=get value=data>" + 
                "<input type=hidden name=highlight value=no><input type=submit value=Go></form></td></td>";
            BufferedReader br = new BufferedReader(new FileReader(pfn));
            String str = null;
            int count=0;

            //seek to a specific time in the raw file
            String hour = request.getParameter("h");
            String data_line = request.getParameter("line");
            if(hour != null){
                String minute = request.getParameter("m");
                String second = request.getParameter("s");
                int h, m, s, this_sec, start_sec;
                int start_line = -1;
                //String[] time_arr = data_time.split(":");
                h = Integer.parseInt(hour);
                m = (minute == null || minute.equals("")) ? 0 : Integer.parseInt(minute);
                s = (second == null || second.equals("")) ? 0 : Integer.parseInt(second);
                start_sec = h*3600 + m*60 + s;
                while((str = br.readLine()) != null){
                    count++;
                    h = Integer.parseInt(str.substring(42, 44));
                    m = Integer.parseInt(str.substring(44, 46));
                    s = Integer.parseInt(str.substring(46, 48));
                    this_sec = h*3600 + m*60 + s;

                    if((this_sec + Integer.parseInt(str.substring(68, 71))/1000) >= 3599*24){
                        continue;   //skip over times which are the previous day
                                    //but are rounded to the next day
                    }

                    if(this_sec >= start_sec){
                        //record starting line
                        if(start_line == -1){
                            start_line = count;
                        }
                        content += "<tr><td align=\"right\"><font color=\"#999999\" face=\"Courier\">" + count + ": </font></td><td align=\"left\"><font face=\"Courier\">" + str + "</font></td></tr>\n";
                        if((count - start_line) >= 100){
                            break;
                        }
                    }
                }
            }
            else if(data_line != null && Integer.parseInt(data_line) > 0){
                int line = Integer.parseInt(data_line);
                while((str = br.readLine()) != null){
                    count++;
                    int startShowing = line;
                    //show 10 previous lines as well (if highlight=yes)
                    if(highlight.equals("yes")){
                        startShowing = line-10;
                    }
                    if(count >= startShowing){
                        content += "<tr><td align=\"right\"><font color=\"#999999\" face=\"Courier\">" + count + ": </font></td>\n";

                        //make line we chose display as green (if highlight==yes)
                        if(count == line && highlight.equals("yes")){
                            content += "<td align=\"left\"><font color=\"00CC00\" face=\"Courier\">" + str + "</font></td></tr>\n";
                        }
                        else{
                            content += "<td align=\"left\"><font face=\"Courier\">" + str + "</font></td></tr>\n";
                        }

                        if((count - line) >= 100){
                            break;
                        }
                    }
                }
            }
            //else simply display from the beginning of the file
            else{
                while((str = br.readLine()) != null){
                    count++;

                    content += "<tr><td align=\"right\"><font color=\"#999999\" face=\"Courier\">" + count + ": </td><td align=\"left\"></font><font face=\"Courier\">" + str + "</font></td></tr>\n";

                    if(count == 100){
                        break;
                    }
                }
            }
            //find out if there are more lines
            boolean moreLines = false;
            if((str = br.readLine()) != null){
                moreLines = true;
            }
            br.close();
            content += "</table>";
            if(moreLines){
                content += "<br><div align=\"right\"><a href=?filename=" + filename + 
                    "&type=data&get=data&highlight=" + highlight + "&line=" + count + 
                    ">Next 100 lines...</a></div>";
            }
        }
    }
}
%>
<center>
    <%=content%>
</center>

</body>
</html>
