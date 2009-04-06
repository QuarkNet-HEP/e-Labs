<?php
/***********************************************************************\
 * overview.php - general overview of the process, mainly for new users
 *
 *
 * Eric Myers <myers@spy-hill.net  - 30 March 2006
 * @(#) $Id: overview.php,v 1.1 2008/07/15 21:59:58 myers Exp $
\***********************************************************************/

require_once("macros.php");         // status message area


//require_authentication();
handle_user_level();

$this_step=update_step('main_steps');


/***********************************************************************\
 * Action:
\***********************************************************************/

if($this_step <1) $this_step = 1;

if( get_posted('go')  && $this_step > 0 ){
  $link = $main_steps[$this_step]->url;
  if( $link ) {
    header("Location: $link");
    debug_msg(2,"Redirecting to ".$link."...");
    exit;
  }
 }

debug_msg(3,"This step is ".$this_step);



/***********************************************************************\
 * Display Page:
\***********************************************************************/

html_begin("Overview");
form_begin("overview");

echo "<blockquote>
  The analysis of LIGO environmental data generally consists
of these several steps:
        ";

steps_as_blocks('main_steps');


echo "<P>
        As you gain experience with the process you can
   move around between the steps, but to get started it 
  is best to follow these steps in order.
        ";

echo "<P>
        You are currently on step $this_step
        ";


echo "<P align='RIGHT'>
        Press 'GO' to get to work on that step:
        <input type='SUBMIT'  name='go' value='Go'>
        ";




echo "<h2>User Levels</h2>
        The level of detail of the user interface can also be
        adjusted, using the control in the upper right hand corner
        of every page.  
        <UL>
        <LI> Use the <b>Beginner</b> setting if this is your first
             time using Bluestone.  You will be given more helpful advice
                and fewer confusing options for your first time through
                an analysis.
        <P>
        <LI> Use the <b>Intermediate</b> setting after you have been through
                the steps of an analysis and know a bit about what you 
                are doing.  The help messages will be less verbose, and
                the controls will have more options.

        <P>
        <LI> Use the <b>Advanced</b> setting when you have some experience
                using Bluestone.   There won't be any extraneious help messages,
                only warnings about errors, and the controls will be terse
                and use technical terms.
        </UL>
        When you are ready to start, press the 'GO' button.
";


echo "\n\n        </blockquote>
";


// DONE:

form_end();

remember_variable('main_steps'); 
remember_variable('this_step'); 

tool_footer();
html_end();
?>
