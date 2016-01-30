=== Social Login & Social Sharing by Janrain ===
Contributors: byron-janrain, rebekahgolden, kylerohr
Donate link: http://www.janrain.com/products/engage/
Tags: rpx, janrain, engage, janrain engage, authentication, facebook, facebook connect, facebookconnect, openid, twitter, google, yahoo, api, oauth, myspace, linkedin, windows live, login, registration, register, social api, social apis, widget, community, sharing, share, publish, publishing, share button, share widget, social widget, tweet, status update, news feed, newsfeed, social login, social sharing, social sign-on, social sign-in
Requires at least: 3.5
Tested up to: 3.6.1
Stable tag: 1.1.2
License: GPLv2

Social Login & Social Sharing by Janrain

== Description ==
[Janrain social
login](http://janrain.com/products/engage/social-login/) increases site
registrations and generates referral traffic to your site by allowing
users to easily register and login via an existing social network or
email ID. [Janrain social
sharing](http://janrain.com/products/engage/social-sharing/) allows
users to publish their comments or activities from your site to multiple
social networks simultaneously.

#### Social Login:

Give your visitors the option to sign-in to your site with their
existing social network such as Facebook, Google, Twitter, Yahoo!,
LinkedIn, Windows Live, MySpace, AOL and others ([20+ Supported
Networks](https://rpxnow.com/docs/providers)).

#### Social Login Display Options:

1.  Social login buttons for standard WordPress registration screen
2.  Social login buttons for comments
3.  Social login buttons within Widgets
4.  Show social provider photo as avatar
5.  Shortcodes for customized integrations.
6.  Provider selection viewable by admin in user list.

#### Collects Email Address:

Prompts users to enter an email address if the provider used for login
does not pass a verified email address (WordPress Requirement). Expert
option to collect placeholder emails to bypass this.

#### Legacy Account Mapping:

If your user has an existing account with your site, Janrain Engage will
map profile data received at login with the existing account (via
verfiedEmail only).

#### Social Sharing:

A customizable widget for your users to share your articles to multiple
social networks simultaneously. Users can select up to four social
communities such as Facebook, Twitter, LinkedIn and Yahoo for sharing.
On average this will generate 13 referral clicks back to your site for
each article that is shared.

#### Social Sharing Display Options

7.  Social share buttons at beginning or end of posts
8.  Social share buttons on each comment
9.  Share button customization

#### Social Provider Comment Icons:

Each comment from a user signed in through a social provider gets an
icon to the provider that links to their profile page for that provider.

#### Connect a provider to an existing account:

Users can connect a provider to their account through the profile page
or the widget. They can also change the provider in the profile page.

#### Automatic user registration:

Register new users automatically when they want to share something from
your site. This optional feature lowers the barrier for new user
registration.

#### More Information:

1.  [Social Login & Social Sharing Plugin - Demo
    Site](http://www.google.com/url?q=http%3A%2F%2Fplugins.janrain.com%2Fwordpress%2F&sa=D&sntz=1&usg=AFQjCNGFBiEkDUTPQV-WHY3Y2Y0kBvhy0Q)
2.  [Social Login & Social Sharing Plugin - Basic Setup
    Video](http://www.youtube.com/watch?v=Qz79cZyBhIE)
3.  [Social Login & Social Sharing Plugin -
    Support](http://www.google.com/url?q=https%3A%2F%2Fsupport.janrain.com%2F&sa=D&sntz=1&usg=AFQjCNFn5cOd7i2v7f9isqKk4SwzFL-QpQ) (Login
    Required)
4.  [Get a Janrain
    Account](http://www.janrain.com/products/engage/get-janrain-engage)
5.  [Learn More About Janrain - Video
    Demo](http://www.janrain.com/products/engage/video)
6.  [Janrain Website](http://www.janrain.com/)

Follow us on [Twitter](http://twitter.com/janrain) and on
[Facebook](http://janrain.com/facebook) to keep up with the latest
updates.

== Installation ==

Requires PHP 5.2 (with JSON) or newer and Wordpress 3.1
(The plugin is all new please test it before deployment on a live site.)

1. Copy the 'rpx' directory and its contents to your `/wp-content/plugins/` directory or use the plugin installed built in to Wordpress.

2. Activate the Janrain Engage plugin through the 'Plugins' menu in WordPress

3. You will need to allow user registrations. Go to General Settings and
turn on "Membership, Anyone can register."

4. Visit the Janrain Engage configuration page by going to 'Settings' ->
'Janrain Engage' and follow the instructions to finish your installation.
If you don't already have an Engage account and API key, you may click
[Get a Janrain Engage Account Now](http://www.janrain.com/products/engage/get-janrain-engage "Get a Janrain Engage Account Now") to sign up.
If you have already created an Engage account and site for your
WordPress blog, just enter your API Key into the box and click "Save."

5. Due to the new email address requirements in Wordpress 3 users will be
prompted for an email address if the provider does not deliver one.
If the provider settings does not show email as a profile option
the plugin will require the user to enter an email address.

== Frequently Asked Questions ==

= How do I enable Facebook, Twitter, MySpace, and Live ID authentication? =

Go to http://www.janrain.com/login and sign-in. Click the
"Provider Configuration
 link on your application dashboard and toggle between
each provider on the right side panel.  Click the blue "Configure" button for
instructions to enable each provider.  All four require you to obtain an API key and
secret for your individual site, and approve their developer terms of service.

= Help! The plugin doesn't work =

The plugin is currently only tested with Twenty Ten theme and a few other themes.
You may have problems with another theme please test it before deployment.

Please test it before deployment on a live site.

Note: Using the most current version of PHP (and JSON) and WordPress (with a current theme)
will fix many problems, so please make sure you are up to date.

Vist https://support.janrain.com/ to search for solutions. There is a Wordpress plugin
specific discussion at [Janrain Engage Plugin - Support](https://support.janrain.com/ "Support")(Login Required)

== Changelog ==

v1.1.0 p1

= Version 1.0 =
*  This is an all new plugin that replaces all previous versions for users of Wordpress 3.

= Version 1.0.0a =
*  First round of bug fixes for 1.0.1

= Version 1.0.0b =
*  Adds IE7 support
*  Added configuration for comment action hook
*  Improved performance, faster page loads
*  Improved widget/theme compatibility
*  Improved Share button design
*  Improved admin settings screen
*  Fixed redirect to permalink (removed)

= Version 1.0.1a =
*  Just an experimental relase for WPMS

= Version 1.0.1b =
*  WPMS that works in at least one config type
*  Output buffering with error detection
*  Fixed bug that blocked admin panel if cURL detect failed
*  Independent email address collection UI
*  Link for admin cleanup on old incomplete accounts(experimental)

= Version 1.0.1 =
*  WPMS support (beta)
*  Social sharing for comments with option in admin screen.
*  Provider icons for comments.
*  Fixed defect where profile was not being updated when user switched providers.
*  Cleaned up admin screen.
*  Icons on wp-login.php are sprites.

= Version 1.0.2 =
* BuddyPress support (beta, requires automatic registration to be disabled)
* Existing users can add a provider or change the provider.
* Eliminated dependency on wp-login.php
* Eliminated last cURL dependency.
* Completed provider icon comment feature.
* Errors display in a light-box style.

= Version 1.0.3 =
* Adds ability to pull provider list to set icons to match enabled providers.
* Added instruction for token URL "whitelist" for admin panel.
* Corrected URL and wording in admin panel.
* Other minor bug fixes.

= Version 1.0.4 =
* CSS and JS system reworked to enable server side caches and improve page loads.
* Various minor fixes.

= Version 1.0.5 =
* More CSS fixes and it's now tested against multiple templates.
* Added the new Engage providers and improved icon art.
* Wordpress 3.1.3 tested and supported.
* Now has it's own settings category.
* Built in help!
* Interface to edit common strings for localization or customization.
* Share button preferences and new look.
* Improved compatability with other WP plugins.
* Shortcodes added for custom template integration.

= Version 1.0.6 =
* Sign on provider list updates on every save of the settings.
* Optional feature to allow users to disconnect the social account.
* Increased FB share summary text size to 128 characters.
* Option to require automatically registered users to select username. (Related: Expert EULA feature.)
* Moved all rpx.conf.php options into the UI as Expert Settings.
* Some bugs where fixed.
* Tested to 3.1.4

= Version 1.0.7 =
* New share button look.
* Share button can show share counts.
* Tested for 3.2.0

= Version 1.0.8 =
* New data mode expert option.
* Multiple new setup options.
* Tested for 3.2.1

= Version 1.0.9 =
* New shortcodes.
* Updated to current widget.
* Tested for 3.3.0

= Version 1.1.0 =
* New share widget.
* Register via share.
* Login via share.
* Register without collecting email.
* Cleaned up admin settings page style.

== Upgrade Notice ==

Version 1.1.0 adds our new share widget.

= Version 1.1.2 =
* Fixed: Widgets now load from the correct urls.
* Improved: You can now use the Engage widget on sites served from ports other than 80.
* Improved: Compatible with Wordpress 3.6.1.
* Fixed: Users can now change their display names when duplicate users are found.
* Fixed: Engage now passes the user to do_action to work with other listeners of login events.

== Screenshots ==

1. The Janrain Engage sign-in widget.  You can fully customize which identity providers to support, and the order in which they appear on the widget.
2. Example of the return user sign-in experience with Janrain Engage.  Janrain Engage remembers the user's preferred network.
3. Comments enabled through Janrain Engage.  Clicking on the icons in the comments section allows users to sign-in via the Janrain Engage interface.
4. The login icons can be configured to show up even if anonymous commenting is enabled.
5. The Janrain Engage button on the login page.
6. The Janrain Engage log in widget.
7. The social share link for articles.
8. The social share link on comments, and provider icons for commenters.
9. The social sharing widget.
10. Targeted sharing.
