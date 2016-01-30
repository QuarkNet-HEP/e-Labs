<?php

require_once('../inc/db.inc');
require_once('../inc/util.inc');
require_once('../inc/translation.inc');

require_once('../project/extras.php');



/***************************************************\
 * Functions
\***************************************************/

function sect_head($text, $name=''){
  echo "\n<P>\n";
  if($name!=''){
    echo "\n<a name='" .$name. "'>\n";
  }
  echo "  <h3 class='help' >$text</h3> \n"; 
}


/***************************************************\
 * DISPLAY page content
\***************************************************/

$hide_user=1;
page_head(PROJECT . "  Help");

/* 
 * Topic Table
 */

echo "<TABLE  align='RIGHT' class='topics border' style='margin: 1em; padding: 1em;'>
	<TR><TD align='center'><u>TOPICS</u></TD></TR>
	<TR><TD><a href='#account'>Getting an account </a></TD></TR>
	<TR><TD><a href='#news'>RSS News </a></TD></TR>
	<TR><TD><a href='#library'>Library</TD></TR>
	<TR><TD><a href='#forums'>Forums</TD></TR>
	<TR><TD><a href='#calendars'>Calendars</TD></TR>
	<TR><TD><a href='#helpdesk'>Help Desk</TD></TR>
     </table>
     \n";



sect_head( "Getting an account" ,'account');

echo "
  <blockquote>
  First of all, you do not need an account to explore this site  
  and learn more about <em>Interactions in Understanding the Universe</em>.
  You only need an account to get to some of the 
  \"work\" areas of the site.    
  If you are unsure, here is 
  <a   href='/research.php'>a good place to start learning about I2U2</a>.


  <P>
  To obtain an account you will need an \"invitation code\".
  Contact Bob Peterson or another I2U2 staff member to get one.  

  </blockquote>
";



sect_head( "RSS News" ,'news');

echo "
  <blockquote>
  The news feed on the front page is set up so that you can 
  subscribe to it using using \"RSS\",
  which allows you to see when there is a new article without having
  to visit the  site.   The way you subscribe to an RSS news feed depends
  on your browser.  Instructions can be found 
  <a target='_blank'
     href='http://www.ci.uchicago.edu/wiki/bin/view/I2U2/RSSNews#How_to_Subscribe_to_RSS_feeds'>here</a>.<img src='/library/skins/monobook/external.png'> 
  You can also add an RSS feed as a \"gadget\" to your personalized iGoogle
  page . 

  </blockquote>
   \n";




sect_head( "Library" ,'library');

echo "
  <blockquote>
  The <a href='/library'>I2U2 Library</a> is a wiki where members of 
  the I2U2 community can collaborate on shared documents, or simply
  upload documents to be shared with others.   The software used for this
  wiki is called MediaWiki.   It is the same software used by the
  Wikipedia, so if you know how to use Wikipiedia you know how to use our
  Library, and vice-versa.

 <P>
 Every page in the Library has a helpful navigation bar at the left side
 of the page, and this includes a \"Help\"  link to help you learn how to
 navigate and edit the wiki.

 <P>
 In addition to the main entrance, the Library also has sub-sections for
 various programs, such as the QuarkNet e-Lab Fellows.
 Everything is stored in one wiki, but you 
 may find it easier to start your visit to the Library in one of the more
 specialilzed sections.

  </blockquote>
   \n";





sect_head( "Forums" ,'forums');

echo "
  <blockquote>
  This site provides on-line discussion forums so that members of the
  I2U2 community can collaborate and discuss various topics. 
  Some tips:	

  <UL>
  <LI>
  It helps personalize the discussion if you upload a forum picture 
  (a \"headshot\"), which is shown along with your name next to each 
  of your postings.
  <P>
  <LI>
  HTML is not allowed in forum codes, but you can use a similar set of
  markup codes called \"BBcode\", 
  which is <a href='/bbcode.php'>summarized here</a>.
  <P>
  <LI>
  Remember that it's harder for people to detect irony or other subtlties
  in this format, so please try to write clearly. 
  </UL> 

  </blockquote>
   \n";



sect_head( "Calendars" ,'calendars');

echo "
  <blockquote>
   If you use 
   <a href='http://calendars.google.com'
      target='_blank' >Google Calendars</a>
   <img src='/library/skins/monobook/external.png'> 
   you can subscribe to the I2U2 calendar via that
   service, and it will be superimposed over your other calendars.
   See the instructions at the bottom of any of our
   <a href='/Calendar.php'>calendar page</a>.
   <P>
   To use Google Calendars you need to set up an account with Google, 
   based on your e-mail address.  It can be based on any existing e-mail 
   address -- it does not need to be a Gmail account (but it can be).

  </blockquote>
   \n";

sect_head( "Help Desk" ,'helpdesk');

echo "
   <blockquote>
    If the topics above didn't help answer your questions, 
    you can ask for help in the 
     <a href='/forum_help_desk.php'>Help Desk</a> Forum.

   </blockquote>
   \n";

page_tail();
?>
