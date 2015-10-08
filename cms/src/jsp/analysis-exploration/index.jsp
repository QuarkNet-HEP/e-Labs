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

  <script type="text/javascript" src="../include/elab.js"></script>
  <script type="text/javascript" src="../include/d3.min.js"></script>
  <script type="text/javascript" src="../include/crossfilter.min.js"></script>

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

  #plot-container {
    margin-top: 20px;
  }

  .plot {
    border: 1px dashed #cccccc;
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
    <script>
      console.log(d3.version);
    </script>
    <p>
      Explore data from the CMS experiment at the LHC. Many particles can be produced in the proton-proton
      collisions recorded by CMS, such as J/&psi; particles, 	&Upsilon; particles, and W and Z bosons. These
      particles decay into perhaps more familiar particles such as electrons, muons, and photons. From these
      particles one can study the properties of the parent particles.
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

    <div id="plot-container">
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
                  <input type="button" class="reset-selection" value="Reset Selection" />
                </td>
                <td class="group-title">
                  Plot
                </td>
                <td class="toolbox-group">
                  Bin Width: <input type="text" class="binwidth" value="0.1" size="6" /><input type="button" class="apply-binwidth" value="Set"/>
                </td>
              </tr>
                <tr>
                <td class="group-title selector">
                  Selectors
                </td>
                <td class="toolbox-group selector-charge">
                  <input type="checkbox" class="selector-charge"/><span class="selector-charge">Select events with muons/electrons of opposite-sign charge</span>
                </td>
                <td class="toolbox-group selector-type">
                  <input type="checkbox" class="selector-type"/><span class="selector-type"></span>
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
        <div class="ylabel" style="position: absolute; left: -50px; top: 200px;writing-mode: tb-rl; filter: flipV flipH; -webkit-transform: rotate(-90deg); -moz-transform: rotate(-90deg);"></div>
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
            <e:popup href="../video/demos-exploration.html?video=dataset-selection" target="tryit" width="800" height="800">Screencast Demo</e:popup>
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

    $('#parameters').hide();
    //$('.plot').hide();

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
          {name:"pt", unit:"GeV", description:"The transverse momentum [GeV] of the lepton (electron or muon)"}
        ]
    };

  for ( var i = 0; i < csv_files.length; i++ ) {
    var id = csv_files[i].id;
    var name = csv_files[i].name;
    var descr = csv_files[i].descr;
    $('#dataset').append('<option value="'+id+'">'+descr+'</option>');
  }

  var input_data;
  var dataset_name;
  var dataset_id;
  var dataset_type;
  var dataset_descr;
  var cfdata;

  function getDataset(id) {
    for ( var i = 0; i < csv_files.length; i++ ) {
      if ( csv_files[i].id === id ) {
        return csv_files[i];
      }
    }
    return null;
  }

  function buildHistogram(data, bw) {
     var minx = d3.min(data),
     maxx = d3.max(data),
     nbins = Math.floor((maxx-minx) / bw);

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
  $('#parameter-table .parameter').live('click', function() {
    var parameter = $(this).html();
    var title = $(this).attr('title');

    var active = $(this).hasClass('active');
    var parId = 'plot'+parameter;

    if ( active ) {
      $(this).removeClass('active');
      $('#'+parId).remove();

    } else {
      $(this).addClass('active');

      var options = {
          lines: { show: true, fill: false, lineWidth: 1.2 },
          grid: { hoverable: true, autoHighlight: false },
          points: { show: false },
          legend: { noColumns: 1 },
          xaxis: { tickDecimals: 0 },
          yaxis: { autoscaleMargin: 0.1 },
          y2axis: { autoscaleMargin: 0.1 },
          crosshair: { mode: "xy" },
          selection: { mode: "xy", color: "yellow" }
      };

      var histogram = buildHistogram(input_data.map(function(d) {return +d[parameter];}), 0.1);
      var nevents = input_data.length;
      $('#plot-container').append("<div class=\"plot\" id=\"" + parId + "\"></div>");
      $('#'+parId).append($('#plot-template').html());

      $('#'+parId+' .selector-type').hide();
      $('#'+parId+' .selector-charge').hide();
      //console.log(dataset_id);
      var dataset = getDataset(dataset_id);
      //console.log(dataset);
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
      $('#'+parId+ ' .ylabel').html('Number of events');
      $('#'+parId+ ' .plottitle').html(dataset_descr+': '+parameter+' : '+nevents+' entries');

      plot.draw();
      var xmin = plot.getAxes().xaxis.min;
      var xmax = plot.getAxes().xaxis.max;
      var ymin = plot.getAxes().yaxis.min;
      var ymax = plot.getAxes().yaxis.max;

      $('#'+parId+' .placeholder').bind('plotselected', function(event, ranges) {
        console.log("You selected " + ranges.xaxis.from.toFixed(1) + " to " + ranges.xaxis.to.toFixed(1));
        console.log(data[0].data.length);
        $.extend(true, options, {xaxis:{min: ranges.xaxis.from, max: ranges.xaxis.to}, yaxis:{ min: ranges.yaxis.from, max: ranges.yaxis.to}});
        $.plot($('#'+parId+ ' .placeholder'), data, options);
      });

      $('#'+parId+' .reset-selection').bind('click', function() {
         $.extend(true, options, {xaxis:{min: xmin, max: xmax}, yaxis:{min: ymin, max:ymax}});
         $.plot($('#'+parId+ ' .placeholder'), data, options);
      });

      $('#'+parId+' .logx').bind('change', function(){
        if ( $(this).is(':checked') ) {
           $.extend(true, options, {xaxis:{transform:log10, inverseTransform:pow10}});
        } else {
           $.extend(true, options, {xaxis:{transform:null,inverseTransform:null}});
        }
        $.plot($('#'+parId+ ' .placeholder'), data, options);
      });

      $('#'+parId+' .logy').bind('change', function(){
        if ( $(this).is(':checked') ) {
           $.extend(true, options, {yaxis:{transform:log10, inverseTransform:pow10}});
        } else {
           $.extend(true, options, {yaxis:{transform:null,inverseTransform:null}});
        }
        $.plot($('#'+parId+ ' .placeholder'), data, options);
      });

      $('#'+parId+' .apply-binwidth').bind('click', function() {
        var value = $('#'+parId+' input.binwidth').val();
        //console.log(parId + ' ' + value);

        if ( value === '' ) {
          return;
        }

        histogram = buildHistogram(input_data.map(function(d) {return +d[parameter];}), value);
        data = [{data:histogram, label:parameter}];
        $.plot($('#'+parId+ ' .placeholder'), data, options);
      });

      $('#'+parId+' input.selector-type').bind('change', function() {
        var bw = $('input.binwidth').val();

        //console.log(bw);
        var hist;

        if ( ! $(this).is(':checked') ) {
          hist = buildHistogram(input_data.map(function(d) {return +d[parameter];}), bw);
        } else {
          console.log('select!');
          console.log(selector.name, selector.value);
          var filtered_data = input_data.filter(function(d) {return d[selector.name] === selector.value;});
          console.log(filtered_data);
          hist = buildHistogram(filtered_data.map(function(d) {return +d[parameter];}), bw);
        }
        data = [{data:hist, label:parameter}];
        $.plot($('#'+parId+ ' .placeholder'), data, options);
      });

      $('#'+parId+' input.selector-charge').bind('change', function() {
        var bw = $('input.binwidth').val();
        var hist;

        if ( ! $(this).is(':checked') ) {
          hist = buildHistogram(input_data.map(function(d) {return +d[parameter];}), bw);
        } else {
          console.log('select!');
          var filtered_data = input_data.filter(function(d) {return +d['Q1'] !== +d['Q2'];});
          console.log(filtered_data);
          hist = buildHistogram(filtered_data.map(function(d) {return +d[parameter];}), bw);
        }
        data = [{data:hist, label:parameter}];
        $.plot($('#'+parId+ ' .placeholder'), data, options);
      });

      $('#'+parId+' .placeholder').bind('plothover', function(event, pos, item) {
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

      $('#'+parId+' .placeholder').bind('mouseout', function() {
        $('#'+parId+' .cursor').css("display", "none");
      });
    }
  });

  function loadFile(input) {
    d3.csv(input.file,
      function(data) {
        input_data = data;
        cfdata = crossfilter(data);
      }
    );
  }

  function datasetSelected() {
    $('#parameters').hide();
    $('#parameter-table').empty();
    $('#plot-container').empty();

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
