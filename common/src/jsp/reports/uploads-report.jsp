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
    fromDate = DATEFORMAT.format(Calendar.getInstance().getTime());
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
  TreeMap<Integer, VDSCatalogEntry> uploadResults = new TreeMap<Integer, VDSCatalogEntry>();
  TreeMap<String, ArrayList<String>> reportLines = new TreeMap<String,ArrayList<String>>();
  
  if ("Retrieve Report".equals(submit)) {
    if (StringUtils.isNotBlank(fromDate)) {
      startDate = DATEFORMAT.parse(fromDate); 
    }
    if (StringUtils.isNotBlank(toDate)) {
      endDate = DATEFORMAT.parse(toDate); 
    }
    //this query will bring all splits in the date range and we can also get the summary from it
    uploadResults = DataTools.getVDSCatalogEntries(elab, startDate, endDate, "cosmic", "split");
    
    //prepare results by detectorid
    ArrayList<String> detectorIds = new ArrayList<String>();
    for (Map.Entry<Integer,VDSCatalogEntry> e: uploadResults.entrySet()) {
    	    VDSCatalogEntry entry = e.getValue();
    	    if (!detectorIds.contains(entry.getTupleValue("detectorid"))) {
    	    	detectorIds.add((String)entry.getTupleValue("detectorid"));
    	    }
    }  
    for (int i = 0; i < detectorIds.size(); i++) {
    	  ArrayList<String> daqDetails = new ArrayList<String>();
        for (Map.Entry<Integer,VDSCatalogEntry> e: uploadResults.entrySet()) {
            VDSCatalogEntry entry = e.getValue();
            if (detectorIds.get(i).equals(entry.getTupleValue("detectorid"))) {
            	  String details = (String) entry.getTupleValue("group") + "," + (String) entry.getTupleValue("teacher") + "," + (String) entry.getTupleValue("school");
            	  if (!daqDetails.contains(details)) {
            		  daqDetails.add(details);
            	  }
            }
        }
        reportLines.put(detectorIds.get(i), daqDetails);
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
    <title>Uploads Report</title>
    <link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
    <link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
    <link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
    <script type="text/javascript" src="../include/jquery/js/jquery-1.6.1.min.js"></script>   
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
        if ($("#splits-results").find("tbody").find("tr").size() > 0) {
            // call the tablesorter plugin 
            $("#splits-results").tablesorter({ 
                // sort on the second column and first column, order asc 
                sortList: [[1,0],[0,0]] 
            }); 
        }
        if ($("#quality-data-results").find("tbody").find("tr").size() > 0) {
            // call the tablesorter plugin 
            $("#quality-data-results").tablesorter({ 
                // sort on the second column and first column, order asc 
                sortList: [[0,0],[0,0]] 
            }); 
        }
      }); 
    </script>
  </head>
  
  <body id="uploads-report" class="teacher">
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
      <form id="uploadReport" method="post">
          <h2>View splits and their details.</h2>
          <ul>
            <li>Choose a date range.</li>
            <li>Click on Retrieve Report to get the list of uploaded files and their details.</li>
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
                 <table>
                 <tr>
                    <td><strong>DAQ#</strong></td>
                    <td><strong>Group,Teacher,School</strong></td>
                 </tr>
                 <c:forEach items="${reportLines}" var="filename">
                    <tr>
                      <td>${filename.key }</td>
                      <td>
                        <c:forEach items="${filename.value}" var="det">
                          ${det }<br />
                        </c:forEach>
                      </td>
                    </tr>
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