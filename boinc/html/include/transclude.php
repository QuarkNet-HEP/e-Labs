<?php
/***********************************************************************\
 * Page Transclusion - (hey kids, it's mashup time!)
 *
 *  Functions to support getting content from some other URI,
 *  such as a wiki page, and then inserting it into a page.
 *
 * @(#) $Id: transclude.php,v 1.5 2009/04/27 19:39:55 myers Exp $
\***********************************************************************/

// This can be set earlier, in which case we won't override
// TODO: There could be several wikis.  Allow selection.
//
if( !isset($Path_to_wiki) )  {
  $Path_to_wiki="/library";
}





// Get body of a wiki page for transclusion into another page.
// Returns the text between strings $start and $end.
// Title is added to array $gWikiTitle for tracking.
//
function get_wiki_article($title, 
			  $start = "<!-- start content -->",
			  $end = "<!-- end content -->", $path='' ){
   global $Path_to_wiki;
   global $gWikiTitle;

   debug_msg(2,"get_wiki_article($title)");

   $title = strtr($title, ' ', '_'); // space -> underscore

   $gWikiTitle[] = $title;	// save for page_tail()

   if( empty($path) ) $path = $Path_to_wiki;


  // 1. Get body from wiki

  $url ="http://" . $_SERVER['SERVER_NAME'] . $path . "/";
  $url .= "index.php?title=$title";
  debug_msg(2,"  URL: $url");
  $body = file_get_contents($url);
  
  if( empty($body) ) return NULL;

  // Extract between $start and $end 
  
  $i = strpos($body,$start);
  debug_msg(4,"  start content: $i");
  if( $i !== FALSE ){   
    $body = substr($body,$i+strlen($start));
  }
  if( empty($body) ) return NULL;

  $i = strpos($body,$end);
  debug_msg(4,"  end content: $i");
  if( $i !== FALSE ){   
    $body = substr($body,0,$i);
  }
  if( empty($body) ) return NULL;

  // Check for "There is currently no text in this page" message

  $i = strpos($body,"There is currently no text in this page");
  if( $i !== FALSE && $i > 0 && $i < 400) return NULL;


  // Images in the wiki are linked to their wiki page.
  // Remove that link, while preserving the image

  $pattern = ',<a href=[^>]+(/|\?title=)Image:[^>]+>(<img [^>]+>)</a>,si';
  $body = preg_replace($pattern, " \\2 ", $body); 

  //FIXME: body skin returns body skin links (ie using body.php not index.php)
  // This corrects the problem, but the real fix is probably in the skin itself

  $body = preg_replace("/body.php/", "index.php", $body);

  // Output:

  $body = "\n\n<!-- Transcluded from wiki article $title -->\n\n"
	 ."<div class='wikibody'>\n$body\n</div>\n"
         ."\n<!-- end transcluded text -->\n\n";

  return $body;
}
//



/***********************************************************************\
 * FNAL and QuarkNet Specific transcluded pages.
 */


// Grab a page from the FNAL site, but dress it up as our own.
//
function show_fnal_page($url){
  global $BASEURI;

  $url_parts= parse_url($url);
  $p = $url_parts['path'];

  // 0. get the body of the requested page
  //
  $response_body = file_get_contents($url);


  // 1. Extract the <title>
  //
  $title="QuarkNet: " . basename($p);		// default

  $x = substr($response_body, 0, 200);
  if( preg_match("/<title>(.*)<\/title>/i", $x, $matches) > 0 ){
    $title=$matches[1];
    debug_msg(2,"Title is '$title'");
  }

  $body = $response_body;

  // 2. Trim off the <head>
  //
  $tag = "</head>";
  $i = strpos($body,$tag);
  if( $i!==FALSE ){   
    $body = substr($body,$i+strlen($tag));
  }

  // 3. Extract document body (stuff between <body> and </body>
  //
  $body = preg_replace("/<body[^>]*>(.*)<\/body>/", "$1", $body);


  // 4. Remove existing top navbar menu  (up to first </h5>)
  //
  $tag = "</h5>";
  $i = strpos($body,$tag);
  if( $i!==FALSE ){   
    $body = substr($body,$i+strlen($tag));
  }


  // 5. Remove top title table, if there is one 
  //    (If the first <table> contains a <h2> )
  //
  $i = strpos($body,"<table>");   // start of first table in page
  $j = strpos($body,"</table>");   // end of first table in page
  $k = strpos($body,"<h2>");      // first H2 header
  if( $k>$i && $k < $j ){	// is the H2 inside the table?
    $body = substr($body,0,$i) . substr($body,$j+8);
  }


  // 6. Monkey with the contents.
  //
  //    a) form cgi-bin links become full links to FNAL site

  $body = preg_replace('/action="\/cgi-bin\/([^"]+)"/', 
	      "action=\"http://quarknet.fnal.gov/cgi-bin/$1\"",
	      $body);


  //    b) and the form has a "return" link we need to modify
  // FIXME: this doesn't work - the cgi script still barfs.
  $body = preg_replace('/VALUE="([^_]+_ret.shtml)"/', 
	      "VALUE=\"http://quarknet.fnal.gov/$1\"",
	      $body);


  /*******
  //     c) Links to eddata.fnal.gov/lasso get rewritten to go through proxy
  $body = preg_replace("/http:\/\/eddata.fnal.gov\/lasso/",
		       "http://www.quarknet.us/lasso", 
  		       $body);
  ********/


  // Display the result as a full page
  //
  $x = dirname($p);   // relative URL for this request
  if( !empty($x) ) {
    $BASEURI = "http://" . $_SERVER['SERVER_NAME'] . $x .'/';
    debug_msg(2,"show_page.php: $p BASEURI is $BASEURI");
  }

  page_head($title);
  debug_msg(3, "Body now begins with:  <hr>"
            ." <tt><pre>" . htmlentities(substr($body, 0, 255))
	    ."</pre></tt><hr><p>");
  echo "<center>\n\n";
  echo $body;
  echo "\n\n</center>\n\n";

  echo "<P><font color='grey' size='1'>$url</font><p>\n";
  page_tail(true);
  exit;
}

?>
