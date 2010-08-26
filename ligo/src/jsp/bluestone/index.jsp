<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Super-Bluestone</title>
		<!--[if lte IE 8]><script language="javascript" type="text/javascript" src="../include/excanvas.min.js"></script><![endif]-->
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>

		<style type="text/css">
			span.dataName {
				font-size: x-small;
			}
			span.rotate-text-left {
				position: absolute;
				width: 0px;
				height: 0px;
				-webkit-transform: rotate(-90deg); 
				-moz-transform: rotate(-90deg);	
				filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);
			}
			td#yAxisLabeltd {
				width: 20px;
			}
		</style>
	</head>
    
    <body id="super-bluestone" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				<noscript><b>This page requires Javascript</b><br /><br /></noscript>
				<%-- Scripts need to be loaded after nav-rollover since that is where the js pages live --%>
				<script language="javascript" type="text/javascript" src="../include/jquery/flot/jquery.flot.min.js"></script>
			    <script language="javascript" type="text/javascript" src="../include/jquery/flot/jquery.flot.selection.min.js"></script>
			    <script src="general.js" type="text/javascript"></script> <%-- General common stuff --%>
			    <script src="advanced.js" type="text/javascript"></script> <%-- Advanced Mode --%>
				
				<h1>Bluestone <span style="color: red">2.0 Public Beta </span></h1>
				<div style="text-align:right">Need help? Try the <e:popup href="../library/ref-analysis.jsp" target="help" width="450" height="600" toolbar="true">Practice Plots</e:popup>.</div>
				<br />
				Time<sub>start</sub>: <input readonly type="text" name="xmin" id="xmin" size="15" class="datepicker"></input>
				Time<sub>end</sub>: <input readonly type="text" name="xmax" id="xmax" size="15" class="datepicker"></input>
				<button id="plotButtonTop" class="plotButton" value="Plot">Plot</button>
				<img src="../graphics/spinner-small.gif" id="busySpinner" style="visibility: hidden"></img>
				<%-- <button title="Zoom to selection" id="buttonZoom" disabled>Zoom to selection</button> --%>
				<button title="Zoom all the way out" id="buttonZoomOut" disabled>Zoom all the way out</button>
				<input type="checkbox" name="log" value="y-axis" id="logYcheckbox" class="logCheckbox" />Y-Axis Log Scale
				
				
				<table>
					<tr>
						<td id="yAxisLabeltd"><span class="rotate-text-left" id="yAxisLabel">&nbsp;</span></td>
						<td width="850">
							<div id="resizablecontainer" style="margin-bottom: 10px; margin-right: 10px;" >
								<div id="chart" style="width:100%; height:250px; text-align: left;"></div>
							</div>
						</td>
					</tr>
					<tr>
						<td>&nbsp;</td>
						<td align="center"><span id="xAxisLabel">Date</span></td>
					</tr>
				</table>
					
					<%-- Temporarily disabled while I figure out how to properly resize the bar - pxn
					<div id="slider"></div>
					--%>
								
				<br />
				
				<%-- <input class="commandLine" type="text" size="100" style="width:300px;"></input> 
				<input class="parseCommandLine" type="button" value="Execute Command"></input>
				<input class="fetchData" type="button" value="Get Test Data!"></input>  --%>
				
				<%-- Super basic demo mode stuff for testing / showing-off
				
				<div id="channel_list">
					<select name="channel" id="channelSelector"> 
						<option value="placeholder">Select a channel: </option>
						<option value="L0:PEM-LVEA_SEISX.mean">Livingston X-Axis Vault Seismometer</option>
						<option value="L0:PEM-LVEA_SEISY.mean">Livingston Y-Axis Vault Seismometer</option>
						<option value="L0:PEM-LVEA_SEISZ.mean">Livingston Z-Axis Vault Seismometer</option>
						<option value="H0:PEM-LVEA_SEISX.mean">Hanford X-Axis Vault Seismometer</option>
						<option value="H0:PEM-LVEA_SEISY.mean">Hanford Y-Axis Vault Seismometer</option>
						<option value="H0:PEM-LVEA_SEISZ.mean">Hanford Z-Axis Vault Seismometer</option>
					</select>
					<input id="parseDropDown" type="button" value="Plot"></input>
				</div>
				
				--%>
				
				<%-- Advanced Mode --%>
				
				<h2>Data Selection<e:popup href="/glossary/kiwi.php/Data_Channel" target="help" width="600" height="600" toolbar="true"><sup>?</sup></e:popup></h2>
				
				<div id="channel-list-advanced">
					<table id="channelTable">
						<thead>
							<tr>
								<th>Add/Remove</th>
								<th>Site<e:popup href="/glossary/kiwi.php/Data_Channel_Source" target="help" width="400" height="500" toolbar="true"><sup>?</sup></e:popup>
</th>
								<th>Subsystem<e:popup href="/glossary/kiwi.php/Data_Channel_Subsystem" target="help" width="500" height="400" toolbar="true"><sup>?</sup></e:popup></th>
								<th>Station<e:popup href="/glossary/kiwi.php/Data_Channel_Station" target="help" width="500" height="400" toolbar="true"><sup>?</sup></e:popup></th>
								<th>Sensor<e:popup href="/glossary/kiwi.php/Data_Channel_Sensor" target="help" width="500" height="400" toolbar="true"><sup>?</sup></e:popup></th>
								<th>Sampling<e:popup href="/glossary/kiwi.php/Data_Channel_Sampling" target="help" width="500" height="400" toolbar="true"><sup>?</sup></e:popup></th>
								<th>Data Filename</th>
							</tr>
						</thead>
						<tbody>
							<tr id="row_0">
								<td>
									<input type="button" value="Remove This Row" id="removeRow_0" class="removeRow"></input>
								</td>
								<td>
									<select name="site" id="site_0" class="site">
										<option value="H0">H0</option>
										<option value="L0">L0</option>
									</select>
								</td>
								<td>
									<select name="subsystem" id="subsystem_0" class="subsystem">
										<option value="DMT-BRMS_PEM_">DMT</option>
										<option value="PEM-">PEM</option>
										<option value="GDS-">GDS</option>
									</select>
								</td>
								<td>
									<select name="station" id="station_0" class="station"></select>
								</td>
								<td>
									<select name="sensor" id="sensor_0" class="sensor"></select>
								</td>
								<td>
									<select name="sampling" id="sampling_0" class="sampling"></select>
								</td>
								<td>
									<span id="dataName_0" class="dataName"></span>
								</td>
							</tr>
						</tbody>
					</table>
					
				</div>
				
				<input id="addNewRow" type="button" value="Add Data Row"></input>
				<br />
				<button id="plotButtonBottom" class="plotButton" value="Plot">Plot</button>
				
				<h2>Save This Plot</h2>
				
				Title: <input id="userPlotTitle" name="title" type="text" maxlength="200" size="30"></input>
				<input id="savePlotToDisk" type="button" value="Save" disabled></input>
				<img src="../graphics/spinner-small.gif" style="visibility: hidden;" id="busySpinnerSmall"></img>
				<a href="#" target="_new" id="savedPlotLink" style="display: none;">View saved plot (popup)</a> 
			</div>
			
			<div id="footer">
				<%@ include file="../include/nav-footer.jsp" %>
			</div>
		</div>
	</body>

</html>
