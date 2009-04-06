<?php

// include cache for lockfile logic
//
require_once("../inc/cache.inc");


// restart newsadmin script
//
function news_call_self($params) {
    $url = "http://" . $_SERVER['HTTP_HOST'] .
                    $_SERVER['PHP_SELF'] . $params;
    header("Location: " .$url);

     // some insurance in case the header: fails...
     echo "<head>
        <meta http-equiv=\"Refresh\" content=\"0; URL=$url \" >
     </head>\n";
     exit;     
     //die("Hej, we should not reach this point!");
}


// build params string for URL/$_GET handling
//
function news_make_params($input) {
    $ret="";
    foreach ($input as $key => $value) {
        if( isset($value) and $value<>"" ) {
            $ret == "" ? $ret = "?" : $ret .= "&" ;
            $ret .= "$key=$value";
        }
    }
    return $ret;
}


// replace chars, i.e. quotes before writing news array
//
function news_replace_chars($input) {
    $input = str_replace("\\\"" , "&quot;", $input);
    $input = str_replace("\""   , "&quot;", $input);
    $input = str_replace("\'"   , "&#039;", $input);
    return $input;
}


// Print a message by message number/ID
//
function news_print_msg( $msg ) {
  $messages = array( 
		    "MsgNoEdit" =>
		    "The Newsfile was modified by another user since you started editing. 
 Please check your changes to prevent data corruption. Then try again!",
		    "MsgNoAdd" =>
		    "The Newsfile was modified by another user since you load it the last time.
 Please check your news to prevent idouble posts. Then try again!",
		    "MsgNoSelect"=>
		    "The Newsfile was modified by another user since you load it the last time.
 To prevent data corruption, please select again a news!",
		    "MsgNoDelete" =>
		    "The Newsfile was modified by another user since you load it the last time.
 To prevent erasing the wrong posts, please select again a news!",
		    "MsgNoLock" =>
		    "Could not create lock file!",
		    "MsgNoBack" =>
		    "Could not create backup file!",
		    "MsgNoWrite" =>
		    "Could not write news file!"
		    );
  echo "<tr><td colspan=\"2\"><font color=#FF0000>".
    wordwrap($messages[$msg],45,"<br>")."</font></td></tr>";
}


// Fill the form fields by array values
//
function news_fill_by_array($items, $i) {
    $GLOBALS["date"] = $items[$i]["date"];
    $GLOBALS["title"] = $items[$i]["title"];
    $GLOBALS["description"] = $items[$i]["description"];
    $GLOBALS["link"] = $items[$i]["link"];
    $GLOBALS["author"] = $items[$i]["author"];
    $GLOBALS["status"] = $items[$i]["status"];
}


// Fill the form fields by POST values
//
function news_fill_by_post() {
    $GLOBALS["date"] = $_POST["date"];
    $GLOBALS["title"] = $_POST["title"];
    $GLOBALS["description"] = $_POST["description"];
    $GLOBALS["link"] = $_POST["link"];
    $GLOBALS["author"] = $_POST["author"];
    $GLOBALS["status"] = $_POST["status"];
    $GLOBALS["thread_id"] = $_POST["thread_id"];
    if ( $thread_id ) {
      $link = MASTER_URL . "forum_thread.php?" . $thread_id;
    }
}


// modify a news item in a given news array by POST values
//
function news_del_item(&$items, $i) {
    array_splice( $items, $i , 1);
}


// modify a news item in a given news array by POST values
//
function news_add_item(&$items, $hide) {
    $tmp_news = array(
        "title" => $_POST["title"],
        "description" => $_POST["description"],
    );
    if( trim($_POST["date"]) <> "" ) {
        $tmp_news["date"] = trim($_POST["date"]);
    };

    if( trim($_POST["link"]) <> "" ) {
        $tmp_news["link"] = trim($_POST["link"]);
    };

    // thread_id takes precendenc
    if( trim($_POST["thread_id"]) <> "" ) {
        $tmp_news["link"] = MASTER_URL . "forum_thread.php?" .
	   trim($_POST["thread_id"]);
    };

    if( trim($_POST["author"]) <> "" ) {
        $tmp_news["author"] = trim($_POST["author"]);
    };
    if( $hide == TRUE ) {
        $tmp_news["status"] = "hidden";
    } else {
        if( trim($_POST["status"]) <> "none" ) {
            $tmp_news["status"] = trim($_POST["status"]);
        };
    }
    array_unshift( $items, $tmp_news );
}


// modify a news item in a given news array by POST values
//
function news_edit_item(&$items, $news) {
    $items[$news]["title"] = $_POST["title"];
    $items[$news]["description"] = $_POST["description"];
    if( trim($_POST["date"]) <> "" ) {
        $items[$news]["date"] = $_POST["date"];
    } else {
        unset($items[$news]["date"]);
    };
    if( trim($_POST["link"]) <> "" ) {
        $items[$news]["link"] = $_POST["link"];
    } else {
        unset($items[$news]["link"]);
    };
    if( trim($_POST["author"]) <> "" ) {
        $items[$news]["author"] = $_POST["author"];
    } else {
        unset($items[$news]["author"]);
    };
    if( trim($_POST["status"]) <> "none" ) {
        $items[$news]["status"] = $_POST["status"];
    } else {
        unset($items[$news]["status"]);
    };
}



/***
 * Write the array project_news to the news file.
 *
 * Also then invoke ../user/news_frontpage.php to generate a new HTML
 * newbox file.
 */

function news_write_file(&$items, $file, &$news_filetime) {
  //echo "<br>Trying to write news to $file, with timestamp $news_filetime<br>\n";

    $ret="";
    // create output
    $output  =  "<?php\n//\n//  Project News for ". PROJECT ."\n";
    $output .= "//  Last updated on ". gmdate("D, d M Y H:i:s") . " GMT \n//\n";
    $output .= "//  Note! You no longer need to edit this file by hand!\n";
    $output .= "//  You can instead (if you wish) use ";
    $output .= MASTER_URL . "ops/news_admin.php \n//\n\n";
    
    $output .= "\$project_news = array(\n";

    for ($n = 0, $no = count($items) ; $n <$no; $n++) {
        $output .= "    array(";
        $gap = "\"";
        foreach ($items[$n] as $key => $value) {
	    // uncomment the next line to remove old-style indexed items
            //if ( $key <= "9") continue;
            $output .= $gap.$key."\" => \"".news_replace_chars($value);
            $gap = "\",\n        \"";
        }
        $output .= "\"\n    ),\n\n";
    }
    $output .= ");\n?>";


    //echo "4) Got here! output=<pre>output suppressed</pre><br>";
    // create lockfile, check, and write newsfile

    $lockfile = get_path(""); // $news_file);
    //echo "4.1) Got here! lockfile=$lockfile <br>";
    // fopen w/ "x" only works in php >4.3.2
    if( ($fd_lockfile = @fopen($lockfile, 'r')) <> FALSE ) {
      if( @filemtime($lockfile) < time()-5 ) { }
      $ret = "MsgNoLock";
    }
    else {
      $fd_lockfile = fopen($lockfile, 'w');
      // copy the existing news file to a backup
      $backup_file=basename($file, '.inc');
      $backup_file= "../cache/".$backup_file."-".gmdate('YmdHi');
      if( copy($file, $backup_file) == FALSE ) {
        error_log("Could not copy news file $file to $backup_file");
	$ret = "MsgNoBack";
      }
      else { 
        // open the file to write 
	if( ($fd_newsfile = @fopen($file,"w")) == FALSE ) {
	  $ret = "MsgNoWrite";
	}
	else {
	  // write to the file, and close it
	  if( !@fwrite($fd_newsfile, $output) ) {
	    $ret = "MsgNoWrite";
	  }
	  @fclose( $fd_newsfile );
	}
      }
      @fclose($fd_lockfile);
      unlink( $lockfile );
    }

    if( $ret <> "" ) {
      $news_filetime = @filemtime($news_file);
      @include($news_file);
    }


    // regenerate HTML news box

    ob_start();

    echo " <TD class='frontpage_news'>
    <h3><a href='rss_main.php'><img align='right' src='images/rss+xml.gif'></a>
       ".tr(NEWS). "</h3>
    ";

    global $newsbox_file;
    global $project_news;

        
    echo show_news($project_news, CURRENT_NEWS_ITEMS);

    if (count($project_news > CURRENT_NEWS_ITEMS)) {
        echo "\n<span style='float:right;'><a href='old_news.php'>
	     News archive...</a></span>\n";
    }

    /******NOW DISABLED - icon is now at the top
    echo  "<span style='float:left;'>
    <a href='rss_main.php'> ". PROJECT." News via RSS</a></span>\n";
    *****/

    echo "\n</TD>\n";

    $x = ob_get_clean();
    if( $x && $h = fopen($newsbox_file, "w", 0775) ){
        fwrite($h, $x);
        fclose($h);
    }
    else {
        error_log("! ERROR: could not write to newsbox file $newsbox_file ");
    }
    ob_end_flush(); 


    return $ret;
    //   echo "8) Got here! <br>";
}
?>
