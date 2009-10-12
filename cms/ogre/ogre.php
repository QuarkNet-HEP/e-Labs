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

    <!-- include the scipts for the flowplayer flash -->
    <script type="Text/JavaScript" Language="JavaScript" src="javascript/flowplayer.js"></script>
    <script type="Text/JavaScript" Language="JavaScript" src="javascript/showTutorial.js"></script>


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
  if ( isset($_GET['restore']) ) {
    $path = $_GET['restore'];
    if ( isset($path) ) {
      include 'php/restore_session.php';
    }
  }

  if ( isset($_GET['user']) ) {
    print "\tvar userName = '" . $_GET['user'] . "';\n";
  } else {
    print "\tvar userName = 'guest';\n";
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

    <!--[if lte IE 8]>
    <style>
    h6#userLevelLabel {top:28%;}
    h6#dataSetLabel {top:28%;}
    h6#selectLabel {top:28%;}

    </style>
    <![endif]-->
  </head>

  <?php if ( isset($_GET['dataset']) ) {$dataset = $_GET['dataset'];} else {$dataset = "mc09";} ?>

  <?php
    if ( isset($path) ) {
      print "<body id='body' onLoad='javascript:initTwo();restoreMe(triggers, holder, plots, color, opts, sID);'>\n";
    } else {
      print "<body id='body' onLoad='javascript:initTwo(sessionID);'>\n";
    }
  ?>
    <Script Language="JavaScript" Type="Text/JavaScript" SRC="javascript/wz_tooltip.js"></Script>

   <div id='load'>
     <div id='loadTxt' class='text' style='top:40%;z-index:20;'>
        <center><font color='#ff00ff'><H1>Loading OGRE Applications</H1></font></center>
       <div id='progress'></div>
     </div> <!-- End of text div -->
   </div>   <!-- end of load div -->

    <!-- silly wrapper so we can hide the page load -->
    <div id="wrapper" class="wrapper" style="display:none;">

      <!-- Wrapper div to isolate the nav controls and keep 'em in one place -->
      <div class="header">
	      <b><i>OGRE</i></b> an <i>O</i>n-line <i>G</i>raphical 
	      <a href="http://root.cern.ch/" target=_blank style="color:#ab0000;"><i>R</i>OOT</a>
	      <i>E</i>nvironment
      </div> <!-- End of header div -->

      <div id='controls' style='margin:25px;'>

 	<button name="button" class="buttons" href="#" style="float:left;margin-right:5px;" 
                onClick='javascript:dataWin.show();'>Select Data</button>
	<button name="button" class="buttons" href="#" style="float:left;margin-right:5px;" 
                onClick='javascript:variWin.show();'>Build Plots</button>
	<button name="button" class="buttons" href="#" style="float:left;margin-right:5px;"
		onClick='return submitGetData(document.forms["getData"]);'>Plot It!</button>

	<button name="button" class="buttons" href="#" style="float:right;margin-left:5px;"
		onClick='javascript:prevWin.show();'>Previous</button>
	<button name="button" class="buttons" href="#" style="float:right;margin-left:5px;"
		onClick='javascript:archWin.show();'>Restore</button>

        <br><br><hr width=98%><br>

	<div name='button' class='tooltip' id='tooltipDiv'>
	  <input type='checkbox' style='cursor:pointer;' checked id='tooltips' onChange='javascript:showToolTips=!showToolTips;'/>ToolTips?
	</div>

	<div name='button' class='dragdrop' id='dragdropDiv'>
	  <input type='checkbox' style='cursor:pointer;' disabled='true' id='dragdrop' onChange='javascript:useDragDrop=!useDragDrop;'/>Drag & Drop?
	</div>

	<div name='button' class='effectToggle' id='effectDiv'>
	  <input type='checkbox' id='effects' style='cursor:pointer;' onChange='javascript:callButton(11);'/>Effects?
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

        <!-- button that opens up overlay -->
	<div name="button" class="button buttons" id='tutorial'>
	  <button href="#" rel="div.overlay" id='tutorialBtn'>Play OGRE Tutorial</button>
	</div>

        <!-- Button that shows the CMS Slice demo -->
        <div name="button" class="buttons" id='demoBtn'>
          <button href="#" onClick='javascript:demoWin.show();'>CMS Detector Demo</button>
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
	    style="float:right;">
	<input type='hidden' name="sessionID"/>
        <?php 
          $directory = "results";
          include "php/previous.php";
          $directory = "archives";
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
	<img id='bkgImg' src="graphics/ogre-mirror-new.png">
      </div>

      <div class="footer" id='footer'> <!-- persistant footer -->
        <div id='menu' class='menu'>
            <script type='Text/JavaScript' src='javascript/menu/ogre-menu.js'></script>
         </div>
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

<script type='text/javascript'>updateProgress(75);</script>

    <!-- load the text for the context sensative help pages -->
    <?php include "php/help.php"; ?>


    <!-- Container for the tutorial video -->
    <!-- element that is overlayed, visuals are done with external CSS -->
    <div class="overlay" style="background-image:url('graphics/gray.png');">

      <!-- flowplayer container -->
      <a id="player" href="../ogre.flv">

  	<!-- some initial content so that player is not loaded upon page load -->
	&nbsp;
      </a>
    </div>

  </body>
</html>
