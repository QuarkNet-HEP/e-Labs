<?

# Skin-by-URL 2 -- a MediaWiki extension for setting page skin via alternate URL
# Copyright (C) 2010 - Glen E. Ivey
#     http://github.com/gleneivey/skin-by-url-2
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License version
# 3 as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program in the file COPYING and/or LICENSE.  If not,
# see <http://www.gnu.org/licenses/>.


$wgExtensionCredits['other'][] = array(
  'name' => 'Skin-by-URL 2',
  'author' => 'Glen E. Ivey',
  'url' => 'http://github.com/gleneivey/skin-by-url-2',
  'version' => '0.1',
  'description' => "Force page's skin by altering page's URL.  " .
    "Replace 'index.php' with 'askin.php' to force any page to " .
    "display with 'askin'."
);



# this extension's initialization; use a function for local variable scope
$wg_SBU2_skinNameFromUrl = '';
function wf_SBU2_checkUrlAndConfigure(){
  global $wg_SBU2_skinNameFromUrl;
  global $wgScriptExtension;
  global $wgHooks;
  global $wgUsePathInfo;

  if ( preg_match( "/\/([^\/]+)\\" . $wgScriptExtension . "/",
                   $_SERVER['PHP_SELF'],
                   $substrings )                     ){
    $wg_SBU2_skinNameFromUrl = $substrings[1];
    if ( $wg_SBU2_skinNameFromUrl != "index" ){
      $wgHooks['OutputPageParserOutput'][] = 'wf_SBU2_oppoCallback';
      $wgHooks['GetLocalURL'][]            = 'wf_SBU2_gluCallback';
      $wgUsePathInfo = false;
    }
  }
}

# actually do extension initialization
wf_SBU2_checkUrlAndConfigure();



# for hook OutputPageParseOutput; our moment to change the skin to be used
function wf_SBU2_oppoCallback( &$out, $parseroutput ){
  global $wg_SBU2_skinNameFromUrl;
  global $wgValidSkinNames;
  global $wgDefaultSkin;
  global $wgUser;

  if ( array_key_exists( $wg_SBU2_skinNameFromUrl,
                         $wgValidSkinNames )                 ){
    $wgDefaultSkin = $wg_SBU2_skinNameFromUrl;
    $wgUser->setOption( 'skin', $wg_SBU2_skinNameFromUrl );
  }

  return true;
}


# for hook GetLocalURL; maybe replace "index.php" with skin-specifying string
function wf_SBU2_gluCallback( $title, $url, $query ){
  global $wg_SBU2_skinNameFromUrl;
  global $wgScriptPath;
  global $wgScriptExtension;

  if ( preg_match( "/action=/",     $query ) == 0 ||
       preg_match( "/action=view/", $query ) == 1    ){

    $indexRe = "/\/index\\" . $wgScriptExtension . "/";
    if ( preg_match( $indexRe, $url ) )
      $url = preg_replace( $indexRe,
                           "/" . $wg_SBU2_skinNameFromUrl . $wgScriptExtension,
                           $url );
    else if ( preg_match( "/\/[a-z0-9]+\\" . $wgScriptExtension . "/",
                          $url ) == 0 ){
      $withoutSlash = substr( $url, 1 );
      $url = "{$wgScriptPath}/{$wg_SBU2_skinNameFromUrl}{$wgScriptExtension}" .
               "?title={$withoutSlash}";
    }
  }

  return true;
}
