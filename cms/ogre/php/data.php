<?php 
  // Handle command line passes
if ( isset($argv) ) {
    for ( $i=0; $i<sizeof($argv); $i++ ) {
      $temp = explode("=", $argv[$i]);
      if ( strtolower($temp[0]) == "userlevel" ) {
	$userLevel = $temp[1];
      } else if ( strtolower($temp[0]) == "dataset" ) {
	$dataset = $temp[1];
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

<div id='moveData'>
   <fieldset id='data'>
     <legend>Data</legend>

	<div class="tData" id="data1" 
	  onMouseOver="showtrigToolTip(dataTip);" 
	  onMouseOut="UnTip();">
	</div>

	<div class="tLogic" id="logic1"
	  onMouseOver="showtrigToolTip(logicTip);" 
	  onMouseOut="UnTip();">
	</div>

   </fieldset>

    <!--the mouse over and dragging class are defined on each item-->

    <fieldset id="Demo0">
      <legend id='select_legend'>Select events with:</legend>

      <div id='leftcol'>
	<label for="DragContainer11">any of</label>
	<div class="tDragContainer" id="DragContainer11" history="History1" 
             onMouseOver="showtrigToolTip(anyofTip);"
             onMouseOut="UnTip();"></div>
     </div>

      <div id='centcol'>
	<label for="DragContainer12">all of</label>
        <div class="tDragContainer" id="DragContainer12" history="History1"
             onMouseOver="showtrigToolTip(allofTip);"
             onMouseOut="UnTip();"></div>
      </div>

      <div id='rightcol'>
	<label for="DragContainer13">one of</label>
	<div class="tDragContainer" id="DragContainer13" history="History1"
             onMouseOver="showtrigToolTip(oneofTip);"
             onMouseOut="UnTip();"></div>
      </div>

    </fieldset>

    <?php
      if ( !isset($userLevel) ) {
	// See if we know how advanced our user is
	if (isset($_COOKIE['userLevel'])) {
	  $userLevel = $_COOKIE['userLevel'];
	} else {
	  $userLevel = 0;
	}
      }
    ?>

    <!--the mouse over and dragging class are defined on each item-->
    <fieldset id="Demo1" 
      <?php if ($userLevel >= 2) { echo " style='display:block;'"; } else {
	echo "style='display:none;'"; }?>>
      <legend id='reject_legend'>Reject events with:</legend>

      <div id='leftcol'>
	<label for="DragContainer15">any of</label>
	<div class="tDragContainer" id="DragContainer15" history="History1"
             onMouseOver="showtrigToolTip(anyofTip,true);"
             onMouseOut="UnTip();"></div>
     </div>

      <div id='centcol'>
	<label for="DragContainer16">all of</label>
        <div class="tDragContainer" id="DragContainer16" history="History1"
             onMouseOver="showtrigToolTip(allofTip, true);"
             onMouseOut="UnTip();"></div>
      </div>

      <div id='rightcol'>
	<label for="DragContainer17">one of</label>
	<div class="tDragContainer" id="DragContainer17" history="History1"
             onMouseOver="showtrigToolTip(oneofTip, true);"
             onMouseOut="UnTip();"></div>
      </div>

    </fieldset>

    <fieldset id="triggers">
      <legend>Data Filters</legend>
      <div id="DragContainer14" history="History1">

        <?PHP             // Get a list of triggers to use with the data selector
          //create xml parser object
          $parser = xml_parser_create();

          // Set the location of the XML file to read
          if ( isset($dataset) ) {
	    include "mysql.php";
	 
	  } else {
	    $xmlFile = "xml/mc_data.xml";
	  }

          //this option ensures that unneccessary white spaces
          //between successive elements would be removed
          xml_parser_set_option($parser,XML_OPTION_SKIP_WHITE,1);

          //to use XML code correctly we have to turn case folding
          //(uppercasing) off. XML is case sensitive and upper 
          //casing is in reality XML standards violation
          xml_parser_set_option($parser,XML_OPTION_CASE_FOLDING,0);

          //read XML file into $data
          $data = implode("",file($xmlFile));

          //parse XML input $data into two arrays:
          //$i_ar - pointers to the locations of appropriate values in
          //$d_ar - data value array
          xml_parse_into_struct($parser, $data, $d_ar, $i_ar); // or print_error();

          //cycle all <trigger> tags. 
          //$i_ar['triggers'] contains the pointers to <trigger> tags

          for($i=0; $i<count($i_ar['triggers'])-1; $i++) {
	    for ($j=$i_ar['triggers'][$i]; $j<$i_ar['triggers'][$i+1]; $j++) {

	      if ($d_ar[$j]['type'] == 'open' || $d_ar[$j]['type'] == 'complete' ) {

                if ( $d_ar[$j]['tag'] == 'trigger' ) {

		  // Only include the stuff appropriate for the users level
		  if ( $userLevel >= $d_ar[$j]['attributes']['level'] ) {

		    echo "<div class=\"tDragBox\" id=\"";
		    echo "{$d_ar[$j]['attributes']['id']}\" history=\"History1\" ";
		    echo "overClass=\"OvertDragBox\" dragClass=\"tDragDragBox\" ";
		    echo "onMouseOver='showtrigToolTip(\"{$d_ar[$j]['attributes']['description']}\");' ";
		    echo "onMouseOut='UnTip();'> {$d_ar[$j]['attributes']['name']}</div>\n";

		  }
		}
	      }
	    }
	  } 

          ?>

      </div>

    </fieldset>

    <fieldset id="tHistory">
      <legend>History</legend>
      <div id="History1"></div>
    </fieldset>

    <div id='navButtons'>
	    
      <button id='gotoCntl' 
	onClick='javascript:cntlWin.show();'
	onMouseOver='javascript:Tip("Access OGRE Controls")';
        onMouseOut='javascript:UnTip();'>
	OGRE Controls
      </button>

      <button id='gotoVars' 
	onClick='javascript:variWin.show();'
	onMouseOver='javascript:Tip("Access the available plots")';
        onMouseOut='javascript:UnTip();'>
	Build Plots
      </button>

    </div>

</div>
