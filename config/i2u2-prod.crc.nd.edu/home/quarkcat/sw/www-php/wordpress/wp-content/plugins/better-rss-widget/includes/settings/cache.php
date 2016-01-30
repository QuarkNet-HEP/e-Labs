<?php
if ( preg_match( '#' . basename( __FILE__ ) . '#', $_SERVER['PHP_SELF'] ) ) {
	die( 'You are not allowed to call this page directly.' );
}
/**
 * cache.php - View for the cache settings.
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
		<?php _e( 'Feed Cache Settings', 'better-rss-widget' ); ?>
     </h3>
     <div class="table better-rss-widget-settings-table">
          <table class="form-table">
               <tr align="top">
                    <th scope="row"><label class="primary" for="<?php echo $this->optionsName; ?>_enable_cache"><?php _e( 'RSS Cache', 'better-rss-widget' ); ?> : </label></th>
                    <td>
                         <label><input name="<?php echo $this->optionsName; ?>[enable_cache]" type="radio" id="better_rss_widget_enable_cache" value="1" <?php checked( $this->options->enable_cache, 1 ); ?> /> <?php _e( 'Enabled', 'better-rss-widget' ); ?></label>
                         <label><input name="<?php echo $this->optionsName; ?>[enable_cache]" type="radio" id="better_rss_widget_disable_cache" value="0" <?php checked( $this->options->enable_cache, 0 ); ?> /> <?php _e( 'Disabled', 'better-rss-widget' ); ?></label>
                    </td>
               </tr>
               <tr align="top">
                    <th scope="row"><label class="primary" for="<?php echo $this->optionsName; ?>_cache_duration"><?php _e( 'Cache Duration (seconds)<br /><small>ex. 3600 seconds = 60 minutes</small>', 'better-rss-widget' ); ?> : </label></th>
                    <td><input  name="<?php echo $this->optionsName; ?>[cache_duration]" type="text" id="<?php echo $this->optionsName; ?>_cache_duration" value="<?php echo $this->options->cache_duration; ?>" /> <?php _e( 'seconds', 'better-rss-widget' ); ?>. </td>
               </tr>
          </table>
     </div>
</div>