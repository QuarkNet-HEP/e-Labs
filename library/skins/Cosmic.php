<?php
/**
 * MediaWiki skin 'Cosmic' for the I2U2 cosmic rayS e-Lab
 * Originally derived from the CologneBlue skin, and 
 * then modified to work with the BOINC forums.
 *
 */

if( !defined( 'MEDIAWIKI' ) )
  die( -1 );

/**
 * BOINC interface
 */

if( empty($BOINC_html) ) $BOINC_html = "/home/i2u2/boinc/html/";
require_once("$BOINC_html/project/i2u2-stuff.php");
if( empty($elab) ) $elab=get_elab_from_URL();
require_once("$BOINC_html/project/$elab-stuff.php");


function elab_forum_login_link($key='userlogin'){
  global $elab;
  $me = htmlspecialchars($_SERVER['REQUEST_URI']); // this page
  $u = "/elab/$elab/teacher/forum/login_form.php?next_url=$me";
  $s = "<a href='$u'>". wfMsg( $key ) ."</a>";
  return $s;
}

function elab_forum_logout_link($key='userlogout'){
  global $elab;
  $me = htmlspecialchars($_SERVER['REQUEST_URI']); // this page
  $u = "/elab/$elab/teacher/forum/logout.php?next_url=$me";
  $s = "<a href='$u'>". wfMsg( $key ) ."</a>";
  return $s;
}


/***********************************************************************\
 * @todo document
 * @addtogroup Skins
 */
class SkinCosmic extends Skin {

  // How many search boxes have we made?  Avoid duplicate id's.
  private $searchboxes = '';  

  function getSkinName() {
    return "cosmic";
  }

  function getStylesheet() {
    return 'common/cosmic.css';
  }

  // re-define how we determine what is the "main" page.

  function mainPageLink() {
    global $wgMainPage;
    if( empty($wgMainPage) ){ 
      $s = $this->makeKnownLinkObj( Title::newMainPage(), wfMsg( 'mainpage' ) );
    }
    else {
      $s = $this->makeKnownLinkObj( Title::newMainPage($wgMainPage), $wgMainPage );
    }
    return $s;
  }


  /**
   * Top of the page:
   */
  function doBeforeContent() {
    global $elab, $BOINC_html;

    $s = "";
    $qb = $this->qbSetting();
    $mainPageObj = Title::newMainPage();
    //
    $s .= cosmic_banner();
    $s .= cosmic_menu_bar();
    $s .= "\n<div id='content'>\n<div id='topbar'>";
    //

    /*******************************
     * ORIGINAL TOP BAR 
    $s .= "<table width='100%' border='0' cellspacing='0' cellpadding='8'><tr>";
    $s .= "<td class='top' align='left' valign='middle' nowrap='nowrap'>";
    $s .= "<a href=\"" . $mainPageObj->escapeLocalURL() . "\">";
    $s .= "<span id='sitetitle'>" . wfMsg( "sitetitle" ) . "</span></a>";

    $s .= "</td><td class='top' align='right' valign='bottom' width='100%'>";
    //$s .= $this->sysLinks();
    $s .= "</td></tr><tr><td valign='top'>";
    $s .= "<font size='-1'><span id='sitesub'>";
    $s .= htmlspecialchars( wfMsg( "sitesubtitle" ) ) . "</span></font>";
    $s .= "</td><td align='right'>" ;

    $s .= "<font size='-1'><span id='langlinks'>" ;
    $s .= str_replace ( "<br />" , "" , $this->otherLanguages() );
    $cat = $this->getCategoryLinks();
    if( $cat ) $s .= "<br />$cat\n";
    $s .= "<br />" . $this->pageTitleLinks();
    $s .= "</span></font>";
    $s .= "</td></tr></table>\n";
    $s .= "\n</div>";
    $notice = wfGetSiteNotice();
    if( $notice ) {
      $s .= "\n<div id='siteNotice'>$notice</div>\n";
    }
    /*************/

    $s .= "\n<div id='article'>";
    $s .= $this->pageTitle();
    $s .= "\n<hr>\n\n";
    //$s .= $this->pageSubtitle() . "\n";
    return $s;
  }

  /**
   * Bottom of the page
   */
  function doAfterContent()
  {
    global $wgOut;

    $s = "\n<hr></div><br clear='all' />\n";
    $s .= "\n<div id='footer'>";
    $s .= "<table width='98%' border='0' cellspacing='0'><tr>";

    $qb = $this->qbSetting();
    if ( 1 == $qb || 3 == $qb ) { # Left
      $s .= $this->getQuickbarCompensator();
    }
    $s .= "<td class='bottom' align='center' valign='top'>";

    $elab = get_elab_from_URL();
    $s .=  elab_help_link($elab);

    //$s .= $this->bottomLinks();
    //$s .= "\n<br />" . $this->makeKnownLinkObj( Title::newMainPage() ) . " | "
    //. $this->aboutLink() . " | "
    //. $this->searchForm( wfMsg( "qbfind" ) );

    $s .= "\n<br />" . $this->pageStats();

    $s .= "</td>";
    if ( 2 == $qb ) { # Right
      $s .= $this->getQuickbarCompensator();
    }
    $s .= "</tr></table>\n</div>\n</div>\n";

    if($this->data['poweredbyico']) { 
      $s .= "<div id='f-poweredbyico'>" .$this->html('poweredbyico') ."</div>";
    }
    if($this->data['copyrightico']) { 
      $s .= "<div id='f-copyrightico'>" .$this->html('copyrightico')."</div>";
    }

    if ( 0 != $qb ) { $s .= $this->quickBar(); }
    return $s;
  }


  function doGetUserStyles() {
    global $wgOut;
    $s = parent::doGetUserStyles();
    $qb = $this->qbSetting();

    $qb = 1;   // Force default for now -EAM 01Jun2009

    if ( 1 == $qb ) {
      $s .= "#quickbar { position: absolute; left: 4px; }\n" .
	"#article { margin-left: 148px; margin-right: 4px; }\n";
    }
    if ( 2 == $qb ) { # Right
      $s .= "#quickbar { position: absolute; right: 4px; }\n" .
	"#article { margin-left: 4px; margin-right: 148px; }\n";
    }
    if ( 3 == $qb ) { # Floating left
      $s .= "#quickbar { position:absolute; left:4px; top: 40px; } \n" .
	"#topbar { margin-left: 148px }\n" .
	"#article { margin-left:148px; margin-right: 4px; } \n" .
	"body>#quickbar { position:fixed; left:4px; top:4px; overflow:auto ;bottom:4px;} \n"; # Hides from IE
												} 
    if ( 4 == $qb ) { # Floating right
      $s .= "#quickbar { position: fixed; right: 4px; } \n" .
	"#topbar { margin-right: 148px }\n" .
	"#article { margin-right: 148px; margin-left: 4px; } \n" .
	"body>#quickbar { position: fixed; right: 4px; top: 4px; overflow: auto ;bottom:4px;} \n"; # Hides from IE
												     }
    return $s;
  }


  /**
   * System links to for general wiki functions 
   * (as opposed to page-specific functions).
   * this is currently not used here.  -EAM 01Jun2009
   */

  function sysLinks() {
    global $wgUser, $wgContLang, $wgTitle;
    //$li = $wgContLang->specialPage("Userlogin");
    $li = elab_forum_login_link();
    //$lo = $wgContLang->specialPage("Userlogout");
    $lo = elab_forum_logout_link();

    $rt = $wgTitle->getPrefixedURL();
    if ( 0 == strcasecmp( urlencode( $lo ), $rt ) ) {
      $q = "";
    } else {
      $q = "returnto={$rt}";
    }

    $s = "" .
      $this->mainPageLink()
      . " | " .
      $this->makeKnownLink( wfMsgForContent( "aboutpage" ), wfMsg( "about" ) )
      . " | " .
      $this->makeKnownLink( wfMsgForContent( "helppage" ), wfMsg( "help" ) )
      . " | " .
      $this->makeKnownLink( wfMsgForContent( "faqpage" ), wfMsg("faq") )
      . " | " .
      $this->specialLink( "specialpages" );

    /* show links to different language variants */
    $s .= $this->variantLinks();
    $s .= $this->extensionTabLinks();
		
    $s .= " | ";
    if ( $wgUser->isLoggedIn() ) {
      $s .=  $this->makeKnownLink( $lo, wfMsg( "logout" ), $q );
    } else {
      $s .=  $this->makeKnownLink( $li, wfMsg( "login" ), $q );
    }

    return $s;
  }

  /**
   * Compute the sidebar
   * @access private
   */
  function quickBar()
  {
    global $wgOut, $wgTitle, $wgUser, $wgLang, $wgContLang, $wgEnableUploads;

    $tns=$wgTitle->getNamespace();


    $s = "\n<div id='quickbar'>";
    $sep = "<br />";

    // Browse menus:
    //
    $s .= $this->menuHead( "qbbrowse" );
    // Uses ONLY the first heading from the Monobook sidebar as the "browse" section
    $bar = $this->buildSidebar();
    $browseLinks = reset( $bar );

    foreach ( $browseLinks as $link ) {
      if ( $link['text'] != '-' ) {
	$s .= "<a href=\"{$link['href']}\">" .
	  htmlspecialchars( $link['text'] ) . '</a>' . $sep;
      }
    }

    // Article Menus:
    //
    if ( $wgOut->isArticle() ) {
      $s .= $this->menuHead( "qbedit" );
      $s .= "<strong>" . $this->editThisPage() . "</strong>";

      $s .= $sep . $this->makeKnownLink( wfMsgForContent( "edithelppage" ), wfMsg( "edithelp" ) );

      if( $wgUser->isLoggedIn() ) {
	$s .= $sep . $this->moveThisPage();
      }
      if ( $wgUser->isAllowed('delete') ) {
	$dtp = $this->deleteThisPage();
	if ( "" != $dtp ) {
	  $s .= $sep . $dtp;
	}
      }
      if ( $wgUser->isAllowed('protect') ) {
	$ptp = $this->protectThisPage();
	if ( "" != $ptp ) {
	  $s .= $sep . $ptp;
	}
      }
      $s .= $sep;

      $s .= $this->menuHead( "qbpageoptions" );
      $s .= $this->talkLink()
	/** . $sep . $this->commentLink() **/
	. $sep . $this->printableLink();  //  BROKEN? -EAM 03Jun2009
      if ( $wgUser->isLoggedIn() ) {
	$s .= $sep . $this->watchThisPage();
      }

      $s .= $sep;

      $s .= $this->menuHead("qbpageinfo")
	. $this->historyLink()
	. $sep . $this->whatLinksHere()
	. $sep . $this->watchPageLinksLink();

      if( $tns == NS_USER || $tns == NS_USER_TALK ) {
	$id=User::idFromName($wgTitle->getText());
	if ($id != 0) {
	  $s .= $sep . $this->userContribsLink();
	  if( $this->showEmailUser( $id ) ) {
	    $s .= $sep . $this->emailUserLink();
	  }
	}
      }
      $s .= $sep;
    }

    // Search Form:
    //
    $s .= $this->menuHead( "qbfind" );
    $s .= $this->searchForm();



    // Personal Links:
    //
    $s .= $this->menuHead( "qbmyoptions" );
    $me = htmlspecialchars($_SERVER['REQUEST_URI']); // this page
    if ( $wgUser->isLoggedIn() ) {
      $name = $wgUser->getName();
      $tl = $this->makeKnownLinkObj( $wgUser->getTalkPage(),
				     wfMsg( 'mytalk' ) );
      if ( $wgUser->getNewtalk() ) {
	$tl .= " *";
      }

      $s .= $this->makeKnownLinkObj( $wgUser->getUserPage(),
				     wfMsg( "mypage" ) )
	. $sep . $tl
	. $sep . $this->specialLink( "watchlist" )
	. $sep . $this->makeKnownLinkObj( SpecialPage::getSafeTitleFor( "Contributions", $wgUser->getName() ),
					  wfMsg( "mycontris" ) )
	. $sep . $this->specialLink( "preferences" );
      //$s .= $sep . $this->speciallink( "userlogout" );
      $s .= $sep . elab_forum_logout_link();
    }
    else {
      //$s .= $this->specialLink( "userlogin" );
      //$s .= $sep ;
      $s .= elab_forum_login_link();
    }

    $s .= $this->menuHead( "qbspecialpages" )
      . $this->specialLink( "newpages" )
      . $sep . $this->specialLink( "imagelist" )
      . $sep . $this->specialLink( "statistics" )
      . $sep . $this->bugReportsLink();
    if ( $wgUser->isLoggedIn() && $wgEnableUploads ) {
      $s .= $sep . $this->specialLink( "upload" );
    }
    global $wgSiteSupportPage;
    if( $wgSiteSupportPage) {
      $s .= $sep."<a href=\"".htmlspecialchars($wgSiteSupportPage)."\" class =\"internal\">"
	.wfMsg( "sitesupport" )."</a>";
    }

    $s .= $sep . $this->makeKnownLinkObj(
					 SpecialPage::getTitleFor( 'Specialpages' ),
					 wfMsg( 'moredotdotdot' ) );

    $s .= $sep . "\n</div>\n";
    return $s;
  }


  function menuHead( $key ) {
    $s = "\n<h6>" . wfMsg( $key ) . "</h6>";
    return $s;
  }


  function searchForm( $label = "" ){
    global $wgRequest;

    $search = $wgRequest->getText( 'search' );
    $action = $this->escapeSearchLink();
    $s = "<form id=\"searchform{$this->searchboxes}\" method=\"get\" class=\"inline\" action=\"$action\">";
    if ( "" != $label ) { $s .= "{$label}: "; }

    $s .= "<input type='text' id=\"searchInput{$this->searchboxes}\" class=\"mw-searchInput\" name=\"search\" size=\"14\" value=\""
      . htmlspecialchars(substr($search,0,256)) . "\" /><br />"
      . "<input type='submit' id=\"searchGoButton{$this->searchboxes}\" class=\"searchButton\" name=\"go\" value=\"" . htmlspecialchars( wfMsg( "searcharticle" ) ) . "\" />"
      . "<input type='submit' id=\"mw-searchButton{$this->searchboxes}\" class=\"searchButton\" name=\"fulltext\" value=\"" . htmlspecialchars( wfMsg( "search" ) ) . "\" /></form>";

    // Ensure unique id's for search boxes made after the first
    $this->searchboxes = $this->searchboxes == '' ? 2 : $this->searchboxes + 1;

   return $s;
  }
}

?>
