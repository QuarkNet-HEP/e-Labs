<?php
/***********************************************************************\
 * Project specific functions for CMS e-Lab
 *
 *
 * @(#) $Id: cms-stuff.php,v 1.1 2009/05/12 15:34:33 myers Exp $
\**********************************************************************/


function cms_masthead($title='',$right_stuff='&nbsp;'){
    echo "\n<!-- cms e-lab masthead -->
     <table class='masthead,noborder' width=100% bgcolor='black' ><tr>
       <td class='noborder' width=15% valign='top' align=left>
              <a href='/elab/cms/' >
               <img src='/elab/cms/graphics/cms_logo.png' border='0'
                   valign='top' align='left' alt='[cms logo]' 
                   title='return to the top level'></a>
       </TD>";

    echo "
       <TD class='noborder' width='60%' align='LEFT' >
	<div class='header-title'>
		CMS e-Lab
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
          <!-- &nbsp; Compact Muon Solenoid -->
        </div>
	</TD></TR>\n";

    echo "</TABLE>";
    echo "\n<!-- END Tool Masthead -->\n";

    //project_menu_bar();
    echo cms_menu_bar();
}

function cms_banner($title='',$right_stuff='&nbsp;'){// returns $x
  // TODO: make this smarter - teacher or student?
  $home_link="/elab/cms/teacher/";
  $elab_logo="/elab/cms/graphics/cms_logo.png";

  $x = "<TABLE class='masthead' width='100%' bgcolor='black' ><tr>
       <TD class='noborder' width='15%' valign='TOP' align='CENTER'>
              <a href='$home_link' >
	      <img src='$elab_logo'
                   title='return to the e-Lab home'
                   alt='' /></a>
       </td>
       <TD class='noborder' width='60%' align='LEFT' >
	<div class='header-title'>
		CMS e-Lab
	</div>
       </td>\n ";
   $x .= "
       <TD class='noborder' width='25%' valign='TOP' align='RIGHT'>\n";

       if( 1 || isset($hide_user) && $hide_user ) {   // don't show user/login or cache indicator
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



function cms_menu_bar(){
  //TODO: detect teacher -vs- student URL and change accordingly
  return cms_teacher_menu_bar();
}


function cms_teacher_menu_bar(){
    $x = "
    <!-- Teacher's menu bar for cms e-Lab -->
    <TABLE class='menu_bar'><TR>
      <TD>&nbsp;</TD>
      <TD><a href='/elab/cms/teacher/'>
            Teacher Home</a>
      </td>";

    $x .= "
      <TD><a href='/elab/cms/teacher/community.jsp'>
            Share Ideas</a>
      </td>";

    $x .= "
      <TD><a href='/elab/cms/teacher/standards.jsp'>
            Standards</a>
      </td>";

    $x .= "
      <TD><a href='/elab/cms/teacher/site-map.jsp'>
            Site Index</a>
      </td>";

    $x .= "
      <TD><a href='/elab/cms/teacher/registration.jsp'>
            Registration</a>
      </td>";

    $x .= "
      <TD><a href='/elab/cms/home/'>
            Student Home</a>
      </td>";

    $x .= "\n    </TR>
    </TABLE><!-- END menu bar -->\n";

    return $x;
}


?>
