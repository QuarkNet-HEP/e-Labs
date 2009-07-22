<?php
/***********************************************************************\
 * Project specific functions for LIGO e-Lab
 *
 *
 * @(#) $Id: ligo-stuff.php,v 1.1 2009/05/12 15:34:33 myers Exp $
\**********************************************************************/


function ligo_masthead($title='',$right_stuff='&nbsp;'){
    echo "\n<!-- LIGO e-lab masthead -->
     <table class='masthead,noborder' width=100% bgcolor='black' ><tr>
       <td class='noborder' width=15% valign='top' align=left>
              <a href='/' >
               <img src='/img/ligo_logo.gif' border='0'
                   valign='top' align='left' alt='[LIGO logo]' 
                   title='return to the top level'></a>
       </TD>";

    echo "
       <TD class='noborder' width='60%' align='LEFT' >
	<div class='header-title'>
		LIGO e-Lab
	</div>
	<div class='header-subtitle'>
	    $title
        </div>

       </TD>\n ";

    echo "
       <TD class='noborder' width='25%' valign='TOP' align='RIGHT'>\n";
       if( isset($hide_user) && $hide_user ) {   // don't show user/login or cache indicator
	 echo "&nbsp;";
       }
       else {      
        // need to see if the person is authenticated, cookie or not
        $authenticator = init_session();
        echo "<font size='1' color='white'>";
        $logged_in_user = get_logged_in_user(false);
        show_login_name($logged_in_user);
        echo "</font>\n";
    }
    echo "\n</TD></TR>\n ";

    echo "<TR ><TD class='noborder' colspan='3'>
        <div class='third-header-title'>
          &nbsp; Laser Interferometer Gravitational-Wave Observatory
        </div>
	</TD></TR>\n";

    echo "</TABLE>";
    echo "\n<!-- END Tool Masthead -->\n";

    //project_menu_bar();
     LIGO_menu_bar();
}

function LIGO_menu_bar(){
  //TODO: detect teacher -vs- student URL and change accordingly
  return cosmic_teacher_menu_bar();
}


function LIGO_teacher_menu_bar(){
    $x = "
    <!-- Teacher's menu bar for Cosmic Ray e-Lab -->
    <TABLE class='menu_bar'><TR>
      <TD>&nbsp;</TD>
      <TD><a href='/elab/ligo/teacher/'>
            Teacher Home</a>
      </td>";

    $x .= "
      <TD><a href='/elab/ligo/teacher/community.jsp'>
            Community</a>
      </td>";

    $x .= "
      <TD><a href='/elab/ligo/teacher/standards.jsp'>
            Standards</a>
      </td>";

    $x .= "
      <TD><a href='/elab/ligo/teacher/site-map.jsp'>
            Site Index</a>
      </td>";

    $x .= "
      <TD><a href='/elab/ligo/teacher/registration.jsp'>
            Registration</a>
      </td>";

    $x .= "
      <TD><a href='/elab/ligo/home/'>
            Student Home</a>
      </td>";

    $x .= "\n    </TR>
    </TABLE><!-- END menu bar -->\n";

    return $x;
}

?>
