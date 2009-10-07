<?php
   if ( isset($_GET['directory']) ) {
     $directory = $_GET['directory'];
   } else if ( !$directory ) {
     $directory = "../archives";
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

function aGetCanvai($path) {
  $files = @aScandir($path);

  if ( !isset($files) ) {
    exit;
  }

  sort($files);
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
	print "<img class=\"icons\" width=64 src=\"$path/$file\" id='$id'";
	//print " onClick='javascript:expand(this, \"aExpander\");'/>\n";
	print " onClick='javascript:showArchivedCanvas(this);'/>\n";
      }
    }
  }
}

if ( $directory ) {
  aGetCanvai($directory);
}

?>

</div>
