<?php
/*******************************
 * Plot a single channel.  
 * 
 */

function plot1chan($task_id, $ch1,
                   $GPS_start_time=830600000, $GPS_end_time=830700000,
                   $t_axis_pref="GMT",$bg=FALSE){
    global $TLA_VI_DIR;
    global $slot;


    $vi_name="plot1chan";

    $chName = $ch1->name;
    $ttype =  $ch1->ttype;
    $tcomp =  $ch1->tcomp;

    /* Write parameters to a file to pass to ROOT script 
     *  (eventually we just pass the name of this file) */

    $fname = $vi_name . ".dat";

    if(! $h = fopen($fname, "w") ){
        debug_msg(1,"Cannot write to parameter file $fname");
    }
    else { // start sketching parameter file
        //TODO: functionalilze this, or parts of it
        $TLA_version = cvs_version();
        $TLA_date = date('c');
        fwrite($h, "#TLA/Bluestone v$TLA_version parameters $TLA_date\n");
        fwrite($h, "BEGIN: TLA_PLOT  \n");
        fwrite($h, "VERSION: $TLA_version \n");
        fwrite($h, "TASK_ID: $task_id \n");
        fwrite($h, "SLOT: $slot \n");
        fwrite($h, "TRANSFORMATION: $vi_name \n");
        fwrite($h, "GPS_start_time: $GPS_start_time\n");
        fwrite($h, "GPS_end_time: $GPS_end_time\n");
        fwrite($h, "Time_Axis_Pref: $t_axis_pref\n");
        fwrite($h, "Ninputs: 1\n"); // eventually redundant
        fwrite($h, "BEGIN: In_Channel \n");
        fwrite($h, "Pen_Number: 1 \n");
        fwrite($h, "Channel_Name: $chName \n");
        fwrite($h, "TrendType: $ttype \n");
        fwrite($h, "Trend_Component: $tcomp \n");
        fwrite($h, "END: In_Channel \n");
        fwrite($h, "END: TLA_PLOT \n");
    }

    //Note: with ROOT 4.04 you cannot have spaces after commas in 
    // the function argument list here.  Ugh!  You have been warned.

    $rootscript="$TLA_VI_DIR/$vi_name/$vi_name".".C(\"$task_id\",\"$chName\"," .
        $GPS_start_time. "," . $GPS_end_time. ",\"". $ttype ."\""
        .",\"".$t_axis_pref."\")";
    return root_run($rootscript,$task_id,$bg);
}

?>