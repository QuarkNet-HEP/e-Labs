<?php
/***********************************************************************\
 * Project specific functions for Cosmic Ray e-Lab
 *
 *
 * @(#) $Id: cosmic-stuff.php,v 1.3 2009/05/22 13:04:02 myers Exp $
\**********************************************************************/

function cosmic_masthead($title='',$right_stuff='&nbsp;'){

  // TODO: make this smarter - teacher or student?
  $home_link="/elab/cosmic/teacher/";
  $elab_logo="/elab/cosmic/graphics/blast.jpg";

  echo "\n<!-- BEGIN Cosmic Ray e-lab masthead -->\n<div class='top'>\n".
     "<TABLE class='masthead' width='100%' bgcolor='black' ><tr>
       <TD class='noborder' width='15%' valign='TOP' align='CENTER'>
              <a href='$home_link' >
	      <img src='$elab_logo'
                   title='return to the e-Lab home'
                   alt='' /></a>
       </td>\n";

    echo "
       <TD class='noborder' width='60%' align='LEFT' >
	<div class='header-title'>
		Cosmic Ray e-Lab
	</div>
	<div class='header-subtitle'>
	    $title
        </div>
       </td>\n ";

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
    echo "\n</TD></TR>\n";

    echo "</TABLE>";

    //project_menu_bar();
    cosmic_menu_bar();

    echo "\n</div><!-- END e-lab masthead -->\n";
  }




function cosmic_menu_bar(){
  //TODO: detect teacher -vs- student URL and change accordingly
  cosmic_teacher_menu_bar();
}


function cosmic_teacher_menu_bar(){
    echo "
    <!-- Teacher's menu bar for Cosmic Ray e-Lab -->
    <TABLE class='menu_bar'><TR>
      <TD>&nbsp;</TD>
      <TD><a href='/elab/cosmic/teacher/'>
            Teacher Home</a>
      </td>";

    echo "
      <TD><a href='/elab/cosmic/teacher/community.jsp'>
            Community</a>
      </td>";

    echo "
      <TD><a href='/elab/cosmic/teacher/standards.jsp'>
            Standards</a>
      </td>";

    echo "
      <TD><a href='/elab/cosmic/teacher/site-map.jsp'>
            Site Index</a>
      </td>";

    echo "
      <TD><a href='/elab/cosmic/teacher/registration.jsp'>
            Registration</a>
      </td>";

    echo "
      <TD><a href='/elab/cosmic/home/'>
            Student Home</a>
      </td>";

    echo "\n    </TR>
    </TABLE><!-- END menu bar -->\n";
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
