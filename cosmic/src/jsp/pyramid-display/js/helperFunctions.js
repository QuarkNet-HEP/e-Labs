/*
	Edit Peronja 12/10/2025: The next few functions are used to populate the spinners in the 2D display
*/
let timeElapsed = "";
let initialTime = "";
let endTime = "";

// Function to populate the datalist dynamically
function populateDatalist(whichList, arr) {
     const datalist = document.getElementById(whichList);
     arr.forEach(value => {
         const option = document.createElement('option');
	     option.value = value;
     });
}

// Function to populate the 6-plane spinner
function populateDropdownSix() {
	populateDatalist('6planevaluesList', globalThis.eventFilter6);
	let oldIndex = 0; // Start with the first value
	const inputElement = document.getElementById('quantity6');
	inputElement.value = globalThis.eventFilter6[oldIndex]; // Set initial value
	inputElement.addEventListener('input', handleInputChange);
	function handleInputChange(event) {
	    const input = event.target;
	    let goalValue = parseInt(input.value, 10);
	    let newIndex = oldIndex;
	    // Determine the direction of change and update index
	    if (goalValue > globalThis.eventFilter6[oldIndex]) {
	        newIndex++;
	        // Keep index within bounds
	        if (newIndex >= globalThis.eventFilter6.length) newIndex = globalThis.eventFilter6.length - 1;
	    } else if (goalValue < globalThis.eventFilter6[oldIndex]) {
	        newIndex--;
	        // Keep index within bounds
	        if (newIndex < 0) newIndex = 0;
	    }
	    
	    // Update the input value to the corresponding list value
	    oldIndex = newIndex;
	    input.value = globalThis.eventFilter6[newIndex];
		if (is_numeric(input.value)) {
			if (input.value > 0) {
			  draw(input.value-1);
			} 
		}
	}
}//end of populateDropdownSix

// Function to populate the 5-plane spinner
function populateDropdownFive() {
	populateDatalist('5planevaluesList', globalThis.eventFilter5);
	let oldIndex = 0; // Start with the first value
	const inputElement = document.getElementById('quantity5');
	inputElement.value = globalThis.eventFilter5[oldIndex]; // Set initial value
	// Use the 'input' event to capture changes from both typing and spinner buttons
	inputElement.addEventListener('input', handleInputChange);
	// Function to handle input changes (spinner clicks or manual entry)	
	function handleInputChange(event) {
	    const input = event.target;
	    let goalValue = parseInt(input.value, 10);
	    let newIndex = oldIndex;

	    // Determine the direction of change and update index
	    if (goalValue > globalThis.eventFilter5[oldIndex]) {
	        newIndex++;
	        // Keep index within bounds
	        if (newIndex >= globalThis.eventFilter5.length) newIndex = globalThis.eventFilter5.length - 1;
	    } else if (goalValue < globalThis.eventFilter5[oldIndex]) {
	        newIndex--;
	        // Keep index within bounds
	        if (newIndex < 0) newIndex = 0;
	    }
	    
	    // Update the input value to the corresponding list value
	    oldIndex = newIndex;
	    input.value = globalThis.eventFilter5[newIndex];
		if (is_numeric(input.value)) {
			if (input.value > 0) {
			  draw(input.value-1);
			} 
		}
	}	
}//end of populateDropdownFive 
 
// Function to populate the 4-plane spinner
function populateDropdownFour() {
	populateDatalist('4planevaluesList', globalThis.eventFilter4);
	let oldIndex = 0; // Start with the first value
	// Function to handle input changes (spinner clicks or manual entry)
	const inputElement = document.getElementById('quantity4');
	inputElement.value = globalThis.eventFilter4[oldIndex]; // Set initial value
	// Use the 'input' event to capture changes from both typing and spinner buttons
	inputElement.addEventListener('input', handleInputChange);
	function handleInputChange(event) {
	    const input = event.target;
	    let goalValue = parseInt(input.value, 10);
	    let newIndex = oldIndex;

	    // Determine the direction of change and update index
	    if (goalValue > globalThis.eventFilter4[oldIndex]) {
	        newIndex++;
	        // Keep index within bounds
	        if (newIndex >= globalThis.eventFilter4.length) newIndex = globalThis.eventFilter4.length - 1;
	    } else if (goalValue < globalThis.eventFilter4[oldIndex]) {
	        newIndex--;
	        // Keep index within bounds
	        if (newIndex < 0) newIndex = 0;
	    }
	    
	    // Update the input value to the corresponding list value
	    oldIndex = newIndex;
	    input.value = globalThis.eventFilter4[newIndex];
		if (is_numeric(input.value)) {
			if (input.value > 0) {
			  draw(input.value-1);
			} 
		}
	}	
}//end of populateDropdownFour

// Display errors
function print(string) { throw new Error(string); }

// Calculate how much time elapsed between date arguments
function calculateProcessTime(endDate, startDate) {
	var seconds = (endDate.getTime() - startDate.getTime()) / 1000;
    return seconds;
}//end of calculateProcessTime

// Determine if a variable is numeric
function isNumeric(num){
  return !isNaN(num);
}//end of isNumeric

// Another function call to determine a number
function is_numeric(str){
    return /^\d+$/.test(str);
}//end of is_numeric

// Helper function to determine if line starts with a number
function startsWithNumber(str) {
	return /^\d+\b/.test(str);
}//end of startsWithNumber

let months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
function parseFileDate(d, t) {
	let day = d.substring(0,2);
	let month = d.substring(2,5);
	let M = months.indexOf(month);
	let y = d.substring(5,9);
	let [h,m,s] = t.split(/[- :]/);
	let newDate =  new Date(parseInt(y),M,parseInt(d),parseInt(h),parseInt(m),parseInt(s));
	return newDate;
}// end of parseFileDate



// Possibly use in the future to cache read files
const cache = {};

function fetchData(url) {
  if (cache[url]) {
	console.log(cache);
    return cache[url];  // Return cached data
  }
  return fetch(url)
    .then(response => response.text())
    .then(data => {
      cache[url] = data;  // Store data in memory for future use
	  console.log(cache);
      return data;
    });
}	
