<?php

// Make sure we've got a path to the saved URL so we can rebuild the call
if ( !isset($path) ) {
  if ( isset($_GET['path']) ) {
    $path = $_GET['path'];
  } else if ( isset($argv) ) {
    for ( $i=0; $i<sizeof($argv); $i++ ) {
      $temp = explode("=", $argv[$i]);
      if ( strtolower($temp[0]) == "path" ) {
	$path = $temp[1];
      }
    }
  }
}

if ( !isset($path) ) {
  exit;
}

function root2hex($rColor) {

  // Take a ROOT color index and convert it to an HTML hex color value
  if ( $rColor == 2 ) {
    return '#FF0000'; # Red
  } else if ( $rColor == 3 ) {
    return '#00FF00'; # Green
  } else if ( $rColor == 4 ) {
    return '#0000FF'; # Blue
  } else if ( $rColor == 1 ) {
    return '#000000'; # Black
  } else if ( $rColor == 10 ) {
    return '#FFFFFF'; # White
  } else if ( $rColor == 5 ) {
    return '#FFFF00'; # Yellow
  } else if ( $rColor == 6 ) {
    return '#FF00FF'; # Purple
  } else {
    return '';        # No color
  }
  return;
}


// Open the restoration file and read the url
if ( isset($path) ) {
  $fHandle = fopen($path,"r");
  $url = fread($fHandle, filesize($path));
  $url = trim($url);
  fclose($fHandle);
}

// Trim the url to get the domain name...
$temp = explode("?", $url);
$index = strpos($temp[0], "cgi");
$url = substr($temp[0], 0,$index);

// Get the rest of the url... which contains all the variables necessary
$varList = explode(";",$temp[1]);

// Declare the arrays we'll use to store stuff
$leafID   = array();
$color    = array();
$opts     = array();
$triggers = array();
$holders  = array();

$size   = "";
$width  = 0;
$height = 0;

// Loop over the variables and assemble the information needed for restoring
for ( $i=0; $i<count($varList); $i++ ) {
  
  $index = strpos($varList[$i], "=");

  if ( $index > 0 ) {
    $temp = explode("=", $varList[$i]);
    $var = trim($temp[0]);
    $val = trim($temp[1]);
  } else {
    $var = trim($varList[$i]);
  }

  if ( $var == "dataset" ) {
    $url .= "ogre.php?dataset=$val&restore=$path";

  } else if ( $var == "leaf" ) {
    array_push($leafID,"'leaf" . $val . "'");

  } else if ( $var == "formula" ) {
    array_push($leafID, "'formula" . $val . "'");

  } else if ( $var == "color" ) {
    array_push($color, "'" . root2hex($val) . "'");

  } else if ( $var == "gWidth" ) {
    $width = $val;

  } else if ( $var == "gHeight" ) {
    $height = $val;

  } else if ( $var == "logx" ) {
    array_push($opts, "'logx'");

  } else if ( $var == "logy" ) {
    array_push($opts,"'logy'");

  } else if ( $var == "gcut" ) {
    array_push($opts, "'gcut'");

  } else if ( $var == "savedata" ) {
    array_push($opts, "'savedata'");

  } else if ( $var == "type" ) {
    array_push($opts, "'type'");
    array_push($opts, "'$val'");

  } else if ( $var == "triggers" ) {
    array_push($triggers, "'" . urldecode($val) ."'");

  } else if ( $var == "holders" ) {
    array_push($holders, "'$val'");
  }
}

$size = $width . "x" . $height;
array_push($opts, "'size'");
array_push($opts, "'$size'");

// And dump out the results
#print "$url\n";

print "      var triggers = new Array( " . join(",", $triggers) . " );\n";
print "      var holder   = new Array( " . join(",",$holders)   . " );\n";
print "      var plots    = new Array( " . join(",",$leafID)    . " );\n";
print "      var color    = new Array( " . join(",", $color)    . " );\n";
print "      var opts     = new Array( " . join(",", $opts)     . " );\n";

?>
