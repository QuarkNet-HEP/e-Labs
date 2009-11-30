<?php
  // Handle command line passes
  if ( isset($argv) ) {
    for ( $i=0; $i<sizeof($argv); $i++ ) {
      $temp = explode("=", $argv[$i]);
      if ( strtolower($temp[0]) == "username" ) {
	$userName = $temp[1];
      }
    }
  }

  if ( isset($_GET['directory']) ) {
    $directory = $_GET['directory'];
  } else if ( !isset($directory) ) {
    $directory = "../archives";
  }

  if ( isset($_GET['userName']) ) {
    $userName = $_GET['userName'];
  } else if ( !isset($userName) ) {
    $userName = 'guest';
  }

  if ( isset($directory) && $directory != "results" )
     print "<div id='moveArch'>\n";
  else
    print "<div id='movePrev'>\n";

  function aScandir($path) {
    if (!is_dir($path)) return 0;
    $list=array();
    $directory = @opendir("$path"); // @-no error display
    while ($file= @readdir($directory)) {
      if (($file<>".")&&($file<>"..")) { 
	$f=$path."/".$file;
	$f=preg_replace('/(\/){2,}/','/',$f); //replace double slashes
	if(is_file($f)) $list[]=$f;            
	if(is_dir($f))
	  $list = array_merge($list ,aScandir($f));   //RECURSIVE CALL
      }
    }
    @closedir($directory); 
    return $list ;
  }

  function aGetCanvai($path, $userName) {
    $files = @aScandir($path);

    if ( !isset($files) ) {
      exit;
    }

    sort($files);

    // If we're looking at stored archives... restrict the results to this user only
    if ( isset($path) && preg_match("/archives/",$path) ) {

      // Get a list from the database of the sessions this user has
      // Include the DB connection information
      include "DBDefs.php";

      // Connect to the database...
      $conn = mysql_connect($dbhost, $dbuser, $dbpass) or 
	die ('Error connecting to database');

      if ( !mysql_select_db($dbname, $conn) ) {
	echo mysql_errno($conn) . ":" . mysql_error($conn) . "\n";
      }

      // Dump out all sessionIDs this user has
      $query = "SELECT sID from settings where username='$userName'";

      $result = mysql_query($query, $conn);
      if ( !$result ) {
	echo mysql_errno($conn) . ":" . mysql_error($conn) . "\n";
      }

      $activeID = array();
      while ($row = mysql_fetch_array($result, MYSQL_ASSOC))
	array_push($activeID, $row['sID']);
    }

    foreach ($files as $fileName) {

      if ( fileType( $fileName ) ) {
	$file = substr(strrchr($fileName, "/"),1,strlen(strrchr($fileName, "/")));

	$pieces = explode(".",$file);
	$count = count($pieces) - 1;
	$ext = $pieces[$count];

	if ( strstr($pieces[0], "-") ) {
	  $temp = explode("-", $pieces[0]);
	  $id = $temp[count($temp)-1];
	  array_pop($temp);
	  $name = join("-",$temp);
	} else {
	  $name = $pieces[0];
	  $id = "";
	}
	if ( $id != "" && ($ext == "png" || $ext == "jpg") ) {
	  if ( isset($activeID) && count(preg_grep("/$id/", $activeID)) ) {
	    print "<img class=\"icons\" width=64 src=\"$path/$file\" id='$id'";
	    print " onClick='javascript:showArchivedCanvas(this);'/>\n";
	  }
	}
      }
    }
  }

  if ( $directory ) {
    aGetCanvai($directory,$userName);
  }

?>

</div>
