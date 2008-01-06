<%@ include file="common.jsp" %>
<%@ page import="java.sql.Timestamp" %> 
<html>
<head>
<title>Quarknet Portal Statistics</title>
</head>

<body>

<table border="0" width="100%">
    <tr>
        <td align="center">
            <a href="?type=grouptotals">Group login totals</a>
        </td>
        <td align="center">
            <a href="?type=allgroups">Every single login</a>
        </td>
    </tr>
</table>
<br>


<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>

<%
String type = request.getParameter("type");
String sortCol = request.getParameter("sort");
String starttime = request.getParameter("starttime");
String endtime = request.getParameter("endtime");
String onlyGroup = request.getParameter("onlyGroup");
String sort_ascS = request.getParameter("sort_asc");
boolean sort_asc = true;
if(sort_ascS != null && !sort_ascS.equals("")){
    sort_asc = sort_ascS.equals("true") ? true : false;
}

out.println("Start Time: " + starttime + " | End Time: " + endtime + "<br><br>");

if(type == null || type.equals("allgroups")){
    rs = s.executeQuery("SELECT research_group.name, usage.date_entered FROM usage, research_group WHERE research_group.id=usage.research_group_id");
    ArrayList group_stats = new ArrayList();
    HashMap groupSplit = new HashMap();    //number of split files
    HashMap groupPlot = new HashMap();      //number of plot files
    HashMap groupPoster = new HashMap();      //number of poster files
    while(rs.next()){
        String group = rs.getString("name");
        if(starttime != null){
            Timestamp stime = Timestamp.valueOf((String)starttime);
            if(stime.compareTo(Timestamp.valueOf(rs.getString("date_entered"))) > 0){
                continue;
            }
        }
        if(endtime != null){
            Timestamp etime = Timestamp.valueOf((String)endtime);
            if(etime.compareTo(Timestamp.valueOf(rs.getString("date_entered"))) < 0){
                continue;
            }
        }
        if(onlyGroup != null){
            if(!group.equals(onlyGroup)){
                continue;
            }
        }

        ArrayList list = new ArrayList(5);
        list.add(0, rs.getString("name"));
        list.add(1, rs.getString("date_entered"));
        if(!groupSplit.containsKey(group)){
            java.util.List splitFiles = getLFNs("type='split' AND group='" + group + "'");
            java.util.List plotFiles = getLFNs("type='plot' AND group='" + group + "'");
            java.util.List posterFiles = getLFNs("type='poster' AND group='" + group + "'");
            Integer numSplitFiles = new Integer(splitFiles.size());
            Integer numPlotFiles = new Integer(plotFiles.size());
            Integer numPosterFiles = new Integer(posterFiles.size());
            groupSplit.put(group, numSplitFiles);
            groupPlot.put(group, numPlotFiles);
            groupPoster.put(group, numPosterFiles);
        }
            
        list.add(2, groupSplit.get(group));
        list.add(3, groupPlot.get(group));
        list.add(4, groupPoster.get(group));
        group_stats.add(list);
    }

    //sort list...
    if(sortCol == null){
        sortCol = "0";
    }
    SortByColumn sbc = new SortByColumn(Integer.parseInt(sortCol));
    if(!sort_asc){
        sbc.sortDescending();
    }
    Collections.sort(group_stats, sbc);
%>

    <table border="0" cellpadding="0" cellspacing="1" width="100%">
        <tr>
            <td align="left">
                <a href="?sort=0&sort_asc=<%=!sort_asc%>">Group Name</a>
            </td>
            <td align="left">
                <a href="?sort=1&sort_asc=<%=!sort_asc%>">Time of login</a>
            </td>
            <td align="center">
                <a href="?sort=2&sort_asc=<%=!sort_asc%>">Number of Split Files</a>
            </td>
            <td align="center">
                <a href="?sort=3&sort_asc=<%=!sort_asc%>">Number of Plot Files</a>
            </td>
            <td align="center">
                <a href="?sort=4&sort_asc=<%=!sort_asc%>">Number of Poster Files</a>
            </td>
        </tr>
<%
        String group;
        Timestamp time;
        Integer numSplit = null;
        Integer numPlot = null;
        Integer numPoster = null;
        for(Iterator i=group_stats.iterator(); i.hasNext(); ){
            ArrayList gt = (ArrayList)i.next();
            group = (String)gt.get(0);
            time = Timestamp.valueOf((String)gt.get(1));
            numSplit = (Integer)gt.get(2);
            numPlot = (Integer)gt.get(3);
            numPoster = (Integer)gt.get(4);
%>
        <tr>
            <td>
                <a href="?type=allgroups&onlyGroup=<%=group%>"><%=group%></a>
            </td>
            <td>
                <%=time%>
                <a href="?type=allgroups&starttime=<%=time%>">S</a>
                <a href="?type=allgroups&endtime=<%=time%>">E</a>
            </td>
            <td align="center">
                <%=numSplit%>
            </td>
            <td align="center">
                <%=numPlot%>
            </td>
            <td align="center">
                <%=numPoster%>
            </td>
        </tr>
<%
    }
%>
    </table>
<%
}
else if(type.equals("grouptotals")){
    rs = s.executeQuery("SELECT research_group.name, usage.date_entered FROM usage, research_group WHERE research_group.id=usage.research_group_id");
    ArrayList group_stats = new ArrayList();
    HashMap group_counter = new HashMap();  //number of logins
    HashMap groupSplit = new HashMap();    //number of split files
    HashMap groupPlot = new HashMap();      //number of plot files
    HashMap groupPoster = new HashMap();      //number of poster files
    while(rs.next()){
        if(starttime != null){
            Timestamp stime = Timestamp.valueOf((String)starttime);
            if(stime.compareTo(Timestamp.valueOf(rs.getString("date_entered"))) >= 0){
                continue;
            }
        }
        if(endtime != null){
            Timestamp etime = Timestamp.valueOf((String)endtime);
            if(etime.compareTo(Timestamp.valueOf(rs.getString("date_entered"))) >= 0){
                continue;
            }
        }
        if(onlyGroup != null){
            String group = rs.getString("name");
            if(!group.equals(onlyGroup)){
                continue;
            }
        }

        String group = rs.getString("name");

        if(!groupSplit.containsKey(group)){
            java.util.List splitFiles = getLFNs("type='split' AND group='" + group + "'");
            java.util.List plotFiles = getLFNs("type='plot' AND group='" + group + "'");
            java.util.List posterFiles = getLFNs("type='poster' AND group='" + group + "'");
            Integer numSplitFiles = new Integer(splitFiles.size());
            Integer numPlotFiles = new Integer(plotFiles.size());
            Integer numPosterFiles = new Integer(posterFiles.size());
            groupSplit.put(group, numSplitFiles);
            groupPlot.put(group, numPlotFiles);
            groupPoster.put(group, numPosterFiles);
        }
            
        if(group_counter.containsKey(group)){
            group_counter.put(group, (new Integer(((Integer)group_counter.get(group)).intValue()+1)));
        }
        else{
            group_counter.put(group, new Integer(1));
        }
    }

    //create array from hash counter
    ArrayList group_total = new ArrayList();
    for(Iterator i=group_counter.keySet().iterator(); i.hasNext(); ){
        String group = (String)i.next();
        ArrayList list = new ArrayList(5);
        list.add(0, group);
        list.add(1, group_counter.get(group));
        list.add(2, groupSplit.get(group));
        list.add(3, groupPlot.get(group));
        list.add(4, groupPoster.get(group));
        group_stats.add(list);
    }

    //sort list...
    if(sortCol == null){
        sortCol = "0";
    }
    SortByColumn sbc = new SortByColumn(Integer.parseInt(sortCol));
    if(!sort_asc){
        sbc.sortDescending();
    }
    Collections.sort(group_stats, sbc);
%>

    <table border="0" cellpadding="0" cellspacing="1" width="100%">
        <tr>
            <td align="left">
                <a href="?type=grouptotals&sort=0">Group Name</a>
            </td>
            <td align="left">
                <a href="?type=grouptotals&sort=1">Total times logged in</a>
            </td>
            <td align="center">
                <a href="?type=grouptotals&sort=2&sort_asc=<%=!sort_asc%>">Number of Split Files</a>
            </td>
            <td align="center">
                <a href="?type=grouptotals&sort=3&sort_asc=<%=!sort_asc%>">Number of Plot Files</a>
            </td>
            <td align="center">
                <a href="?type=grouptotals&sort=4&sort_asc=<%=!sort_asc%>">Number of Poster Files</a>
            </td>
        </tr>
<%
        String group;
        Integer times;
        Integer numSplit = null;
        Integer numPlot = null;
        Integer numPoster = null;
        for(Iterator i=group_stats.iterator(); i.hasNext(); ){
            ArrayList gt = (ArrayList)i.next();
            group = (String)gt.get(0);
            times = (Integer)gt.get(1);
            numSplit = (Integer)gt.get(2);
            numPlot = (Integer)gt.get(3);
            numPoster = (Integer)gt.get(4);
%>
        <tr>
            <td>
                <a href="?type=grouptotals&onlyGroup=<%=group%>"><%=group%></a>
            </td>
            <td>
                <%=times%>
            </td>
            <td align="center">
                <%=numSplit%>
            </td>
            <td align="center">
                <%=numPlot%>
            </td>
            <td align="center">
                <%=numPoster%>
            </td>
        </tr>
<%
    }
%>
    </table>
<%
}
%>
</body>
</html>
