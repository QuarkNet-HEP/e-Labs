=== Growmap Anti Spambot Plugin ===
Contributors: commentluv
Donate link:http://comluv.com/about/donate
Tags: comments, anti spam, spam, spambot, gasp
Requires at least: 2.9.2
Tested up to: 3.7
Stable tag: 1.5.4
	
Defeat automated spambots (even the new 'learning' bots with dynamically named hidden fields) by adding a client side generated checkbox.

== Description ==

[Upgrade to CommentLuv Pro For More Anti-Spam Heuristics](http://www.commentluv.com "Upgrade to CommentLuv Pro")

This plugin will add a client side generated checkbox to your comment form asking users to confirm that they are not a spammer.
It is a lot less trouble to click a box than it is to enter a captcha and because the box is genereated via client side javascript that bots cannot see, it should stop 99% of all automated spam bots.

A check is made that the checkbox has been checked before the comment is submitted so there's no chance that a comment will be lost if it's being submitted by legitimate human user.

To combat the new 'learning' bots, this plugin adds dynamically named fields to the comment form so each post has a differently named field and value.

You can set the maximum amount of comments a user can have in the moderation queue to protect you from comment floods (provided you haven't approved any of the spammers comments before)

*new! - prevent spambots from thinking they got links on your site by removing all links from comments that are waiting for moderation

You can get support and see this plugin in action at [Growmap](http://www.growmap.com/growmap-anti-spambot-plugin/ "Growmap Internet Strategist")

This is provided for free by [Andy Bailey](http://comluv.com "Andy Bailey @ ComLuv - The CommentLuv Network")

(please remember to delete your cache when you upgrade or change any settings if you are using a cache plugin)

[youtube http://www.youtube.com/watch?v=MVZ6pN8FFfw]

Translations : 

French : [Frederic](http://www.fredserva.fr "French Translation")

Spanish : [Ramon](http://apasionados.es/ "Spanish Translation")

== Installation ==

Wordpress : Extract the zip file and just drop the contents in the wp-content/plugins/ directory of your WordPress installation and then activate the Plugin from Plugins page.

WordpressMu : Same as above (do not place in mu-plugins)

== Frequently Asked Questions ==

= Does this plugin add any database tables? =

No. 

= Will this plugin work with Disqus/Intense Debate/js-kit? =

This will only work with the default Wordpress comments system.

= If I disable javascript will it still work? =

No. This plugin requires javascript to be enabled in the users browser for the comment to be accepted.

= The checkbox doesn't appear in my comment form =

The checkbox only appears for logged out users.
If you're logged out, it only shows if you have javascript enabled.
If you are logged out and have javascript enabled and it is still not showing then you need to have the comment form action active in your comments.php theme file
` do_action('comment_form',$post->ID); `

= I am allowing trackbacks but I am being trackback spammed! what do I do? =

You can download any of the number of trackback validation plugins which will check the trackback before allowing it or not.

= After having no spam I am now getting LOTS of spam, what do I do? =

Sometimes scripts can semi automate spam and they know what the checkbox name is so they can automatically tick it.
Change the `checkbox name` value in the settings page to something new (like change the number) so the autmoated systems don't know what the checkbox is called any more
You can also change the secret key value and set the maximum comments in moderation to a lower number.

= everyone is getting the error message = 

if you have a cache plugin, please clear all caches.

also, you can try saving the settings again to reset all the variables

== Screenshots ==

1. settings page

2. in use

3. error message

== ChangeLog ==

= 1.5.4 =

* added : remove all links from a comment if it is in moderation. (prevents autospam bots like scrapebox from thinking they got through with a link)
* updated : compatibility with 3.7

= 1.5.3 =

* updated : $count is checked if it has a value before checking if it is greater than max_mod to hopefully elimate the problem of random users being told they have too many comments in moderation

= 1.5.2 =

* updated : set checkbox as descendant of label so users can click the label to tick the box (thanks Anthony T)
* updated : added a link back to the post with a query arg to fix pages that were expired and had old form fields on the die message
* updated : change refer check logic
* updated : add error codes to error messages
* updated : allow user to not use secret_key (set as no by default)
* fixed : max_mod kept reverting back to 3 due to get_options not saving version number
* updated : added warning message about clearing the cache if a user upgrades or changes settings and has a cache plugin installed

= 1.5.1 =

* updated : set the max_mod value during install if it doesn't exist
* updated : new readme

= 1.5 =

* updated : max_mod is set at 3 by default
* updated : readme.txt updated

= 1.4.3 =
* updated : allow option of using referer check or not in settings
* updated : use dynamic input field name so each post uses a different value and can't be learned for the whole site
* added : allow user to set maximum comments that can be held in moderation before new comments can be added (from CommentLuv Premium)

= 1.4.2 =
* added : add a referer check to start of check_comment
* updated : notices about undefined index when debug turned on
* updated : check $_SERVER['HTTP_REFERER'] is set and die if not

= 1.4.1 =
* updated : improved code for checkbox and label to help with styling (thanks James)
* updated : regex for saving secret key
* added : keep a count of bots caught
* added : ad box below author info

= 1.4 =
* added : new extra security added with secret_key
* added : insert commentdata as spam before wp_die so spammer can't keep submitting the same comment with new key try
* fixed : bug with gasp_check declaration using == instead of =
* added : keep a track of bot comments and show count in settings page (only bot comments, not forgotten checkboxes)

= 1.3 =
* fixed : prevent two checkboxes being rendered on some themes (nexus)

= 1.2 =
* allow blogger to change checkbox name in settings

= 0.1 =
* First version , commissioned by @phollows via @growmap

= 0.2 =
* tidied up options page and added field for checkbox label

= 0.3 =
* changed the hidden div with text type input to hidden input to prevent google toolbar from filling in the text field

= 0.4 =
* added client side alert if checkbox is not checked. @donnafontenot http://bit.ly/9Uqfxz

= 1.0 =
* release version

= 1.01 =
* use different method to identify submitted form for forms that have a submit button with no id or name set (@dragonblogger)

= 1.02 =
* ignore trackbacks and pingbacks (@basicblogtips)

= 1.03 =
* let blog owner to choose to allow trackbacks or not (@dragonblogger)

= 1.1 =
* add ability to specify maximum number of names or urls in content of comment. (@dragonblogger)
* choose where to send comment


== Upgrade Notice ==

= 1.5.4 =

* added - prevent autospam bots from thinking they got through by removing all links from a moderated comment until it is approved

== Configuration ==

* You only need to specify which error messages to show when the user forgets to use the checkbox or no checkbox is present.
