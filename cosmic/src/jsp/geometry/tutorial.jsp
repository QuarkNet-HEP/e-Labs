<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>

<jsp:useBean id="e" scope="request" class="gov.fnal.elab.cosmic.beans.GeometryErrors" />

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Detector Geometry Instructions</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/upload.css"/>
		<link rel="stylesheet" type="text/css" href="../css/geo.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="tutorial" class="data geo">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-upload.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">
			<center>
	           <font color="#0a5ca6" size=+3><b>Geometry Tutorial</b></font>
	        </center>	
	        
<table border="0" id="main">
	<tr>
		<td id="center">
			<h3>You should upload geometry each time you move the detector.</h3>
			<h4>Many calculations rely on knowing the detector's location.</h4>
			
			<table border="0" width="100%" cellspacing="10">
				<tr>
					<td style="border:1px solid black; background:yellow;">
						Here is a typical detector layout. The GPS unit is the 0,0,0 point of a 
						coordinate system. In this example, the GPS unit is on the roof, and the 
						<a href="javascript:glossary('counter',350)">counters</a> are inside the classroom.
					</td>
					
					<td style="border:1px solid black; background:yellow;">
						The counters are arranged in this (x,y,z) coordinate system which our measurements 
						refer to. Our example shows the plane containing the counters to be 4 meters below 
						the plane containing the GPS.
					</td>
				</tr>
			
				<tr>
					<td>
						<img src="../graphics/room.gif" alt="room.gif" width="375" height="288" />
					</td>
					
					<td>
						<img src="../graphics/grid.gif" alt="grid.gif" width="357" height="288" />
					</td>
				</tr>
			</table>
			
			<p>
	            Compare the values in the screen shot below to the diagram above.
	            We have circled Counter 1 and its values to help you.
	            The geometry update page consists of three main areas: <b><i>Detectory List</i></b> in the purple box on the side, <b><i>Detector Geometry</i></b>, 
	            and <b><i>GPS Coordinates</i></b>.
	        </p>  
            <ul>
                <li>
                	The <b><i>Detector List</i></b> area lists all detectors you own along 
                	with a listing of the dates on which you changed that detector's 
                	geometry. For any entry, you can <b>edit</b> (click <img src="../graphics/geo_pencil.gif" />),  
                	<b>delete</b> (click <img src="../graphics/delete_x.gif" />), <b>duplicate</b> (click  <img src="../graphics/saveas.gif" />), 
                	or <b>view map</b> (click <img border="0" src="../graphics/world.png" height="15px" width="15px" />), 
                	as well as <b>add</b> new ones for each detector (click <img src="../graphics/geo_new.gif" />).<br></br>
                </li>
                <li>
                	The <b><i>Detector Geometry</i></b> area allows you to input the location
                	of the counters.  The "Active Channels" checkboxes are to indicate 
                	which channels will have data in them while this geometry entry is in 
                	effect. If you only have two counters and hooked them up to the second 
                	and third channel slots during your data run, you should only have the 
                	"2" and "3" boxes checked.  IMPORTANT: Make sure your "Active Channels" 
                	match up to the channels that you plugged your counters into on your 
                	DAQ board during your data run.  Cable Length refers to the length of 
                	the cables that connect the counters to the Readout Board.  Area refers 
                	to the top surface area of the counter.  E-W, N-S, and Up-Dn refer 
                	to the position of the counters relative to the GPS antenna (see image 
                	above).  The "Orientation" refers to whether the counters are stacked 
                	(<img src="../graphics/stacked.gif" />) or spread out 
                	(<img src="../graphics/unstacked.gif" />).<br></br>
                </li>
                <li>
                	The <b><i>GPS Coordinates</i></b> area allows you to input the location of your 
                	GPS antenna and the length of the cable connecting it to the DAQ board.
                </li>
            </ul>
            
            <p>
	            This display is set up in an "unstacked", or "array", orientation.  If your counters are set up 
	            in a "stacked" orientation, you should make sure that you accurately measure 
	            the altitude (Up-Dn) of each indivual counter instead of assuming that they're 
	            all at the same altitude.  Some of our analyses need to know the order in which 
	            the counters are stacked.
	        </p>
            <p>
            	Once all of the information is entered, click "Commit Geometry" to write that 
            	information to a file that will be used in future analyses.
                    
				<center><img src="../graphics/geometry_sections.png" alt="geometry_sections.png" width="500" height="500" /></center>
			</p>
			
   			<h3>Error List</h3>
   			<h4>
   				Seeing errors and unsure of what they mean?  Here's a list of the errors you 
   				might see to help you figure it out.
   			</h4>
   			<div id="error-list">
   				<a name="${e.keys['date-field-not-set']}"></a>
   				<p class="error-message">${e.errors['date-field-not-set']}</p>
        		<ul>
            		<li>
            			<b>Meaning: </b>You did not enter a value for all 5 fields of Date and 
            			Time (Month, Day, Year, Hour, Minute).  All 5 fields of the Date and 
            			Time need to be selected to provide the date for which your geometry 
            			changed.  If you linked to the geometry page from the "Upload Successful!" 
            			page, make sure the date you enter is BEFORE the start of that data run.
            		</li>
            		<li>
            			<b>Fix: </b>Choose a valid value in each pulldown box (valid meaning not 
            			"Month", "Day", "Year", "Hour", "Minute").
            		</li>
        		</ul>
    			<a name="${e.keys['date-in-the-future']}"></a>
   				<p class="error-message">${e.errors['date-in-the-future']}</p>
        		<ul>
            		<li>
            			<b>Meaning: </b>You entered a Date and Time that is past the current Date 
            			and Time.  You cannot make a geometry entry for the future.  Remember, 
            			the Date and Time you enter must be the Date and Time in 
            			<a href="javascript:glossary('UTC')">UTC</a>, not your local Date and Time.
            		</li>
            		<li>
            			<b>Fix: </b>Choose values for each pulldown box that corresponds to a Date 
            			and Time that is not past the current Date and Time.
            		</li>
        		</ul>
   				<a name="${e.keys['date-existing']}"></a>
   				<p class="error-message">${e.errors['date-existing']}</p>
        		<ul>
            		<li>
            			<b>Meaning: </b>You entered a Date and Time that exactly matches the Date 
            			and Time of another geometry entry.  If you want to edit that geometry entry, 
            			you must click on the "edit" pencil next to that entry.
            		</li>
            		<li>
            			<b>Fix: </b>Choose values for each pulldown box that do not create a Date and 
            			Time identical to that of another geometry entry.
            		</li>
        		</ul>
        		<c:forEach var="i" items="1,2,3,4">
        			<c:set var="key" value="channel${i}-cable-length"/>
        			<a name="${e.keys[key]}"></a>
   					<p class="error-message">${e.errors[key]}</p>
   				</c:forEach>
		        <ul>
		            <li>
		            	<b>Meaning: </b>You entered an invalid value for the given channel's (1, 2, 3, 4) 
		            	cable length.  The cable length input will only accept positive numbers 
		            	(integers, decimal numbers).
		            </li>
		            <li>
		            	<b>Fix: </b>Enter a positive number.
		            </li>
		        </ul>
		        <c:forEach var="i" items="1,2,3,4">
		        	<c:forEach var="j" items="area,ew,ns,ud">
		        		<c:set var="key" value="channel${i}-${j}"/>
		        		<a name="${e.keys[key]}"></a>
	   					<p class="error-message">${e.errors[key]}</p>
		        	</c:forEach>
	   			</c:forEach>
        		<ul>
		            <li>
		            	<b>Meaning: </b>You entered an invalid value for the given channel's 
		            	(1, 2, 3, 4) specified field (Area, E-W, N-S, Up-Dn).  These fields will 
		            	only accept numbers (integers, decimal numbers, and negative numbers).  
		            	Area will not accept negative numbers.  To specify directions in the 
		            	E-W, N-S, and Up-Dn fields, use positive (E, N, Up) and negative 
		            	(W, S, Dn) numbers.
		            </li>
		            <li>
		            	<b>Fix: </b>Enter a number (positive for Area).
		            </li>
		        </ul>
    			<a name="${e.keys['stacked-ew']}"></a>
   				<p class="error-message">${e.errors['stacked-ew']}</p>
		        <ul>
		            <li>
		            	<b>Meaning: </b>You indicated that your counters are stacked, but you 
		            	also indicated that your counters have different E-W offsets from the 
		            	GPS unit. If your counters really <i>are</i> stacked, then they should 
		            	all have the exact same E-W offset from the GPS unit.
		            </li>
		            <li>
		            	<b>Fix: </b>Either change your orientation from "Stacked" to "Unstacked" 
		            	or give every channel's E-W field the same value.
		            </li>
		        </ul>
    			<a name="${e.keys['stacked-ns']}"></a>
   				<p class="error-message">${e.errors['stacked-ns']}</p>
		        <ul>
		            <li>
		            	<b>Meaning: </b>You indicated that your counters are stacked, but you 
		            	also indicated that your counters have different N-S offsets from the 
		            	GPS unit.  If your counters really <i>are</i> stacked, then they 
		            	should all have the exact same N-S offset from the GPS unit.
		            </li>
		            <li>
		            	<b>Fix: </b>Either change your orientation from "Stacked" to "Unstacked" 
		            	or give every channel's N-S field the same value.
		            </li>
		        </ul>
    			<a name="${e.keys['stacked-ud']}"></a>
   				<p class="error-message">${e.errors['stacked-ud']}</p>
		        <ul>
		            <li>
		            	<b>Meaning: </b>You indicated that your counters are stacked, but you 
		            	also indicated that your counters have the same Up-Dn offsets from the 
		            	GPS unit.  If your counters really <i>are</i> stacked, then they should
		            	 all have a different Up-Dn offset from the GPS unit. This is important 
		            	 because in some studies looking at stacked counters, we need to know 
		            	 the order in which the counters were stacked, and we get that 
		            	 information from the Up-Dn offsets that you put into the geometry entry.
		            </li>
		            <li>
		            	<b>Fix: </b>Either change your orientation from "Stacked" to "Unstacked" 
		            	or give every channel's Up-Dn field a different value.
		            </li>
		        </ul>
    			<a name="${e.keys['latitude']}"></a>
   				<p class="error-message">${e.errors['latitude']}</p>
		        <ul>
		            <li>
		            	<b>Meaning: </b>You entered an incorrectly-formatted value for the 
		            	latitude of your GPS unit.  The format must look like: 47:39.2347.
		            </li>
		            <li>
		            	<b>Fix: </b>Enter a correctly-formatted latitude value
		            </li>
		        </ul>
    			<a name="${e.keys['longitude']}"></a>
   				<p class="error-message">${e.errors['longitude']}</p>
		        <ul>
		            <li>
		            	<b>Meaning: </b>You entered an incorrectly-formatted value for the 
		            	longitude of your GPS unit.  The format must look like: 122:18.68 W.
		            </li>
		            <li>
		            	<b>Fix: </b>Enter a correctly-formatted longitude value
		            </li>
		        </ul>
    			<a name="${e.keys['altitude']}"></a>
   				<p class="error-message">${e.errors['altitude']}</p>
		        <ul>
		            <li>
		            	<b>Meaning: </b>You entered an invalid value for the altitude of the 
		            	GPS unit.  This field will only accept positive numbers (integers, 
		            	decimal numbers).
		            </li>
		            <li>
		            	<b>Fix: </b>Enter a positive number.
		            </li>
		        </ul>
    			<a name="${e.keys['gps-cable-length']}"></a>
   				<p class="error-message">${e.errors['gps-cable-length']}</p>
		        <ul>
		            <li>
		            	<b>Meaning: </b>You entered an invalid value for the cable length 
		            	connecting the GPS unit to the DAQ board.  This field will only accept 
		            	positive numbers (integers, decimal numbers).
		            </li>
		            <li>
		            	<b>Fix: </b>Enter a positive number.
		            </li>
		        </ul>
			</div>
		</td>
	</tr>
</table>


			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
