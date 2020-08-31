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
  Calendar cal = Calendar.getInstance();
  cal.setTime(new Date());
  cal.add(Calendar.DATE, 1);    
  String fromDate = DATEFORMAT.format(cal.getTime());
  Date startDate = null;
  String messages = "";
  ResultSet searchResults = null;
  TreeMap<String, ArrayList<String>> reportLines = new TreeMap<String,ArrayList<String>>();

  if ("Retrieve Report".equals(submit)) {
	    //this query will bring all plots in the date range and we can also get the summary from it
    	if (StringUtils.isNotBlank(fromDate)) {
      		startDate = DATEFORMAT.parse(fromDate); 
    	}
 	    In and = new In();
	    and.add(new Equals("project", "cosmic"));
	    and.add(new Equals("type", "split"));
	    and.add(new GreaterOrEqual("startdate", startDate));
		searchResults = elab.getDataCatalogProvider().runQuery(and);
		for (Iterator i = searchResults.iterator(); i.hasNext(); ) {
		    CatalogEntry e = (CatalogEntry) i.next();
		    String lfn = e.getLFN();
	        ArrayList<String>details = new ArrayList<String>();
	        details.add((String) e.getTupleValue("name"));
	        details.add((String) e.getTupleValue("group"));
	        details.add((String) e.getTupleValue("teacher"));
	        details.add((String) e.getTupleValue("school"));
	        details.add((String) e.getTupleValue("city"));
	        details.add((String) e.getTupleValue("state"));
	        details.add((String) e.getTupleValue("project"));
	        reportLines.put(lfn, details);
		}
  }//end of submit
  request.setAttribute("reportLines", reportLines);
  request.setAttribute("messages", messages);
  
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">   
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>Splits with Future Dates Report</title>
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
  
  <body id="splits-with-future-date-report" class="teacher">
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
      <form id="splitsWithFutureDateReport" method="post">
          <h2>View splits with dates in the future.</h2>
          <ul>
            <li>Click on Retrieve Report to get the list of splits with future dates.</li>
          </ul>
        <table>
           <tr>      
            <td><div style="width: 100%; text-align:center;"><input type="submit" name="submit" value="Retrieve Report"/></div>
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
                     <th width="50px"><strong>Split File</strong></th>
                    <th width="120px"><strong>Group</strong></th>
                    <th width="120px"><strong>Teacher</strong></th>
                    <th width="200px"><strong>School</strong></th>
                    <th width="100px"><strong>City</strong></th>
                    <th width="50px"><strong>State</strong></th>
                    <th width="50px"><strong>Project</strong></th>
                   </tr>
                 <c:forEach items="${reportLines}" var="filename">
                    <tr name="details">
                      <td width="50px" valign="top">${filename.key }</td>
                      <td width="120px" valign="top">${filename.value[1]}</td>
                      <td width="120px" valign="top">${filename.value[2]}</td>
                      <td width="200px" valign="top">${filename.value[3]}</td>
                      <td width="100px" valign="top">${filename.value[4]}</td>
                      <td width="50px" valign="top">${filename.value[5]}</td>
                      <td width="50px" valign="top">${filename.value[6]}</td>
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