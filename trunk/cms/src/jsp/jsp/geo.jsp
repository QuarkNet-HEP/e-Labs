<%@ page import="gov.fnal.elab.cosmic.beans.Geometries" %>
<%@ page import="gov.fnal.elab.cosmic.beans.GeoEntryBean" %>
<%@ page import="gov.fnal.elab.cosmic.Geometry" %>
<%@ include file="../login/upload-login-required.jsp" %>
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
geometries = new Geometries(
    (String)session.getAttribute("groupID"), 
    System.getProperty("portal.datadir"), 
    conn); // can fix this to use user bean later
String action = request.getParameter("action");
String detectorID = request.getParameter("detectorID");
String jd = request.getParameter("jd");
String submit = request.getParameter("commit");
String deleteConfirm = request.getParameter("delete_confirm");
String month = request.getParameter("month");
String day = request.getParameter("day");
String year = request.getParameter("year");
String hour = request.getParameter("hour");
String minute = request.getParameter("minute");
String chan1Active = request.getParameter("chan1Active");
String chan2Active = request.getParameter("chan2Active");
String chan3Active = request.getParameter("chan3Active");
String chan4Active = request.getParameter("chan4Active");
String currDateSDF = null;


// booleans for checking validity of user inputs
boolean invalid = false;
boolean invalidDate = false;
boolean invalidChan1CableLength = false;
boolean invalidChan2CableLength = false;
boolean invalidChan3CableLength = false;
boolean invalidChan4CableLength = false;
boolean invalidChan1Area = false;
boolean invalidChan2Area = false;
boolean invalidChan3Area = false;
boolean invalidChan4Area = false;
boolean invalidChan1X = false;
boolean invalidChan2X = false;
boolean invalidChan3X = false;
boolean invalidChan4X = false;
boolean invalidChan1Y = false;
boolean invalidChan2Y = false;
boolean invalidChan3Y = false;
boolean invalidChan4Y = false;
boolean invalidChan1Z = false;
boolean invalidChan2Z = false;
boolean invalidChan3Z = false;
boolean invalidChan4Z = false;
boolean invalidLatitude = false;
boolean invalidLongitude = false;
boolean invalidAltitude = false;
boolean invalidGpsCableLength = false;
boolean smartCheckFailed = false;
boolean smartCheckDateFailed = false;
boolean smartCheckDuplicateDateFailed = false;
boolean smartCheckStackedEWFailed = false;
boolean smartCheckStackedNSFailed = false;
boolean smartCheckStackedUpDnFailed = false;
boolean chan1IsActive = true;
boolean chan2IsActive = true;
boolean chan3IsActive = true;
boolean chan4IsActive = true;
boolean commitSuccessful = false;

if(submit != null || deleteConfirm != null) {
    if (detectorID != null) {
%>
        <jsp:setProperty name="geoEntry" property="*" />
<%
        if (action != null && action.equals("new")) {
            String dateTime = "";
            // Only set the time in the bean if all date/time fields have been set...sending in a dateTime of with any "null" fields blows things up
            if (!month.equals("0") && !day.equals("0") && !year.equals("0") && !hour.equals("0") && !minute.equals("0")) {
                dateTime = month + "/" + day + "/" + year + " " + hour + ":" + minute;
%>
            <jsp:setProperty name="geoEntry" property="date" value="<%=dateTime%>" /> 
<%
            }
            else { // We're doing the error checking for the date here in the jsp instead of in the bean
                invalidDate = true;
            }
        }

        // Smart Checking (check some of the user inputs for accuracy - goes beyond simply checking validity of inputs)
        if (deleteConfirm == null) { // we don't want to do this when user is trying to delete a geo entry
            if (!(action != null && action.equals("edit"))) { // user can't change date when editing an entry, so smart checking not needed
                //  SmartCheck if date is past current date
                java.util.Date currDate = new java.util.Date();
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MM/dd/yyyy HH:mm z");
                sdf.setTimeZone(TimeZone.getTimeZone("GMT")); // make sure user is seeing current date in GMT (for the error message)
                currDateSDF = sdf.format(currDate);
                GregorianCalendar oldGC = new GregorianCalendar(Integer.parseInt(year), Integer.parseInt(month) - 1, Integer.parseInt(day), Integer.parseInt(hour), Integer.parseInt(minute));
                java.util.Date oldDate = oldGC.getTime();
                if (oldDate.after(currDate)) {
                    smartCheckDateFailed = true;
                }
                //  SmartCheck if date entered is a duplicate of another geo entry's date
                for (Iterator i = geometries.iterator(); i.hasNext(); ) {
                    Geometry geo = (Geometry)i.next();
                    if (detectorID.equals(geo.getDetectorID())) {
                        for (Iterator it = geo.getDescendingGeoEntries(); it.hasNext(); ) {
                            GeoEntryBean geb = (GeoEntryBean)it.next();
                            String gebDate = geb.getFormDate() + " " + geb.getFormTime();
                            if (geoEntry.getDate() != null && (geoEntry.getDate()).equals(gebDate)) {
                                smartCheckDuplicateDateFailed = true;
                            }
                        }
                    }
                }
            }
            //  SmartCheck that if stacked, then E-W and N-S values for all channels should be equal and Up-Dn values for all channels should be different
            if ((geoEntry.getStackedState()).equals("1")) {
                String chan1X = geoEntry.getChan1X();
                String chan2X = geoEntry.getChan2X();
                String chan3X = geoEntry.getChan3X();
                String chan4X = geoEntry.getChan4X();
                String chan1Y = geoEntry.getChan1Y();
                String chan2Y = geoEntry.getChan2Y();
                String chan3Y = geoEntry.getChan3Y();
                String chan4Y = geoEntry.getChan4Y();
                String chan1Z = geoEntry.getChan1Z();
                String chan2Z = geoEntry.getChan2Z();
                String chan3Z = geoEntry.getChan3Z();
                String chan4Z = geoEntry.getChan4Z();
                chan1IsActive = chan1Active == null ? false : true;
                chan2IsActive = chan2Active == null ? false : true;
                chan3IsActive = chan3Active == null ? false : true;
                chan4IsActive = chan4Active == null ? false : true;
                // Checking channel 1 against channels 2, 3, 4
                if (chan1IsActive) { // nested conditionals are easier to read and understand than one ridiculously long conditional
                    // Check E-W (X) values (only between channels that are active)
                    if ((chan2IsActive && !chan1X.equals(chan2X)) || (chan3IsActive && !chan1X.equals(chan3X)) || (chan4IsActive && !chan1X.equals(chan4X))) {
                        smartCheckStackedEWFailed = true;
                    }
                    // Check N-S (Y) values (only between channels that are active)
                    if ((chan2IsActive && !chan1Y.equals(chan2Y)) || (chan3IsActive && !chan1Y.equals(chan3Y)) || (chan4IsActive && !chan1Y.equals(chan4Y))) {
                        smartCheckStackedNSFailed = true;
                    }
                    // Check Up-Dn (Z) values (only between channels that are active)
                    if ((chan2IsActive && chan1Z.equals(chan2Z)) || (chan3IsActive && chan1Z.equals(chan3Z)) || (chan4IsActive && chan1Z.equals(chan4Z))) {
                        smartCheckStackedUpDnFailed = true;
                    }
                }
                // Checking channel 2 against channels 3, 4
                if (chan2IsActive) {
                    // Check E-W (X) values (only between channels that are active)
                    if ((chan3IsActive && !chan2X.equals(chan3X)) || (chan4IsActive && !chan2X.equals(chan4X))) {
                        smartCheckStackedEWFailed = true;
                    }
                    // Check N-S (Y) values (only between channels that are active)
                    if ((chan3IsActive && !chan2Y.equals(chan3Y)) || (chan4IsActive && !chan2Y.equals(chan4Y))) {
                        smartCheckStackedNSFailed = true;
                    }
                    // Check Up-Dn (Z) values (only between channels that are active)
                    if ((chan3IsActive && chan2Z.equals(chan3Z)) || (chan4IsActive && chan2Z.equals(chan4Z))) {
                        smartCheckStackedUpDnFailed = true;
                    }
                }
                // Checking channel 3 against channel 4
                if (chan3IsActive) {
                    // Check E-W (X) values (only between channels that are active)
                    if (chan4IsActive && !chan3X.equals(chan4X)) {
                        smartCheckStackedEWFailed = true;
                    }
                    // Check N-S (Y) values (only between channels that are active)
                    if (chan4IsActive && !chan3Y.equals(chan4Y)) {
                        smartCheckStackedNSFailed = true;
                    }
                    // Check Up-Dn (Z) values (only between channels that are active)
                    if (chan4IsActive && chan3Z.equals(chan4Z)) {
                        smartCheckStackedUpDnFailed = true;
                    }
                }
            }
        }
        if (smartCheckDateFailed || smartCheckDuplicateDateFailed || smartCheckStackedEWFailed || smartCheckStackedNSFailed || smartCheckStackedUpDnFailed) {
            smartCheckFailed = true;
        }
        
        // This needs to be done because if a user tries to enter invalid inputs into a geometry entry, those inputs are still in the bean
        //   even though an error message is output.  If the user tries to immediately delete another entry, it won't happen because the
        //   bean won't be valid (due to the previous attempts at invalid inputs).  We can reset here because the only part of geoEntry that is
        //   used to delete a geo entry is the julian date (Geometry.java line 101).  So we took the "julianDay = null" out of the reset function 
        //   so we can put in valid inputs to the bean here (by resetting) and make it valid.  This shouldn't affect julianDay at all, since it's 
        //   already been set and it's not getting reset to null anymore.  Also, date and julianDay don't need to be set in the bean anymore since 
        //   we're defaulting to invalid date/time values here in the jsp (with the pulldown boxes) instead of defaulting to the current date/time 
        //   from the bean.
        if (deleteConfirm != null && deleteConfirm.equals("Yes, I'm sure!")) {
            java.util.List list = geoEntry.getInvalidKeys();
            if (list.size() > 0) {
                geoEntry.reset(); // this needs to happen BEFORE the conditional to check validity of geoEntry
            }
        }

        // Before committing, set non-active channel values back to defaults
        if (chan1Active == null) {
            geoEntry.setChan1X("0");
            geoEntry.setChan1Y("0");
            geoEntry.setChan1Z("0");
            geoEntry.setChan1Area("625.0");
            geoEntry.setChan1CableLength("0.0");
        }
        if (chan2Active == null) {
            geoEntry.setChan2X("0");
            geoEntry.setChan2Y("0");
            geoEntry.setChan2Z("0");
            geoEntry.setChan2Area("625.0");
            geoEntry.setChan2CableLength("0.0");
        }
        if (chan3Active == null) {
            geoEntry.setChan3X("0");
            geoEntry.setChan3Y("0");
            geoEntry.setChan3Z("0");
            geoEntry.setChan3Area("625.0");
            geoEntry.setChan3CableLength("0.0");
        }
        if (chan4Active == null) {
            geoEntry.setChan4X("0");
            geoEntry.setChan4Y("0");
            geoEntry.setChan4Z("0");
            geoEntry.setChan4Area("625.0");
            geoEntry.setChan4CableLength("0.0");
        }
        // invalidDate should be the first check, since if the date is not set, then dateTime is null, and isDateValid() in the bean dies
        if (!invalidDate && !smartCheckFailed && geoEntry.isValid()) {
            if (submit != null && submit.equals("Commit Geometry")) {
                geometries.addGeoEntry(detectorID, geoEntry);
                commitSuccessful = true;
                
                // Update the stacked state of all files that use this geo entry
                String query = null;
                String enddateString = null;
                boolean updated = true;
                String stackedState = (geoEntry.getStackedState().equals("1")) ? "true" : "false";
                String startdateString = geoEntry.getDate();
                java.util.Date startdateDate = new java.util.Date(startdateString);
                java.text.SimpleDateFormat sdf2 = new java.text.SimpleDateFormat("MM/dd/yyyy HH:mm:SS");
                String startdate = sdf2.format(startdateDate);
                for (Iterator i = geometries.iterator(); i.hasNext(); ) {
                    Geometry geo = (Geometry)i.next();
                    for (Iterator it = geo.getGeoEntries(); it.hasNext(); ) {
                        GeoEntryBean geb = (GeoEntryBean)it.next();
                        if (geb.getDate().equals(startdateString) && it.hasNext()) {
                            GeoEntryBean gebGrab = (GeoEntryBean)it.next();
                            enddateString = gebGrab.getDate();
                        }
                    }
                }
                if (enddateString != null) {
                    java.util.Date enddateDate = new java.util.Date(enddateString);
                    String enddate = sdf2.format(enddateDate);
                    query = "type=\'split\' AND project=\'" + eLab + "\' AND detectorid=\'" + detectorID + "\' AND startdate BETWEEN \'" + startdate + "\' AND \'" + enddate + "\'";
                }
                else {
                    query = "type=\'split\' AND project=\'" + eLab + "\' AND detectorid=\'" + detectorID + "\' AND startdate > \'" + startdate + "\'";
                }
                ArrayList meta = new ArrayList();
                meta.add("stacked boolean " + stackedState);
                ArrayList lfnsmeta = null;
                lfnsmeta = getLFNsAndMeta(out, query);
                if (lfnsmeta != null) {
                    for(Iterator i=lfnsmeta.iterator(); i.hasNext(); ){
                        ArrayList pair = (ArrayList)i.next();
                        String lfn = (String)pair.get(0);
                        try {
                            updated &= setMeta(lfn, meta);
                        } catch(ElabException e){
                            out.println("<font color=red>" + e + "</font><!--" + lfn + "--><br>");
                            updated = false;
                        }
                    }
                }
            } else if (deleteConfirm != null && deleteConfirm.equals("Yes, I'm sure!")) {
                geometries.removeGeoEntry(detectorID, geoEntry);

                // Update the stacked state of all files that used this geo entry to reflect the previous geo entry
                String query = null;
                String enddateString = null;
                boolean updated = true;
                String stackedState = null;
                String startdateString = geoEntry.getDate();
                java.util.Date startdateDate = new java.util.Date(startdateString);
                java.text.SimpleDateFormat sdf2 = new java.text.SimpleDateFormat("MM/dd/yyyy HH:mm:SS");
                String startdate = sdf2.format(startdateDate);
                GeoEntryBean lastGeoEntry = null;
                for (Iterator i = geometries.iterator(); i.hasNext(); ) {
                    Geometry geo = (Geometry)i.next();
                    for (Iterator it = geo.getGeoEntries(); it.hasNext(); ) {
                        GeoEntryBean geb = (GeoEntryBean)it.next();
                        if (geb.getDate().equals(startdateString)) {
                            if (it.hasNext()) {
                                GeoEntryBean gebGrab = (GeoEntryBean)it.next();
                                enddateString = gebGrab.getDate();
                            }
                            stackedState = (lastGeoEntry.getStackedState().equals("1")) ? "true" : "false";
                        }
                        lastGeoEntry = geb;
                    }
                }
                if (enddateString != null) {
                    java.util.Date enddateDate = new java.util.Date(enddateString);
                    String enddate = sdf2.format(enddateDate);
                    query = "type=\'split\' AND project=\'" + eLab + "\' AND detectorid=\'" + detectorID + "\' AND startdate BETWEEN \'" + startdate + "\' AND \'" + enddate + "\'";
                }
                else {
                    query = "type=\'split\' AND project=\'" + eLab + "\' AND detectorid=\'" + detectorID + "\' AND startdate > \'" + startdate + "\'";
                }
                ArrayList meta = new ArrayList();
                meta.add("stacked boolean " + stackedState);
                ArrayList lfnsmeta = null;
                lfnsmeta = getLFNsAndMeta(out, query);
                if (lfnsmeta != null) {
                    for(Iterator i=lfnsmeta.iterator(); i.hasNext(); ){
                        ArrayList pair = (ArrayList)i.next();
                        String lfn = (String)pair.get(0);
                        try {
                            updated &= setMeta(lfn, meta);
                        } catch(ElabException e){
                            out.println("<font color=red>" + e + "</font><!--" + lfn + "--><br>");
                            updated = false;
                        }
                    }
                }

            }
            // We don't want any of this to happen if the user chooses not to delete the geo entry
            if (!(deleteConfirm != null && deleteConfirm.equals("Of course not!"))) {
                geoEntry = new GeoEntryBean();
                geometries.commit();
                // Updating metadata might take a while, so it is good to get back to them with
                // some feedback.
                out.write("<div id=\"geo_commited\"><span style=\"color:#000\">Please wait while we update metadata for your data files . . . </span>");
                out.flush(); // FIXME: why is this hanging and stopping the rest of the page from loading?
                geometries.updateMetadata();
                out.write("<br><span style=\"color:#00CC00\">Your geometry has been successfully committed.</span></div>");
            }
        } else {
            invalid = true;
            // Check all the user inputs for updating geometry to make sure they're correct
            if (!geoEntry.isChan1CableLengthValid()) {
                invalidChan1CableLength = true;
            }
            if (!geoEntry.isChan2CableLengthValid()) {
                invalidChan2CableLength = true;
            }
            if (!geoEntry.isChan3CableLengthValid()) {
                invalidChan3CableLength = true;
            }
            if (!geoEntry.isChan4CableLengthValid()) {
                invalidChan4CableLength = true;
            }
            if (!geoEntry.isChan1AreaValid()) {
                invalidChan1Area = true;
            }
            if (!geoEntry.isChan2AreaValid()) {
                invalidChan2Area = true;
            }
            if (!geoEntry.isChan3AreaValid()) {
                invalidChan3Area = true;
            }
            if (!geoEntry.isChan4AreaValid()) {
                invalidChan4Area = true;
            }
            if (!geoEntry.isChan1XValid()) {
                invalidChan1X = true;
            }
            if (!geoEntry.isChan2XValid()) {
                invalidChan2X = true;
            }
            if (!geoEntry.isChan3XValid()) {
                invalidChan3X = true;
            }
            if (!geoEntry.isChan4XValid()) {
                invalidChan4X = true;
            }
            if (!geoEntry.isChan1YValid()) {
                invalidChan1Y = true;
            }
            if (!geoEntry.isChan2YValid()) {
                invalidChan2Y = true;
            }
            if (!geoEntry.isChan3YValid()) {
                invalidChan3Y = true;
            }
            if (!geoEntry.isChan4YValid()) {
                invalidChan4Y = true;
            }
            if (!geoEntry.isChan1ZValid()) {
                invalidChan1Z = true;
            }
            if (!geoEntry.isChan2ZValid()) {
                invalidChan2Z = true;
            }
            if (!geoEntry.isChan3ZValid()) {
                invalidChan3Z = true;
            }
            if (!geoEntry.isChan4ZValid()) {
                invalidChan4Z = true;
            }
            if (!geoEntry.isLatitudeValid()) {	
                invalidLatitude = true;
            }
            if (!geoEntry.isLongitudeValid()) {	
                invalidLongitude = true;
            }
            if (!geoEntry.isAltitudeValid()) {	
                invalidAltitude = true;
            }
            if (!geoEntry.isGpsCableLengthValid()) {
                invalidGpsCableLength = true;
            }
        }
    }
}

if (action != null && (action.equals("edit") || action.equals("delete"))) {
    if (detectorID != null && jd != null && !invalid) {
        geoEntry = geometries.getGeoEntry(detectorID, jd);
        if (geoEntry == null) { geoEntry = new GeoEntryBean(); }
        geoEntry.setDetectorID(detectorID);
    }
} else if (action != null && action.equals("new") && submit == null){
    geoEntry.reset(); // don't reset when page reloads to inform user of invalid inputs
}
// If a channel has all default values, we assume that it was an "inactive" channel, and treat it as such
if (action != null && action.equals("edit") && submit == null) {
    if ((geoEntry.getChan1X()).equals("0") && (geoEntry.getChan1Y()).equals("0") && (geoEntry.getChan1Z()).equals("0")
            && (geoEntry.getChan1Area()).equals("625.0") && (geoEntry.getChan1CableLength()).equals("0.0")) {
        chan1IsActive = false;
    }
    if ((geoEntry.getChan2X()).equals("0") && (geoEntry.getChan2Y()).equals("0") && (geoEntry.getChan2Z()).equals("0")
            && (geoEntry.getChan2Area()).equals("625.0") && (geoEntry.getChan2CableLength()).equals("0.0")) {
        chan2IsActive = false;
    }
    if ((geoEntry.getChan3X()).equals("0") && (geoEntry.getChan3Y()).equals("0") && (geoEntry.getChan3Z()).equals("0")
            && (geoEntry.getChan3Area()).equals("625.0") && (geoEntry.getChan3CableLength()).equals("0.0")) {
        chan3IsActive = false;
    }
    if ((geoEntry.getChan4X()).equals("0") && (geoEntry.getChan4Y()).equals("0") && (geoEntry.getChan4Z()).equals("0")
            && (geoEntry.getChan4Area()).equals("625.0") && (geoEntry.getChan4CableLength()).equals("0.0")) {
        chan4IsActive = false;
    }
}
// Deactivate channels when user has unchecked them and entered an invalid entry causing page to reload
if (invalid) {
    if (chan1Active == null) { chan1IsActive = false; }
    if (chan2Active == null) { chan2IsActive = false; }
    if (chan3Active == null) { chan3IsActive = false; }
    if (chan4Active == null) { chan4IsActive = false; }
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
                                <img align="top" border="0" src="graphics/geo_new.gif">
                            </a>
                        <div class="geo_indented_small">
                            <table>
<%
                            if (geo.isEmpty()) { out.write("<tr><td><span style=\"font-size:100%;\">No entries</span><td></tr>"); }
                            int gebNum = 0;
                            boolean printMoreTBody = false;
                            if (invalid) { printMoreTBody = true; } // don't set this on a page reload due to invalid entry
                            for (Iterator it = geo.getDescendingGeoEntries(); it.hasNext(); ) {
                                gebNum++;
                                GeoEntryBean geb = (GeoEntryBean)it.next();
                                if (gebNum > 5 && !printMoreTBody && (!geoEntry.getDetectorID().equals(geo.getDetectorID()) || action == null || deleteConfirm != null)) { 
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
                                        <%if (geoEntry.equals(geb) && deleteConfirm == null && action != null && (!invalid || (invalid && submit != null))) {%>
                                            <img src="graphics/white_arrow.gif">
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
                                        <%="@ " + geb.getFormTime()%>
                                    </td>
                                    <td>
                                        <a href="geo.jsp?action=edit&detectorID=<%=geo.getDetectorID()%>&jd=<%=geb.getJulianDay()%>" title="Edit entry"><img border="0" src="graphics/geo_pencil.gif"></a>
                                    </td>
                                    <td>
                                        <a href="geo.jsp?action=delete&detectorID=<%=geo.getDetectorID()%>&jd=<%=geb.getJulianDay()%>" title="Delete entry"><img border="0" src="graphics/delete_x.gif"></a>
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
                    <% if (!commitSuccessful && (action != null && (action.equals("edit") || action.equals("new")))){
                            if (action.equals("new")){ %>
                                <div id="edit_title">
                                    New Detector <c:out value="${param.detectorID}"/> Entry:
                                    
                                    <%
                                    // Print out an error message if an invalid value has been input by the user and DON'T let them commit.
                                    //   For some reason, committing geometry with invalid values erases the entire .geo file.
                                    if (invalidDate) {
                                        out.write("<br><span style=\"font-size:11; color: #EE0000\">Please check that your Date/Time values are all selected.</span>");
                                    }
                                    // SmartCheck if date entered exceeds current date
                                    if (smartCheckDateFailed) {
                                        out.write("<br><span style=\"font-size:11; color: #EE0000\">Date cannot exceed current date (" + currDateSDF + ")</span>");
                                    }
                                    //  SmartCheck if date entered is a duplicate of another geo entry's date
                                    if (smartCheckDuplicateDateFailed) {
                                        out.write("<br><span style=\"font-size:11; color: #EE0000\">Date exactly matches that of an existing geometry entry.</span>");
                                    }
                                    %>
                                    <span style="font-size:70%">
                                    <br><br>
										
										 Date:
										 	<select name="month">
												<option value="0" selected>Month</option>
												<option value="01" <%if (month != null && month.equals("01")) {%>selected<%}%>>January</option>
												<option value="02" <%if (month != null && month.equals("02")) {%>selected<%}%>>February</option>
												<option value="03" <%if (month != null && month.equals("03")) {%>selected<%}%>>March</option>
												<option value="04" <%if (month != null && month.equals("04")) {%>selected<%}%>>April</option>
												<option value="05" <%if (month != null && month.equals("05")) {%>selected<%}%>>May</option>
												<option value="06" <%if (month != null && month.equals("06")) {%>selected<%}%>>June</option>
												<option value="07" <%if (month != null && month.equals("07")) {%>selected<%}%>>July</option>
												<option value="08" <%if (month != null && month.equals("08")) {%>selected<%}%>>August</option>
												<option value="09" <%if (month != null && month.equals("09")) {%>selected<%}%>>September</option>
												<option value="10" <%if (month != null && month.equals("10")) {%>selected<%}%>>October</option>
												<option value="11" <%if (month != null && month.equals("11")) {%>selected<%}%>>November</option>
												<option value="12" <%if (month != null && month.equals("12")) {%>selected<%}%>>December</option>
											</select>
									        /	
											<select name="day">
												<option selected value="0">Day</option>
												<option value="01" <%if (day != null && day.equals("01")) {%>selected<%}%>>1</option>
												<option value="02" <%if (day != null && day.equals("02")) {%>selected<%}%>>2</option>
												<option value="03" <%if (day != null && day.equals("03")) {%>selected<%}%>>3</option>
												<option value="04" <%if (day != null && day.equals("04")) {%>selected<%}%>>4</option>
												<option value="05" <%if (day != null && day.equals("05")) {%>selected<%}%>>5</option>
												<option value="06" <%if (day != null && day.equals("06")) {%>selected<%}%>>6</option>
												<option value="07" <%if (day != null && day.equals("07")) {%>selected<%}%>>7</option>
												<option value="08" <%if (day != null && day.equals("08")) {%>selected<%}%>>8</option>
												<option value="09" <%if (day != null && day.equals("09")) {%>selected<%}%>>9</option>
												<option value="10" <%if (day != null && day.equals("10")) {%>selected<%}%>>10</option>
												<option value="11" <%if (day != null && day.equals("11")) {%>selected<%}%>>11</option>
												<option value="12" <%if (day != null && day.equals("12")) {%>selected<%}%>>12</option>
												<option value="13" <%if (day != null && day.equals("13")) {%>selected<%}%>>13</option>
												<option value="14" <%if (day != null && day.equals("14")) {%>selected<%}%>>14</option>
												<option value="15" <%if (day != null && day.equals("15")) {%>selected<%}%>>15</option>
												<option value="16" <%if (day != null && day.equals("16")) {%>selected<%}%>>16</option>
												<option value="17" <%if (day != null && day.equals("17")) {%>selected<%}%>>17</option>
												<option value="18" <%if (day != null && day.equals("18")) {%>selected<%}%>>18</option>
												<option value="19" <%if (day != null && day.equals("19")) {%>selected<%}%>>19</option>
												<option value="20" <%if (day != null && day.equals("20")) {%>selected<%}%>>20</option>
												<option value="21" <%if (day != null && day.equals("21")) {%>selected<%}%>>21</option>
												<option value="22" <%if (day != null && day.equals("22")) {%>selected<%}%>>22</option>
												<option value="23" <%if (day != null && day.equals("23")) {%>selected<%}%>>23</option>
												<option value="24" <%if (day != null && day.equals("24")) {%>selected<%}%>>24</option>
												<option value="25" <%if (day != null && day.equals("25")) {%>selected<%}%>>25</option>
												<option value="26" <%if (day != null && day.equals("26")) {%>selected<%}%>>26</option>
												<option value="27" <%if (day != null && day.equals("27")) {%>selected<%}%>>27</option>
												<option value="28" <%if (day != null && day.equals("28")) {%>selected<%}%>>28</option>
												<option value="29" <%if (day != null && day.equals("29")) {%>selected<%}%>>29</option>
												<option value="30" <%if (day != null && day.equals("30")) {%>selected<%}%>>30</option>
												<option value="31" <%if (day != null && day.equals("31")) {%>selected<%}%>>31</option>
											</select>
											/	
											<select name="year">
												<option selected value="0">Year</option>
												<option value="1999" <%if (year != null && year.equals("1999")) {%>selected<%}%>>1999</option>
												<option value="2000" <%if (year != null && year.equals("2000")) {%>selected<%}%>>2000</option>
												<option value="2001" <%if (year != null && year.equals("2001")) {%>selected<%}%>>2001</option>
												<option value="2002" <%if (year != null && year.equals("2002")) {%>selected<%}%>>2002</option>
												<option value="2003" <%if (year != null && year.equals("2003")) {%>selected<%}%>>2003</option>
												<option value="2004" <%if (year != null && year.equals("2004")) {%>selected<%}%>>2004</option>
												<option value="2005" <%if (year != null && year.equals("2005")) {%>selected<%}%>>2005</option>
												<option value="2006" <%if (year != null && year.equals("2006")) {%>selected<%}%>>2006</option>
												<option value="2007" <%if (year != null && year.equals("2007")) {%>selected<%}%>>2007</option>
												<option value="2008" <%if (year != null && year.equals("2008")) {%>selected<%}%>>2008</option>
												<option value="2009" <%if (year != null && year.equals("2009")) {%>selected<%}%>>2009</option>
												<option value="2010" <%if (year != null && year.equals("2010")) {%>selected<%}%>>2010</option>
											</select>
										    @
											<select name="hour">
												<option selected value="0">Hour</option>
												<option value="00" <%if (hour != null && hour.equals("00")) {%>selected<%}%>>0</option>
												<option value="01" <%if (hour != null && hour.equals("01")) {%>selected<%}%>>1</option>
												<option value="02" <%if (hour != null && hour.equals("02")) {%>selected<%}%>>2</option>
												<option value="03" <%if (hour != null && hour.equals("03")) {%>selected<%}%>>3</option>
												<option value="04" <%if (hour != null && hour.equals("04")) {%>selected<%}%>>4</option>
												<option value="05" <%if (hour != null && hour.equals("05")) {%>selected<%}%>>5</option>
												<option value="06" <%if (hour != null && hour.equals("06")) {%>selected<%}%>>6</option>
												<option value="07" <%if (hour != null && hour.equals("07")) {%>selected<%}%>>7</option>
												<option value="08" <%if (hour != null && hour.equals("08")) {%>selected<%}%>>8</option>
												<option value="09" <%if (hour != null && hour.equals("09")) {%>selected<%}%>>9</option>
												<option value="10" <%if (hour != null && hour.equals("10")) {%>selected<%}%>>10</option>
												<option value="11" <%if (hour != null && hour.equals("11")) {%>selected<%}%>>11</option>
												<option value="12" <%if (hour != null && hour.equals("12")) {%>selected<%}%>>12</option>
												<option value="13" <%if (hour != null && hour.equals("13")) {%>selected<%}%>>13</option>
												<option value="14" <%if (hour != null && hour.equals("14")) {%>selected<%}%>>14</option>
												<option value="15" <%if (hour != null && hour.equals("15")) {%>selected<%}%>>15</option>
												<option value="16" <%if (hour != null && hour.equals("16")) {%>selected<%}%>>16</option>
												<option value="17" <%if (hour != null && hour.equals("17")) {%>selected<%}%>>17</option>
												<option value="18" <%if (hour != null && hour.equals("18")) {%>selected<%}%>>18</option>
												<option value="19" <%if (hour != null && hour.equals("19")) {%>selected<%}%>>19</option>
												<option value="20" <%if (hour != null && hour.equals("20")) {%>selected<%}%>>20</option>
												<option value="21" <%if (hour != null && hour.equals("21")) {%>selected<%}%>>21</option>
												<option value="22" <%if (hour != null && hour.equals("22")) {%>selected<%}%>>22</option>
												<option value="23" <%if (hour != null && hour.equals("23")) {%>selected<%}%>>23</option>
											</select>
											:
											<select name="minute">
												<option selected value="0">Minute</option>
												<option value="00" <%if (minute != null && minute.equals("00")) {%>selected<%}%>>00</option>
												<option value="01" <%if (minute != null && minute.equals("01")) {%>selected<%}%>>01</option>
												<option value="02" <%if (minute != null && minute.equals("02")) {%>selected<%}%>>02</option>
												<option value="03" <%if (minute != null && minute.equals("03")) {%>selected<%}%>>03</option>
												<option value="04" <%if (minute != null && minute.equals("04")) {%>selected<%}%>>04</option>
												<option value="05" <%if (minute != null && minute.equals("05")) {%>selected<%}%>>05</option>
												<option value="06" <%if (minute != null && minute.equals("06")) {%>selected<%}%>>06</option>
												<option value="07" <%if (minute != null && minute.equals("07")) {%>selected<%}%>>07</option>
												<option value="08" <%if (minute != null && minute.equals("08")) {%>selected<%}%>>08</option>
												<option value="09" <%if (minute != null && minute.equals("09")) {%>selected<%}%>>09</option>
												<option value="10" <%if (minute != null && minute.equals("10")) {%>selected<%}%>>10</option>
												<option value="11" <%if (minute != null && minute.equals("11")) {%>selected<%}%>>11</option>
												<option value="12" <%if (minute != null && minute.equals("12")) {%>selected<%}%>>12</option>
												<option value="13" <%if (minute != null && minute.equals("13")) {%>selected<%}%>>13</option>
												<option value="14" <%if (minute != null && minute.equals("14")) {%>selected<%}%>>14</option>
												<option value="15" <%if (minute != null && minute.equals("15")) {%>selected<%}%>>15</option>
												<option value="16" <%if (minute != null && minute.equals("16")) {%>selected<%}%>>16</option>
												<option value="17" <%if (minute != null && minute.equals("17")) {%>selected<%}%>>17</option>
												<option value="18" <%if (minute != null && minute.equals("18")) {%>selected<%}%>>18</option>
												<option value="19" <%if (minute != null && minute.equals("19")) {%>selected<%}%>>19</option>
												<option value="20" <%if (minute != null && minute.equals("20")) {%>selected<%}%>>20</option>
												<option value="21" <%if (minute != null && minute.equals("21")) {%>selected<%}%>>21</option>
												<option value="22" <%if (minute != null && minute.equals("22")) {%>selected<%}%>>22</option>
												<option value="23" <%if (minute != null && minute.equals("23")) {%>selected<%}%>>23</option>
												<option value="24" <%if (minute != null && minute.equals("24")) {%>selected<%}%>>24</option>
												<option value="25" <%if (minute != null && minute.equals("25")) {%>selected<%}%>>25</option>
												<option value="26" <%if (minute != null && minute.equals("26")) {%>selected<%}%>>26</option>
												<option value="27" <%if (minute != null && minute.equals("27")) {%>selected<%}%>>27</option>
												<option value="28" <%if (minute != null && minute.equals("28")) {%>selected<%}%>>28</option>
												<option value="29" <%if (minute != null && minute.equals("29")) {%>selected<%}%>>29</option>
												<option value="30" <%if (minute != null && minute.equals("30")) {%>selected<%}%>>30</option>
												<option value="31" <%if (minute != null && minute.equals("31")) {%>selected<%}%>>31</option>
												<option value="32" <%if (minute != null && minute.equals("32")) {%>selected<%}%>>32</option>
												<option value="33" <%if (minute != null && minute.equals("33")) {%>selected<%}%>>33</option>
												<option value="34" <%if (minute != null && minute.equals("34")) {%>selected<%}%>>34</option>
												<option value="35" <%if (minute != null && minute.equals("35")) {%>selected<%}%>>35</option>
												<option value="36" <%if (minute != null && minute.equals("36")) {%>selected<%}%>>36</option>
												<option value="37" <%if (minute != null && minute.equals("37")) {%>selected<%}%>>37</option>
												<option value="38" <%if (minute != null && minute.equals("38")) {%>selected<%}%>>38</option>
												<option value="39" <%if (minute != null && minute.equals("39")) {%>selected<%}%>>39</option>
												<option value="40" <%if (minute != null && minute.equals("40")) {%>selected<%}%>>40</option>
												<option value="41" <%if (minute != null && minute.equals("41")) {%>selected<%}%>>41</option>
												<option value="42" <%if (minute != null && minute.equals("42")) {%>selected<%}%>>42</option>
												<option value="43" <%if (minute != null && minute.equals("43")) {%>selected<%}%>>43</option>
												<option value="44" <%if (minute != null && minute.equals("44")) {%>selected<%}%>>44</option>
												<option value="45" <%if (minute != null && minute.equals("45")) {%>selected<%}%>>45</option>
												<option value="46" <%if (minute != null && minute.equals("46")) {%>selected<%}%>>46</option>
												<option value="47" <%if (minute != null && minute.equals("47")) {%>selected<%}%>>47</option>
												<option value="48" <%if (minute != null && minute.equals("48")) {%>selected<%}%>>48</option>
												<option value="49" <%if (minute != null && minute.equals("49")) {%>selected<%}%>>49</option>
												<option value="50" <%if (minute != null && minute.equals("50")) {%>selected<%}%>>50</option>
												<option value="51" <%if (minute != null && minute.equals("51")) {%>selected<%}%>>51</option>
												<option value="52" <%if (minute != null && minute.equals("52")) {%>selected<%}%>>52</option>
												<option value="53" <%if (minute != null && minute.equals("53")) {%>selected<%}%>>53</option>
												<option value="54" <%if (minute != null && minute.equals("54")) {%>selected<%}%>>54</option>
												<option value="55" <%if (minute != null && minute.equals("55")) {%>selected<%}%>>55</option>
												<option value="56" <%if (minute != null && minute.equals("56")) {%>selected<%}%>>56</option>
												<option value="57" <%if (minute != null && minute.equals("57")) {%>selected<%}%>>57</option>
												<option value="58" <%if (minute != null && minute.equals("58")) {%>selected<%}%>>58</option>
												<option value="59" <%if (minute != null && minute.equals("59")) {%>selected<%}%>>59</option>
											</select>
											
											
                                        <a href="javascript:glossary('UTC')">UTC</a>
                                    </span>
                                </div>
                            <% } if (action.equals("edit")){ %>
                                <div id="edit_title">
                                    Edit Detector <c:out value="${param.detectorID}"/>: 
                                    <%=geoEntry.getPrettyMonth() + " " + geoEntry.getPrettyDayNumber() + ", " + 
                                    geoEntry.getPrettyLongYear() + " @ " + geoEntry.getFormTime() + " UTC"/*geoEntry.getPrettyAMPM()*/%>
                                </div>
                            <% } %>

                            <input type="hidden" name="julianDay" value="<%=geoEntry.getJulianDay()%>">
                            <input type="hidden" name="detectorID" value="<%=geoEntry.getDetectorID()%>">
                            <div class="edit_subheading">
                                Detector Configuration
                                <br>
                                <span style="font-size:70%">
                                    Confused? Seeing errors? Please consult the <a href="geoInstructions.jsp">tutorial</a>.
                                </span>
				            <br>
<%
                            // Print out an error message if an invalid value has been input by the user and DON'T let them commit.
                            //   For some reason, committing geometry with invalid values erases the entire .geo file.
                            if (invalidChan1CableLength) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your channel 1 Cable Length value is correct.</span><br>");
                            }
                            if (invalidChan2CableLength) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your channel 2 Cable Length value is correct.</span><br>");
                            }
                            if (invalidChan3CableLength) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your channel 3 Cable Length value is correct.</span><br>");
                            }
                            if (invalidChan4CableLength) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your channel 4 Cable Length value is correct.</span><br>");
                            }
                            if (invalidChan1Area) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your channel 1 Area value is correct.</span><br>");
                            }
                            if (invalidChan2Area) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your channel 2 Area value is correct.</span><br>");
                            }
                            if (invalidChan3Area) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your channel 3 Area value is correct.</span><br>");
                            }
                            if (invalidChan4Area) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your channel 4 Area value is correct.</span><br>");
                            }
                            if (invalidChan1X) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your channel 1 E-W value is correct.</span><br>");
                            }
                            if (invalidChan2X) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your channel 2 E-W value is correct.</span><br>");
                            }
                            if (invalidChan3X) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your channel 3 E-W value is correct.</span><br>");
                            }
                            if (invalidChan4X) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your channel 4 E-W value is correct.</span><br>");
                            }
                            if (invalidChan1Y) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your channel 1 N-S value is correct.</span><br>");
                            }
                            if (invalidChan2Y) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your channel 2 N-S value is correct.</span><br>");
                            }
                            if (invalidChan3Y) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your channel 3 N-S value is correct.</span><br>");
                            }
                            if (invalidChan4Y) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your channel 4 N-S value is correct.</span><br>");
                            }
                            if (invalidChan1Z) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your channel 1 Up-Dn value is correct.</span><br>");
                            }
                            if (invalidChan2Z) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your channel 2 Up-Dn value is correct.</span><br>");
                            }
                            if (invalidChan3Z) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your channel 3 Up-Dn value is correct.</span><br>");
                            }
                            if (invalidChan4Z) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your channel 4 Up-Dn value is correct.</span><br>");
                            }
%>
                            </div>

                            <div id="geo_channels">
                            <table border="0" cellspacing="5" cellpadding="2">
                                <tr>
                                    <td>&nbsp;</td>
                                    <td><span style="font-size:120%; color: #000000">Active<br>Channels:</span></td>
                                    <td><span style="font-size:135%; color: #000000">1</span><input type="checkbox" name="chan1Active" 
                                        onclick="HideShow('chan1_input_fields');HideShow('chan1_none')" <%if (chan1IsActive) {%>checked<%}%>></td>
                                    <td><span style="font-size:135%; color: #000000">2</span><input type="checkbox" name="chan2Active" 
                                        onclick="HideShow('chan2_input_fields');HideShow('chan2_none')" <%if (chan2IsActive) {%>checked<%}%>></td>
                                    <td><span style="font-size:135%; color: #000000">3</span><input type="checkbox" name="chan3Active" 
                                        onclick="HideShow('chan3_input_fields');HideShow('chan3_none')" <%if (chan3IsActive) {%>checked<%}%>></td>
                                    <td><span style="font-size:135%; color: #000000">4</span><input type="checkbox" name="chan4Active" 
                                        onclick="HideShow('chan4_input_fields');HideShow('chan4_none')" <%if (chan4IsActive) {%>checked<%}%>></td>
                                </tr>
                                <tr>
                                    <td valign="middle">&nbsp;</td>
                                    <td valign="middle">Cable<br>Length<span style="font-size:90%"> (m)</span></td>
                                    <td valign="bottom">Area <span style="font-size:90%">(cm<sup>2</sup>)</span></td>
                                    <td valign="bottom">E-W <span style="font-size:90%">(m)</span></td>
                                    <td valign="bottom">N-S <span style="font-size:90%">(m)</span></td>
                                    <td valign="bottom">Up-Dn <span style="font-size:90%">(m)</span></td>
                                </tr>
                                <% if (chan1IsActive) { %>
                                <tbody id="chan1_input_fields" style="visibility: visible; display:">
                                <% } else { %>
                                <tbody id="chan1_input_fields" style="visibility: hidden; display: none">
                                <% } %>
                                <tr>
                                    <td style="padding-right:5px"><img src="graphics/geo_det1.gif"></td>
                                    <td><input type="text" name="chan1CableLength" size="4" value="<%=geoEntry.getChan1CableLength()%>"></td>
                                    <td><input type="text" name="chan1Area" size="6" value="<%=geoEntry.getChan1Area()%>"></td>
                                    <td><input type="text" name="chan1X" size="5" value="<%=geoEntry.getChan1X()%>"></td>
                                    <td><input type="text" name="chan1Y" size="5" value="<%=geoEntry.getChan1Y()%>"></td>
                                    <td><input type="text" name="chan1Z" size="5" value="<%=geoEntry.getChan1Z()%>"></td>
                                </tr>
                                </tbody>
                                <% if (chan1IsActive) { %>
                                <tbody id="chan1_none" style="visibility: hidden; display: none">
                                <% } else { %>
                                <tbody id="chan1_none" style="visibility: visible; display:">
                                <% } %>
                                <tr>
                                    <td style="padding-right:5px"><img src="graphics/geo_det1.gif"></td>
                                    <td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
                                </tr>
                                </tbody>
                                <% if (chan2IsActive) { %>
                                <tbody id="chan2_input_fields" style="visibility: visible; display:">
                                <% } else { %>
                                <tbody id="chan2_input_fields" style="visibility: hidden; display: none">
                                <% } %>
                                <tr>
                                    <td style="padding-right:5px"><img src="graphics/geo_det2.gif"></td>
                                    <td><input type="text" name="chan2CableLength" size="4" value="<%=geoEntry.getChan2CableLength()%>"></td>
                                    <td><input type="text" name="chan2Area" size="6" value="<%=geoEntry.getChan2Area()%>"></td>
                                    <td><input type="text" name="chan2X" size="5" value="<%=geoEntry.getChan2X()%>"></td>
                                    <td><input type="text" name="chan2Y" size="5" value="<%=geoEntry.getChan2Y()%>"></td>
                                    <td><input type="text" name="chan2Z" size="5" value="<%=geoEntry.getChan2Z()%>"></td>
                                </tr>
                                </tbody>
                                <% if (chan2IsActive) { %>
                                <tbody id="chan2_none" style="visibility: hidden; display: none">
                                <% } else { %>
                                <tbody id="chan2_none" style="visibility: visible; display:">
                                <% } %>
                                <tr>
                                    <td style="padding-right:5px"><img src="graphics/geo_det2.gif"></td>
                                    <td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
                                </tr>
                                </tbody>
                                <% if (chan3IsActive) { %>
                                <tbody id="chan3_input_fields" style="visibility: visible; display:">
                                <% } else { %>
                                <tbody id="chan3_input_fields" style="visibility: hidden; display: none">
                                <% } %>
                                <tr>
                                    <td style="padding-right:5px"><img src="graphics/geo_det3.gif"></td>
                                    <td><input type="text" name="chan3CableLength" size="4" value="<%=geoEntry.getChan3CableLength()%>"></td>
                                    <td><input type="text" name="chan3Area" size="6" value="<%=geoEntry.getChan3Area()%>"></td>
                                    <td><input type="text" name="chan3X" size="5" value="<%=geoEntry.getChan3X()%>"></td>
                                    <td><input type="text" name="chan3Y" size="5" value="<%=geoEntry.getChan3Y()%>"></td>
                                    <td><input type="text" name="chan3Z" size="5" value="<%=geoEntry.getChan3Z()%>"></td>
                                </tr>
                                </tbody>
                                <% if (chan3IsActive) { %>
                                <tbody id="chan3_none" style="visibility: hidden; display: none">
                                <% } else { %>
                                <tbody id="chan3_none" style="visibility: visible; display:">
                                <% } %>
                                <tr>
                                    <td style="padding-right:5px"><img src="graphics/geo_det3.gif"></td>
                                    <td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
                                </tr>
                                </tbody>
                                <% if (chan4IsActive) { %>
                                <tbody id="chan4_input_fields" style="visibility: visible; display:">
                                <% } else { %>
                                <tbody id="chan4_input_fields" style="visibility: hidden; display: none">
                                <% } %>
                                <tr>
                                    <td style="padding-right:5px"><img src="graphics/geo_det4.gif"></td>
                                    <td><input type="text" name="chan4CableLength" size="4" value="<%=geoEntry.getChan4CableLength()%>"></td>
                                    <td><input type="text" name="chan4Area" size="6" value="<%=geoEntry.getChan4Area()%>"></td>
                                    <td><input type="text" name="chan4X" size="5" value="<%=geoEntry.getChan4X()%>"></td>
                                    <td><input type="text" name="chan4Y" size="5" value="<%=geoEntry.getChan4Y()%>"></td>
                                    <td><input type="text" name="chan4Z" size="5" value="<%=geoEntry.getChan4Z()%>"></td>
                                </tr>
                                </tbody>
                                <% if (chan4IsActive) { %>
                                <tbody id="chan4_none" style="visibility: hidden; display: none">
                                <% } else { %>
                                <tbody id="chan4_none" style="visibility: visible; display:">
                                <% } %>
                                <tr>
                                    <td style="padding-right:5px"><img src="graphics/geo_det4.gif"></td>
                                    <td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
                                </tr>
                                </tbody>
                            </table>
                            </div>
                            <%
                            // Smart checking to make sure if user chooses "stacked" orientation, all the E-W and N-S values will match and all the Up-Dn values will differ
                            if (smartCheckStackedEWFailed) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">With stacked orientation, the E-W values for all four channels should be equal.</span><br>");
                            }
                            if (smartCheckStackedNSFailed) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">With stacked orientation, the N-S values for all four channels should be equal.</span><br>");
                            }
                            if (smartCheckStackedUpDnFailed) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">With stacked orientation, the Up-Dn values for all four channels should be different.</span><br>");
                            }
                            %>
                            <center>
                                <div id="geo_orientation">
                                    <table border="0">
                                        <tr>
                                            <td valign="middle" width="31">
                                                <img src="graphics/med_stacked.gif">
                                                <input type="radio" name="stackedState" value="1"
                                                    <%if (geoEntry.getStackedState().equals("1")) {%>checked<%}%>>
                                            </td>
                                            <td valign="middle" >
                                                <span style="padding-left:20px; padding-right:20px">Orientation</span>
                                            </td>
                                            <td valign="bottom" width="68">
                                                <img src="graphics/med_unstacked.gif">
                                                <input type="radio" name="stackedState" value="0"
                                                    <%if (geoEntry.getStackedState().equals("0")) {%>checked<%}%>>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </center>

                            <div class="edit_subheading">GPS Location</div>
<%
                            // Print out an error message if an invalid value has been input by the user and DON'T let them commit.
                            //   For some reason, committing geometry with invalid values erases the entire .geo file.
                            if (invalidLatitude) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your Latitude value is correct (see e.g. format below).</span><br>");
                            }
                            if (invalidLongitude) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your Longitude value is correct (see e.g. format below).</span><br>");
                            }
                            if (invalidAltitude) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your Altitude value is correct.</span><br>");
                            }
                            if (invalidGpsCableLength) {
                                out.write("<span style=\"font-size:11; color: #EE0000\">Please check that your GPS Cable Length value is correct.</span><br>");
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
                                    </tr>
                                    <tr valign="top">
                                        <td>
                                            Altitude (m): <input type=text" name="altitude" size="3" value="<%=geoEntry.getAltitude()%>">
                                        </td>
                                        <td>
                                            GPS Cable Length (m): <input type="text" name="gpsCableLength" size="4" value="<%=geoEntry.getGpsCableLength()%>">
                                        </td>
                                    </tr>
                                </table>
                            </div>

                            <center>
                                <input type="submit" name="commit" value="Commit Geometry">
                            </center>
                        
                        <% } else if (deleteConfirm == null && (action != null && action.equals("delete"))){ %>
                            <div id="edit_title">
                                Delete Detector <c:out value="${param.detectorID}"/> Entry: 
                                <%=geoEntry.getPrettyMonth() + " " + geoEntry.getPrettyDayNumber() + ", " + 
                                geoEntry.getPrettyLongYear() + " @ " + geoEntry.getFormTime() + " UTC"/*geoEntry.getPrettyAMPM()*/%>
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
                        <% } else { %>
                            <div id="edit_title">
                                Please choose an action to your left.
                                <br>
                                <br>
                                <span style="font-size:75%">
                                    Confused? Seeing errors? Please consult the <a href="geoInstructions.jsp">tutorial</a>.
                                </span>
                            </div>
                        <% } %>
                </div>
            </div>
        </div>
    </form>
</body>
<%
if (s != null)
    s.close();
if (conn != null)
    conn.close();
%>
</html>
