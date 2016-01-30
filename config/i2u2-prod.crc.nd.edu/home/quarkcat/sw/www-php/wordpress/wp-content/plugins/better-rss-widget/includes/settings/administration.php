<?php
if ( preg_match( '#' . basename( __FILE__ ) . '#', $_SERVER['PHP_SELF'] ) ) {
	die( 'You are not allowed to call this page directly.' );
}
/**
 * admin.php - View for the administration tab.
 *
 * @package Better RSS Widget
 * @subpackage includes
 * @author GrandSlambert
 * @copyright 2009-2013
 * @access public
 * @since 2.1
 */
?>

<div class="postbox">
     <h3 class="handl" style="margin:0;padding:3px;cursor:default;">
		<?php _e( 'Administration', 'better-rss-widget' ); ?>
     </h3>
     <div class="table better-rss-widget-settings-table">
          <table class="form-table cp-table">
               <tbody>
                    <tr align="top">
                         <th scope="row"><label class="primary" for="better_rss_widget_reset_options"><?php _e( 'Reset to default', 'better-rss-widget' ); ?> : </label></th>
                         <td><input type="checkbox" id="better_rss_widget_reset_options" name="confirm-reset-options" value="1" onclick="better_rss_widget_reset(this)" /></td>
                    </tr>
                    <tr align="top">
                         <th scope="row"><label class="primary" for="better_rss_widget_search"><?php _e( 'Shortcode Search', 'better-rss-widget' ); ?> : </label></th>
                         <td>
						<?php _e( 'Search for instances of the shortcode in', 'better-rss-widget' ); ?>
						<?php echo $this->get_post_types( array( 'output' => 'dropdown', 'id' => 'better_rss_search_type' ) ); ?>
                              <input type="button" name="better_rss_search" onclick="better_rss_widget_search()" value="<?php _e( 'Search', 'better-rss-widget' ); ?>" />
                              <input type="hidden" name="url" id="better_rss_url" value="<?php echo admin_url( 'edit.php?s=[better-rss&post_type=' ); ?>" />
                         </td>
                    </tr>
                    <!--
                    <tr align="top">
                         <th scope="row"><label class="primary" for="better_rss_widget_backup_options"><?php _e( 'Back-up Options', 'better-rss-widget' ); ?> : </label></th>
                         <td><input type="checkbox" id="better_rss_widget_backup_options" name="confirm-backup-options" value="1" onclick="backupOptions(this)" /></td>
                    </tr>
                    <tr align="top">
                         <th scope="row"><label class="primary" for="better_rss_widget_restore_options"><?php _e( 'Restore Options', 'better-rss-widget' ); ?> : </label></th>
                         <td><input type="file" id="better_rss_widget_restore_options" name="better-rss-widget-restore-options"/></td>
                    </tr>
                    -->
               </tbody>
          </table>
     </div>
</div>