<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" 
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

   <head>
   <script type="text/javascript" language="javascript" src="javascript/showhide.js"></script>
   <script type="text/javascript" language="javascript" src="javascript/procForm.js"></script>
   <link rel="stylesheet" type="text/css" href="stylesheets/restore.css"/>
   </head>
   <body id='body' style="background-color:transparent">

   <div class="expander" id="expander" onMouseOut='javascript:contract(this);'>
   </div>
   <div class="previous" id="previous">

<?php

function scandir_recursive($path) {
  if (!is_dir($path)) return 0;
  $list=array();
  $directory = @opendir("$path"); // @-no error display
  while ($file= @readdir($directory)) {
    if (($file<>".")&&($file<>"..")) { 
      $f=$path."/".$file;
      $f=preg_replace('/(\/){2,}/','/',$f); //replace double slashes
      if(is_file($f)) $list[]=$f;            
      if(is_dir($f))
	$list = array_merge($list ,scandir_recursive($f));   //RECURSIVE CALL
    }
  }
  @closedir($directory); 
  return $list ;
  }

function get_canvai($path) {
  $files = @scandir_recursive($path);

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
	print " onClick='javascript:expand(this);'/>\n";
      }
    }
  }
}

if ( isset($_GET['directory']) ) {
    $directory = $_GET['directory'];
} else {
  $directory = "results";
}
if ( $directory ) {
  get_canvai($directory);
}

?>

</div>
</body>
</html>
