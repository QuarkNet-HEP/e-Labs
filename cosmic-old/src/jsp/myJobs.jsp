<%@ page import="java.util.*" %>
<%! 
public class GridJob {
    public java.util.Date submitTime = null;
    public String studyType = null;
    public int numJobs = 0;
    public int completedJobs = 0;
    public String currStatus = null;
    public String runLocation = null;
    public java.util.Date finishTime = null;
    public double fractionCompleted = 0;

    public GridJob() {}
}
%>
<%@ include file="common.jsp" %>
<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>
<html>
    <head>
        <title>My Jobs</title>
            <link rel="stylesheet" type="text/css" href="include/jobsStyles.css">
            <%
            //be sure to set this before including the navbar
            String headerType = "Data";
            %>
            <%@ include file="include/navbar_common.jsp" %>

            <link rel="stylesheet" type="text/css" href="http://pro.html.it/esempio/nifty2/niftyCorners.css">
            <link rel="stylesheet" type="text/css" href="http://pro.html.it/esempio/nifty2/niftyPrint.css" media="print">
            <script type="text/javascript" src="http://pro.html.it/esempio/nifty2/nifty.js"></script>
            <script type="text/javascript">
                window.onload=function(){
                    if(!NiftyCheck())
                            return;
                    Rounded("div#dayjobs","all","#FFF","#9BC4DD","smooth");
                    Rounded("div#weekjobs","all","#FFF","#BAD4E8","smooth");
                    Rounded("div#monthjobs","all","#FFF","#D6E3ED","smooth");
                    Rounded("div#olderjobs","all","#FFF","#E4EAEF","smooth");
                    Rounded("div#instructions","all","#FFF","#FF8103","smooth");
                }
            </script>
    </head>
    <div id="container">
    <div id="instructions">
        <h2>Legend</h2>
        <p>Here would go the descriptions.</p><br>
        <p>Progress bar</p>
        <p>Error symbol</p><br>
        <p>Finished symbol</p>
    </div>
    <div id="jobs">
        <h1>My Jobs</h1>
<%
        java.text.SimpleDateFormat df = new java.text.SimpleDateFormat("EEE, MMM d @ h:mm a");
        HashMap masterMap = new HashMap();
        masterMap.put("day", new TreeMap());
        masterMap.put("week", new TreeMap());
        masterMap.put("month", new TreeMap());
        masterMap.put("older", new TreeMap());
        
        GregorianCalendar oneDayAgo = new GregorianCalendar(new Locale("en", "US"));
        GregorianCalendar oneWeekAgo = new GregorianCalendar(new Locale("en", "US"));
        GregorianCalendar oneMonthAgo = new GregorianCalendar(new Locale("en", "US"));
        oneDayAgo.add(Calendar.DAY_OF_WEEK, -1);
        oneWeekAgo.add(Calendar.WEEK_OF_MONTH, -1);
        oneMonthAgo.add(Calendar.MONTH, -1);
        java.util.Date day = oneDayAgo.getTime();
        java.util.Date week = oneWeekAgo.getTime();
        java.util.Date month = oneMonthAgo.getTime();

        int dayJobs = 0;
        int dayRunning = 0;
        int dayFinished = 0;
        int dayError = 0;
        
        int weekJobs = 0;
        int weekRunning = 0;
        int weekFinished = 0;
        int weekError = 0;

        int monthJobs = 0;
        int monthRunning = 0;
        int monthFinished = 0;
        int monthError = 0;

        int olderJobs = 0;
        int olderRunning = 0;
        int olderFinished = 0;
        int olderError = 0;

        rs = s.executeQuery(
            "SELECT * FROM jobs WHERE rg_id = (SELECT id FROM research_group WHERE name = '" + user + "') ORDER BY submit_time DESC");
        
        while (rs.next()) {
            GridJob gj = new GridJob();
            gj.submitTime = rs.getTimestamp("submit_time");
            gj.finishTime = rs.getTimestamp("finish_time");
            gj.studyType = rs.getString("job_type");
            gj.numJobs = rs.getInt("num_jobs");
            gj.completedJobs = rs.getInt("jobs_completed");
            gj.currStatus = rs.getString("curr_status");
            gj.runLocation = rs.getString("run_location");
            gj.fractionCompleted = ((double) gj.completedJobs) / ((double) gj.numJobs);

            if (gj.submitTime.after(day)) {
                ((TreeMap)masterMap.get("day")).put(gj.submitTime, gj);

                if (gj.currStatus.equals("Finished")) {
                    dayFinished++;
                } else if (gj.currStatus.indexOf("Running") >= 0 || gj.currStatus.equals("Starting") || gj.currStatus.equals("Cleaning up")) {
                    dayRunning++;
                } else if (gj.currStatus.equals("Error")) {
                    dayError++; 
                }
                dayJobs++;
            } else if (gj.submitTime.after(week)) {
                ((TreeMap)masterMap.get("week")).put(gj.submitTime, gj);

                if (gj.currStatus.equals("Finished")) {
                    weekFinished++;
                } else if (gj.currStatus.indexOf("Running") >= 0 || gj.currStatus.equals("Starting") || gj.currStatus.equals("Cleaning up")) {
                    weekRunning++;
                } else if (gj.currStatus.equals("Error")) {
                    weekError++; 
                }
                weekJobs++;
            } else if (gj.submitTime.after(month)) {
                ((TreeMap)masterMap.get("month")).put(gj.submitTime, gj);
                
                if (gj.currStatus.equals("Finished")) {
                    monthFinished++;
                } else if (gj.currStatus.indexOf("Running") >= 0 || gj.currStatus.equals("Starting") || gj.currStatus.equals("Cleaning up")) {
                    monthRunning++;
                } else if (gj.currStatus.equals("Error")) {
                    monthError++; 
                }
                monthJobs++;
            } else {
                ((TreeMap)masterMap.get("older")).put(gj.submitTime, gj);
                
                if (gj.currStatus.equals("Finished")) {
                    olderFinished++;
                } else if (gj.currStatus.indexOf("Running") >= 0 || gj.currStatus.equals("Starting") || gj.currStatus.equals("Cleaning up")) {
                    olderRunning++;
                } else if (gj.currStatus.equals("Error")) {
                    olderError++; 
                }
                olderJobs++;
            }
        }
%>
        <div id="dayjobs">
        <div class="job_category">
            <div id="day_open" style="visibility:hidden; display:none">
                <a href="javascript:void(0);" onclick="HideShow('day_listing');HideShow('day_closed');HideShow('day_open');">
                    <img src="graphics/Tright.gif" alt="" border="0"></a>
                    Today's Jobs
            </div>
            <div id="day_closed" style="visibility:visible; display:">
                <a href="javascript:void(0);" onclick="HideShow('day_listing');HideShow('day_open');HideShow('day_closed');">
                    <img src="graphics/Tdown.gif" alt="" border="0"></a>
                    Today's Jobs
            </div>
        </div>
        <div class="job_stats">
            <%=dayJobs%> Total jobs: <%=dayRunning%> Running, <%=dayFinished%> Finished, <%=dayError%> Errors<br><br>
        <div id="day_listing" style="visibility:visible; display:">
            <div class="job_listing">
                <table width="400" cellspacing="0" cellpadding="5" border="0">
<%
        TreeMap dayOld = (TreeMap)masterMap.get("day");
        Object[] dayIt = dayOld.values().toArray();
        for (int i = dayIt.length - 1; i >= 0; i--) {
            GridJob gj = (GridJob)dayIt[i];
%>
                    <tr>
                        <td width=50">
                            <%=gj.studyType%>
                        </td>
                        <td width="200">
                            <%=df.format(gj.submitTime)%>
                        </td>
                        <td width="50">
                            <%=gj.runLocation%>
                        </td>
                        <td width="100">
                            <%=gj.currStatus%>
                        </td>
                    </tr>
<%
        }
%>
                </table>
            </div>
        </div>
        </div>
        </div>
        <br>

        <div id="weekjobs">
        <div class="job_category">
            <div id="week_open" style="visibility:visible; display:">
                <a href="javascript:void(0);" onclick="HideShow('week_listing');HideShow('week_closed');HideShow('week_open');">
                    <img src="graphics/Tright.gif" alt="" border="0"></a>
                    This Week's Jobs
            </div>
            <div id="week_closed" style="visibility:hidden; display:none">
                <a href="javascript:void(0);" onclick="HideShow('week_listing');HideShow('week_open');HideShow('week_closed');">
                    <img src="graphics/Tdown.gif" alt="" border="0"></a>
                    This Week's Jobs
            </div>
        </div>
        <div class="job_stats">
            <%=weekJobs%> Total jobs: <%=weekRunning%> Running, <%=weekFinished%> Finished, <%=weekError%> Errors<br><br>
        <div id="week_listing" style="visibility:hidden; display:none">
            <div class="job_listing">
                <table width="400" cellspacing="0" cellpadding="5" border="0">
<%
        TreeMap weekOld = (TreeMap)masterMap.get("week");
        Object[] weekIt = weekOld.values().toArray();
        for (int i = weekIt.length - 1; i >= 0; i--) {
            GridJob gj = (GridJob)weekIt[i];
%>
                    <tr>
                        <td width=50">
                            <%=gj.studyType%>
                        </td>
                        <td width="200">
                            <%=df.format(gj.submitTime)%>
                        </td>
                        <td width="50">
                            <%=gj.runLocation%>
                        </td>
                        <td width="100">
                            <%=gj.currStatus%>
                        </td>
                    </tr>
<%
        }
%>
                </table>
            </div>
        </div>
        </div>
        </div>
        <br>

        <div id="monthjobs">
        <div class="job_category">
            <div id="month_open" style="visibility:visible; display:">
                <a href="javascript:void(0);" onclick="HideShow('month_listing');HideShow('month_closed');HideShow('month_open');">
                    <img src="graphics/Tright.gif" alt="" border="0"></a>
                    This Month's Jobs
            </div>
            <div id="month_closed" style="visibility:hidden; display:none">
                <a href="javascript:void(0);" onclick="HideShow('month_listing');HideShow('month_open');HideShow('month_closed');">
                    <img src="graphics/Tdown.gif" alt="" border="0"></a>
                    This Month's Jobs
            </div>
        </div>
        <div class="job_stats">
            <%=monthJobs%> Total jobs: <%=monthRunning%> Running, <%=monthFinished%> Finished, <%=monthError%> Errors<br><br>
        <div id="month_listing" style="visibility:hidden; display:none">
            <div class="job_listing">
<%
        TreeMap monthOld = (TreeMap)masterMap.get("month");
        Object[] monthIt = monthOld.values().toArray();
        for (int i = monthIt.length - 1; i >= 0; i--) {
            GridJob gj = (GridJob)monthIt[i];
            out.write("Job: " + gj.submitTime + " " + gj.numJobs + " " + gj.runLocation + "<br>");
        }

        s.close();
        conn.close();
%>
            </div>
        </div>
        </div>
        </div>
        <br>

        <div id="olderjobs">
        <div class="job_category">
            <div id="older_open" style="visibility:visible; display:">
                <a href="javascript:void(0);" onclick="HideShow('older_listing');HideShow('older_closed');HideShow('older_open');">
                    <img src="graphics/Tright.gif" alt="" border="0"></a>
                    Older Jobs
            </div>
            <div id="older_closed" style="visibility:hidden; display:none">
                <a href="javascript:void(0);" onclick="HideShow('older_listing');HideShow('older_open');HideShow('older_closed');">
                    <img src="graphics/Tdown.gif" alt="" border="0"></a>
                    Older Jobs
            </div>
        </div>
        <div class="job_stats">
            <%=olderJobs%> Total jobs: <%=olderRunning%> Running, <%=olderFinished%> Finished, <%=olderError%> Errors<br><br>
        <div id="older_listing" style="visibility:hidden; display:none">
            <div class="job_listing">
<%
        TreeMap olderOld = (TreeMap)masterMap.get("older");
        Object[] olderIt = olderOld.values().toArray();
        for (int i = olderIt.length - 1; i >= 0; i--) {
            GridJob gj = (GridJob)olderIt[i];
            out.write("Job: " + gj.submitTime + " " + gj.numJobs + " " + gj.runLocation + "<br>");
        }
%>
            </div>
        </div>
        </div>
        </div>
        <br>
    </div>
    </body>
</html>
