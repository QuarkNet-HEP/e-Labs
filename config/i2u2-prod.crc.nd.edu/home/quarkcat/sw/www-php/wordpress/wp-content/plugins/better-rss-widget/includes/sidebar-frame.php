<?php
if ( preg_match( '#' . basename( __FILE__ ) . '#', $_SERVER['PHP_SELF'] ) ) {
	die( 'You are not allowed to call this page directly.' );
}
/**
 * footer.php - View for the footer on all plugin pages.
 *
 * @package Better RSS Widget
 * @subpackage includes
 * @author GrandSlambert
 * @copyright 2009-2013
 * @access public
 * @since 0.1
 */
?>

<div class="postbox">
     <h3 class="handl" style="margin:0; padding:3px;cursor:default;">
		<?php _e( 'Plugin Information', 'better-rss-widget' ); ?>
     </h3>
     <div style="padding:5px;">
          <p><?php _e( 'This page sets the defaults for the plugin. Each of these settings can be overridden when you add an index to your page.', 'better-rss-widget' ); ?></p>
          <p><span><?php _e( 'You are using', 'better-rss-widget' ); ?> <strong> <a href="http://grandslambert.tk/plugins/better-rss-widget.html" target="_blank"><?php echo $this->pluginName; ?> <?php echo $this->version; ?></a></strong> by <a href="http://grandslambert.tk" target="_blank">GrandSlambert</a>.</span> </p>
     </div>
</div>
<div class="postbox">
     <h3 class="handl" style="margin:0; padding:3px;cursor:default;">
		<?php _e( 'Usage', 'better-rss-widget' ); ?>
     </h3>
     <div style="padding:5px;">
          <p>
			<?php printf( __( 'See the %1$s for this plugin for more details on what each of these settings does.', 'better-rss-widget' ),
				'<a href="http://grandslambert.tk/documentation/better-rss-widget.html" target="_blank">' . __( 'Documentation Page', 'better-rss-widget' ) . '</a>' ); ?>
          </p>
     </div>
</div>
<div class="postbox">
     <h3 class="handl" style="margin:0; padding:3px;cursor:default;">
		<?php _e( 'Recent Contributors', 'better-rss-widget' ); ?>
		</h3>
		<div style="padding:5px;">
			<p><?php _e( 'GrandSlambert would like to thank these wonderful contributors to this plugin!', 'better-rss-widget' ); ?></p>
		<?php $this->contributor_list(); ?>
     </div>
</div>