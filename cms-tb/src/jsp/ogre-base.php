<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
    <META HTTP-EQUIV="Pragma" content="no-cache">
    <head>
      <title>OGRE CMS HCAL TB04 Page</title>

      <?php
          echo "<Script Language='JavaScript' Type='Text/JavaScript'>\n";

         $dbhost='localhost';
		$dbuser='ogre';
		$dbpass='';
		$dbname='ogredb';
		$tblname='rundb';
		
		$dbconn = pg_connect("host=$dbhost dbname=$dbname user=$dbuser password=$dbpass")
		 or die('Could not connect: ' . pg_last_error());
          
		 /*
	  $dbhost = 'localhost';
          $dbuser = 'ogre';
          $dbpass = '';

          $conn = mysql_connect($dbhost, $dbuser, $dbpass) or die ('Error connecting to mysql');

          $dbname  = 'ogredb';
          $tblname = 'rundb';
          mysql_select_db($dbname);
			*/

          $query  = "SELECT COUNT(run) from $tblname ;";
          $result = pg_query($query) or die('Query failed: ' . pg_last_error());
          //$result = mysql_query($query);
          
          $row = pg_fetch_array($result, null, PGSQL_ASSOC) ;
          //$row = mysql_fetch_array($result, MYSQL_ASSOC);
          $number_of_runs = $row['count'];
          echo "var number_of_runs = $number_of_runs;\n";
          echo "var runType;\n";

          // Build the lists of run types
          // First, simple list of all the runs....
          $query = "SELECT run from $tblname ;";
          
          $result = pg_query($query) or die('Query failed: ' . pg_last_error());
          //$result = mysql_query($query);

          echo "var runList = new Array(";
		while ( $line = pg_fetch_array($result, null, PGSQL_ASSOC) ) {
              echo $line["run"].", ";
	    }
	    /*
          while ( $row = mysql_fetch_array($result, MYSQL_ASSOC) ) {
	    		$run = $row['run'];
	    		echo "$run,";
	  		}
		*/
          echo "null);\n";

          // Next, all the muons....
          $query = "SELECT run from $tblname where beam='Mu-';";
          
		$result = pg_query($query) or die('Query failed: ' . pg_last_error());
          //$result = mysql_query($query);

          echo "var muonRuns = new Array(";
          /*
          while ( $row = mysql_fetch_array($result, MYSQL_ASSOC) ) {
	    $run = $row['run'];
	    echo "$run,";
	  }
		*/
		while ( $line = pg_fetch_array($result, null, PGSQL_ASSOC) ) {
              echo $line["run"].", ";
	    }
        echo "null);\n";

          // Next, all the pions....
          $query = "SELECT run from $tblname where beam='Pi-';";
		$result = pg_query($query) or die('Query failed: ' . pg_last_error());
          //$result = mysql_query($query);

          echo "var pionRuns = new Array(";
		/*
          while ( $row = mysql_fetch_array($result, MYSQL_ASSOC) ) {
	    $run = $row['run'];
	    echo "$run,";
	  }
	  */
	  		while ( $line = pg_fetch_array($result, null, PGSQL_ASSOC) ) {
              echo $line["run"].", ";
	    }
	  
          echo "null);\n";

          // electrons....
          $query = "SELECT run from $tblname where beam='e-';";
   		$result = pg_query($query) or die('Query failed: ' . pg_last_error());       
          //$result = mysql_query($query);

          echo "var elecRuns = new Array(";
		/*
          while ( $row = mysql_fetch_array($result, MYSQL_ASSOC) ) {
	    $run = $row['run'];
	    echo "$run,";
	  }
		*/
		while ( $line = pg_fetch_array($result, null, PGSQL_ASSOC) ) {
              echo $line["run"].", ";
	    }
		
          echo "null);\n";

          // Annnnd..... calibration
          $query = "SELECT run from $tblname where beam='LED';";
   		$result = pg_query($query) or die('Query failed: ' . pg_last_error());
          //$result = mysql_query($query);

          echo "var calRuns = new Array(";
		/*
          while ( $row = mysql_fetch_array($result, MYSQL_ASSOC) ) {
	    $run = $row['run'];
	    echo "$run,";
	  }
		*/
		while ( $line = pg_fetch_array($result, null, PGSQL_ASSOC) ) {
              echo $line["run"].", ";
	    }
		
          echo "null);\n";

          echo "var runData = new Array(\n";

          $query  = "SELECT run,nevents,energy,beam FROM $tblname ;";
		$result = pg_query($query) or die('Query failed: ' . pg_last_error());
          //$result = mysql_query($query);

          /*
          while ( $row = mysql_fetch_array($result, MYSQL_ASSOC) ) {
	    $run = $row['run'];
	    $evt = $row['nevents'];
	    $eng = $row['energy'];
	    $beam = $row['beam'];
	    echo "\t\"Run $run $evt events of $eng GeV $beam\\n\",\n";
	  }
	  	*/
			while ( $line = pg_fetch_array($result, null, PGSQL_ASSOC) ) {
              echo "\t\"Run ".$line["run"]." ".$line['nevents']." events of ".$line['energy']."GeV ".$line['beam']." \\n\",\n";
	    }
	  
          echo "\tnull);\n";
          echo "function getRunData() {\n";
          echo "var text = \"\";\n";
          echo "for (var i=0; i<number_of_runs; i++) {\n";
          echo "\tif (document.getData.run_number[i].selected) {\n";
          echo "\t\ttext = text + runData[i];\n";
          //echo "\t\tif ( opener != null ) {\n";
          //echo "\t\t\topener.document.getData.run_number[i].selected = true;\n";
          echo "\t\t}\n";
          //echo "\t} else {\n";
          //echo "\t\tif ( opener != null ) {\n";
          //echo "\t\t\topener.document.getData.run_number[i].selected = false;\n";
          //echo "\t\t}\n";
          //echo "\t}\n";
          echo "}\n";
          //echo "opener.document.getData.muon_runs.checked = document.getData.muon_runs.checked;\n";
          //echo "opener.document.getData.pion_runs.checked = document.getData.pion_runs.checked;\n";
          //echo "opener.document.getData.elec_runs.checked = document.getData.elec_runs.checked;\n";
          //echo "opener.document.getData.cal_runs.checked  = document.getData.cal_runs.checked;\n";
          //echo "opener.document.getData.all_runs.checked  = document.getData.all_runs.checked;\n";
          echo "document.getData.dummy.value = text;\n";
          echo "return true;\n";
          echo "}\n";

          
          
          echo "function select_muons() {\n";
	echo "  if ( document.getData.all_runs.checked ) {\n";
    echo "document.getData.all_runs.checked = false;\n";
    echo "select_all();\n";
  echo "}\n";
  
  // Turn off any runs that are currently selected
echo "  for ( var i=0; i<number_of_runs; i++ ) {\n";
echo "    document.getData.run_number[i].selected = false;\n";
echo "  }\n";

echo "  if ( document.getData.muon_runs.checked ) {\n";
echo "    var j = 0;\n";
echo "    for ( var i=0; i<number_of_runs; i++ ) {\n";
echo "      if ( muonRuns[j] == runList[i] ) {\n";
echo "	document.getData.run_number[i].selected = true;\n";
echo "	j++;\n";
echo "      }\n";
echo "    }\n";
echo "  } else {\n";
echo "    var j = 0;\n";
echo "    for ( var i=0; i<number_of_runs; i++ ) {\n";
echo "      if ( muonRuns[j] == runList[i] ) {\n";
echo "	document.getData.run_number[i].selected = false;\n";
echo "	j++;\n";
echo "      }\n";
echo "    }\n";
echo "  }\n";
echo "  getRunData();\n";
echo "  return true;\n";
echo "}\n";

echo "</Script>\n";
          
          
          
          
          
      ?>
      
      
      
      <Script Language="JavaScript" Type="Text/JavaScript" SRC="utilities.js"></Script>
      <Script Language="JavaScript" Type="Text/JavaScript" SRC="run_utilities.js"></Script>
    </head>

  <body>

    <CENTER>
      <img src="graphics/ogre_small.png"></img>
    <FONT color="red"><H2>OGRE is an Online Graphical ROOT Environment</FONT></H2>
      Visit the <a href="http://root.cern.ch" target=_blank>Root</a> Homepage. (Creates a new window.)
    </CENTER>
    <HR>

    <CENTER>

    <!-- Change CGI path on moving! -->
    <form method="POST" name="getData" 
      action="ogreProcess.jsp?process=true" target="graphics"
      onsubmit="javascript:graphicsWin=popWindow('',document.getData.target,document.getData.
                                                    gWidth.value,document.getData.gHeight.value);">

      <!-- Store some basic bootstrap data for ogre.pl -->
      <input type="hidden" name="xmlfile" value="tb_data.xml">
      <input type="hidden" name="dataset" value="tb04">

	<H2>CMS HCal Testbeam '04 Data</H2>

	<!-- Script Language="JavaScript" Type="Text/JavaScript">setNumberOfVariables();</Script -->

        <table border=5 cellpadding=1>
          <!-- Put up the table header -->
          <tr align="center" valign="baseline">
            <td><FONT color="blue"><H4>Variable</H4></FONT></td>
            <td><FONT color="blue"><H4>Selection</H4></FONT></td>
            <td><FONT color="blue"><H4>Color</H4></FONT></td>
          </tr>

          <!-- Put up the table of variables that can be plotted -->

<!------------------------------------------- Begin PHP Table Builder ------------------------------------>

          <?PHP
            function print_error() {
              global $parser;
              die(sprintf("XML Error: %s at line %d",
          		   xml_error_string($xml_get_error_code($parser)),
          	           xml_get_current_line_number($parser)
          	         )
                 );
            }

          //create xml parser object
          $parser = xml_parser_create();

          // Set the location of the XML file to read
          $xmlFile = "tb_data.xml";

          //this option ensures that unneccessary white spaces
          //between successive elements would be removed
          xml_parser_set_option($parser,XML_OPTION_SKIP_WHITE,1);

          //to use XML code correctly we have to turn case folding
          //(uppercasing) off. XML is case sensitive and upper 
          //casing is in reality XML standards violation
          xml_parser_set_option($parser,XML_OPTION_CASE_FOLDING,0);

          //read XML file into $data
          $filename = "xml/$xmlFile";
          $data = implode("",file($filename));

          //parse XML input $data into two arrays:
          //$i_ar - pointers to the locations of appropriate values in
          //$d_ar - data value array
          xml_parse_into_struct($parser, $data, $d_ar, $i_ar) or print_error();

	  // Keep a running count of the variables we expose for plotting
          $leaf_number = 0;
          $form_number = 0;
          $cut_type_id = 0;
          $cut_id      = 0;
          
          
          
        for($i=0; $i<count($i_ar['dataset']); $i++) {

            //since we have <item> nested inside another <item> tag,
            //we have to check if pointer is to open type tag.
            if($d_ar[$i_ar['dataset'][$i]]['type']=='open') {
          			echo "<input type=hidden name=dataset_location value=\"".$d_ar[$i_ar['dataset'][$i]]['attributes']['location']."\" />";
            }	
            
            //add the file names to the page
            	
        }

          //cycle all <tree> tags. 
          //$i_ar['tree'] contains all pointers to <leaf> tags
          for($i=0; $i<count($i_ar['tree']); $i++) {

            $name = "";

            //since we have <item> nested inside another <item> tag,
            //we have to check if pointer is to open type tag.
            if($d_ar[$i_ar['tree'][$i]]['type']=='open') {
          
              // Dump out the tree
              for ($j=$i_ar['tree'][$i]; $j<$i_ar['tree'][$i+1]; $j++) {

                if ($d_ar[$j]['type'] == 'open' || $d_ar[$j]['type'] == 'complete' ) {

          	if ( $d_ar[$j]['tag'] == 'tree' ) {
          	  //$name = "\t";
          	  //echo "Tree {$d_ar[$j]['attributes']['name']}\n";

          	} elseif ( $d_ar[$j]['tag'] == 'branch' ) {
          	  //$name = $name . $d_ar[$j]['attributes']['name'];
          
          	} elseif ( $d_ar[$j]['tag'] == 'leaf' ) {

          	  echo "<tr>\n<td>\n";

          	  // Put up the variable to plot, and a button to select it
          	  echo "<input type=\"checkbox\" name=\"leaf\" value=\"";
                  echo $leaf_number;
                  echo "\">&nbsp;";
          	  echo "{$d_ar[$j]['attributes']['title']}\n";

                  echo "<input type=\"hidden\" name=\"root_leaf\"";
                  echo "  value=\"{$d_ar[$j]['attributes']['name']}\"></td>\n";

                  echo "<input type=\"hidden\" name=\"labelx\"";
                  echo "  value=\"{$d_ar[$j]['attributes']['labelx']}\"></td>\n";
                  
                  echo "<input type=\"hidden\" name=\"labely\"";
                  echo "  value=\"{$d_ar[$j]['attributes']['labely']}\"></td>\n";
                  
                  echo "<input type=\"hidden\" name=\"title\"";
                  echo "  value=\"{$d_ar[$j]['attributes']['title']}\"></td>\n";
                  
                  
                  echo "<td>\n";
          	  echo "<input type=\"checkbox\" name=\"cuttype\" multiselect value=0 id=";
                  echo $cut_type_id++;
                  echo " checked onClick=\"javascript:uncheckOthers(this);\">&nbsp; None &nbsp;\n";

          	  echo "<input type=\"checkbox\" name=\"cuttype\" multiselect value=1 id=";
                  echo $cut_type_id++;
                  echo " onClick=\"javascript:uncheckOthers(this);\" >&nbsp; > &nbsp;\n";

          	  echo "<input type=\"checkbox\" name=\"cuttype\" multiselect value=2 id=";
                  echo $cut_type_id++;
                  echo " onClick=\"javascript:uncheckOthers(this);\">&nbsp; < &nbsp;\n";

          	  echo "<input type=\"text\" name=\"cut\" size=\"5\" maxlength=\"5\" id=";
                  echo $cut_id++;
	          echo "  onBlur=\"javascript:isNumeric(this.value,this);\">\n";

          	  echo "</td>\n";

                  // Put up the histogram fill color select
                  echo "<td align=\"center\">\n";
                  echo "<select name=\"color\" id=$leaf_number>\n";
                  echo "<option value=0>None\n";
                  echo "<option value=1>Black\n";
                  echo "<option value=2>Red\n";
                  echo "<option value=3>Green\n";
                  echo "<option value=4>Blue\n";
                  echo "<option value=5>Yellow\n";
                  echo "<option value=6>Purple\n";
                  echo "</select>\n</td>\n</tr>\n\n";

          	  $leaf_number++;

          	} elseif ( $d_ar[$j]['tag'] == 'formula' ) {
          	  echo "<tr>\n<td>\n";

          	  // Put up the variable to plot, and a button to select it
          	  echo "<input type=\"checkbox\" name=\"formula\" value=\"";
                  echo $form_number;
                  echo "\">&nbsp;";
          	  echo "{$d_ar[$j]['attributes']['title']}\n";
          	  
                  echo "<td><input type=\"text\" name=\"cutf\"";
                  echo "  value=\"{$d_ar[$j]['attributes']['name']}\"></td>\n";

                  echo "<input type=\"hidden\" name=\"labelx\"";
                  echo "  value=\"{$d_ar[$j]['attributes']['labelx']}\"></td>\n";
                  
                  echo "<input type=\"hidden\" name=\"labely\"";
                  echo "  value=\"{$d_ar[$j]['attributes']['labely']}\"></td>\n";
                  
                  echo "<input type=\"hidden\" name=\"title\"";
                  echo "  value=\"{$d_ar[$j]['attributes']['title']}\"></td>\n";
                  
                  
                  // Put up the histogram fill color select
                  echo "<td align=\"center\">\n";
                  echo "<select name=\"colorf\">\n";
                  echo "<option value=0>None\n";
                  echo "<option value=1>Black\n";
                  echo "<option value=2>Red\n";
                  echo "<option value=3>Green\n";
                  echo "<option value=4>Blue\n";
                  echo "<option value=5>Yellow\n";
                  echo "<option value=6>Purple\n";
                  echo "</select>\n</td>\n</tr>\n\n";

          	  $form_number++;
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

          <tr></tr>
            <td></td>
            <td align="center"><input type="checkbox" name="savedata" value=1>Save Raw Data</td>
            <td align="center">
              <input type="checkbox" name="logx" value=1>logx
              <input type="checkbox" name="logy" value=1>logy
            </td>
          </tr>

        </table>

<!------------------------------------------- End PHP Table Builder ------------------------------------>


<!------------------------------------------ Build Available Run List ---------------------------------->
<!--
	<div class="hidden_table" id="table1" style="display:none">
         <table>
	    <tr>
	      <td>
		<input type="checkbox" name="muon_runs" > &nbsp;muons<BR>
		<input type="checkbox" name="pion_runs" > &nbsp;pions<BR>
		<input type="checkbox" name="elec_runs" > &nbsp;electron<BR>
		<input type="checkbox" name="cal_runs"  > &nbsp;Calibration<BR>
		<input type="checkbox" name="all_runs"  > &nbsp;All
	      </td>
              <td>
-->
	      <!-- Access the runDB and generate a list of available runs -->
	      <?php
/*
	        $dbhost = 'localhost';
                $dbuser = 'ogre';
                $dbpass = '';

                $conn = mysql_connect($dbhost, $dbuser, $dbpass) or die ('Error connecting to mysql');

                $dbname  = 'ogredb';
                $tblname = 'rundb';
                mysql_select_db($dbname);

                $query = "SELECT run from $tblname";
                $result= mysql_query($query);

                echo "<select name=\"run_number\" multiple size=5 onChange=\"javascript:select_single_run();\">\n";
                while ( $row = mysql_fetch_array($result, MYSQL_ASSOC) ) {
                  echo "<option value='{$row['run']}'> Run {$row['run']}\n";
	        }
                echo "</select><BR><BR>\n";

                mysql_close($conn);
*/
              ?>
<!--
              </td>
            </tr>
          </table>
        </div>
-->
<!---------------------------------------- End Build Available Run List -------------------------------->

	<H3>Data Selection</H3>
	<table border=5 cellpadding=5>
	    <tr align="center" valign="baseline">
	      <td><FONT color="blue"><H4>Select all runs of type</FONT></H4></td>
	      <td><FONT color="blue"><H4>Data to Plot</FONT></H4></td>
	      <td><FONT color="blue"><H4>Run Info</FONT> &nbsp;&nbsp;
<!--
		  <a href="http://pcephc356.cern.ch:8000/%7Edaq/searchForm.php" target=_blank>
		    (Search the CMS HCal TB Run DataBase)</a></H4>
-->
	      </td>
	    </tr>
	    <tr>
	      <td>
		<input type="checkbox" name="muon_runs" onClick="javascript:select_muons();">     &nbsp;muons<BR>
		<input type="checkbox" name="pion_runs" onClick="javascript:select_pions();">     &nbsp;pions<BR>
		<input type="checkbox" name="elec_runs" onClick="javascript:select_electrons();"> &nbsp;electron<BR>
		<input type="checkbox" name="cal_runs"  onClick="javascript:select_calib();">     &nbsp;Calibration<BR>
		<input type="checkbox" name="all_runs"  onClick="javascript:select_all();">       &nbsp;All
	      </td>

	<!-- Access the runDB and generate a list of available runs -->
	<?php
		/*
	  $dbhost = 'localhost';
          $dbuser = 'ogre';
          $dbpass = '';

          $conn = mysql_connect($dbhost, $dbuser, $dbpass) or die ('Error connecting to mysql');

          $dbname  = 'ogredb';
          $tblname = 'rundb';
          mysql_select_db($dbname);
          */
		
		/*
          		$dbhost='localhost';
		$dbuser='ogre';
		$dbpass='';
		$dbname='ogredb';
		$table='rundb';
		
		$dbconn = pg_connect("host=$dbhost dbname=$dbname user=$dbuser password=$dbpass")
		 or die('Could not connect: ' . pg_last_error());
		*/
		 
          $query = "SELECT run from $tblname";

          //$result= mysql_query($query);
			$result = pg_query($query) or die('Query failed: ' . pg_last_error());
			
          echo "<td>\n<select name=\"run_number\" multiple size=5 onChange=\"javascript:select_single_run();\">\n";

          /*
          while ( $row = mysql_fetch_array($result, MYSQL_ASSOC) ) {
            echo "<option value='{$row['run']}'> Run {$row['run']}\n";
	  }
		*/
		while ( $line = pg_fetch_array($result, null, PGSQL_ASSOC) ) {
              echo "<option value='{$line["run"]}'> Run {$line["run"]}\n";
	    }
          
	  	echo "</select>\n</td>\n<td><textarea name='dummy' rows=5 cols=37 readonly></textarea></td>";

          
          pg_close($dbconn);
          //mysql_close($conn);
      ?>

      </tr>
      </table>

	<H2>Graphics Options</H2>
	<table border=5 cellpadding=5>
	    <tr align="center" valign="baseline">
	      <td><FONT color="blue"><H4>Graphics Size</FONT></H4></td>
	      <td><FONT color="blue"><H4>Output Graphics Type</FONT></H4></td>
	      <td><FONT color="blue"><H4>All Plots on One Histogram</FONT></H4></td>
	    </tr>

	    <tr>
	      <td>
		Width &nbsp;&nbsp;<input type="text" value=800 name=gWidth  size=4 onBlur="javascript:checkgSize();">
		Height      &nbsp;<input type="text" value=600 name=gHeight size=4 onBlur="javascript:checkgSize();">
	      </td>
	      <td>
		<input type="radio" name="type" value="png" checked>PNG
		<input type="radio" name="type" value="jpg"        >JPG
		<input type="radio" name="type" value="eps"        >EPS
	      </td>
	      <td align="center"><input type="checkbox" name="allonone" value=1>&nbsp;Yes</td>
	    </tr>
	</table>

      <BR>

      <input type=SUBMIT value="Plot">&nbsp;&nbsp;
      <input type="button" value="Previous Results" 
        onclick="javascript:previousResults=popWindow('results/','previousResults',500,600);">
      <input type=RESET  value="Reset Values">&nbsp;&nbsp;
      <input type="button" value="Close Popups" onclick="javascript:closePopUps();">
    </form>

    </CENTER>

    <hr>
    <address><a href="mailto:karmgard.1@nd.edu">Bug the OGRE</a></address>
  </body>
</html>
