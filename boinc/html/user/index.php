<?php
/***********************************************************************\
 *  index.php - main page for the PROJECT user area
 *
 *  @(#) $Id: index.php,v 1.5 2008/11/10 21:12:31 myers Exp $
\***********************************************************************/

// Unless the site is shut down, just get the home page from the 
// project area, which is separate from the user area.

if ( !  file_exists("../../stop_web") ) {
   require_once("../project/home_page.php");
   exit;
}

// What follows is a stripped down version of the home page,
// with no reference to the database.

session_start();

require_once("../project/project.inc");

$hide_user=true;
home_page_header();


echo "<h2><center><font color='RED'>
        The ".PROJECT." web site is shut down for maintenance.
        </font></center></h2>\n";



/***********
 *  Overview description of Project is read from a different file 
 */
if ( file_exists( OVERVIEW )) {
    echo "<P>
     <TABLE width='98%' border=1 class='description' align='center' >
      <TR><TD><font face=Helvetica>\n";
    include OVERVIEW ;
    echo "</font> </TD></TR>
       </TABLE>\n";
 }



// Begin double columns:

echo "
      <TABLE CELLPADDING=8 BORDER=0 WIDTH=100% ALIGN=CENTER>
      <TR>
     ";

echo "<TD width='42%' valign='TOP'>
        <TABLE CELLPADDING=8 CELLSPACING=5 BORDER=1>\n";


// STATUS AND  NEWS: =======================================

echo "<TR>
     <TD class='frontpage_status'>
       <b>Status</b>
	<P>
    ";


/* Status of server components: database, feeder, scheduler
 */

$errors=0;

if (  file_exists("../../stop_web") ) {
    $errors++;
    echo "<LI><font color='RED'>
      <b>The ".PROJECT." web site is now turned off,
        most likely for maintenance or testing.
        Please come back later.
      </b></font><P>
       ";
 }

//  General status is displayed if nothing else

  if( $errors==0 && file_exists( STATUS_TEXT ) ){
    include STATUS_TEXT ;
  }


// NEWS: RSS & Front page 

echo "</TD></TR>
      <TR>\n";

/*******************************
 * News:
 */

if( file_exists("../user_profile/news_frontpage.html") ){
    include("../user_profile/news_frontpage.html");
 }
 else if( file_exists("../user/news_frontpage.php") ){
    include("../user/news_frontpage.php");
 }
 else {
     error_log("! ERROR: cannot create front page news box."); 
     echo " <TD class='frontpage_news'>
           <h3>"  .tr(NEWS). "</h3>
           The news is currently unavailable
           </td>\n";
 }

echo " 
     </tr></table>
      </TD>\n";   // end of Status/News column

// Next column of double coumns


// USERS COLUMN:

    echo "<TD class='frontpage' valign=top  bgcolor=ffffff>\n";


// GENERERAL INFO & NEW USERS:

echo "
    <h3><font color='GREEN'>What is I2U2?  What are e-Labs?</font></h3>
    <UL>
    <li><a href='research.php'>About I2U2 and its research goals</a>

    <LI><a target='_blank'
           href='http://ed.fnal.gov/e-labs/'>What is an 'e-Lab'?</a>
           <img src='/glossary/skins/monobook/external.png'>

    <LI><a href='inquiry.php'>Inquiry Learning</a>
           <img src='/glossary/skins/monobook/external.png'>



    </UL>      
        \n";


// Other on-site links

echo "
    <h3> General Resources </h3>
    <UL>
      <LI><a href='Help.php'>Help! </a>
      <LI><a href='Calendar.php'>Calendar</a>
    </UL>
        ";

echo "
    <h3> LIGO Resources </h3>
    <UL>
      <LI><a href='http://www.ligo-wa.caltech.edu'>LIGO Hanford Observatory (LHO)</a>
      <LI><a href='http://ilog.ligo-wa.caltech.edu/ilog'>LIGO Hanford iLogs</a>
     </UL>
	";


/* Off-site links (these open a new window) */

echo "
    <h3>I2U2 Links </h3>
    <p>
    <UL STYLE='list-style-image: url(/images/fnal-ed.jpg)'>
    <LI><a href='http://www.i2u2.org' target='_blank'>I2U2 Home</a>
    <LI><a href='http://quarknet.fnal.gov/' target='_blank'	>QuarkNet</a>
    <LI><a href='http://www-ed.fnal.gov/uueo/i2u2.html' target='_blank'>About I2U2</a>
        - from the FNAL Education Office
    <LI><a href='http://www-ed.fnal.gov/' target='_blank'>FNAL
                Education Office</a>
     ";

echo "
    <LI><a href='http://www.ci.uchicago.edu/wiki/bin/view/I2U2/'
           target='_uchicago'>I2U2 Developer's Notebook</a> (wiki at U. Chicago CI)
        ";
echo "
    </UL>
";


echo"
<pre>


</pre>
    <p align='right'>
    <!-- Powered  by&nbsp; --><a href='http://boinc.berkeley.edu'
         ><img align='middle' border=0
           alt='Powered by BOINC'
           title='Forum software from the Berkeley Open Infrastructure for Network Computing (BOINC)'
		   src='/images/pb_boinc.gif'></a><br/>
        BOINC&nbsp;Forums

    </p>
    ";

// End of double columns

echo "\n   </tr></table>\n";


// SPONSOR LIST

if(file_exists('../project/sponsors.html')){
  include '../project/sponsors.html';
}

page_tail(true);

//end_cache(INDEX_PAGE_TTL);

?>
