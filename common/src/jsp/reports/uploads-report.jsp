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
  TreeMap<Integer, VDSCatalogEntry> uploadResults = new TreeMap<Integer, VDSCatalogEntry>();
  TreeMap<String, ArrayList<ArrayList<String>>> reportLines = new TreeMap<String,ArrayList<ArrayList<String>>>();
  ArrayList<String> detectorIds = new ArrayList<String>();
  ArrayList<String[]> uploadReportData = new ArrayList<String[]>();
  ArrayList<ArrayList<String>> uploadReportDataDistinct = new ArrayList<ArrayList<String>>();
  
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
    for (Map.Entry<Integer,VDSCatalogEntry> e: uploadResults.entrySet()) {
    	    VDSCatalogEntry entry = e.getValue();
    	    if (!detectorIds.contains(entry.getTupleValue("detectorid"))) {
    	    	detectorIds.add((String)entry.getTupleValue("detectorid"));
    	    }
    	    String[] details = new String[6];
          details[0] = (String)  entry.getTupleValue("detectorid");
          details[1] = (String)  entry.getTupleValue("group");
          details[2] = (String)  entry.getTupleValue("teacher");
          details[3] = (String)  entry.getTupleValue("school");
          details[4] = (String)  entry.getTupleValue("city");
          details[5] = (String)  entry.getTupleValue("state");
          uploadReportData.add(details);
    } 
    //get frequency
    for (int i = 0; i < uploadReportData.size(); i++) {
    	  String[] details = uploadReportData.get(i);
    	  int detailCount = 0;
    	  for (int x = 0; x < uploadReportData.size(); x++) {
    		     if (Arrays.equals(details, uploadReportData.get(x))) {
    		    	  detailCount += 1;
    		     }
    	  }
    	  ArrayList<String> detailsDistinct = new ArrayList<String>();
    	  detailsDistinct.add(details[0]);
        detailsDistinct.add(details[1]);
        detailsDistinct.add(details[2]);
        detailsDistinct.add(details[3]);
        detailsDistinct.add(details[4]);
        detailsDistinct.add(details[5]);
        detailsDistinct.add(String.valueOf(detailCount));
        if (!uploadReportDataDistinct.contains(detailsDistinct)) {
        	   uploadReportDataDistinct.add(detailsDistinct);
        }
    }
    
    for (int i = 0; i < detectorIds.size(); i++) {
    	  ArrayList<ArrayList<String>> daqDetails = new ArrayList<ArrayList<String>>();
    	  for (int x = 0; x < uploadReportDataDistinct.size(); x++) {
    		  if (detectorIds.get(i).equals(uploadReportDataDistinct.get(x).get(0))) {
    			   daqDetails.add(uploadReportDataDistinct.get(x));
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
                 <table class="altrowstable" id="alternatecolor">
                 <tr name="details">
                    <th width="50px"><strong>DAQ#</strong></th>
                    <th width="120px"><strong>Group</strong></th>
                    <th width="120px"><strong>Teacher</strong></th>
                    <th width="200px"><strong>School</strong></th>
                    <th width="100px"><strong>City</strong></th>
                    <th width="50px"><strong>State</strong></th>
                    <th width="50px"><strong>Uploads</strong></th>
                 </tr>
                 <c:forEach items="${reportLines}" var="filename">
                    <tr name="details">
                      <td width="50px" valign="top">${filename.key }</td>
                      <td width="640px" colspan="6" valign="top">
                        <c:forEach items="${filename.value}" var="details">
                          <table>
                            <tr>
                              <td width="116px">${details[1]}</td>
                              <td width="116px">${details[2]}</td>
                              <td width="196px">${details[3]}</td>
                              <td width="96px">${details[4]}</td>
                              <td width="48px">${details[5]}</td>
                              <td width="44px">${details[6]}</td>
                            </tr>
                          </table>
                        </c:forEach>
                      </td>
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