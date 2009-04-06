<?php

require_once("../inc/forum.inc");
require_once("../inc/text_transform.inc");
require_once("../inc/profile.inc");
require_once("../inc/util_ops.inc");

db_init();

function buttons($i) {
    echo "
        <input type='radio' name='user$i' value='0'>&nbsp;skip <br>
        <input type='radio' name='user$i' value='1' checked=\"checked\">&nbsp;accept <br>
        <input type='radio' name='user$i' value='-1'>&nbsp;reject
    ";
}

admin_page_head("screen profiles");

$result = mysql_query("select * from profile, user where profile.userid=user.id and (has_picture>0) and (verification=0) order by recommend desc limit 20");

$n = 0;
echo "<form method=\"get\" action=\"profile_screen_action.php\">\n";
start_table();
$found = false;
while ($profile = mysql_fetch_object($result)) {
    $found = true;
    echo "<tr><td VALIGN=TOP WIDTH=120>\n";
    echo "
	Recommends:&nbsp;$profile->recommend
        <br>
	Rejects:&nbsp;$profile->reject
	<p>&nbsp;<p>
    ";
    buttons($n);

    echo "\n</td><td>
          <h2>".$profile->name. "</h2>
       ";

    show_profile($profile->userid, true);
    echo "</td></tr>\n";
    echo "<input type=\"hidden\" name=\"userid$n\" value=\"$profile->userid\">\n";
    $n++;
}

end_table();

if ($found) {
    echo "
        <input type=\"hidden\" name=\"n\" value=\"$n\">
        <input type=\"submit\" value=\"OK\">
    ";
} else {
    echo "No more profiles to screen.";
}

echo "
    </form>
";

admin_page_tail();

//Generated automatically - do not edit
$cvs_version_tracker[]="\$Id: profile_screen_form.php,v 1.3 2006/12/14 18:31:35 myers Exp $";  
?>
