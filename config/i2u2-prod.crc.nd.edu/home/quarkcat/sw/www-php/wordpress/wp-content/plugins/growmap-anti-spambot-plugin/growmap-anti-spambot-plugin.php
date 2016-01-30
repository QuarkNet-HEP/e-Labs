<?php
/*
Plugin Name: Growmap Anti Spambot Plugin
Plugin URI: http://www.growmap.com/growmap-anti-spambot-plugin/
Description: Very simple plugin that adds a client side generated checkbox to the comment form requesting that the user clicks it to prove they are not a spammer. Bots wont see it so their spam comment will be discarded.
Version: 1.5.4
Author: Andy Bailey
Author URI: http://ComLuv.com
*/

/*********************************************
*		setup
*********************************************/
$gasp_plugin_dir = dirname(__FILE__);
$gasp_plugin_url = WP_PLUGIN_URL.'/'.basename(dirname(__FILE__));
$gasp_check = false;
$gasped = false;


/*********************************************
*		hooks
*********************************************/
if(is_admin()){
    // admin hooks
    add_action( 'admin_menu', 'gasp_admin_link' );
    add_action( 'admin_init', 'gasp_admin_init' );
    add_filter ( 'plugin_action_links', 'gasp_action' , - 10, 2 ); 
} else {
    // public hooks
    add_action('comment_form','gasp_add_checkbox',1);
    add_filter('preprocess_comment','gasp_check_comment',1,1);
    add_filter('pre_comment_approved','gasp_autospam_comment_check',1,1);
}
// everywhere hooks
add_action('init','gasp_init');

/*********************************************
*		internal functions
*********************************************/

/**
* strip the links out of the comment text if moderated comment
* @param string $commenttext
* @return string
* since 1.5.4
*/
function gasp_strip_tags($commenttext){
    global $comment;
    if($comment->comment_approved == '0'){
        return strip_tags($commenttext);
    }
    return $commenttext;
}
/**
* strip the link off the name if comment is in moderation
* @param string $authorlink
* @return string
*/
function gasp_get_comment_author($authorlink){
    global $comment;
    if($comment->comment_approved == '0'){
        return get_comment_author();
    }
    return $authorlink;
}
/** gasp_init
*/
function gasp_init(){
    load_plugin_textdomain( 'ab_gasp', false, dirname( plugin_basename( __FILE__ ) ) . '/languages' );
    if(is_singular()){
        // filters for single posts to remove links from moderated comments
        add_filter('comment_text','gasp_strip_tags',99);
        add_filter('get_comment_author_link','gasp_get_comment_author',99);
    }
}
/** gasp_admin_init
* Sets up the admin pages and settings
*/
function gasp_admin_init(){
    register_setting( 'gasp_options_group', 'gasp_options' , 'gasp_options_sanitize');
}

/** gasp_admin_link
* Add link to settings panel in dashboard
*/
function gasp_admin_link(){
    // language
    load_plugin_textdomain( 'ab_gasp', false, dirname( plugin_basename( __FILE__ ) ) . '/languages' );
    add_options_page('Growmap Anti Spambot Plugin Settings','G.A.S.P.','manage_options','gasp','gasp_options_page');
}

/** gasp_action
* adds a link on the plugins page next to activate/deactivate to go to the settings page
* @param array $links - the links to be filtered
*@param string $file - the file whos links are being filtered
* return string $links - the new string of links
*/
function gasp_action($links,$file){
    $this_plugin = plugin_basename ( __FILE__ );
    if ($file == $this_plugin) {
        $links [] = "<a href='options-general.php?page=gasp'>" . __ ( 'Settings', 'ab_gasp' ) . "</a>";
    }
    return $links;
}

/** gasp_get_options
* Retrieves the options from the database.
* Returns saved options or defaults if no options have been saved.
*/
function gasp_get_options(){
    //debugbreak();
    $checkbox_name = 'cl_check_'.substr(md5(home_url()),0,3);
    $default_options = array(
        'checkbox_alert' => __('Please check the box to confirm that you are NOT a spammer','ab_gasp'),
        'no_checkbox_message' => __('You may have disabled javascript. Please enable javascript before leaving a comment on this site.','ab_gasp'),
        'hidden_email_message' => __('You appear to be a spambot. Contact admin another way if you feel this message is in error','ab_gasp'),
        'checkbox_label' => __('Confirm you are NOT a spammer','ab_gasp'),
        'trackbacks' => 'yes',
        'refer_check' => 'yes',
        'urls' => '0',
        'name_words' => '0',
        'checkbox_name' => $checkbox_name,
        'secret_key' => COOKIEHASH.md5(home_url()),
        'send_to' => 'spam',
        'version' => '1.5.2'
    );
    $options = get_option('gasp_options',$default_options);
    // update options with new defaults if upgrading from older version
    if((float)$options['version'] < 0.4 ){
        update_option('gasp_options',$default_options);
        return $default_options;
    }
    if((float)$options['version'] < 1.1){
        $options['version'] = '1.1';
        $options['trackbacks'] = 'yes';
        $options['urls'] = '0';
        $options['name_words'] = '0';
        $options['send_to'] = 'spam';
        update_option('gasp_options',$options);
    }
    if(version_compare($options['version'],'1.2','<')){
        $options['version'] = '1.2';
        $options['checkbox_name'] = $checkbox_name;
        update_option('gasp_options',$options);
    }
    if(version_compare($options['version'], 1.4,'<')){
        $options['version'] = '1.4';
        $options['secret_key'] = COOKIEHASH.md5(home_url());
        update_option('gasp_options',$options);
    }
    if(version_compare($options['version'],'1.5.2','<')){
        $options['version'] = '1.5.2';
        $options['refer_check'] = 'yes';
        $options['use_secret_key'] = 'no';
        $options['max_mod'] = 3;
        update_option('gasp_options',$options);
    }
    return $options;
}

/** gasp_options_sanitize
* checks the options before they are saved
*/
function gasp_options_sanitize($newoptions){
    //debugbreak();
    $urls = intval($newoptions['urls']);
    $name_words = intval($newoptions['name_words']);
    if(!isset($newoptions['secret_key']) || !$newoptions['secret_key']){
        $secret_key = COOKIEHASH.md5(home_url());
    }
    $secret_key = preg_replace('/[^a-zA-Z0-9]/','',$newoptions['secret_key']);
    $newoptions['secret_key'] = $secret_key;
    $newoptions['use_secret_key'] = $newoptions['use_secret_key'] == 'yes'? 'yes':'no';
    $newoptions['urls'] = (string)$urls;
    $newoptions['name_words'] = (string)$name_words;
    $newoptions['refer_check'] = $newoptions['refer_check'] == 'yes'? 'yes':'no';
    $newoptions['max_mod'] = (int)$newoptions['max_mod'];
    return $newoptions;
}

/** gasp_check_comment
* Called by preprocess_comment filter
* @param array $commentdata - array containing indices "comment_post_ID", "comment_author", "comment_author_email", "comment_author_url", "comment_content", "comment_type", and "user_ID"
* Return array updated comment data array or wp_die()
*/
function gasp_check_comment($commentdata){
    //DebugBreak();
    global $gasp_check;

    $options = gasp_get_options();
    if($commentdata['comment_type'] == 'pingback' || $commentdata['comment_type'] == 'trackback'){
        if($options['trackbacks'] == 'yes'){
            return $commentdata;
        } else {
            exit;
        }
    }
    if(is_user_logged_in()){
        return $commentdata;
    }
    // construct return link
    $nocache_return = '<p><a href="'.add_query_arg('nocache','yes',get_permalink($commentdata['comment_post_ID'])).'">'.__('The cache may have been out of date. Use this link to view a fresh version','ab_gasp').' '.get_the_title($commentdata['comment_post_ID']).'</a>';
    // referer check. make sure the page sending the comment is correct
    //debugbreak();         
    if($options['refer_check'] != 'no'){
        if(!isset($_SERVER['HTTP_REFERER'])){
            update_option('gasp_count',get_option('gasp_count',true)+1);
            wp_die($options['hidden_email_message'].$nocache_return.'<p>Error Code: nr01');
        }
        $refer = parse_url($_SERVER['HTTP_REFERER']);
        $posturl = parse_url(get_permalink($_POST['comment_post_ID']));
        if($refer['host'] != $posturl['host']){
            update_option('gasp_count',get_option('gasp_count',true)+1);
            wp_die($options['hidden_email_message'].$nocache_return.'<p>Error Code: nr02');
        }
    }

    // checkbox check
    if(!isset($_POST[$options['checkbox_name']])){
        wp_die($options['no_checkbox_message'].$nocache_return.'<p>Error Code: nc03');
    } elseif (isset($_POST['gasp_email']) && $_POST['gasp_email'] !== ''){
        $commentdata['comment_approved'] = 'spam';
        wp_insert_comment($commentdata);
        update_option('gasp_count',get_option('gasp_count',true)+1);
        wp_die($options['hidden_email_message'].$nocache_return.'<p>Error Code: he04');
    }
    // secret key check
    if($options['use_secret_key'] != 'no'){
        $check = md5($options['secret_key'].$commentdata['comment_post_ID']);
        if(!isset($_POST[$check]) || $_POST[$check] != $check){
            $commentdata['comment_approved'] = 'spam';
            wp_insert_comment($commentdata);
            update_option('gasp_count',get_option('gasp_count',true)+1);
            wp_die($options['hidden_email_message'].$nocache_return.'<p>Error Code sk05');
        } 
    }      
    // check optional heuritics
    if($options['urls'] != '0'){
        $count = (int)$options['urls'];
        if(substr_count($commentdata['comment_content'], "http") > $count){
            $gasp_check = $options['send_to'];
        } 
    }
    if($options['name_words'] != '0'){
        $count = (int)$options['name_words'];
        if(substr_count($commentdata['comment_author'],' ') >= $count){
            $gasp_check = $options['send_to'];
        }
    }
    if(isset($options['max_mod']) && $options['max_mod'] != 'disabled'){
        $count = get_comments(array('status'=>'hold','author_email'=>$commentdata['comment_author_email'],'count'=>true));
        if($count && $count > $options['max_mod']){
            wp_die(__('You already have too many comments in moderation. Please wait until your existing comments have been approved before attempting to leave more comments','ab_gasp').$nocache_return.'<p>Error Code: mc'.$count.'mm0'.$options['max_mod']);
        }
    }
    return $commentdata; // send back commentdata, another filter will set comment as spam/pending if gasp is set
}

function gasp_autospam_comment_check($approved){
    //DebugBreak();
    global $gasp_check;
    if($gasp_check != NULL){
        $approved = $gasp_check;
    }
    return $approved;
}


/*********************************************
*		admin output
*********************************************/
/** gasp_options_page
* This function handles the page for options
*/
function gasp_options_page(){
    //debugbreaK();
    $options = gasp_get_options();

    global $gasp_plugin_url;
    if(empty($options['secret_key'])){
        $options['secret_key'] = COOKIEHASH.md5(home_url());
    } 
    $count = get_option('gasp_count');
    $gasp_count = $count ? $count : 0;
    ?>
    <div class="wrap">
        <h2>Growmap Anti Spambot Plugin Settings Page</h2> Version <?php echo $options['version'];?> 
        <?php echo __('GASP has caught this many bot comments','ab_gasp') . ' : <strong style="font-size:1.2em">'. $gasp_count . '</strong> '. __('(This does not count people who do not check the box)','ab_gasp')?>
        <form method="post" action="options.php">
            <?php settings_fields( 'gasp_options_group' );?>
            <table class="form-table postbox">
                <tr valign="top"  class="alt menu_option postbox">
                    <td><?php _e('Checkbox Label','ab_gasp');?></td>
                    <td><input type="text" size="60" name="gasp_options[checkbox_label]" value="<?php echo $options['checkbox_label'];?>"/></td>
                </tr>
                <tr valign="top"  class="alt menu_option postbox">
                    <td><?php _e('Checkbox Name','ab_gasp');?></td>
                    <td><input type="text" size="60" name="gasp_options[checkbox_name]" value="<?php echo $options['checkbox_name'];?>"/>
                        <p class="description"><?php _e('You can change this if you find that bots have started to target your blog again','ab_gasp');?></p>
                    </td>
                </tr>
                <tr valign="top"  class="alt menu_option postbox">
                    <td><?php _e('Secret Key','ab_gasp');?> <span style="position: relative; top: -0.5em; font-size: 80%; color: red;">updated</span></td>
                    <td><input type="checkbox" name="gasp_options[use_secret_key]" value="yes" <?php checked($options['use_secret_key'],'yes',true);?>/> <?php _e('Use secret key?','ab_gasp');?> <input type="text" size="60" name="gasp_options[secret_key]" value="<?php echo $options['secret_key'];?>"/>
                        <p class="description"><?php _e('this another bit of security to secure your comment form. You can change this to any value (letters and numbers only)','ab_gasp');?></p>
                    </td>
                </tr>
                <tr valign="top"  class="alt menu_option postbox">
                    <td><?php _e('Allow Trackbacks?','ab_gasp');?></td>
                    <td><input type="checkbox" name="gasp_options[trackbacks]" value="yes" <?php if(isset($options['trackbacks'])){checked($options['trackbacks'],'yes');}?>/>
                        (<?php _e('Unchecking the box will prevent ALL trackbacks', 'ab_gasp'); ?>) 
                        <br/><?php _e('See this plugin if you want a trackback validation plugin that works well with GASP','ab_gasp');?>
                        <a href="http://wordpress.org/extend/plugins/simple-trackback-validation/" target="_blank">Simple Trackback Validation</a>
                    </td>
                </tr>
                <tr><td colspan="2"><p><?php _e('These are the messages you will show the user if they forget to check the checkbox or if the comment looks like it was submitted by a spambot','ab_gasp');?></p></td></tr>
                <tr><td width="30%">
                        <?php _e('There is only 1 situation where this can happen','ab_gasp'); ?>
                        <ol>
                            <li><?php _e('The user forgot to check the checkbox','ab_gasp');?></li>
                        </ol>
                    </td>
                    <td><h2><?php _e('Checkbox not checked alert','ab_gasp');?></h2>
                        <input type="text" size = "95" name="gasp_options[checkbox_alert]" value="<?php echo $options['checkbox_alert'];?>" />
                    </td>
                </tr>
                <tr><td width="30%">
                        <?php _e('There is only 1 situation where this can happen','ab_gasp'); ?>
                        <ol>
                            <li><?php _e('The user does not have javascript enabled','ab_gasp');?></li>
                        </ol>
                    </td>
                    <td><h2><?php _e('No checkbox','ab_gasp');?></h2>
                        <textarea cols="60" rows="5" name="gasp_options[no_checkbox_message]" ><?php echo $options['no_checkbox_message'];?></textarea>
                    </td>
                </tr>
                <tr>
                    <td><?php _e('There is only one situation where this would happen','ab_gasp');?>
                        <ol>
                            <li><?php _e('The form has a hidden field added with a label that has a name value with the word "email" in it. A spam bot will usually try to fill in all fields on a form, if this field has been filled in then something is wrong','ab_gasp');?></li>
                        </ol>
                    </td>
                    <td><h2><?php _e('Hidden email field completed','ab_gasp');?></h2>
                        <textarea cols="60" rows="5" name="gasp_options[hidden_email_message]" ><?php echo $options['hidden_email_message'];?></textarea>
                    </td>
                </tr>
            </table>

            <?php // heuristics ?>
            <h2><?php _e('Heuristics (optional spam detection)','ab_gasp');?></h2>
            <p><?php _e('You can have more advanced spam detection by setting these options. Many thanks to @dragonblogger for these suggestions','ab_gasp');?></p>
            <table class="form-table postbox">
                <tr valign="top"  class="alt menu_option postbox">
                    <td width="30%"><?php _e('User refer check?','ab_gasp');?><span style="position: relative; top: -0.5em; font-size: 80%; color: red;">updated</span></td>
                    <td><select name="gasp_options[refer_check]">
                            <option value="yes" <?php selected($options['refer_check'],'yes');?>><?php _e('Yes','ab_gasp');?></option>
                            <option value="no" <?php selected($options['refer_check'],'no');?>><?php _e('No','ab_gasp');?></option>
                        </select>
                        (<?php _e('GASP will check if the page the comment was sent on matches the page the comment was for','ab_gasp');?>)
                    </td>
                </tr>  
                <tr valign="top"  class="alt menu_option postbox">
                    <td width="30%"><?php _e('Maximum comments in moderation?','ab_gasp');?><span style="position: relative; top: -0.5em; font-size: 80%; color: red;">new</span></td>
                    <td>
                        <select name="gasp_options[max_mod]">
                            <option value="disabled" <?php selected($options['max_mod'],'disabled');?>><?php _e('disabled','ab_gasp');?></option>
                            <?php
                            for($i = 1; $i<10 ; $i++){
                                echo '<option value="'.$i.'" '.selected($options['max_mod'],$i,false).'>'.$i.'</option>';
                            }
                            ?>
                        </select>
                        (<?php $desc = sprintf(__('A user can only submit comments if they have less than this number of comments to be moderated %s( for more control and to change the message, upgrade to CommentLuv Premium )%s','ab_gasp'),'<br/><a href="http://www.commentluv.com/?utm_source=settingspage&utm_medium=plugin&utm_term=gasp&utm_content=textlink&utm_campaign=freeplugin">','</a>'); 
                        echo $desc;
                        ?>)
                    </td>
                </tr> 
                <tr valign="top"  class="alt menu_option postbox">
                    <td width="30%"><?php _e('Maximum number of URLs allowed in comment text','ab_gasp');?></td>
                    <td><input type="text" size = "5" name="gasp_options[urls]" value="<?php echo $options['urls'];?>" />
                        (<?php _e('Use 0 (zero) to disable check', 'ab_gasp'); ?>) 
                    </td>
                </tr>
                <tr valign="top"  class="alt menu_option postbox">
                    <td width="30%"><?php _e('Maximum number of words allowed in name field','ab_gasp');?></td>
                    <td><input type="text" size = "5" name="gasp_options[name_words]" value="<?php echo $options['name_words'];?>" />
                        (<?php _e('Use 0 (zero) to disable check', 'ab_gasp'); ?>) 
                    </td>
                </tr>
                <tr valign="top"  class="alt menu_option postbox">
                    <td width="30%"><?php _e('Where to send suspicious comments?','ab_gasp');?></td>
                    <td>
                        <select name="gasp_options[send_to]">
                            <option value="spam" <?php selected($options['send_to'],'spam');?>><?php _e('spam','ab_gasp');?></option>
                            <option value="0" <?php selected($options['send_to'],'0');?>><?php _e('pending','ab_gasp');?></option>
                        </select>
                    </td>
                </tr>

            </table>
            <input type="hidden" name="action" value="update" />
            <input type="hidden" name="gasp_options[version]" value="<?php echo $options['version'];?>"/>
            <p class="submit">
                <input type="submit" class="button-primary" value="<?php _e('Save Changes') ?>" />
            </p>
        </form>
        <table class="form-table postbox"><tr><td><h2>Warning:</h2><?php _e('If you are using a cache plugin like WP Super Cache or W3 total cache you MUST clear your cache after installing the updated plugin and/or changing any settings on this page. If you do not delete your cache after upgrading or changing settings, your comment form will still be using the old values and your readers may not be able to leave comments until you clear/delete your cache. (ignore this message if you do not have a cache plugin installed)','ab_gasp');?></td></tr></table>
        <table class="form-table postbox">
        <tr class="alt"><td><h2><?php _e('Error Codes','ab_gasp');?>:</h2><?php _e('What the error codes on the error messages mean and what to do about them','ab_gasp');?></td></tr>
        <tr><td>nr01 : <?php echo __('No referrer sent with comment.','ab_gasp').'<p class="description">'.__('Sometimes peoples browsers do not send the referring page. This can appear to be bot behaviour. Advise the commenter to use another browser or switch off the refer check','ab_gasp');?></td></tr>
        <tr class="alt"><td>nr02 : <?php echo __('Referring domain does not match your domain.','ab_gasp').'<p class="description">'.__('The page that sent the comment was not from your site or was using a different domain name which appears to be bot behaviour','ab_gasp');?></td></tr>
        <tr><td>nc03 : <?php echo __('No checkbox value sent','ab_gasp').'<p class="description">'.__('The user did not check the checkbox or has disabled javascript or is using a bot','ab_gasp');?></td></tr>
        <tr class="alt"><td>he04 : <?php echo __('Hidden email field was submitted','ab_gasp').'<p class="description">'.__('A hidden field on the form was filled. Sometimes bots fill in all fields with the word "email" as the name. Bot behaviour','ab_gasp');?></td></tr>
        <tr><td>sk05 : <?php echo __('Secret Key value mismatch','ab_gasp').'<p class="description">'.__('The extra check using the secret key failed. This could be bot behaviour or the comment form is from a cached page which is out of date. Clear your cache if you have a cache plugin installed','ab_gasp');?></td></tr>
        <tr class="alt"><td>mc{x}mm0{x} : <?php echo '<p class="description">'.__('User tried to make a comment when they already had the maxiumum number of comments allowed in moderation. (where mc# is made comments and mm# is the maximum you have set)','ab_gasp');?></td></tr>
        </table>
        <br />
        <table class="form-table postbox">        
            <tr class="alt">
                <td valign="top" width="150px">
                    This plugin was made by Andy Bailey (<a href="http://twitter.com/commentluv">@commentluv</a>)
                    <br/><p style="float:left; margin: 5px 5px 5px 0px;"><?php echo get_avatar('admin@comluv.com',48);?></p>
                </td>
                <td>
                </td>
                <td valign="top" width="250px">
                    Some of my other plugins : 
                </td>
                <td>
                    <ul><li><a target="_blank" href="http://www.commentluv.com/?utm_source=gasp&utm_medium=settingspage&utm_campaign=freeplugin"><img title="Download CommentLuv Premium today!"src="<?php echo $gasp_plugin_url;?>/commentluv-plus-logo.png"/></a>
                            <br />A fantastically powerful new plugin that combines 8 premium plugins in to 1. It has advanced heuristics for anti spam (like this plugin but even more powerful!). It can help your posts go viral, allow dofollow, keywordname, twitterlink and much much more! <a href="http://www.commentluv.com" target="_blank">Click here to see the video</a></li>
                        <li><a href="http://wordpress.org/extend/plugins/twitterlink-comments/">TwitterLink Comments</a>
                            <br />Add an extra field to your comment form to allow your visitors to leave their twitter username and have it displayed along with their comment. All without having to edit your theme.</li>
                    </ul>
                </td>
            </tr>
            <tr>
                <td colspan="4">
                    <?php
                    //debugbreak();
                    include_once(ABSPATH.WPINC.'/feed.php');
                    $rss = fetch_feed('http://comluv.com/category/ads/feed/');
                    if(!is_wp_error($rss)) {
                        $maxitems = $rss->get_item_quantity(2);
                        $rssitems = $rss->get_items(0,$maxitems);
                    }
                    foreach($rssitems as $item){
                        echo '<div><a href="'.esc_url( $item->get_permalink() ).'">'.esc_html($item->get_title()).'</a>';
                        echo '<p>'.$item->get_content().'</p></div>';
                    }
                    ?>
                </td>
            </tr>
        </table>

    </div>
    <?php
}

/*********************************************
*		public output
*********************************************/

/** gasp_add_checkbox
* Called by comment_form action
* Adds javascript to create a checkbox on the comment form
*/
function gasp_add_checkbox(){
    global $gasped, $post;

    if(!is_user_logged_in() && !$gasped){
        //debugbreak();
        $options = gasp_get_options();
        $gasp_secret = md5($options['secret_key'].$post->ID);
        echo '<input type="hidden" name="'.$gasp_secret.'" value="'.$gasp_secret.'"/>';
        echo '<p id="gasp_p" style="clear:both;"></p>';
        echo '<script type="text/javascript">
        //v1.5.1
        var gasp_p = document.getElementById("gasp_p");
        var gasp_cb = document.createElement("input");
        var gasp_text = document.createTextNode(" '.$options['checkbox_label'].'");
        gasp_cb.type = "checkbox";
        gasp_cb.id = "'.$options['checkbox_name'].'";
        gasp_cb.name = "'.$options['checkbox_name'].'";

        var gasp_label = document.createElement("label");
        gasp_p.appendChild(gasp_label);
        gasp_label.appendChild(gasp_cb);
        gasp_label.appendChild(gasp_text);
        var frm = gasp_cb.form;
        frm.onsubmit = gasp_it;
        function gasp_it(){
        if(gasp_cb.checked != true){
        alert("'.$options['checkbox_alert'].'");
        return false;
        }
        return true;
        }
        </script>
        <noscript>you MUST enable javascript to be able to comment</noscript>
        <input type="hidden" id="gasp_email" name="gasp_email" value="" />';
        $gasped = true;
    } else {
        echo '<!-- no checkbox needed by Growmap Anti Spambot Plugin for logged on user -->';
    }
}
?>