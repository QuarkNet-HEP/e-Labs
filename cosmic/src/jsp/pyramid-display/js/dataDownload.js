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
	// Produce the same flattened array-of-strings output as original but with fewer allocations.
	var newData = [];
	for (var i = 0; i < data.length; i++) {
		var row = data[i];
		for (var j = 0; j < row.length; j++) {
			var cell = row[j];
			if (cell && typeof cell === 'object') {
				// collect keys and values manually (faster than Object.keys/values)
				var kParts = [];
				var vParts = [];
				for (var k in cell) {
					if (Object.prototype.hasOwnProperty.call(cell, k)) {
						kParts.push(k);
						vParts.push(cell[k]);
					}
				}
				// combine keys and values into a single comma-separated string (matches original coercion)
				var combined = '';
				if (kParts.length > 0) combined += kParts.join(',');
				if (vParts.length > 0) {
					if (combined.length > 0) combined += ',';
					combined += vParts.join(',');
				}
				newData.push(combined + "\n");
			} else {
				newData.push(String(cell) + "\n");
			}
		}
	}
	return newData;
}

function downloadArrayAsArray(data, filename, nestedLevels){
	// Build result pieces in an array then join once — faster than repeated string concatenation.
	var parts = [];
	if (nestedLevels == 1) {
		for (var i = 0; i < data.length; i++) {
			parts.push('[' + data[i].join(',') + '],\r\n');
		}
	} else if (nestedLevels == 2) {
		for (var i = 0; i < data.length; i++) {
			parts.push('[');
			var rowArray = data[i];
			for (var r = 0; r < rowArray.length; r++) {
				parts.push('[');
				var subRow = rowArray[r];
				for (var s = 0; s < subRow.length; s++) {
					parts.push(String(subRow[s]) + ',');
				}
				parts.push('],');
			}
			parts.push('],\r\n');
		}
	} else if (nestedLevels == 3) {
		for (var i = 0; i < data.length; i++) {
			parts.push('[');
			var rowArray = data[i];
			for (var r = 0; r < rowArray.length; r++) {
				parts.push('[');
				var subRow = rowArray[r];
				for (var s = 0; s < subRow.length; s++) {
					parts.push('[');
					var itemArray = subRow[s];
					for (var t = 0; t < itemArray.length; t++) {
						parts.push(String(itemArray[t]) + ',');
					}
					parts.push('],');
				}
				parts.push('],');
			}
			parts.push('],\r\n');
		}
	}
	var csvContent = parts.join('');
	const blob = new Blob([csvContent], { type: 'text/csv' });
	const url = URL.createObjectURL(blob);
	const a = document.createElement('a');
	a.href = url;
	a.download = filename;
	document.body.appendChild(a);
	a.click();
	document.body.removeChild(a);
	URL.revokeObjectURL(url); // Clean up the temporary URL
}

function downloadArray(data, filename){
	// Use Blob/URL method (more robust for large data); content preserved as before
	const csvString = data.join('\n');
	const blob = new Blob([csvString], { type: 'text/csv;charset=utf-8;' });
	const url = URL.createObjectURL(blob);
	const link = document.createElement('a');
	link.href = url;
	link.download = filename;
	document.body.appendChild(link);
	link.click();
	document.body.removeChild(link);
	URL.revokeObjectURL(url);
}

function download2DArray(data, filename) {
	var csvContent = checkForObjects(data);
	// Keep the original coercion behavior (array coerced to string when concatenated with prefix)
	const encodedUri = encodeURI("data:text/csv;charset=utf-8," + csvContent);
	const link = document.createElement("a");
	link.setAttribute("href", encodedUri);
	link.setAttribute("download", filename);
	document.body.appendChild(link); // Append to trigger download in some browsers
	link.click();
	document.body.removeChild(link); // Clean up
}