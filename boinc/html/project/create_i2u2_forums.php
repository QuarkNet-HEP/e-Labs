#!/usr/local/bin/php
<?php

/* Run this script once from PHP via the command line to create 
 * the Help Desk and discussion forums (rooms). 
 *
 * This properly lives in html/project not html/ops, as it is very
 * project specific.
 *
 * This needs to be replaced by a web form interface someday!
 *
 * Eric Myers <myers@vassar.edu> - 18 January 2006
 */

require_once("../project/forum_ops.php");   // functions moved here

db_init();		// gotta have Database access for this


//=================================================================
// Reminder:   create_category($orderID, $name, $is_helpdesk)
//             create_forum($category, $orderID, $title, $description)
//
// categories and forums (rooms) are arranged in ascending $orderID





if(0){
  delete_category("Public Areas");
  delete_category("Meeting and Discussion Rooms");
  delete_category("Private Areas");
  delete_category("Help Desk: General Issues");
  delete_category("Help Desk: Audio/Visual Issues");
 }


// Broad categories first!


if(0){
  $public = create_category(0, "Public Areas", 0);
  $room   = create_category(5, "Meeting and Discussion Rooms", 0);
  $private= create_category(10,"Private Areas", 0);

  $help   = create_category(1, "Help Desk: General Issues", 1);
  $avhelp = create_category(5, "Help Desk: Audio/Visual Issues", 1);
 }



if( !isset($public) )   $public=find_category("Public");
echo "Public area is category ". $public. "\n";


// Public Areas

if (0) { 
  create_forum($public, 1, "The Front Desk",
	       "This is the reception area for visitors and new members, 
		and a place to ask general questions that do not fit elsewhere. ");

  create_forum($public, 5, "The Bulletin Board",  
	       "This area is for Announcements and RSS News.");

  create_forum($public, 9, "Help!",
	       "This is a discussion room where anybody can ask 
		a question and get some help.  <b>You can also visit 
		the Helpdesk</b>");

  create_forum($public, 13, "The A/V Room",
	       "This is a discussion room for Audio/Video issues, 
		including teleconferencing and web lectures."
	       ."<br><b>You can also visit the A/V Helpdesk, 
		or the Wiki.</b>");

  create_forum($public, 17, "The Cafe",
	       "This is a room for discussions of a more philosophical 
		nature, or for broader, less specific topics.");

  create_forum($public, 21, "The Playground",
	       "This is the place for lighter stuff like funny stories
		or goofy images.  If you want to play around, this is 
		the place for it.");
 }



// Meeting and Discussion Rooms

if( !isset($room) ) $room =find_category("Meeting");
echo "Meeting Rooms are category ". $room. "\n";


if (0) {	
  create_forum($room, 0, "The Aquarium Room",
	       "Named for the Fermilab meeting room in which the I2U2 
	kickoff meeting was held, this room is for follow up discussion 
	from that meeting.");

  create_forum($room, 5, "The Forum Shops",
	       "This room is for discussions about these meeting rooms, 
	especially about how they might be altered to better support 
	e-Labs and i-Labs.");

  create_forum($room, 10, "Cosmic Ray's Diner",
	       "This room is for QuarkNet cosmic ray e-Lab development 
 	and related activities.");

  create_forum($room, 15, "The ROOT Cellar",
	       "This room is for common development of ROOT based Grid 
	tools for e-Labs and i-Labs.");

  create_forum($room, 20, "The Gladstone Room",
	     "This room is for LIGO e-Lab development based on the 
	microseism project conducted between LHO and Gladstone High School");

  create_forum($room, 25, "The Cascade Room",
	       "This room is for development of LIGO e-Labs based 
	primarily on seismic data.");



}


// Private Areas (or at least they will be someday)

if( !isset($private) ) $private =find_category("Private");
echo "Private Rooms are category ". $private. "\n";

if (isset($private) && 0) {
  create_forum($private, 2, "The Teacher's Lounge",
	       "This is a teachers-only area for pedagogical discussions 
		and e-Lab development.");

  create_forum($private, 6, "The Office",
	       "Hidden back behind the Front Desk,
		this room is for site administrators only.");

  create_forum($private, 10, "The Boiler Room",
	       "Hidden down in the basement, this room is for developers only.
		They use it to discuss the nuts & bolts of
		the I2U2 site and tools.");
}

// General Helpdesk

if( !isset($help) ) $help =find_category("Help Desk: General");
echo "Help Desk is category ". $help. "\n";


if (isset($help) && 1) {
  create_forum($help, 5, "Helpdesk: General Issues",
	       "Questions and Answers on general issues,
	or on anything that does not fit anywhere else.");

  create_forum($help, 10, "Helpdesk: Twiki tools",
	       "Questions and Answers about using the Twiki areas.");
 }


// A/V Helpdesk


if( !isset($avhelp) ) $avhelp =find_category("Help Desk: Audio");
echo "A/V Help Desk is category ". $avhelp. "\n";

if (isset($avhelp) && 1) {
  create_forum($avhelp, 5, "Teleconferencing",
	       "Questions and Answers about teleconferincing tools.");

  create_forum($avhelp, 10, "Web Lectures",
	       "Questions and Answers about on-line lectures.");
}


?>
