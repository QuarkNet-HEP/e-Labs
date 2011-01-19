<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>

		<title>CMS 3D Event Display</title>

		<link href="scrollbar.css" rel="stylesheet" type="text/css" />
		<link href="eventdisplay.css" rel="stylesheet" type="text/css" />
		<link href="eventdisplay.css" rel="stylesheet" type="text/css" />
		
		<link href="settings.css" rel="stylesheet" type="text/css" />
		<link href="range-selection.css" rel="stylesheet" type="text/css" />
		<link href="event-browser.css" rel="stylesheet" type="text/css" />
		<link href="speed-test.css" rel="stylesheet" type="text/css" />
		
		<script type="text/javascript" src="jquery-1.4.3.min.js"></script>
		<script type="text/javascript" src="jquery.jeegoocontext.min.js"></script>
		<script type="text/javascript" src="pre3d.js"></script>
		<script type="text/javascript" src="pre3d_shape_utils.js"></script>
		<script type="text/javascript" src="base64.js"></script>		
		<script type="text/javascript" src="elab.js"></script>
		<script type="text/javascript" src="utils.js"></script>
		<script type="text/javascript" src="flexcroll.js"></script>
		<script type="text/javascript" src="canvas2image.js"></script>
		<script type="text/javascript" src="demo_utils.js"></script>
		<script type="text/javascript" src="object-conversion.js"></script>
		<script type="text/javascript" src="detector-model-gen.js"></script>
		<script type="text/javascript" src="data-description.js"></script>
		<script type="text/javascript" src="about.js"></script>
		<script type="text/javascript" src="eventdisplay.js"></script>
		<script type="text/javascript" src="settings.js"></script>
		<script type="text/javascript" src="range-selection.js"></script>
		<script type="text/javascript" src="event-browser.js"></script>
		<script type="text/javascript" src="speed-test.js"></script>
		
	</head>
	<body class="black">
	<script>
		initlog(false);
	</script>
<table>
	<tr>
		<td colspan="2" class="titlebar-plain bordered">
			<div id="title"></div>
		</td>
	</tr>
	<tr height="24px">
		<td colspan="2" class="bordered">
			<!-- toolbar.jspf -->
			
			<table id="toolbar">
				<tr>
					<td>
						<a class="toolbar-button" onclick="showEventBrowser();">
							<img src="../graphics/open.png" title="Open"/>
						</a>
					</td>
					<td>
						<a class="toolbar-button" onclick="renderCanvasData();">
							<img src="../graphics/image-x-generic.png" title="Open Image in New Window"/>
						</a>
					</td>
					<td class="toolbar-separator">
						&nbsp;
					</td>
					<td>
						<a class="toolbar-button disabled" id="prev-event-button" onclick="prevEvent();">
							<img src="../graphics/prev-event.png" title="Previous Event"/>
						</a>
					</td>
					<td>
						<a class="toolbar-button disabled" id="next-event-button" onclick="nextEvent();">
							<img src="../graphics/next-event.png" title="Next Event"/>
						</a>
					</td>
					<td class="toolbar-separator">
						&nbsp;
					</td>
					<td>
						<a class="toolbar-button" onclick="setCameraRotation(0, 0, 0);">
							<img src="../graphics/z-plane.png" title="X-Y Plane"/>
						</a>
					</td>
					<td>
						<a class="toolbar-button" onclick="setCameraRotation(0, Math.PI / 2, Math.PI / 2);">
							<img src="../graphics/y-plane.png" title="Z-X Plane"/>
						</a>
					</td>
					<td>
						<a class="toolbar-button" onclick="setCameraRotation(0, Math.PI / 2, 0);">
							<img src="../graphics/x-plane.png" title="Y-Z Plane"/>
						</a>
					</td>
					<td class="toolbar-separator">
						&nbsp;
					</td>
					<td>
						<a class="toolbar-button" id="perspective-view" onclick="setPerspectiveProjection(true);">
							<img src="../graphics/perspective-projection.png" title="Perspective View"/>
						</a>
					</td>
					<td>
						<a class="toolbar-button" id="orthographic-view" onclick="setPerspectiveProjection(false);">
							<img src="../graphics/orthographic-projection.png" title="Orthographic View"/>
						</a>
					</td>
					<td class="toolbar-separator">
						&nbsp;
					</td>
					<td>
						<a class="toolbar-button" onclick="showSettings();">
							<img src="../graphics/settings.png" title="Settings"/>
						</a>
					</td>
					<td class="toolbar-separator">
						&nbsp;
					</td>
					<td>
						<a class="toolbar-button" id="help">
							<img src="../graphics/help2.png" title="Help"/>
						</a>
					</td>
				</tr>
			</table>
			<ul id="help-menu" class="jeegoocontext menu">
				<li id="help-contents"><a href="help/contents.html" target="edhelp">Help Contents</a></li>
				<li class="separator"></li>
				<li id="help-about">About</li>
			</ul>
			<script>
				function helpItemChosen(e, context) {
					if ($(this).context.id == "help-about") {
						openAboutWindow();
					}
				}
				
				$("#help").jeegoocontext("help-menu", {
					widthOverflowOffset: 0,
			        heightOverflowOffset: 3,
			        submenuLeftOffset: -4,
			        submenuTopOffset: -5,
			        event: 'click',
			        onSelect: helpItemChosen,
				});
			</script>
						
		</td>
	</tr>
	<tr>
		<td width="280px" class="bordered">
			<div id="switches-div" style="overflow: auto; height: 600px;" class="flexcroll">
				<table id="switches" width="266px">
				</table>
			</div>
		</td>
		<td class="bordered">
			<canvas id="canvas" width="800" height="600">
  				Sorry, this requires a web browser which supports HTML5 canvas.
			</canvas>
		</td>
	</tr>
	<tr>
		<td class="bordered">
			<!-- controls-help.jspf -->
			<div class="group">Controls:</div>
			<table>
			<tr><td class="ctrl"><img src="../graphics/mouse.png" /></td><td>&rarr;</td><td>rotate</td></tr>
			<tr><td class="ctrl"><span class="key">Ctrl</span> + <img src="../graphics/mouse.png" /></td><td>&rarr;</td><td>pan x / y</td></tr>
			<tr><td class="ctrl"><span class="key">Shift</span> + <img src="../graphics/mouse.png" /></td><td>&rarr;</td><td>pan z</td></tr>
			</table>
		</td>
		<td class="bordered">
		</td>
	</tr>
</table>

<!-- settings.jspf -->
<div id="settings" class="dialog-window">
	<table class="titlebar">
		<tr>
			<td>
				<div class="title">Settings</div>
			</td>
			<td class="buttons">
				<a class="titlebar-button" onclick="saveAndHideSettings();"><img src="../graphics/close.png" /></a>
			</td>
		</tr>
	</table>
	<table width="100%" height="98%">
		<tr>
			<td width="100%">
				<div class="group">Display</div>
				<table class="settings-section">
					<tr>
						<td>
							<input type="checkbox" id="setting-invert-colors" onclick="toggleBackground();" />Invert colors
						</td>
					</tr>
					<tr>
						<td>
							<input type="checkbox" id="setting-show-fps" onclick="toggleFPS();" />Show FPS
						</td>
					</tr>
					<tr>
						<td>
							<a class="button" id="speed-test" onclick="showSpeedTest();">Browser speed test</a>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<div class="group">Rendering</div>
				<table class="settings-section">
					<tr>
						<td>
							<div class="radio-group">
								<div class="radio-group-label">Calorimeter energy display mode</div>
								<div class="radio">
									<input type="radio" name="calorimeter-display" value="opacity" checked="true" onclick="setTowers(false);"/>Opacity is proportional to energy (faster)
								</div>
								<div class="radio">
									<input type="radio" name="calorimeter-display" value="towers" onclick="setTowers(true);" />Size is proportional to energy (slower but consistent with lego plots)
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<td>
							<input type="checkbox" id="setting-global-cut" onclick="toggleGlobalCut();" />Show only calorimeter hits with energies in the top 
							<input class="text-input" type="text" id="settings-global-low-cut-percentage" size="5"/> percent.
						</td>
					</tr>
					<tr>
						<td>
							<input type="checkbox" id="wireframe-sides" onclick="toggleTowersWireframe();" />Show tower sides as wireframes.
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td align="right">
				<table>
					<tr>
						<td></td>
						<td>
							<a class="button" id="settings-close" onclick="saveAndHideSettings();">Close</a>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</div>

<!--  range-selection.jspf -->
<div id="range-selector" class="dialog-window">
	<table class="titlebar">
		<tr>
			<td>
				<div class="title">Energy Range Selector</div>
			</td>
			<td class="buttons">
				<a class="titlebar-button" onclick="closeRangeSelector();"><img src="../graphics/close.png" /></a>
			</td>
		</tr>
	</table>
	<table>
		<tr>
			<td>
				<canvas id="range-selector-canvas" width="440" height="160"></canvas>
			</td>
			<td>
				<table>
					<tr>
						<td align="left" colspan="2" id="cut-title">??</td>
					</tr>
					<tr>
						<td align="right">Low cut:</td>
						<td id="low-cut"></td>
					</tr>
					<tr>
						<td align="right">High cut:</td>
						<td id="high-cut"></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</div>

<!-- event-browser.jspf -->
<div id="event-browser" class="dialog-window">
	<table class="titlebar">
		<tr>
			<td>
				<div class="title">Open Event</div>
			</td>
			<td class="buttons">
				<a class="titlebar-button" onclick="closeEventBrowser();"><img src="../graphics/close.png" /></a>
			</td>
		</tr>
	</table>
	<table width="100%" id="browser-table">
		<tr>
			<th width="50%">Files</th><th>Events</th>
		</tr>
		<tr id="panels">
			<td>
				<div style="overflow: auto;" class="flexcroll browser-panel" id="browser-files-div">
					<table id="browser-files">
					</table>
				</div>
			</td>
			<td>
				<div style="overflow: auto;" class="flexcroll browser-panel" id="browser-events-div">
					<table id="browser-events">
					</table>
				</div>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<div id="selected-event"></div>
			</td>
		</tr>
		<tr>
			<td colspan="2" align="right">
				<table>
					<tr>
						<td>
							<a class="button" id="browser-close" onclick="closeEventBrowser();">Close</a>
						</td>
						<td>
							<a class="button" id="browser-load" onclick="loadEvent();">Load</a>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</div>
<div id="load-progress-window" class="dialog-window">
	<table class="titlebar">
		<tr>
			<td>
				<div class="title" id="load-progress-window-title"></div>
			</td>
		</tr>
	</table>
	<div id="event-load-progress-frame">
		<div id="event-load-progress-bar"></div>
	</div>
	<div id="event-load-progress-text">0%</div>
</div>

<!-- speed-test.jspf -->
<div id="test-zone">
	<canvas id="test-canvas" width="320" height="200"></canvas>
</div>

<div id="speed-test-window" class="dialog-window">
	<table class="titlebar">
		<tr>
			<td>
				<div class="title">Browser Speed Test</div>
			</td>
			<td class="buttons">
				<a class="titlebar-button" onclick="closeSpeedTest();"><img src="../graphics/close.png" /></a>
			</td>
		</tr>
	</table>
	<table width="90%" style="padding: 8px">
		<tr>
			<td colspan="2">
				<div id="speed-progress">
					<div id="speed-progress-bar"></div>
					<div id="speed-progress-number"></div>
				</div>
			</td>
		</tr>
		<tr>
			<td id="vtl" width="50%">
			</td>
			<td id="vtv" width="50%">
			</td>
		</tr>
		<tr>
			<td id="frl" width="50%">
			</td>
			<td id="frv" width="50%">
			</td>
		</tr>
		<tr>
			<td align="right" colspan="2">
				<table>
					<tr>
						<td></td>
						<td>
							<a class="button" id="start-test" onclick="startTest();">Start test</a>
						</td>
						<td>
							<a class="button" id="cancel-test" onclick="closeSpeedTest();">Cancel</a>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</div>

<!-- about.jspf -->
<div id="about" class="dialog-window">
	<table class="titlebar">
		<tr>
			<td>
				<div class="title">About Event Display</div>
			</td>
			<td class="buttons">
				<a class="titlebar-button" onclick="closeAboutWindow();"><img src="../graphics/close.png" /></a>
			</td>
		</tr>
	</table>
	<table width="100%" height="98%">
		<tr>
			<td width="100%">
				<p>
					This software is part of the <a target="edabout" href="http://www.i2u2.org">I2U2</a> project, 
					which is published under the <a target="edabout" href="http://fermitools.fnal.gov/about/terms.html">Fermitools License</a>.
				</p>
				<p>
					The <a target="edabout" href="http://deanm.github.com/pre3d/">3D library</a> was initially developed by Dean McNamee
					and is published under a <a target="edabout" href="http://www.opensource.org/licenses/bsd-license.php">BSD license</a>.
				</p>
			</td>
		</tr>
		<tr>
			<td align="right">
				<table>
					<tr>
						<td></td>
						<td>
							<a class="button" target="edabout" id="settings-close" onclick="closeAboutWindow();">Close</a>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</div>

<!-- detector-help.jsfp -->
<div id="help-detsystem-0" class="dialog-window">
	<table class="titlebar">
		<tr>
			<td>
				<div class="title">Detector Model Help</div>
			</td>
			<td class="buttons">
				<a class="titlebar-button" onclick="closePopup('help-detsystem-0');"><img src="../graphics/close.png" /></a>
			</td>
		</tr>
	</table>
	<table>
		<tr>
			<td class="content">
				<dl>
					<dt>Tracker</dt>
					<dd>Innermost part of CMS; samples trajectories of charged particles</dd>
					
					<dt>ECAL (Electromagnetic Calorimeter)</dt>
					<dd>
						<dl>
							<dt>ECAL Barrel</dt>
							<dd>Central electromagnetic calorimeter; measures energy of electrons and photons</dd>
							
							<dt>ECAL Endcap</dt>
							<dd>Electromagnetic calorimeters at either end of CMS for measurements close to the beam axis</dd>
							
							<dt>ECAL Preshower</dt>
							<dd>Provides an initial (before the EM shower) measurement helping to discriminate between photons and (neutral) pions</dd>
						</dl>
					</dd>
					
					<dt>HCAL (Hadron Calorimeter)</dt>
					<dd>
						<dl>
							<dt>HCAL Barrel</dt>
							<dd>Central hadronic calorimeter; measures energy of hadrons</dd>
							
							<dt>HCAL Endcap</dt>
							<dd>Hadronic calorimeters at either end of CMS for measurements close to the beam axis</dd>
							
							<dt>HCAL Outer</dt>
							<dd>Final HCAL layer just outside the solenoid magnet</dd>
							
							<dt>HCAL Forward</dt>
							<dd>Hadronic calorimeters farther down and very close to the beam axis</dd>
						</dl>
					</dd>
					
					<dt>Drift Tubes (DT)</dt>
					<dd>Main large central muon chambers outside the solenoid and HCAL Outer using ionization of gas to record muon hits</dd>
					
					<dt>Cathode Strip Chambers (CSC)</dt>
					<dd>Forward muon detectors</dd>
					
					<dt>Resistive Place Chambers (RPC)</dt>
					<dd>Solid state muon detectors</dd>
				</dl>
			</td>
		</tr>
		<tr>
			<td align="right">
				<table>
					<tr>
						<td></td>
						<td>
							<a class="button" onclick="closePopup('help-detsystem-0');">Close</a>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</div>

<div id="help-detsystem-1" class="dialog-window">
	<table class="titlebar">
		<tr>
			<td>
				<div class="title">Tracking Help</div>
			</td>
			<td class="buttons">
				<a class="titlebar-button" onclick="closePopup('help-detsystem-1');"><img src="../graphics/close.png" /></a>
			</td>
		</tr>
	</table>
	<table>
		<tr>
			<td class="content">
				<dl>
					<dt>Tracks (reco.)</dt>
					<dd>All reconstructed particle tracks in the tracker</dd>
					
					<dt>Electron Tracks (GSF)</dt>
					<dd>Electron tracks in the tracker</dd>
					
					<dt>Clusters (Si Pixels)</dt>
					<dd>Recorded events in the innermost part of the tracker</dd>
					
					<dt>Clusters (Si Strips)</dt>
					<dd>Recorded events in the tracker</dd>
					
					<dt>Rec. Hits (Tracking)</dt>
					<dd>All particle hits in the tracker</dd>
				</dl>
			</td>
		</tr>
		<tr>
			<td align="right">
				<table>
					<tr>
						<td></td>
						<td>
							<a class="button" onclick="closePopup('help-detsystem-1');">Close</a>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</div>

<div id="help-detsystem-2" class="dialog-window">
	<table class="titlebar">
		<tr>
			<td>
				<div class="title">ECAL Help</div>
			</td>
			<td class="buttons">
				<a class="titlebar-button" onclick="closePopup('help-detsystem-2');"><img src="../graphics/close.png" /></a>
			</td>
		</tr>
	</table>
	<table>
		<tr>
			<td class="content">
				<dl>
					<dt>Barrel Rec. Hits</dt>
					<dd>Energy in a single ECAL crystal</dd>
					
					<dt>Endcap Rec. Hits</dt>
					<dd>Hits in ECAL Endcap</dd>
					
					<dt>Preshower Rec. Hits</dt>
					<dd>Hits in ECAL Preshower</dd>
				</dl>
			</td>
		</tr>
		<tr>
			<td align="right">
				<table>
					<tr>
						<td></td>
						<td>
							<a class="button" onclick="closePopup('help-detsystem-2');">Close</a>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</div>

<div id="help-detsystem-3" class="dialog-window">
	<table class="titlebar">
		<tr>
			<td>
				<div class="title">HCAL Help</div>
			</td>
			<td class="buttons">
				<a class="titlebar-button" onclick="closePopup('help-detsystem-3');"><img src="../graphics/close.png" /></a>
			</td>
		</tr>
	</table>
	<table>
		<tr>
			<td class="content">
				<dl>
					<dt>Barrel Rec. Hits</dt>
					<dd>Energy in a single HCAL tile</dd>
					
					<dt>Endcap Rec. Hits</dt>
					<dd>Hits in HCAL Endcap</dd>
					
					<dt>Forward Rec. Hits</dt>
					<dd>Hits in HCAL Forward</dd>
					
					<dt>Outer Rec. Hits</dt>
					<dd>Hits in HCAL Outer</dd>
				</dl>
			</td>
		</tr>
		<tr>
			<td align="right">
				<table>
					<tr>
						<td></td>
						<td>
							<a class="button" onclick="closePopup('help-detsystem-3');">Close</a>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</div>

<div id="help-detsystem-4" class="dialog-window">
	<table class="titlebar">
		<tr>
			<td>
				<div class="title">Muon Help</div>
			</td>
			<td class="buttons">
				<a class="titlebar-button" onclick="closePopup('help-detsystem-4');"><img src="../graphics/close.png" /></a>
			</td>
		</tr>
	</table>
	<table>
		<tr>
			<td class="content">
				<dl>
					<dt>DT Rec. Hits</dt>
					<dd>Muon hits in Drift Tubes (barrel)</dd>
					 
					<dt>DT Rec. Segments</dt>
					<dd>Muon track segments in Drift Tubes (barrel)</dd>
					
					<dt>CSC Segments</dt>
					<dd>Muon track segments in Cathode Strip Chambers (forward)</dd>
					
					<dt>RPC Rec. Hits</dt>
					<dd>Muon hits in Resistive Plate Chambers (barrel)</dd>
					
					<dt>CSC Rec. Hits</dt>
					<dd>Muon hits in Cathode Strip Chambers (forward)</dd>
				</dl>
			</td>
		</tr>
		<tr>
			<td align="right">
				<table>
					<tr>
						<td></td>
						<td>
							<a class="button" onclick="closePopup('help-detsystem-4');">Close</a>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</div>

<div id="help-detsystem-5" class="dialog-window">
	<table class="titlebar">
		<tr>
			<td>
				<div class="title">Particle Flow Help</div>
			</td>
			<td class="buttons">
				<a class="titlebar-button" onclick="closePopup('help-detsystem-5');"><img src="../graphics/close.png" /></a>
			</td>
		</tr>
	</table>
	<table>
		<tr>
			<td class="content">
				<dl>
				</dl>
			</td>
		</tr>
		<tr>
			<td align="right">
				<table>
					<tr>
						<td></td>
						<td>
							<a class="button" onclick="closePopup('help-detsystem-5');">Close</a>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</div>

<div id="help-detsystem-6" class="dialog-window">
	<table class="titlebar">
		<tr>
			<td>
				<div class="title">Physics Objects Help</div>
			</td>
			<td class="buttons">
				<a class="titlebar-button" onclick="closePopup('help-detsystem-6');"><img src="../graphics/close.png" /></a>
			</td>
		</tr>
	</table>
	<table>
		<tr>
			<td class="content">
				<dl>
					<dt>Tracker Muons (Reco)</dt>
					<dd>Reconstructed muon tracks in central Tracker</dd>
					
					<dt>Stand-alone Muons (Reco)</dt>
					<dd>Reconstructed muon track segments in barrel</dd>
					
					<dt>Global Muons (Reco)</dt>
					<dd>Reconstructed complete muon tracks</dd>
					
					<dt>Calorimeter energy towers</dt>
					<dd>Histogram "towers" to indicate energy deposits in calorimeters summed over the trajectories</dd>
					
					<dt>Jets</dt>
					<dd>Collimated groups of particles which come from strong force energy conversion to matter</dd> 
				</dl>
			</td>
		</tr>
		<tr>
			<td align="right">
				<table>
					<tr>
						<td></td>
						<td>
							<a class="button" onclick="closePopup('help-detsystem-6');">Close</a>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</div>
	</body>
</html>
