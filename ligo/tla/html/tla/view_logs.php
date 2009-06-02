<?php
/***********************************************************************\
 * control_panel.php  - user controls for execution of the analysis
 *
 *
 * Eric Myers <myers@spy-hill.net  - 30 March 2006
 * @(#) $Id: view_logs.php,v 1.8 2009/04/29 20:43:24 myers Exp $
\***********************************************************************/

require_once("macros.php");             // general utilities
require_once("root.php");               // stuff to run ROOT scripts

check_authentication();
handle_user_level();

$this_step=update_step('main_steps');

recall_variable('Ninputs');
recall_variable('channel_info');
recall_variable('debug_level');
recall_variable('Nplot');
recall_variable('root_rc');

/***********************************************************************\
 * Action:
\***********************************************************************/

handle_debug_level();

if( empty($Nplot) )  $Nplot=1;

$id = uniq_id($Nplot);
$id = uniq_id();
$logfile = $id .".log";
$errfile = $id ."_err.log";

/***********************************************************************\
 * Display Page:
\***********************************************************************/

$title="View Log Files";
html_begin($title);
title_bar($title);
controls_begin();

show_log_files($Nplot);
controls_next();

echo select_debug_level(); 
echo "&nbsp;|&nbsp;Plot # $Nplot &nbsp;|&nbsp;\n";

controls_end();


/**********************************************************************\
 * DONE:
 */

//form_end();

remember_variable('debug_level');
remember_variable('Nplot');

tool_footer();
html_end();
?>

