<!-- Hide script from old browsers, so they do not choke on it

var graphicsWin;
var previousResults;
var dataPage;

function popWindow(url, name, win_width, win_height) {

  var win;

  var win_stat   = 0;
  var win_menu   = 0;
  var win_tool   = 0;
  var win_locate = 1;
  var win_dir    = 0;
  var win_resize = 1;
  var win_scroll = 1;

  var options    = "toolbar="+ win_tool +",location="+ win_locate +",directories="+ win_dir +
    ",status="+ win_stat + ",menubar="+ win_menu +",resizeable="+ win_resize +
    ",scrollbars="+ win_scroll +",width="+ win_width +",height="+ win_height;

  win=window.open(url,name,options,false);
  win.window.focus();
  win.resizeTo(win_width,win_height);
  win.moveTo(0,0);

  return win;
}

function checkgSize() {
  if ( document.getData.gWidth.value > 1600 )
    document.getData.gWidth.value = 1600; 

  if ( document.getData.gHeight.value > 1200 )
    document.getData.gHeight.value = 1200;

  if ( document.getData.gHeight.value > 3*document.getData.gWidth.value/4 )
    document.getData.gHeight.value = 3*document.getData.gWidth.value/4;
}

function closePopUps() {
  if ( graphicsWin )
    graphicsWin.window.close();
  if ( previousResults )
    previousResults.window.close();
  if ( dataPage ) {
    dataPage.window.close();
  }
  if ( runData ) {
    runData.window.close();
  }
}

// Handle the oddities of a multiselect checkbox
function uncheckOthers( element ) {

  // If the user deselected it... fuggdaboutit
  if ( element.checked == false ) {
    element.checked = true;
    return;
  }

  var noBoxID = 0;
  var gtBoxID = 0;
  var ltBoxID = 0;
  var ctBoxID = parseInt(element.id/3, 10);
  var thisID  = parseInt(element.id,10);

  if ( element.value == 0 ) {            // The "None" box was just clicked

    gtBoxID = thisID + 1;
    ltBoxID = thisID + 2;

    document.getData.cuttype[gtBoxID].checked = false;
    document.getData.cuttype[ltBoxID].checked = false;
    //document.getData.cut[ctBoxID].disabled = true;

  } else if ( element.value == 1 ) {     // The ">" box was just clicked
    noBoxID = thisID - 1;
    ltBoxID = thisID + 1;

    document.getData.cuttype[noBoxID].checked = false;
    document.getData.cuttype[ltBoxID].checked = false;
    document.getData.cut[ctBoxID].disabled = false;

  } else if ( element.value == 2 ) {        // The "<" box was just clicked
    noBoxID = thisID - 2;
    gtBoxID = thisID - 1;

    document.getData.cuttype[noBoxID].checked = false;
    document.getData.cuttype[gtBoxID].checked = false;
    document.getData.cut[ctBoxID].disabled = false;
  }
  return;
}


// check for valid numeric strings in the cut boxes
function isNumeric(srcString, element) {
  var strValidChars = "0123456789.-";
  var strChar;
  var blnResult = true;

  if (srcString.length == 0) return false;

  // compare srcString to list of valid characters
  for (var i = 0; i < srcString.length && blnResult == true; i++) {
    strChar = srcString.charAt(i);
    if (strValidChars.indexOf(strChar) == -1) {
      blnResult = false;
    }
  }

  if ( !blnResult ) {
    element.value = "";
  }
  return blnResult;
}

// -->
