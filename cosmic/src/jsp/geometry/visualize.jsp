<%-- *** filename:  visualize.jspf -- created by Sudha Balakrishnan, May 2015 *** --%>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.util.*" %>

<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>

<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
 		<script src="../include/jquery/js/jquery-1.12.4.min.js"></script>
		<script src="../include/highcharts/js/highcharts.js"></script>
		<script src="../include/highcharts/js/highcharts-3d.js"></script>
		<script src="../include/highcharts/js/modules/exporting.js"></script>
		<title>Visualize Geometry</title>
	</head>

	<body>
	<div id="container" style="height:500px; min-width:310px; max-width:800px; margin:0 auto;"></div>
	<script>

$(function () {

    // Give the points a 3D feel by adding a radial gradient
    Highcharts.getOptions().colors = $.map(Highcharts.getOptions().colors, function (color) {
        return {
            radialGradient: {
                cx: 0.4,
                cy: 0.3,
                r: 0.5
            },
            stops: [
                [0, color],
                [1, Highcharts.Color(color).brighten(-0.2).get('rgb')]
            ]
        };
    });


    var callingURL = top.location.href;
    var cgiString = callingURL.substring(callingURL.indexOf('?'), callingURL.length);

    if (callingURL.indexOf('?') != -1) {
      var x1 = parseFloat(cgiString.substring(cgiString.indexOf('x1=') + 3, cgiString.indexOf('&y1=')),10);
      var y1 = parseFloat(cgiString.substring(cgiString.indexOf('y1=') + 3, cgiString.indexOf('&z1=')),10);
      var z1 = parseFloat(cgiString.substring(cgiString.indexOf('z1=') + 3, cgiString.indexOf('&x2=')),10);

      var x2 = parseFloat(cgiString.substring(cgiString.indexOf('x2=') + 3, cgiString.indexOf('&y2=')),10);
      var y2 = parseFloat(cgiString.substring(cgiString.indexOf('y2=') + 3, cgiString.indexOf('&z2=')),10);
      var z2 = parseFloat(cgiString.substring(cgiString.indexOf('z2=') + 3, cgiString.indexOf('&x3=')),10);

      var x3 = parseFloat(cgiString.substring(cgiString.indexOf('x3=') + 3, cgiString.indexOf('&y3=')),10);
      var y3 = parseFloat(cgiString.substring(cgiString.indexOf('y3=') + 3, cgiString.indexOf('&z3=')),10);
      var z3 = parseFloat(cgiString.substring(cgiString.indexOf('z3=') + 3, cgiString.indexOf('&x4=')),10);

      var x4 = parseFloat(cgiString.substring(cgiString.indexOf('x4=') + 3, cgiString.indexOf('&y4=')),10);
      var y4 = parseFloat(cgiString.substring(cgiString.indexOf('y4=') + 3, cgiString.indexOf('&z4=')),10);
      var z4 = parseFloat(cgiString.substring(cgiString.indexOf('z4=') + 3, cgiString.length),10);
    }


    if (x1==0 && y1==0 && z1==0) {
    	x1 = y1 = z1 = null;
    }
    if (x2==0 && y2==0 && z2==0) {
    	x2 = y2 = z2 = null;
    }
    if (x3==0 && y3==0 && z3==0) {
    	x3 = y3 = z3 = null;
    }
    if (x4==0 && y4==0 && z4==0) {
    	x4 = y4 = z4 = null;
    }


    //Find min and max of x, y, and z values
    var xMin = Math.min(x1, x2, x3, x4, 0) - 1; //alert("xMin: "+xMin);
    var xMax = Math.max(x1, x2, x3, x4, 0) + 1; //alert("xMax: "+xMax);

    var yMin = Math.min(y1, y2, y3, y4, 0) - 1; //alert("yMin: "+yMin); 
    var yMax = Math.max(y1, y2, y3, y4, 0) + 1; //alert("yMax: "+yMax);

    var zMin = Math.min(z1, z2, z3, z4, 0) - 1; //alert("zMin: "+zMin);
    var zMax = Math.max(z1, z2, z3, z4, 0) + 1; //alert("zMax: "+zMax);

    // Set up the chart
    var chart = new Highcharts.Chart({
        chart: {
            renderTo: 'container',
            margin: 100,
            type: 'scatter',
            options3d: {
                enabled: true,
                alpha: 10,
                beta: 30,
                depth: 250,
                viewDistance: 5,

                frame: {
                    bottom: { size: 1, color: 'rgba(0,0,0,0.02)' },
                    back: { size: 1, color: 'rgba(0,0,0,0.04)' },
                    side: { size: 1, color: 'rgba(0,0,0,0.06)' }
                }
            }
        },

        title: {
            text: 'Configuration of Counters & GPS',
            style: {font: 'bold'}
        },
        subtitle: {
            text: 'Click and drag plot area to rotate. <br/> Hover over point to see description & coordinates.  <br/> A point represents center of counter or GPS.'
        },
        tooltip: {
                    formatter: function () {
                		return this.point.name + ':  (<b>' + this.point.x + ',<b>' + this.point.z + ',<b>' + this.point.y +')<b>';
            		}
                },

//z and y axes are reversed because we want z-axis to be up-down.
        xAxis: {
            min: xMin,
            max: xMax,
            tickPixelInterval:  100,
			title: {
				text: 'X-Axis (meters):  W(-)->E(+)',
				style: {color: 'blue'},
         		rotation: 10
         	}
        },
        yAxis: {
            min: zMin,
            max: zMax,
            tickPixelInterval:  100,
            title: {
            	text: 'Z-Axis (meters):  Down(-)->Up(+)',
            	style: {color: 'blue'},
            }
        },
        zAxis: {
            min: yMin,
            max: yMax,
            title: {
            	text: 'Y-Axis (meters)',
            	style: {color: 'blue'}
         	}
        },
        legend: {
            enabled: false
        },


        series: [{
        	data:  [
	       	{name:  'Channel 1', color:'black', x:x1, y:z1, z:y1},
         	{name:  'Channel 2', color: 'black', x:x2, y:z2, z:y2},
         	{name:  'Channel 3', color: 'black', x:x3, y:z3, z:y3},
         	{name:  'Channel 4', color: 'black', x:x4, y:z4, z:y4},
        	{name:  'GPS', color:'red', x:0, y:0, z:0}
        	]
    	}]
    },

 		//Add extra text
    	function (chart) {
    	chart.renderer.text('Are your counters in these locations? <br/> If not, make sure you have entered your geometry properly.', 0, 475)
            .css({
                fontSize: '12px',
                fontStyle: 'italic'
            })
            .add();

		chart.renderer.text('Y-axis (m): S(-)->N(+)',700,475)
			.attr({
                rotation: -40
            })
            .css({
                color: 'blue',
                fontSize: '12px'
            })
			.add();

	}
	);

    // Add mouse events for rotation
    $(chart.container).bind('mousedown.hc touchstart.hc', function (e) {
        e = chart.pointer.normalize(e);

        var posX = e.pageX,
            posY = e.pageY,
            alpha = chart.options.chart.options3d.alpha,
            beta = chart.options.chart.options3d.beta,
            newAlpha,
            newBeta,
            sensitivity = 5; // lower is more sensitive

        $(document).bind({
            'mousemove.hc touchdrag.hc': function (e) {
                // Run beta
                newBeta = beta + (posX - e.pageX) / sensitivity;
                newBeta = Math.min(100, Math.max(-100, newBeta));
                chart.options.chart.options3d.beta = newBeta;

                // Run alpha
                newAlpha = alpha + (e.pageY - posY) / sensitivity;
                newAlpha = Math.min(100, Math.max(-100, newAlpha));
                chart.options.chart.options3d.alpha = newAlpha;

                chart.redraw(false);
            },
            'mouseup touchend': function () {
                $(document).unbind('.hc');
            }
        });
    });

});

	</script>
	</body>
</html>


