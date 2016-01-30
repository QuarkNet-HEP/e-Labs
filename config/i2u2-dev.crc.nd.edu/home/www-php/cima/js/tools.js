var addedID={};
var index=0;
var mod="name";

function connect(array){
	  var str = "";
	  for(var i=0; i<index; i++){
	  	str+=""+array[i];
		if(i!=index-1){
			str+=" ";
		}
	  }
	  //str+=""+array[0];
	  return str;
}

function postIng() {
	$.ajax({
	type: "POST",
	url: "php/Ingres.php",
	data: {
	keyword : document.getElementById("IngSearch").value,
	filter: connect(addedID)
	},
	success: function( data ) {
	$( "#SresIng" ).html( data );
	}
	});
}

							
function DisplayAdded() {
	$.ajax({
	type: "POST",
	url: "php/addedIng.php",
	data: {
	ids : connect(addedID) },
	success: function( data ) {
	$( "#addedIng" ).html( data );
	}
	});
}

function add(id){
	addedID[index]=id;
	index=index+1;
	DisplayAdded();
	postIng();
	lookForCocktails();


}

function rmv(id){
	var rm=false;
	for(var i=0;i<index;i++){
		if(rm){
			addedID[i-1]=addedID[i];
		}
		if(id==addedID[i]){
			rm=true;
		}
	}
	index=index-1;
	DisplayAdded();
	postIng();
	lookForCocktails();
}
	
function radioSelect(key){
	if(key=="name"){
		$( "#selectedMod" ).html( "nur Cocktailname" );
		mod=key;
	}else if(key=="min"){
		$( "#selectedMod" ).html( "Zutatmodus" );
		mod=key;
	}else if(key=="max"){
		$( "#selectedMod" ).html( "Barmodus" );
		mod=key;
	}
}

function lookForCocktails() {
	$.ajax({
	type: "POST",
	url: "php/CocktailRes.php",
	data: {
	name: document.getElementById("CocktailName").value,
	ing: connect(addedID),
	modus: mod},
	success: function( data ) {
	$( "#final" ).html( data );
	}
	});
}

