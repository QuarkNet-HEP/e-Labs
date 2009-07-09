#!/usr/bin/env php
<?php
/***********************************************************************\
 * copy-rds.php  - copy the I2U2 Reduced Data Set 
 *
 * This script, which may be from the command line or as a cron job, 
 * will copy frame files for the I2U2 Reduced Data Set (RDS) from a machine
 * on which they reside, based on GPS time. 
 *
 * When run and there is no existing copy of the RDS then it will simply
 * work itself back in time until it runs out of data, assembling 
 * the whole RDS.  You probably don't want this, but it's possible.
 * You will have to remove the safety stop which is on by default to prevent
 * this from happening (see below).
 * 
 * When run and there already is existing data locally it will work itself
 * back in time until it finds an existing file in the destination
 * directory, and then it will stop.   Thus it can be run periodically, 
 * either by hand or via cron job, to just add the latest data available 
 * since the last time it was run.
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
 * behaviour of this script.  They are similar to the update-rds.php script.
 * 
 *   -s <timestamp> starting time (GPS time or Unix timestamp)
 *
 *   -e <timestamp> ending time (GPS time or Unix timestamp)
 *
 *   -r             rebuild/replace - will overwrite existing frame files
 *                  in the destination directory instead of stopping  
 *
 *   -x		        exists - skip over existing destination files, continue
 *                     work with the next  (AT PRESENT THIS IS MEANINGLESS)
 *
 *   -i ifo         name of interferometer, either "H" (default) or "L",
 *                  (someday perhaps "G", "V" and "T" for other IFO's?)
 *
 *   -t ttype       type of trending or sampling, either "R" for raw data 
 *                  at full sampling rate or M for minute-trends, T for 
 *                  second trends, D for 10min trends, or H for hour-trends.
 *
 *
 * NOTE: it doesn't all work like this yet.  This version is just getting
 * something to work that we can then work on.
 *
 * Eric Myers <myers@spy-hill.net>  - 1 March 2007
 * @(#) $Id: copy-rds.php,v 1.22 2008/10/30 21:11:31 myers Exp $
\***********************************************************************/

// Configuration defaults:

$replace_file=false;            // replace existing frame file? 
$partial_data=false;            // use only partial data? 
$site="H";                      // 'H' for Hanford, 'L' for Livingston
$ttype="M";                     // trend/sampling type ('M', 'T', or 'R')
$work_start = time();           // starting time  
$work_end=time()-12*3600;       // 12 hours ago, a reasonable default

$tmpfile="/tmp/" .uniqid(). "-copy-rds.log";


// Data source: old 

$RDS_Login = "myers";
$RDS_Server = "tekoa.ligo-wa.caltech.edu";
$RDS_data_source="$RDS_Login@$RDS_Server";
$RDS_data_path="/data/ligo/frames/";

// Data source: new

$RDS_Login = "i2u2data";
$RDS_Server = "terra.ligo.caltech.edu";
$RDS_data_source="$RDS_Login@$RDS_Server";
$RDS_data_path="/ligo/";


// Data destination:

$HOME = getenv("HOME");
if( is_dir("/disks/i2u2-dev/ligo/data/frames/") ){       # Argonne I2U2 dev
   $RDS_local_path = "/disks/i2u2-dev/ligo/data/frames/";
   $httpd_group="www-data";   // Debian 
}
elseif( is_dir("/disks1/myers/data/ligo/frames/") ){    # Argonne I2U2 old
   $RDS_local_path = "/disks1/myers/data/ligo/frames/";
   $httpd_group="www-data";   // Debian
}
elseif( is_dir($HOME."/i2u2/data/ligo/frames/") ){      # Spy Hill
   $RDS_local_path=$HOME."/i2u2/data/ligo/frames/";
   $httpd_group="apache";   // Fedora, probably everybody else
 }

if( ! is_dir($RDS_local_path) ) {
    echo "!Error: cannot find a local destination directory.\n";
    exit(7);
 }
if( ! is_writeable($RDS_local_path) ){
    echo "!Error: cannot write to destination directory $RDS_local_path\n";
    exit(8);
 }



/*******************************
 * Begin:
 */

/* If run from the command line then show a text header and parse args */

if( empty($_SERVER['SERVER_ADDR']) ) {
    $is_html=false;
    $self=$_SERVER['argv'][0];
    // parse command line arguments
    $options = getopt("s:e:rpxi:t:");   
    echo "copy-rds.php:  Copy the I2U2 Reduced Data Set    \n";
    echo "=================================================\n";
 }// command line



/* Web page parsing has been removed.  A separate web form can 
 * be written someday to somehow invoke this script.  */

if( !empty($_SERVER['SERVER_ADDR']) ) {
     $is_html=true;
     $self=$_SERVER['PHP_SELF'];
 }// via web (incomplete)


/**
 * -r means "rebuild" or "replace".  Don't stop if we find an existing 
 *       output frame here, just replace it and continue.
 */
if( isset($options['r']) ) {
    $replace_file=true;
 }


/**
 * -x means "exists".  Don't stop if we find an existing output frame, 
 *       just skip right to the next.  Allows us to quickly
 *       scan a range and fill in anything missing.
 *   (THIS IS MEANINGLESS IN THE PRESENT IMPLEMENTATION)
 */
if( isset($options['x']) ) {
  $skip_existing=true;
 }


/**
 * -i site  is either 'H' for Hanford or 'L' for Livingston
 */
if( isset($options['i']) && $options['i'] !== FALSE ) {
    $x =$options['i'];
    if($x == 'H' || $x == 'L') {
        $site=$x;
    }
    else {
        echo "$self: unknown argument for '-i $x'\n.";
    }
 }

/**
 * -t trending   is either 'M' or 'T' for trending, 'R' for raw
 */
if( isset($options['t']) && $options['t'] !== FALSE ) {
    $x =$options['t'];
    if($x == 'M' || $x == 'T' || $x == 'R') {
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
    if( is_numeric($x) && $x < time() && $x > 749000111) {
        $work_start = $x;
    }
    else {
        echo "$self: unknown argument or bad time for '-s $x'\n.";
    }
 }

/**
 *  -e <timestamp> sets $work_end, which is the time at which to stop working
 *               (backwards).  Can be either a GPS time or a Unix time.
 */
if( isset($options['e']) && $options['e'] !== FALSE ) {
    $x =$options['e'];
    if( is_numeric($x) && $x < time() && $x > 749000111) {
        $work_end = $x;
    }
    else {
        echo "$self: unknown argument or bad time for '-e $x'\n.";
    }
 }
 else {
     $default_lag=array('M' => 36*3600, 'T' => 15*60,  'R' => 3*60,
                        'D' => 2*3600,  'H' => 48*3600);
     $work_end = $work_start - $default_lag[$ttype];
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
     $data_path = "A5/L0/";
     $GPS_block = 1e5;
     break;

 case 'D':                      // 10-min trends
     $frame_length = 12*3600;   // 12 hrs long
     $data_path = "trend/ten-minute-trend/";

 case 'H':                      // 60-min trends
     $frame_length = 72*3600;   // 72 hrs long
     $data_path = "trend/hour-trend/";

 default:
     echo "$self: Unknown trend type $ttype";
     exit(3);
 }



/**
 * Source and destination directories
 */

$source_dir .= "rsync://" .$RDS_data_source . $RDS_data_path 
        . $data_path . "L" .$site."O/";   

$dir_prefix=$site."-".$ttype."-";  // eg. "H-M-"

$dest_dir = $RDS_local_path . $data_path . "L" .$site."O/";   

//TODO: mkdir -p $dest_dir here and now.
//    Recursive mkdir is not available until PHP 5.0.0, so use exec()


//echo "Remote Source directory:\n $source_dir\n";
//echo "Local Destination directory:\n  $dest_dir\n";
//exit(47);


/**
 *  Figure out starting point, either from Unix or GPS time
 */

$GPS_epoch=date("U",strtotime("6 Jan 1980 00:00:00 GMT"));

if( $work_start > 1e9 ) { // Unix time or GPS time?
    $work_start = $work_start - $GPS_epoch - 14; // current GPS time (14 leap s$
 }
if( $work_end > 1e9 ) { // Unix time or GPS time?
    $work_end = $work_end - $GPS_epoch - 14; // current GPS time (14 leap secon$
 }

/*  We always work backwards: correct for reversed start/end times */

if($work_start < $work_end) {
    $x = $work_end;
    $work_end = $work_start;
    $work_start = $x;
 }

echo "Starting GPS time $work_start, working backward to $work_end \n";
if( !$replace_file && !$skip_existing ) {
  echo "(or until we find an existing frame file)";
 }
if( $skip_existing ) {
  echo "(we will skip over existing files)";
 }
if( $ttype == 'M') echo ", minute trends ";
if( $ttype == 'T') echo ", second trends ";
if( $ttype == 'R') echo ", raw data ";
if( $ttype == 'D') echo ", 10min trends ";
if( $ttype == 'H') echo ", hour trends ";

echo "\n";

// I proposed IP address based restrictions, but
// someone at Caltech wanted a password, just to keep
// bots from scanning our server.  This seems to be enough for that.
//
putenv("RSYNC_PASSWORD=".str_rot13("v2h2bayl") );


/**********************
 * Loop over (megasecond) blocks of GPS times
 */

$GPS_frame= intval($work_start/$frame_length)*$frame_length;
print "Starting GPS frame is $GPS_frame \n";

$GPS_prefix=intval($GPS_frame/$GPS_block);
$Nfiles=0;  // count files processed for performance monitoring
$t_start = time();   // time how long this takes

while( $GPS_prefix > 700 ) {
    print "Processing GPS prefix $GPS_prefix... \n";

    $src_subdir = $source_dir . $dir_prefix . $GPS_prefix;
    //print "  Source subdirectory is $src_subdir \n";

    /* Locate/create the destination directory */

    $dest_subdir=$dest_dir . $dir_prefix . $GPS_prefix;
    //print "  Destination subdirectory is $dest_subdir \n";

    if( !is_dir($dest_subdir) ){
        print "  Creating $dest_subdir...\n";
        if( !mkdir($dest_subdir,02775) ) {
            echo " !Error creating directory $dest_subdir. \n";
            //exit(1);
        }
        if( !chgrp($dest_subdir, $httpd_group) ) {
            echo " !Warning: chgrp() directory $dest_subdir"
                        ." to $httpd_group group failed. \n";
        }
    }

    // Construct rsync command for this sub-directory

    $rsync_flags = "-az ";
    //$rsync_cmd = "rsync -v $rsync_flags -e \"/usr/bin/ssh -l $RDS_Login \" ";
    $rsync_cmd = "rsync -v $rsync_flags ";


    $cmd = "$rsync_cmd $src_subdir/ $dest_subdir/";
    echo "% $cmd \n";
    $out="";
    $txt = exec($cmd,$out,$rc);
    if($rc) echo "!Error: rsync returned RC=".$rc."\n";

    if( !empty($out) ){ // grep for file names
        foreach($out as $line){
            if( strpos($line,".gwf") !== FALSE) {
                echo "$line\n";
                $Nfiles++;
            }
            //else { echo " IGNORE: $line\n"; }
        }
    }
    flush();  // in case viewing via web?

    // back another megasecond...

    $t = $GPS_prefix*$GPS_block;
    //echo "Earliest GPS time is $t \n";
    if( $t < $work_end ) break;
    $GPS_prefix--;
 }


/*******************************
 * Some final stats
 */

if($Nfiles>0) {
  $dt = (time()-$t_start); 
  echo "Copied $Nfiles frame files in $dt seconds";
  printf(", which is %3.2f sec/file.\n", $dt/$Nfiles);
 }
if( $Nfiles==0 ) echo "NO FRAME FILES WERE COPIED.\n";

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
