<!-- Hide from old browsers

var runData;
function get_rundb() {
  var gwidth     = 600;
  var gheight    = 600;
  var win_stat   = 0;
  var win_menu   = 0;
  var win_tool   = 0;
  var win_locate = 0;
  var win_dir    = 0;
  var win_resize = 1;
  var win_scroll = 1;
  
  var win;

  var run_list = "";
  var first_run = true;
  for (var i=0; i<number_of_runs; i++) {
    if ( document.getData.run_number[i].selected == true ) {
      if ( first_run ) {
	run_list = "run=" + document.getData.run_number[i].value;
	first_run = false;
      } else
	run_list = run_list + "," + document.getData.run_number[i].value;
    }
  }
  var page = "get_run_data.php?" + run_list;

  var win_width  = (gwidth  <= 0.9*screen.width ) ? 1.1*gwidth  : 0.9*screen.width;
  var win_height = (gheight <= 0.9*screen.height) ? 1.1*gheight : 0.9*screen.height;

  var options    = "toolbar="+ win_tool +",location="+ win_locate +",directories="+ win_dir +
    ",status="+ win_stat + ",menubar="+ win_menu +",resizeable="+ win_resize +
    ",scrollbars="+ win_scroll;

  win=window.open(page,"runData",options,false);
  win.window.focus();
  win.moveTo(0,0);
  return win;
}

function select_muons() {


  // If all was previously selected... turn it off
  if ( document.getData.all_runs.checked ) {
    document.getData.all_runs.checked = false;
    select_all();
  }
  
  // Turn off any runs that are currently selected
  for ( var i=0; i<number_of_runs; i++ ) {
    document.getData.run_number[i].selected = false;
  }

  if ( document.getData.muon_runs.checked ) {
    var j = 0;
    for ( var i=0; i<number_of_runs; i++ ) {
      if ( muonRuns[j] == runList[i] ) {
	document.getData.run_number[i].selected = true;
	j++;
      }
    }
  } else {
    var j = 0;
    for ( var i=0; i<number_of_runs; i++ ) {
      if ( muonRuns[j] == runList[i] ) {
	document.getData.run_number[i].selected = false;
	j++;
      }
    }
  }
  getRunData();
  return true;
}

function select_pions() {

  // If all was previously selected... turn it off
  if ( document.getData.all_runs.checked ) {
    document.getData.all_runs.checked = false;
    select_all();
  }
  
  // Turn off any runs that are currently selected
  for ( var i=0; i<number_of_runs; i++ ) {
    document.getData.run_number[i].selected = false;
  }

  if ( document.getData.pion_runs.checked ){
    var j = 0;
    for ( var i=0; i<number_of_runs; i++ ) {
      if ( pionRuns[j] == runList[i] ) {
	document.getData.run_number[i].selected = true;
	j++;
      }
    }
  } else {
    var j = 0;
    for ( var i=0; i<number_of_runs; i++ ) {
      if ( pionRuns[j] == runList[i] ) {
	document.getData.run_number[i].selected = false;
	j++;
      }
    }
  }
  getRunData();
  return true;
}

function select_electrons() {

  // If all was previously selected... turn it off
  if ( document.getData.all_runs.checked ) {
    document.getData.all_runs.checked = false;
    select_all();
  }
  
  // Turn off any runs that are currently selected
  for ( var i=0; i<number_of_runs; i++ ) {
    document.getData.run_number[i].selected = false;
  }

  if ( document.getData.elec_runs.checked ){
    var j = 0;
    for ( var i=0; i<number_of_runs; i++ ) {
      if ( elecRuns[j] == runList[i] ) {
	document.getData.run_number[i].selected = true;
	j++;
      }
    }
  } else {
    var j = 0;
    for ( var i=0; i<number_of_runs; i++ ) {
      if ( elecRuns[j] == runList[i] ) {
	document.getData.run_number[i].selected = false;
	j++;
      }
    }
  }
  getRunData();
  return true;
}

function select_calib() {

  // If all was previously selected... turn it off
  if ( document.getData.all_runs.checked ) {
    document.getData.all_runs.checked = false;
    select_all();
  }
  
  // Turn off any runs that are currently selected
  for ( var i=0; i<number_of_runs; i++ ) {
    document.getData.run_number[i].selected = false;
  }

  if ( document.getData.cal_runs.checked ) {
    var j = 0;
    for ( var i=0; i<number_of_runs; i++ ) {
      if ( calRuns[j] == runList[i] ) {
	document.getData.run_number[i].selected = true;
	j++;
      }
    }
  } else {
    var j = 0;
    for ( var i=0; i<number_of_runs; i++ ) {
      if ( calRuns[j] == runList[i] ) {
	document.getData.run_number[i].selected = false;
	j++;
      }
    }
  }
  getRunData();
  return true;
}

function select_all() {
  if ( document.getData.all_runs.checked ) {
    document.getData.cal_runs.checked = false;
    document.getData.elec_runs.checked = false;
    document.getData.pion_runs.checked = false;
    document.getData.muon_runs.checked = false;
    for ( var i=0; i<number_of_runs; i++ ) {
      document.getData.run_number[i].selected = true;
    }
  } else {
        for ( var i=0; i<number_of_runs; i++ ) {
      document.getData.run_number[i].selected = false;
    }
  }
  getRunData();
  return true;
}

function select_single_run() {
  // Turn off the run type buttons
  document.getData.cal_runs.checked = false;
  document.getData.elec_runs.checked = false;
  document.getData.pion_runs.checked = false;
  document.getData.muon_runs.checked = false;
  document.getData.all_runs.checked = false;

  getRunData();
  return true;
}
//-->
