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
  <link rel="stylesheet" type="text/css" href="../css/dc.min.css"/>

  <script type="text/javascript" src="../include/elab.js"></script>
  <script type="text/javascript" src="../include/d3.min.js"></script>
  <script type="text/javascript" src="../include/crossfilter.min.js"></script>
  <script type="text/javascript" src="../include/dc.min.js"></script>
  <script type="text/javascript" src="../include/html2canvas.js"></script>

   <link href="../include/jeegoocontext/skins/cm_blue/style.css" rel="Stylesheet" type="text/css" />

  <style>
  .parameter.active {
    font-weight: bold;
    background-color: #cccccc;
  }

  .parameter:hover {
    color: #cccccc;
  }

  .placeholder {
    width: 758px;
    height: 380px;
    margin-bottom: 26px;
    margin-left: 26px;
  }

  .plottitle {
    width: 758px;
    height: 16px;
    padding-left: 48px;
  }

  .xlabel {
    position: absolute;
    left: 200px;
    bottom: -24px;
  }

  .ylabel {
    position: absolute;
    left: 0px;
    top: 200px;
    writing-mode: tb-rl;
    filter: flipV flipH;
    -webkit-transform: rotate(180deg);
    -moz-transform: rotate(180deg);
  }

  #plot-container {
    margin-top: 20px;
  }

  .plot {
    border: 1px dashed #cccccc;
  }

  ul.tab {
    list-style-type: none;
    margin: 0;
    padding: 0;
    overflow: hidden;
    border: 1px solid #ccc;
    background-color: #f1f1f1;
  }

  ul.tab li {float: left;}

  ul.tab li a {
    display: inline-block;
    color: black;
    text-align: center;
    padding: 14px 16px;
    text-decoration: none;
    transition: 0.3s;
    font-size: 17px;
  }

  ul.tab li a:hover {background-color: #ddd;}
  ul.tab li a:focus, .active {background-color: #ccc;}

  .tabcontent {
    display: none;
    padding: 6px 12px;
    border: none;
    border-top: none;
  }

  .tab::before {
    content: none;
  }

  .data .tab {
    padding-top: 0;
  }
  </style>

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
  <script language="javascript" type="text/javascript" src="../include/jquery.flot.js"></script>
  <script language="javascript" type="text/javascript" src="../include/jquery.flot.selection.js"></script>
  <script language="javascript" type="text/javascript" src="../include/jquery.flot.crosshair.js"></script>
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
                  <input type="button" class="reset-selection" disabled autocomplete="off" value="Reset X Selection" />
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
      <div class="cursor" style="position: absolute; z-index: 10; display: none">
        <span class="cursorValue"></span> <span class="cursorUnit"></span>
      </div>
      <div class="frame" style="position: relative;">
        <div class="plottitle"></div>
        <div class="placeholder"></div>
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
  $(function() {

    $('.tablinks').on('click', function() {
      $('.tablinks').removeClass('active');
      $(this).addClass('active');

      if ($(this).hasClass('plot')) {
        $('#chart-container').hide();
        $('#plot-container').show();
      }

      if ($(this).hasClass('chart')) {
        $('#plot-container').hide();
        $('#chart-container').show();
      }
    });

    $('#parameters').hide();

    // show plot container div by default
    $('#plot-container').show();

    var csv_files = [
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

    // We know the names of the parameters that we have produced in the csv files.
    // We also have only two event types in the csv: lepton_neutrino and two_lepton.
    // We therefore provide some information on the parameters.
    var event_types = {
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

  for ( var i = 0; i < csv_files.length; i++ ) {
    var id = csv_files[i].id;
    var name = csv_files[i].name;
    var descr = csv_files[i].descr;
    $('#dataset').append('<option value="'+id+'">'+descr+'</option>');
  }

  var original_data;
  var current_data;
  var dataset_name;
  var dataset_id;
  var dataset_type;
  var dataset_descr;
  var cfdata, all;

  function getDataset(id) {
    for ( var i = 0; i < csv_files.length; i++ ) {
      if ( csv_files[i].id === id ) {
        return csv_files[i];
      }
    }
    return null;
  }

  function buildHistogram(data, bw) {
    var minx = Math.floor(d3.min(data)),
    maxx = Math.ceil(d3.max(data)),
    nbins = Math.floor((maxx-minx) / bw);

    //console.log('minx, maxx', minx, maxx);

    var histogram = d3.layout.histogram();
    histogram.bins(nbins);
    data = histogram(data);

    var output = [];
    for ( var i = 0; i < data.length; i++ ) {
      output.push([data[i].x, data[i].y]);
      output.push([data[i].x + data[i].dx, data[i].y]);
    }
    return output;
  }

  ln = function(v) { return v > 0 ? Math.log(v) : 0; }
  exp = function(v) { return Math.exp(v); }
  log10 = function(v) { return v > 0 ? Math.log(v)/Math.log(10): 0; }
  pow10 = function(v) { return Math.pow(v,10); }

  // need to update jquery!
  $('#parameter-table .parameter').on('click', function() {
    var parameter = $(this).html();
    var title = $(this).attr('title');

    var active = $(this).hasClass('active');
    var parId = 'plot'+parameter;

    if ( active ) {
      $(this).removeClass('active');
      $('#'+parId).remove();
      $('#'+parId+'-chart').remove();
    } else {
      $(this).addClass('active');

      var options = {
          lines: { show: true, fill: false, lineWidth: 1.2 },
          grid: { hoverable: true, autoHighlight: false },
          points: { show: false },
          legend: { noColumns: 1 },
          xaxis: { tickDecimals: 0 },
          yaxis: { autoscaleMargin: 0.1 },
          crosshair: { mode: "xy" },
          selection: { mode: "x", color: "yellow" }
      };

      var dimension = cfdata.dimension(function(d) {return +d[parameter];});

      var xmin = dimension.bottom(1)[0][parameter];
      var xmax = dimension.top(1)[0][parameter];

      xmin = Math.floor(xmin);
      xmax = Math.ceil(xmax);

      var binw = (xmax - xmin) / 100;
      if ( binw > 1.0 ) {
        binw = Math.floor(binw);
      } else {
        binw = 1.0;
      }

      var group = dimension.group(function(d) {return Math.floor(d/binw)*binw;});

      var histogram = buildHistogram(original_data.map(function(d) {return +d[parameter];}), binw);
      var nevents = original_data.length;

      $('#plot-container').append("<div class=\"plot\" id=\"" + parId + "\"></div>");
      $('#'+parId).append($('#plot-template').html());
      $('#'+parId+' input.binwidth').attr('value', binw);

      $('#chart-container').append("<div class=\"chart\" id=\"" + parId+"-chart" + "\"></div>");

      $('#'+parId+' .selector').hide();
      var dataset = getDataset(dataset_id);
      var selector;

      if ( dataset !== null && 'selector' in dataset ) {
        //console.log(dataset.selector);
        selector = dataset.selector;
        $('#'+parId+' .selector-type').show();
        $('span.selector-type').html(selector.descr);
      }

      if ( dataset_type === 'two_lepton' ) {
        $('#'+parId+' .selector-charge').show();
      }

      var data = [{data:histogram, label:parameter}];
      var plot = $.plot($('#'+parId+ ' .placeholder'), data, options);

      $('#'+parId+ ' .xlabel').html(title);
      //$('#'+parId+ ' .ylabel').html('Number of events');
      $('#'+parId+ ' .plottitle').html(dataset_descr+': '+parameter+' : '+nevents+' entries');

      plot.draw();

      $('#'+parId+'-chart').append('<input type="button" class="save" value="Print plot"/>');

      var chart = dc.barChart('#'+parId+'-chart')
        .width(768)
        .height(480)
        .x(d3.scale.linear().domain([xmin,xmax]))
        .brushOn(true)
        .centerBar(false)
        .xAxisLabel(title)
        .yAxisLabel('Number of events')
        .dimension(dimension)
        .group(group);

      chart.render();

      xmin = plot.getAxes().xaxis.min;
      xmax = plot.getAxes().xaxis.max;

      $('#'+parId+' .placeholder').on('plotselected', function(event, ranges) {
        //console.log("You selected " + ranges.xaxis.from.toFixed(1) + " to " + ranges.xaxis.to.toFixed(1));
        //console.log(data[0].data.length);
        $('.reset-selection').removeAttr('disabled');
        $.extend(true, options, {xaxis:{min: ranges.xaxis.from, max: ranges.xaxis.to}});
        //$.extend(true, options, {xaxis:{min: xmin, max: xmax}});
        $.plot($('#'+parId+ ' .placeholder'), data, options);
      });

      $('#'+parId+' .reset-selection').on('click', function() {
         $.extend(true, options, {xaxis:{min: xmin, max: xmax}});
         $.plot($('#'+parId+ ' .placeholder'), data, options);
      });

      $('#'+parId+' .logx').on('change', function(){
        if ( $(this).is(':checked') ) {
           $.extend(true, options, {xaxis:{transform:log10, inverseTransform:pow10}});
        } else {
           $.extend(true, options, {xaxis:{transform:null,inverseTransform:null}});
        }
        $.plot($('#'+parId+ ' .placeholder'), data, options);
      });

      $('#'+parId+' .logy').on('change', function(){
        if ( $(this).is(':checked') ) {
           $.extend(true, options, {yaxis:{transform:log10, inverseTransform:pow10}});
        } else {
           $.extend(true, options, {yaxis:{transform:null,inverseTransform:null}});
        }
        $.plot($('#'+parId+ ' .placeholder'), data, options);
      });

      $('#'+parId+' .apply-binwidth').on('click', function() {
        var value = $('#'+parId+' input.binwidth').val();
        //console.log(parId + ' ' + value);

        if ( value === '' ) {
          return;
        }

        histogram = buildHistogram(current_data.map(function(d) {return +d[parameter];}), value);
        data = [{data:histogram, label:parameter}];
        $.plot($('#'+parId+ ' .placeholder'), data, options);
      });

      $('#'+parId+' .save').on('click', function() {
        html2canvas($('#'+parId)).then(function(canvas) {
          image = canvas.toDataURL("image/png");
          window.open(image, "toDataURL() image", "width=800, height=400");
        });
      });

      $('#'+parId+'-chart .save').on('click', function() {

        var svg = document.querySelector('#'+parId+'-chart > svg');
        var serializer = new XMLSerializer();
        var source = serializer.serializeToString(svg);
        var imgsrc = 'data:image/svg+xml;base64,'+ btoa(source);

        var img = '<img src="'+imgsrc+'">';
        var image = new Image;
        image.src = imgsrc;

        image.onload = function() {
          var canvas = document.createElement('canvas');
          canvas.width = image.width;
          canvas.height = image.height;
          var context = canvas.getContext('2d');
          context.drawImage(image, 0, 0);
          var canvasdata = canvas.toDataURL("image/png");
          window.open(canvasdata, "toDataURL() image", "width=800, height=400");
        };
      });
      
      $('#'+parId+' input.selector').on('change', function() {
        var bw = $('input.binwidth').val();
        var hist;

        // This only assumes that we have the two selectors for charge and type.
        // Kludgy, but good enough for now.

        if ( ! $('#'+parId+' input.selector-charge').is(':checked') && ! $('#'+parId+' input.selector-type').is(':checked') ) {
          //console.log('original');
          current_data = original_data;
        }

        if ( ! $('#'+parId+' input.selector-charge').is(':checked') && $('#'+parId+' input.selector-type').is(':checked') ) {
          //console.log('type');
          current_data = original_data.filter(function(d) {return d[selector.name] === selector.value;});
        }

        if ( $('#'+parId+' input.selector-charge').is(':checked') && ! $('#'+parId+' input.selector-type').is(':checked') ) {
          //console.log('charge');
          current_data = original_data.filter(function(d) {return +d['Q1'] !== +d['Q2'];});
        }

        if( $('#'+parId+' input.selector-charge').is(':checked') && $('#'+parId+' input.selector-type').is(':checked') ) {
          //console.log('both');
          current_data = original_data.filter(function(d) {return (+d['Q1'] !== +d['Q2'] && d[selector.name] === selector.value);});
        }

        hist = buildHistogram(current_data.map(function(d) {return +d[parameter];}), bw);
        data = [{data:hist, label:parameter}];
        $.plot($('#'+parId+ ' .placeholder'), data, options);
      });

      $('#'+parId+' .placeholder').on('plothover', function(event, pos, item) {
        // Hmm, I need to fix the cursor value when logx.
        // For now, disable cursor when logx is checked
        if ( $('#'+parId+' .logx').is(':checked') ) {
          $('#'+parId+' .cursor').css("display", "none");
          return;
        }

        $('#'+parId+' .cursor').css("display", "block");
        $('#'+parId+' .cursor').css("left", (pos.pageX + 6) + "px");
        $('#'+parId+' .cursor').css("top", (pos.pageY - 20) + "px");
        $('#'+parId+' .cursorValue').html('[x:'+pos.x.toFixed(2) +', y:'+pos.y.toFixed(2)+']');
      });

      $('#'+parId+' .placeholder').on('mouseout', function() {
        $('#'+parId+' .cursor').css("display", "none");
      });
    }
  });

  function loadFile(input) {
    d3.csv(input.file,
      function(data) {
        original_data = data;
        current_data = original_data;
        cfdata = crossfilter(data);
        all = cfdata.groupAll();
      }
    );
  }

  function datasetSelected() {
    $('#parameters').hide();
    $('#parameter-table').empty();
    $('#plot-container').empty();
    $('#chart-container').empty();

    var expr = $('select option:selected').attr('value');
    var type;

    for ( var i = 0; i < csv_files.length; i++ ) {
      if ( csv_files[i].id === expr ) {
        //type = csv_files[i].type;

        dataset_name = csv_files[i].name;
        dataset_id = csv_files[i].id;
        dataset_type = csv_files[i].type;
        dataset_descr = csv_files[i].descr;

        loadFile(csv_files[i]);

        for ( var j = 0; j < event_types[dataset_type].length; j++ ) {
            var par = event_types[dataset_type][j];
            $('#parameters').show();
            $('#parameter-table').append('<td><button class="parameter" title="'+ par.description +'">'+ par.name +'</button></td>');
        }
        return;
      }
    }
  }

  $('#dataset').change(datasetSelected);

  });
 </script>
</body>
</html>
