<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.apache.commons.lang.time.DateUtils" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.cosmic.bless.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>
<%@ page import="jxl.*" %>
<%@ page import="jxl.write.*" %>
<%@ page import="java.io.File" %>

<%
  SimpleDateFormat DATEFORMAT = new SimpleDateFormat("MM/dd/yyyy");
  DATEFORMAT.setLenient(false);
  String submit = request.getParameter("submit");
  String fromDate = request.getParameter("fromDateSplit");
  if (fromDate == null) {
    Calendar fromMonth = Calendar.getInstance();
    fromMonth.add(Calendar.MONTH,-1);     
    fromDate = DATEFORMAT.format(fromMonth.getTime());
  }
  String toDate = request.getParameter("toDateSplit");
  if (toDate == null) {
    Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.DATE, 1);    
    toDate = DATEFORMAT.format(cal.getTime());
  }
  Date startDate = null;
  Date endDate = null;
  String messages = "";
  TreeMap<Integer, VDSCatalogEntry> plotResults = new TreeMap<Integer, VDSCatalogEntry>();
  TreeMap<String, ArrayList<String>> reportLines = new TreeMap<String, ArrayList<String>>();
  
  if ("Retrieve Report".equals(submit)) {
    if (StringUtils.isNotBlank(fromDate)) {
      startDate = DATEFORMAT.parse(fromDate); 
    }
    if (StringUtils.isNotBlank(toDate)) {
      endDate = DATEFORMAT.parse(toDate); 
    }
    //this query will bring all plots in the date range and we can also get the summary from it
    plotResults = DataTools.getVDSCatalogEntries(elab, startDate, endDate, "", "plot");
    
    //prepare results by detectorid
    for (Map.Entry<Integer,VDSCatalogEntry> e: plotResults.entrySet()) {
          VDSCatalogEntry entry = e.getValue();
          ArrayList<String> details = new ArrayList<String>();
          details.add((String) entry.getTupleValue("name"));
          details.add((String) entry.getTupleValue("group"));
          details.add((String) entry.getTupleValue("teacher"));
          details.add((String) entry.getTupleValue("school"));
          details.add((String) entry.getTupleValue("city"));
          details.add((String) entry.getTupleValue("state"));
          details.add((String) entry.getTupleValue("project"));
    /// entry.getTupleValue("name") seems to throw null on the new servers for some reason
    /// Stopgap fix to allow code to run until underlying problem fixed
    ///          reportLines.put((String) entry.getTupleValue("name"), details);
          if (entry.getTupleValue("name") != null && details != null) {
	         reportLines.put((String) entry.getTupleValue("name"), details);
	  }
    } 
  }//end of submit
  
  request.setAttribute("reportLines", reportLines);
  request.setAttribute("messages", messages);
  request.setAttribute("fromDate", fromDate);
  request.setAttribute("toDate", toDate);
  
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">   
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>Plots Report</title>
    <link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
    <link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
    <link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
    <script type="text/javascript" src="../include/jquery/js/jquery-1.12.4.min.js"></script>   
    <link type="text/css" href="../include/jquery/css/blue/jquery-ui-1.7.2.custom.css" rel="Stylesheet" />  
    <script type="text/javascript" src="../include/jquery/js/jquery-ui-1.7.3.custom.min.js"></script>
    <script type="text/javascript" src="../include/jquery/js/jquery.event.hover-1.0.js"></script> 
    <script type="text/javascript" src="../include/jquery/js/jquery.tablesorter.min.js"></script> 
    <link type="text/css" rel="stylesheet" href="../include/jquery/css/blue/style.css" />   
    <script type="text/javascript" src="../include/elab.js"></script>
    <script>
      $(document).ready(function() {
        var calendarParam = {
            showOn: 'button', 
            buttonImage: '../graphics/calendar-blue.png',
            buttonImageOnly: true, 
            changeMonth: true,
            changeYear: true, 
            showButtonPanel: true,
            minDate: new Date(2000, 11-1, 30)//, // Earliest known date of data - probably should progamatically find. 
            //maxDate: new Date() // Should not look later than today
        }
      $('.datepicker1').datepicker(calendarParam);
      $("#fromDateSplit").datepicker('option', 'buttonText', 'Choose start date for data files.');
      $("#toDateSplit").datepicker('option', 'buttonText', 'Choose start date for data files.');
      $('img.ui-datepicker-trigger').css('vertical-align', 'text-bottom');      
      }); 
      $(document).ready(function() { 
        if ($("#alternatecolor").find("tbody").find("tr").size() > 0) {
            // call the tablesorter plugin 
            $("#alternatecolor").tablesorter({ 
                // sort on the second column and first column, order asc 
                sortList: [[6,0],[0,0]] 
            }); 
        }
      }); 
      
      function altRows(id){
        if(document.getElementsByTagName){           
          var table = document.getElementById(id);  
          var rows = document.getElementsByName("details"); 
          for(i = 0; i < rows.length; i++){          
            if(i % 2 == 0){
              rows[i].className = "evenrowcolor";
            }else{
              rows[i].className = "oddrowcolor";
            }      
          }
        }
      }
      window.onload=function(){
        altRows('alternatecolor');
      }
      </script>

      <style type="text/css">
      table.altrowstable {
        border-width: 1px;
        border-color: #a9c6c9;
        border-collapse: collapse;
      }
      table.altrowstable th {
        border-width: 1px;
        padding: 2px;
        border-style: solid;
        border-color: #a9c6c9;
      }
      table.altrowstable td {
        border-width: 1px;
        padding: 2px;
        border-style: solid;
        border-color: #a9c6c9;
      }
      .oddrowcolor{
        background-color:#ffffff;
      }
      .evenrowcolor{
        background-color:#f2f2f2;
      }
      </style>
  </head>
  
  <body id="plot-report" class="teacher">
    <!-- entire page container -->
    <div id="container">
      <div id="top">
        <div id="header">
          <%@ include file="../include/header.jsp" %>
          <div id="nav">
            <%@ include file="../include/nav-teacher.jsp" %>
          </div>
        </div>
      </div>
      
      <div id="content">
      <form id="plotReport" method="post">
          <h2>View plots and their details.</h2>
          <ul>
            <li>Choose a date range.</li>
            <li>Click on Retrieve Report to get the list of plots and their details.</li>
          </ul>
        <table>
          <tr>
            <td nowrap style="vertical-align: center;">Date Range
                <input type="text" name="fromDateSplit" id="fromDateSplit" size="12" value="<%=fromDate %>" class="datepicker1" ></input>
                to <input type="text" name="toDateSplit" id="toDateSplit" size="12" value="<%=toDate %>" class="datepicker1" ></input>  
            </td>
          </tr>
          <tr>      
            <td><div style="width: 100%; text-align:center;"><input type="submit" name="submit" value="Retrieve Report"/></div>
            </td>
          </tr>
          <tr>
            <td><div style="width: 100%; text-align:center;"><i>* This may take a while depending on the date range you choose.</i></div>
            </td>
          </tr>
        </table>
      </form>
      <c:choose>
            <c:when test="${not empty reportLines }"> 
                 <hr></hr>
                 <h2>Query Results</h2> 
                 <table class="altrowstable" id="alternatecolor">
                 <thead>
                 <tr name="details">
                    <th width="50px"><strong>Plot Name</strong></th>
                    <th width="120px"><strong>Group</strong></th>
                    <th width="120px"><strong>Teacher</strong></th>
                    <th width="200px"><strong>School</strong></th>
                    <th width="100px"><strong>City</strong></th>
                    <th width="50px"><strong>State</strong></th>
                    <th width="50px"><strong>Project</strong></th>
                 </tr>
                 </thead>
                 <c:forEach items="${reportLines}" var="filename">
                    <tr name="details">
                      <td width="50px" valign="top">${filename.key }</td>
                      <td width="120px" valign="top">${filename.value[1]}</td>
                      <td width="120px" valign="top">${filename.value[2]}</td>
                      <td width="200px" valign="top">${filename.value[3]}</td>
                      <td width="100px" valign="top">${filename.value[4]}</td>
                      <td width="50px" valign="top">${filename.value[5]}</td>
                      <td width="50px" valign="top">${filename.value[6]}</td>
                      
                  </c:forEach>          
                </table>
            </c:when>
      </c:choose>
      </div>
      <!-- end content -->  
    
      <div id="footer">
      </div>
    </div>
    <!-- end container -->
  </body>
</html>