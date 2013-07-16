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

function showCharts(filename, path){
	$currentDiv = $("#tableWrapper").children("."+filename);
	var messages = document.getElementById("messages");
	messages.innerHTML = "";
	var chartDiv = document.getElementById("chartsDiv");
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
		url: path+filename,
		processData: false,
		dataType: "json",
		type: "GET",
		success: onDataLoad1,
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
	var chartDiv = document.getElementById("chartsDiv");
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

function addBenchmarkFiles(detector, fromDateObject, toDateObject) {
	if (detector != "") {
		var fromDate = document.getElementById(fromDateObject);
		var toDate = document.getElementById(toDateObject);
		var params = 'dialogWidth:1000px;dialogHeight:750px;dialogTop:10px;dialogLeft:150px';
		var newwindow = window.showModalDialog("benchmark-add.jsp?detector="+detector+"&fromDate="+fromDate.value+"&toDate="+toDate.value, "addBenchmark", params);		
	} else {
		var messages = document.getElementById("messages");
		messages.innerHTML = "<i>* Choose a detector first.</i>"		
	}
}//end of addBenchMarkFiles

function setDefault(checkedObject, detector, fileName) {
	var filename = document.getElementById("filename");
	filename.value = fileName;
	var detectorId = document.getElementById("detectorId");
	detectorId.value = detector;				
	var def = document.getElementById("defaultBenchmark");
	if (checkedObject.checked) {
		def.value = "true";
	} else {
		def.value = "false";
	}
	document.getElementById('submitButton').click();
}//end of setDefault	

function deleteBenchmark(filename, defaultFlag) {
	if (defaultFlag) {
		var messages = document.getElementById("messages");
		messages.innerHTML = "<i>* Cannot remove a default benchmark file</i>"
		return false;
	} else {
		var removeBenchmark = document.getElementById("removeBenchmark");
		var blessed = document.getElementsByClassName(filename);
		var msg = "";
		if (blessed) {
			for (var i = 0; i < blessed.length; i++) {
				msg = blessed[i].value + "\n";
			}
		}
		if (msg != "") {
			var answer = confirm("Files: \n" + msg + "will be unblessed. Continue?");
			if (answer == true) {
				removeBenchmark.value = filename;
				document.getElementById('submitButton').click();	
			}
		}
	}
}//end of deleteBenchmark

$("html").keyup( function(keyEvent) {
	//tab = 9, keydown= 40
    if (keyEvent.keyCode == 40) {
        var $nextDiv;
        if ($currentDiv.next().size() == 0) {
            $nextDiv = $("#tableWrapper").children().first();
        }
        else {
            $nextDiv = $currentDiv.next();
        }
        for (var i = 0; i < $nextDiv.length; i++) {
        	showCharts($nextDiv[i].id, "get-data.jsp?file=");
        	$nextDiv[i].scrollIntoView(true);
        }

        $currentDiv = $nextDiv;
    }
	//tab back= shiftKey, keyup= 38
    else if (keyEvent.keyCode == 38) {
        var $previousDiv;
        if ($currentDiv.prev().size() == 0) {
            $previousDiv = $("#tableWrapper").children().last();
        }
        else {
            $previousDiv = $currentDiv.prev();
        }
        for (var i = 0; i < $previousDiv.length; i++) {
        	showCharts($previousDiv[i].id, "get-data.jsp?file=");
        	$previousDiv[i].scrollIntoView(true);
          }
        $currentDiv = $previousDiv;
    }
});

function checkLabel(){
	var benchmarkLabel = document.getElementById("benchmarkLabel");
	var radios = document.getElementsByName("benchmark");
	var message = document.getElementById("messages");
	var keepGoing = false;
	for (i = 0; i < radios.length; i++) {
		if (radios[i].checked) {
			keepGoing = true;
		}
	}
	if (keepGoing) {
		if (benchmarkLabel.value == "" || benchmarkLabel.value == null) {
			message.innerHTML = "<i>* Please enter a label for this file.</i>";
			benchmarkLabel.focus();
			return false;
		} else {
			return true;
		}
	} else {
		message.innerHTML = "<i>* Please select a benchmark file.</i>";
		return false;
	}
}//end of checkLabel

function retrieveAll() {
	var includeBlessed = document.getElementById("includeBlessed");
	if (includeBlessed.selectedIndex != -1) {
		includeBlessed.value = "YES";
		var selectedDetector = document.getElementById("selectedDetector");
		if (selectObject.value != "") {
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
