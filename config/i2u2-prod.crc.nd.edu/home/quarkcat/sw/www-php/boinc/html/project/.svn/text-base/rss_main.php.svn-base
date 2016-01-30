<?php

// rss_main.php:
// RSS 2.0 feed for BOINC default server installation.
// Channel Main show the current news on project mainpage 
// - for more informations about RSS see RSS 2.0 Specification:
//   http://blogs.law.harvard.edu/tech/rss

// Jens Seidler's modified version...  modified further by Eric Myers


  /**
   * Change Master URL to match the apparent server (in case of
   *Reverse Proxy) */

$remote_addr = $_SERVER['REMOTE_ADDR'];            // full URI
if( $remote_addr && preg_match("/^192\.5\.186\.82/", $remote_addr) ){
    $local_server = "www13.i2u2.org";
 }
 else {
     $local_server = $_SERVER['SERVER_NAME'];
 }
$self = $_SERVER['PHP_SELF']; 

$master_URL = "http://".$local_server. dirname($self);

/************/



// Inclue project constants and utils
//
require_once("../inc/cache.inc");
require_once("../inc/news.inc");
require_once("../inc/util.inc"); 
require_once("../project/project.inc");


// Get or set display options
// - from 1 to 9 News could be set by option "news", default is up to 9
// - The rss release could be set by option "rss", default is 2.0
//
$params = "";
$news = $_GET["news"];
if ( !$news or  $news < "1" or $news > "9" ) {
    $news = "9";
}
else {
    $params = "news=".$news;
}
$rss = $_GET["rss"];
if (!$rss or $rss <> "0.91") {
    $rss = "2.0";
} else {
    $params = "rss=".$rss;
} 

// Create and send out http header
//
header ("Expires: " . gmdate('D, d M Y H:i:s', time()) . " GMT");
header ("Last-Modified: " . gmdate('D, d M Y H:i:s') . " GMT");
header ("Content-Type: application/xml");


/////////////////////////////////////////
// Customizing script logic  (move these to project.inc)
//
define("NEWS_USE_CACHE", FALSE);
define("NEWS_FILE_NAME", "../project/project_news.inc");
/////////////////////////////


// Do caching if it is allowed by 'NEWS_USE_CACHE'.
// If the newsfile is not changed call the cache file
// which is created in normal cache and will be deleted
// by clean_cache function from time to time
//
if( NEWS_USE_CACHE ) {
    $cachefile = get_path($params);
    $last_cachetime = @filemtime($cachefile);
    $last_newstime = @filemtime(NEWS_FILE_NAME);
    if( $last_cachetime > $last_newstime ) {
        readfile($cachefile);
        exit;
    } 
    // prevent multiple processes creating the file
    // - the fopen mode "x" works from php 4.3.2 up
    // - lockfiles older then 5 seconds are removed
    //
    $lockfile = get_path($params."lock");
    if( ($lock_fd = @fopen($lockfile,"x")) == FALSE ) { 
        if( @filemtime($lockfile) < time()-5 ) {
            @unlink($lockfile);
        }
    }
    ob_start();
    ob_implicit_flush(0);
}

// Customize RSS feed here 
// - Load RSS data 
//


require_once(NEWS_FILE_NAME);

// - Define RSS channel header 
//
define("NEWS_PAGE", $master_URL."index.php");
define("DESCRIPTION", PROJECT." Front Page News");
define("CHANNEL_IMAGE", $master_URL."rss_image.jpg");
define("CREATE_DATE", gmdate('D, d M Y H:i:s')." GMT"); 
define("LANGUAGE", "en-us");

// Create channel header and open XML content
//
echo "<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?>
<rss version=\"$rss\">
<channel>
    <title>".PROJECT." News </title>
    <link>".$master_URL."</link>
    <description>".DESCRIPTION."</description>
    <copyright>".COPYRIGHT_HOLDER."</copyright>
    <lastBuildDate>".CREATE_DATE."</lastBuildDate>
    <language>".LANGUAGE."</language>
    <image>
       <url>".CHANNEL_IMAGE."</url>
       <title>".PROJECT."</title>
       <link>".$master_URL."</link>
    </image>\n";


// - Create news items
//
$Nnews = min( count($project_news), $news);
for( $i=0; $i < $Nnews; $i++ ) {
  $item = $project_news[$i];

  // If the file is in the old format then convert the item here
  if ( isset($item[0]) ) $item = convert_news_item($item);

  echo "    <item>\n";

  if ( array_key_exists("date", $item) ) {
    $timestamp = strtotime($item["date"]);
    if( $timestamp !== -1) {
      echo "      <pubDate>";
      echo gmdate("D, d M Y H:i:s", $timestamp) . " GMT";
      echo " </pubDate>\n";
    }
  }

  if ( array_key_exists('title',$item) ) {
    echo "      <title>";
    echo strip_tags($item["title"]);
    echo " </title>\n";
  }
  if ( array_key_exists('description',$item) ) {
    echo "      <description>";
    echo strip_tags($item["description"]);
    echo "\n      </description>\n";
  }

  if ( array_key_exists('link',$item) ) {
      $link = $item["link"];
      if( strpos($link,'/') === 0) {
          $link = $master_URL . substr($link,1);
      }
      echo "      <link>" .$link."</link>\n";
      echo "      <guid>" .$link."</guid>\n";
  }
  else {
    echo "      <link>".NEWS_PAGE."</link>\n";
    echo "      <guid>".NEWS_PAGE."</guid>\n";
  }

  echo "    </item>\n";
}

// Close XML content
//
echo "</channel>\n</rss>";

// End do caching 
//
if( NEWS_USE_CACHE ) {
    if( $lock_fd ) {
        $page = ob_get_contents();
        $file = fopen($cachefile,"w");
        fwrite($file, $page);
        fclose($file);
        unlink($lockfile);
    }
    ob_end_flush();
}

?>
