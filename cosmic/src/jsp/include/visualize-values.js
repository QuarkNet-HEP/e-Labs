function VisualizeValues()
{
var x1 = document.getElementById("myForm").elements.namedItem("chan1X").value;
var y1 = document.getElementById("myForm").elements.namedItem("chan1Y").value;
var z1 = document.getElementById("myForm").elements.namedItem("chan1Z").value;

var x2 = document.getElementById("myForm").elements.namedItem("chan2X").value;
var y2 = document.getElementById("myForm").elements.namedItem("chan2Y").value;
var z2 = document.getElementById("myForm").elements.namedItem("chan2Z").value;

var x3 = document.getElementById("myForm").elements.namedItem("chan3X").value;
var y3 = document.getElementById("myForm").elements.namedItem("chan3Y").value;
var z3 = document.getElementById("myForm").elements.namedItem("chan3Z").value;

var x4 = document.getElementById("myForm").elements.namedItem("chan4X").value;
var y4 = document.getElementById("myForm").elements.namedItem("chan4Y").value;
var z4 = document.getElementById("myForm").elements.namedItem("chan4Z").value;

var urlwithcoord = "visualize.jsp?x1="+x1+"&y1="+y1+"&z1="+z1;
var urlwithcoord = urlwithcoord+"&x2="+x2+"&y2="+y2+"&z2="+z2;
var urlwithcoord = urlwithcoord+"&x3="+x3+"&y3="+y3+"&z3="+z3;
var urlwithcoord = urlwithcoord+"&x4="+x4+"&y4="+y4+"&z4="+z4;

window.open (urlwithcoord,"mywindow");
}
