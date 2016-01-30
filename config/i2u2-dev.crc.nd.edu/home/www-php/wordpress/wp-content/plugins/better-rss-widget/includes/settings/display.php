<?php
if ( preg_match( '#' . basename( __FILE__ ) . '#', $_SERVER['PHP_SELF'] ) ) {
	die( 'You are not allowed to call this page directly.' );
}
/**
 * display.php - View for the display settings.
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
		<?php _e( 'Default Display Settings', 'better-rss-widget' ); ?>
     </h3>
     <div class="table better-rss-widget-settings-table">
          <table class="form-table">
			<colspan>
				<col width="35%">
				<col width="35%">
				<col width="30%">
			</colspan>
			<tbody>
				<tr align="top">
					<th scope="row"><label class="primary" for="<?php echo $this->optionsName; ?>_allow_intro"><?php _e( 'Use Intro Text?', 'better-rss-widget' ); ?></label></th>
					<td>
						<input type="checkbox" name="<?php echo $this->optionsName; ?>[allow_intro]" id="<?php echo $this->optionsName; ?>_allow_intro" value="1" <?php checked( $this->options->allow_intro, 1 ); ?>>
					</td>
				</tr>
				<tr align="top">
					<th scope="row"><label class="primary" for="<?php echo $this->optionsName; ?>_link_target"><?php _e( 'Default Link Target', 'better-rss-widget' ); ?> : </label></th>
					<td>
						<select name="<?php echo $this->optionsName; ?>[link_target]" id="<?php echo $this->optionsName; ?>_link_target">
							<option>None</option>
							<option value="_blank" <?php selected( $this->options->link_target, '_blank' ); ?>><?php _e( 'New Window', 'better-rss-widget' ); ?></option>
							<option value="_top" <?php selected( $this->options->link_target, '_top' ); ?>><?php _e( 'Top Window', 'better-rss-widget' ); ?></option>
						</select>
					</td>
				</tr>
				<tr align="top">
					<th scope="row"><label class="primary"><?php _e( 'Display items', 'better-rss-widget' ); ?> : </label></th>
					<td>
						<label>
							<input name="<?php echo $this->optionsName; ?>[show_summary]" type="checkbox" id="better_rss_widget_show_summary" value="1" <?php checked( $this->options->show_summary, 1 ); ?> />
							<?php _e( 'Item Summary', 'better-rss-widget' ); ?>
						</label>
					</td>
					<td><label>
							<input name="<?php echo $this->optionsName; ?>[show_author]" type="checkbox" id="better_rss_widget_show_summary" value="1" <?php checked( $this->options->show_author, 1 ); ?> />
							<?php _e( 'Item Author', 'better-rss-widget' ); ?>
						</label>
					</td>
				</tr>
				<tr align="top">
					<th scope="row"></th>
					<td>
						<label>
							<input name="<?php echo $this->optionsName; ?>[show_date]" type="checkbox" id="<?php echo $this->optionsName; ?>[show_date]" value="1" <?php checked( $this->options->show_date, 1 ); ?> />
							<?php _e( 'Item Date', 'better-rss-widget' ); ?>
						</label>
					</td>
					<td>
						<label>
							<input name="<?php echo $this->optionsName; ?>[show_time]" type="checkbox" id="<?php echo $this->optionsName; ?>_show_time" value="1" <?php checked( $this->options->show_time, 1 ); ?> />
							<?php _e( 'Item Time', 'better-rss-widget' ); ?>
						</label>
					</td>
				</tr>
				<tr align="top">
					<th scope="row"><label class="primary" for="<?php echo $this->optionsName; ?>_nofollow"><?php _e( 'Add nofollow to links', 'better-rss-widget' ); ?> : </label></th>
					<td><input name="<?php echo $this->optionsName; ?>[nofollow]" type="checkbox" id="<?php echo $this->optionsName; ?>_nofollow" value="1" <?php checked( $this->options->nofollow, 1 ); ?> /> </td>
				</tr>
				<tr align="top">
					<th scope="row"><label class="primary" for="<?php echo $this->optionsName; ?>_items"><?php _e( 'Default Items to Display', 'better-rss-widget' ); ?></label> : </th>
					<td><select name="<?php echo $this->optionsName; ?>[items]" id="<?php echo $this->optionsName; ?>_items">
							<?php
							for ( $i = 1; $i <= 20; ++$i )
								echo "<option value='$i' " . ($this->options->items == $i ? "selected='selected'" : '' ) . ">$i</option>";
							?>
						</select>
					</td>
				</tr>
				<tr align="top">
					<th scope="row"><label class="primary" for="<?php echo $this->optionsName; ?>_title_length"><?php _e( 'Max Length of Title', 'better-rss-widget' ); ?> : </label></th>
					<td colspan="2">
						<input  name="<?php echo $this->optionsName; ?>[title_length]" type="text" id="<?php echo $this->optionsName; ?>_title_length" value="<?php echo $this->options->title_length; ?>" />
						&nbsp;<?php _e('( Enter "0" for no limit. )', 'better-rss-widget'); ?>
					</td>
				</tr>
				<tr align="top">
					<th scope="row"><label class="primary" for="<?php echo $this->optionsName; ?>_excerpt"><?php _e( 'Length of Excerpt', 'better-rss-widget' ); ?> : </label></th>
					<td colspan="2"><input  name="<?php echo $this->optionsName; ?>[excerpt]" type="text" id="<?php echo $this->optionsName; ?>_excerpt" value="<?php echo $this->options->excerpt; ?>" /></td>
				</tr>
				<tr align="top">
					<th scope="row"><label class="primary" for="<?php echo $this->optionsName; ?>_suffix"><?php _e( 'Add after the excerpt', 'better-rss-widget' ); ?> : </label></th>
					<td colspan="2"><input name="<?php echo $this->optionsName; ?>[suffix]" type="text" id="<?php echo $this->optionsName; ?>_suffix" value="<?php echo $this->options->suffix; ?>" /></td>
				</tr>
			</tbody>
          </table>
     </div>
</div>