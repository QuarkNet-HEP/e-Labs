var onOffPlot = null;
var data = []; //data that will be sent to the chart
var layout = "";

layout = {
		  autosize: false,
		  width: 600,
		  height: 600,
		  margin: {
			    l: 50, 
			    r: 50, 
			    b: 50, 
			    t: 100, 
			    pad: 4			  
		  },
		  title: "Performance Study", 
		  xaxis: {
		    title: "Time over Threshold (nanosec)", 
		    titlefont: {
		      family: "Courier New, monospace", 
		      size: 18, 
		      color: "#7f7f7f"
		    }
		  }, 
		  yaxis: {
		    title: "Number of PMT pulses", 
		    titlefont: {
		      family: "Courier New, monospace", 
		      size: 18, 
		      color: "#7f7f7f"
		    }
		  }
	};


function onDataLoad(json) {	
	channel1 = json.channel1;
	channel2 = json.channel2;
	channel3 = json.channel3;
	channel4 = json.channel4;
	data.push(channel1);
	data.push(channel2);
	data.push(channel3);
	data.push(channel4);
	Plotly.plot(document.getElementById("placeholder"), data, layout);
}//end of onDataLoad	


