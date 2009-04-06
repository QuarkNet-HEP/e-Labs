<?php

require_once('../inc/db.inc');
require_once('../inc/util.inc');

$dbrc =  db_init_aux();

$authenticator = init_session();
$logged_in_user = get_logged_in_user(false);
$logged_in_user = getForumPreferences($logged_in_user);

// RSS feed for THIS page is different
//
$rsslink='http://www.google.com/calendar/feeds/0dgj44qqutfg71qecppggucs20%40group.calendar.google.com/private-ac15a114012333b7cef4e6d2f0bf4d18/basic';
$rssname='I2U2 Calendar';
$rsstype='application/atom+xml';

page_head("I2U2  Calendar");

echo "<div align='right'>
        See below about how <a href='#sub_info'>
        you can subscribe to this calendar<a/>.&nbsp;&nbsp;
        </div>\n";

// Display calendar from Google in an iframe.  SINGLE CALENDAR VERSION
//
echo "<center>
<iframe
   src='http://www.google.com/calendar/embed?src=0dgj44qqutfg71qecppggucs20%40group.calendar.google.com' 
   style='border: 0' width='800' height='600' frameborder='0' scrolling='no'>
</iframe> 
</center>
";


/*********
// Display calendar from Google in an iframe.  Multi-calendar version
//
echo "<center>
<iframe src='http://www.google.com/calendar/embed?title=I2U2%20Calendar%20%2B%20Eric%20Myers&amp;height=600&amp;wkst=1&amp;bgcolor=%23FFFFFF&amp;src=myers%40spy-hill.net&amp;color=%235229A3&amp;src=0dgj44qqutfg71qecppggucs20%40group.calendar.google.com&amp;color=%234A716C&amp;ctz=America%2FNew_York' style=' border-width:0 ' width='800' height='600' frameborder='0' scrolling='no'>
</iframe>
</center>
";
**********/

if( $logged_in_user && user_has_permission('admin') ){
    echo "<div align='right'>
        Administrators can
        <a target='_blank' href='http://www.google.com/calendar/render'>
        edit or manage this calendar</a>. &nbsp;&nbsp;
        </div>\n";
 }



// Subscriptions


echo "<a name='sub_info'>
<h2>        Subscription Information
</h2>

You can subscribe directly to this calendar in one of sevaral ways:

<DL class='calendars'>
<DT> Google Calendar
<DD> Press this button to add this calendar to your existing  Google calendars:
     <a href='http://www.google.com/calendar/render?cid=http%3A%2F%2Fwww.google.com%2Fcalendar%2Ffeeds%2F0dgj44qqutfg71qecppggucs20%2540group.calendar.google.com%2Fpublic%2Fbasic' target='_blank'>
     <img src='http://www.google.com/calendar/images/ext/gc_button6.gif' border='0' align='top'></a>

<DT> iCal
<DD> Use this link to 
    <a href='http://www.google.com/calendar/ical/0dgj44qqutfg71qecppggucs20%40group.calendar.google.com/public/basic.ics'>
       ADD a copy of this calendar to iCal</a>.   
        (This adds a copy of the calendar as it is right now, 
        it is not a subscription.)

<P>
<DT> Atom
<DD> This page include an ATOM/XML feed of the calendar.  
     Use your browser's RSS/ATOM ability to subscribe to the feed.

<P>
<DT>
<DT> Outlook
<DD> If you use Microsoft Outlook it is possible to use the \"Sync\"  
feature of Google Calendar to syncronize events with Outlook.  
(At present it is only possible to syncronize events from your primary Google calendar 
and your default Microsoft Outlook calendar, but we expect in the future to be able to 
syncronize secondary calendars.)   
<a href='http://www.google.com/support/calendar/bin/answer.py?answer=89955'>Read more...</a>


<P>
<DT> Bookmark it
<DD> You could just bookmark this page.
        <p>
        Or you can use this link to 
    <a href='http://www.google.com/calendar/embed?src=0dgj44qqutfg71qecppggucs20%40group.calendar.google.com'>
        go directly to just the bare calendar, then bookmark that</a>.

</DL>\n";
 

page_tail();

$cvs_version_tracker[]=         //Generated automatically - do not edit
    "\$Id: ";
?>
