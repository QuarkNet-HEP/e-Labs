<%@ page import="java.io.*" %>
<%@ page import="org.griphyn.vdl.util.*" %>
<%@ page import="org.griphyn.vdl.classes.*" %>
<%@ page import="org.griphyn.vdl.dbschema.*" %>
<%@ page import="org.griphyn.vdl.directive.*" %>
<%@ page import="org.griphyn.vdl.annotation.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.regex.*" %>
<%@ page import="java.sql.*" %>
<%@ include file="common.jsp" %>
<%@ include file="include/javascript.jsp" %>

<html>
<head>
	<title>Detector Geometry Instructions</title>
	
		<!-- include css style file -->
        <!-- header/navigation -->
        <%
        //be sure to set this before including the navbar
        String headerType = "Upload";
        %>
        <%@ include file="include/navbar_common.jsp" %>
    	
    	<!-- creates variables ResultSet rs and Statement s to use: -->
		<%@ include file="include/jdbc_userdb.jsp" %>
		
		
		
</head>
<body>

	<center>
		<table cellpadding = 10 width = 100%>
			<tr>
				<td colspan = 2 valign = top>
					<center><h3>You should  upload geometry each time you move the detector.</h3><h4>Many calculations rely on knowing the detector's location.</h4></center>
				</td>
			</tr>
			
			<tr>
	
				<td valign = top>
					Here is a typical detector layout. The GPS unit is the 0,0,0 point of a coordinate system. In this example, the GPS unit is on the roof and the <A HREF="javascript:glossary('counter',350)">counters</a> are inside the classroom.
				</td>
				
				<td valign = top>
					The counters are arranged in this (x,y,z) coordinate system which our measurements refer to. Our example shows the plane containing the counters to be 4 meters below the plane containing the GPS.
				</td>
			</tr>
			
			<tr>
				<td>
					<img src="graphics/room.gif" alt="room.gif" width="375" height="288">
				</td>
				
				<td>
					<img src="graphics/grid.gif" alt="grid.gif" width="357" height="288">
				</td>
			</tr>
			
			<tr>
				<td colspan=2>
					<center>
						<p>
                        <table>
                            <tr>
                                <td>
						            Compare the values in the screen shot below to the diagram above.  We have circled Counter 1 and its values in orange to help you.  The geometry update page consists of three main areas: <b>Detector Geometry</b>, <b>Detector Configuration</b>, and <b>GPS Location</b>.  
                                    <ul>
                                        <li>The <b>Detector Geometry</b> area lists all detectors you own along with a listing of the dates on which you changed that detector's geometry.  You can edit (click <img src="graphics/geo_pencil.gif">) or delete (click <img src="graphics/delete_x.gif">) any entry, as well as add new ones for each detector (click <img src="graphics/geo_new.gif">).
                                        <li>The <b>Detector Configuration</b> area allows you to input the location of the counters.  The "Active Channels" checkboxes are to indicate which channels will have data in them while this geometry entry is in effect.  If you only have two counters and hooked them up to the second and third channel slots during your data run, you should only have the "2" and "3" boxes checked.  IMPORTANT: Make sure your "Active Channels" match up to the channels that you plugged your counters into on your DAQ board during your data run.  Cable Length refers to the length of the cables that connect the counters to the Readout Board, Area refers to the top surface area of the counter, and E-W, N-S, and Up-Dn refers to the position of the counters relative to the GPS antenna (see image above).  The "Orientation" refers to whether the counters are stacked (<img src="graphics/stacked.gif">) or spread out (<img src="graphics/unstacked.gif">).
                                        <li>The <b>GPS Location</b> area allows you to input the location of your GPS antenna and the length of the cable connecting it to the DAQ board.  If you link to the geometry page from the "Upload Successful!" page, the latitude, longitude, and altitude will automatically be filled in (as long as the "DG" command was used during the data run).
                                    </ul>
                                    This display is set up in an "array" orientation.  If your counters are set up in a "stacked" orientation, you should make sure that you accurately measure the altitude (Up-Dn) of each indivual counter instead of assuming that they're all at the same altitude.  Some of our analyses need to know the order in which the counters are stacked.<br>
                                    <br>Once all of the information is entered, click "Commit Geometry" to write that information to a file that will be used in future analyses.
                                </td>
                            </tr>
                        </table><br>
						<img src="graphics/grab.gif" alt="grab.gif" width="750" height="500">
					</center>
				</td>
			</tr>
		</table>
    </center>
    <center><h3>Error List</h3><h4>Seeing errors and unsure of what they mean?  Here's a list of the errors you might see to help you figure it out.</h4></center></center>
   <div id="error-list">
   <span class="error-message">Please check that your Date/Time values are all selected.</span><br>
        <ul>
            <li><b>Meaning: </b>You did not enter a value for all 5 fields of Date and Time (Month, Day, Year, Hour, Minute).  All 5 fields of the Date and Time need to be selected to provide the date for which your geometry changed.  If you linked to the geometry page from the "Upload Successful!" page, make sure the date you enter is BEFORE the start of that data run.
            <li><b>Fix: </b>Choose a valid value in each pulldown box (valid meaning not "Month", "Day", "Year", "Hour", "Minute").
        </ul>
    <span class="error-message">Date cannot exceed current date.</span><br>
        <ul>
            <li><b>Meaning: </b>You entered a Date and Time that is past the current Date and Time.  You cannot make a geometry entry for the future.  Remember, the Date and Time you enter must be the Date and Time in <a href="javascript:glossary('UTC')">UTC</a>, not your local Date and Time.
            <li><b>Fix: </b>Choose values for each pulldown box that corresponds to a Date and Time that is not past the current Date and Time.
        </ul>
   <span class="error-message">Date exactly matches that of an existing geometry entry.</span><br>
        <ul>
            <li><b>Meaning: </b>You entered a Date and Time that exactly matches the Date and Time of another geometry entry.  If you want to edit that geometry entry, you must click on the "edit" pencil next to that entry.
            <li><b>Fix: </b>Choose values for each pulldown box that do not create a Date and Time identical to that of another geometry entry.
        </ul>
    <span class="error-message">Please check that your channel 1 Cable Length value is correct.</span><br>
    <span class="error-message">Please check that your channel 2 Cable Length value is correct.</span><br>
    <span class="error-message">Please check that your channel 3 Cable Length value is correct.</span><br>
    <span class="error-message">Please check that your channel 4 Cable Length value is correct.</span><br>
        <ul>
            <li><b>Meaning: </b>You entered an invalid value for the given channel's (1, 2, 3, 4) cable length.  The cable length input will only accept positive numbers (integers, decimal numbers).  Additionally, it will not accept numbers with greater than 2 decimal places of precision.  For example, it will accept 10.24, but it will not accept 10.242.
            <li><b>Fix: </b>Enter a number with no more than 2 decimal places.
        </ul>
    <span class="error-message">Please check that your channel 1 Area value is correct.</span><br>
    <span class="error-message">Please check that your channel 2 Area value is correct.</span><br>
    <span class="error-message">Please check that your channel 3 Area value is correct.</span><br>
    <span class="error-message">Please check that your channel 4 Area value is correct.</span><br>
    <span class="error-message">Please check that your channel 1 E-W value is correct.</span><br>
    <span class="error-message">Please check that your channel 2 E-W value is correct.</span><br>
    <span class="error-message">Please check that your channel 3 E-W value is correct.</span><br>
    <span class="error-message">Please check that your channel 4 E-W value is correct.</span><br>
    <span class="error-message">Please check that your channel 1 N-S value is correct.</span><br>
    <span class="error-message">Please check that your channel 2 N-S value is correct.</span><br>
    <span class="error-message">Please check that your channel 3 N-S value is correct.</span><br>
    <span class="error-message">Please check that your channel 4 N-S value is correct.</span><br>
    <span class="error-message">Please check that your channel 1 Up-Dn value is correct.</span><br>
    <span class="error-message">Please check that your channel 2 Up-Dn value is correct.</span><br>
    <span class="error-message">Please check that your channel 3 Up-Dn value is correct.</span><br>
    <span class="error-message">Please check that your channel 4 Up-Dn value is correct.</span><br>
        <ul>
            <li><b>Meaning: </b>You entered an invalid value for the given channel's (1, 2, 3, 4) specified field (Area, E-W, N-S, Up-Dn).  These fields will only accept numbers (integers, decimal numbers, and negative numbers).  Area will not accept negative numbers.  To specify directions in the E-W, N-S, and Up-Dn fields, use positive (E, N, Up) and negative (W, S, Dn) numbers.
            <li><b>Fix: </b>Enter a number (positive for Area).
        </ul>
    <span class="error-message">With stacked orientation, the E-W values for all four channels should be equal.</span><br>
        <ul>
            <li><b>Meaning: </b>You indicated that your counters are stacked, but you also indicated that your counters have different E-W offsets from the GPS unit.  If your counters really <i>are</i> stacked, then they should all have the exact same E-W offset from the GPS unit.
            <li><b>Fix: </b>Either change your orientation from "Stacked" to "Unstacked" or give every channel's E-W field the same value.
        </ul>
    <span class="error-message">With stacked orientation, the N-S values for all four channels should be equal.</span><br>
        <ul>
            <li><b>Meaning: </b>You indicated that your counters are stacked, but you also indicated that your counters have different N-S offsets from the GPS unit.  If your counters really <i>are</i> stacked, then they should all have the exact same N-S offset from the GPS unit.
            <li><b>Fix: </b>Either change your orientation from "Stacked" to "Unstacked" or give every channel's N-S field the same value.
        </ul>
    <span class="error-message">With stacked orientation, the Up-Dn values for all four channels should be different.</span><br>
        <ul>
            <li><b>Meaning: </b>You indicated that your counters are stacked, but you also indicated that your counters have the same Up-Dn offsets from the GPS unit.  If your counters really <i>are</i> stacked, then they should all have a different Up-Dn offset from the GPS unit.  This is important because in some studies looking at stacked counters, we need to know the order in which the counters were stacked, and we get that information from the Up-Dn offsets that you put into the geometry entry.
            <li><b>Fix: </b>Either change your orientation from "Stacked" to "Unstacked" or give every channel's Up-Dn field a different value.
        </ul>
    <span class="error-message">Please check that your Latitude value is correct (see e.g. format below).</span><br>
        <ul>
            <li><b>Meaning: </b>You entered an incorrectly-formatted value for the latitude of your GPS unit.  The format must look like: 47:39.2347.
            <li><b>Fix: </b>Enter a correctly-formatted latitude value
        </ul>
    <span class="error-message">Please check that your Longitude value is correct (see e.g. format below).</span><br>
        <ul>
            <li><b>Meaning: </b>You entered an incorrectly-formatted value for the longitude of your GPS unit.  The format must look like: 122:18.68 W.
            <li><b>Fix: </b>Enter a correctly-formatted longitude value
        </ul>
    <span class="error-message">Please check that your Altitude value is correct.</span><br>
        <ul>
            <li><b>Meaning: </b>You entered an invalid value for the altitude of the GPS unit.  This field will only accept positive numbers (integers, decimal numbers).
            <li><b>Fix: </b>Enter a positive number.
        </ul>
    <span class="error-message">Please check that your GPS Cable Length value is correct.</span><br>
        <ul>
            <li><b>Meaning: </b>You entered an invalid value for the cable length connecting the GPS unit to the DAQ board.  This field will only accept positive numbers (integers, decimal numbers).
            <li><b>Fix: </b>Enter a positive number.
        </ul>
    </div><!-- error-list-->
</body>
</html>
