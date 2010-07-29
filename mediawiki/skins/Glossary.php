<?php
/**
 * See skin.txt
 *
 * @todo document
 * @addtogroup Skins
 */

if( !defined( 'MEDIAWIKI' ) )
	die( -1 );

/**
 * @todo document
 * @addtogroup Skins
 */
class SkinGlossary extends Skin {

	private $searchboxes = '';
	// How many search boxes have we made?  Avoid duplicate id's.

	function getStylesheet() {
		return 'i2u2/glossary.css';
	}
	function getSkinName() {
		return "glossary";
	}
	
	function getHeadScripts($allowUserJs) {
		global $wgStylePath, $wgJsMimeType, $wgStyleVersion;

		$s = parent::getHeadScripts($allowUserJs);
		$s .= "<script language='javascript' type='$wgJsMimeType' " .
			  "src='{$wgStylePath}/i2u2/glossary.js'></script>\n";
		return $s;
	}
	
	function getBodyOptions() {
		$a = parent::getBodyOptions();

		$a["onload"] .= ";resizeDefault();";
		return $a;
	}

	function doBeforeContent() {

		$s = "";
		$qb = $this->qbSetting();
		$mainPageObj = Title::newMainPage();

		$s .= "\n<div id='content'>\n";

		$s .= "<div id='article'>";

		//$s .= $this->pageTitle();
		//$s .= $this->pageSubtitle() . "\n";
		return $s;
	}

	function doAfterContent()
	{
		global $wgOut;

		$s = "\n</div><br />\n";
		$s .= "<hr /><p align='right'><a href='javascript:window.close();'>Close Window</a></p> ";
		
		//code to auto-resize window
		$s .= "<script language=\"JavaScript\">\n";
		$s .= "\n";
		$s .= "</script>\n";
		
		$s .= "\n</div>\n";

		return $s;
	}

	function doGetUserStyles() {
		global $wgOut;
		$s = parent::doGetUserStyles();
		$qb = $this->qbSetting();

		return $s;
	}

	function sysLinks() {
		global $wgUser, $wgContLang, $wgTitle;
		$li = $wgContLang->specialPage("Userlogin");
		$lo = $wgContLang->specialPage("Userlogout");

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
		$s .= $this->menuHead( "qbfind" );
		$s .= $this->searchForm();

		$s .= $this->menuHead( "qbbrowse" );

		# Use the first heading from the Monobook sidebar as the "browse" section
		$bar = $this->buildSidebar();
		$browseLinks = reset( $bar );

		foreach ( $browseLinks as $link ) {
			if ( $link['text'] != '-' ) {
				$s .= "<a href=\"{$link['href']}\">" .
					htmlspecialchars( $link['text'] ) . '</a>' . $sep;
			}
		}

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
			  . $sep . $this->commentLink()
			  . $sep . $this->printableLink();
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

		$s .= $this->menuHead( "qbmyoptions" );
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
		  	  . $sep . $this->specialLink( "preferences" )
		  	  . $sep . $this->specialLink( "userlogout" );
		} else {
			$s .= $this->specialLink( "userlogin" );
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

	function menuHead( $key )
	{
		$s = "\n<h6>" . wfMsg( $key ) . "</h6>";
		return $s;
	}

	function searchForm( $label = "" )
	{
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


