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
//require_once( dirname(__FILE__) . '/MonoBook.php' );
*/

/**
 * @todo document
 * @addtogroup Skins
 */
class SkinKiwi extends SkinTemplate {
	function initPage( &$out ) {
		SkinTemplate::initPage( $out );
		$this->skinname  = 'kiwi';
		$this->stylename = 'kiwi';
		$this->template  = 'KiwiTemplate';

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


        // TODO: insure that external links open yet another window,
        //       not the little one we use for our display.

        // TODO: Add a JavaScript "close window" button to the top and
        //       bottom of every page

        //TODO: disallow access to any but the Main or Help namespaces
        //    ie. No access to Special:  or Template: or MediaWiki:

        //global $wgExtraSubtitle;
        //$wgExtraSubtitle = ", the I2U2 e-Lab Glossary";


/**
 * @todo document
 * @addtogroup Skins
 */

class KiwiTemplate extends QuickTemplate {
	/**
	 * Template filter callback for Body skin.
	 * Takes an associative array of data set from a SkinTemplate-based
	 * class, and a wrapper for MediaWiki's localization database, and
	 * outputs a formatted page.
	 *
	 * @access private
	 */
	function execute() {
		global $wgUser, $wgScriptPath;
		$skin = $wgUser->getSkin();

		// Suppress warnings to prevent notices about missing indexes in $this->data
		wfSuppressWarnings();
		
		// Make intrawiki links use kiwi.php
        // This may break if links are external and happen to have a
        // similarly ($wgScriptPath/index.php/$title) constructed URL
        $bodytext = $this->data["bodytext"];
        $bodytext = preg_replace("#$wgScriptPath/index.php/([_a-zA-Z0-9]*)\"#", "$wgScriptPath/kiwi.php/$1\"", $bodytext);
        $this->data["bodytext"] = $bodytext;		

?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="<?php $this->text('xhtmldefaultnamespace') ?>" <?php 
	foreach($this->data['xhtmlnamespaces'] as $tag => $ns) {
		?>xmlns:<?php echo "{$tag}=\"{$ns}\" ";
	} ?>xml:lang="<?php $this->text('lang') ?>" lang="<?php $this->text('lang') ?>" dir="<?php $this->text('dir') ?>">
	<head>
		<meta http-equiv="Content-Type" content="<?php $this->text('mimetype') ?>; charset=<?php $this->text('charset') ?>" />

		<title><?php $this->text('pagetitle') ?></title>

		<style type="text/css" media="screen,projection">/*<![CDATA[*/ @import "<?php $this->text('stylepath') ?>/<?php $this->text('stylename') ?>/main.css?<?php echo $GLOBALS['wgStyleVersion'] ?>"; /*]]>*/</style>
		<link rel="stylesheet" type="text/css" <?php if(empty($this->data['printable']) ) { ?>media="print"<?php } ?> href="<?php $this->text('stylepath') ?>/common/commonPrint.css?<?php echo $GLOBALS['wgStyleVersion'] ?>" />
		<link rel="stylesheet" type="text/css" media="handheld" href="<?php $this->text('stylepath') ?>/<?php $this->text('stylename') ?>/handheld.css?<?php echo $GLOBALS['wgStyleVersion'] ?>" />
		<!--[if lt IE 5.5000]><style type="text/css">@import "<?php $this->text('stylepath') ?>/<?php $this->text('stylename') ?>/IE50Fixes.css?<?php echo $GLOBALS['wgStyleVersion'] ?>";</style><![endif]-->
		<!--[if IE 5.5000]><style type="text/css">@import "<?php $this->text('stylepath') ?>/<?php $this->text('stylename') ?>/IE55Fixes.css?<?php echo $GLOBALS['wgStyleVersion'] ?>";</style><![endif]-->
		<!--[if IE 6]><style type="text/css">@import "<?php $this->text('stylepath') ?>/<?php $this->text('stylename') ?>/IE60Fixes.css?<?php echo $GLOBALS['wgStyleVersion'] ?>";</style><![endif]-->
		<!--[if IE 7]><style type="text/css">@import "<?php $this->text('stylepath') ?>/<?php $this->text('stylename') ?>/IE70Fixes.css?<?php echo $GLOBALS['wgStyleVersion'] ?>";</style><![endif]-->
		<!--[if lt IE 7]><script type="<?php $this->text('jsmimetype') ?>" src="<?php $this->text('stylepath') ?>/common/IEFixes.js?<?php echo $GLOBALS['wgStyleVersion'] ?>"></script>
		<meta http-equiv="imagetoolbar" content="no" /><![endif]-->
		
		<?php print Skin::makeGlobalVariablesScript( $this->data ); ?>

<?php	if($this->data['pagecss'   ]) { ?>
		<style type="text/css"><?php $this->html('pagecss'   ) ?></style>
<?php	} ?>


		<!-- Head Scripts -->
<?php $this->html('headscripts') ?>
	</head>
<body <?php if($this->data['body_ondblclick']) { ?>ondblclick="<?php $this->text('body_ondblclick') ?>"<?php } ?>
<?php if($this->data['body_onload'    ]) { ?>onload="<?php     $this->text('body_onload')     ?>"<?php } ?>
	<div id="globalWrapper">
		<div id="column-content">
	<div id="content">
		<a name="top" id="top"></a>
		<?php if($this->data['sitenotice']) { ?><div id="siteNotice"><?php $this->html('sitenotice') ?></div><?php } ?>

                <p class="closeWindow" align="right">
                    <input type=button value="Close Window"
			   onClick="javascript:window.close();"></p>

		<h1 class="firstHeading"><?php $this->data['displaytitle']!=""?$this->html('title'):$this->text('title') ?></h1>
		<div id="bodyContent">
			<h3 id="siteSub"><?php $this->msg('tagline') ?></h3>
			<div id="contentSub"><?php $this->html('subtitle') ?></div>

			<!-- start content -->

			<?php $this->html('bodytext') ?>
 			<?php if($this->data['catlinks']) { ?><div id="catlinks"><?php       $this->html('catlinks') ?></div><?php } ?>
			<!-- end content -->

		<p class="closeWindow" align="right">
		   <input type=button value="Close Window"
			  onClick="javascript:window.close();"></p>

		</div>
	</div>
		</div>

</div>


</body></html>
<?php
	wfRestoreWarnings();
	} // end of execute() method
} // end of class
?>
