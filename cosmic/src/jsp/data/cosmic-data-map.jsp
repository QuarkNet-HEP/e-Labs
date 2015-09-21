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
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<% 
     Collection allDaqs = (Collection) session.getAttribute("allDaqs");
     TreeMap<String,String> daqLatLong = new TreeMap<String,String>();
     for (Iterator i = allDaqs.iterator(); i.hasNext();) {
    	   String detectorid = (String) i.next();
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
        	  Double latPos = Double.parseDouble(latParts[0])+(Double.parseDouble(latParts[1])/60)+(Double.parseDouble(latParts[2])/1000000/60);
        	  Double lonPos = Double.parseDouble(lonParts[0])+(Double.parseDouble(lonParts[1])/60)+(Double.parseDouble(lonParts[2])/1000000/60);
        	  daqLatLong.put(detectorid, latPos+","+lonPos);         
       }
     }
     
     request.setAttribute("daqLatLong", daqLatLong);
     
     //TreeMap<Integer,String> allCities = DataTools.getCosmicDataMarkers(elab);
     //request.setAttribute("allCities", allCities);
     
     
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
    <style>
				#map_wrapper {
				    height: 500px;
				    width: 1000px;
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
            script.src = "http://maps.googleapis.com/maps/api/js?sensor=false&callback=initialize";
            document.body.appendChild(script);  
        }); 
 
        function initialize() {
            var map;
            var bounds = new google.maps.LatLngBounds();
            var mapOptions = {
                mapTypeId: 'roadmap'
            };
            // Display a map on the page
            map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
            map.setTilt(45);          

            var city = [];
            var latitude = [];
            var longitude = [];
            var cityDetails = document.getElementsByName("detectorDetails");
            if (cityDetails.length > 0) {
              for (var i=0; i < cityDetails.length; i++) {
                cityArr = cityDetails[i].value.split(',');
                if (cityArr[1] != "null" && cityArr[2] != "null") {
                  city.push(cityArr[0]);
                  latitude.push(cityArr[1]);
                  longitude.push(cityArr[2]);
                }
              }
            }

            // Loop through our array of markers & place each one on the map  
            for( i = 0; i < city.length; i++ ) {
                var position = new google.maps.LatLng(latitude[i], longitude[i]);
                bounds.extend(position);
                marker = new google.maps.Marker({
                    position: position,
                    map: map,
                    title: city[i]
                });
                
                // Automatically center the map fitting all markers on the screen
                map.fitBounds(bounds);
            }

        }
    </script>

  </head>
  
  <body id="data-map" class="data">
    <!-- entire page container -->
    <div id="container">
      <div id="top">
        <div id="header">
          <%@ include file="../include/header.jsp" %>
          <%@ include file="../include/nav-rollover.jspf" %>
        </div>
      </div>
      
      <div id="content">
        <table border="0" id="main">
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
