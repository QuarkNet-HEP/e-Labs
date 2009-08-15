<?php
/***********************************************************************\
 * work_flow.php -  User selects the work_flow (analysis)
 *                  they wish to use.
 *
 * Eric Myers <myers@spy-hill.net  - 30 March 2006
 * @(#) $Id: work_flow.php,v 1.34 2009/04/29 20:43:24 myers Exp $
\***********************************************************************/

require_once("macros.php");             // general utilities

check_authentication();
handle_user_level();
handle_auto_update();
handle_reset();

$this_step = update_step('main_steps');
recall_variable('msgs_list');

// General:
recall_variable('elab_group');
recall_variable('elab_cookies');


// This page:
recall_variable('WorkFlow');


/***********************************************************************\
 * Action:
\***********************************************************************/

elab_ping();

// Default workflow:
//
if( !isset($WorkFlow) ) $WorkFlow='plot1chan';


// handle work-flow selector
//
if( $x = get_posted('WorkFlow') ) {

    if( $x != $WorkFlow ) {
        clear_steps_after();
        clear_log_files();
    }
    $WorkFlow=$x;
    remember_variable('WorkFlow');
}

if( isset($WorkFlow) )  set_step_status('main_steps', STEP_DONE);
debug_msg(2,"WorkFlow is set to $WorkFlow");


// Update this after any user input

handle_prev_next('main_steps');


//Scan for workflows, read settings.php (change the name?)
//
$WorkFlow_list = array();
load_all_vi_settings();         // All of them!


// Helpful? user message

if($user_level<3){
    add_message(" Use the control below to select the ".glossary_link('Analysis type', 'analysis type')
                ."...");
    if($user_level<2){
    add_message(" (The analysis type determines what kind of processing is applied "
                ."to the data.) ");
    }
 }

debug_msg(6, "Number of steps: ". sizeof($main_steps) ); 
debug_msg(6, "User level: ".$user_level);


/***********************************************************************\
 * Display Page:
\***********************************************************************/

$title="Analysis Type";
html_begin($title);
title_bar($title);
controls_begin();

echo "<div class=\"control\">\n";
if( $user_level < 3) {
	echo "Select the <b>analysis type</b>:"; 
}
else {
	echo "<b>Analysis Type:&nbsp;</b> ";	
}
echo "<P align='CENTER'>";


// Selector for workflow:
//
$list=array();
foreach($WorkFlow_list as $wf){
    debug_msg(6, "Considering workflow ".$wf->name);
    if( $wf->user_level <= $user_level){
        if($user_level == 1) $list[$wf->name]=$wf->info;
        if($user_level == 2) $list[$wf->name]="$wf->info ($wf->name)";
        if($user_level >= 3) $list[$wf->name]=$wf->name;
    }
}
echo auto_select_from_array('WorkFlow',$list,$WorkFlow);



// Image for selected workflow.  If the image is not in ./img subdirectory,
// or if it is out of date, then make a visible copy.
// [Image file name should eventually change to WorkFlowDiagram.gif, eh?]
//
$img_file= "img/".$WorkFlow.".gif";
$img_src= "$TLA_VI_DIR/$WorkFlow/$WorkFlow".".gif";

if( !file_exists($img_file) ){ // copy if visible file doesn't exist

    if( file_exists($img_src) ){// old name 
        @copy($img_src, $img_file);
    }
    if( file_exists("$TLA_VI_DIR/$WorkFlow/WorkFlowDiagram.gif") ){//New
        $img_src="$TLA_VI_DIR/$WorkFlow/WorkFlowDiagram.gif";
        @copy($img_src, $img_file);
    }
}
elseif( file_exists($img_src) ){ // or copy if vi image file is newer than visible file
     $img_src_s = stat($img_src);
     $img_file_s = stat($img_file);
     if( $img_src_s['mtime'] > $img_file_s['mtime'] ){
        @copy($img_src, $img_file);
     }
 }

// Show the image, if there is one
//
if( file_exists($img_file) ){
    $x = $WorkFlow_list[$WorkFlow]->desc;
    echo "<br><img src='$img_file' align='CENTER' ";
    if( $x ) echo "title='$WorkFlow: $x' ";
    echo ">\n";
 }
 
echo "</div>\n";

controls_end();

/*******************************
 * DONE:
 */

// General:
remember_variable('main_steps'); 
remember_variable('this_step'); 
remember_variable('msgs_list'); 

// From this page:
remember_variable('WorkFlow');
//remember_variable('Ninputs'); 


tool_footer();
html_end();

$cvs_version_tracker[]=        //Generated automatically - do not edit
    "\$Id: work_flow.php,v 1.34 2009/04/29 20:43:24 myers Exp $";
?>
