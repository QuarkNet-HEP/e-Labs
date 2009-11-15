<?php
  // Handle command line passes
if ( isset($argv) ) {
    for ( $i=0; $i<sizeof($argv); $i++ ) {
      $temp = explode("=", $argv[$i]);
      if ( strtolower($temp[0]) == "userlevel" ) {
	$userLevel = $temp[1];
      } else if ( strtolower($temp[0]) == "dataset" ) {
	$dataset = $temp[1];
      } else if ( strtolower($temp[0]) == "sessionid" ) {
	$sessionID = $temp[1];
      }

    }
}

// And POST/GET
if ( !isset($dataset) ) {
  if ( isset($_GET['dataset']) ) {
    $dataset = $_GET['dataset'];
  } else {
    $dataset = "mc09";
  }
}

?>

   <div id='moveVars'>
    <fieldset id="Options" class="fieldset options">
      <legend>Options</legend>

      <!-- Draggable colors for the plot(s) -->
      <div class="vDragContainer DragContainer3" id="DragContainer3" history="History2" 
           onMouseOver="showvarsToolTip(tip3);" onMouseOut="UnTip();">
	<div class="colorDragBox red"    overClass="colorDragBox OvercolorDragBox" 
                 style="background-color: #ff0000;" name="color" id="color" value="red"   ></div>
	<div class="colorDragBox green"  overClass="colorDragBox OvercolorDragBox" 
                 style="background-color: #00ff00;" name="color" id="color" value="green" ></div>
	<div class="colorDragBox blue"   overClass="colorDragBox OvercolorDragBox" 
                 style="background-color: #0000ff;" name="color" id="color" value="blue"  ></div>
	<div class="colorDragBox black"  overClass="colorDragBox OvercolorDragBox" 
                 style="background-color: #000000;" name="color" id="color" value="black" ></div>
	<div class="colorDragBox white"  overClass="colorDragBox OvercolorDragBox" 
                 style="background-color: #ffffff;" name="color" id="color" value="white" ></div>
	<div class="colorDragBox yellow" overClass="colorDragBox OvercolorDragBox" 
                 style="background-color: #ffff00;" name="color" id="color" value="yellow"></div>
	<div class="colorDragBox purple" overClass="colorDragBox OvercolorDragBox" 
                 style="background-color: #ff00ff;" name="color" id="color" value="purple"></div>
	<div class="colorDragBox none" name="color" id="color" value="none"  ></div>
      </div>

<?php
  /*
      <!-- Change linear plots to semilog or log-log form -->
      <div class="vDragContainer DragContainer4" id="DragContainer4" history="History2" 
           onMouseOver="showvarsToolTip(tip4);" onMouseOut="UnTip();">
	<div class="vminiDragBox" overClass="vminiDragBox OvervminiDragBox" id="logx">LogX</div>
	<div class="vminiDragBox" overClass="vminiDragBox OvervminiDragBox" id="logy">LogY</div>
      </div>
      <!-- Output graphics formats -->
     <div class="vDragContainer DragContainer5" id="DragContainer5" history="History2" 
          onMouseOver="showvarsToolTip(tip5);" onMouseOut="UnTip();">
	<div class="vminiDragBox" overClass="vminiDragBox OvervminiDragBox" name="type" id="type" value="png" >png</div>
	<div class="vminiDragBox" overClass="vminiDragBox OvervminiDragBox" name="type" id="type" value="jpg" >jpg</div>
	<div class="vminiDragBox" overClass="vminiDragBox OvervminiDragBox" name="type" id="type" value="eps" >eps</div>
      </div>
  */
?>

  <!-- Change linear plots to semilog or log-log form, apply previously saved cuts, dump out the raw data -->
      <div class="vDragContainer DragContainer4" id="DragContainer4" history="History2">
	<div class="vminiDragBox" overClass="vminiDragBox OvervminiDragBox" id="logx" 
           onMouseOver="showvarsToolTip(tip4);" onMouseOut="UnTip();">LogX</div>
	<div class="vminiDragBox" overClass="vminiDragBox OvervminiDragBox" id="logy" 
           onMouseOver="showvarsToolTip(tip4);" onMouseOut="UnTip();">LogY</div>
<?php
  //      <div class='vDragContainer DragContainer7' id='DragContainer7' history='History2'>

  echo "\t  <div class='vminiDragBox' overClass='vminiDragBox OvervminiDragBox' style='height:2.67em;' id='gcut'\n";

  if ( isset($_GET['sessionID']) ) {
    $sessionID = $_GET['sessionID'];
  }

  if ( isset($sessionID) ) {

    // Include the DB connection information
    include "DBDefs.php";

    // Connect to the database...
    $conn = mysql_connect($dbhost, $dbuser, $dbpass) or 
    die ('Error connecting to database');

    if ( !mysql_select_db($dbname, $conn) ) {
      echo mysql_errno($conn) . ":" . mysql_error($conn) . "\n";
    }

    // Read the selection from the settings table to include it as a tooltip
    $query = "SELECT selection from settings where sID='$sessionID'";

    $result = mysql_query($query, $conn);
    if ( !$result ) {
      echo mysql_errno($conn) . ":" . mysql_error($conn) . "\n";
    }

    while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {
      $selection = $row['selection'];
    }
  }

  print "\t    onMouseOver='showvarsToolTip(tip7_1";
  if ( isset($selection) )
    print "+\"<BR>$selection\"";
  print ");' onMouseOut='UnTip();'>My Cuts</div>\n";
?>

    <div class='vminiDragBox' overClass='vminiDragBox OvervminiDragBox' id='savedata' style='display:none;;'
      onMouseOver='showvarsToolTip(tip7_2);' onMouseOut='UnTip();'>Raw Data</div>
    </div>

      <!-- Output graphics sizes -->
      <div class="vDragContainer DragContainer6" id="DragContainer6" history="History2" 
        onMouseOver="showvarsToolTip(tip6);" onMouseOut="UnTip();">
        <div class="vminiDragBox" overClass="vminiDragBox OvervminiDragBox" name="size" id="size" value="640x480"   > 640</div>
        <div class="vminiDragBox" overClass="vminiDragBox OvervminiDragBox" name="size" id="size" value="800x600"   > 800</div>
        <div class="vminiDragBox" overClass="vminiDragBox OvervminiDragBox" name="size" id="size" value="1024x768"  >1024</div>
        <div class="vminiDragBox" overClass="vminiDragBox OvervminiDragBox" name="size" id="size" value="1280x1024" >1280</div>
        <div class="vminiDragBox" overClass="vminiDragBox OvervminiDragBox" name="size" id="size" value="1600x1200" >1600</div>
      </div>
    
      <!-- Mathematical operations that can be performed on the data as it goes into a histogram -->
      <div class="vDragContainer DragContainer9" id="DragContainer9" history="History2" 
           onMouseOver="showvarsToolTip(tip10);" onMouseOut="UnTip();">

<?php

    print "\t<div class='vminiOpsDragBox' overClass='vminiOpsDragBox OvervminiOpsDragBox' name='plus' id='ops0' value='plus'>+</div>\n";
    print "\t<div class='vminiOpsDragBox' overClass='vminiOpsDragBox OvervminiOpsDragBox' name='-' id='ops1' value='-'>-</div>\n";
    print "\t<div class='vminiOpsDragBox' overClass='vminiOpsDragBox OvervminiOpsDragBox' name=':' id='ops4' value=':'>:</div>\n";
    print "\t<div class='vminiOpsDragBox' overClass='vminiOpsDragBox OvervminiOpsDragBox' name='|' id='ops7' value='|'>|</div>\n";

if ( $userLevel >= 1 ) {
        print "\t<div class='vminiOpsDragBox' overClass='vminiOpsDragBox OvervminiOpsDragBox' name='*' id='ops2' value='*'>*</div>\n";
        print "\t<div class='vminiOpsDragBox' overClass='vminiOpsDragBox OvervminiOpsDragBox' name='/' id='ops3' value='/'>/</div>\n";
        print "\t<div class='vminiOpsDragBox' overClass='vminiOpsDragBox OvervminiOpsDragBox' name='(' id='ops5' value='('>(</div>\n";
        print "\t<div class='vminiOpsDragBox' overClass='vminiOpsDragBox OvervminiOpsDragBox' name=')' id='ops6' value=')'>)</div>\n";
}

if ( $userLevel >=2 ) {
      print "\t<div class='vminiOpsDragBox' overClass='vminiOpsDragBox OvervminiOpsDragBox' name='tan'  id='ops9'  value='tan'>tan</div>\n";
      print "\t<div class='vminiOpsDragBox' overClass='vminiOpsDragBox OvervminiOpsDragBox' name='sin'  id='ops10' value='sin'>sin</div>\n";
      print "\t<div class='vminiOpsDragBox' overClass='vminiOpsDragBox OvervminiOpsDragBox' name='cos'  id='ops11' value='cos'>cos</div>\n";
}
if ( $userLevel > 2 ) {
      print "\t<div class='vminiOpsDragBox' overClass='vminiOpsDragBox OvervminiOpsDragBox' name='exp'  id='ops8'  value='exp'>exp</div>\n";
      print "\t<div class='vminiOpsDragBox' overClass='vminiOpsDragBox OvervminiOpsDragBox' name='ln'   id='ops12' value='ln'>ln</div>\n";
      print "\t<div class='vminiOpsDragBox' overClass='vminiOpsDragBox OvervminiOpsDragBox' name='sqrt' id='ops13' value='sqrt'>sqrt</div>\n";
}
?>
      </div>

    </fieldset>

    <!-- Drop targets for the other stuff on the page -->
    <fieldset id="Demo2" class="fieldset targets">
      <legend>Make a Plot</legend>
      <div class="vDragContainer DragContainer2" id="DragContainer2" history="History2" 
           onMouseOver="showvarsToolTip(tip2);" onMouseOut="UnTip();"></div>
      <div class="vDragContainer DragContainer8" id="DragContainer8" history="History2" 
           onMouseOver="showvarsToolTip(tip8);" onMouseOut="UnTip();"></div>
    </fieldset>

    <fieldset id="variables" class="fieldset">
      <legend>Available Plots</legend>
      <div class="vDragContainer DragContainer1" id="DragContainer1" history="History2"> 
        <?php include "xmlVar.php";?>
      </div>
    </fieldset>

    <fieldset id='history' >
	<legend>History</legend>
	<div id="History2"></div>
    </fieldset>

     <div id='navButtons'>
      <button id='gotoData' 
	onClick='javascript:dataWin.show();'
        onMouseOver='javascript:showvarsToolTip(tip9_1);'
        onMouseOut='javascript:UnTip();'>
	Select Data
      </button>

      <button id='makePlot'
	onClick='javascript:submitGetData(document.forms["getData"]);'
        onMouseOver='javascript:showvarsToolTip(tip9_2);'
        onMouseOut='javascript:UnTip();'>
	Plot It!
      </button>
    </div>

   </div>
