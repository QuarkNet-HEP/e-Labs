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
				    height: 750px;
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
            script.src = "https://maps.googleapis.com/maps/api/js?sensor=false&callback=initialize";
            document.body.appendChild(script);  
        }); 
 
        function initialize() {
            var map;
            var bounds = new google.maps.LatLngBounds();
            var mapOptions = {
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
            var school = [];
            var city = [];
            var state = [];
            var stacked = [];
            var teacher = [];
            var latest = [];
            var uploads = [];
            var detectorUploads = [];
            
            var detectorDetails = document.getElementsByName("detectorDetails");
            if (detectorDetails.length > 0) {
              for (var i=0; i < detectorDetails.length; i++) {
                daqArr = detectorDetails[i].value.split(',');
                if (daqArr[1] != "null" && daqArr[2] != "null") {
                	daq.push(daqArr[0]);
                  latitude.push(daqArr[1]);
                  longitude.push(daqArr[2]);
                  school.push(daqArr[3]);
                  city.push(daqArr[4]);
                  state.push(daqArr[5]);
                  stacked.push(daqArr[6]);
                  teacher.push(daqArr[7]);
                  latest.push(daqArr[8]);
                  uploads.push(daqArr[9])
                  detectorUploads.push(new detectorInfo(daqArr[0],daqArr[9]));
                }
              }
            }
            detectorUploads.sort(function (a,b) {

            	var uA=parseInt(a.uploadcount), uB=parseInt(b.uploadcount);

            	if (uA > uB)
            	  return -1;
            	if (uA < uB)
            	  return 1;
            	return 0;  //no sorting

            	});
            var marqueeText = "<strong>Detector</strong>:Total Uploads &rarr; ";
            for (var x = 0; x < detectorUploads.length; x++) {
            	var addStar = '';
            	if (x < 3) {
            		addStar = '<span style="color: red;">&#x2605;</span>';
            	}
            	marqueeText += addStar+" <strong>"+detectorUploads[x].detectorid + "</strong>:" + detectorUploads[x].uploadcount + " &#8226; ";
            }
            document.getElementById("scrollMarquee").innerHTML = marqueeText;
            
            // Loop through our array of markers & place each one on the map  
            for( i = 0; i < daq.length; i++ ) {
                var position = new google.maps.LatLng(latitude[i], longitude[i]);
                bounds.extend(position);
                var daqForm = createDataLink('DAQ#:','detectorid',daq[i].trim());
                var schoolForm = createDataLink('School:','school',school[i].trim());
                var cityForm = createDataLink('City:','city',city[i].trim());
                var stateForm = createDataLink('State:','state',state[i].trim());
                var stackedForm = createDataLinkOther('Stacked:','stacked',stacked[i].trim());
                var teacherInfo = 'Teacher: ' + teacher[i].trim() +'<br />';
                var latestInfo = 'Last Upload: ' + latest[i].trim() + '<br />';
                var examineYear = latest[i].trim().split('-');
                var markerIcon = "http://maps.google.com/mapfiles/ms/icons/blue-dot.png";
                var thisYear = new Date().getFullYear();
                if (parseInt(examineYear[0]) == thisYear) {
                    markerIcon = "http://maps.google.com/mapfiles/ms/icons/red-dot.png";
                }
                var uploadsInfo = 'Total Files: ' + uploads[i].trim() + '<br />';
                var marker = new google.maps.Marker({
                    position: position,
                    icon: markerIcon,
                    map: map,
                    title: daq[i].trim(),
                    clickable: true
                });
                var content =  '<div id="daqContent" style="text-align: left;">'+
                               daqForm + schoolForm + cityForm + stateForm + stackedForm + teacherInfo + latestInfo + uploadsInfo +
                               '</div>';
                var infowindow = new google.maps.InfoWindow({maxWidth:250});
                
                google.maps.event.addListener(marker, 'click', (function(marker,content,infowindow){
                	return function() {
                		infowindow.setContent(content);
                		infowindow.open(map,marker);
                	}
                })(marker,content,infowindow));
                

                // Automatically center the map fitting all markers on the screen
                map.fitBounds(bounds);
            }
          }
          function createDataLink(keyname, key, value) {
        	  var submitToPage = document.getElementById("submitToPage");
        	  var lastMonth = document.getElementById("lastMonth");
        	  var dataLink = '<form action="'+submitToPage.value+'" name="searchForm" method="post">'+
              '<input type="hidden" name="key" value="'+key+'" />'+
              '<input type="hidden" name="value" value="'+value+'" />'+
              '<input type="hidden" name="date1" value="'+lastMonth.value+'" />'+
              '<input type="hidden" name="submitFromMap" value=true />'+keyname+' '+                
              '<a href="#" onclick="$(this).closest(&quot;form&quot;).submit()">'+value+'</a>'+
              '</form>';
        		return dataLink;
          }
          function createDataLinkOther(keyname, key, value) {
              var submitToPage = document.getElementById("submitToPage");
              var lastMonth = document.getElementById("lastMonth");
              var newValue = "";
              if (value == true && key == "stacked") {
            	  newValue = "yes";
              } else {
            	  newValue = "no";
              }
              var dataLink = '<form action="'+submitToPage.value+'" name="searchForm" method="post">'+
                '<input type="hidden" name="'+key+'" value="'+newValue+'" />'+
                '<input type="hidden" name="date1" value="'+lastMonth.value+'" />'+
                '<input type="hidden" name="submitFromMap" value=true />'+keyname+' '+                
                '<a href="#" onclick="$(this).closest(&quot;form&quot;).submit()">'+value+'</a>'+
                '</form>';
              return dataLink;
          }
          function detectorInfo(detectorid, uploadcount) {
        	  this.detectorid = detectorid;
        	  this.uploadcount = uploadcount;
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
      <h1>Worldwide DAQ Information</h1>
      <ul>
        <li>Click on DAQ markers to view information.</li>
        <li>If your detector appears in the wrong place, you need to update the geometry file.</li>
        <li>Inside information window click on links to search and view uploaded data. By default we are retrieving the last 3 months worth of data for the criteria you choose.</li>
        <li><img src="http://maps.google.com/mapfiles/ms/icons/red-dot.png" witdh="12px" height="12px"></img>Detectors that uploaded this calendar year</li>
        <li><img src="http://maps.google.com/mapfiles/ms/icons/blue-dot.png" witdh="12px" height="12px"></img>Older uploads</li>
      </ul>      
      </div>
      <div>
        <table border="0">
          <tr><td><div style="display: none;"><marquee id="scrollMarquee" onMouseover="this.scrollAmount=2" onMouseout="this.scrollAmount=2">Scrolling text here</marquee></div></td></tr>
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
      <input type="hidden" name="lastMonth" id="lastMonth" value="<%=DATEFORMAT.format(lastMonth.getTime())%>"></input>
      <p>${message }</p>
      <!-- end content -->  
    
      <div id="footer">
      </div>
    </div>
    <!-- end container -->
  </body>
</html>
