<?PHP
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

// Determine what dataset we're going to be using today
if ( !isset($dataset) ) {
  if ( isset($_GET['dataset']) ) {
    $dataset = $_GET['dataset'];
  } else {
    $dataset = "mc09";
  }
}

// See if we know how advanced our user is
if ( !isset($userLevel) ) {
  if (isset($_COOKIE['userLevel'])) {
    $userLevel = $_COOKIE['userLevel'];
  } else {
    $userLevel = 0;
  }
}

// Parse the xml file and get a list of stuff to plot

//create xml parser object
$parser = xml_parser_create();

// Set the location of the XML file to read
if ( $dataset ) {
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
xml_parse_into_struct($parser, $data, $d_ar, $i_ar);// or print_error();

// Keep a running count of the variables we expose for plotting
$leaf_number = 0;
$form_number = 0;
$cut_type_id = 0;
$cut_id      = 0;

//cycle all <tree> tags. 
//$i_ar['tree'] contains all pointers to <leaf> tags
for($i=0; $i<count($i_ar['tree']); $i++) {

  $name = "";
  echo "\n";

  //since we have <item> nested inside another <item> tag,
  //we have to check if pointer is to open type tag.
  if($d_ar[$i_ar['tree'][$i]]['type']=='open') {

    // Dump out the tree
    for ($j=$i_ar['tree'][$i]; $j<$i_ar['tree'][$i+1]; $j++) {

      if ($d_ar[$j]['type'] == 'open' || $d_ar[$j]['type'] == 'complete' ) {
	if ( $d_ar[$j]['tag'] == 'leaf' ) {

	  // Only include the stuff appropriate for the users level
	  if ( $userLevel >= $d_ar[$j]['attributes']['level'] ) {

	    // Dump out the leaf for the drag and drop frame
            echo "        <div class=\"vDragBox1\" history=\"History1\" ";
#            echo "name=\"{$d_ar[$j]['attributes']['name']}\"";
	    echo "name='leaf'";
            echo " id=\"leaf{$d_ar[$j]['attributes']['id']}";
            echo "\" overClass=\"OvervDragBox1\" dragClass=\"vDragDragBox1\" ";
	    echo "onMouseOver='javascript:showvarsToolTip(\"{$d_ar[$j]['attributes']['description']}\");'";
	    echo "onMouseOut='javascript:UnTip();'>";
            echo "{$d_ar[$j]['attributes']['title']}</div>\n";
	  }

	} elseif ( $d_ar[$j]['tag'] == 'formula' ) {

	  // Only include the stuff appropriate for the users level
	  if ( $userLevel >= $d_ar[$j]['attributes']['level'] ) {

	    // Dump out the leaf for the drag and drop frame
	    echo "        <div class=\"vDragBox1\" history=\"History1\" ";
#	    echo "name=\"{$d_ar[$j]['attributes']['name']}\" ";
	    echo "name='formula'";
            echo "id=\"formula{$d_ar[$j]['attributes']['id']}\"";
	    echo "\" overClass=\"OvervDragBox1\" dragClass=\"vDragDragBox1\" ";
	    echo "onMouseOver='javascript:showvarsToolTip(\"{$d_ar[$j]['attributes']['description']}\");' ";
            echo "onMouseOut='javascript:UnTip();'>";
	    echo " {$d_ar[$j]['attributes']['title']}</div>\n";
	  }

	}
      }

      if ( $d_ar[$j]['type'] == 'close' ) {
	if ( $d_ar[$j]['tag'] == 'tree' ) {
	  $name = "";
	} elseif ( $d_ar[$j]['tag'] == 'branch' ) {
	  $name = "\t";
	}
      }
    }
  }
}

//unseting XML parser object
xml_parser_free($parser);

?>
