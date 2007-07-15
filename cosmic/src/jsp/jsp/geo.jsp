<%@ page import="gov.fnal.elab.cosmic.beans.Geometries" %>
<%@ page import="gov.fnal.elab.cosmic.beans.GeoEntryBean" %>
<%@ page import="gov.fnal.elab.cosmic.Geometry" %>
<%@ include file="common.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:useBean id="geoEntry" scope="session" class="gov.fnal.elab.cosmic.beans.GeoEntryBean" />
<jsp:useBean id="geometries" scope="session" class="gov.fnal.elab.cosmic.beans.Geometries" />
<html>
    <head>
        <title>Update Geometry Journal</title>
        
        <!-- include css style file -->
        <%@ include file="include/geo_style.css" %>
        <!-- header/navigation -->
        <%
        //be sure to set this before including the navbar
        String headerType = "Upload";
        %>
        <%@ include file="include/navbar_common.jsp" %>
        <link rel="stylesheet" type="text/css" href="include/niftyCorners.css">
        <link rel="stylesheet" type="text/css" href="include/niftyPrint.css" media="print">
        <script type="text/javascript" src="include/nifty.js"></script>
        <script type="text/javascript">
            window.onload=function(){
                if(!NiftyCheck())
                    return;
                Rounded("div#existing_geo_entries","all","#FFF","#CC99CC","smooth");
                Rounded("div#edit_geo_entry","all","#FFF","#CCCCCC","smooth");
            }
        </script>
        <%@ include file="include/javascript.jsp" %>
        
<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>

<%
geometries = new Geometries(user.getId(), elab.getProperty("data.dir"), 
    conn); // can fix this to use user bean later
String action = request.getParameter("action");
String detectorID = request.getParameter("detectorID");
String jd = request.getParameter("jd");
String submit = request.getParameter("commit");
String deleteConfirm = request.getParameter("delete_confirm");
String theDate = request.getParameter("theDate");
String time = request.getParameter("time");
boolean invalid = false;
if(submit != null || deleteConfirm != null) {
    if (detectorID != null) {
%>
        <jsp:setProperty name="geoEntry" property="*" />
<%
        if (action != null && action.equals("new")) {
            String dateTime = "";
            if (theDate != null && time != null)
                dateTime = theDate + " " + time;
%>
            <jsp:setProperty name="geoEntry" property="date" value="<%=dateTime%>" /> 
<%
        }
        if (geoEntry.isValid()) {
            if (submit != null && submit.equals("Commit Geometry")) {
                geometries.addGeoEntry(detectorID, geoEntry);
            } else if (deleteConfirm != null && deleteConfirm.equals("Yes, I'm sure!")) {
                geometries.removeGeoEntry(detectorID, geoEntry);
            }

            geoEntry = new GeoEntryBean();
            geometries.commit();
            // Updating metadata might take a while, so it is good to get back to them with
            // some feedback.
            out.write("<div id=\"geo_commited\"><span style=\"color:#000\">Please wait while we update metadata for your data files . . . </span>");
            out.flush();
            geometries.updateMetadata();
            out.write("<br><span style=\"color:#00CC00\">Your geometry has been sucessfully commited.</span></div>");
        } else {
            invalid = true;
        }
    }
}
if (action != null && (action.equals("edit") || action.equals("delete"))) {
    if (detectorID != null && jd != null && !invalid) {
        geoEntry = geometries.getGeoEntry(detectorID, jd);
        if (geoEntry == null) geoEntry = new GeoEntryBean();
        geoEntry.setDetectorID(detectorID);
    }
} else {
    geoEntry.reset();
}
%>
        <form method="post">
            <div id="geo_container">
                <div id="existing_geo_entries">
                    <div class="geo_padded_interior">
<%
                        for (Iterator i = geometries.iterator(); i.hasNext(); ) {
                            Geometry geo = (Geometry)i.next();
%>
                            <span class="detector">Detector <%=geo.getDetectorID()%></span>&nbsp;
                            <a href="geo.jsp?action=new&detectorID=<%=geo.getDetectorID()%>" title="New entry for detector <%=geo.getDetectorID()%>">
                                <img align="top" border="0" src="../graphics/geo_new.gif">
                            </a>
                            <c:choose>
                                <c:when test="${param.action == 'edit' || param.action == 'delete'}">
                                    <div class="geo_indented_small">
                                </c:when>
                                <c:otherwise>
                                    <div class="geo_indented_big">
                                </c:otherwise>
                            </c:choose>
                            <table>
<%
                            if (geo.isEmpty()) { out.write("<tr><td><span style=\"font-size:100%;\">No entries</span><td></tr>"); }
                            int gebNum = 0;
                            boolean printMoreTBody = false;
                            for (Iterator it = geo.getDescendingGeoEntries(); it.hasNext(); ) {
                                gebNum++;
                                GeoEntryBean geb = (GeoEntryBean)it.next();
                                if (gebNum > 5 && !printMoreTBody && !geoEntry.getDetectorID().equals(geo.getDetectorID())) { 
                                    printMoreTBody = true;
%>
                                    <tbody id="<%=geo.getDetectorID()%>_show_more" style="visibility: visible; display:"> 
                                        <tr>
                                            <td colspan="8">
                                            <a href="javascript:void(0);" onclick="HideShow('<%=geo.getDetectorID()%>_show_more');HideShow('<%=geo.getDetectorID()%>_all')">and <%=geo.size() - gebNum + 1%> more...</a>
                                            </td>
                                        </tr>
                                    </tbody>
                                    <tbody id="<%=geo.getDetectorID()%>_all" style="visibility: hidden; display: none;">
<%
                                }
%>
                                <tr valign="bottom">
                                    <td valign="middle">
                                        <%if (geoEntry.equals(geb)) {%>
                                            <img src="../graphics/white_arrow.gif">
                                        <%} else {%>
                                            &nbsp;
                                        <%}%>
                                    <td>
                                        <%=geb.getPrettyMonth() + " " + geb.getPrettyDayNumber() + ","%>
                                    </td>
                                    <td>
                                        <%=geb.getPrettyLongYear()%>
                                    </td>
                                    <td>
                                        <%="@ " + geb.getPrettyTime()%>
                                    </td>
                                    <td>
                                        <%=geb.getPrettyAMPM()%>
                                    </td>
                                    <td>
                                        <a href="geo.jsp?action=edit&detectorID=<%=geo.getDetectorID()%>&jd=<%=geb.getJulianDay()%>" title="Edit entry"><img border="0" src="../graphics/geo_pencil.gif"></a>
                                    </td>
                                    <td>
                                        <a href="geo.jsp?action=delete&detectorID=<%=geo.getDetectorID()%>&jd=<%=geb.getJulianDay()%>" title="Delete entry"><img border="0" src="../graphics/delete_x.gif"></a>
                                    </td> 
                                </tr>
<%
                            }
                            if (printMoreTBody)
                                out.write("</tbody>");
                            out.write("</table>");
                        out.write("</div>");
                        //out.write("</div>");
                    }
%>
                </div>
            </div>
            <div id="edit_geo_entry">
                <div class="geo_padded_interior">
                    <c:choose>
                        <c:when test="${!empty param.delete_confirm}"> 
                            <div id="edit_title">
                                Please choose an action to your left.
                                <br>
                                <br>
                                <span style="font-size:75%">
                                    Confused? Please consult the <a href="geoInstructions.jsp">tutorial</a>.
                                </span>
                            </div>
                        </c:when>

                        <c:when test="${param.action == 'edit' || param.action == 'new'}">
                            <c:if test="${param.action == 'new'}">
                                <div id="edit_title">
                                    New Detector <c:out value="${param.detectorID}"/> Entry:
                                    <span style="font-size:70%">
                                        <input type="text" name="theDate" size="10" value="<%=geoEntry.getFormDate()%>"> @ 
                                        <input type="text" name="time" size="5" value="<%=geoEntry.getFormTime()%>">
                                        <a href="http://wwp.greenwichmeantime.com/">GMT</a>
                                    </span>
                                </div>
                            </c:if>
                            <c:if test="${param.action == 'edit'}">
                                <div id="edit_title">
                                    Edit Detector <c:out value="${param.detectorID}"/>: 
                                    <%=geoEntry.getPrettyMonth() + " " + geoEntry.getPrettyDayNumber() + ", " + 
                                    geoEntry.getPrettyLongYear() + " @ " + geoEntry.getPrettyTime() + " " + geoEntry.getPrettyAMPM()%>
                                </div>
                            </c:if>

                            <input type="hidden" name="julianDay" value="<%=geoEntry.getJulianDay()%>">
                            <input type="hidden" name="detectorID" value="<%=geoEntry.getDetectorID()%>">
                            <div class="edit_subheading">
                                Detector Configuration
                                <br>
                                <span style="font-size:70%">
                                    Confused? Please consult the <a href="geoInstructions.jsp">tutorial</a>.
                                </span>
                            </div>

                            <div id="geo_channels">
                            <table border="0" cellspacing="5" cellpadding="2">
                                <tr>
                                    <td valign="middle">&nbsp;</td>
                                    <td valign="middle">Cable<br>Length<span style="font-size:90%"> (m)</span></td>
                                    <td valign="bottom">Area <span style="font-size:90%">(cm<sup>2</sup>)</span></td>
                                    <td valign="bottom">E-W <span style="font-size:90%">(m)</span></td>
                                    <td valign="bottom">N-S <span style="font-size:90%">(m)</span></td>
                                    <td valign="bottom">Up-Dn <span style="font-size:90%">(m)</span></td>
                                </tr>
                                <tr>
                                    <td style="padding-right:5px"><img src="../graphics/geo_det1.gif"></td>
                                    <td><input type="text" name="chan1CableLength" size="4" value="<%=geoEntry.getChan1CableLength()%>"></td>
                                    <td><input type="text" name="chan1Area" size="6" value="<%=geoEntry.getChan1Area()%>"></td>
                                    <td><input type="text" name="chan1X" size="5" value="<%=geoEntry.getChan1X()%>"></td>
                                    <td><input type="text" name="chan1Y" size="5" value="<%=geoEntry.getChan1Y()%>"></td>
                                    <td><input type="text" name="chan1Z" size="5" value="<%=geoEntry.getChan1Z()%>"></td>
                                </tr>
                                <tr>
                                    <td><img src="../graphics/geo_det2.gif"></td>
                                    <td><input type="text" name="chan2CableLength" size="4" value="<%=geoEntry.getChan2CableLength()%>"></td>
                                    <td><input type="text" name="chan2Area" size="6" value="<%=geoEntry.getChan2Area()%>"></td>
                                    <td><input type="text" name="chan2X" size="5" value="<%=geoEntry.getChan2X()%>"></td>
                                    <td><input type="text" name="chan2Y" size="5" value="<%=geoEntry.getChan2Y()%>"></td>
                                    <td><input type="text" name="chan2Z" size="5" value="<%=geoEntry.getChan2Z()%>"></td>
                                </tr>
                                <tr> 
                                    <td><img src="../graphics/geo_det3.gif"></td>
                                    <td><input type="text" name="chan3CableLength" size="4" value="<%=geoEntry.getChan3CableLength()%>"></td>
                                    <td><input type="text" name="chan3Area" size="6" value="<%=geoEntry.getChan3Area()%>"></td>
                                    <td><input type="text" name="chan3X" size="5" value="<%=geoEntry.getChan3X()%>"></td>
                                    <td><input type="text" name="chan3Y" size="5" value="<%=geoEntry.getChan3Y()%>"></td>
                                    <td><input type="text" name="chan3Z" size="5" value="<%=geoEntry.getChan3Z()%>"></td>
                                </tr>
                                <tr>
                                    <td><img src="../graphics/geo_det4.gif"></td>
                                    <td><input type="text" name="chan4CableLength" size="4" value="<%=geoEntry.getChan4CableLength()%>"></td>
                                    <td><input type="text" name="chan4Area" size="6" value="<%=geoEntry.getChan4Area()%>"></td>
                                    <td><input type="text" name="chan4X" size="5" value="<%=geoEntry.getChan4X()%>"></td>
                                    <td><input type="text" name="chan4Y" size="5" value="<%=geoEntry.getChan4Y()%>"></td>
                                    <td><input type="text" name="chan4Z" size="5" value="<%=geoEntry.getChan4Z()%>"></td>
                                </tr>
                            </table>
                            </div>

                            <center>
                                <div id="geo_orientation">
                                    <table border="0">
                                        <tr>
                                            <td valign="middle" width="31">
                                                <img src="../graphics/med_stacked.gif">
                                                <input type="radio" name="stackedState" value="1"
                                                    <%if (geoEntry.getStackedState().equals("1")) {%>checked<%}%>>
                                            </td>
                                            <td valign="middle" >
                                                <span style="padding-left:20px; padding-right:20px">Orientation</span>
                                            </td>
                                            <td valign="bottom" width="68">
                                                <img src="../graphics/med_unstacked.gif">
                                                <input type="radio" name="stackedState" value="0"
                                                    <%if (geoEntry.getStackedState().equals("0")) {%>checked<%}%>>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </center>

                            <div class="edit_subheading">GPS Location</div>
<%
                            if (invalid) {
                                out.write("<span style=\"font-size:90%; color: #EE0000\">Please check that your latitude and longitude values are correct.</span>");
                            }
%>
                            <div id="geo_gps">
                                <table border="0" cellspacing="3">
                                    <tr valign="top">
                                        <td>
                                            Latitude: <input type=text" name="latitude" size="11" value="<%=geoEntry.getFormLatitude()%>">
                                            <br>
                                            <span style="font-size: 90%">e.g., 47:39.2347 N</font>
                                        </td>
                                        <td>
                                            Longitude: <input type=text" name="longitude" size="11" value="<%=geoEntry.getFormLongitude()%>">
                                            <br>
                                            <span style="font-size: 90%">e.g., 122:18.68 W</span>
                                        </td>
                                        <td>
                                            Altitude (m): <input type=text" name="altitude" size="3" value="<%=geoEntry.getAltitude()%>">
                                        </td>
                                    </tr>
                                </table>
                            </div>

                            <center>
                                <input type="submit" name="commit" value="Commit Geometry">
                            </center>
                                
                        </c:when>

                        <c:when test="${param.action == 'delete'}">
                            <div id="edit_title">
                                Delete Detector <c:out value="${param.detectorID}"/> Entry: 
                                <%=geoEntry.getPrettyMonth() + " " + geoEntry.getPrettyDayNumber() + ", " + 
                                geoEntry.getPrettyLongYear() + " @ " + geoEntry.getPrettyTime() + " " + geoEntry.getPrettyAMPM()%>
                            </div>

                            <center>
                                <div class="edit_subheading">
                                    Are you sure?
                                </div>
                                <input type="submit" name="delete_confirm" value="Yes, I'm sure!">&nbsp;&nbsp;&nbsp;
                                <input type="submit" name="delete_confirm" value="Of course not!">
                                <input type="hidden" name="julianDay" value="<%=geoEntry.getJulianDay()%>">
                                <input type="hidden" name="detectorID" value="<%=geoEntry.getDetectorID()%>">
                            </center>
                        </c:when>

                        <c:otherwise> 
                            <div id="edit_title">
                                Please choose an action to your left.
                                <br>
                                <br>
                                <span style="font-size:75%">
                                    Confused? Please consult the <a href="geoInstructions.jsp">tutorial</a>.
                                </span>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
