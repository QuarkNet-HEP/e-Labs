<?php
/*
Plugin Name: HTML Javascript Adder
Plugin URI: http://www.aakashweb.com
Description: A widget plugin for adding Javascripts, HTML scripts, Shortcodes, advertisements and even simple texts in the sidebar with advanced targeting on posts and pages.
Author: Aakash Chakravarthy
Version: 3.8
Author URI: http://www.aakashweb.com/
*/

if(!defined('WP_CONTENT_URL')) {
	$hja_url = get_option('siteurl') . '/wp-content/plugins/' . plugin_basename(dirname(__FILE__)).'/';
}else{
	$hja_url = WP_CONTENT_URL . '/plugins/' . plugin_basename(dirname(__FILE__)) . '/';
}

define('HJA_VERSION', '3.7');
define('HJA_AUTHOR', 'Aakash Chakravarthy');
define('HJA_URL', $hja_url);

$hja_donate_link = 'http://bit.ly/hjaDonate';

## Load languages
load_plugin_textdomain('hja', false, basename(dirname(__FILE__)) . '/languages/');

class html_javascript_adder_widget extends WP_Widget{

	## Initialize
	function html_javascript_adder_widget(){
		$widget_ops = array(
			'classname' => 'widget_html_javascript_adder',
			'description' => __("Insert HTML, Javascripts, shortcodes and other codes in the sidebar", 'hja')
		);
		
		$control_ops = array('width' => 480, 'height' => 500);
		parent::WP_Widget('html_javascript_adder', __('HTML Javascript Adder', 'hja'), $widget_ops, $control_ops);
		
		// Rename old array keys @since v3.5
		$hja = get_option('widget_html_javascript_adder');
		if(is_array($hja) && !isset($hja['_varscleaned'])){
			$toRep = array('hja_' , 'is_', 'diable_post');
			$repWith = array('', 'hide_', 'hide_in_posts');
			foreach($hja as $k=>$v){
				if(is_array($v)){
					foreach($v as $m=>$n){
						$old = $m;
						$new = str_replace($toRep, $repWith, $old);
						$hja[$k][$new] = $hja[$k][$old];
						unset($hja[$k][$old]);
					}
				}
			}
			$hja['_varscleaned'] = true;
			update_option('widget_html_javascript_adder', $hja);
		}
	}
	
	function page_check($instance){
		$hide_single = $instance['hide_single'];
		$hide_archive = $instance['hide_archive'];
		$hide_home = $instance['hide_home'];
		$hide_page = $instance['hide_page'];
		$hide_search = $instance['hide_search'];
		
		if (is_home() == 1 && $hide_home != 1){
			return true;
		
		}elseif (is_single() == 1 && $hide_single!= 1){
			return true;
		
		}elseif (is_page() == 1 && $hide_page != 1){
			return true;
		
		}elseif (is_archive() == 1 && $hide_archive != 1){
			return true;
		
		}elseif (is_tag() == 1 && $hide_archive != 1){
			return true;
		
		}elseif(is_search() == 1 && $hide_search != 1){
			return true;
		
		}else{
			return false;
		}
	}
	
	function admin_check($instance){
		$hide_admin = $instance['hide_admin'];
		
		if(current_user_can('level_10') && $hide_admin == 1){
			return true;
		}else{
			return false;
		}
	}
	
	function hide_post_check($instance){
		global $post;
		$hide_in_posts = $instance['hide_in_posts'];
		$splitId = explode(',', $hide_in_posts);
		
		if(is_page($splitId) || is_single($splitId)){
			return false;
		}else{
			return true;
		}
	}
	
	function show_post_check($instance){
		global $post;
		$show_in_posts = $instance['show_in_posts'];
		$splitId = explode(',', $show_in_posts);
		
		if(is_page($splitId) || is_single($splitId)){
			return true;
		}else{
			return false;
		}
	}
	
	function all_ok($instance){
		if($this->admin_check($instance)){
			return false;
		}else{
			if($instance['display_in'] == 'all'){
				return true;
			}elseif($instance['display_in'] == 'hide_only'){
				return (
					$this->page_check($instance) && 
					$this->hide_post_check($instance)
				);
			}elseif($instance['display_in'] == 'show_only'){
				return (
					$this->show_post_check($instance)
				);
			}else{
				return true;
			}
		}
	}
	
	## Display the Widget
	function widget($args, $instance){
		extract($args);
		
		if(empty($instance['title'])){
			$title = '';
		}else{
			$title = $before_title . apply_filters('widget_title', $instance['title'], $instance, $this->id_base) . $after_title;
		}
		
		if(empty($instance['content'])){
			$content = '';
		}elseif($instance['add_para'] == 1){
			$content = wpautop($instance['content']);
		}else{
			$content = $instance['content'];
		}
		
		if($this->all_ok($instance)){
			$content = do_shortcode($content);
		}
		
		$before_content = "\n" . '<div class="hjawidget textwidget">' . "\n";
		$after_content = "\n" . '</div>' . "\n";
		
		$before_cmt = "\n<!-- Start - HTML Javascript Adder plugin v" . HJA_VERSION . " -->\n";
		$after_cmt =  "<!-- End - HTML Javascript Adder plugin v" . HJA_VERSION . " -->\n";
		
		## Output
		$output_content = 
			$before_cmt .
				$before_widget . 
					$title . 
					$before_content . 
						$content . 
					$after_content . 
				$after_widget.
			$after_cmt;
		
		## Print the output
		echo $output_content;

	}
	
	## Save settings
	function update($new_instance, $old_instance){
		$instance = $old_instance;
		$instance['title'] = stripslashes($new_instance['title']);
		$instance['content'] = stripslashes($new_instance['content']);
		
		$instance['hide_single'] = $new_instance['hide_single'];
		$instance['hide_archive'] = $new_instance['hide_archive'];
		$instance['hide_home'] = $new_instance['hide_home'];
		$instance['hide_page'] = $new_instance['hide_page'];
		$instance['hide_search'] = $new_instance['hide_search'];
		
		$instance['add_para'] = $new_instance['add_para'];
		
		$instance['hide_admin'] = $new_instance['hide_admin'];
		$instance['hide_in_posts'] = $new_instance['hide_in_posts'];
		$instance['show_in_posts'] = $new_instance['show_in_posts'];
		
		$instance['display_in'] = $new_instance['display_in'];
		
		return $instance;
	}
  
	## HJA Widget form
	function form($instance){

		$instance = wp_parse_args( (array) $instance, array(
			'title' => '', 'content' => '', 'hide_single'=> '0',
			'hide_archive' => '0', 'hide_home' => '0', 'hide_page' => '0',
			'hide_search' => '0', 'add_para' => '0', 'hide_admin' => '0', 
			'hide_in_posts' => '', 'show_in_posts' => '', 'display_in' => 'all'
		));
		
		$title = htmlspecialchars($instance['title']);
		$content = htmlspecialchars($instance['content']);
		
		$hide_single = $instance['hide_single'];
		$hide_archive = $instance['hide_archive'];
		$hide_home = $instance['hide_home'];
		$hide_page = $instance['hide_page'];
		$hide_search = $instance['hide_search'];
		
		$add_para = $instance['add_para'];
		
		$hide_admin = $instance['hide_admin'];
		$hide_in_posts = $instance['hide_in_posts'];
		$show_in_posts = $instance['show_in_posts'];
		
		$display_in = $instance['display_in'];
	?>
	
		<div class="section">
			<label><?php _e('Title', 'hja'); ?> :<br />
				<input id="<?php echo $this->get_field_id('title');?>" name="<?php echo $this->get_field_name('title'); ?>" type="text" value="<?php echo $title; ?>" class="widefat" placeholder="Enter the title here"/>
			</label>
		</div>
		
		<div class="section">
			<label for="<?php echo $this->get_field_id('content'); ?>"><?php _e('Content :', 'hja'); ?></label>
			
			<ul class="hjaToolbar clearfix">
				<li class="hjaSupport" title="If you like this plugin, then just make a small Donation to continue this plugin development."><a href="http://bit.ly/hjaDonate" target="_blank" class="hjaDonate"><img src="<?php echo HJA_URL . 'images/donate-icon.png'; ?>" /></a></li>
				<li class="hjaSupport hjaShare" title="Like this plugin !"><img src="<?php echo HJA_URL . 'images/like-icon.png'; ?>" /></li>
				<li><img src="<?php echo HJA_URL . 'images/edit-icon.png'; ?>" /> Toolbar
					<ul>
						<li editorId="<?php echo $this->get_field_id('content'); ?>">
							
							<span class="hjaTb" openTag="&lt;h1&gt;" closeTag="&lt;/h1&gt;">H1</span>
							<span class="hjaTb" openTag="&lt;h2&gt;" closeTag="</h2>">H2</span>
							<span class="hjaTb hjaTbSpace" openTag="&lt;h3&gt;" closeTag="&lt;/h3&gt;">H3</span>
							
							<span class="hjaTb" openTag="&lt;strong&gt;" closeTag="&lt;/strong&gt;">B</span>
							<span class="hjaTb" openTag="&lt;em&gt;" closeTag="&lt;/em&gt;">I</span>
							<span class="hjaTb" openTag="&lt;u&gt;" closeTag="&lt;/u&gt;">U</span>
							<span class="hjaTb hjaTbSpace" openTag="<s>" closeTag="</s>">S</span>
							
							<span class="hjaTb" openTag="&lt;a " closeTag="&lt;/a&gt;" action="a">Link</span>
							<span class="hjaTb" openTag="&lt;img " closeTag="/&gt;" action="img">Image</span>
							<span class="hjaTb" openTag="&lt;code&gt;" closeTag="&lt;/code&gt;">Code</span>
							<span class="hjaTb" openTag="&lt;p&gt;" closeTag="&lt;/p&gt;">P</span>
							<span class="hjaTb" openTag="&lt;ol&gt;" closeTag="&lt;/ol&gt;">OL</span>
							<span class="hjaTb" openTag="&lt;ul&gt;" closeTag="&lt;/ul&gt;">UL</span>
							<span class="hjaTb" openTag="&lt;li&gt;" closeTag="&lt;/li&gt;">LI</span>
							<span class="hjaTb" openTag="&lt;br/&gt;" closeTag="">Br</span>
						</li>
					</ul>
				</li>

				<?php echo $this->wpsr_toolbar($this->get_field_id('content')); ?>
				
				<li><img src="<?php echo HJA_URL . 'images/help-icon.png'; ?>" /> Help
					<ul>
						<li><a href="http://www.aakashweb.com/wordpress-plugins/html-javascript-adder/" target="_blank">Documentation</a></li>
						<li><a href="http://www.aakashweb.com/forum/" target="_blank">Report Bugs</a></li>
					</ul>
				</li>
				
				<li class="hjaTb-preview" editorId="<?php echo $this->get_field_id('content'); ?>"><img src="<?php echo HJA_URL . 'images/preview-icon.png'; ?>" /> Preview</li>
			</ul>
			
			<textarea rows="10" id="<?php echo $this->get_field_id('content'); ?>" name="<?php echo $this->get_field_name('content'); ?>" class="hjaContent" spellcheck="false" placeholder="Enter your HTML/Javascript/Plain text content here"><?php echo $content; ?></textarea>
		</div>
		
		<div class="section">
			<h3><?php _e("Settings", 'hja'); ?></h3>
			
			<label class="hjaAccord"><input type="radio" name="<?php echo $this->get_field_name('display_in'); ?>" value="all" <?php echo ($display_in == 'all') ? 'checked="checked"' : '' ; ?> /> <?php _e("Show in all pages", 'hja'); ?></label>
			
			<label class="hjaAccord"><input type="radio" name="<?php echo $this->get_field_name('display_in'); ?>" value="show_only" <?php echo ($display_in == 'show_only') ? 'checked="checked"' : '' ; ?> /> <?php _e("Show only in specific pages", 'hja'); ?></label>
			
			<div class="hjaAccordWrap" <?php echo ($display_in != 'show_only') ? 'style="display:none"' : '' ; ?>>
				<label><input id="<?php echo $this->get_field_id('show_in_posts'); ?>" type="text" name="<?php echo $this->get_field_name('show_in_posts'); ?>" value="<?php echo $show_in_posts; ?>" class="widefat hjaGetPosts"/></label>
				<span class="smallText"><?php _e("Post ID / name / title separated by comma", 'hja'); ?></span>
			</div> <!-- HJA ACCORD WRAP 2 -->
			
	
			<label class="hjaAccord"><input type="radio" name="<?php echo $this->get_field_name('display_in'); ?>" value="hide_only" <?php echo ($display_in == 'hide_only') ? 'checked="checked"' : '' ; ?> /> <?php _e("Hide only in specific pages", 'hja'); ?></label>
			
			<div class="hjaAccordWrap" <?php echo ($display_in != 'hide_only') ? 'style="display:none"' : '' ; ?>>
			
			<label><input id="<?php echo $this->get_field_id('hide_single'); ?>" type="checkbox"  name="<?php echo $this->get_field_name('hide_single'); ?>" value="1" <?php echo $hide_single == "1" ? 'checked="checked"' : ""; ?> /> <?php _e("Don't display in Posts page", 'hja'); ?></label>
			
			<label><input id="<?php echo $this->get_field_id('hide_archive'); ?>" type="checkbox" name="<?php echo $this->get_field_name('hide_archive'); ?>" value="1" <?php echo $hide_archive == "1" ? 'checked="checked"' : ""; ?>/> <?php _e("Don't display in Archive or Tag page", 'hja'); ?></label>
			
			<label><input id="<?php echo $this->get_field_id('hide_home'); ?>" type="checkbox" name="<?php echo $this->get_field_name('hide_home'); ?>" value="1" <?php echo $hide_home == "1" ? 'checked="checked"' : ""; ?>/> <?php _e("Don't display in Home page", 'hja'); ?></label>
			
			<label><input id="<?php echo $this->get_field_id('hide_page'); ?>" type="checkbox" name="<?php echo $this->get_field_name('hide_page'); ?>" value="1" <?php echo $hide_page == "1" ? 'checked="checked"' : ""; ?>/> <?php _e("Don't display in Pages", 'hja'); ?></label>
			
			<label><input id="<?php echo $this->get_field_id('hide_search'); ?>" type="checkbox" name="<?php echo $this->get_field_name('hide_search'); ?>" value="1" <?php echo $hide_search == "1" ? 'checked="checked"' : ""; ?>/> <?php _e("Don't display in Search page", 'hja'); ?></label><br />
			
			<label><?php _e("Don't show in posts", 'hja'); ?><br />
				<input id="<?php echo $this->get_field_id('hide_in_posts'); ?>" type="text" name="<?php echo $this->get_field_name('hide_in_posts'); ?>" value="<?php echo $hide_in_posts; ?>" class="widefat hjaGetPosts"/></label>
				<span class="smallText"><?php _e("Post ID / name / title separated by comma", 'hja'); ?></span>
				
			</div><!-- HJA Accord 3 -->
			
			<div class="hjaOtherOpts">
			<label><input id="<?php echo $this->get_field_id('add_para'); ?>" type="checkbox" name="<?php echo $this->get_field_name('add_para'); ?>" value="1" <?php echo $add_para == "1" ? 'checked="checked"' : ""; ?>/> <?php _e("Automatically add paragraphs", 'hja'); ?></label> &nbsp;
			
			<label><input id="<?php echo $this->get_field_id('hide_admin'); ?>" type="checkbox" name="<?php echo $this->get_field_name('hide_admin'); ?>" value="1" <?php echo $hide_admin == "1" ? 'checked="checked"' : ""; ?>/> <?php _e("Don't display to admin", 'hja'); ?></label>
			</div>
			
		</div>

		<?php	  
	}
	
	function wpsr_check(){
		if(function_exists('wp_socializer') && WPSR_VERSION >= '2.3'){
			return 1;
		}else{
			return 0;
		}
	}
	
	function wpsr_toolbar($edit_id){
		if($this->wpsr_check()){
			global $wpsr_shortcodes_list;
			
			$list = '<li><img src="' . WPSR_ADMIN_URL . 'images/wp-socializer.png" width="12" height="12" /> WP Socializer Buttons <ul><li editorId="' . $edit_id . '">';
			foreach($wpsr_shortcodes_list as $name => $val){
				$list .= '<span class="hjaTb" openTag="' . $val . '" closeTag="">' . $name . '</span>';
			}
			$list .= '<li><a href="http://www.aakashweb.com/docs/wp-socializer-docs/function-reference/" target="_blank">Customize buttons</a></li></ul></li>';
			return $list;
		}
	}
}
## End class

function html_javascript_adder_init(){
	register_widget('html_javascript_adder_widget');
}
add_action('widgets_init', 'html_javascript_adder_init');

function hja_include_files($hook){
	
	if($hook == "widgets.php"){
		
		wp_register_script('hja-script', HJA_URL . 'js/hja-widget.js');
		wp_enqueue_script('hja-script');
		
		wp_register_script('hja-awquicktag', HJA_URL . 'js/awQuickTag.js');
		wp_enqueue_script('hja-awquicktag');
		
		wp_register_style('hja-style', HJA_URL . 'hja-widget-css.css');
		wp_enqueue_style('hja-style');
		
	}
}
add_action('admin_enqueue_scripts', 'hja_include_files'); 

function hja_admin_footer(){
	global $pagenow, $post;
	
	if($pagenow == "widgets.php"){
	
		echo '<span style="display:none" class="hjaUrl">' . HJA_URL . '</span>';
		echo '<div class="hjaWindow">
			<span class="hjaOverlayClose"></span>
			<h3 class="hjaWinHead">Preview</h3>
			<iframe id="hjaIframe" name="hjaIframe" src="about:blank"></iframe>
			If the script is not working, try it in <a href="http://jsfiddle.com" target="_blank">jsfiddle</a>
		</div>';
		
	}

}
add_action('admin_footer', 'hja_admin_footer'); 

## Action Links
function hja_plugin_actions($links, $file){
	static $this_plugin;
	global $hja_donate_link;
	
	if(!$this_plugin) $this_plugin = plugin_basename(__FILE__);
	if( $file == $this_plugin ){
		$settings_link = "<a href='$hja_donate_link' title='If you like this plugin, then just make a small Donation to continue this plugin development.' target='_blank'>" . __('Make Donations', 'hja') . '</a> ';
		$links = array_merge(array($settings_link), $links);
	}
	return $links;
}
add_filter('plugin_action_links', 'hja_plugin_actions', 10, 2);
?>