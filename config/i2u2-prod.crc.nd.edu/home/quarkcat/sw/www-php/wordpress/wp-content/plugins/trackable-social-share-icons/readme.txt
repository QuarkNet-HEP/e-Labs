=== Trackable Social Share Icons ===
Contributors: EcreativeIM, mikestowe
Tags: social media, sharing, trackable, google analytics, facebook, twitter, social, social bookmarking, email, reddit, del.icio.us, digg, stats, statistics, share, sharing, tracking, analytics, snail mail, google plus, pinterest
Requires at least: 2.9
Tested up to: 3.3.1

The Trackable Social Share Icons plugin enables blog readers to easily share posts via social media networks, including Facebook and Twitter. All share clicks are automatically tracked in your Google Analytics.


== Description ==

Increase the reach of your blog with social network sharing, and track the number of share clicks in Google Analytics.

Trackable Social Share Icons plugin is a simple, intuitive, and customizable plugin that places social media icons, such as Twitter and Facebook, at the bottom of Wordpress posts and pages. Users can click on the icon to share the blog post over social networks without ever leaving the page.

All clicks on the social icons are automatically tracked in your Google Analytics, under Event Tracking. Tracking data is not shared with us or any 3rd party – only someone with access to your Google Analytics will see it in any form.

= Key Features =
* Integrates with Google Analytics
* Choose where and how icons display
* 12 sets to choose from, or upload your own
* Trackable Facebook "Like" button
* Add custom button links to other services
* Built in CSS editor for even more customization


== Customization Options ==

Trackable Social Share Icons lets you select which social media icons appear (including Facebook, Twitter, LinkedIn, Digg, Reddit, StumbleUpon, Tumblr, Posterous, and Email), choose from a dozen different icon appearances - or upload your own, customize the size of the icons, whether or not to use text along side the icons, and lets you turn the Google Analytics tracking on and off.


== Tracking ==

If you have tracking turned on in the admin, all clicks on your social icons will automatically be tracked in Google Analytics – there is nothing to set up. Social icon clicks will appear in Google Analytics under Content > Event Tracking in a category called SocialSharing. It will break out which buttons were clicked, and let you drill down to see which pages the clicks came from. Note that tracking only works with the new asynchronous analytics code (not the old urchin code).

Trackable Social Share Icons will work even without Google Analytics on your site – though obviously you won’t be able to track the clicks without analytics.


== Installation ==

1. Upload `trackable-social-share-icons` to the `/wp-content/plugins/` directory
1. Activate the plugin through the 'Plugins' menu in WordPress
1. Click on `Trackable Sharing` under `Plugins` to customize


== Frequently Asked Questions ==

View our full FAQ at http://www.ecreativeim.com/trackable-social-share-icons-faq


== Screenshots ==

1. Example configurations of Share Icons and Options
2. Decide what buttons to display, how to display them, and where to display them
3. Choose from 12 different icon sets or create your own
4. Add text before and after buttons, add the Facebook Like button, manage Google Analytic tracking, and more
5. Hide buttons from individual posts and pages that you don't want to be shared


== Changelog ==

= 1.3 =
* Added Pinterest
* Google+ is now either inline with the custom buttons, or below the buttons similar to the facebook section
* Fixed the Tumblr share option
* Cleaned up some unnecessary files
* Reverted change of footer link behavior, it is now deactivated by default. Thanks for your support if you decide to turn it on!

= 1.2 =
* Added security fix regarding permissions
* Minor text fixes

= 1.1 =
* Added Google +1 buttons with ability to either have balloon, inline, or no annotations
* Added ability to change Show Support text and link color

= 1.0 =
* Added ability to hide buttons on Home Page
* Added ability to hide buttons on Category/Archive Pages
* Added ability to hide buttons on individual posts and pages
* Added ability to add text before the buttons (eg: Share this)
* Added trackable Facebook "like" button with optional "faces" and "send"
* Fixed window focus issue
* Enhanced Snail Mail window

= 0.9 =
* Added delicous
* Added snail mail
* Added Trackable Social Share Icons widget
* Added `[trackable_share]` tag for greater post/page control
* Added call function `_trackableshare_embed()` for use in templates
* Added ability to upload custom button images
* Added ability to add custom share links (advanced)
* Fixed link bug on image pages

= 0.8 =
* Added ability to display icons on top, bottom, or both
* Added ability to choose whether to display on posts, pages, both, or neither
* Added CSS block to further customize the look and feel of the icons and how they display on the page
* Noscript Support - windows will still popup if JavaScript is not supported or if there is a Javascript error (eg. enabling Google Analytic Tracking without the latest code)
* Updated path to work if `trackable-social-share-icons` folder name is changed
* Updated path to work if `wp-content` or `plugins` folder names are changed in WordPress
* Added LinkedIn, Tumblr, Posterous, and Email icons to the `Location` set
* Added LinkedIn, Tumblr, Posterous, and Email icons to the `Handy Icons` set

= 0.7 =
* Path Fix - fixes broken images in front end and back end

= 0.6 =
* Image Fix - in the .5 release some downloads may not have contained the images.  The updated version fixes this issue.

= 0.5 =
* Public Release


== Privacy Information ==

Ecreative IM does not gather any information about user shares, nor is any information shared with any third party. All click data is accessible only by someone with access to your Google Analytics.


== Stats and Analytics ==

Tracking only works with the newer, asynchronous analytics code (though the rest of the plugin will work fine even without it). The asynchronous analytics code appears in the header of your site code, whereas the old urchin analytics appears in the footer. You can get Google Analytics or upgrade to the new version at any time for free.

See our FAQ for more info.

Trackable Social Share Icons data appears in Google Analytics under the Content > Event Tracking section. See Screenshots for more.

== Known Issues ==

There is an issue where images images do not display properly in IIS while using HTTPS.

Currently Google does not offer a manner in which to share URIs with custom buttons or links. As of 9-6-11 they only offer their Javascript +1 button solution. When they update this with the ability to share websites through custom links we will update the plugin with buttons that match the sets of other buttons.