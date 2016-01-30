<?php
if ( preg_match( '#' . basename( __FILE__ ) . '#', $_SERVER['PHP_SELF'] ) ) {
	die( 'You are not allowed to call this page directly.' );
}
/**
 * settings.php - View for the Settings page.
 *
 * @package Better RSS Widget
 * @subpackage includes
 * @author GrandSlambert
 * @copyright 2009-2013
 * @access public
 * @since 2.1
 */
/* Flush the rewrite rules */
global $wp_rewrite, $wp_query;
$wp_rewrite->flush_rules();

if ( isset( $_REQUEST['tab'] ) ) {
	$selectedTab = $_REQUEST['tab'];
} else {
	$selectedTab = 'display';
}

$tabs = array(
	'display' => __( 'Display Settings', 'better-rss-widget' ),
	'page' => __( 'Page Settings', 'better-rss-widget' ),
	'cache' => __( 'Cache Settings', 'better-rss-widget' ),
	'administration' => __( 'Administration', 'better-rss-widget' ),
);
?>

<div id="overDiv" style="position:absolute; visibility:hidden; z-index:1000;" class="overDiv"></div>
<div class="wrap">
     <form method="post" action="options.php" id="better_rss_widget_settings">
          <input type="hidden" id="home_page_url" value ="<?php echo site_url(); ?>" />
          <div class="icon32" id="icon-better-rss-widget"><br/></div>
          <h2><?php echo $this->pluginName; ?> &raquo; <?php _e( 'Plugin Settings', 'better-rss-widget' ); ?> </h2>
		<?php if ( isset( $_REQUEST['reset'] ) ) : ?>
			<div id="settings-error-better-rss-widget_upated" class="updated settings-error">
				<p><strong><?php _e( 'Better RSS Widget settings have been reset to defaults.', 'better-rss-widget' ); ?></strong></p>
			</div>
		<?php endif; ?>
		<?php settings_fields( $this->optionsName ); ?>
		<input type="hidden" name="<?php echo $this->optionsName; ?>[random-value]" value="<?php echo rand( 1000, 100000 ); ?>" />
		<input type="hidden" name="active_tab" id="active_tab" value="<?php echo $selectedTab; ?>" />
		<ul id="better_rss_widget_tabs">
			<?php foreach ( $tabs as $tab => $name ) : ?>
				<li id="better_rss_widget_<?php echo $tab; ?>" class="better-rss-widget<?php echo ($selectedTab == $tab) ? '-selected' : ''; ?>">
					<a href="#top" onclick="better_rss_widget_show_tab('<?php echo $tab; ?>')"><?php echo $name; ?></a>
				</li>
			<?php endforeach; ?>
			<li id="better_rss_widget_save_tab" class="save-tab">
				<a href="#top" onclick="better_rss_widget_save_settings()"><?php _e( 'Save Settings', 'better-rss-widget' ); ?></a>
			</li>
		</ul>

		<div style="width:49%; float:left">
			<?php foreach ( $tabs as $tab => $name ) : ?>
				<div id="better_rss_widget_box_<?php echo $tab; ?>" style="display: <?php echo ($selectedTab == $tab) ? '' : 'none'; ?>">
					<?php require_once('settings/' . $tab . '.php'); ?>
				</div>
			<?php endforeach; ?>

		</div>

		<div style="width:49%; float:right">
			<?php require_once('sidebar-frame.php'); ?>
		</div>
	</form>
</div>
<?php require_once('footer.php'); ?>
