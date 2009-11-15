<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" 
	  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

  <head>
    <META HTTP-EQUIV="Pragma" content="no-cache"/>
    <title>OGRE: CMS On-Line Data Analysis Project</title>

    <link rel="stylesheet" type="text/css" href="stylesheets/ogre.css"/>
    <link rel="shortcut icon" href="graphics/ogre.icon.png" type="image/x-icon" />

    <!-- Include file for javascript needed on this page -->
    <Script Language="JavaScript" Type="Text/JavaScript" SRC="javascript/ogre-includes.js"></Script>

   <script type='text/javascript'>
<?php

   include 'php/getBaseURL.php';
   if ( isset($urlPath) ) {
     print "\tvar baseURL = '$urlPath';\n";
   } else {
     print "\tvar baseURL = '';\n";
   }

   if ( isset($_GET['theme']) ) {
     $theme = $_GET['theme'];
     print "\t// Location of the theme definition file for decorating the windowlets\n";
     if ( $theme == "ogre" ) {
       print "\tvar xmlThemeFile = \"$urlPath/xml/ogre-theme.xml\"\n";
     } else if ( $theme == "simple" ) {
       print "\tvar xmlThemeFile = \"$urlPath/xml/ogre-simple.xml\"\n";
     } else {
       print "\tvar xmlThemeFile = \"$urlPath/xml/ogre-theme.xml\"\n";
     }
   } else {
     print "\tvar xmlThemeFile = \"$urlPath/xml/ogre-theme.xml\"\n";
   }

  // If we're restoring a previous session state... do it here
  if ( isset($_COOKIE['sessionID']) ) {
    $sessionID = $_COOKIE['sessionID'];
    $path = "tmp/$sessionID/url";
    //error_log("Trying to restore from $path");

    if ( file_exists($path) ) {
      include "php/restore_session.php";
    }
  } else if ( isset($_GET['restore']) ) {
    $path = $_GET['restore'];
    if ( isset($path) ) {
      include 'php/restore_session.php';
    }
  } //else {
    //error_log("Unable to find anything to retore from");
//}

  if ( !isset($user) ) {
    if ( isset($_GET['user']) ) {
      print "\tvar userName = '" . $_GET['user'] . "';\n";
    } else {
      print "\tvar userName = 'guest';\n";
    }
  }
?>
    </script>

    <!--[if lte IE 6]>
    <style>
      img#loadImg {
        display: none;
      }
    </style>
    <![endif]-->

    <!--[if IE]>
    <script type="Text/JavaScript" language="JavaScript" src="javascript/IE8.js"></script>
    <style>
	h6#userLevelLabel {top:28%;}
	h6#dataSetLabel {top:28%;}
	h6#selectLabel {top:28%;}

	div.stdContent {
          overflow:hidden;
        }
	button#gotoVars, button#gotoCntl {
	  bottom: -0.5em;
        }
        DragContainer9 {
	  margin-left: 1px;
	}
    </style>
    <![endif]-->
  </head>

  <?php if ( isset($_GET['dataset']) ) {$dataset = $_GET['dataset'];} else {$dataset = "mc09";} ?>

  <?php
    if ( isset($path) ) {
      print "<body id='body' onLoad='javascript:init();restoreMe(triggers, holder, plots, color, opts, sID);'>\n";
    } else {
      print "<body id='body' onLoad='javascript:init(sessionID);'>\n";
    }
  ?>
    <Script Language="JavaScript" Type="Text/JavaScript" SRC="javascript/wz_tooltip.js"></Script>

   <div id='load'>
     <div id='loadTxt' class='text'>
        <center><font color='#ff00ff'><H1>Loading OGRE Applications</H1></font></center>
       <div id='progress'></div>
     </div> <!-- End of text div -->
   </div>   <!-- end of load div -->

    <!-- silly wrapper so we can hide the page load -->
    <div id="wrapper" class="wrapper">

      <!-- Wrapper div to isolate the nav controls and keep 'em in one place -->
      <div class="header">
          <div id='hdrText'>
	      <b><i>OGRE</i></b> an <i>O</i>n-line <i>G</i>raphical 
	      <a id='rootlink' href="http://root.cern.ch/" target=_blank ><i>R</i>OOT</a>
	      <i>E</i>nvironment
        </div>
        <div id='buttonWrapperTop'>

 	<button name="button" class="buttons ctlbtnlft" href="#"
                onClick='javascript:dataWin.show();'>Select Data</button>
	<button name="button" class="buttons ctlbtnlft" href="#"
                onClick='javascript:variWin.show();'>Build Plots</button>
	<button name="button" class="buttons ctlbtnlft" href="#"
		onClick='return submitGetData(document.forms["getData"]);'>Plot It!</button>

	<button name="button" class="buttons ctlbtnrgt" href="#"
		onClick='javascript:prevWin.show();'>Previous</button>
	<button name="button" class="buttons ctlbtnrgt" href="#"
		onClick='javascript:archWin.show();'>Restore</button>
        </div>
      </div> <!-- End of header div -->

      <div id='controls'>

 	<button name="button" class="buttons ctlbtnlft" href="#"
                onClick='javascript:dataWin.show();'>Select Data</button>
	<button name="button" class="buttons ctlbtnlft" href="#"
                onClick='javascript:variWin.show();'>Build Plots</button>
	<button name="button" class="buttons ctlbtnlft" href="#"
		onClick='return submitGetData(document.forms["getData"]);'>Plot It!</button>

	<button name="button" class="buttons ctlbtnrgt" href="#"
		onClick='javascript:prevWin.show();'>Previous</button>
	<button name="button" class="buttons ctlbtnrgt" href="#"
		onClick='javascript:archWin.show();'>Restore</button>

        <br><br><hr width=98%><br>

	<div name='button' class='tooltip' id='tooltipDiv'>
	  <input type='checkbox' checked id='tooltips' onChange='javascript:toggleTips();'/>ToolTips?
	</div>

	<div name='button' class='dragdrop' id='dragdropDiv'>
	  <input type='checkbox'disabled='true' id='dragdrop' onChange='javascript:toggleDragDrop();'/>Drag & Drop?
	</div>

	<div name='button' class='effectToggle' id='effectDiv'>
	  <input type='checkbox' id='effects' onChange='javascript:callButton(11);'/>Effects?
	</div>

        <!-- Test selector for user levels -->
        <h6 id='userLevelLabel'>Set User Level</h6>
	<select name="button" class="buttons" id='userLevel'
		onChange='javascript:simpleMenuLevel(this.options[this.selectedIndex].value);'>
	  <option value=0>Beginner</option>
	  <option value=1>Intermediate</option>
	  <option value=2>Advanced</option>
	  <option value=3>Wizard</option>
	</select>

        <!-- Grab the datasets from the database and include a selector here -->
        <h6 id='dataSetLabel'>Select Dataset</h6>
        <?php include "php/datasets.php"; ?>

        <!-- Selection for changing themes -->
        <H6 id='selectLabel'>Select Theme</H6>
        <select name="button" class='buttons' id='themes'
		onChange='javascript:callButton(this.options[this.selectedIndex].value);'>
          <option value=12 selected>Standard</option>
          <option value=13>Simple</option>
        </select>

        <br><br><hr width=98%><br>

       <!-- Button that shows the OGRE Tutorial -->
        <div name="button" class="buttons" id='tutrBtnTop'>
          <button href="#" onClick='javascript:tutrWin.show();'>Play OGRE Tutorial</button>
        </div>

        <!-- Button that shows the CMS Slice demo -->
        <div name="button" class="buttons" id='demoBtnTop'>
          <button href="#" onClick='javascript:demoWin.show();'>CMS Detector Demo</button>
        </div>

        <!-- Button that shows the statistics demo -->
        <div name="button" class="buttons" id='statBtnTop'>
          <button href="#" onClick='javascript:statWin.show();'>Statistical Demo</button>
        </div>

        <br><br><hr width=98%><br>

	<div name="button" class="address buttons" id='address'>
	  <address><a href="mailto:karmgard.1@nd.edu?subject=Bug the OGRE">Bug the OGRE</a></address>
	</div>

      </div> <!-- end of controls div -->


<script type='text/javascript'>updateProgress(10);</script>

      <!-- Form for grabbing previous investigations -->
      <form method="POST" id='restoreForm' name="restore"
	    action="./cgi-bin/restore.pl.cgi"
	    onsubmit='return submitForm(document.forms["restore"]);'
	    >
	<input type='hidden' name="sessionID"/>
        <?php 
          $directory = "results";
          include "php/previous.php";
          $directory = "archives";
          if ( isset($_GET['user']) )
            $userName  = $_GET['user'];
          
          include "php/archive.php";
        ?>
      </form>

<script type='text/javascript'>updateProgress(20);</script>

      <!-- Change CGI path on moving! -->
      <form method="POST" name="getData" id='getData' action="./cgi-bin/ogre.pl.cgi">

        <!-- Store some basic bootstrap data for ogre.pl -->
        <?php

          // store the dataset & data description file for later use
          if ( isset($dataset) ) {
            print "<input type='hidden' name='dataset' id='dataset' value='" . $dataset . "'>\n";
            include "php/mysql.php";   // If we have a dataset... and we should... assemble the XML path from it
            print "<input type='hidden' name='xmlfile' id='xmlfile' value='" . $xmlFileName . "'>\n";
          } else {
            print "<input type='hidden' name='xmlfile' id='xmlfile' value='mc_data.xml'>\n";
            print "<input type='hidden' name='dataset' id='dataset' value='mc09'>\n";
          }
        ?>

        <!-- Include the dynamic content -->
        <?php include "php/data.php"; ?>
        <?php include "php/vars.php"; ?>

      </form>

<script type='text/javascript'>updateProgress(30);</script>

      <div class="background" name="Bert" id="background" onMouseDown='javascript:bkgClick(event);'>
	<img id='bkgImg' src="graphics/ogre.png">
      </div>

      <div class="footer" id='footer'> <!-- persistant footer -->

        <div id='buttonWrapperBtm'>

	  <div name='button' class='tooltip' id='tooltipDivBtm'
               onMouseOver='javascript:showogreToolTip(tipTip);' onMouseOut='javascript:UnTip();'>
	    <input type='checkbox' id='tooltipsBtm' 
                   onChange='javascript:toggleTips()'/>ToolTips?
	  </div>

          <!-- Test selector for user levels -->
	  <select name="button" class="buttons" id='userLevelBtm'
		  onChange='javascript:simpleMenuLevel(this.options[this.selectedIndex].value);'
                  onMouseOver='javascript:showogreToolTip(lvlTip);' onMouseOut='javascript:UnTip();'>
	    <option value=0>Beginner</option>
	    <option value=1>Intermediate</option>
	    <option value=2>Advanced</option>
	    <option value=3>Wizard</option>
	  </select>

          <!-- Grab the datasets from the database and include a selector here -->
          <?php $footer=true;include "php/datasets.php"; ?>

          <!-- Selection for changing themes -->
          <select name="button" class='buttons' id='themesBtm'
		  onChange='javascript:callButton(this.options[this.selectedIndex].value);'
                  onMouseOver='javascript:showogreToolTip(thmTip);' onMouseOut='javascript:UnTip();'>
            <option value=12 selected>Standard</option>
            <option value=13>Simple</option>
          </select>

          <!-- Button that shows the OGRE Tutorial -->
          <div name="button" class="buttons" id='tutrBtn'>
            <button href="#" onClick='javascript:tutrWin.show();' 
                    onMouseOver='javascript:showogreToolTip(tutTip);'
                    onMouseOut='javascript:UnTip();'>Tutorial</button>
          </div>

          <!-- Button that shows the CMS Slice demo -->
          <div name="button" class="buttons" id='demoBtn'>
            <button href="#" onClick='javascript:demoWin.show();' 
                    onMouseOver='javascript:showogreToolTip(dmoTip);'
                    onMouseOut='javascript:UnTip();'>CMS Demo</button>
          </div>

          <!-- Button that shows the statistics demo -->
          <div name="button" class="buttons" id='statBtn'>
            <button href="#" onClick='javascript:statWin.show();'
                    onMouseOver='javascript:showogreToolTip(staTip);'
                    onMouseOut='javascript:UnTip();'>Statistics</button>
          </div>

	  <div name="button" class="address buttons" id='addressBtm'>
	    <address><a href="mailto:karmgard.1@nd.edu?subject=Bug the OGRE">Bug the OGRE</a></address>
	  </div>

        </div> <!-- End of button wrapper div -->

      </div> <!-- End of footer div -->

<script type='text/javascript'>updateProgress(40);</script>

      <div id='demo'>
        <div id='flashWrapper'>
        <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width=620 height=450
           codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0" 
           id="CMS_Slice_Demo" align="center">

          <param name="movie"    value="graphics/CMS_Slice.swf">
          <param name="Show All" value="true">
          <param name="quality"  value="medium">
          <param name="bgcolor"  value="#FFFFFF"> 

          <embed src="graphics/CMS_Slice.swf" 
	      quality="high" bgcolor="#FFFFFF" 
	      width="620" height="450" 
	      name="CMS Slice Demo" align="center" 
	      type="application/x-shockwave-flash" 
	      pluginspage="http://www.macromedia.com/go/getflashplayer">
        </object>
        </div>
      </div>

      <div id="demohelp">
	<div id="text" class="text">
	  <H2>Using the CMS Flash Demo</H2>
	  This is where the help text is for the detector demo
	</div> <!-- End of text div -->
      </div>   <!-- end of varhelp div -->

<script type='text/javascript'>updateProgress(50);</script>

      <div id='statdemo'>
        <div id='flashWrapper'>
        <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width=620 height=450
           codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0" 
           id="statdemo" align="center">

          <param name="movie"    value="graphics/masspec.swf">
          <param name="Show All" value="true">
          <param name="quality"  value="medium">
          <param name="bgcolor"  value="#FFFFFF"> 

          <embed src="graphics/masspec.swf" 
	      quality="high" bgcolor="#FFFFFF" 
	      width="620" height="450" 
	      name="Statistical Demo" align="center" 
	      type="application/x-shockwave-flash" 
	      pluginspage="http://www.macromedia.com/go/getflashplayer">
        </object>
        </div>
      </div>

    <!-- load the text for the context sensative help pages -->
    <?php include "php/help.php"; ?>

<script type='text/javascript'>updateProgress(60);</script>

    <div id='tutorial'>
     <div id='flashWrapper'>
        <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width=600 height=280
           codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0" 
           id="ogreTutorial" align="center">

          <param name="movie"    value="graphics/ogre.swf">
          <param name="Show All" value="true">
          <param name="quality"  value="high">
          <param name="play"     value="false">
          <param name="loop"     value="false">
          <param name="bgcolor"  value="#FFFFFF"> 

          <embed src="graphics/ogre.swf" 
	      quality="high" bgcolor="#FFFFFF" 
	      width="600" height="280" 
	      name="OGRE Tutorial" align="center" 
	      type="application/x-shockwave-flash" 
              loop="false"
	      pluginspage="http://www.macromedia.com/go/getflashplayer">
        </object>
        </div>
    </div>

<script type='text/javascript'>updateProgress(75);</script>

  </body>
</html>
