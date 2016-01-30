<?php

define( 'FORCE_SSL_LOGIN', true );
define( 'FORCE_SSL_ADMIN', true );
/**
* The base configurations of the WordPress.
*
* This file has the following configurations: MySQL settings, Table Prefix,
* Secret Keys, WordPress Language, and ABSPATH. You can find more information
* by visiting {@link http://codex.wordpress.org/Editing_wp-config.php Editing
* wp-config.php} Codex page. You can get the MySQL settings from your web host.
*
* This file is used by the wp-config.php creation script during the
* installation. You don't have to use the web site, you can just copy this file
* to "wp-config.php" and fill in the values.
*
* @package WordPress
*/

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
//define('WP_CACHE', true); //Added by WP-Cache Manager
define('DB_NAME', 'wordpress');

/** MySQL database username */
define('DB_USER', 'wordpress');

/** MySQL database password */
define('DB_PASSWORD', '2Njm2LVfs6CWgpVP');

/** MySQL hostname */
define('DB_HOST', 'data1.i2u2.org');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
* Authentication Unique Keys and Salts.
*
* Change these to different unique phrases!
* You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
* You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
*
* @since 2.6.0
*/
define('AUTH_KEY',         '9PF3l;fZt*pl -:WgaT2Bs(cwJ|d) ^$-7{8332LCJmw<_?:T8>:Jg~evB0+k+<3');
define('SECURE_AUTH_KEY',  'k~#LL}Lshd>)@+,3dq{3$xT>V`H0eCKn{H/8V+hex]=bri&;iH:h::[=}-Sddw++');
define('LOGGED_IN_KEY',    'x{iBCa<2q;Vg9GMN+;xFqn5(i(r|2?<+Hql;a,DbiiKw9c-ej<e1n,hI[L t9PY^');
define('NONCE_KEY',        '3h}aKuvMxBW@u-=R 0+g6+.3?rh7ojK._aT|SPB*7UJ5-(k%%}j-zLTS`<`(.WmA');
define('AUTH_SALT',        'M2G~<2:OhUthcVY/9-0,U+y:EY(LId[7O7[r|1-?0BNvk?}+{>Mo-yMdy+0Qb%+g');
define('SECURE_AUTH_SALT', 'oA%-v.qNrb :&lLRL0~&p/E2SYFYcaI/37>HeJd%2+9Ud_}ZAd#U27?/}<.q}rz3');
define('LOGGED_IN_SALT',   ',RZOFA3uYHpE|)x*6{(u~fer~^&nOzp!PfG(H}]uJfdf{afb!k]ZU#/q;#>?D3^`');
define('NONCE_SALT',       'R=KHj]Mmv|Wiu#k^#GC+Emr9|z!%yB^v=4|`_:Hot:cvg7lVS++j$%+b0/O,:{ea');

/**#@-*/

/**
* WordPress Database Table prefix.
*
* You can have multiple installations in one database if you give each a unique
* prefix. Only numbers, letters, and underscores please!
*/
$table_prefix  = 'wp_';

/**
* WordPress Localized Language, defaults to English.
*
* Change this to localize WordPress. A corresponding MO file for the chosen
* language must be installed to wp-content/languages. For example, install
* de_DE.mo to wp-content/languages and set WPLANG to 'de_DE' to enable German
* language support.
*/
define('WPLANG', '');

/**
* For developers: WordPress debugging mode.
*
* Change this to true to enable the display of notices during development.
* It is strongly recommended that plugin and theme developers use WP_DEBUG
* in their development environments.
*/
define('WP_DEBUG', false);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
