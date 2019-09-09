//initialize toggle variables
let t1=true;
let t2=true;
let t3=true;
let t4=true;

//CUSTOMIZED FROM:  i2u2/common/src/jsp/include/elab.js
//Onclick, call HideShowChannel(ID) first with ch${i}-v, and then with ch${i}-h.  
//Onclick, if inactive (hidden), make visible.
//Onclick, if active (visible), make hidden.
function HideShowChannel(ID) {
	if ((aLs(ID).visibility == "hidden")) {
		aLs(ID).visibility = "visible";
		aLs(ID).display = "";			
//		console.log(t1); 
	}
	else if (aLs(ID).visibility == "visible") {
		aLs(ID).visibility = "hidden";
		aLs(ID).display = "none";	
		if (ID=="ch1-v") {t1=false;}
		if (ID=="ch2-v") {t2=false;}
		if (ID=="ch3-v") {t3=false;}
		if (ID=="ch4-v") {t4=false;}		
		if (ID=="ch1-h") {t1=true;}
		if (ID=="ch2-h") {t2=true;}
		if (ID=="ch3-h") {t3=true;}
		if (ID=="ch4-h") {t4=true;}
		console.log(ID);
	}
}

//Note:  For a new geometry, all channels are by default inactive and initialized to x=y=z=0.
function VisualizeValues(t1, t2, t3, t4)
{
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
urlwithcoord = urlwithcoord+"&x2="+x2+"&y2="+y2+"&z2="+z2;
urlwithcoord = urlwithcoord+"&x3="+x3+"&y3="+y3+"&z3="+z3;
urlwithcoord = urlwithcoord+"&x4="+x4+"&y4="+y4+"&z4="+z4;

window.open (urlwithcoord,"mywindow");
}
