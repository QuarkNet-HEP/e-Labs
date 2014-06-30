//checking for new groups
function checkNewGroup(object, index) {
	setOption(index, "new");
	checkExists(object);
	checkGroupName(object);
}
//checking for selecting existing groups from the drop down
function checkExistingGroup(object, index){
	setOption(index, "existing");	
	checkMaxNumber(object, index);
}
//need to set if it is one or the other because the boxes/dropdown selection 
//does not get cleared and later we need to know which one it is
function setOption(index, type) {
	var name_option = document.getElementById("name_option"+index);
	if (name_option != null) {
		name_option.value = type;
	}	    		
}
//check if this newly entered name already exists as a group
function checkExists(object) {
	var messages = document.getElementById("messages");
	messages.innerHTML = "";
	var existingGroup = document.getElementsByClassName("existingGroups");
	for (var i = 0; i < existingGroup.length; i++) {
		if (object.value == existingGroup[i].name) {
			if (existingGroup[i].value < 4) {
    			messages.innerHTML = "<i>* "+object.value+" already exists, add your student to the group instead of trying to create a new one.</i>";
			} else {
				messages.innerHTML = "<i>* "+object.value+" exists and already has the maximum number of 4 students allowed per group. Please make a new group.</i>";
			}
		return false;
		}
	}
	return true;
}
//make sure the entered name does not have invalid characters.
function checkGroupName(object) {
	if (object != null) {
		var messages = document.getElementById("messages");
		if (object.value != "Group Name") {
			if (! /^[a-zA-Z0-9_-]+$/.test(object.value)) {
				var message = "Group Name contains invalid characters. Use any alphanumeric combination, dashes or underscores. No spaces.";
				messages.innerHTML = "<i>* "+message+"</i>";
				return false;
			}
		}
	}
	return true;
}
//when choosing a group from the dropdown, make sure new students can be added (max number allowed is 4)
function checkMaxNumber(object, index) {
	var messages = document.getElementById("messages");
	messages.innerHTML = "";
	var newGroupCounter = 0;
	for (var j = 0; j < 10; j++) {
		var newGroup = document.getElementById("res_name_chooser"+j);
		var name_option = document.getElementById("name_option"+index)
		if (newGroup != null && name_option.value == "existing") {
			if (newGroup.value == object.value) {
				newGroupCounter++;
			}
		}
	}
	var existingGroup = document.getElementsByClassName("existingGroups");
	for (var i = 0; i < existingGroup.length; i++) {
		if (object.value == existingGroup[i].name) {
    		var total_items = parseInt(existingGroup[i].value) + parseInt(newGroupCounter);
			if ( total_items > 4) {
				messages.innerHTML = "<i>* "+object.value+" exists and already has the maximum number of 4 students allowed per group. Please make a new group.</i>";
				return false;
			}
		}
	}       		
	return true;
} 
//check all before submitting
function checkEnteredData() {
	var allOK = true;
	var messages = document.getElementById("messages");
	messages.innerHTML = "";
	var existingGroup = document.getElementsByClassName("existingGroups");
	//loop through the records to see if there is a problem and cannot save
	for (var i = 0; i < 10; i++) {
		var type = document.getElementById("name_option"+i);
		if (type != null && type.value > "") {
			//check the newly created groups
			if (type.value == "new") {
				//check the names
				var newGroup = document.getElementById("res_name_text"+i);
				allOK = checkGroupName(newGroup);
				if (!allOK) return false;
				allOK = checkExists(newGroup);
				if (!allOK) return false;
				allOK = checkMaxNumber(newGroup, i);
				if (!allOK) return false;
			}
			//check the additions to existing groups
			if (type.value == "existing") {
				//check the names
				var newGroup = document.getElementById("res_name_chooser"+i);
				allOK = checkMaxNumber(newGroup, i);
				if (!allOK) return false;				
			}
		}
	}

	return allOK;
}
