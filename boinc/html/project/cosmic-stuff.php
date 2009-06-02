<?php
/***********************************************************************\
 * Project specific functions for Cosmic Ray e-Lab
 *
 *
 * @(#) $Id: cosmic-stuff.php,v 1.4 2009/05/28 21:36:50 myers Exp $
\**********************************************************************/


function cosmic_masthead($title='',$right_stuff='&nbsp;'){
  echo "\n<!-- BEGIN Cosmic Ray e-lab masthead -->\n<div class='top'>\n";
  echo cosmic_banner($title,$right_stuff);
  echo cosmic_teacher_menu_bar();
  echo "\n</div><!-- END e-lab masthead -->\n";
}


function cosmic_banner($title='',$right_stuff='&nbsp;'){// returns $x
  // TODO: make this smarter - teacher or student?
  $home_link="/elab/cosmic/teacher/";
  $elab_logo="/elab/cosmic/graphics/blast.jpg";

  $x = "<TABLE class='masthead' width='100%' bgcolor='black' ><tr>
       <TD class='noborder' width='15%' valign='TOP' align='CENTER'>
              <a href='$home_link' >
	      <img src='$elab_logo'
                   title='return to the e-Lab home'
                   alt='' /></a>
       </td>
       <TD class='noborder' width='60%' align='LEFT' >
	<div class='header-title'>
		Cosmic Ray e-Lab
	</div>
       </td>\n ";
   $x .= "
       <TD class='noborder' width='25%' valign='TOP' align='RIGHT'>\n";

       if( isset($hide_user) && $hide_user ) {   // don't show user/login or cache indicator
	 $x .= "&nbsp;";
       }
       else {      
        // need to see if the person is authenticated, cookie or not
        $authenticator = init_session();
        $x .= "<font size='1' color='white'>";
        $logged_in_user = get_logged_in_user(false);
        $x .= show_login_name($logged_in_user);
        $x .=  "</font>\n";
    }
    $x .=  "\n</TD></TR>\n";
    $x .=  "</TABLE>";
    return $x;
}


function cosmic_teacher_menu_bar(){
    $x = "
    <!-- Teacher's menu bar for Cosmic Ray e-Lab -->
    <TABLE class='menu_bar'><TR>
      <TD>&nbsp;</TD>
      <TD><a href='/elab/cosmic/teacher/'>
            Teacher Home</a>
      </td>";

    $x .= "
      <TD><a href='/elab/cosmic/teacher/community.jsp'>
            Community</a>
      </td>";

    $x .= "
      <TD><a href='/elab/cosmic/teacher/standards.jsp'>
            Standards</a>
      </td>";

    $x .= "
      <TD><a href='/elab/cosmic/teacher/site-map.jsp'>
            Site Index</a>
      </td>";

    $x .= "
      <TD><a href='/elab/cosmic/teacher/registration.jsp'>
            Registration</a>
      </td>";

    $x .= "
      <TD><a href='/elab/cosmic/home/'>
            Student Home</a>
      </td>";

    $x .= "\n    </TR>
    </TABLE><!-- END menu bar -->\n";

    return $x;
}


// Previous Attempt... 

function old_cosmic_masthead($title=''){
  echo "
	<TABLE width=100% border=0><TR>\n";
 
  echo "<TD id='header-image'>
	<img src='/elab/cosmic/graphics/blast.jpg' alt='Cosmic Ray Blast' />
	</TD>\n";
 
  echo "<TD valign='top'>
	<id='header-title'> Cosmic Ray e-Lab</div>\n";

  $nav_file="/home/i2u2/cosmic/src/jsp/include/nav-teacher.jsp";
  include($nav_file);

echo "</TD>
    </TR></TABLE>
	\n";    

  echo "<hr>\n\n";
}

?>
