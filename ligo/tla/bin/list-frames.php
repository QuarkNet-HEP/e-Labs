#!/usr/bin/env php
<?php 
/***********************************************************************\
 * list-frames.php  - list frame files needed for a given GPS interval
 *
 * This script, which is intended to be called from a script, not 
 * a web page, will list all the LIGO frame files needed to cover a given
 * GPS time interval.  You may optionally specify the trend type (defaults to 
 * minute-trends) and source (defaults to LHO). 
 *
 * The following command line arguments can be used to modify the 
 * behaviour of this script:
 * 
 *   -i ifo         name of interferometer, either "H" (default) or "L" 
 *
 *   -t ttype       type of trending or sampling, either "R" for raw data 
 *                  at full sampling rate or M for minute-trends, T for 
 *                  second trends, D for 10min trends, or H for hour-trends.
 *
 *   -s <timestamp> starting time (GPS time or Unix timestamp)
 *
 *   -e <timestamp> ending time (GPS time or Unix timestamp)
 *
 *
 * Eric Myers <myers@spy-hill.net>  - 31 October 2007
 * @(#) $Id: list-frames.php,v 1.1 2007/10/31 18:05:40 myers Exp $
\***********************************************************************/

// Configuration defaults:

$work_start = time();           // starting time, defaults to now
$work_end = $work_start - 3600; // default fallback
$site = "H";                    // 'H' for Hanford, 'L' for Livingston
$ttype = "M";               // sampling type ('M', 'T', or 'R')

$HOME = getenv("HOME");


// Data source:
//
if( is_dir("/data/ligo/frames/") ){                     # LHO - tekoa
        $RDS_local_path = "/data/ligo/frames/";
 }
if( is_dir("/disks1/myers/data/ligo/frames/") ){        # Argonne I2U2
        $RDS_local_path = "/disks1/myers/data/ligo/frames/";
 }
elseif( is_dir($HOME."/i2u2/data/ligo/frames/") ){      # Spy Hill
        $RDS_local_path=$HOME."/i2u2/data/ligo/frames/";
}

if( ! is_dir($RDS_local_path) ) {
    echo "!Error: cannot find local data directory for frame files.\n";
    exit(7);
 }



/*******************************
 * Begin:
 */


/* If run from the command line then parse command line args */

if( empty($_SERVER['SERVER_ADDR']) ) {
    $is_html=false;
    $self=$_SERVER['argv'][0];
    $options = getopt("s:e:rpxi:t:");   
 }// command line
 else exit;


/**
 * -i site  is either 'H' for Hanford or 'L' for Livingston
 */
if( isset($options['i']) && $options['i'] !== FALSE ) {
    $x =$options['i'];
    if($x == 'H' || $x == 'L' || $x == 'G' || $x == 'V' ) {
        $site=$x;
    }
    else {
        echo "$self: unknown argument for '-i $x'\n.";
    }
 }


/**
 * -t ttype  is trending/sampling type, either 'R' for raw data at the full 
 *           sampling rage, or 'M' for minute trends,  'T' for second trends, 
 *           or 'D' for 10-minute trends,  'H' for hour trends. 
 */
if( isset($options['t']) && $options['t'] !== FALSE ) {
    $x =$options['t'];
    if($x == 'M' || $x == 'T' || $x == 'R' || $x == 'D' || $x == 'H' ) {
        $ttype=$x;
    }
    else {
        echo "$self: unknown argument for '-t $x'\n.";
    }
 }


/**
 *  -s <timestamp> sets $work_start, which is the time at which to begin working
 *               backwards.  It may be may be either a GPS time or a Unix time.
 */
if( isset($options['s']) && $options['s'] !== FALSE ) {
    $x =$options['s'];
    if( is_numeric($x) && $x < time() && $x > 729000111) {
        $work_start = $x;
    }
    else {
        echo "$self: unknown argument or bad time for '-s $x'\n.";
    }
 }


/**
 *  -e <timestamp> sets $work_end, which is the time at which to stop working
 *               (backwards).  Can be either a GPS time or a Unix time.
 *               If not set, pick a reasonable default.
 */

if( isset($options['e']) && $options['e'] !== FALSE ) {
    $x =$options['e'];
    if( is_numeric($x) && $x < time() && $x > 729000111) {
        $work_end = $x;
    }
    else {
        echo "$self: unknown argument or bad time for '-e $x'\n.";
    }
 }
 else {

     ////////
     //TODO: replace this with an associative array of values
     ///////

     $default_lag=array('M' => 24*3600, 'T' => 15*60,  'R' => 3*60,
                        'D' => 2*3600,  'H' => 24*3600);
     /////////

     switch($ttype){
     case 'M':              // minute trends are 24hrs ago
         $work_end = $work_start-24*3600;     
         break;
     case 'T':              // second trends are 15min ago
         $work_end = $work_start-15*60;     
         break;
     case 'R':              // raw data is 3min
         $work_end = $work_start-3*60;     
         break;
     case 'D':              // 10-min trends for 2 hours
         $work_end = $work_start-2*3600;     
         break;
     case 'H':              // Hour trends: go back 2 days
         $work_end = $work_start-48*3600;
         break;
     }
 }



/*******************************
 * Source and Destination paths and parameters:
 * Frame files are stored in subdirectories of the form
 * H-R-8549  or H-M-864.  

 */

$GPS_block = 1e6;
$source_dirs=array();

switch($ttype){
 case 'M':              // minute trends 
     $frame_length = 3600;
     $data_path = "trend/minute-trend/";
     $source_dirs[] = "/dmt/New_Seis_Blrms";
     break;

 case 'T':              // second trends
     $frame_length = 60;
     $data_path = "trend/second-trend/";
     break;

 case 'R':              // raw data, untrended
     $frame_length = 32;
     //TODO: this will need to be fleshed in to choose S5, S4, S3, S2, E12, E11...
     // based on GPS time, and will have problems if the interval spans
     // the division between any of those
     $data_path = "S5/L0/";
     $GPS_block = 1e5;
     break;

 case 'D':                      // 10-min trends
     $frame_length = 12*3600;   // 12 hrs long
     $data_path = "trend/ten-minute-trend/";

 case 'H':                      // 60-min trends
     $frame_length = 72*3600;   // 72 hrs long
     $data_path = "trend/hour-trend/";

 default:
     echo "Unknown trend type $ttype";
     exit(3);
 }




/**
 * Data directories
 */

$dest_dir  = $RDS_local_path;
$dest_dir .= $data_path ."L" .$site."O";

$dest_prefix = $site."-".$ttype."-";  

/**
 *  Figure out starting point, either from Unix or GPS time 
 */

$GPS_epoch=date("U",strtotime("6 Jan 1980 00:00:00 GMT"));  

if( $work_start > 1e9 ) { // Unix time or GPS time? (this fails in 2011)
    $work_start = $work_start - $GPS_epoch - 14; // current GPS time (14 leap seconds)
 }
if( $work_end > 1e9 ) { // Unix time or GPS time?  (this fails in 2011)
    $work_end = $work_end - $GPS_epoch - 14; // current GPS time (14 leap seconds)
 }

/*  correct for reversed start/end times */

if($work_start < $work_end) {
    $x = $work_end;
    $work_end = $work_start;
    $work_start = $x;
 }


/*********NOT SO VERBOSE
echo "Starting GPS time $work_start, working backward to $work_end \n";
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
if( $ttype == 'D') echo ", 10min trends ";
if( $ttype == 'H') echo ", hour trends ";
echo "\n";
*********/


/**********************
 * Loop over (megasecond) blocks of GPS times
 */

$GPS_frame= intval($work_start/$frame_length)*$frame_length;
#print "Starting GPS frame is $GPS_frame \n";
$GPS_now = time ()- $GPS_epoch-14;   // current GPS time 


$GPS_prefix=intval($GPS_frame/$GPS_block);
$Nfiles=0;  // count files processed for performance monitoring
$t_start = time();   // time how long this takes

$GPS_frame += $frame_length;    // offset by first step back below


while( $GPS_prefix > 748 ) { 
    #print "Processing GPS prefix $GPS_prefix \n";

    /* Locate/create the destination directory */

    $dest_subdir = $dest_dir ."/". $dest_prefix . $GPS_prefix;
    //print "  Destination subdirectory is $dest_subdir \n";

    if( !is_dir($dest_subdir) ){
        print "  Missing data directory: $dest_subdir...\n";
        continue;
    }

    // Loop over frame times in this block

    $GPS_low = $GPS_prefix*$GPS_block;    // lowest time in the block

    while($GPS_frame > $GPS_low){
        $GPS_frame -= $frame_length;    // next frame back
        //echo "Processing frame $GPS_frame\n";

    ///////////////
    //TODO change GPS_prefix *inside* this loop rather than outside,
    // and handle attendant work here.
    //////////////
         
        // If too recent then a frame won't be ready yet
        if( $GPS_frame+$frame_length > $GPS_now ) continue;

        if( $GPS_frame > $work_start ) continue;        // too high
        if( $GPS_frame < $work_end  ) break 2;          // done
        if( $GPS_frame < 700123456  ) break 2;          // safety net

        $filename = $dest_prefix . $GPS_frame . "-" . $frame_length . ".gwf";
        $dest_gwf= $dest_subdir ."/". $filename;

        /* if dest file already exists and if
         *  -x was specified, then skip it; or if
         *  -r was not specified, then quit         */

        if( file_exists($dest_gwf) ){
            echo $dest_gwf . "\n";
            $Nfiles++;
        }
    }// next frame (earlier)

    $GPS_prefix--;            // back another megasecond...
 }

/*******************************
 * Some final stats
 */

if(0 && $Nfiles>0) {
  echo "Listed $Nfiles frame files.";
 }
if( $Nfiles==0 ) echo "NO FRAME FILES WERE FOUND!\n";

?>
