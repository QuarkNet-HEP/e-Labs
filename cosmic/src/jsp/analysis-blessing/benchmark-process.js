/*
 * Edit Peronja: 07/15/2013 - Common code for benchmark jsps.
 * 		In order to be able to call this function we need the following:
 *      -a div called 'tableWrapper' to be able to navigate with mouse down/up.
 * 	    -a div called 'messages' to give feedback to the user
 * 		-a div called 'chartsDiv' that will show the bless charts (see benchmark-charts.jspf)
 * 		-an h2 called 'datafile' to display the file name
 * 		-tables with a common class called 'highlight' to be able to indicate which row the user selected
 */
var $currentDiv = $("#tableWrapper").children().first();

function showChartsWithBenchmark(filename, benchmark, path){
	$currentDiv = $("#tableWrapper").children("."+filename);
	var messages = document.getElementById("messages");
	messages.innerHTML = "";
	var chartDiv = document.getElementById("benchmarkProcessChartsDiv");
	chartDiv.style.visibility = 'visible';
	var datafile = document.getElementById("datafile");
	datafile.innerHTML = "<strong>"+filename+"</strong>";
	var ts = document.getElementsByClassName("highlight");
	highlightRow(ts, filename);
	var radios = document.getElementsByClassName("selectBenchmark");
	selectRadioRow(radios, filename);
	//var arrows = document.getElementsByTagName("label");
	//showArrow(arrows, filename);
	$.ajax({
		//url: "../analysis-blessing/get-data.jsp?file="+filename,
		url: path+"?file="+filename+"&benchmark="+benchmark,
		processData: false,
		dataType: "json",
		type: "GET",
		success: onDataLoadWithBenchmark,
		error: clearPlots
	});				
}//end of showCharts

function highlightRow(ts, filename) {
	if (ts) {
		for (var i = 0; i < ts.length; i++) {
			ts[i].style.border = "solid 0px";
			ts[i].style.backgroundColor = "#ffffff";
		}
	}		
	var t = document.getElementById("table"+filename);
	if (t) {
		t.style.border="1px solid black";
		t.style.backgroundColor = "#ffffe0";
	}
}//end of highlightRow

function selectRadioRow(radios, filename) {
	if (radios) {
		for (var i = 0; i < radios.length; i++) {
			radios[i].checked = false;
		}
	}
	var radio = document.getElementById("benchmark"+filename);
	if (radio) {
		radio.checked = true;
	}	
}// end of selectRadioRow

function showArrow(arrows, filename){
	if (arrows) {
		for (var i = 0; i < arrows.length; i++) {
			arrows[i].style.visibility = "hidden";
		}
	}
	var arrow = document.getElementById("arrow"+filename);
	if (arrow) {
		arrow.style.visibility = "visible";
	}	
}//end of showArrow

function clearPlots() {
	var chartDiv = document.getElementById("benchmarkProcessChartsDiv");
	chartDiv.style.visibility = 'hidden';
	var messages = document.getElementById("messages");
	messages.innerHTML = "<i>* Bless file cannot be rendered.</i>"
}//end of clearPlots

function showAllFiles(selectObject){
	var selectedDetector = document.getElementById("detector");
	if (selectObject.selectedIndex != -1) {
		selectedDetector.value = selectObject.value;
		document.getElementById('submitButton').click();
	}
}//end of showAllFiles

$("html").keyup( function(keyEvent) {
	//tab = 9, keydown= 40
    if (keyEvent.keyCode == 40) {
    	var benchmark = document.getElementById("benchmark");
        var $nextDiv;
        if ($currentDiv.next().size() == 0) {
            $nextDiv = $("#tableWrapper").children().first();
        }
        else {
            $nextDiv = $currentDiv.next();
        }
        for (var i = 0; i < $nextDiv.length; i++) {
        	showChartsWithBenchmark($nextDiv[i].id, benchmark.value, "benchmark-get-data.jsp");
        	$nextDiv[i].scrollIntoView(true);
        }

        $currentDiv = $nextDiv;
    }
	//tab back= shiftKey, keyup= 38
    else if (keyEvent.keyCode == 38) {
    	var benchmark = document.getElementById("benchmark");
        var $previousDiv;
        if ($currentDiv.prev().size() == 0) {
            $previousDiv = $("#tableWrapper").children().last();
        }
        else {
            $previousDiv = $currentDiv.prev();
        }
        for (var i = 0; i < $previousDiv.length; i++) {
        	showChartsWithBenchmark($previousDiv[i].id, benchmark.value, "benchmark-get-data.jsp");
        	$previousDiv[i].scrollIntoView(true);
          }
        $currentDiv = $previousDiv;
    }
});

function retrieveAll() {
	var includeBlessed = document.getElementById("includeBlessed");
	if (includeBlessed.selectedIndex != -1) {
		includeBlessed.value = "YES";
		var selectedDetector = document.getElementById("detector");
		if (selectedDetector.value != "") {
			document.getElementById('submitButton').click();
		}
	}				
}//end of retrieveAll

function selectAll(checkAll) {
	var inputs = document.getElementsByTagName("input");
	for (var i = 0; i < inputs.length; i++) {
		if (inputs[i].type == "checkbox" && inputs[i].name != "blessAll") {
			if (checkAll.checked) {
				inputs[i].checked = true;
			} else {
				inputs[i].checked = false;
			}
		}
	}
}//end of selectAll

function showCandidates(selectObject){
	var includeBlessed = document.getElementById("includeBlessed");
	if (includeBlessed.selectedIndex != -1) {
		includeBlessed.value = "YES";
	}
	var benchmark = document.getElementById("selectedBenchmark");
	if (benchmark.selectedIndex != -1) {
		benchmark.value = selectObject.value;
		document.getElementById('submitButton').click();
	}				
}//end of showCandidates

function checkSelection(flag) {
	if (flag == "NO") {
		return true;
	} else {
		var inputs = document.getElementsByTagName("input");
		for (var i = 0; i < inputs.length; i++) {
			if (inputs[i].type == "checkbox" && inputs[i].name != "checkAll") {
				if (inputs[i].checked == true) {
					return true;
				}
			}
		}		
		var messages = document.getElementById("messages");
		messages.innerHTML = "<i>* Select files(s) to bless.</i>"
		return false;
	}
}//end of checkSelection


