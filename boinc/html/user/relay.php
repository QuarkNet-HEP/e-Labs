<?php
/***********************************************************************\
 * @package Tool, LIGO Analysis 
 *
 * relay.php  - redirect user's session to another server
 *
 * This script handles redirecting an authenticated session on one
 * server to a corresponding session on a remote server.
 * It also handles the receiving end of the handoff, though in future
 * that will also be built in to the authentication mechanism used by 
 * every page.
 *
 * Session authentication credentials are passed to the other
 * server through a back channel (currently ssh), and then the user's browser 
 * is redirected to that server and starts a (new, continued) session there.
 *
 * Ideally the redirection is automatic, but we also provide direct
 * links (for POST and GET methods) and a Refresh, just in case.
 *
 * Eric Myers <myers@spy-hill.net>  - 20 June 2006
 * @(#) $Id: relay.php,v 1.1 2007/09/27 16:43:04 myers Exp $
\***********************************************************************/

$src_path='../tla/';

require_once("../tla/macros.php");             // general utilities


/***********************************************************************\
 * Action:
\***********************************************************************/

$next_url = get_destination();
$next_url = fill_in_url($next_url);


/* Deal with shortcut of just relay.php?filename.php */

if( empty($next_url) ){
    $x = parse_url($URI);
    if( !empty($x['query']) ) {
        $x =basename($x['query']);
        if( file_exists($x) ){ // valid filename in this collection?
            $next_url= fill_in_url(dirname($self).'/'.$x);
        }
    }
 }


/* Default final destination, if none given */

if( empty($next_url) ){
    $next_url  = "http://tekoa.ligo-wa.caltech.edu/tla" .$this_dir;
     $next_url .=  "data_flow.php";
    debug_msg(2,"No next_url specified, default to $next_url");
 }


/* Authentication required.  If user is already authenticated then go on.
 * If not, ask them to login on the main discussion site first.
 * They should end up back here with next_url set to the final destination.
 * (TODO: check this) */

$authenticated = check_authentication();

if( !$authenticated ){//TODO: || $auth_type='Basic' ? ){//
    debug_msg(2, "$hostname: user not yet authenticated");

    $url= "http://".$local_server.$this_dir. "login_form.php";
    if( $host=='tekoa' ) {
        $url= "http://i2u2.spy-hill.net".$this_dir. "/relay.php";
    }
    if( !empty($next_url) ) $url .= "?next_url=$next_url";

    debug_msg(2, "   redirecting to $url...");
    header("Location: $url ");
    exit(0);
 }


/* We are authenticated *here*. Good. */

debug_msg(3,"relay.php: authentcation accepted: $auth_type");
debug_msg(2, "  Local server is $local_server");


/* If the URL is on THIS server then just go there */

if( $host == $local_server && !empty($next_url) ) {
    $url = $next_url;
    debug_msg(2,"Local location: $url");
    header("Location: $url ");
    exit(0);
}

debug_msg(2, "  It's a non-local relay to $host");



/**********
 * Jumping to remote server?  Generate a new ticket if necessary
 * and send it ahead via the back channel.
 */

recall_variable('ticket_time');
if( (time()-$ticket_time) < MAX_TICKET_AGE
        && array_key_exists('ticket',$_SESSION) ) {
    recall_variable('ticket');
    debug_msg(2,"We already have a ticket on record: $ticket".
              "  Ticket age: ".(time()-$ticket_time));       
 }

if( empty($ticket) ){ // make a new ticket and send it
    if( $auth_type == 'BOINC' ){// get user info for the ticket
        db_init();
        $uid = $logged_in_user->id;
        $username = $logged_in_user->name;
        if( function_exists('lookup_team') ){
            $team=lookup_team($logged_in_user->teamid);
            $institute=$team->name;
            debug_msg(2,"User affiliation: $institute");
        }
    }

    $ticket = make_new_ticket();
    $now = time();
    if( empty($user_level) ) $user_level=1;

    $cmd = "echo $now $user_IP $ticket  $auth_type $uid $authenticator ";
    $cmd .="\\\"$username\\\" $user_level \\\"$institute\\\"  | ";
    $cmd .="/usr/bin/ssh -v myers@tekoa \"cat >>/home/www/etc/tickets.txt\" ";
    $cmd .=" & >/dev/null"; 
    debug_msg(3,"% $cmd");
    $txt = exec($cmd,$out,$rc);
    if($rc) add_message("Non-zero return code from ticket forwarding. RC=".
                        $rc, MSG_ERROR);
    else debug_msg(2, "Ticket sent ahead to tekoa via secure channel: $ticket");
 }

/* Now send them on to the remote site */

if( !empty($next_url) ){
    $url  = $next_url;
    if( !empty($ticket) ) $url .= "?ticket=$ticket";
    debug_msg(1, "Relay url: $url");
    header("Location: $url ");
    exit;
    $ttl = 7;
    header("Refresh: $ttl ; $url ");
    debug_msg(1, "Refresh in $ttl seconds....");
 }


/***********************************************************************\
 * Display Page:
\***********************************************************************/

html_begin("Relay");

//show_message_area();

if( empty($next_url) ) {
    echo "<P>Error: no place to send you
        <P>
        Please report this to the developer:
        <a href='mailto:Eric.Myers@ligo.org'>Eric.Myers@ligo.org</a>
        <P>
        Sorry about that.
        <P>\n";

 }
 else {
     echo "<P>You should have been forwarded to
        <blockquote>
        <a href='$url'>$url</a>
        </blockquote>
        You can try the link directly; it may or may not work.
        ";




     echo "<h2>Make the Jump by hand</h2>
          </form>
          <form method='POST' action='$url'>
          Press the button to make the jump to $url
          <br/>
          <input name='ticket' type='hidden' value='$ticket'>
          <input name='next_url' type='hidden' value='$next_url'>

          <input type='submit' value='Go'>
          </form>
          ";
 }


echo "\n\n<hr>\n\n";

if(0){
echo "<h2>Session Information:</h2>
        <blockquote><tt>\n";
flush();

echo "PHP Session ID: ". session_id()."\n";
echo "<br>\n";
echo "User Name: $username (user $uid)\n";
echo "<br>\n";

echo "Auth type: $auth_type \n<br>\n";
echo "Authenticator: $authenticator \n<br>\n";

echo "REQUEST URI:  $URI \n<br>\n";
echo "Local server:  $local_server \n<br>\n";
echo "PHP_SELF:  $self\n<br>\n";
echo "REFERER: $referer \n<br>\n";
echo "next_url=$next_url\n<br>\n";

echo "<P>\n";
if( $dest !== FALSE ){
  echo "destination host: ".$dest['host']."\n<br>\n";
  echo "destination path: ".$dest['path']."\n<br>\n";
  echo "destination query: ".$dest['query']."\n<br>\n";
  echo "destination fragment: ".$dest['fragment']."\n<br>\n";

 }
echo "IP Address: $user_IP \n<br>\n";

echo "<br>\n";
echo "UNIQUE_ID: $uniq  (this is somewhat guessable!)\n";
echo "<br>\n";
echo "Ticket: " .$ticket." (this should not be guessable) \n";
echo "<br>\n";
echo "Authenticator: " .$authenticator." (this should be protected) \n";
 }

echo "<br>\n";
echo "Next URL: " .$url;
echo "<br>\n";

echo "</tt></blockquote>\n\n";


if(0){
echo "SESSION:<pre> "; 
echo print_r($_SESSION,true);
echo "</pre>\n";
 }


/*******************************
 * DONE:
 */

tool_footer();
html_end();
?>

