<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>GPS Coordinates Tutorial</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	<body id="shower-tutorial" class="data, tutorial">
		
	  <div id="container"><!-- entire page container -->
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
	  <div id="content">
      <h2>GPS Coordinates Tutorial</h2>
      <table>
		<tr  align="left">
		<td>
        1.  Review <a href="javascript:glossary('GPS_Coordinates',400,200)">GPS Coordinates</a>.
        <br></br>
        2.  The GPS Coordinates area allows you to input the location of your DAQ. If you link to the geometry page from the "Upload Successful!" page, the latitude, longitude, and altitude will automatically be filled in (as long as the "DG" command was used during the data run).
        <br></br>
        3.  Alternatively, you can determine your DAQ's location.    
           <ul style="list-style-type:disc">
              <li>Click          
                 <a href="http://www.gpsvisualizer.com/geocode" title="Find GPS coordinates" target="_blank">Find GPS Coordinates</a> or 
                 <a href="http://www.gpsvisualizer.com/geocode" title="Find GPS coordinates" target="_blank"><img border="0" src="../graphics/latlong.png" height="15px" width="15px" /></a>.  
              </li>
              <li>In the GPSVisualizer website, enter address where the DAQ collects data.  </li>
              <li>For example, here is the address for Fermilab:  Kirk Road and Pine Street Batavia IL 60510-5011. </li>
              <li>Click "Geocode it."</li>
              <li>Use the second row in the latitude, longitude section (N41&deg; 50.4386', W088&deg; 16.7739').  This is shown in degrees (&deg;) and minutes (').  There are 60 minutes in a degree. </li>
		      <li>Enter it like this in the Geometry page:  Latitude:  41:50.4386 N, Longitude:  88:16.7739 W.  </li>
              <li>  The N in latitude indicates that Fermilab is north of the equator, and the W in longitude indicates that 
              Fermilab is west of the Prime Meridian running through Greenwich, England.   </li>
           </ul>
        4.  Click "Map GPS Coordinates" or <img border="0" src="../graphics/world.png" height="15px" width="15px" /></a> on the Geometry page. 
           Check on the map that your DAQ shows up in the correct location.     
        </td>
        </tr>
      </table>
      </div><!-- end content -->	
	  </div><!-- end container -->
  
   </body>
</html>
