<?php
/***********************************************************************\
 * Project specific user roles (special users) for I2U2
 * 
 * These are just the role definitions.   See project/roles.php
 * and BOINCAuthPolicy.php to see how they are used.
 *
 * Eric Myers <myers@spy-hill.net> - 13 February 2009
 * @(#) $Id: i2u2-roles.php,v 1.1 2009/03/30 20:36:15 myers Exp $
\***********************************************************************/

/* Special Users: special roles
 * Any user can be classified as one or more of these roles */

define('S_MODERATOR', 0);  $special_user_bitfield[S_MODERATOR]="Forum Moderator";
define('S_ADMIN', 1);      $special_user_bitfield[S_ADMIN]="Project Administrator";
define('S_DEV', 2);        $special_user_bitfield[S_DEV]="Project Developer";
define('S_LEADER', 3);     $special_user_bitfield[S_LEADER]="Project Leader";
define('S_HS_TEACHER', 4); $special_user_bitfield[S_HS_TEACHER]="HS Teacher";
define('S_HS_STUDENT', 5); $special_user_bitfield[S_HS_STUDENT]="HS Student";
define('S_SCIENTIST', 6);  $special_user_bitfield[S_SCIENTIST]="Project Scientist";
define('S_MS_TEACHER', 7); $special_user_bitfield[S_MS_TEACHER]="MS Teacher";
define('S_QN_FELLOW', 8);  $special_user_bitfield[S_QN_FELLOW]="QuarkNet Fellow";
define('S_DOCENT', 9);     $special_user_bitfield[S_DOCENT]="Docent";
define('S_EVALUATOR', 10);  $special_user_bitfield[S_EVALUATOR]="Evaluator";
define('S_QN_STAFF', 11);  $special_user_bitfield[S_QN_STAFF]="QuarkNet Staff";

// NOTE: to go beyond 12 roles will take a database update to extend
//       the field.  Instead, I'd like to add a roles table. 


?>
