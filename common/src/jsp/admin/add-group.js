function validateForm() {
	var messages = document.getElementById("messages");
	var stateAbbrevFromDD = "";
	//STATE CHECKINGS
	//check new state, allow only letters, spaces, periods and dashes
	var stateNew = document.getElementById("stateNew");
	var stateAbbrev = document.getElementById("stateAbbrev");
	//console.log(stateAbbrev.value);
	if (stateNew.value != null && stateNew.value != "") {
		var pattern = /^[ A-Za-z_.-]*$/;
		if (! pattern.test(stateNew.value)) {
			messages.innerHTML = "*Please only use letters, spaces, periods, and dashes for your state.";
			stateNew.value = "";
			return false;
		} 
		//make sure state doesn't already exist
		for(var i = 0, opts = document.getElementById("state").options; i < opts.length; ++i)
			   if( opts[i].value === stateNew.value.toUpperCase() ) {
				  messages.innerHTML = stateNew.value + " is already in the pull-down list.";
				  stateNew.value = "";
				  return false;
			}
		//checks for the stateAbbreviation
		var stateAbbrev = document.getElementById("stateAbbrev");
		if ((stateAbbrev.value == null || stateAbbrev.value == "") && stateNew.value != "") {
				messages.innerHTML = "Please enter an abbreviation for the state/country.";
				return false;
		}
		if ((stateAbbrev != null || stateAbbrev.value != "") && stateNew.value == "") {
			messages.innerHTML = "Please enter a name for the state/country.";
			return false;
		}
		//check if the state abbreviation already exists
		var abbrev = document.getElementsByName("stateAbbreviation");
		if (stateAbbrev.value != null || stateAbbrev.value != "") {
			for (var i = 0; i < abbrev.length; i++) {
				if (abbrev[i].value == stateAbbrev.value.toUpperCase()) {
					messages.innerHTML = "State abbreviation " + stateAbbrev.value + " is already in the pull-down list.";
					stateAbbrev.value = "";
					return false;
				}
			}
		}
		//check if user selected type
		var stateType = document.getElementById("stateType");
		if (stateType.value != null && stateType.value == "0") {
			messages.innerHTML = "Please enter a state type for the state/country.";
			return false;
		}
	}
	if (stateNew.value == null || stateNew.value == "") {
		var state = document.getElementById("state");
		if (state.value == null || state.value == "") {
			messages.innerHTML = "Please select or enter a state/country.";
			return false;
		}
	}
	
	//CITY CHECKINGS
	var cityNew = document.getElementById("cityNew");
	if (cityNew.value != null && cityNew.value != "") {
		var pattern = /^[ A-Za-z_.-]*$/;
		if (! pattern.test(cityNew.value)) {
			messages.innerHTML = "*Please only use letters, spaces, periods, and dashes for your city.";
			cityNew.value="";
			return false;
		} 
		//make sure city doesn't already exist
		var state = document.getElementById("state");
		if (state.value != null && state.value != "") {
			stateAbbrevFromDD = state.options[state.selectedIndex].text;
			var citiesInState = document.getElementsByName("cityIn"+stateAbbrevFromDD);
			for(var i = 0; i < citiesInState.length; i++) {
				var clean = citiesInState[i].value.replace(/[\[\]']+/g,'');
				var parts = clean.split(",");
				if( parts[2].trim().toUpperCase() === cityNew.value.trim().toUpperCase() ) {
				  messages.innerHTML = cityNew.value + " city is already in the pull-down list.";
				cityNew.value="";
				  return false;
				}
			}
		}
	}	
	if (cityNew.value == null || cityNew.value == "") {
		var city = document.getElementById("city");
		if (city.value == null || city.value == "") {
			messages.innerHTML = "Please select or enter a city.";
			return false;
		}
	}

	//SCHOOL CHECKINGS
	var schoolNew = document.getElementById("schoolNew");
	if (schoolNew.value != null && schoolNew.value != "") {
		var pattern = /^[ A-Za-z_.-]*$/;
		if (! pattern.test(schoolNew.value)) {
			messages.innerHTML = "*Please only use letters, spaces, periods, and dashes for your school.";
			schoolNew.value = "";
			return false;
		} 
		//make sure school doesn't already exist
		var city = document.getElementById("city");
		var state = document.getElementById("state");
		if (state != null && state != "") {
			stateAbbrevFromDD = state.options[state.selectedIndex].text;	
			if (stateAbbrevFromDD != "") {
				cityNameFromDD = city.options[city.selectedIndex].text;
				if (cityNameFromDD != null && cityNameFromDD != "") {
					var schoolInStateCity = document.getElementsByName("schoolIn"+stateAbbrevFromDD+cityNameFromDD);
					for(var i = 0; i < schoolInStateCity.length; i++) {
						var clean = schoolInStateCity[i].value.replace(/[\[\]']+/g,'');
						var parts = clean.split(",");
						if( parts[3].trim().toUpperCase() === schoolNew.value.trim().toUpperCase() ) {
							messages.innerHTML = schoolNew.value + " school is already in the pull-down list.";
							schoolNew.value = "";
							return false;
						}
					}
				}
			}
		}
	}	
	if (schoolNew.value == null || schoolNew.value == "") {
		var school = document.getElementById("school");
		if (school.value == null || school.value == "") {
			messages.innerHTML = "Please select or enter a school.";
			return false;
		}
	}
	
	//TEACHER CHECKINGS
	var teacherNew = document.getElementById("teacherNew");
	if (teacherNew.value != null && teacherNew.value != "") {
		var pattern = /^[ A-Za-z_.-]*$/;
		if (! pattern.test(teacherNew.value)) {
			messages.innerHTML = "*Please only use letters, spaces, periods, and dashes for your teacher.";
			teacherNew.value = "";
			return false;
		} 
		//make sure teacher doesn't already exist
		var state = document.getElementById("state");
		var city = document.getElementById("city");
		var school = document.getElementById("school");
		if (state != null && state != "") {
			stateAbbrevFromDD = state.options[state.selectedIndex].text;	
			if (stateAbbrevFromDD != "") {
				cityNameFromDD = city.options[city.selectedIndex].text;
				if (cityNameFromDD != null && cityNameFromDD != "") {
					schoolNameFromDD = school.options[school.selectedIndex].text;
					if (schoolNameFromDD != null && schoolNameFromDD != "") {
						var teacherInStateCitySchool = document.getElementsByName("teacherIn"+stateAbbrevFromDD+cityNameFromDD+schoolNameFromDD);
						for(var i = 0; i < teacherInStateCitySchool.length; i++) {
							var clean = teacherInStateCitySchool[i].value.replace(/[\[\]']+/g,'');
							var parts = clean.split(",");
							if( parts[1].trim().toUpperCase() === teacherNew.value.trim().toUpperCase() ) {
								messages.innerHTML = teacherNew.value + " is already in the pull-down list.";
								teacherNew.value = "";
								return false;
							}
						}
					}
					
				}
			}
		}
	}
	if (teacherNew.value == null || teacherNew.value == "") {
		var teacher = document.getElementById("teacher");
		if (teacher.value == null || teacher.value == "") {
			messages.innerHTML = "Please select or enter a teacher/leader.";
			return false;
		}
	}	
	//GROUP CHECKINGS
	var groupNew = document.getElementById("researchGroup");
	if (groupNew.value != null && groupNew.value != "") {
		var pattern = /^[A-Za-z0-9_]*$/;
		if (! pattern.test(groupNew.value)) {
			messages.innerHTML = "*Please go back and enter a group name with ONLY alpha-numeric characters.";
			groupNew.value = "";
			return false;
		}
		var groups = document.getElementsByName("groups");
		for(var i = 0; i < groups.length; i++) {
			var clean = groups[i].value.replace(/[\[\]']+/g,'');
			var parts = clean.split(",");
			if( parts[1].trim().toUpperCase() === groupNew.value.trim().toUpperCase() ) {
				messages.innerHTML = " Your username/groupname is already taken. Please go back and choose a different name.";
				groupNew.value = "";
				return false;
			}
		}	
	}
	if (groupNew.value == null || groupNew.value == "") {
		messages.innerHTML = "Please select or enter a group name.";
		return false;
	}	
	
	//DETECTOR STRING CHECKING
	var detectorString = document.getElementById("detectorString");
	if (detectorString.value != null && detectorString.value != "") {
		var pattern = /^[0-9]+(,[0-9]+)*$/;
		if (! pattern.test(detectorString.value)) {
			messages.innerHTML = "*Please go back and enter a detector (or detectors) as a comma delimited list.";
			detectorString.value = "";
			return false;			
		}
	}
	
	//PROJECT CHECKING
	var researchProject = document.getElementById("researchProject");
	if (researchProject.value == null || researchProject.value == "") {
		messages.innerHTML = "Please select a project.";
		return false;
	}	
	
	//ROLE CHECKING
	var role = document.getElementById("groupRole");
	if (role.value == null || role.value == "") {
		messages.innerHTML = "Please select a role.";
		return false;
	}	
	
	//PASSWORD CHECKING
	var password1 = document.getElementById("passwd1");
	var password2 = document.getElementById("passwd2");
	if (password1.value != null && password2.value != null) {
		if (password1.value != password2.value) {
			messages.innerHTML = "*Please go back - Your passwords do not match!.";
			password1.value = "";
			password2.value = "";
			return false;			
		}
		var pattern = /".*[\"'\\(\\)*].*"/;
		if (pattern.test(password1.value)) {
			messsages.innerHTML = "Please go back and do not enter a password with any characters: *\"()'";
			password1.value = "";
			password2.value = "";
			return false;
		}
	}
	if (password1.value == "") {
		messages.innerHTML = "*Please go back and enter a password.";
		password1.value = "";
		password2.value = "";
		return false;						
	}
	
	return true;
}

$(document).ready(function() {
	var stateAbbrev = "";
	var city = "";
	var school = "";
	$("#state").bind("change", function() {
	    stateAbbrev = $(this).find("option:selected").attr("name");
	    var cities = document.getElementsByName("cityIn"+stateAbbrev);
	    document.getElementById("stateNew").value = "";
	    document.getElementById("stateAbbrev").value = "";
	    document.getElementById("stateType").value = "0";
	    createOption(document.getElementById("city"), cities, 2);
	});
	$("#city").bind("change", function() {
	    city = $(this).find("option:selected").attr("name");
	    var schools = document.getElementsByName("schoolIn"+stateAbbrev+city.trim());
	    document.getElementById("cityNew").value = "";
	    createOption(document.getElementById("school"), schools, 3);
	});
	$("#school").bind("change", function() {
	    school = $(this).find("option:selected").attr("name");
	    var teachers = document.getElementsByName("teacherIn"+stateAbbrev+city.trim()+school.trim());
	    document.getElementById("schoolNew").value="";
	    createOption(document.getElementById("teacher"), teachers, 1);
	});
	$("#teacher").bind("change", function() {
	    document.getElementById("teacherNew").value="";
	});
 });

function createOption(ddl, arr, nameIndex) {
	ddl.options.length=0;
	var opt = document.createElement('option');
	opt.value = "";
	opt.text = "";
	ddl.options.add(opt);
	for (var i = 0; i < arr.length; i++) {
		var opt = document.createElement('option');
		var clean = arr[i].value.replace(/[\[\]']+/g,'');
		var values = clean.split(",");
		opt.value = values[0];
		var name = document.createAttribute("name");
		name.value = values[nameIndex];
		opt.text = values[nameIndex];
		opt.setAttributeNode(name);
		ddl.options.add(opt);
	}
}
