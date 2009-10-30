<?php
/***********************************************************************\
 * Custom-made {{MAGIC}} words for this site
 *
 * Copied and then modified from
 * http://www.mediawiki.org/wiki/Manual:Variables#Registering_custom_variables
 *
\***********************************************************************/

#--------------------------------------------------
# Step 1: choose a magic word id
#--------------------------------------------------
 
# storing the chosen id in a constant is not required
# but still good programming practice - it  makes 
# searching for all occurrences of the magic word id a
# bit easier - note that the the name of the constant
# and the value it is assigned don't have to have anthing
# to do with each other.
 
define('MAG_ELAB', 'i2u2_elab_var');
define('MAG_ELAB_CATEGORY', 'i2u2_elab_category');
 
#---------------------------------------------------
# Step 2: define some words to use in wiki markup
#---------------------------------------------------
 
$wgHooks['LanguageGetMagic'][] = 'wfMyWikiWords';

function wfMyWikiWords(&$aWikiWords, &$langID) {
 
  #tell MediaWiki that {{elab}} and all case variants found 
  #in wiki text should be mapped to magic id 'i2u2_elab_var'
  # (0 means case-insensitive)

  $aWikiWords[MAG_ELAB] = array(0, 'elab');
  $aWikiWords[MAG_ELAB_CATEGORY] = array(0, 'elabcategory');
 
  #must do this or you will silence every LanguageGetMagic
  #hook after this!
  return true;
}
 
#---------------------------------------------------
# Step 3: assign a value to our variable
#---------------------------------------------------
 
$wgHooks['ParserGetVariableValueSwitch'][] = 'wfMyAssignAValue';

function wfMyAssignAValue(&$parser, &$cache, &$magicWordId, &$ret) {
  global $elab;

  if (MAG_ELAB == $magicWordId) {
     // We found a value
     $ret=$elab;
  }
  elseif (MAG_ELAB_CATEGORY == $magicWordId) {
     if ($elab == 'cosmic') {
        $ret = 'Cosmic Rays';
     }
     elseif ($elab == 'cms') {
        $ret = 'CMS';
     }
     elseif ($elab == 'cms-tb') {
        $ret = 'CMS TB';
     }
     elseif ($elab == 'ligo') {
        $ret = 'LIGO';
     }
  }
  // We must return true for two separate reasons:
  // 1. To permit further callbacks to run for this hook.
  //    They might override our value but that's life.
  //    Returning false would prevent these future callbacks from running.
  // 2. At the same time, "true" indicates we found a value.
  //    Returning false would the set variable value to null.
  //
  // In other words, true means "we found a value AND other 
  // callbacks will run," and false means "we didn't find a value
  // AND abort future callbacks." It's a shame these two meanings
  // are mixed in the same return value.  So as a rule, return
  // true whether we found a value or not.
  return true;
}
 
#---------------------------------------------------
# Step 4: register the custom variables so that it
#         shows up in Special:Version under the 
#         listing of custom variables
#---------------------------------------------------
 
$wgExtensionCredits['variable'][] = array(
       'name' => 'elab',
       'author' =>'Eric Myers', 
       'url' => 'http://www.i2u2.org/', 
       'description' => 'Identifies I2U2 e-Lab the user is using.'
       );
 
#---------------------------------------------------
# Step 5: register wiki markup words associated with
#         MAG_ELAB as a variable and not some 
#         other type of magic word
#---------------------------------------------------
 
$wgHooks['MagicWordwgVariableIDs'][] = 'wfMyDeclareVarIds';

function wfMyDeclareVarIds(&$aCustomVariableIds) {
 
  # aCustomVariableIds is where MediaWiki wants to store its
  # list of custom variable ids. We oblige by adding ours:
  $aCustomVariableIds[] = MAG_ELAB;
  $aCustomVariableIds[] = MAG_ELAB_CATEGORY;
 
  #must do this or you will silence every MagicWordwgVariableIds
  #registered after this!
  return true;
}

?>
