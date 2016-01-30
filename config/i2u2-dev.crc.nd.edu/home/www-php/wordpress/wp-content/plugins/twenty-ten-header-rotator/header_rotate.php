<?php
/*
Plugin Name: Twenty Ten Header Rotator
Plugin URI: http://hungrycoder.xenexbd.com/scripts/header-image-rotator-for-twenty-ten-theme-of-wordpress-3-0.html
Description: Rotate header images for Twenty Ten theme
Author: The HungryCoder
Version: 1.3
Author URI: http://hungrycoder.xenexbd.com
*/

if(!is_admin()){
	add_filter('theme_mod_header_image','hr_rotate');
}


function hr_rotate(){
	require_once (ABSPATH.'/wp-admin/custom-header.php');
	$hr = new Custom_Image_Header(null);
	$hr->process_default_headers();
	$all_headers=array();
	$i=0;
	foreach (array_keys($hr->default_headers) as $header){
		$all_headers[$i]['url']= sprintf( $hr->default_headers[$header]['url'], get_template_directory_uri(), get_stylesheet_directory_uri() );
		//$all_headers[$i]['thumbnail']= sprintf( $hr->default_headers[$header]['thumbnail_url'], get_template_directory_uri(), get_stylesheet_directory_uri() );
		//$all_headers[$i]['description']= $hr->default_headers[$header]['description'];
		$i++;
	}

	//add any custom header
	$custom = get_option('mods_Twenty Ten');
	if(is_array($custom)){
		if(!empty($custom['header_image']))	$all_headers[]['url']= $custom['header_image'];
	}

	$cur_header = $all_headers[rand(0,count($all_headers)-1)];

	return $cur_header['url'];
}
