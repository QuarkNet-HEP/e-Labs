<?php
require_once('../inc/db.inc');
require_once('../inc/util.inc');
require_once('../inc/countries.inc');
require_once('../inc/translation.inc');

// Web-based interface for account creation.
// This isn't needed for people who use the version 5 Manager's
// "attach project wizard".
// But (for the time being at least)
// it's needed for pre-version 5 clients,
// and clients that don't use the account manager

db_init();
page_head(tr(CREATE_AC_TITLE));

$config = get_config();
if (parse_bool($config, "disable_account_creation")) {
    echo "
        <h1>".tr(CREATE_AC_DISABLED)."</h1>
        <p>".tr(CREATE_AC_DISABLED_TEXT)."
        </p>
    ";
    page_tail();
    exit();
}
echo "<p>
    <b>".tr(CREATE_AC_USE_CLIENT)."</b>
";
echo "
    <p>
    <form action='create_account_action.php' method='POST'>
";
$teamid = get_int("teamid", true);
if ($teamid) {
    $team = lookup_team($teamid);
    $user = lookup_user_id($team->userid);
    if (!$user) {
        echo "No such user";
    } else {
        echo "<b>";
        printf(tr(CREATE_AC_TEAM), "<a href=\"team_display.php?teamid=$team->id\">$team->name</a>");
        echo "</b> <p> ";
        echo "
            <input type=hidden name=teamid value=$teamid>
        ";
    }
}
start_table();

// Using invitation codes to restrict access?
//
if(defined('INVITE_CODES')) {
    row2("<b>".
         tr(AC_INVITE_CODE)."<br><span class=description>".
         tr(AC_INVITE_CODE_DESC)."</span",
         "<input name=invite_code size=30>"
     );
} 

row2("<b>".
     tr(CREATE_AC_NAME)."</b><br><span class=description>".
     tr(CREATE_AC_NAME_DESC)."</span>",
    "<input name=new_name size=30>"
);
row2("<b>".
     tr(CREATE_AC_EMAIL)."</b><br><span class=description>".
     tr(CREATE_AC_EMAIL_DESC)."</span>",
    "<input name=new_email_addr size=50>"
);
$min_passwd_length = parse_element($config, "<min_passwd_length>");
if (!$min_passwd_length) {
    $min_passwd_length = 6;
}

row2("<b>Password</b><br><span class=description>"
    .sprintf(tr(CREATE_AC_PASSWORD_DESC), $min_passwd_length)
    ." </span>",
    "<input type=password name=passwd>"
     );

row2("<b>Confirm password</b><br><span class=description>
        to be sure we get it right</span>", "<input type=password name=passwd2>");




// Country (this is actually State for I2U2) 

row2_init("<b>".
          tr(CREATE_AC_COUNTRY)."</b><br><span class=description>\n".
          tr(CREATE_AC_COUNTRY_DESC)."</span>",
          "<select name=country>"
          );
print_country_select();
echo "</select></td></tr>\n";


row2("<b>".tr(CREATE_AC_AFFILIATION)."</b><br> <span class=description>\n".
      tr(CREATE_AC_AFFILIATION_DESC)."</span>",
      team_select() );


row2("<b>".
     tr(CREATE_AC_ZIP)."</b><br><span class=description>".
     tr(OPTIONAL).".</span>",
     "<input name=postal_code size=20>"
     );

row2("",
    "<input type=submit value='".tr(CREATE_AC_CREATE)."'>"
     );

end_table();

echo "<P>
        Once your account has been created you can create and edit your
        own personal profile,
        and you can add a \"head shot\" image for the discussion forums.
        </P>\n";

echo "
    </form>
";

page_tail();
?>

