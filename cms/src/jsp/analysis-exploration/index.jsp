<!--Rev.8278-->
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <title>Data Selection - Exploration Studies</title>
  <link rel="stylesheet" type="text/css" href="../css/style2.css"/>
  <link rel="stylesheet" type="text/css" href="../css/data.css"/>
  <link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
  <link rel="stylesheet" type="text/css" href="../css/analysis.css"/>
  <link rel="stylesheet" type="text/css" href="../css/dc-3.0.3.min.css"/>
  <link rel="Stylesheet" type="text/css" href="../css/exploration.css" />
  <link rel="Stylesheet" type="text/css" href="../include/jeegoocontext/skins/cm_blue/style.css" />

  <script type="text/javascript" src="../include/elab.js"></script>

	<!-- Crossfilter, D3.js, and DC.js for creating correlated charts -->
	<!-- These are inter-dependent and must be upgraded as a set (including DC.js's CSS file,
			 above).  Import them in this order. -->
  <script type="text/javascript" src="../include/crossfilter-1.5.4.js"></script>
  <script type="text/javascript" src="../include/d3-5.16.0.min.js"></script>
	<!--<script type="text/javascript" src="../include/d3-6.7.0.min.js"></script>-->
  <!--<script type="text/javascript" src="../include/d3-7.8.5.min.js"></script>-->
  <script type="text/javascript" src="../include/dc-4.0.0.min.js"></script>

	<!-- HTML2Canvas for saving graphs to file -->
  <script type="text/javascript" src="../include/html2canvas-1.0.0-alpha.12.js"></script>

	<!-- Chart.js for creating the histogram plots-->
  <script type="text/javascript" src="../include/chart-4.4.0.umd.js"></script>
  <script type="text/javascript" src="../include/chartjs-plugin-zoom-2.0.1.min.js"></script>
	<!-- Chart.js Zoom plugin requires hammer.js for touchscreen panning/zooming.
	     We don't currently use that, but the option exists:-->
  <!--<script type="text/javascript" src="../include/hammer-2.0.8.min.js"></script>-->

</head>

<body class="data">
<!-- entire page container -->
<div id="container">
  <div id="top">
    <div id="header">
      <%@ include file="../include/header.jsp" %>
      <%@ include file="../include/nav-rollover.jspf" %>
    </div>
  </div>
  <script type="text/javascript" src="../include/jeegoocontext/jquery.jeegoocontext.min.js"></script>
  <div id="content">
    <a class="help-icon" href="#" onclick="openPopup(event, 'help')">Help <img src="../graphics/help.png" /></a>
    <h1>Dataset Selection - Exploration Studies</h1>
    <p>
      Explore data from the CMS experiment at the Large Hadron Collider (LHC). Many particles can be produced in the proton-proton
      collisions recorded by CMS, such as J/&psi; mesons, &Upsilon; (upsilon) mesons, and W and Z bosons. These
      particles decay very promptly and cannot be detected directly.  Some of the more familiar particles into which they can decay, 
      such as electrons, muons, and photons, can be detected and measured in CMS.  From these particles, one can study the properties 
      of the parent particles.
    </p>
    <p>
      Choose one of the following datasets:
    </p>
    <table border="0" id="main">
      <tr>
        <td>
          <div id="simple-form">
            <select id="dataset" name="dataset">
              <option value="none" id="nothing-selected">Choose dataset...</option>
            </select>
          </div>
        </td>
      </tr>
    </table>

    <div id="parameters">
      <p>Choose one or more parameters:</p>
      <table id="parameter-table">
        <tr></tr>
      </table>
    </div>

    <ul class="tab">
      <li><a href="#" class="tablinks plot active">Histograms</a></li>
      <li><a href="#" class="tablinks chart">Correlated charts</a></li>
    </ul>

    <div id="plot-container" class="tabcontent">
    </div>

    <div id="chart-container" class="tabcontent">
    </div>

    <div id="plot-template" style="display: none">

		  <div class="cursor" style="position: absolute; z-index: 10; display: none">
				<span class="cursorValue"></span>
				<span class="cursorUnit"></span>
      </div>


				<table class="toolbox-set">
        <tr>
          <td class="toolbox-row">
            <table class="toolbox">
              <tr>
                <td class="group-title">
                  Axes
                </td>
                <td class="toolbox-group">
										<!--
												 Max Y: <input type="text" class="maxy" size="6" /><input type="button" class="apply-maxy" value="Set" disabled="true" />
										-->
										<input type="checkbox" class="logx" />Log X
										<input type="checkbox" class="logy" />Log Y
										<!--<input type="button" class="reset-selection" disabled autocomplete="off" value="Reset X Selection" />-->
										<input type="button" class="reset-selection" autocomplete="off" value="Reset Zoom" />
                </td>
                <td class="group-title">
                  Plot
                </td>
                <td class="toolbox-group">
                  Bin Width: <input type="text" class="binwidth" value="1.0" size="6" /><input type="button" class="apply-binwidth" value="Set"/>
                </td>
                <td>
                  <input type="button" class="save" value="Print plot"/>
                </td>
              </tr>
                <tr>
                <td class="group-title">
                  Selectors
                </td>
                <td class="toolbox-group selector selector-charge">
                  <input type="checkbox" id="charge" class="selector selector-charge"/><span class="selector-charge">Select events with muons/electrons of opposite-sign charge</span>
                </td>
                <td class="toolbox-group selector selector-type">
                  <input type="checkbox" id="type" class="selector selector-type"/><span class="selector-type"></span>
                </td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
      <!--<div class="cursor" style="position: absolute; z-index: 10; display: none">-->
			<div class="cursor" style="position: absolute; z-index: 100; background-color: blue; height: 40px; width: 40px; display: none;">
							<span class="cursorValue"></span> <span class="cursorUnit"></span>
      </div>
      <div class="frame" style="position: relative;">
					<div class="plottitle"></div>

					<!-- Chart.js canvas: -->
					<div class="placeholder">
							<div class="legend-container"></div>
							<canvas id="myChart"></canvas>
					</div>

					<div class="selection" style="position: absolute; top: 40px; z-index: 10;"></div>
					<div class="xlabel"></div>
					<div class="ylabel"></div>
      </div>
    </div>

<div id="help" class="help">
  <table>
    <tr>
      <td class="title">Dataset Selection Help<a href="#" onclick="closeHelp('help');"><img src="../graphics/close.png" /></a></td>
    </tr>
    <tr>
      <td class="content">
        <p>Need help with dataset selection? Try these links:</p>
        <ul>
<li>
            <e:popup href="http://screencast.com/t/m9QDaF4p" target="tryit" width="800" height="800">Screencast Demo</e:popup>
 - how to select datasets.
          </li>
          <li><a href="javascript:showRefLink('../library/FAQ.jsp',700,700)">FAQs</a>
          </li>
        </ul>
      </td>
    </tr>
    <tr>
      <td align="right"><button name="close" onclick="closePopup('help');">Close</button></td>
    </tr>
  </table>
</div>

      </div>
      <!-- end content -->

      <div id="footer">
      </div>
</div>
<!-- end container -->

<script type="text/javascript">

  const onReady = (callback) =>{
			if (document.readyState!='loading') callback();
			else if (document.addEventListener) document.addEventListener('DOMContentLoaded', callback);
			else document.attachEvent('onreadystatechange', function() {
					if (document.readyState=='complete') callback();
			});
	};

  /* After the DOM has fully loaded */
  onReady(() => { 

			let plot_container = document.getElementById('plot-container');
			let chart_container = document.getElementById('chart-container');
			let tab_links = document.querySelectorAll('.tablinks');
			let params = document.getElementById('parameters');

			/* Attach listeners to the Histograms/Correlated charts tabs */
			tab_links.forEach(function(item) {
					item.addEventListener('click', function() {

							tab_links.forEach(function(tab_link) {
									tab_link.classList.remove('active');
							})
							this.classList.add('active');

							if (this.classList.contains('plot')) {
									chart_container.style.display = 'none';
									plot_container.style.display = 'block';
							}

							if (this.classList.contains('chart')) {
									plot_container.style.display = 'none';
									chart_container.style.display = 'block';
							}
					});
			});

			params.style.display = 'none';

			/* Show plot container div by default */
			plot_container.style.display = 'block';

			let csv_files = [
					{
							id:"Jpismumu",
							name: "J/&psi;&rarr;&mu;&mu;",
							descr:"dimuon events with an invariant mass between 2-5 GeV",
							file:"../data/dimuon-Jpsi.csv",
							type:"two_lepton",
							selector: {name: "Type", descr: "Select events with two global muons", value: "GG"}
					},
					{
							id:"Jpsiee",
							name: "J/&psi;&rarr;ee",
							descr:"dielectron events with an invariant mass between 2-5 GeV",
							file:"../data/dielectron-Jpsi.csv",
							type:"two_lepton"
					},
					{
							id:"Yee",
							name: "Y&rarr;ee",
							descr:"dielectron events with an invariant mass between 8-12 GeV",
							file:"../data/dielectron-Upsilon.csv",
							type:"two_lepton"
					},
					{
							id:"Zee",
							name: "Z&rarr;ee",
							descr:"dielectron events around the Z boson mass",
							file:"../data/Zee.csv",
							type:"two_lepton"
					},
					{
							id:"Zmumu",
							name: "Z&rarr;&mu;&mu;",
							descr:"dimuon events around the Z boson mass",
							file:"../data/Zmumu.csv",
							type:"two_lepton"
					},
					{
							id:"Wenu",
							name: "W&rarr;e&nu;",
							descr:"W bosons decaying to an electron and a neutrino",
							file:"../data/Wenu.csv",
							type:"lepton_neutrino"
					},
					{
							id:"Wmuu",
							name: "W&rarr;&mu;&nu;",
							descr:"W bosons decaying to a muon and a neutrino",
							file:"../data/Wmunu.csv",
							type:"lepton_neutrino"
					},
					{
							id:"dimuon",
							name: "Dimuons",
							descr:"dimuon events with invariant mass between 2-110 GeV",
							file:"../data/dimuon.csv",
							type:"two_lepton",
							selector: {name: "Type", descr: "Select events with two global muons", value: "GG"}
					},
					{
							id:"dielectron",
							name: "Dielectrons",
							descr: "dielectron events with invariant mass between 2-110 GeV",
							file: "../data/dielectron.csv",
							type:"two_lepton"
					}
			];

			/* We know the names of the parameters that we have produced in the csv files.
		   * We also have only two event types in the csv: lepton_neutrino and two_lepton.
		   * We therefore provide some information on the parameters.
			 */
			let event_types = {
					"two_lepton":
					[
							{name:"E1", unit:"GeV", description:"The total energy [GeV] of the first lepton (electron or muon)"},
							{name:"pt1", unit:"GeV", description:"The transverse momentum [GeV] of the first lepton (electron or muon)"},
							{name:"eta1", unit:null, description:"The pseudorapidity of the first lepton (electron or muon)"},
							{name:"phi1", unit:"radians", description:"The &phi; angle [radians] of the first lepton (electron or muon) direction"},
							{name:"Q1", unit:null, description:"The charge of the first lepton (electron or muon)"},
							{name:"E2", unit:"GeV", description:"The total energy [GeV] of the second lepton (electron or muon)"},
							{name:"pt2", unit:"GeV", description:"The transverse momentum [GeV] of the second lepton (electron or muon)"},
							{name:"eta2", unit:null, description:"The pseudorapidity of the second lepton (electron or muon)"},
							{name:"phi2", unit:"radians", description:"The &phi; angle [radians] of the second lepton (electron or muon)"},
							{name:"Q2", unit:null, description:"The charge of the second lepton (electron or muon)"},
							{name:"M", unit:"GeV", description:"The invariant mass [GeV] of the two leptons (electrons or muons)"}
					],
					"lepton_neutrino":
					[
							{name:"E", unit:"GeV", description:"The total energy [GeV] of the lepton (electron or muon)"},
							{name:"MET", unit:"GeV", description:"The missing transverse energy [GeV] due to the neutrino"},
							{name:"Q", unit:null, description:"The charge of the lepton (electron or muon)"},
							{name:"phiMET", unit:"radians", description:"The &phi; angle [radians] of the missing transverse energy"},
							{name:"eta", unit:null, description:"The pseudorapidity of the lepton (electron or muon)"},
							{name:"phi", unit:"radians", description:"The &phi; angle [radians] of the lepton (electron or muon) direction"},
							{name:"pt", unit:"GeV", description:"The transverse momentum [GeV] of the lepton (electron or muon)"},
							{name:"Mt", unit:"GeV", description:"The transverse mass [GeV]"}
					]
			};

			for ( let i = 0; i < csv_files.length; i++ ) {
					let id = csv_files[i].id;
					let name = csv_files[i].name;
					let descr = csv_files[i].descr;

					let dataset_selector = document.getElementById('dataset');
					let dataset_option = document.createElement('option');
					dataset_option.setAttribute('value', id);
					dataset_option.innerHTML = descr;
					dataset_selector.appendChild(dataset_option);
			}
			
			let original_data;
			let current_data;
			let dataset_name;
			let dataset_id;
			let dataset_type;
			let dataset_descr;
			let cfdata, all;

			function getDataset(id) {
					for ( let i = 0; i < csv_files.length; i++ ) {
							if ( csv_files[i].id === id ) {
									return csv_files[i];
							}
					}
					return null;
			}

			function buildHistogram(data, bw) {
					let minx = Math.floor(d3.min(data)),
							maxx = Math.ceil(d3.max(data)),
							nbins = Math.floor((maxx-minx) / bw);

					//console.log('minx, maxx', minx, maxx);

					/* D3.js 3.5.5 */
					//let histogram = d3.layout.histogram();	 
					//histogram.bins(nbins);

					/* D3.js 4.0 */
					//let histogram = d3.histogram();
					//let histogram = d3.bin();

					/* D3.js 5.4.0 */
					let histogram = d3.histogram();
					histogram.thresholds(nbins);
					data = histogram(data);

					/* D3.js 6 */
					//let histogram = d3.bin();
					//histogram.thresholds(nbins);
					//data = histogram(data);

					let output = [];
					for ( let i = 0; i < data.length; i++ ) {
							/* D3.js 3.5.5 */
							//output.push([data[i].x, data[i].y]);
							//output.push([data[i].x + data[i].dx, data[i].y]);

							/* D3.js 4 */
							output.push([data[i].x0, data[i].length]);
							output.push([data[i].x1, data[i].length]);
					}
					return output;
			}

			ln = function(v) { return v > 0 ? Math.log(v) : 0; }
			exp = function(v) { return Math.exp(v); }
			log10 = function(v) { return v > 0 ? Math.log(v)/Math.log(10): 0; }
			pow10 = function(v) { return Math.pow(v,10); }


			function parameterSelected(e) {

					let parameter_table = document.getElementById('parameter-table');
					let parameter = this.textContent;
					let title = this.getAttribute('title');
					let active = this.classList.contains('active');

					let parId = 'plot' + parameter;

					if ( active ) {
							this.classList.remove('active');
							document.getElementById(parId).remove();
							document.getElementById(parId+'-chart').remove();

					} else {
							this.classList.add('active');

							let dimension = cfdata.dimension(function(d) {return +d[parameter];});

							let xmin = dimension.bottom(1)[0][parameter];
							let xmax = dimension.top(1)[0][parameter];
							
							xmin = Math.floor(xmin);
							xmax = Math.ceil(xmax);

							let binw = (xmax - xmin) / 100;
							if ( binw > 1.0 ) {
									binw = Math.floor(binw);
							} else {
									binw = 1.0;
							}

							let group = dimension.group(
									function(d) {return Math.floor(d/binw)*binw;}
							);

							let histogram = buildHistogram(
									original_data.map(
											function(d) {return +d[parameter];}),
									binw);

							let nevents = original_data.length;

							/* Chart.js */
							/* Grab the Plot Container <div>, which contains all plots.
							 * There is only one, and it is not part of the template. */
							let plot_container = document.getElementById('plot-container');

							/* Create the parId <div>, which will contain this one plot. */
							let parId_plot = document.createElement('div');
							parId_plot.setAttribute('class', 'plot');
							parId_plot.setAttribute('id', parId);

							/* Add the parId <div> to the Plot Container <div> */
							plot_container.appendChild(parId_plot);

							/* Grab a copy of the plot template. */
							let plot_template = document.getElementById('plot-template')
																					.cloneNode(true);

							/* Change the id of the Chart.js canvas that's part
							 * of the cloned template. */
							plot_template.querySelector('#myChart')
													 .setAttribute('id', 'cjs-'+parId);

							/* Set the id of the Chart.js .legend-container <div> */
							let legend_container = plot_template.querySelector('.legend-container')
							legend_container.setAttribute('id', parId+'-legend');

							/* Copy the cloned template's contents into the parId <div> */
							parId_plot.innerHTML = plot_template.innerHTML;

							/* Set the value of the bin width input */
							let plot_binwidth_input = parId_plot.querySelector('input.binwidth');
							plot_binwidth_input.setAttribute('value', binw);

							/* Prepare a similar setup for the correlated charts */
							let chart_container = document.getElementById('chart-container');

							/* Create the parId-chart <div>, which will contain
							 * this one chart */
							let parId_chart = document.createElement('div');
							parId_chart.setAttribute('class', 'chart');
							parId_chart.setAttribute('id', parId+'-chart');

							/* Add the parId-chart <div> to the Chart Container <div> */
							chart_container.appendChild(parId_chart);

							/* Back to plots. */
							/* Hide all `.selector` elements within the parId <div> */
							parId_plot.querySelectorAll('.selector')
												.forEach(function(e) {
														e.style.display = 'none';
												});

							let dataset = getDataset(dataset_id);
							let selector;

							/* A dataset with selectable 'type' will have a 'selector'
							 * key in the dataset. */
							if ( dataset !== null && 'selector' in dataset ) {
									//console.log(dataset.selector);
									selector = dataset.selector;

									/* Type Selector elements were previously hidden.
									 * Show them. */
									parId_plot.querySelectorAll('.selector-type')
														.forEach(function(e) {
																e.style.display = '';
														});

									/* There should be only one of these */
									parId_plot.querySelectorAll('span.selector-type')[0]
														.innerHTML = selector.descr;
							}

							/* A dataset with selectable 'charge' will be of type
							 * 'two_lepton'. */
							if ( dataset_type === 'two_lepton' ) {
									parId_plot.querySelectorAll('.selector-charge').forEach(function(e) {
											e.style.display = '';
									});
							}

							let data = [{data:histogram, label:parameter}];

							/* The Chart.js context */
							const ctx = document.getElementById('cjs-'+parId);

							/* Shadow effect plugin */
							/* Flot.js places a slight drop shadow under the chart line,
               * which looks quite nice.  It is very difficult to figure
               * out how to get Chart.js to do the same.  
               * 
							 * The object below is a Chart.js plugin that exposes the
							 * underlying `<canvas>` object on which  the chart is
							 * drawn, allowing us to use the Canvas API to add a shadow
							 * to drawn lines.  Since we want a shadow on only the graph,
							 * not all other lines in the chart, we use the
							 * `beforeDatasetsDraw` and `afterDatasetsDraw` hooks
							 * provided by Chart.js to limit the shadow effect to the
							 * drawing of the plot line itself.
							 */
							const dropShadowPlugin = {
									id: 'dropShadow',

									/* Immediately before Chart.js begins to draw the
									 * data itself, we turn on shadows on the Canvas: */
									beforeDatasetsDraw: (chart, args, options) => {

											/* The input `chart` will be the Chart.js object.
										   * Its context object `ctx` is the underlying Canvas
										   * object.
										   * The syntax below is 'object destructuring', and
										   * it's the same as `const ctx = chart.ctx`.
											 */
											const {ctx} = chart;

											/* The Canvas API provides these 4 shadow
											 * attributes */
											ctx.shadowColor = 'rgba(54, 54, 54, 0.6)';
											ctx.shadowBlur = 1.5;
											ctx.shadowOffsetX = 0;
											ctx.shadowOffsetY = 2;
									},

									/* As soon as Chart.js finishes drawing the data, we
									 * return the shadow attributes to their default "off"
									 * values: */
									afterDatasetsDraw: (chart, args, options) => {

											/* Get the context of the input chart, a Chart.js object.
											 * Same as `const ctx = chart.ctx;` */
											const {ctx} = chart;

											/* Put everything back to "No shadow" settings. */
											ctx.shadowColor = 'transparent';
											ctx.shadowBlur = 0;
											ctx.shadowOffsetX = 0;
											ctx.shadowOffsetY = 0;
									}
							}; /* End of dropShadowPlugin */


							/* Chart border plugin */
							/* You read that right.  In Chart.js, you need a separate
							 * plugin to *put a border around the chart*.
							 * Fortunately they give you this one
							 * https://www.chartjs.org/docs/latest/samples/plugins/chart-area-border.html
							 */
							const chartAreaBorderPlugin = {
									id: 'chartAreaBorder',
									beforeDraw(chart, args, options) {
											const {ctx, chartArea: {left, top, width, height}} = chart;
											ctx.save();
											ctx.strokeStyle = options.borderColor;
											ctx.lineWidth = options.borderWidth;
											ctx.setLineDash(options.borderDash || []);
											ctx.lineDashOffset = options.borderDashOffset;
											ctx.strokeRect(left, top, width, height);
											ctx.restore();
									}
							}; /* End of chartAreaBorderPlugin */


							/* HTML legend plugin */
							/* The default Chart.js legend is not easily changed.
							 * Our only real option is to define a completely new legend
               * in HTML. */
							/* https://www.chartjs.org/docs/latest/samples/legend/html.html */
							const getOrCreateLegendList = (chart, id) => {
									const legendContainer = document.getElementById(id);
									let listContainer = legendContainer.querySelector('ul');

									if (!listContainer) {
											listContainer = document.createElement('ul');
											listContainer.style.display = 'flex';
											listContainer.style.flexDirection = 'row';
											listContainer.style.margin = 0;
											listContainer.style.padding = 0;

											legendContainer.appendChild(listContainer);
									}

									return listContainer;
							};

							const htmlLegendPlugin = {
									id: 'htmlLegend',
									afterUpdate(chart, args, options) {
											const ul = getOrCreateLegendList(chart, options.containerID);

											/* Remove old legend items */
											while (ul.firstChild) {
													ul.firstChild.remove();
											}

											/* Reuse the built-in legendItems generator */
											const items = chart.options.plugins.legend.labels.generateLabels(chart);

											items.forEach(item => {
													const li = document.createElement('li');
													li.style.alignItems = 'center';
													li.style.cursor = 'pointer';
													li.style.display = 'flex';
													li.style.flexDirection = 'row';

													//li.style.marginLeft = '700px';
													/* Moves the whole graph down */
													//li.style.marginTop = '100px';

													/* Placement */
													li.style.position = 'relative';
													li.style.top = '50px';
													li.style.left = '660px';
													
													li.onclick = () => {
															const {type} = chart.config;
															chart.setDatasetVisibility(item.datasetIndex, !chart.isDatasetVisible(item.datasetIndex));
															chart.update();
													};

													/* Color box */
													const boxSpan = document.createElement('span');
													/* Change color of box: */
													//boxSpan.style.background = item.fillStyle;
													boxSpan.style.background = chart.options.borderColor;

													/* This does nothing: */
													boxSpan.style.borderColor = item.strokeStyle;
													//boxSpan.style.borderColor = 'rgba(54, 54, 54, 0.6)';

													/* This does nothing: */
													boxSpan.style.borderWidth = item.lineWidth + 'px';
													//boxSpan.style.borderWidth = '50 px';

													boxSpan.style.display = 'inline-block';
													boxSpan.style.flexShrink = 0;
													//boxSpan.style.height = '20px';
													boxSpan.style.height = '15px';
													boxSpan.style.marginRight = '10px';
													//boxSpan.style.width = '20px';
													boxSpan.style.width = '15px';

													/* Text */
													const textContainer = document.createElement('p');
													textContainer.style.color = item.fontColor;
													textContainer.style.margin = 0;
													textContainer.style.padding = 0;
													textContainer.style.textDecoration = item.hidden ? 'line-through' : '';

													const text = document.createTextNode(item.text);
													textContainer.appendChild(text);

													li.appendChild(boxSpan);
													li.appendChild(textContainer);
													ul.appendChild(li);
											});
									}
							}; /* End of htmlLegend plugin */


							/* Plugin options for the Chart.js constructor,
							 * defined below. */
							let plugin_options = {
									zoom: {
											zoom: {
													mode: 'x',
													wheel: {enabled: false},
													pinch: {enabled: false},
													drag: {enabled: true},
											}
									},
									chartAreaBorder: {
											borderColor: 'black',
											borderWidth: 2,
									},
									legend: {
											display: false,
									},
									htmlLegend: {
											//containerID: 'legend-container',
											containerID: parId+'-legend',
									},
							};

							/* Chart.js data object for the Chart.js constructor,
							 * defined below. */
							let chart_data = {
									datasets: [{
											label: parameter,
											data: histogram,
											/* 'borderWidth' is actually the line width */
											borderWidth: 1.2,
											/* For the crosshair to work, must disable other
											 * tooltip hover effects: */
											pointHoverRadius: 0,
											pointHitRadius: 0,
											pointRadius: 0
									}]
							};

							/* Chart.js chart options object for the Chart.js
							 *  constructor, defined below. */
							let chart_options = {
									showLine: true,
									pointStyle: false,

									/* Again, "border" here refers to the graph line itself. */
									/* USC Gold */
									borderColor: 'rgba(255,204,0,1)', 

									borderWidth: 1,
									fill: '+1',
									scales: {
											y: {beginAtZero: true}
									},
									plugins: plugin_options,
							};

							/* Create the Chart.js chart */
							let cjs_plot = new Chart(ctx, {
									/*
									 * 'line' plots in Chart.js don't accept the (x,y)
									 * coordinate data format we used with Flot.  Rather
									 * than change everything, a 'scatter' plot with the
									 * points hidden and connected by lines works the same.
									 */
									type: 'scatter',
									data: chart_data,
									options: chart_options,
									plugins: [dropShadowPlugin, chartAreaBorderPlugin, htmlLegendPlugin],
							});

							/* Implementing the crosshair effect previously done
							 * using the Flot.js 'crosshair' plugin. */
							/* https://www.youtube.com/watch?v=za2cQFObvWQ */
							cjs_plot.canvas.addEventListener('mousemove', (e) => {
									crosshair(cjs_plot, e);
							})

							/* Make sure crosshair disappears outside the chart */
							cjs_plot.canvas.addEventListener('mouseleave', (e) => {
									cjs_plot.update('none')

									let cursor = parId_plot.querySelector('.cursor');
									cursor.style.display = 'none';
							})

							function crosshair(chart, mousemove) {

									/* Setting `update` to 'none' means the refresh is
							     * invisible so that we don't see previous crosshair
								   * lines as the mouse moves. */
									chart.update('none');

									//console.log(mousemove);
									const x = mousemove.offsetX;
									const y = mousemove.offsetY;

									/* object destructuring */
									const { ctx, chartArea: {top, bottom, left, right, width, height} } = chart;
									ctx.save();

									//console.log("ctx:" + ctx);
									//console.log("cjs_plot:" + cjs_plot);

									/* Draw items */
									/* rgba(102,102,102,0.5) is light grey */
									/* rgba(255,0,0,1) is solid red */
									ctx.strokeStyle = 'rgba(255,0,0,1)';

									ctx.lineWidth = 1;

									/* For calculating (x,y) coordinates on the chart: */
									let xMin = chart.scales['x'].min;
									let xMax = chart.scales['x'].max;
									let yMin = chart.scales['y'].min;
									let yMax = chart.scales['y'].max;

									let x_coord = 0;
									let y_coord = 0;

									/* Added cursor for coordinate labels */
									let cursor = parId_plot.querySelector('.cursor');
									cursor.style.display = 'block';

									let label = parId_plot.querySelector('.cursorValue');

									let placeholder = parId_plot.querySelector('.placeholder');
									placeholder.addEventListener('mouseout', function() {
											cursor.style.display = 'none';
									});

									/* Only draw crosshairs if mouse is inside the chart area.
								   * Remember 'y' is measured top-down. */
									if(x >= left && x <= right && y >= top && y <= bottom) {

											//console.log('x = ' + x);
											//console.log('y = ' + y);

											/* Draw horizontal line */
											ctx.beginPath();
											ctx.moveTo(left, y);
											ctx.lineTo(right, y);
											ctx.stroke();
											ctx.closePath();

											/* Draw vertical line */
											ctx.beginPath();
											ctx.moveTo(x, top);
											ctx.lineTo(x, bottom);
											ctx.stroke();
											ctx.closePath();

											/* Find coordinates */
											/* x_frac: x \in (0,1) as proportion of chart width */
											let x_frac = Math.abs((x - left) / (right - left));

											/* X: Total width of the x-axis in physical units */
											let X = Math.abs(xMax - xMin);

											/* x_coord: x \in (xMin, xMax) in physical units */
											if (cjs_plot.options.scales['x'].type == 'linear') {
													x_coord = x_frac * X + xMin;
											}	else if (cjs_plot.options.scales['x'].type == 'logarithmic') {
													let logX = Math.abs(log10(xMax) - log10(xMin));
													x_coord = 10**( x_frac * logX + log10(xMin) );
											}

											/* y_frac: y \in (0,1) as proportion of chart height
											 * (measured from the top!) */
											let y_frac = Math.abs((y - top) / (bottom - top));

											/* Invert y_frac so that it measures from the bottom */
											y_frac = (y_frac - 1) * -1;

											/* Y: Total height of the y-axis in physical units */
											let Y = Math.abs(yMax - yMin);

											/* y_coord: y \in (yMin, yMax) in physical units */
											if (cjs_plot.options.scales['y'].type == 'linear') {
													y_coord = y_frac * Y + yMin;
											} else if (cjs_plot.options.scales['y'].type == 'logarithmic') {
													let logY = Math.abs(log10(yMax) - log10(yMin));
													y_coord = 10**( y_frac * logY + log10(yMin) );
											}

											/* Offset the [x,y] label to the lower right a bit */
											let delta = 5;
											cursor.style.left = (mousemove.pageX + delta) + 'px';
											cursor.style.top = (mousemove.pageY + delta) + 'px';

											label.innerHTML = '[x:' + x_coord.toFixed(2)
																			+ ', y:' + y_coord.toFixed(2) + ']';
									}

									/* If you don't do this the chart area border takes the 
									 * same styling as the crosshairs */
									ctx.restore();

							} /* End of crosshair() function */


							parId_plot.querySelector('.xlabel').innerHTML = title;
							parId_plot.querySelector('.plottitle')
												.innerHTML = dataset_descr + ': ' +
																		 parameter + ' : ' +
																		 nevents + ' entries';

							let print_button = document.createElement('input');
							print_button.setAttribute('type', 'button');
							print_button.setAttribute('class', 'save');
							print_button.setAttribute('value', 'Print plot');

							parId_chart.appendChild(print_button);

						  /* Define the DC.js correlated chart */
						  let chart = dc.barChart('#'+parId+'-chart')
													  .width(768)
														.height(480)
														.x(d3.scaleLinear().domain([xmin,xmax]))
														.brushOn(true)
														.centerBar(false)
														.xAxisLabel(title)
														.yAxisLabel('Number of events')
														.dimension(dimension)
														.group(group);

						  /* Create the DC.js correlated chart */
							chart.render();

							/* For Chart.js */
							xmin_cjs = cjs_plot.scales.x.min;
							xmax_cjs = cjs_plot.scales.x.max;
							//console.log("Chart.js: " + xmin_cjs + ", " + xmax_cjs);

							let reset_button = parId_plot.querySelector('.reset-selection');
							reset_button.addEventListener("click", (event) => {
									/* mode choices are 'active', 'resize', 'show', 'hide' */
									cjs_plot.resetZoom(mode = 'active');
							});

							let logx_box = parId_plot.querySelector('.logx');
							let logy_box = parId_plot.querySelector('.logy');

							logx_box.addEventListener("change", function(e) {
									if (this.checked) {
											cjs_plot.options.scales['x'].type = 'logarithmic';
									} else {
											cjs_plot.options.scales['x'].type = 'linear';
									}
									cjs_plot.update();
							});

							logy_box.addEventListener("change", function(e) {
									if (this.checked) {
											cjs_plot.options.scales['y'].type = 'logarithmic';
									} else {
											cjs_plot.options.scales['y'].type = 'linear';
									}
									cjs_plot.update();
							});

							let binwidth_set = parId_plot.querySelector('.apply-binwidth');
							//console.log(binwidth_set);
							binwidth_set.addEventListener("click", function(e) {

									let new_binwidth = parId_plot.querySelector('input.binwidth').value;
									//console.log(new_binwidth);

									if ( new_binwidth === '') {
											return;
									}

									histogram = buildHistogram(
											current_data.map(
													function(d) {return +d[parameter];}
											),
											new_binwidth
									);
									cjs_plot.data.datasets = [{data: histogram}];
									cjs_plot.update();
							});
					
							/* A "save" button for the histogram, which opens a new
							 * window/tab with a PNG that can be downloaded */
							let plot_save_button = parId_plot.querySelector('.save');
							plot_save_button.addEventListener("click", function(e) {
									let image = cjs_plot.toBase64Image();
									window.open(image, "toDataURL() image", "width=800, height=400");
							});

							/* A "save" button for the correlated charts, which opens
							 * a new window/tab with a PNG that can be downloaded */
							let chart_save_button = parId_chart.querySelector('.save');
							chart_save_button.addEventListener("click", function(e) {

									let svg = document.querySelector('#'+parId+'-chart > svg');
									let serializer = new XMLSerializer();
									let source = serializer.serializeToString(svg);
									let imgsrc = 'data:image/svg+xml;base64,'+ btoa(source);

									let img = '<img src="'+imgsrc+'">';
									let image = new Image;
									image.src = imgsrc;

									image.onload = function() {
											let canvas = document.createElement('canvas');
											canvas.width = image.width;
											canvas.height = image.height;
											let context = canvas.getContext('2d');
											context.drawImage(image, 0, 0);
											let canvasdata = canvas.toDataURL("image/png");
											window.open(canvasdata, "toDataURL() image", "width=800, height=400");
									};
							});

							/* There are two `.selector` checkboxes; one for "type" and
							 * one for "charge".  We attach to both a function that 
							 * evaluates the four combinations of checked/unchecked
							 * individually.
							 */
							let input_selectors = parId_plot.querySelectorAll('input.selector');
							for (let i = 0; i < input_selectors.length; i++) {
									input_selectors[i].addEventListener("change", function() {

											let binwidth = $('input.binwidth').val();
											let hist;

											/* This only assumes that we have the two selectors
											 * for charge and type.
											 * Kludgy, but good enough for now. */
											let charge_checked = parId_plot.querySelector('input.selector-charge').checked;
											let type_checked = parId_plot.querySelector('input.selector-type').checked;

											if ( ! charge_checked && ! type_checked ) {
													current_data = original_data;
											}

											if ( ! charge_checked && type_checked ) {
													current_data = original_data.filter(
															function(d) {
																	return d[selector.name] === selector.value;
															}
													)
											}

											if ( charge_checked && ! type_checked ) {
													current_data = original_data.filter(
															function(d) {
																	return +d['Q1'] !== +d['Q2'];
															}
													)
											}

											if ( ! charge_checked && type_checked ) {
													current_data = original_data.filter(
															function(d) {
																	return (+d['Q1'] !== +d['Q2'] && d[selector.name] === selector.value);
															}
													)
											}

											histogram = buildHistogram(
													current_data.map(function(d) {return +d[parameter];}),
													binwidth
											)

											cjs_plot.data.datasets = [{data: histogram}];
											cjs_plot.update();
									});
							}
					}
			} /* End parameterSelected() */

			function loadFile(input) {
					d3.csv(input.file).then(function(data) {
							original_data = data;
							current_data = original_data;
							cfdata = crossfilter(data);
							all = cfdata.groupAll();
					});
			}

			function datasetSelected() {
				 
					let params = document.getElementById('parameters');
					let param_table = document.getElementById('parameter-table');
					let plot_container = document.getElementById('plot-container');
					let chart_container = document.getElementById('chart-container');
					params.style.display = 'none';
					param_table.innerHTML = '';
					plot_container.innerHTML = '';
					chart_container.innerHTML = '';

					let expr = document.getElementById('dataset').value;

					for ( let i = 0; i < csv_files.length; i++ ) {
							if ( csv_files[i].id === expr ) {

									dataset_name = csv_files[i].name;
									dataset_id = csv_files[i].id;
									dataset_type = csv_files[i].type;
									dataset_descr = csv_files[i].descr;

									loadFile(csv_files[i]);

									for ( let j = 0; j < event_types[dataset_type].length; j++ ) {
											let par = event_types[dataset_type][j];

											params.style.display = '';

											let param_row = document.createElement('td');
											let param_button = document.createElement('button');
											param_button.setAttribute('class', 'parameter');
											param_button.setAttribute('title', par.description);
											param_button.innerHTML = par.name;
											param_button.addEventListener('click', parameterSelected);
										 
											param_row.appendChild(param_button);
											param_table.appendChild(param_row);
									}
									return;
							}
					}
			} /* End datasetSelected() */

			let dataset_selector = document.getElementById('dataset');
			dataset_selector.addEventListener("change", datasetSelected);

 }); /* End onReady() */

</script>
</body>
</html>
