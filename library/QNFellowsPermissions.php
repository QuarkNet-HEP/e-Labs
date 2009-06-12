<?php
/***********************************************************************\
 * Detailed permisisons for the QuarkNet Fellows Library
 *
 * This file should be included by LocalSettings.php
\***********************************************************************/

/**
 *  Admin's should be able to do just about everything. We give all admin's
 *  these powers, but expect that off-line arrangements determine who will
 *  actually do what under normal and extraordinary circumstances
 */
$wgGroupPermissions['admin' ]['read']       = true;
$wgGroupPermissions['admin' ]['edit']       = true;
$wgGroupPermissions['admin' ]['createtalk'] = true;
$wgGroupPermissions['admin' ]['createpage'] = true;

$wgGroupPermissions['admin']['patrol'] =    true;
$wgGroupPermissions['admin']['rollback'] =  true;
$wgGroupPermissions['admin']['protect'] =   true;
$wgGroupPermissions['admin']['block'] =     true;
$wgGroupPermissions['admin']['move'] =      true;
$wgGroupPermissions['admin']['delete'] =    true;
$wgGroupPermissions['admin']['undelete'] =  true;
$wgGroupPermissions['admin']['upload']  =   true;
$wgGroupPermissions['admin']['siteadmin'] =  true;
$wgGroupPermissions['admin']['userrights'] = true;
$wgGroupPermissions['admin']['createaccount'] = true;

/**
 *  A 'teacher' is allowed to do things to keep things in order
 *  and to prevent mischief.
 */
$wgGroupPermissions['teacher']['patrol']   = true;
$wgGroupPermissions['teacher']['move']     = true;
$wgGroupPermissions['teacher']['rollback'] = true;
$wgGroupPermissions['teacher']['protect']  = true;
$wgGroupPermissions['teacher']['block']    = true;
$wgGroupPermissions['teacher' ]['read']            = true;
$wgGroupPermissions['teacher' ]['edit']            = true;
$wgGroupPermissions['teacher' ]['createtalk']      = true;
$wgGroupPermissions['teacher' ]['createpage']      = true;
$wgGroupPermissions['teacher']['upload']           = true;
$wgGroupPermissions['teacher']['reupload']           = true;


/**
 *  A 'fellow' is likely also a teacher, so it's not clear that
 *  we should make the distinction, but in case we do...
 */
$wgGroupPermissions['fellow']['patrol']   = true;
$wgGroupPermissions['fellow']['move']     = true;
$wgGroupPermissions['fellow']['rollback'] = true;
$wgGroupPermissions['fellow']['protect']  = true;
$wgGroupPermissions['fellow']['block']    = true;
$wgGroupPermissions['fellow' ]['read']            = true;
$wgGroupPermissions['fellow' ]['edit']            = true;
$wgGroupPermissions['fellow' ]['createtalk']      = true;
$wgGroupPermissions['fellow' ]['createpage']      = true;
$wgGroupPermissions['fellow']['upload']           = true;
$wgGroupPermissions['fellow']['reupload']           = true;

/**
 *  Hall monitors?  this would be a subset of teacher's  abilities
 */
$wgGroupPermissions['monitor']['patrol'] = true;
$wgGroupPermissions['monitor']['move'] = true;
$wgGroupPermissions['monitor']['rollback'] = true;
$wgGroupPermissions['monitor']['protect'] = true;
$wgGroupPermissions['monitor']['block'] = true;

?>
