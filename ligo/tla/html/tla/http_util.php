<?php
/***********************************************************************\
 * HTTP response processing - generic stuff  
 * 
 * Functions to aid processing responses from http_post_fields() 
 * and http_get().   
 *
 * Moved from Bluestone's elab_interface.php to this file.
 * Stuff here should be generic for the HTTP protocol, not
 * specific to Bluestone.
 *
 * Eric Myers <myers@spy-hill.net>  - 14 November 2008
 * @(#) $Id: http_util.php,v 1.3 2009/01/29 19:56:16 myers Exp $
\***********************************************************************/

// Take a response from http_post_fields() and break it up
// into $headers and $body (be advised: headers use ^M^J as per RFC 1945!)
// Extract the status code from the headers (if we can) and return that value.
// Headers and body are returned via reference.
//
function parse_http_response($response, &$headers, &$body){
    if( empty($response) ) return NULL;

    $i = strpos($response,"\r\n\r\n",1); // offset avoids initial \r\n
    if($i === FALSE ){
        $headers = $response;
        $body = "";
        debug_msg(3,"parse_http_reponse(): NO BODY!"); 
    }
    else{
        debug_msg(4,"parse_http_response: Found header break at $i");
        $headers = substr($response, 0, $i+2);  // includes final \r\n
        $body =  substr($response, $i+4);       // past \r\n\r\n
    }

    // Extract status code
    //
    $pattern = "/^HTTP\/(\d)\.(\S) (\d\d\d) (.*)/m";
    if( preg_match($pattern, $response, $matches) >0 ) {
        list( $all, $http_major, $http_minor, $status, $msg ) = $matches;
        if( !is_numeric($status) ) $status = NULL;
    }
    return $status;
}


/**
 * Show raw headers and body, if we have them
 */
 
function display_http_response($response_headers,$response_body){
    global $debug_level;

    if( $response_headers ){
        controls_next();
        echo "<b>Response headers:</b><br>
          <TABLE width='100%' bgcolor='white' border=4>
           <TR><TD>";
        echo "<pre>";

        // Turn \r and \n into printables
        //
        $response_headers = preg_replace("%\r%","\\r",
                                         $response_headers);
        $response_headers = preg_replace("%\n%","\\n\n",
                                         $response_headers);
        echo htmlentities($response_headers);
        echo "\n</pre>\n";
        echo "</TD></TR>\n</TABLE>\n";
    }

    if( $response_body ){
        controls_next();
        echo "<b>Response body:</b><br>
          <TABLE width='100%' bgcolor='white' border=4>
           <TR><TD>";
        echo "<pre>";
        echo htmlentities($response_body);
        echo "\n</pre>\n";
        echo "</TD></TR>\n</TABLE>\n";
    }
}

?>
