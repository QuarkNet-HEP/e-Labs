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
 * Inherit main code from SkinTemplate, set the CSS and template filter.
 * @todo document
 * @addtogroup Skins
 */

require_once('includes/SkinTemplate.php');


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

    global  $wgDefaultUserOptions;
    $wgDefaultUserOptions = array( 
       'quickbar'              => 0,
       'underline'             => 2,
       'skin'                  => false,
       'math'                  => 1,
       'highlightbroken'       => 0,
       'stubthreshold'         => 0,
       'previewontop'          => 0,
       'editsection'           => 0,
       'editsectiononrightclick'=> 0,
       'showtoc'               => 0,
       'showtoolbar'           => 0,
       'date'                  => 'default',
       'imagesize'             => 2,
       'thumbsize'             => 2,
       'rememberpassword'      => 0,
       'enotifwatchlistpages'  => 0,
       'enotifusertalkpages'   => 0,
       'enotifminoredits'      => 0,
       'enotifrevealaddr'      => 0,
       'shownumberswatching'   => 0,
       'fancysig'              => 0,
       'externaleditor'        => 0,
       'externaldiff'          => 0,
       'showjumplinks'         => 0,
       'numberheadings'        => 0,
       'uselivepreview'        => 0,
				   );
  }
}


/**
 * @todo document
 * @addtogroup Skins
 */
class BodyTemplate extends QuickTemplate {

  /**
   * @access private
   */
  function execute() {
    # Suppress warnings to prevent notices about missing indexes in $this->data
    wfSuppressWarnings();

    echo "<!-- Article: ";
    $this->html('title');
    echo " --> \n";

    echo "
    <div id='globalWrapper'>
      <div id='column-content'>
        <div id='content'> 
          <a name='top' id='top'></a>
          <div id='bodyContent'>\n";
    echo "\n<!-- start content -->";
    
    // this is a kludge to hide editing links and footer until I
    // figure out how to turn them off completely. -EAM 17Jun2009
    echo "
	 <style type='text/css'>
	    .editsection {	display: none; }
	    .printfooter {	display: none; }
	 </style>\n";

    $this->html('bodytext');

    echo "\n<!-- end content -->\n
	  </div>
	</div>
      </div>
    </div>\n \n";

    wfRestoreWarnings();
  } // end of execute() method
} // end of class

?>
