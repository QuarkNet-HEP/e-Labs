<?php
/**
 * Body - simple skin to just show body of a page, for use in mashup
 *
 * Derived from MediaWiki MonoBook skin, trimmed to the bone.
 *
 * @todo document
 * @addtogroup Skins
 */

if( !defined( 'MEDIAWIKI' ) )
	die( -1 );

/**
 * If this skin is loaded then set these bare defaults for user options 
 * TODO: move this into initialization
 */

$wgDefaultUserOptions = array( 
	'quickbar' 		=> 0,
	'underline' 		=> 2,
	'skin' 			=> false,
	'math' 			=> 1,
	'highlightbroken'	=> 0,
	'stubthreshold' 	=> 0,
	'previewontop' 		=> 0,
	'editsection'		=> 0,
	'editsectiononrightclick'=> 0,
	'showtoc'		=> 0,
	'showtoolbar' 		=> 0,
	'date' 			=> 'default',
	'imagesize' 		=> 2,
	'thumbsize'		=> 2,
	'rememberpassword' 	=> 0,
	'enotifwatchlistpages' 	=> 0,
	'enotifusertalkpages' 	=> 0,
	'enotifminoredits' 	=> 0,
	'enotifrevealaddr' 	=> 0,
	'shownumberswatching' 	=> 0,
	'fancysig' 		=> 0,
	'externaleditor' 	=> 0,
	'externaldiff' 		=> 0,
	'showjumplinks'		=> 0,
	'numberheadings'	=> 0,
	'uselivepreview'	=> 0,
);


/** */
require_once('includes/SkinTemplate.php');

/**
 * Inherit main code from SkinTemplate, set the CSS and template filter.
 * @todo document
 * @addtogroup Skins
 */
class SkinBody extends SkinTemplate {
  function initPage( &$out ) {
    SkinTemplate::initPage( $out );
    $this->skinname  = 'body';
    $this->stylename = 'body';
    $this->template  = 'BodyTemplate';

    // Settings specific to this skin

    global $wgDisabledActions, $wgReadOnly, $wgAllowUserCss;
    $wgDisabledActions[] = 'edit';
    $wgReadOnly=" You cannot edit this glossary. ";
    $wgAllowUserCss = false;

    global $wgSkipSkins;
    $wgSkipSkins = array("monobook", "cologneblue", "myskin", "simple",
			 "nostalgia", "standard", "chick");
  }
}


/**
 * @todo document
 * @addtogroup Skins
 */
class BodyTemplate extends QuickTemplate {
	/**
	 * Template filter callback for Body skin.
	 * Takes an associative array of data set from a SkinTemplate-based
	 * class, and a wrapper for MediaWiki's localization database, and
	 * outputs a formatted page.
	 *
	 * @access private
	 */
	function execute() {
		global $wgUser;
		$skin = $wgUser->getSkin();

		// Suppress warnings to prevent notices about missing indexes in $this->data
		wfSuppressWarnings();
		print Skin::makeGlobalVariablesScript( $this->data ); 
		if($this->data['pagecss'   ]) { ?>
		<style type="text/css"><?php $this->html('pagecss'   ) ?></style>
<?php	} ?>
<div id="globalWrapper">
     <div id="column-content">
	<div id="content">
		<a name="top" id="top"></a>
		<?php if($this->data['sitenotice']) { ?><div id="siteNotice"><?php $this->html('sitenotice') ?></div><?php } ?>
		<h1 class="firstHeading"><?php $this->data['displaytitle']!=""?$this->html('title'):$this->text('title') ?></h1>
		<div id="bodyContent">
			<h3 id="siteSub"><?php $this->msg('tagline') ?></h3>
			<div id="contentSub"><?php $this->html('subtitle') ?></div>

			<!-- start content -->
			<style type="text/css">
			.editsection {	display: none; }
			</style>
			<?php $this->html('bodytext') ?>
			<?php if($this->data['catlinks']) { ?><div id="catlinks"><?php       $this->html('catlinks') ?></div><?php } ?>
			<!-- end content -->

		</div>
	</div>
     </div>
</div>
<?php
	wfRestoreWarnings();
	} // end of execute() method
} // end of class
?>
