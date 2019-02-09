<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>
<%@ page import="gov.fnal.elab.util.ElabException" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.apache.commons.lang.time.DateUtils" %>
<%@ page import="gov.fnal.elab.cosmic.Geometry" %>
<%@ page import="gov.fnal.elab.cosmic.beans.GeoEntryBean" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.regex.*" %>
<% 
     String submitToPage = request.getParameter("submitToPage");
     String study = request.getParameter("study");
     Collection allDaqs = (Collection) session.getAttribute("allDaqs");
     TreeMap<String,String> daqLatLong = new TreeMap<String,String>();
     TreeMap<String,String> daqUploadDetails = new TreeMap<String,String>();
     daqUploadDetails = DataTools.getDAQLatestUploadData(elab);
     String message = "";
     
     for (Iterator i = allDaqs.iterator(); i.hasNext();) {
    	   String detectorid = (String) i.next();
    	   try {
		         Geometry g = new Geometry(elab.getProperties().getDataDir(), Integer.parseInt(detectorid));
		         Iterator it = g.getDescendingGeoEntries();
		         if (it.hasNext()) {
		        	  GeoEntryBean geb = (GeoEntryBean) it.next();
		        	  String latitude = geb.getFormattedLatitude();
		        	  String longitude = geb.getFormattedLongitude();
		        	  String[] latParts = latitude.split("(:)|(\\.)");
		        	  String[] lonParts = longitude.split("(:)|(\\.)");
		        	  latParts[2] = String.format("%1$-6s", latParts[2]).replace(' ', '0');
		        	  lonParts[2] = String.format("%1$-6s", lonParts[2]).replace(' ', '0');  
		        	  Double latPos = 0.0;
		        	  Double lonPos = 0.0;
		        	  if (Double.parseDouble(latParts[0]) > 0) {
		        		    latPos = Double.parseDouble(latParts[0])+(Double.parseDouble(latParts[1])/60)+(Double.parseDouble(latParts[2])/1000000/60);
		        	  } else {
		                latPos = Double.parseDouble(latParts[0])-(Double.parseDouble(latParts[1])/60)-(Double.parseDouble(latParts[2])/1000000/60);        		  
		        	  }
		        	  if (Double.parseDouble(lonParts[0]) > 0) {
		        		    lonPos = Double.parseDouble(lonParts[0])+(Double.parseDouble(lonParts[1])/60)+(Double.parseDouble(lonParts[2])/1000000/60);
		        	  } else {
		                lonPos = Double.parseDouble(lonParts[0])-(Double.parseDouble(lonParts[1])/60)-(Double.parseDouble(lonParts[2])/1000000/60);        		  
		        	  }
		        	  if (daqUploadDetails.get(detectorid) != null) {
		        		       daqLatLong.put(detectorid, latPos+","+lonPos+","+daqUploadDetails.get(detectorid));   
		        	  }
		         }
    	   } catch (Exception e) {
    		    message += detectorid + ": " + e.getMessage()+"<br />";
    	   }
     }
     SimpleDateFormat DATEFORMAT = new SimpleDateFormat("MM/dd/yyyy");
     DATEFORMAT.setLenient(false);
     Calendar cal = Calendar.getInstance();
     cal.setTime(new Date());
     cal.add(Calendar.DATE, 1);    
     Calendar lastMonth = Calendar.getInstance();
     lastMonth.add(Calendar.MONTH,-3);       
     request.setAttribute("message", message);    
     request.setAttribute("lastMonth", lastMonth);    
     request.setAttribute("daqLatLong", daqLatLong);    
     request.setAttribute("submitToPage", submitToPage);
     request.setAttribute("study", study);

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>Cosmic Data Map</title>
    <link rel="stylesheet" type="text/css" href="../css/style2.css"/>
    <link rel="stylesheet" type="text/css" href="../css/data.css"/>
    <link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
    <script type="text/javascript" src="../include/elab.js"></script>
    <script type="text/javascript" src="../include/jquery/js/jquery-1.6.1.min.js"></script>
    <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?v=3.exp"></script>
	<!-- <script async defer src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCLzaP-ovuMxiqiuMsPKTBQLSpDdFPR4uc" type="text/javascript"></script> -->
    <script type="text/javascript" src="../include/oms/oms.min.js"></script>
    <script type="text/javascript" src="cosmic-data-map.js"></script>
    <style>
				#map_wrapper {
				    height: 870px;
				    width: 1024px;
				}
				
				#map_canvas {
				    width: 100%;
				    height: 100%;
				}
    </style>
    <script type="text/javascript">
    </script>
  </head>
  
  <body id="data-map">
    <!-- entire page container -->
    <div id="container">
      <div id="top">
        <div id="header">
          <%@ include file="../include/header.jsp" %>
          <%@ include file="../include/nav-rollover.jspf" %>
        </div>
      </div>
      
      <div id="content">
      <h1>Worldwide DAQ Information - Beta Version</h1>
      <ul>
        <li>Click on DAQ markers to view information. The coordinates are read from the geometry file.</li>
        <li>If your detector appears in the wrong place, you need to update the geometry file.</li>
        <li>Inside information window click on links to search and view uploaded data. By default we are retrieving the last 3 months worth of data for the criteria you choose.</li>
        <li><img src="https://maps.google.com/mapfiles/ms/icons/red-dot.png" witdh="12px" height="12px"></img>Detectors with data uploaded this calendar year</li>
        <li><img src="https://maps.google.com/mapfiles/ms/icons/blue-dot.png" witdh="12px" height="12px"></img>Older uploads</li>
      </ul>      
      </div>
      <div>
        <table border="0">
           <tr><td>          
		          <div id="map_wrapper">				
					         <div id="map_canvas" class="mapping"></div>
		          </div>		          
          </td></tr>
         </table>
      </div>
      <c:forEach items="${daqLatLong }" var="detector">
          <input type="hidden" name="detectorDetails" id="detectorDetails${detector.key }" value='${detector.key },${detector.value }'></input>
      </c:forEach>
      <input type="hidden" name="submitToPage" id="submitToPage" value="${submitToPage}"></input>
      <input type="hidden" name="study" id="study" value="${study}"></input>
      <input type="hidden" name="lastMonth" id="lastMonth" value="<%=DATEFORMAT.format(lastMonth.getTime())%>"></input>

      <!-- end content -->  
    
      <div id="footer">
      </div>
    </div>
    <!-- end container -->
  </body>
</html>

