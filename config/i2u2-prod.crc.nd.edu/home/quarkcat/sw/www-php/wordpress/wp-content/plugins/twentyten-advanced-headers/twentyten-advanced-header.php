<?php
/*
Plugin Name: TwentyTen Advanced Header
Plugin URI: http://www.coolryan.com/plugins/twentyten-advanced-headers/
Description: Turbo-Charge your twenty ten header!
Version: 1.0
Author: Cool Ryan
Author URI: http://www.coolryan.com
*/


class Twentyten_Advanced_Header {

	/**
	 * Holds admin notice messages. 
	 * 
	 * Displayed through display_message.
	 * @var $message
	 */
	public $message;
	
	
	/**
	 * Holds plugin options from table. 
	 * 
	 * Loaded via load_options.
	 * @var $options
	 */
	public $options;

	
	/**
	 * PHP 4 Constructor
	 */
	function Twentyten_Advanced_Header() {
		$this->__construct(); // For PHP 4 compatibility.
	}
	
	
	/**
	 * Class Constructor.
	 */
	function __construct() {
		add_action('plugins_loaded', array(&$this, 'init'));
	}
	
	
	/**
	 * Loads init based upon location.  
	 * 
	 * @name Init
	 * @since 1.0
	 * @uses admin_init, frontend_init
	 * @return void
	 */
	function init() {
		// Admin Functions
		if(is_admin()) {
			$this->admin_init();
		}
		// Frontend functions
		else {
			$this->frontend_init();
		}
	}
	
	
	/**
	 * All Admin functionality.
	 * 
	 * @name Admin Init
	 * @since 1.0
	 * @uses add_action, save_options, load_options
	 * @return void
	 */
	function admin_init() {
		$this->save_options(); // Saves the options
		$this->load_options(); // Load options into variable
		add_action('admin_notices', array(&$this, 'display_message')); // Displays Admin Notices
		add_action('admin_menu', array(&$this, 'admin_menu')); // Loads the Admin Menu
	}
	
	
	/**
	 * All frontend functionality. 
	 * 
	 * @name Frontend Init
	 * @since 1.0
	 * @uses add_action, load_options
	 * @return void
	 */
	function frontend_init() {
		$this->load_options();
		add_action('wp', array(&$this, 'set_header')); // Runs condition for header.
	}
	
	
	/**
	 * Displays admin notice messages
	 * 
	 * @name Display Message
	 * @since 1.0
	 * @return string $message.  The admin notice. 
	 */
	function display_message() {
		if(!empty($this->message)) {
			echo $this->message;
		}
	}
	
	
	/**
	 * Renders the Admin menu
	 * 
	 * @name Admin Menu
	 * @since 1.0
	 * @uses add_theme_page
	 * @return void
	 */
	function admin_menu() {
		add_theme_page( 'Twentyten Advanced Header', 'Adv. Header', 'manage_options', 'advanced-header', array(&$this, 'options_html') );
	}
	
	
	/**
	 * Saves options to the database.
	 * 
	 * @name Save Options
	 * @since 1.0
	 * @uses update_option
	 * @return void
	 */
	function save_options() {
		if(isset($_POST['submitted'])) {
			update_option('advanced-header-images', $_POST['category']);
			$this->message .= '<div class="updated"><p>Headers Updated!</p></div>'; // Success!
			
		}
	}
	
	
	/**
	 * Loads the options into the $options variable
	 * 
	 * @name Load Options
	 * @since 1.0
	 * @uses get_option
	 * @return void
	 */
	function load_options() {
		$this->options = get_option('advanced-header-images');
	}
	
	
	/**
	 * The html for the options page.
	 * 
	 * @name Options HTML
	 * @since 1.0
	 * @uses category_header_display
	 * @return void
	 */
	function options_html() {
	?>
	<div class="wrap">
		<h2>Advanced Header Options</h2>
		Enter the URL of a header image into the forms below for each respective category.  They will show up on all pages pertaining to that category. 
		<form action="" method="POST">
			<table class="form-table">
				<tr valign="top">
					<td>
						<?php $this->category_header_display();?>
					</td>
				</tr>
			
			</table>
			<p class="submit">
				<input type="submit" name="submit" value="Update Headers" class="button-primary" />
			</p>
			<input type="hidden" name="submitted" value="update-headers" />
		</form>
		
	</div>
	<?php 
	}
	
	
	/**
	 * Shows the category forms.
	 * 
	 * @name Category Header Display
	 * @since 1.0
	 * @uses get_categories
	 * @return string.  The html for the category forms.
	 */
	function category_header_display() {
	
		foreach(get_categories('hide_empty=0') as $category) {
			echo '<strong>'. $category->name . '</strong> <input type="text" class="large-text" name="category['.$category->term_id.']" value="'.$this->options[$category->term_id].'" /><br />';
		}
	}
	
	
	/**
	 * Checks conditions for adding a customized header.
	 * 
	 * Checks to see if on a single page.  If so, grabs categories for that page.  
	 * If any of those categories has a header in the options, and that option is not null,
	 * then it adds the filter to replace the header.
	 *
	 * @name Set Header
	 * @since 1.0
	 * @global $post
	 * @uses is_single, is_category, is_front_page, wp_get_post_categories, add_filter
	 * @return void
	 */
	function set_header() {
		global $post;
		
		// Are we in the right location?
		if(is_single() || is_category() && !is_front_page()) {
			
			// Grab the categories
			$categories = wp_get_post_categories($post->ID);
			foreach($categories as $category) {
				
				// Do we have any headers to go through?
				if($this->options) {
					
					// Do any headers exist for this category?
					if(array_key_exists($category, $this->options)) {
						
						// Does this category have a header?
						if(!empty($this->options[$category])) {
							
							// Run the filter.
							add_filter('theme_mod_header_image', array(&$this, 'header_image'));
							break; // Exit loop.
						}
					}
				}
			}
		}
	}
	
	
	/**
	 * Returns the header image URL. 
	 * 
	 * Called via filter, theme_mod_header_image, (see above).
	 * 
	 * @name Header Image
	 * @since 1.0
	 * @global $post
	 * @uses wp_get_post_categories
	 * @return string.  the url of the header image.
	 */
	function header_image() {
		global $post;
		$categories = wp_get_post_categories($post->ID);
		foreach($categories as $category) {
			if(array_key_exists($category, $this->options)) {
				if(!empty($this->options[$category])) {
					return $this->options[$category];
					break;
				}
			}
		}
		  
	}
}

$ttsh = new Twentyten_Advanced_Header(); // Initiate the plugin.