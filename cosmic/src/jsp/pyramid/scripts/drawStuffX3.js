x = [];
y = [];
var geometry = [];
var subtractPedX; // Declare in the global scope
var subtractPedY;



// Function to process the data from the URL using fetch
function processData2(url) {
  return fetch(url)
    .then(function(response) {
      if (!response.ok) {
        throw new Error('Network response was not ok.');
      }
      return response.text();
    })
    .then(function(textData) {
      var df = Papa.parse(textData, { delimiter: /\s+/, header: false }).data;
      df = df.map(function(row) {
        return row.filter(function(cell) {
          return cell !== '';
        });
      }); // Filter out empty cells
      return df;
    })
    .catch(function(error) {
      console.error('Error fetching data:', error);
      return [];
    });
}


//------------------------------

// Function to process the data from the URL using fetch
url1 = 'https://raw.githubusercontent.com/QuarkNet-HEP/pyramid/1eb1981bb0acd91618cf99790c6656e1ced6db2c/Pyramid_FakeTracker_XY-views_Run3_non-ZeroSup.txt'
function processData(url1, overallArr) {
  return fetch(url1)
    .then(function(response) {
      if (!response.ok) {
        throw new Error('Network response was not ok.');
      }
      return response.text();
    })
    .then(function(content) {
      var lines = content.trim().split('\n').slice(8); // Skip first 8 rows
      var header = lines[0].trim().split(/\s+/); // Assuming the first line is the header

      var data = lines.slice(1).filter(function(line) {
        return line.trim() !== '';
      }).map(function(line) {
        var values = line.trim().split(/\s+/);
        for (var i = 0; i < header.length; i++) {
          if (values[i] === undefined) {
            values[i] = null; // Replace empty values with null
          }
        }
        return values;
      });

      var df = {
        data: data,
        shape: [data.length, header.length],
        index: Array.from({ length: data.length }, function(_, i) { return i; }),
        columns: header,
        T: function() {
          var transposed = this.data[0].map(function(_, columnIndex) {
            return this.data.map(function(row) {
              return row[columnIndex];
            });
          }, this);
          var transposedHeader = this.columns.map(function(_, i) {
            return this.data[0][i];
          }, this);
          this.data = transposed; // Exclude the header row

          return this;
        },
        shift: function(columnIndex, shiftAmount) {
          var columnData = this.data[columnIndex];

          var shiftedArray = columnData.slice(0); // Create a copy of the original array

          if (shiftAmount > 0) {
            for (var i = 0; i < shiftAmount; i++) {
              var element = shiftedArray.shift(); // Remove the first element and store it
              shiftedArray.push(element); // Add the element at the end of the array
            }
          } else if (shiftAmount < 0) {
            for (var i = 0; i < -shiftAmount; i++) {
              var element = shiftedArray.pop(); // Remove the last element and store it
              shiftedArray.unshift(element); // Add the element at the beginning of the array
            }
          }

          this.data[columnIndex] = shiftedArray;
          return this;
        },
        at: function(rowIndex, columnName) {
          var columnIndex;
          if (typeof columnName === 'string') {
            columnIndex = this.columns.indexOf(columnName);
          } else {
            columnIndex = columnName;
          }
          return this.data[rowIndex][columnIndex];
        },
        isna: function(num) {
          return num === null;
        }
      };

      for (var i = 0; i < df.shape[0]; i++) {
        if (df.isna(df.at(i, 4))) {
          df.shift(i, -2);
        }
      }

      for (var i = 1; i < df.shape[0]; i++) {
        if (df.isna(df.at(df.index[i], 'TrgID'))) {
          df.data[i][1] = df.at(i - 1, 'TrgID');
        }
      }

      var id = 0;
      var i = 0;
      while (id <= parseInt(df.at(df.index[df.shape[0] - 1], 'TrgID'))) {
        x.push(Array.from({ length: 3 }, function() {
          return Array.from({ length: 28 }, function() { return 0; });
        }));
        y.push(Array.from({ length: 3 }, function() {
          return Array.from({ length: 28 }, function() { return 0; });
        }));

        while (i < df.shape[0] && parseInt(df.at(df.index[i], 'TrgID')) == id) {
          var brd = parseFloat(df.at(df.index[i], 'Brd'));
          var ch = parseInt(df.at(df.index[i], 'Ch'));
          var lg = parseFloat(df.at(df.index[i], 'LG'));

          if (brd % 2 === 0) {
            x[id][Math.floor(brd / 2)][ch] = lg;
          } else {
            y[id][Math.floor((brd - 1) / 2)][ch] = lg;
          }

          i++;
        }

        id++;
      }
    //console.log("DATAMAN: ", x);
      var minPed = 10;

    subtractPedX = x;
    subtractPedY = y;

for (var x1 = 0; x1 < x.length; x1++) {
    for (var y1 = 0; y1 < x[0].length; y1++) {
        for (var z1 = 0; z1 < x[0][0].length; z1++) {
            subtractPedX[x1][y1][z1] = subtractPedX[x1][y1][z1] - parseInt(overallArr[x1][y1 * 2 + 1][z1]);
            if (subtractPedX[x1][y1][z1] < minPed) {
                subtractPedX[x1][y1][z1] = 0;
            }
        }
    }
}
    //console.log("subtractPedX", subtractPedX);
    //console.log("subtractPedY", subtractPedY);
    // GEOMETRY FILE READINGGGGGGGGGGGGGG
var url2 = 'https://raw.githubusercontent.com/QuarkNet-HEP/pyramid/main/GEOMETRY%20HEADER.txt';

var up;
// Fetch the content of the URL using the fetch API
fetch(url2)
  .then(function(response) {
    return response.text();
  })
  .then(function(data) {
    //console.log('Fetched data:', data); // Debug: Output the fetched data to the console

    // Process the data as needed
    var lines = data.split(/\r?\n/); // Use regex to handle different line endings
    //console.log(lines);
    
    var i = 11;
    while (i < lines.length && (lines[i].substring(0, 3) === 'ATH' || lines[i].substring(5, 10) === 'Layer')) {
      geometry.push(lines[i].split(/\s+/)); 
      //console.log('Parsed Geometry:', geometry); 
      i++;
    }
    globalThis.g = geometry;
    //processGeometryData(geometry, 1);

    // Use the geometry data as needed
    // Debug: Output the parsed geometry to the console
    // You can process the geometry data further or perform other operations here.
  })
  .catch(function(error) {
    console.error('Error fetching data:', error);
  });

    })
    .catch(function(error) {
      console.error('Error fetching data:', error);
      return [];
    });
  

}














//-----------------------



var url2 = 'https://raw.githubusercontent.com/QuarkNet-HEP/pyramid/main/Pedastalv2.txt';

fetch(url2)
  .then(function(response) {
    if (!response.ok) {
      throw new Error('Network response was not ok.');
    }
    return response.text();
  })
  .then(function(content) {
    var lines = content.trim().split('\n');
    var overallArr = [];
    var ped = [[], [], [], [], [], [], []];
    ped[0] = lines[0].trim().split(' ');

    var mod = 0;
    for (var r = 1; r < lines.length; r++) {
      if (lines[r].startsWith('ATH')) {
        overallArr.push(ped);
        ped = [[], [], [], [], [], [], []];
        ped[0] = lines[r].trim().split(' ');
        //console.log('!!!!!!!!!!!!!!!!!!!!!!!!');
        mod = 0;
      }
      if (lines[r].startsWith('Mod')) {
        r++;
        mod++;
      }
      ped[mod] = ped[mod].concat(lines[r].trim().split(' '));
      //console.log(lines[r].trim().split(' '));
    }
    overallArr.push(ped);
    //console.log(overallArr); // Overall array with processed data from the file
    processData(url1, overallArr);
  
    
  })
  .catch(function(error) {
    console.error('Error fetching data:', error);
  });


globalThis.retrieveGeometry = function () {
  return new Promise((resolve, reject) => {
    //console.log('rg');
    var url2 = 'https://raw.githubusercontent.com/QuarkNet-HEP/pyramid/main/GEOMETRY%20HEADER.txt';

    var up;
    // Fetch the content of the URL using the fetch API
    fetch(url2)
      .then(function(response) {
        return response.text();
      })
      .then(function(data) {
        //console.log('Fetched data:', data); // Debug: Output the fetched data to the console

        // Process the data as needed
        var lines = data.split(/\r?\n/); // Use regex to handle different line endings
        //console.log(lines);

        var i = 11;
        while (i < lines.length && (lines[i].substring(0, 3) === 'ATH' || lines[i].substring(5, 10) === 'Layer')) {
          geometry.push(lines[i].split(/\s+/)); 
          //console.log('Parsed Geometry:', geometry); 
          i++;
        }
        //console.log(geometry);
        globalThis.g = geometry;
        resolve();
        //processGeometryData(geometry, 1);

        // Use the geometry data as needed
        // Debug: Output the parsed geometry to the console
        // You can process the geometry data further or perform other operations here.
      })
      .catch(function(error) {
        console.error('Error fetching data:', error);
        reject();
      });
  });
}






























 














  






