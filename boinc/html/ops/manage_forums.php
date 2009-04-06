<?php
/***********************************************************************\
 * Display and Manage BOINC forums
 * 
 * This page presents a form with information about discussoin forums.
 * Some of the fields can be changed...
 *
 * Eric Myers <myers@spy-hill.net>  - 27 July 2006
 * @(#) $Id: manage_forums.php,v 1.1 2008/11/13 21:05:06 myers Exp $
\***********************************************************************/

require_once('../inc/util_ops.inc');

$self=$_SERVER['PHP_SELF'];
$error="";
$messg="";

db_init();

/*******************************\
 * Authorization:
\*******************************/

$logged_in_user = get_logged_in_user(true);
$logged_in_user = getForumPreferences($logged_in_user);
$is_admin = isSpecialUser($logged_in_user, S_ADMIN)
         || isSpecialUser($logged_in_user, S_DEV);

if( !$is_admin ){
    error_page("You must be a project administrator to use this page.");
 }


/***************************************************\
 * Functions
\***************************************************/


function delete_forum($id){
    $result = mysql_query("SELECT * FROM thread WHERE forum=$id");
    $Nthread =  mysql_num_rows($result);

    // 1. List all the threads in the forum.
    for($i=0;$i<$Nthread;$i++){
        $thread[$i] = mysql_fetch_object($result);
    }

    // 2. For each thread, delete all posts
    for($i=0; $i< $Nthread; $i++){
        $thid = $thread[$i]->id;
        $q = "DELETE FROM post WHERE thread=$thid";
        $result = mysql_query($q);
        if($result){ // 3. then delete the thread itself
            $result = mysql_query("DELETE FROM thread WHERE id=$thid");
            if(!$result) break;  
        }
    }        

    // 4. finally, delete the forum itself
    if($result){
      $x = mysql_query("DELETE FROM forum WHERE id=$id");
      return $x;
    }
    return NULL;
}




/***************************************************\
 *  Action: 
\***************************************************/

// Collect all categories and forums (but not threads)

$result = mysql_query("SELECT * FROM forum");
$Nroom =  mysql_num_rows($result);
for($i=0;$i<=$Nroom;$i++){
    $forum[$i]= mysql_fetch_object($result);
 }

// Count threads in each forum
for($i=0;$i<=$Nroom;$i++){
    $result = mysql_query("SELECT * FROM thread WHERE forum=".$forum[$i]->id);
    $forum[$i]->Nthread = mysql_num_rows($result);
 }


$result = mysql_query("SELECT * FROM category");
$Ncat  =  mysql_num_rows($result);
for($i=0;$i<=$Ncat;$i++){
  $category[$i] = mysql_fetch_object($result);
 }




/**
 * process form input for changes
 */

if( !empty($_POST) ) {

    // Delete requested forums
    //
    for($i=0;$i<=$Nroom;$i++){
        $id = $forum[$i]->id;
        $field="delete_room_".$id; 
        if( array_key_exists($field,$_POST) ){
            if( empty($_POST[$field]) ) continue;
            if( $_POST[$field]=='DELETE'){
                if( !delete_forum($id) ){
                    $error .= "<br>Could not delete forum $id";
                }
                else {
                    unset($forum[$i]);
                    $messg .= "<br>Deleted forum $id";
                }
            }
            else {
                $error .= "<br>forum #$id) "
                    ."You must enter 'DELETE' to delete a discussion room.";
            }
        }
    }// delete forums

 }//_POST



/***************************************************\
 * Display the DB contents in a form
\***************************************************/

admin_page_head("Manage Discussion Forums");

echo "Use this form to manage <a href='#room'>discussion rooms</a>
        or <a href='#cat'>categories</a>.
";


if($error){
    echo "<p><font color=RED> $error </font></P>\n";
 }

if($messg){
    echo "<p><font color=GREEN> $messg </font></P>\n";
 }



echo "<form action='$self' method='POST'>\n";
echo"<P>\n";


/**
 * Rooms
 */

echo "<a name='room'>
      <H2>Discussion Rooms </h2>\n";

start_table("align='center'");

echo "<TR><TH>ID #</TH><TH>orderID</TH><TH width='33%'>Title</TH>
                <TH># threads</TH><TH>DELETE?<sup>*</sup>
         </TH></TR>\n";

for($j=0;$j<$Nroom;$j++){
    $item = $forum[$j];
    $id=$item->id;
    $orderID=$item->orderID;
    $title=$item->title;
    $Nthread = $item->Nthread;

  // grey-out rooms hidden by negative orderID
  $f1=$f2='';
  if($item->orderID<0) {
    $f1="<font color='GREY'>";
    $f2="</font>";
  }

  echo "<TR>
        <TD align='center'>$f1 $id $f2</TD>
        <TD align='center'>$f1 $orderID $f2</TD>
        <TD align='left'>$f1 $title $f2</TD>
        <TD align='center'>$f1 $Nthread $f2</TD>";

  $field="delete_room_".$id; 
  echo "
        <TD align='center'>
          <input type='text' size='6' name='$field' value=''></TD>\n";
  echo "</tr> "; 
 }

echo "<TR><TD colspan='3'>
    <sup>*</sup>To delete an entry you must enter 'DELETE' in this field.
    <td align='center' colspan=2><input type='submit' value='Update'></td>
    </tr>\n";

end_table();



/**
 * Categories
 */


echo "<a name='cat'>
      <H2>Forum Categories </h2>\n";


start_table("align='center'");

echo "<TR><TH>ID #</TH> <TH>orderID</TH><TH width='33%'>Name</TH>
                <TH>Helpdesk?</TH> <TH>DELETE?<sup>*</sup>
          </TH> </TR>\n";

for($j=0;$j<$Ncat;$j++){
    $item=$category[$j];
    $id=$item->id;
    $orderID = $item->orderID;
    $name = $item->name;
    $lang = $item->lang;
    $is_helpdesk = $item->is_helpdesk;

  // grey-out deprecated versions 
  $f1=$f2='';
  if($item->deprecated==1) {
    $f1="<font color='GREY'>";
    $f2="</font>";
  }


  echo "<TR>
        <TD align='center'>$f1 $id $f2</TD>
        <TD align='center'>$f1 $orderID $f2</TD>
        <TD align='left'>$f1 $name $f2</TD>
        <TD align='center'>$f1 ".(($is_helpdesk==1) ? "Yes" : "&nbsp;")."$f2</TD>";

  $field="delete_cat".$id; 
  echo "
        <TD align='center'>
            <input type='text' size='6' name='$field' value=''></TD>\n";
  echo "</tr> "; 
 }

echo "<tr><td colspan='4'>
    <sup>*</sup>To delete an entry you must enter 'DELETE' in this field.
    <td align='center' colspan=2><input type='submit' value='Update'></td>
    </tr>\n";

end_table();



echo "</form>\n";
admin_page_tail();

$cvs_version_tracker[] = //Generated automatically - do not edit
    "\$Id: manage_forums.php,v 1.1 2008/11/13 21:05:06 myers Exp $";  
?>
