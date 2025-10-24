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

function downloadArray(data, filename) {
	const csvContent = data.join('\n'); 
	const encodedUri = encodeURI("data:text/csv;charset=utf-8," + csvContent);	
	const link = document.createElement("a");
	link.setAttribute("href", encodedUri);
	link.setAttribute("download", filename);
	document.body.appendChild(link); // Append to trigger download in some browsers
	link.click();
	document.body.removeChild(link); // Clean up
}
