function downloadXYdata(data, filename) {
    const csvRows = [];
    const headers = Object.keys(data[0]);
    csvRows.push(headers.join(','));
    for (const row of data) {
        const values = headers.map(header => {
            const escapedValue = String(row[header]).replace(/"/g, '""'); // Escape double quotes
            return `"${escapedValue}"`; // Enclose values in double quotes
        });
        csvRows.push(values.join(','));
    }
    const csvString = csvRows.join('\n');
    const blob = new Blob([csvString], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url); // Clean up the URL object
}

function checkForObjects(data) {
	var newData = [];
	var newDataLine = [];
	for (var i = 0; i < data.length; i++) {
		for (var j = 0; j < data[i].length; j++) {
			newDataLine = [];
			if (typeof data[i][j] === 'object') {
				var keys = Object.keys(data[i][j]);
				var values = Object.values(data[i][j]);
				if (keys.length > 0) {
					newDataLine.push(keys.join(','));
				}
				if (values.length > 0) {
					newDataLine.push(values.join(','));
				}			
			 } else {
				newDataLine.push(data[i][j]);
			 }
			 newData.push(newDataLine+"\n");
		}
	}
	return newData;
}
function downloadArray(data, filename){
	const csvContent = data.join('\n'); 
	const encodedUri = encodeURI("data:text/csv;charset=utf-8," + csvContent);	
	const link = document.createElement("a");
	link.setAttribute("href", encodedUri);
	link.setAttribute("download", filename);
	document.body.appendChild(link); // Append to trigger download in some browsers
	link.click();
	document.body.removeChild(link); // Clean up
}

function download2DArray(data, filename) {
	var csvContent = checkForObjects(data);	
	//console.log(csvContent);
	//let csvContent = newData.map(e => e.join(",")).join("\n");
	const encodedUri = encodeURI("data:text/csv;charset=utf-8," + csvContent);	
	const link = document.createElement("a");
	link.setAttribute("href", encodedUri);
	link.setAttribute("download", filename);
	document.body.appendChild(link); // Append to trigger download in some browsers
	link.click();
	document.body.removeChild(link); // Clean up
}
