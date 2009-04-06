<?php
/*  htpasswd.php  -  let users change their per-directory password
 * 
 *  This script allows an authenticated user to change their own password
 *  for a directory protected by a .htaccess file, by running the htpasswd
 *  program for them.
 *
 *  Usage: Put this script in the same directory as the .htaccess file which is
 *  protecting the directory or directory tree under it, and make sure that
 *  the password file named in the .htaccess file is writeable by the web server 
 *  daemon (often user or group 'apache').
 *
 * Eric Myers <myers@spy-hill.net>   - 21 November 2005
 * (C) Copyright 2005 by Eric A. Myers - all rights reserved
 * @(#) $Id: htpasswd.php,v 1.1 2007/02/12 18:39:54 myers Exp $
 ***********************************************************************/
// Functions:

function get_from_array($var, $array) { // avoids errors if index does not exist
  if( array_key_exists($var, $array) ) return $array[$var];
  return '';
}

function err($txt){     // simple error message display 
  echo "<P><font color='RED'>$txt </font></P>\n";
}


function begin_html($title) {
  echo "<HTML>\n<HEAD>\n<TITLE>\n". $title ."\n</TITLE></HEAD><BODY>\n";
  echo "<H1>  ".$title ."</H1>\n";
}

/* end_html() ends the page, possibly with a link back to the page
 * we were called from  */

function end_html(){
  global $orig_referer;
  if( $orig_referer ) {
    echo "<P><a href='" .$orig_referer.
      "'>Click here to go back to what you were doing...</a></P>\n";
  }
  echo "\n</BODY>\n</HTML>\n";
}

/* is_good_passwd(passwd) runs various tests on a password to see that it is okay,
 * and displays an error message if it's not (and returns FALSE);
 * Feel free to add tests to this to implement local policy.  */

function  is_good_passwd($passwd){
  if( strlen($passwd) < 6) {
    err("A password must have at least 6 characters.");
    return FALSE;
  }
  return TRUE;
}


/* change_dir_passwd(user,passwd) finds the password file from the .htaccess
 * file it finds in the same directory as the script itself, and then invokes
 * the htpasswd command to change the user's password. */

function change_dir_passwd($user, $passwd) {
    //  $my_path =  get_from_array('PATH_TRANSLATED',$_SERVER);
    //  $my_dir = dirname($my_path);
    //  $ht_access = $my_dir . "/.htaccess";
    $ht_access = ".htaccess";
    if( !file_exists($ht_access) ) {
        err("The access file " .$ht_access. " does not exist.");
        return(1);
    }

  // Read through the .htaccess file for AuthUserFile

  $fh = fopen($ht_access,"r");
  $ht_passwd='';        // empty means not found
  while ( $line = fgets($fh, 132) ) {
    $line = ltrim(preg_replace("/^(.*)#(.*)$/", "$1", $line));  // strip # comments  
    if( trim($line=='') ) continue;             // skip empty lines
    $tok = preg_split("/\s+/", $line);          // split line into tokens
    if($tok[0]=="AuthUserFile") {
      $ht_passwd = $tok[1];
      break;                                    // use first one we find
    }
  }
  fclose($fh);

  if( !$ht_passwd ){
    err("No password file could be found in the .htaccess file.<br>
         This is likely a server or script configuration error.");
    return(2);
  }

  if( !file_exists($ht_passwd) ) {
    err("The password file " .$ht_passwd. " does not exist.<br>
         This is likely a server or script configuration error.");
    return(3);
  }

  // Give the htpasswd -b command to change the user's password

  $cmd = "/usr/bin/htpasswd -b -m " .$ht_passwd. " " .$user. " " .$passwd ;
  $emg1 = system($cmd, $rc);
  if($rc != 0) {
    switch($rc) {
    case 1:
      $emg2 = "File access problem.";
    break;
    case 2:
      $emg2 = "Syntax error on command line.";
    break;
    case 4:
      $emg2 = "Operation interupted.";
    break;
    case 5:
      $emg2 = "A value is too long (username, filename, password, or final
                computed record)";
    break;
    case 6:
      $emg2 = " Username contains illegal  characters. ";
    break;
    }
    err("Error (".$rc."): &nbsp;  $emg2 <br>\n $emg1");
  }
  return($rc); 
}


//
/************************
 ** BEGIN:
 */


$ref = get_from_array('HTTP_REFERER', $_SERVER);
// this script POST's to itself
$self = "http://" . strtolower($_SERVER['SERVER_NAME']) . $_SERVER['PHP_SELF']; 
// save original referer, as long as it is not the script itself, if there is one
if( $ref != '' && $ref != $self ) $orig_referer = $ref;   

$user =  get_from_array('PHP_AUTH_USER',$_SERVER);
$oldpw = get_from_array('PHP_AUTH_PW',$_SERVER);

begin_html("Change Directory Password");
echo "\n<hr><P>\n";

// Can't change the password if we are not using them

$auth_type = get_from_array('AUTH_TYPE',$_SERVER);

if ( $auth_type == '') {
  err("Directory passwords are not in use here, 
                so you cannot change your password.");
  end_html();
  exit;
}


if ( $auth_type != "Basic" ) {
  echo "<P>Authentication method: AUTH_TYPE = " . $auth_type;
  err("You need to authenticate with a password in order to change your 
        directory password this way.");
  end_html();
  exit;
}


// Can't change the password unless you are logged in with the old one

if( !$user && !$oldpw ) {
  err(" <h2> You are not logged in. </h2> 
        </font><font color='BLACK'> 
        You must be authenticated to the server using a username and 
        password in order to change your directory password.");
  end_html();
  exit;
}

echo "Changing directory password for user <font color='BLUE'> " .$user.  
"</font> <P>\n";

// Did the user already post an answer?

$posted = get_from_array('posted',$_POST);     // flags we have submitted the form
$passwd1 = get_from_array('passwd1',$_POST);
$passwd2 = get_from_array('passwd2',$_POST);
$passwd3 = get_from_array('passwd3',$_POST);
$ref = get_from_array('orig_referer',$_POST);  // save where we came from 
if( $ref != '' && $ref != $self ) $orig_referer = $ref;   


// Check for valid password combination, and if all is okay then make the change

if( $posted != '' ) {
  if( $passwd1 == '' ) { // form submitted w/o passwd?
    err("Please enter your old password for authentication.");
  }
  else {
    if( $passwd1 != $oldpw && $passwd1 != '' ) {
      err("The old password you entered was not correct.");
      $passwd1='';  // reset it
    } else {
      if ( $passwd2 == '' ) {
        err("Please enter a new password (twice for verification).");
      } else {
        if( $passwd2 != $passwd3 ) {
          err("The two passwords you entered do not match.");
        } else {
          if( is_good_passwd($passwd2) ) {
            $rc  = change_dir_passwd($user,$passwd2);
            if($rc!=0) {
              err("Your password was not changed.");
            }
            else {
              echo "<blockquote>
                <h2><font color='GREEN'>Your password has been changed. </font></h2>
                </blockquote>\n";
              echo " <P>To continue you will need to re-validate using the
                        new password.</P>\n";
              echo "<P><a href='basic_auth.php?next_url=".$orig_referer."'
                  >Click here to re-validate using the new password...</a>
                  </P>\n";
              echo "\n</BODY>\n</HTML>\n";
              exit;
            }
          }
        }
      }
    }
  }
}

// Show the form (again?) to get password input

echo "<FORM method='post' action='" .$self. "'>  
   <TABLE>
     <TR><TD>Old Password:</TD><TD>
        <INPUT type='password' name='passwd1' value='".$passwd1."'></TD></TR>
     <TR><TD>New Password:</TD><TD>   <INPUT type='password' name='passwd2'></TD></TR>
     <TR><TD>Verify New:  </TD><TD>   <INPUT type='password' name='passwd3'></TD></TR>
   </TABLE>
   <P>
   <INPUT type='hidden' name='posted'  value='YES'>
   ";

// If we know the original refering page then link back to it...
if( $orig_referer ) {
  echo "<INPUT type='hidden' name='orig_referer'  value='" .$orig_referer. "'>\n";
}

echo "    <INPUT type='submit' value='Change password...'>
        </FORM>\n";

end_html();

?>
