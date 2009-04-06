<?php
/***********************************************************************\
 * Display a list of candidates for User of the Day 
 * 
 * The policy for choosing the UOTD is either the default in uotd.inc
 * or a user-defined policy function called uotd_candidates_query()
 * from project.inc
 *
 * Eric Myers <myers@spy-hill.net>  - 12 July 1006
\***********************************************************************/

require_once('../inc/uotd.inc');
require_once('../inc/util_ops.inc');
require_once('../project/project.inc');

db_init();

// Verify authorization 

if( function_exists('is_Administrator') ){ // only (now) on Pirates@Home
    $logged_in_user = get_logged_in_user(true);
    $logged_in_user= getForumPreferences($logged_in_user);
    if( 0 && !is_Administrator($logged_in_user) ){ 
        error_page("You must be a <b>" .$special_user_bitfield[1].
                   "</b> to use this page.");
    }    
 }

admin_page_head("Display Candidates for UOTD");


// get a list of profiles that have been 'approved' for UOTD,
// using a project-specific query if supplied in project.inc

if (function_exists('uotd_candidates_query')) {
    $query = uotd_candidates_query();
 }
 else {
     $query = default_uotd_candidates_query();
 }
$result = mysql_query($query);
if(!result){
    echo "<P><font color='RED'>*       
             There was a problem finding candidates for User of the Day.
            </font></P>\n   ";
    admin_page_tail();      
    return;
 }
$N = mysql_num_rows($result);

echo "<P>There are $N users who are candidates for UOTD under
        the present policy</p>\n";

// Show the list as a table

echo "<TABLE border='1' align='center'><TR>\n";
if(PROJECT=="Pirates@Home") echo "    <TH>dubloons</TH>\n";
echo "      <TH> score </TH>
            <TH> &nbsp; Credit &nbsp; </TH>
            <TH> &nbsp; Recent &nbsp; </TH>
            <TH> &nbsp; UOTD_time &nbsp; </TH>
            <TH> Name</TH>
        </TR>\n"; 

for($i=0;$i<=$N;$i++){
    $item=mysql_fetch_object($result);
    $name=$item->name;
    $id=$item->id; 
    if(empty($name)) continue;
    $recommend = $item->recommend;
    $reject =  $item->reject;
    $score = $recommend - $reject;
    $credit = $item->total_credit;
    $expavg = $item->expavg_credit;
    $dubloons = $item->seti_nresults;
    if($item->uotd_time) {
        $uotd_time = date("j M, Y",$item->uotd_time);
    }
    else {
        $uotd_time="";
    }

    echo "<TR>\n";
    if(PROJECT=="Pirates@Home") echo "   <TD align='center'> $dubloons </TD>\n";
    echo "        <TD align='right'> ".number_format($score)." </TD>
                <TD align='right'> ".number_format($credit,2)." </TD>
                <TD align='right'> ".number_format($expavg,3)." </TD>
                <TD>&nbsp; ".$uotd_time."&nbsp; </TD>
                <TD><a href='".URL_BASE."/view_profile.php?userid=$id'> $name </a></TD>
        </TR>\n";
 }
echo "</TABLE> \n";

admin_page_tail();

//Generated automatically - do not edit
$cvs_version_tracker[]=
    "\$Id: list_uotd_candidates.php,v 1.2 2007/06/07 19:23:06 myers Exp $";  
?>
