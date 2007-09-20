<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.cosmic.beans.Geometries" %>
<%@ page import="gov.fnal.elab.cosmic.beans.GeoEntryBean" %>
<%@ page import="gov.fnal.elab.cosmic.Geometry" %>
<%@ page import="java.util.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>View Geometry</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
		<%@ include file="../jsp/include/geo_style.css" %>
		<style type="text/css">
			div#edit_geo_entry1 {
				width: 500px;
				background: #CCCCCC;
				color: #000;
       			text-align: left;
				margin-left: auto;
				margin-right: auto;
            }
        </style>
	</head>
	
	<body id="view-geometry" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-data.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">

<table border="0" id="main">
	<tr>
		<td id="center">
			<% 
				String filename = request.getParameter("filename");
				String detectorId;
				Object rdo;
				if (filename == null) {
					detectorId = request.getParameter("id");
					if (detectorId == null) {
				    	throw new ElabJspException("Missing both file name and detector id.");
				    }
				    rdo = request.getParameter("julianstartdate");
				    if (rdo == null) {
				    	throw new ElabJspException("Missing julianstartdate");
				    }
				}
				else {
					CatalogEntry entry = elab.getDataCatalogProvider().getEntry(filename);
					if (entry == null) {
				    	throw new ElabJspException("No metadata about " + filename + " found.");
					}
					request.setAttribute("e", entry);
					//[m] grr 
					rdo = entry.getTupleValue("julianstartdate");
					if (rdo == null) {
						if (rdo == null) {
							throw new ElabJspException(filename + " is missing the Julian start date");
						}
					}
					detectorId = (String) entry.getTupleValue("detectorid");
					if (detectorId == null) {
						throw new ElabJspException("No detector associated with " + filename);
					}
				}
				
				String jd = rdo.toString();
				request.setAttribute("detectorId", detectorId);
				Geometry geometry = new Geometry(elab.getProperties().getDataDir(), detectorId);
				if (geometry == null || geometry.isEmpty()) {
					throw new ElabJspException("Error: no geometry information for detector " + detectorId);
				}
				//so, we're looking for the last entry before the date of the file
				//but there's some weirdness. Perhaps in the case of julian dates
				//lexicongraphic order is the same as temporal order
				//It certainly seems like Geometry.java thinks that way
				SortedMap geos = geometry.getGeoEntriesBefore(jd);
				if (geos.isEmpty()) {
					throw new ElabJspException("Error: no geometry information for detector " + 
						detectorId + " for when this data was taken.");
				}
				request.setAttribute("g", geos.get(geos.lastKey()));
			%>
			
			<c:if test="${param.filename != null}">
				<a href="../data/view.jsp?filename=${param.filename}">Show Data</a>
				<a href="../data/view-metadata.jsp?filename=${param.filename}">Show Metadata</a>
			</c:if>
			
			<h2>Geometry for ${param.filename == null ? param.id : param.filename}</h2>
			
			<div id="geo_container">
				<div id="edit_geo_entry1">
					<div class="geo_padded_interior">
						<div id="edit_title">
                    		Detector ${detectorId}: ${g.prettyMonth}  ${g.prettyDayNumber}, ${g.prettyLongYear} @ ${g.formTime}  UTC
                    	</div>
						<div class="edit_subheading">
							Detector Configuration<br/>
						</div>
						<div id="geo_channels">
							<table border="0" cellspacing="5" cellpadding="2">
								<tr>
                    				<td>&nbsp;</td>
									<td><span style="font-size:120%; color: #000000">Active<br/>Channels:</span></td>
									<td>
										<c:if test="${g.chan1IsActive}">
											<span style="font-size:135%; color: #000000">1</span>
										</c:if>
										&nbsp;
									</td>
									<td>
										<c:if test="${g.chan2IsActive}">
											<span style="font-size:135%; color: #000000">2</span>
										</c:if>
										&nbsp;
									</td>
									<td>
										<c:if test="${g.chan3IsActive}">
											<span style="font-size:135%; color: #000000">3</span>
										</c:if>
										&nbsp;
									</td>
									<td>
										<c:if test="${g.chan4IsActive}">
											<span style="font-size:135%; color: #000000">4</span>
										</c:if>
										&nbsp;
									</td>
								</tr>
								<tr>
									<td valign="middle">&nbsp;</td>
									<td valign="middle">Cable<br/>Length<span style="font-size:90%"> (m)</span></td>
									<td valign="bottom">Area <span style="font-size:90%">(cm<sup>2</sup>)</span></td>
									<td valign="bottom">E-W <span style="font-size:90%">(m)</span></td>
									<td valign="bottom">N-S <span style="font-size:90%">(m)</span></td>
									<td valign="bottom">Up-Dn <span style="font-size:90%">(m)</span></td>
								</tr>
								<tr>
									<c:choose>
										<c:when test="${g.chan1IsActive}">
											<td style="padding-right:5px"><img src="../graphics/geo_det1.gif"/></td>
											<td><span style="font-size:110%; color: #000000">${g.chan1CableLength}</span></td>
											<td><span style="font-size:110%; color: #000000">${g.chan1Area}</span></td>
											<td><span style="font-size:110%; color: #000000">${g.chan1X}</span></td>
											<td><span style="font-size:110%; color: #000000">${g.chan1Y}</span></td>
											<td><span style="font-size:110%; color: #000000">${g.chan1Z}</span></td>
										</c:when>
										<c:otherwise>
											<td style="padding-right:5px"><img src="../graphics/geo_det1.gif"/></td>
											<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
										</c:otherwise>
									</c:choose>
								</tr>
								<tr>
									<c:choose>
										<c:when test="${g.chan2IsActive}">
											<td style="padding-right:5px"><img src="../graphics/geo_det2.gif"/></td>
											<td><span style="font-size:110%; color: #000000">${g.chan2CableLength}</span></td>
											<td><span style="font-size:110%; color: #000000">${g.chan2Area}</span></td>
											<td><span style="font-size:110%; color: #000000">${g.chan2X}</span></td>
											<td><span style="font-size:110%; color: #000000">${g.chan2Y}</span></td>
											<td><span style="font-size:110%; color: #000000">${g.chan2Z}</span></td>
										</c:when>
										<c:otherwise>
											<td style="padding-right:5px"><img src="../graphics/geo_det2.gif"/></td>
											<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
										</c:otherwise>
									</c:choose>
								</tr>
								<tr>
									<c:choose>
										<c:when test="${g.chan3IsActive}">
											<td style="padding-right:5px"><img src="../graphics/geo_det3.gif"/></td>
											<td><span style="font-size:110%; color: #000000">${g.chan3CableLength}</span></td>
											<td><span style="font-size:110%; color: #000000">${g.chan3Area}</span></td>
											<td><span style="font-size:110%; color: #000000">${g.chan3X}</span></td>
											<td><span style="font-size:110%; color: #000000">${g.chan3Y}</span></td>
											<td><span style="font-size:110%; color: #000000">${g.chan3Z}</span></td>
										</c:when>
										<c:otherwise>
											<td style="padding-right:5px"><img src="../graphics/geo_det3.gif"/></td>
											<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
										</c:otherwise>
									</c:choose>
								</tr>
								<tr>
									<c:choose>
										<c:when test="${g.chan4IsActive}">
											<td style="padding-right:5px"><img src="../graphics/geo_det4.gif"/></td>
											<td><span style="font-size:110%; color: #000000">${g.chan4CableLength}</span></td>
											<td><span style="font-size:110%; color: #000000">${g.chan4Area}</span></td>
											<td><span style="font-size:110%; color: #000000">${g.chan4X}</span></td>
											<td><span style="font-size:110%; color: #000000">${g.chan4Y}</span></td>
											<td><span style="font-size:110%; color: #000000">${g.chan4Z}</span></td>
										</c:when>
										<c:otherwise>
											<td style="padding-right:5px"><img src="../graphics/geo_det4.gif"/></td>
											<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
										</c:otherwise>
									</c:choose>
								</tr>
							</table>
						</div>
						<center>
							<div id="geo_orientation">
								<table border="0">
									<tr>
										<td valign="middle" width="31">
											<c:if test="${g.stackedState == '1'}">
												<img src="../graphics/med_stacked.gif"/>
											</c:if>
											&nbsp;
										</td>
										<td valign="middle">
											<span style="padding-left:20px; padding-right:20px">Orientation</span>
										</td>
										<td valign="bottom" width="68">
											<c:if test="${g.stackedState == '0'}">
												<img src="../graphics/med_unstacked.gif"/>
											</c:if>
											&nbsp;
										</td>
                    				</tr>
                    			</table>
                    		</div>
                    	</center>
						<div class="edit_subheading">GPS Location</div>
						<div id="geo_gps">
							<table border="0" cellspacing="3">
								<tr valign="top">
									<td>
										Latitude: <span style="color: #000000">${g.formLatitude}</span>
                   					</td>
                   					<td>
										Longitude: <span style="color: #000000">${g.formLongitude}</span>
									</td>
                   				</tr>
								<tr valign="top">
									<td>
										Altitude (m): <span style="color: #000000">${g.altitude}</span>
									</td>
									<td>
										GPS Cable Length (m): <span style="color: #000000">${g.gpsCableLength}</span>
									</td>
								</tr>
							</table>
						</div>
					</div>
				</div>
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
