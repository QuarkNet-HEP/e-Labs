<?php
  //require_once('../inc/db.inc');
require_once('../inc/util.inc');


$hide_user=true;

page_head(PROJECT." Forum Restrictions",true);

echo "
  <blockquote>
  The various Meeting Rooms (discussion forums) for this site have
  different access restrictions, based on the following
  categories:

  <DL>
  <DT> <b>Public Areas</b>
  <DD> <UL>
        <LI>Anyone on the Internet can read these postings.
        <LI>Only a Teacher, Administrator, or Developer may post here.
        </UL>

  <P>
  <DT><b> Meeting and Discussion Rooms</b>
  <DD> <UL>
       <LI>Only registered users may read these discussions.
                They are not open to the Internet.
       <LI> Any registered user may post to any discussion room.
        (Please be sure to use the appropriate room.)
        </UL>

  <P>
  <DT> <b>Private Areas</b>
   <DD> Reading and posting to these discussion rooms is limited to 
        particular users based on their \"role\" classification
        or institutional affiliation:

     <UL>
        <LI> <a href='forum_forum.php?id=49'>The Teacher's Lounge</a> 
                - only Teachers or Administrators
                may read and post here.

        <LI> <a href='forum_forum.php?id=45'>Cosmic Ray's Diner</a> 
                - a place for the QuarkNet Fellows to work on e-Lab development.
                  Project scientists are also welcomed. 

        <LI> <a href='forum_forum.php?id=56'>SJHSRC</a> 
                - an example of a \"Classroom\" forum, restricted to only
                  members of the St. Joseph's High School Research Community

        <LI> <a href='forum_forum.php?id=59'>Evaluators Workroom</a> 
                - only for the project evaluation teamr

        <LI> <a href='forum_forum.php?id=51'>The Boiler Room</a>
                - only Developers or Administrators may read and post here.
     </UL>  

  <P>
  <DT><b>Help Desks</b>
  <DD> <UL>
       <LI>Only registered users may read the Help Desks.
                They are not open to the Internet.
       <LI> Any registered user may post to any Help Desk. 
        (Please try to use the appropriate room.)
        </UL>

  <P>

  </DL>

";


echo "<P>
 The purpose of these restrictions is to organize the
discussion and to help us manage the site and I2U2 activities.
Areas in which students may someday be allowed to post are
not open to the Internet.
<P>

We can easily adjust and refine these policies as needed.
To make suggestions or to discuss changes please post to <a
href='forum_forum.php?id=43'>The Aquarium Room</a>.
";



echo "<center><b>
      Return to the <em><a href='forum_index.php'>List of Forums</a>
        </em></b>
</center>\n\n";


echo "\n</blockquote>\n";


page_tail();
?>
