<%@ page import="java.io.*" %>
<%@ page import="org.griphyn.vdl.util.*" %>
<%@ page import="org.griphyn.vdl.classes.*" %>
<%@ page import="org.griphyn.vdl.dbschema.*" %>
<%@ page import="org.griphyn.vdl.directive.*" %>
<%@ page import="org.griphyn.vdl.annotation.*" %>
<%@ page import="org.griphyn.common.util.Separator" %>
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
					The scintillators are arranged in this (x,y,z) coordinate system which our measurements refer to. Our example shows the plane containing the scintillators to be 4 meters below the plane containing the GPS.
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
                                        <li>The <b>Detector Configuration</b> area allows you to input the location of the counters.  Cable Length refers to the length of the cables that connect the counters to the Readout Board, Area refers to the top surface area of the counter, and E-W, N-S, and Up-Dn refers to the position of the counters relative to the GPS antenna (see image above).  The orientation refers to whether the counters are stacked (<img src="graphics/stacked.gif">) or spread out (<img src="graphics/unstacked.gif">).
                                        <li>The <b>GPS Location</b> area allows you to input the location of your GPS antenna.  If you link to the geometry page from the "Upload Successful!" page, this will automatically be filled in (as long as the "DG" command was used during the data run).
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










</body>
</html>
