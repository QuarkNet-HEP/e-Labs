<?php
/*******************************
 * Plot multiple channels
 * 
 */

function plotNchan($task_id, $list_file, $Nchan,
                   $GPS_start_time=830600000, $GPS_end_time=830700000,
                   $ttype, $t_axis_pref="GMT",$bg=FALSE){
    global $TLA_VI_DIR, $slot;
    global $input_channels;

    $vi_name="plotNchan";

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
        fwrite($h, "Version: $TLA_version \n");
        fwrite($h, "TaskID: $task_id \n");
        fwrite($h, "Slot: $slot \n");
        fwrite($h, "Transformation: $vi_name \n");
        fwrite($h, "GPS_start_time: $GPS_start_time\n");
        fwrite($h, "GPS_end_time: $GPS_end_time \n");
        fwrite($h, "TimeAxisPref: $t_axis_pref \n");
        fwrite($h, "Ninputs: $Nchan\n"); // eventually redundant

        // loop over $Nch channels, counting from 1
        //
        for($i=1;$i<=$Nchan;$i++){

           $chName = $input_channels[$i]->name; 
           $ttype  = $input_channels[$i]->ttype;
           $tcomp  = $input_channels[$i]->tcomp;

            fwrite($h, "BEGIN: InChannel \n");
            fwrite($h, "PenNumber: $i \n");
            fwrite($h, "ChannelName: $chName \n");
            fwrite($h, "TrendType: $ttype \n");
            fwrite($h, "TrendComponent: $tcomp \n");
            fwrite($h, "END: InChannel \n");
        }
        fwrite($h, "END: TLA_PLOT \n");
    }

    //Note: with ROOT 4.04 you cannot have spaces after commas in 
    // the function argument list here.  Ugh!  You have been warned.

    $rootscript="$TLA_VI_DIR/$vi_name/$vi_name".".C(\"$task_id\","
        .'"'.$list_file.'",'.$Nchan.','
        .$GPS_start_time. ',' . $GPS_end_time. ',"'. $ttype .'",'
        .'"'.$t_axis_pref.'")';
    return root_run($rootscript,$task_id,$bg);
}

?>