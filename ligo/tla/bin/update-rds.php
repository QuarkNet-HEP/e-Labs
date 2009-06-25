#!/usr/bin/env php
<?php 
/***********************************************************************\
 * update-rds.php  - build/update the I2U2 Reduced Data Set
 *
 * This script, which may be run from the command line or as a cron job, 
 * will update the I2U2 RDS by starting at the current time
 * and working backward, collecting together the selected channels from
 * various frame files and putting them into an RDS frame file.
 *
 * When run and there is no existing RDS then it will simply work itself
 * back in time until it runs out of data, assembling the whole RDS.
 * 
 * When run and there already is existing data in the RDS it will work 
 * back in time until it finds an existing file in the destination
 * directory, and then it will stop.   Thus it can be run periodically, 
 * to just add the latest data available since the last time it was run.
 * 
 * Files are organized in subdirectories under the main destination directory 
 * based on GPS times.   You just need to name the directory which contains
 * these subdirectories.   The same is assumed for the source file directories,
 * you just need to name the top level data directories which contain the
 * subdirectories.  The source subdirectories do not need to be grouped 
 * together based on the same GPS time blocks.
 *
 * The first source directory (if there is more than one) is used to get GPS
 * timestamps for frame files.  Processing will stop when all files under that
 * source directory have been processed. [TODO: change to using GPS hours]
 *
 * The following command line arguments can be used to modify the 
 * behaviour of this script:
 * 
 *   -r             rebuild/replace - will overwrite existing frame files
 *                    in the destination directory instead of stopping  
 *
 *   -x             exists - skip over existing destination files, continue
 *                     work with the next           
 *
 *   -p             partial data OK - will use whatever frames are available
 *                     instead of skipping the frame (eg missing DMT frames)
 *
 *   -i ifo         name of interferometer, either "H" (default) or "L" 
 *
 *   -t ttype       type of trending or sampling, either "R" for raw data 
 *                  at full sampling rate or M for minute-trends, T for 
 *                  second trends, D for 10min trends, or H for hour-trends.
 *
 *   -d value       Set the debug level to "value".  Larger values are more
 *		    verbose.
 *
 *   -s <timestamp> starting GPS time.  Defaults to current time.
 *
 *   -e <timestamp> ending GPS time.  Defaults to short time earlier. 
 *
 * If you give a starting time earlier than ending time then the script
 * will work forward in time rather than backwards.
 * 
 *
 * Eric Myers <myers@spy-hill.net>  - 9 May 2006
 * @(#) $Id: update-rds.php,v 1.39 2009/06/25 00:33:59 myers Exp $
\***********************************************************************/

// Configuration defaults:

$site  = "H";                   // 'H' for Hanford, 'L' for Livingston
$ttype = "M";                   // sampling type ('M', 'T', or 'R')
$replace_file  = false;         // replace existing frame file? 
$skip_existing = false;         // skip over existing frame file?
$partial_data  = false;         // use only partial data (eg. DMT missing)?

$path_to_FrCopy="/ligotools/bin/FrCopy";        // executable FrCopy

$Frames_source  = "/archive/frames";            // source top level          
$RDS_data_path = "/data/ligo/frames";           // destination top level


$debug_level=1;			// larger is more verbose, 0 = silent


/*******************************
 * Functions:
 */

// Convert a Unix timestamp to a GPS time
//
function Unix_to_GPS($time_t) { 
  global $GPS_epoch;
  $t = $time_t - $GPS_epoch;
  // TODO: account for leap seconds
  return $t;
}

// Path to data file  (relative to  /frames )
// 
function frame_filepath($GPS_time, $ttype='M', $site='H'){
  global $frame_length;

  if( empty($frame_length) )
    die("frame_filepath() requires that frame_length be set.\n");

  $p = '';

  if( $ttype == 'M' ) {
    $GPS_block_size=1e6;
    $p = "/trend/minute-trend";
  }

  if( $ttype == 'T' ) {
    $GPS_block_size=1e6;
    $p = "/trend/second-trend";
  }

  if( $ttype == "R" ) { // what if it's not S5?  Deal with it then.
    $GPS_block_size = 1e5;
    // TODO: adjust this based on GPS time
    $p = "/A5/L0";      
  }

  $GPS_block = intval($GPS_time/$GPS_block_size);
  $GPS_frame = $frame_length * intval($GPS_time/$frame_length);

  $p .= "/L".$site."O";
  $p .= "/$site-$ttype-$GPS_block";
  $p .= "/$site-$ttype-$GPS_frame-$frame_length.gwf";
  return $p;
}


// Display a message if debug level is high enough
//
function debug_msg($lvl, $msg){
  global $debug_level;

  if( $lvl <= $debug_level ) {
    echo substr("     ",-$lvl);		// indent by level
    echo  "[$lvl] $msg \n";
  }
}



/*******************************
 * Begin:
 * If run from the command line then show a text header and parse args
 * (and this script is always run from the command line or via cron)
 */
if( empty($_SERVER['SERVER_ADDR']) ) {
    $is_html=false;
    $self=$_SERVER['argv'][0];
    // parse command line arguments
    $options = getopt("s:e:rpxi:t:d:");   
    echo "update-rds.php:  Update the I2U2 Reduced Data Set\n";
    echo "=================================================\n";
 }


$tmpfile="/tmp/" .uniqid(). "-FrCopy.log";

$GPS_epoch=date("U",strtotime("6 Jan 1980 00:00:00 GMT"));  
$GPS_now = Unix_to_GPS(time()-14);      //  Current GPS time, w/ leap second
$GPS_early = 707457600;                 

$work_start = $GPS_now;         // default is to start now
$step = -1;                     //        and work backwards


/**
 * -r means "rebuild" or "replace".  Don't stop if we find an existing 
 *       output frame, just replace it and continue.
 */
if( isset($options['r']) ) {
    $replace_file=true;
 }


/**
 * -x means "exists".  Don't stop if we find an existing output frame, 
 *       just skip right to the next.  Allows us to quickly
 *       scan a range and fill in anything missing.
 */
if( isset($options['x']) ) {
  $skip_existing=true;
 }


/**
 * -p means "partial".  If there are multiple sources of data and one is
 *          not available but others are then just use what is there and
 *          continue work.  Normally we skip it and expect to get more 
 *          complete data next time the script is run.
 */
if( isset($options['p'] ) ){
    $partial_data=true;
 }


/**
 * -t ttype  is trending/sampling type, either 'R' for raw data at the full 
 *           sampling rage, or 'M' for minute trends,  'T' for second trends, 
 *           or 'D' for 10-minute trends,  'H' for hour trends. 
 */
if( isset($options['t']) && $options['t'] !== FALSE ) {
    $x = $options['t'];
    if($x == 'M' || $x == 'T' || $x == 'R' || $x == 'D' || $x == 'H' ) {
        $ttype=$x;
    }
    else {
        echo "$self: unknown argument for '-t $x'\n.";
    }
 }

// debugging:  this prevents command from actualy executing
//
//if( $ttype == 'R' ) $debug_level = 5;




/**
 * -i site  is either 'H' for Hanford or 'L' for Livingston
 */
if( isset($options['i']) && $options['i'] !== FALSE ) {
    $x = $options['i'];
    if($x == 'H' || $x == 'L' || $x == 'G' || $x == 'V' ) {
        $site=$x;
    }
    else {
        echo "$self: unknown argument for '-i $x'\n.";
    }
 }
$IFO = "L".$site."O";           // eg. LHO or LLO 


/** 
 * -d N sets the debug level to N
 */
if( isset($options['d']) && $options['d'] !== FALSE ) {
    $x = $options['d'];
    if( is_numeric($x) ) $debug_level = $x;
    debug_msg(2,"Debug level set to $debug_level");
}


/**
 *  -s <timestamp> sets $work_start, which is the GPS time to start at
 */
if( isset($options['s']) && $options['s'] !== FALSE ) {
    $x = $options['s'];
    if( is_numeric($x) && $x > $GPS_early) {
        $work_start = $x;
    }
    else {
        echo "$self: unknown argument or bad time for '-s $x'\n.";
    }
 }


/**
 *  -e <timestamp> sets $work_end, which is the GPS time at which to stop
 *               If not set, pick a reasonable default.
 */

if( isset($options['e']) && $options['e'] !== FALSE ) {
    $x = $options['e'];
    if( is_numeric($x) && $x > $GPS_early) {
        $work_end = $x;
    }
    else {
        echo "$self: unknown argument or bad time for '-e $x'\n.";
    }
 }
 else {// Default work end is back a reasonable amount of time

     $default_lag=array('M' => 36*3600, 'T' => 15*60,  'R' => 3*60,
                        'D' => 2*3600,  'H' => 48*3600);
     $work_end = $work_start - $default_lag[$ttype];
 }

if( empty($work_start) || empty($work_end) )
  die("! Error specifying start or end time.\n ");

if( $work_start < $GPS_early || $work_start < $GPS_early )
  die("GPS time is too early.  No data before $GPS_early.");

if($work_start < $work_end) {
  $step = +1;
 }


/*******************************
 * Source and Destination parameters:
 * Frame files are stored in subdirectories of the form H-R-8549 or H-M-864.  
 */

// TODO: change this to a set of arrays 

switch($ttype){
 case 'M':              // minute trends 
     $frame_length = 3600;
     $GPS_block_size = 1e6;
     break;

 case 'T':              // second trends
     $frame_length = 60;
     $GPS_block_size = 1e6;
     break;

 case 'R':              // raw data, untrended
   $frame_length = 32;   // Except that this might be 16 
   $GPS_block_size = 1e5;
   break;

 case 'D':                      // 10-min trends (some day...)
     $frame_length = 12*3600;   // 12 hrs long 
     $GPS_block_size = 1e6;
     $data_path = "trend/ten-minute-trend/";

 case 'H':                      // 60-min trends (some day...)
     $frame_length = 72*3600;   // 72 hrs long
     $GPS_block_size = 1e6;
     $data_path = "trend/hour-trend/";

 default:
     echo "Unknown trend type $ttype";
     exit(3);
 }



/**
 * Channel selection: names or patterns of channels to extract from full 
 * frame files.  Note that for FrCopy channel names are case insensitive.
 */

$DEVICE=$site."0:";
$PEM=$DEVICE."PEM";
$DMT=$DEVICE."DMT";
$GDS=$DEVICE."GDS";

$TAGS ="$DEVICE*_TILT* $DEVICE*_MAG* $DEVICE*_SEIS*  $PEM-*_RAIN* ";
$TAGS.="$PEM-*_WIND* $PEM-*_WDIR $PEM-*_O5* $GDS-EARTHQUAKE* ";
$TAGS.="$DEVICE*SEIS*Hz ";


/**
 *  Get it started:
 */

echo "Starting GPS time $work_start, working ";
if( $step > 0 ) echo "forwards ";
 else           echo "backwards ";
echo "to $work_end \n";

if( !$replace_file && !$skip_existing ) {
  echo "(or until we find an existing frame file)";
 }
if( $skip_existing ) {
  echo "(we will skip over existing files)";
 }
if( $replace_file) {
  echo "(we will regenerate existing files)";
 }

if( $ttype == 'M') echo ", minute trends ";
if( $ttype == 'T') echo ", second trends ";
if( $ttype == 'R') echo ", raw data ";
//if( $ttype == 'D') echo ", 10min trends ";
//if( $ttype == 'H') echo ", hour trends ";
echo "\n";


/**********************
 * Loop over frames.  We can't use a for() loop here because
 * frame_length can change (on A3 for raw data).
 */

$GPS_frame= intval($work_start/$frame_length)*$frame_length;
debug_msg(2, "Starting GPS frame is $GPS_frame ");
$work_start = $GPS_frame;

$GPS_block = intval($GPS_frame/$GPS_block_size);
debug_msg(2, "GPS block $GPS_block");
$GPS_block_old = $GPS_block-1;  // trigger initial check

$Nfiles=0;  // count files processed for performance monitoring
$t_start = time();   // time how long this takes


while( $GPS_frame > $GPS_early && $GPS_frame < $GPS_now  ){

  // Are we done?  (If working backwards, don't stop until we create a file) 
  //
  $work_done= abs($GPS_frame-$work_start)/abs($work_end-$work_start);
  debug_msg(2,"$GPS_frame " . intval(0.5+$work_done*100). "% ");
  if( ($work_done >= 1.0)
      && ( $step > 0 || ($ttype=='M' && $Nfiles > 0) || $ttype!='M') ) break;


  // Destination filepath:

  $dest_gwf  = $RDS_data_path . frame_filepath($GPS_frame,$ttype,$site);
  $filename = basename($dest_gwf);


  // New Block?  Then we may need to create a new block directory
  //
  $GPS_block = intval($GPS_frame/$GPS_block_size);   
  if( $GPS_block != $GPS_block_old ) {  // New block?
    debug_msg(1, "Processing GPS block $GPS_block ");

    $dest_subdir = dirname($dest_gwf);
    debug_msg(3,"  Destination subdirectory is $dest_subdir ");

    if( !is_dir($dest_subdir) ){
      debug_msg(2,"Creating $dest_subdir...");
      if( !mkdir($dest_subdir,0755,true) ) {
        echo " ! Error creating directory $dest_subdir. \n";
        exit(1);
      }
    }
    $GPS_block_old = $GPS_block;
  }

   
  // if dest file already exists and  -x was specified, then skip it
  //
  if( file_exists($dest_gwf) && $skip_existing ){
    echo basename($dest_gwf). " exists. Skipped.\n";
    $GPS_frame += $step * $frame_length;    // next frame 
    continue;
  }

  // If dest file already exists and -r was not specified, then quit
  //
  if( file_exists($dest_gwf) && !$replace_file ) { 
    echo "File " .basename($dest_gwf). " already exists. \n";
    echo "Updating is finished.\n";
    break; 
  }


  $in_list='';

  if( $ttype == 'M' ){// Minute trends are both /archive and DMT

    $filepath  = $Frames_source."/trend/minute-trend/$IFO";
    $filepath .= "/$site-M-" . intval($GPS_block/10);
    $filepath .= "/$site-$ttype-$GPS_frame-$frame_length.gwf";
    if( file_exists($filepath) ) {
      $in_list .= " -i $filepath ";
    }
    else {
      if( !$partial_data ) {    
        if( $step > 0 || $Nfiles > 0 )
          echo " ! Error: missing archive file $filepath \n";
        $GPS_frame += $step * $frame_length;    // next frame 
        continue;
      }
      else {
        echo "* Warning: missing archive file $filepath \n";
      }
    }

    $filepath  = $Frames_source."/dmt/$IFO/New_Seis_Blrms";
    $filepath .= "/$site-M-$GPS_block";
    $filepath .= "/$site-Seis_Blrms_$ttype-$GPS_frame-$frame_length.gwf";
    if( file_exists($filepath) ) {
      $in_list .= " -i $filepath ";
    }
    else {
      if( !$partial_data ) {
        if( $step > 0 || $Nfiles > 0 )
          echo " ! Error: missing DMT file " . basename($filepath). "\n";
        $GPS_frame += $step * $frame_length;    // next frame 
        continue;
      }
      else {
        echo "* Warning: missing DMT file " . basename($filepath). "\n";
      }
    }
  }

  // Second-trends or raw frames:
  //
  if( $ttype == 'T' || $ttype == 'R' ){// 
    $filepath  = $Frames_source. frame_filepath($GPS_frame,$ttype,$site);
    debug_msg(3,"Looking for $filepath");
    if( file_exists($filepath) ) {
      $in_list .= " -i $filepath ";
    }
    else {
      if( !$partial_data ) {
        if( $step > 0 || $Nfiles > 0 )
          echo " ! Error: missing data file " . basename($filepath). "\n";
        $GPS_frame += $step * $frame_length;    // next frame 
        continue;
      }
      else {
        echo "* Warning: missing data file " . basename($filepath). "\n";
      }
    }
  }


  // Process the input file(s)

  if(empty($in_list)) {
    debug_msg(2," ! Error: no input files found for GPS $GPS_frame");
    $GPS_frame += $step * $frame_length;    // next frame       
    continue;
  }
  $cmd="$path_to_FrCopy $in_list -o $dest_gwf -t $TAGS";
  echo "$filename ";

  $rc=0; 
  debug_msg(4," % $cmd ");
  if( $debug_level < 5 ) {
	system($cmd." >$tmpfile", $rc);
	if( $rc == 0 ) echo " OK.\n";
	else           echo " FAILED! (rc=$rc) \n";
  }
  else {
    echo " (not attempted) \n";
  }
  $Nfiles++;    // counts number of files processed or attempted
  $GPS_frame += $step * $frame_length;    // next frame 
}


/*******************************
 * Some final stats
 */

if($Nfiles>0) {
  $dt = (time()-$t_start); 
  echo "Created $Nfiles frame files in $dt seconds";
  printf(", which is %3.2f sec/file.\n", $dt/$Nfiles);
 }
if( $Nfiles==0 ) echo "NO FRAME FILES WERE CREATED.\n";

if( $is_html ) {
    echo "\n</PRE>
    </BODY>\n</HTML>\n";
 }
 else {
     if( $Nfiles > 0 ){
         echo "%DONE\n";
     }
 }
?>
