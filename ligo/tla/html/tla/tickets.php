<?php 
/***********************************************************************\
 * Cross Site authentication "tickets"
 *
 * This file is implementation code, not presentation code.
 * No direct user output should be generated.
 * Use add_message() to show something to the user.
 *
 * Eric Myers <myers@spy-hill.net  - 20 June 2006
 * @(#) $Id: tickets.php,v 1.3 2008/07/17 14:54:59 myers Exp $
\***********************************************************************/


if( empty($ticket_file) ){
    $ticket_file= $TLA_TOP_DIR."/var/tickets.txt";
 }



/**
 * Returns a random code of the specified length, containing characters
 * that are equally likely to be any of the digits, uppercase letters,
 * or  lowercase letters.
 *
 * The default length of 10 provides 839299365868340224 (62^10) possible codes.
 *
 * NOTE: Do not call wt_srand().  It is handled automatically in PHP 4.2.0 and
 *       above and any additional calls are likely to DECREASE the randomness.
 *
 * Originally due to to sean@codeaholics.com, as posted to the discussion
 * about mt_rand() on www.php.net
 */

function randomCode($length=10){
    $retVal = "";
    while( strlen($retVal) < $length ){
        $nextChar = mt_rand(0, 61); // 10 digits + 26 uppercase + 26 lowercase = 62 chars
        if( ($nextChar >=10) && ($nextChar < 36) ){ // uppercase letters
            $nextChar -= 10; // bases the number at 0 instead of 10
            $nextChar = chr($nextChar + 65); // ord('A') == 65
        } else if( $nextChar >= 36 ){ // lowercase letters
            $nextChar -= 36; // bases the number at 0 instead of 36
            $nextChar = chr($nextChar + 97); // ord('a') == 97
        } else { // 0-9
            $nextChar = chr($nextChar + 48); // ord('0') == 48
        }
        $retVal .= $nextChar;
    }
    return $retVal;
}


/**
 * Generate a long random number for verification (a 'ticket')
 */

function new_ticket_code(){
    $x = randomCode(16);
    $_SESSION['ticket'] = $x;
    $_SESSION['ticket_time'] = time();
    return $x;
}


/**************************
 * Ticket object:  (unused, so far)
 */

class Ticket{
    var $code;        // ticket code number
    var $timestamp;   // when created
    var $ttl;         // time to live  
    var $IP_addr;     // IP address of user when created  
    var $server_name; // name of server where created
    var $auth_type;   // type of authentication used
    var $uid;         // userid of owner
    var $authenticator;  // authenticator of owner
    var $username;    // personal name of owner
    var $institute;   // affiliation of owner

    // Constructor: 
    function Ticket(){
        $this->code=new_ticket_code();
        //TODO: fill in what's below
        return $this;
    }

    // Registering the ticket puts it into the database (sends ahead)
    function register(){
        global $user_level;

        $now=time();
        $cmd  = "echo $now " . $this->IP_addr." ".$this->code;
        $cmd .= " ".$this->code." ".$this->auth_type;
        $cmd .= " ".$this->uid." ".$this->authenticator;
        $cmd .= " \\\"".$this->username."\\\" ".$user_level;
        $cmd .= " ".$this->server_name." \\\"".$this->institute."\\\"";
        $cmd .=" |/usr/bin/ssh myers@tekoa.ligo-wa.caltech.edu "
                ." \"cat >>/home/www/etc/tickets.txt\" ";
        $cmd .=" & >/dev/null"; 
        debug_msg(3,"% $cmd");
        $txt = exec($cmd,$out,$rc);
        if($rc) add_message("Non-zero return code from ticket forwarding. RC=".
                        $rc, MSG_ERROR);
        else debug_msg(2, "Ticket sent ahead to tekoa via secure channel: $ticket");
    }
}
/***************end of class************/



/**
 * Creating a new ticket (and send it ahead)
 */

function make_new_ticket(){
    global $user_level;
    global $logged_in_user;
    global $auth_type, $authenticator;
    global $user_IP, $local_server;

    $ticket = new_ticket_code();

    if( $auth_type == 'BOINC' ){// get user info for the ticket
        db_init(); // this needs the proper db prefix?
        $uid = $logged_in_user->id;
        $username = $logged_in_user->name;
        if( function_exists('lookup_team') ){
            $team=lookup_team($logged_in_user->teamid);
            $institute=$team->name;
            debug_msg(2,"User affiliation: $institute");
        }
    }

    $now = time();
    if( empty($user_level) ) $user_level=1;
    $server_name = $_SESSION['server_name'];  

    // insert the ticket into the secure database (straw version)

    $cmd = "echo $now $user_IP $ticket  $auth_type $uid $authenticator ";
    $cmd .="\\\"$username\\\" $user_level $local_server \\\"$institute\\\" ";
    $cmd .="|/usr/bin/ssh -v myers@tekoa \"cat >>$ticket_file\" ";
    $cmd .=" & >/dev/null"; 
    debug_msg(3,"% $cmd");
    $txt = exec($cmd,$out,$rc);
    if($rc) add_message("Non-zero return code from ticket forwarding. RC=".
                        $rc, MSG_ERROR);
    else debug_msg(2, "Ticket sent ahead to tekoa via secure channel: $ticket");
    return $ticket;
}



/**
 * Get any ticket (number) the user has for the session, via GET or POST
 */

function get_ticket(){
    $got_ticket=NULL;
    if( isset($_GET['ticket']) ){
        $got_ticket = $_GET['ticket'];
    }
    if( isset($_POST['ticket']) ){ // this will override GET
        $got_ticket = $_POST['ticket'];
    }
    return $got_ticket;
}    




/**
 * Check that a ticket presented via web matches one in our list
 * Returns TRUE if everything is okay, FALSE if the match fails
 * for any of a number of reasons. 
 */

function check_ticket($got_ticket=NULL){
    global $ticket_file;
    global $user_IP;
    global $authenticator, $auth_type;
    global $logged_in_user;

    if( !$got_ticket ) $got_ticket=get_ticket();
    if( empty($got_ticket) ) {
        debug_msg(3,"No ticket presented.");
        return FALSE;
    }
    debug_msg(3,"Presented with ticket $got_ticket");

    // Look up the ticket in the current list

    $cmd="grep $got_ticket $ticket_file  | /usr/bin/tail -1";
    debug_msg(2,"% $cmd");
    $result = shell_exec($cmd);
    if( empty($result) ) {
        debug_msg(3,"Did not find ticket $got_ticket on file.");
        return FALSE;
    }
    debug_msg(2,"Ticket entry: $result"); 

    // Parse the ticket list entry for this ticket.  Example:
    //1173128501 204.210.158.6 zd70qQdFZ7izZKOD BOINC 1 $auth "Eric Myers" 1 i2u2.spy-hill.net "LIGO Hanford"

    $tickets_match=FALSE;  

    ////               time    IPaddr  ticket  ////
    $ticket_pattern="/^(\d+)\s+(\S+)\s+(\S+)(.*)$/";
    $n=preg_match($ticket_pattern,$result,$matches);
    if( $n<1 ) {
        debug_msg(2,"1) Cannot parse ticket time, IP, etc..");
        return;
    }
    list($all, $timestamp, $ip_addr, $ticket_on_file, $rest)
        = $matches;
    debug_msg(2," Extracted: $timestamp [$ip_addr] $ticket_on_file ");

    if( empty($timestamp) || (time()-$timestamp) > MAX_TICKET_AGE ) {
        debug_msg(1,"Invalid or expired timestamp on ticket: $timestamp");
        return FALSE;
    }

    if( empty($ticket_on_file) || $ticket_on_file != $got_ticket ) {
        debug_msg(1,"Tickets do not match: $ticket != $ticket_on_file");
        return FALSE;
    }

    $user_IP=$_SERVER['REMOTE_ADDR']; 
    if( $ip_addr != $user_IP ){
        debug_msg(1,"IP addresses do not match: $ip_addr != $user_IP");
        return FALSE;
    }


    // Extract user info from the ticket on file

    debug_msg(2,"Rest: $rest");

    /////////////     type    UID      auth      "user name"
    $ticket_pattern="/(\S+)\s+(\d+)\s+(\S+)\s+\\\"([^\"]+)\\\"(.*)$/";
    $n=preg_match($ticket_pattern,$rest,$matches);
    if( $n<1 ) {
        debug_msg(2,"2) Cannot parse ticket auth info: $rest");
        // return FALSE;
    }
    list($all, $auth_type, $uid, $authenticator, $user_name, $rest2 ) = $matches;

    debug_msg(2,"uid=$uid, auth=$authenticator, Name: $user_name");
    debug_msg(2,"Rest: $rest2");


    ////////////      lvl    server    "institution"
    $ticket_pattern="/(\d)\s+(\S+)\s+\\\"([^\"]+)\\\"/";
    $n=preg_match($ticket_pattern,$rest2,$matches);
    if( $n<1 ) {
        debug_msg(2,"2) Cannot parse ticket user info: $rest2");
        // return FALSE;
    }
    list($all, $user_level, $server_name, $institution ) = $matches;

    if( empty($user_name) || $uid<=0 ){
        debug_msg(1,"User info not valid.  Uid: $uid   Name: $user_name");
        // return FALSE;
    }

    if( !empty($server_name) ){
        debug_msg(2,"Server name: $server_name");        
        //We could use this here to compare against HTTP_REFERER  
        //In any case, we can use $server_name to access the database there. 
    }


    /* TADA! We are in via the ticket */

    $_SESSION['authenticator']= $authenticator;
    $authenticated=TRUE;
    $auth_type='BOINC';


    //TODO: Look this person up in the database using $uid and $auth
    //      Meanwhile, fake it.
    //

    $logged_in_user->name=$user_name;
    $logged_in_user->id=$uid;
    $logged_in_user->authenticator=$authenticator;

    debug_msg(2,"Successful handoff for $user_name");
    return TRUE;
}

?>
