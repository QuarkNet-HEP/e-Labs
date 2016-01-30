<?php
/**
 * Talkright MediaWiki extension
 * @version 1.2
 * @author Marc Noirot - marc dot noirot at gmail
 * @author P.Levêque - User:Phillev
 * @link http://www.mediawiki.org/wiki/Extension:Talkright
 *
 * This extension makes the editing of talk pages a distinct action from
 * the editing of articles, to create finer permissions by adding the 'talk' right.
 *
 * Edit tab in talk page
       a "view source" button is still  existing on talk pages. To fix this problem, modify includes/SkinTemplate.php on line 672 changing :
     " if ( $this->mTitle->quickUserCan( 'edit' ) && ( $this->mTitle->exists() || $this->mTitle->quickUserCan( 'create' ) ) ) {"
      to
     " if ( ($this->mTitle->quickUserCan( 'edit' ) || ($this->mTitle->isTalkPage() && $wgUser->isAllowed('talk'))) && ( $this->mTitle->exists() || $this->mTitle->quickUserCan( 'create' ) ) ) {"
 
*/
 
if (!defined('MEDIAWIKI')) die();
 
$wgExtensionCredits['other'][] = array(
	'name' => 'Talkright',
	'version' => '1.2',
	'author' => array('P.Levêque', 'Marc Noirot'),
	'description' => 'Adds a <tt>talk</tt> permission independent from article edition',
	'url' => 'http://www.mediawiki.org/wiki/Extension:Talkright',
);
 
 
/* Register hooks */
$wgHooks['userCan'][] = 'userCanTalk';
// $wgHooks['AlternateEdit'][] = 'alternateEdit';
 
/* Global 'talk' right */
$wgAvailableRights[] = 'talk';
 
/**
 * Can user edit the given page if it's a talk page?
 * @param &$title the concerned page
 * @param &$wgUser the current MediaWiki user
 * @param $action the action performed
 * @param &$result (out) true or false, or null if we don't care about the parameters
 */
 
function userCanTalk(&$title, &$user, $action, &$result) {
	if ( $action = 'edit' && $title->isTalkPage() ) {
		$return = $user->isAllowed( 'talk' );
	}
	return true;
}
 
/*
 * Bypass edit restriction when editing pages if user can talk and page is a comment.
 * @param $&editPage the page edition object
 * @return true to resume edition to normal operation
*/
 
function alternateEdit(&$editPage) { 
/*
	global $wgOut, $wgUser, $wgRequest, $wgTitle;
	if ( $wgTitle->isTalkPage() && $wgUser->isAllowed( 'talk' )) {
		array_push($wgUser->mRights, 'edit');
	}
*/
	return true;
}

