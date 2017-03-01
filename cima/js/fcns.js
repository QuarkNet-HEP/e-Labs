var Mmass=0;
function printMass(mass){
	if(Mmass!=0){
		mass=Mmass;
	}
	var HiggsChecked=document.getElementById("H").checked;
	//var ZChecked=document.getElementById("Z").checked;
	var NPChecked=document.getElementById("NP").checked;

	// Code to have an event's mass written to the particle selection
	// panel's mass entry input box. Unused as of Feb2017 - JG
	/*
	if(HiggsChecked){
			//$("#massEntry").prop("value",mass);
			$("#massEntry").prop("value"," ");
	} else if(!HiggsChecked){
			$("#massEntry").prop("value"," ");
	} else if(NPChecked){
			$("#massEntry").prop("value"," ");
	} else{
			$("#massEntry").prop("value"," ");
	}
	*/
}

function check(state){
  // check(primary)=true if a final state box is checked
  // check(final)=true if a primary state box is checked
	// Did someone get these backwards?
	if(state=="primary"){
		return (document.getElementById("e").checked ||
						document.getElementById("mu").checked);
	}
	if(state=="final"){
		return (document.getElementById("H").checked ||
						document.getElementById("Z").checked ||
						document.getElementById("NP").checked ||
						document.getElementById("W").checked ||
						document.getElementById("Wp").checked ||
						document.getElementById("W-").checked ||
						document.getElementById("Zoo").checked);
	}
}

function SelP(element,mass){
	var prim=false;
	var fin=false;

	checked=element.checked;
	// If a final state element has been checked,	
	if(element.id=="mu" || element.id=="e"){
		var arr=["mu","e"];
		prim=checked; // true if e or mu (final state) checked
		fin=check("final"); // true if primary state box checked
		// I think whoever wrote this switched "primary" and "final" in a
		//   way that cancels out :) JG
	}
	// Otherwise, a primary state element will have been checked
	else{
		// If H or Zoo are selected as primary, uncheck and disable
		// the final state selection boxes
		if(element.id=="Zoo" || element.id=="H"){
			$("#mu").prop("checked",false);
			$("#e").prop("checked",false);
			$("#mu").prop("disabled",checked);
			$("#e").prop("disabled",checked);
			prim=checked; // true if e or mu checked
		}else{
			prim=check("primary"); // true if e or mu checked
		}

		//if(element.id=="Z"){
		// If NP is selected as primary, enable the massEntry input box
		//   and change styling
		if(element.id=="NP"){
			$("#massEntry").prop("disabled",!checked);
			if(checked){
				document.getElementById('massInput').style.color = 'black';
				document.getElementById('Znote').style.fontWeight = 'bold';
			} else if (!checked){
				document.getElementById('massInput').style.color = 'grey';
				document.getElementById('Znote').style.fontWeight = 'normal';
			}
		}
			
		//printMass(mass);
		//var arr=["H","W","W-","Wp","Z","Zoo"];
		var arr=["H","W","W-","Wp","NP","Zoo"];
		fin=checked; // true if e or mu checked
	}
	for(var i=0;i<arr.length;i++){
		// For everything in arr[] that *isn't* the selected element,
		//   disable it
		if(element.id!=arr[i]){
			//$("#"+arr[i]).prop("checked",false);
			$("#"+arr[i]).prop("disabled",checked);
		}
		// Nonetheless, if mu is checked, e does not disable, and vice-versa
	}
	if(prim && fin){
		$("#next").prop("disabled", false);
	}else{
		$("#next").prop("disabled", true);
	}

}

function GetTables(){
	var sel=document.getElementById("Eselect");
	var list=new Array;
	var k=0
	  for (var i = 0; i < sel.options.length; i++) {
   		  if(sel.options[i].selected ==true){
			list[k]=sel.options[i].value;
			k++;
      		}
  	}
	$.ajax({
	type: "POST",
	url: "showTables.php",
	data: {
	MCE : list.join(),
	source: "Backend"},
	success: function( data ) {
	$( "#tables" ).html( data );
	}
	});

	$.ajax({
	type: "POST",
	url: "showNG.php",
	data: {
	MCE : list.join() },
	success: function( data ) {
	$( "#NG" ).html( data );
	}
	});

}


function PostGroups(){
	var selB=document.getElementById("BTables");
	var selF=document.getElementById("Ftables");
	var list=new Array;
	var k=0
	 for (var i = 0; i < selB.options.length; i++) {
   		  if(selB.options[i].selected){
			list[k]=selB.options[i].value;
			k++;
      		}
  	}
	 for (var i = 0; i < selF.options.length; i++) {
   		  if(selF.options[i].selected){
			list[k]=selF.options[i].value;
			k++;
      		}
  	}
	
	$.ajax({
	type: "POST",
	url: "showGroups.php",
	data: {
	tables : list.join(),
	source : "Backend" },
	success: function( data ) {
	$( "#bg" ).html( data );
	}
	});

}
function showdel(element){
	//alert(elstr);
	element.style.backgroundColor = "#AAFFAA";
	elstr="del-"+element.id;
	$( "#"+elstr ).html("<span class='glyphicon glyphicon-pencil'></span> edit (double click)");
}

function nshowdel(element){

	element.style.backgroundColor = "white";
	var elstr="del-"+element.id;
	$( "#"+elstr ).html("");

}

function OverCol(element){
	if(!(selectedE && element==selectedE)&& !(selectedT && element==selectedT)){
		element.style.backgroundColor = "#AAAAFF";
	}
}
var selectedE;
var selectedT;
var selectedG;

function OffCol(element){
	if(!(selectedE && element==selectedE)&& !(selectedT && element==selectedT)&&!(selectedG && element==selectedG)){
		element.style.backgroundColor = "white";
	}
}


function EvSel(element){
	element.style.backgroundColor = "#AAFFAA";
	if(selectedE && element!=selectedE){
		selectedE.style.backgroundColor = "white";
		$( "#Group").html("");
	}
	
	if(element!=selectedE){
		$.ajax({
		type: "POST",
		url: "showTables.php",
		data: {
		MCE : element.id,
		source: "index" },
		success: function( data ) {
		$( "#Tab" ).html( data );
		}
		});
	}

	selectedE=element;

}

function TSel(element){
	element.style.backgroundColor = "#AAFFAA";
	if(selectedT && element!=selectedT){
		selectedT.style.backgroundColor = "white";
	}
	selectedT=element;

	$.ajax({
	type: "POST",
	url: "showGroups.php",
	data: {
	tables : element.id,
	source: "index" },
	success: function( data ) {
	$( "#Group" ).html( data );
	}
	});
}

function GSel(element){

	$.ajax({
	type: "POST",
	url: "sendIndData.php",
	data: {
	SE : selectedE.id,
	ST : selectedT.id,
	SG : element.id},
	success: function() {
	window.location.href = "fillOut.php";
	}
	});
}


function del(element){
	var cs=element.childNodes
	var checked=cs[5].innerHTML.split(";");
	var mass=cs[7].innerHTML;
	 $.ajax({
	type: "POST",
	url: "delE.php",
	data: {
	row : element.id
	},
	success: function( ) {
	$( "#"+element.id ).html( "" );
	}
	});

	$(":checkbox").prop("disabled",false);
//		var allC=["e","mu","W","Wp","W-","Z","H","Zoo"];
	var allC=["e","mu","W","Wp","W-","NP","H","Zoo"];
	for(var i=0;i<allC.length;i++){
		    document.getElementById(allC[i]).checked = false;
	}
	sel=document.getElementById("EvSelOver");
	var nopt=document.createElement("option");
	nopt.text=$.trim(cs[1].innerHTML);
	nopt.value=parseInt($.trim(cs[1].innerHTML))+(parseInt(group)-1)*100;
	nopt.selected=true;
	sel.add(nopt,sel[0]);
	$("#Eventid").html($.trim(cs[3].innerHTML));

	var s=massGlobal.split(";");
	for(var i=0;i<s.length;i++){
		var temp=s[i].split(":");
		if(parseInt(temp[0])==parseInt(element.id)){
			Mmass=temp[1];

		}
	}


	if(checked && $.trim(checked[0])!=""){
		for(var i=0;i<checked.length;i++){
			    var temp = $.trim(checked[i]);
			    document.getElementById(temp).checked = true;
			    SelP(document.getElementById(temp),0);
		}
	}
	$("#fedit").prop("disabled",true);
}
