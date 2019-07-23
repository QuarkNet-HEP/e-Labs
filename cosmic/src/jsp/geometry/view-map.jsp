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
     String detectorid = request.getParameter("detectorID");
     String jd = request.getParameter("jd");
     String referer = request.getHeader("Referer");

     TreeMap<String,String> daqLatLong = new TreeMap<String,String>();
     Geometry g = new Geometry(elab.getProperties().getDataDir(), Integer.parseInt(detectorid));
     Iterator it = g.getDescendingGeoEntries();
     while (it.hasNext()) {
        GeoEntryBean geb = (GeoEntryBean) it.next();
        String juliandate = geb.getJulianDay();
        if (juliandate.equals(jd)) {
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
        	  daqLatLong.put(detectorid, latPos+","+lonPos+","+geb.getLatitude()+","+geb.getLongitude());
       }
     }
     
     request.setAttribute("daqLatLong", daqLatLong);    
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>Geometry Map</title>
    <link rel="stylesheet" type="text/css" href="../css/style2.css"/>
    <link rel="stylesheet" type="text/css" href="../css/upload.css"/>
    <link rel="stylesheet" type="text/css" href="../css/geo.css"/>
    <link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
    <script type="text/javascript" src="../include/elab.js"></script>
    <script type="text/javascript" src="../include/jquery/js/jquery-1.6.1.min.js"></script>   
    <style>
        #map_wrapper {
            height: 600px;
            width: 800px;
        }
        
        #map_canvas {
            width: 100%;
            height: 100%;
        }
    </style>
    <script type="text/javascript">
  
        $(document).ready(function() {
            // Asynchronously Load the map API 
            var script = document.createElement('script');
            script.src = "https://maps.googleapis.com/maps/api/js?key=AIzaSyAVf4myirajaV-MiYHSGewHgxxF6zok07w&sensor=false&callback=initialize";
            document.body.appendChild(script);  
        }); 
 
        function initialize() {
            var map;
            var bounds = new google.maps.LatLngBounds();
            var mapOptions = {
            		maxZoom: 15,
                rotateControl: true,
                mapTypeControl: true,
                style: google.maps.MapTypeControlStyle.DROPDOWN_MENU,
                mapTypeIds: [
                      google.maps.MapTypeId.ROADMAP,
                      google.maps.MapTypeId.TERRAIN
                      ]
            };
            // Display a map on the page
            map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
            map.setTilt(45);          

            var daq = [];
            var latitude = [];
            var longitude = [];
            var displayLatitude = [];
            var displayLongitude = [];
            var detectorDetails = document.getElementsByName("detectorDetails");
            if (detectorDetails.length > 0) {
              for (var i=0; i < detectorDetails.length; i++) {
                daqArr = detectorDetails[i].value.split(',');
                if (daqArr[1] != "null" && daqArr[2] != "null") {
                  daq.push(daqArr[0]);
                  latitude.push(daqArr[1]);
                  longitude.push(daqArr[2]);
                  displayLatitude.push(daqArr[3]);
                  displayLongitude.push(daqArr[4]);
                }
              }
            }
            
            // Loop through our array of markers & place each one on the map  
            for( i = 0; i < daq.length; i++ ) {
                var position = new google.maps.LatLng(latitude[i], longitude[i]);
                bounds.extend(position);
                var markerIcon = "http://maps.google.com/mapfiles/ms/icons/red-dot.png";
                var marker = new google.maps.Marker({
                    position: position,
                    icon: markerIcon,
                    map: map,
                    title: daq[i].trim(),
                    clickable: true
                });               
                var infowindow = new google.maps.InfoWindow({maxWidth:250});
                infowindow.setContent("<strong>DAQ# "+daq[i].trim()+"</strong><br />"+ "Latitude: "+displayLatitude[i] + "<br />Longitude: "+displayLongitude[i]);
                infowindow.open(map,marker);
                
                // Automatically center the map fitting all markers on the screen
                map.fitBounds(bounds);
            }
          }
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
      <h1>Geometry information for DAQ# <%=detectorid %></h1>
      <a href="<%=referer%>">Go back to geometry</a>
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
      <!-- end content -->  
    
      <div id="footer">
      </div>
    </div>
    <!-- end container -->
  </body>
</html>
