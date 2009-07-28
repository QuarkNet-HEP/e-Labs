<?php
/*****************************************************************\ 
 * message.php -  Status/Message area functions
 *
 * Don't use `echo` to show a message to the user, use these functions.
 *
 * Messages show up in a box at the top of the screen.
 * They can be normal (black text) or warning (orange) or errors (red)
 * They can be 'once only' or 'persistent' (blue)
 * They can be added from any script via the API defined here.
 *
 * Eric Myers <myers@spy-hill.net  - 24 April 2006
 * @(#) $Id: messages.php,v 1.18 2009/03/24 15:28:18 myers Exp $
\***********************************************************************/

require_once("util.php");        // TLA utilities
 
define('MSG_NORMAL', 0);        // most messages
define('MSG_GOOD',   1);        // success messages
define('MSG_INFO',   2);        // supplemental
define('MSG_WARNING', 3);       // warnings in orange
define('MSG_ERROR',   4);       // errors in red
define('MSG_DEBUG',   5);       // debug level or debug_msg converts?

$messages_shown=false;

/*******************************
 * Status Message objects
\*/

class Status_Message{
  var $text;    // the text of the message
  var $level;   // message level: normal, info, warning, error, debug
  var $Nshow;    // =1 to show once, =999 to show 'always'
  var $is_shown;  // has it been shown?

  function Status_Message($text, $level=1, $Nshow=1){//  Constructor
    $this->text=$text;
    $this->level=$level;
    $this->Nshow=$Nshow;
    $this->is_shown=false;
  }
}// End class Status_Message



function add_message($text,$level=MSG_NORMAL,$n=1){
  global $msgs_list;
  $msgs_list[] = new Status_message($text, $level, $n);
  //  remember_variable('msgs_list');
}



/**
 * The status messages will be in an array of objects.
 * Each message has text and a display status...
 */

function show_message_area(){
  global $user_level, $main_steps;
  global $msgs_list, $messages_shown;
  global $status_msg; 

  if( !isset($msgs_list) )  recall_variable('msgs_list');

  //delete old messages before checking if the list is empty
  if( !empty($msgs_list) ){
    foreach ($msgs_list as $i=>$msg){

      if( $msg->Nshow < 1 ) {      // remove old messages
        debug_msg(5,"Need to delete message $i from list.");
        unset($msgs_list[$i]);
      }
    }
  }
  
  if (empty($msgs_list) && empty($status_msg) && (empty($main_steps) || $user_level > 1)) {
  	return;
  }

  // Box height varies with user level
  if( $user_level == 1) $ht = 120;
  if( $user_level == 2) $ht = 90;
  if( $user_level > 2)  $ht = 60;

  echo "<div class=\"control\">\n";

  echo "   <TABLE class=\"textarea\" height=\"$ht\">
           <TR><TD class='message-area'>\n";

  // Beginners get the block diagram  at every step...

  if( $user_level==1 && !empty($main_steps) ){
     echo "<font color='black'>
          Follow the above steps to complete your analysis.</font><br>\n";
      echo "Further details may be found in the 
		<a target='_tutorial' href='tutorial.php'
		   title='Open the tutorial in another window'>Tutorial</a>
		<font size='-1'>(opens a new window)</font>\n";
      echo "<P>\n";      

    }


  // New style:  dump the list from the array

  if( !empty($msgs_list) ){
    foreach ($msgs_list as $i=>$msg){
      switch($msg->level){
      case MSG_GOOD:
        $color='GREEN';
        break;
      case MSG_WARNING:
        $color='ORANGE';
        break;
      case MSG_ERROR:
        $color='RED';
        break;
      default:
        $color='BLACK';
      }
      echo "<font color='$color'>\n$msg->text   ";
      //echo " [" .$msgs_list[$i]->Nshow. "] ";
      echo "\n </font><br>\n   ";
      if(!$messages_shown) $msgs_list[$i]->Nshow--;
    }
    remember_variable('msgs_list');   // save any changes we made
  }

  // Old style: just show accumulated  $status_msg.   
  // (This should go a way once we've removed $status_msg everywhere.)
  // ((Which is pretty close to being done.  -EAM 06Feb2009))

  if( !empty($status_msg) ) {
    echo "<hr> <font color='purple' size='-1'>Old Style messages:<br>
        $status_msg 
        </font>\n";
  }

  echo   "\n   </TD></TR></TABLE>\n    ";
  echo "</div>\n";

  $messages_shown=true;  // flag for debug messages
}

$cvs_version_tracker[]=        //Generated automatically - do not edit
    "\$Id: messages.php,v 1.18 2009/03/24 15:28:18 myers Exp $";
?>
