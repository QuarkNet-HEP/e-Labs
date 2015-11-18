function VisualizeValues(t1, t2, t3, t4)
{
	alert(t1); 
	alert(t2);
	alert(t3);
	alert(t4);
	
if (t1 == true){
var x1 = document.getElementById("myForm").elements.namedItem("chan1X").value;
var y1 = document.getElementById("myForm").elements.namedItem("chan1Y").value;
var z1 = document.getElementById("myForm").elements.namedItem("chan1Z").value;
}
else{
	x1 = 0; y1 = 0; z1 = 0;
}

if (t2 == true){
var x2 = document.getElementById("myForm").elements.namedItem("chan2X").value;
var y2 = document.getElementById("myForm").elements.namedItem("chan2Y").value;
var z2 = document.getElementById("myForm").elements.namedItem("chan2Z").value;
}
else{
	x2 = 0; y2 = 0; z2 = 0;
}

if (t3 == true){
var x3 = document.getElementById("myForm").elements.namedItem("chan3X").value;
var y3 = document.getElementById("myForm").elements.namedItem("chan3Y").value;
var z3 = document.getElementById("myForm").elements.namedItem("chan3Z").value;
}
else{
	x3 = 0; y3 = 0; z3 = 0;
}

if (t4 == true){
var x4 = document.getElementById("myForm").elements.namedItem("chan4X").value;
var y4 = document.getElementById("myForm").elements.namedItem("chan4Y").value;
var z4 = document.getElementById("myForm").elements.namedItem("chan4Z").value;
}
else{
	x4 = 0; y4 = 0; z4 = 0;
}	

var urlwithcoord = "visualize.jsp?x1="+x1+"&y1="+y1+"&z1="+z1;
var urlwithcoord = urlwithcoord+"&x2="+x2+"&y2="+y2+"&z2="+z2;
var urlwithcoord = urlwithcoord+"&x3="+x3+"&y3="+y3+"&z3="+z3;
var urlwithcoord = urlwithcoord+"&x4="+x4+"&y4="+y4+"&z4="+z4;

window.open (urlwithcoord,"mywindow");
}

var t1=true; var t2=true; var t3=true; var t4=true;//this will go away when code below is filled in

/*
//initialize global toggle variables
if (brandnew detector){
	var t1=false; var t2=false; var t3=false; var t4=false;
}
else if (existing detector){
	var t1=; var t2=; var t3=; var t4=;//populate with initial conditions
}
*/

//CUSTOMIZED FROM:  i2u2/common/src/jsp/include/elab.js
function HideShowChannel(ID) {
	if ((aLs(ID).visibility == "hidden")) {
		aLs(ID).visibility = "visible";
		aLs(ID).display = "";
		alert(ID);
		
//		console.log(t1); console.log(t2); console.log(t3); console.log(t4);
	}
	else if (aLs(ID).visibility == "visible") {
		aLs(ID).visibility = "hidden";
		aLs(ID).display = "none";	
		alert(ID);
		if (ID=="ch1-v") {t1=false;}
		if (ID=="ch2-v") {t2=false;}
		if (ID=="ch3-v") {t3=false;}
		if (ID=="ch4-v") {t4=false;}
	}
}
