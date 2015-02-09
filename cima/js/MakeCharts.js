var ctx;
var myBarChart;
var options;


function MakeHist(datax){

	var x=new Array(68)
	var y=datax.split(";");
	var c=1;

	for(var i=0;i<68;i++){
		x[i]=c;
		c+=2;

	}

	var data = {
	    labels: x,
	    datasets: [
	        {
	            label: "My First dataset",
	            fillColor: "rgba(0,10,220,0.5)",
	            strokeColor: "rgba(220,220,220,0.8)",
	            highlightFill: "rgba(220,0,0,0.75)",
	            highlightStroke: "rgba(220,220,220,1)",
	            data: y
	        },
	    ]
	};

	options={
	    //Boolean - Whether the scale should start at zero, or an order of magnitude down from the lowest value
	scaleBeginAtZero : true,

 	   //Boolean - Whether grid lines are shown across the chart
    	scaleShowGridLines : true,

    	//String - Colour of the grid lines
    	scaleGridLineColor : "rgba(0,0,0,.05)",

    	//Number - Width of the grid lines
    	scaleGridLineWidth : 1,

    	//Boolean - If there is a stroke on each bar
    	barShowStroke : true,

    	//Number - Pixel width of the bar stroke
    	barStrokeWidth : 2,

    	//Number - Spacing between each of the X value sets
    	barValueSpacing : 0,

    	//Number - Spacing between data sets within X values
    	barDatasetSpacing : 0,

    	//String - A legend template
    	legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><li><span style=\"background-color:<%=datasets[i].lineColor%>\"></span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>"

	}
	ctx = document.getElementById("myChart").getContext("2d");
	myBarChart = new Chart(ctx).Bar(data, options);

}

function uhist(datax){

	var y=datax.split(";");
	
	for(var i=0;i<68;i++){
		myBarChart.datasets[0].bars[i].value=y[i];
	}
	myBarChart.update();
}	

function update(evt){
    var activeBars = myBarChart.getBarsAtEvent(evt);
    //alert(Chart.helpers.getRelativePosition(evt).x);
    var index=(activeBars[0].label-1)/2;
    var del=1;
    if(evt.ctrlKey || evt.metaKey){
	del=1;
	/*if(myBarChart.datasets[0].bars[index].value!=0){
       	 myBarChart.datasets[0].bars[index].value=(parseInt(activeBars[0].value)-1).toString();
	}*/

    }else{
	del=0;
        //myBarChart.datasets[0].bars[index].value=(parseInt(activeBars[0].value)+1).toString();

    }
    $.ajax({
	type: "POST",
	url: "AddHistData.php",
	data: {
	x : index,
	d : del
	},
	success: function( data ) {
		uhist(data);
	}
	});
  }

