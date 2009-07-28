<?php
/***********************************************************************\
 * plot_options.php -  deal with ROOT plot options and how to change them
 *
 *  These functions support changing the appearance of a ROOT plot after
 *  it has been created.  In general, for each item which can be altered 
 *  there is a 'control', which presents an input box or button for the user,
 *  a 'handler' which processes any input from the corresponding control.
 *  Changes are recorded in the array $plot_options, including the ROOT
 *  commands necessary to affect the change.  When all options have been
 *  processed, the ones which have been changed are written to an update file.
 *  
 *  To apply changes to a plot we run a ROOT process which reads in 3 files:
 *  1) script to create current plot, 2) update script to apply the change,
 *  and 3) script to save the results, as both graphics file and script.
 *
 *
 * Eric Myers <myers@spy-hill.net  - 24 May 2006
 * @(#) $Id: plot_options.php,v 1.31 2009/04/22 14:59:27 myers Exp $
\***********************************************************************/


// Each controllable option in a ROOT plot is described by 
// one of these Objects:

class ROOT_Plot_Option{
  var $value;
  var $previous_values;   // array - used for Undo function
  var $root_cmd;          // ROOT commands to implement a change 


  function ROOT_Plot_Option($v=''){ // Constructor
    $this->value=$v;
    $this->previous_values=array(); // fresh start
  }

  function set($v){ // set new value (push previous) and set change flag
    global $Nplot;

    $this->previous_values[$Nplot]=$this->value;
    $this->value=$v;
  }

  function get_update(){ // return the ROOT commands, and clear them  
    $root_cmd = $this->root_cmd;
    $this->root_cmd = '';
    return $root_cmd;
  }

  function undo(){ // back up to previous applicable value
    global $Nplot;

    if($Nplot <= 1 ) return;
    $N = $Nplot-1;

    $v = $this->value;
    for($i=1;$i< $Nplot;$i++){
      if( array_key_exists($i,$this->previous_values) ){       
        if($i<=$N){
          $v=$this->previous_values[$i];
        }
        else{
          unset($this->previous_values[$i]);
        }
      }
    }
    $this->value=$v;
  }
}

/***************************************************\
 * Supporting functions:
\***************************************************/


// Handle input changes for all plotting options, and then apply them 
//
function handle_plot_options(){
  handle_time_axis();
  handle_max_y();
  handle_min_y();
  handle_autoscale_y();
  handle_plot_title();
  handle_y_axis();
  handle_pen_color();
  // Now apply the change.  This writes ROOT update file
  apply_plot_options();         
}



// Get any *changes* to plot options from user input
//
function handle_plot_option_item($item){
  if( !get_posted($item) ) return;    
  $x = get_posted($item);               
  //TODO: for security, check the value before using it.
  return update_plot_option_item($item,$x);   // sets the value
}



//  Update value of a given plot option in the list of options
//
function update_plot_option_item($item,$value){
  global $plot_options;

  // make sure an Object exists for the item in the options array

  if( empty($plot_options) || !array_key_exists($item,$plot_options) ) {
    $plot_options[$item] = new ROOT_Plot_Option;
    $plot_options[$item]->lable = $item;   // (redundant?)
  }       

  // Compare old/new values, implement change if changed

  $old_value = $plot_options[$item]->value;
  if( $value == $old_value ){
    $plot_options[$item]->root_cmd='';
    debug_msg(4,"$item was unchanged: $value");
    return;  // no change
  }
  $plot_options[$item]->set($value);
  return $value;
}


/**
 *  Return the value of a plot option, or empty string if not set.
 */

function get_plot_option($item){
  global $plot_options;

  $v=''; 
  if( !empty($plot_options) && array_key_exists($item, $plot_options) ){
    $v=$plot_options[$item]->value;
  }
  return $v;
}



/**
 * For each plot option which has changed, write to the update file
 * the ROOT commands to apply the change.  An option is known to have
 * changed if there is a ROOT command for changing it.
 */

function apply_plot_options(){
  global $plot_options;
  global $Npens;

  if( empty($plot_options) ) return;

  $Nchanged=0;
  foreach($plot_options as $name => $opt){
    if( !empty($opt->root_cmd) ) {
      $Nchanged++;
      debug_msg(3,"Changed plot option: ".$name);
    }
  }
  debug_msg(4,"apply_plot_options(): $Nchanged items changed");
  if($Nchanged==0) return;  // no changes!


  // open ROOT Update file
  //
  $id0 = uniq_id();
  $update_file=slot_dir()."/".$id0."_update.C";
  $h = fopen($update_file, 'a');
  if(!$h) {
    debug_msg(1,"apply_plot_options() could not open file $update_file.");
    return;
  } 

  $x = "{/* Now apply updates to the previous plot */\n";
  fwrite($h,$x);

  // Common stuff for any update
  //
  $x = "
  //TCanvas* cGDS = (TCanvas*) gROOT->FindObject(\"cGDS\");
  TPad* padT = (TPad*) gROOT->FindObject(\"padT\");
  // TH1*  Pen01 = (TH1*) gROOT->FindObject(\"Pen01\");
";
  fwrite($h, $x);

  $x = "
  padT->Draw();
  padT->cd();
  padT->SetBottomMargin(0.12);
  padT->SetLeftMargin(0.16);
";
  fwrite($h, $x);

  // Apply the options 
  //
  foreach($plot_options as $opt){
    if( !empty($opt->root_cmd) ){
      debug_msg(4,"apply_plot_option():<br>$opt->root_cmd");
      fwrite($h,"  ".$opt->get_update());
    }
  }

  $x = "
  // Pen01->Draw();
  padT->Modified();
  //cGDS->cd();
  //cGDS->Modified();
  //cGDS->SetSelected(cGDS);
";

  fwrite($h,"$x \n}\n");
  fclose($h);
}


/***************************************************\
 * Time axis format:
\***************************************************/

function time_axis_control(){
	global $user_level, $plot_options, $time_input_pref;  // assumed recalled

	if ($user_level <= 1) {
		//no point displaying radio button with one option
  		return;
	} 
  	$buttons['GMT'] = "GMT";
  	$buttons['GPS'] = "GPS";
	if ($user_level>3) { // TODO: decide appropriate level
		$buttons['LCL'] = "Local";   // later...
	}

  	/* Try to use existing value as default */
  
	$selected="GMT";      // default (best guess)

  if( empty($plot_options) || !array_key_exists('time_axis', $plot_options) ){
    $plot_options['time_axis'] = new ROOT_Plot_Option;
    if( !empty($time_input_pref) ) {
      $selected=$time_input_pref;
      debug_msg(6,"Time axis option unset, so default to input pref: " .$time_input_pref);      
    }
    $plot_options['time_axis']->set($selected);
  }
  else{
    $selected=$plot_options['time_axis']->value;
    debug_msg(6,"Time axis option uses previous value: " .$time_input_pref);      
  }

  echo "<div class=\"vindent\"><b>Time Axis:</b><br />";
  echo auto_buttons_from_array('time_axis', $buttons, $selected);
  echo "</div>";
}
        

// Deal with a change in time axis format selection

function handle_time_axis(){
  if( !$x = handle_plot_option_item('time_axis') ) return;
  set_time_axis_root_cmd();
} 


// ROOT command to change the time axis.


function set_time_axis_root_cmd(){
  global $plot_options;

  if($plot_options['time_axis']->value == 'GMT'){
    $root_cmd="
      Pen01->GetXaxis()->SetTimeDisplay(1);
      Pen01->GetXaxis()->SetTimeFormat(\"#splitline{\ \ \ %H:%M}{%d %b %y}\");
      Pen01->GetXaxis()->SetTitle(\"Time (GMT)\");
      Pen01->GetXaxis()->SetNdivisions(510);
      Int_t GPS_epoch = 315964800; 
      Pen01->GetXaxis()->SetTimeOffset(GPS_epoch, \"gmt\" );
      \n";      
  }
  if($plot_options['time_axis']->value == 'GPS'){
    $root_cmd="
      Pen01->GetXaxis()->SetTimeDisplay(0);
      Pen01->GetXaxis()->SetTitle(\"GPS Time (seconds)\");
      Pen01->GetXaxis()->SetNdivisions(1005);
      \n";      
  }
  $plot_options['time_axis']->root_cmd=$root_cmd;
}


/***************************************************\
 * Maximum and Minimum y-values
 */

function max_y_control(){
    global $plot_options;

    $max_y=get_plot_option('max_y');

echo <<<END
    <div class="vindent">
    	<b>Maximum y value:</b><br />&nbsp;&nbsp;<input class="textfield" type="text" name="max_y" size="10" value="$max_y" />
	</div>
END;
}

function handle_max_y(){
    if( !$x = handle_plot_option_item('max_y') ) return;
    set_max_y_root_cmd();  
}

function set_max_y_root_cmd(){
    global $plot_options, $Npens;

    $root_cmd='';
    $x = $plot_options['max_y']->value;
    if( is_numeric($x) ) {

        // Apply to all 'pens'  (remember, they start at 1 not 0)
        //
        for($p=1;$p<=$Npens; $p++){
            $p0 = sprintf("%'02d", $p);    
            $y = 'Pen'.$p0; 
            $root_cmd .="$y" ."->SetMaximum($x);";
        }
        $root_cmd .= "\n";
    }
    $plot_options['max_y']->root_cmd=$root_cmd;
}


function min_y_control(){
    global $plot_options;

    $min_y=get_plot_option('min_y');

echo <<<END
	<div class="vindent">
    	<b>Minimum y value:</b><br/>&nbsp;&nbsp;<input class="textfield" type="text" name="min_y" size="10" value="$min_y" />
    </div>
END;
}


function handle_min_y(){
    if( !$x = handle_plot_option_item('min_y') ) return;
    set_min_y_root_cmd();  
}


function set_min_y_root_cmd(){
    global $plot_options, $Npens;

    $root_cmd='';
    $x = $plot_options['min_y']->value;
    if( is_numeric($x) ) {

        // Apply to all 'pens'  (remember, they start at 1 not 0)
        //
        for($p=1;$p<=$Npens; $p++){
            $p0 = sprintf("%'02d", $p);    
            $y = 'Pen'.$p0; 
            $root_cmd .="$y" ."->SetMinimum($x);";
        }
        $root_cmd .= "\n";
    }
    $plot_options['min_y']->root_cmd=$root_cmd;
}



function autoscale_y_control(){
    echo "<input type='submit' name='autoscale_y' value='Autoscale'>";
}


function handle_autoscale_y(){
    if( !$x = handle_plot_option_item('autoscale_y') ) return;
    debug_msg(2,"Request to autoscale the y axis.");
    set_autoscale_y_root_cmd();
}

function   set_autoscale_y_root_cmd(){
    unset($plot_options['min_y']);
    unset($plot_options['max_y']);
    $plot_options['autoscale_y']->value=1;
    $plot_options['autoscale_y']->root_cmd="/* command here to autoscale */";
}



/***************************************************\
 * Plot Title
\***************************************************/

function plot_title_control(){	// control panel item
  global $plot_options;

  $plot_title=get_plot_option('plot_title');

echo <<<END
	<div class="vindent">
    	<b>Plot title:</b><br/>
    	<input class="textfield" type="text" name="plot_title" size="18" value="$plot_title" />
    </div>
END;
}

function handle_plot_title(){ // handle input from control panel item
  if( !$x = handle_plot_option_item('plot_title') ) return;
  set_plot_title_root_cmd();
}

function set_plot_title_root_cmd(){  // create ROOT cmd to apply change
  global $plot_options;

  $x =  $plot_options['plot_title']->value;
  $x = strtr($x,'"', ' ');	// remove double quotes
  $x = addslashes($x);		// escape other stuff
  $root_cmd="Pen01->SetTitle(\"$x\");\n";
  $plot_options['plot_title']->root_cmd=$root_cmd;
}



/***************************************************\
 * Y - axis properties
\***************************************************/

function y_axis_control(){
    global $plot_options, $user_level;

    $y_axis_title=get_plot_option('y_axis_title');
    $y_log=get_plot_option('y_log');

echo <<<END
	<div class="vindent">
    	<b>Y Axis Label:</b><br/>
    	<input class="textfield" type="text" name="y_axis_title" size="18" value="$y_axis_title"></input><br />
END;

    if( $user_level>1 ){// No Log scale for Beginners
        debug_msg(2,"y_axis_control(): y_log is >$y_log<");
        echo checkbox("y_log", $y_log, "Logarithmic");
    }

    echo "</div>\n";
}


// Deal with a change to y-axsis properties

function handle_y_axis(){
  global $Nplot;

  if( $x = handle_plot_option_item('y_axis_title') ) {
    set_y_axis_title_root_cmd();
  }

  //  an unset Checkbox is meaningful, so set to 'off' instead
 if( !get_posted('y_log') && $Nplot > 1 ) $_POST['y_log']='off';
 //if( $x = handle_plot_option_item('y_log') ) {
 handle_plot_option_item('y_log');
 set_y_log_root_cmd();  
}

function set_y_axis_title_root_cmd(){
  global $plot_options;

  $x=get_plot_option('y_axis_title');
  $x=strtr($x,'"',' ');   // no double quotes
  $x=addslashes($x);
  $root_cmd="Pen01->GetYaxis()->SetTitle(\"$x\");\n";
  $plot_options['y_axis_title']->root_cmd=$root_cmd;
}


function set_y_log_root_cmd(){
  global $plot_options;

  $x = get_plot_option('y_log');
  debug_msg(1, "set_y_log_root_cmd: Logarithmic is $x");
  if($x=='on') {
    $root_cmd  = "Pen01->SetMinimum(1.0);\n  ";
    $root_cmd .= "padT->SetLogy();\n";
  }
  if($x=='off') {
    $root_cmd = "padT->SetLogy(0);\n";
  }
  if( !empty($root_cmd) ){
    $plot_options['y_log']->root_cmd=$root_cmd;
  }
}


/***************************************************\
 * Pen color(s)
\***************************************************/

function pen_color_control(){
  global $plot_options, $Npens;

  debug_msg(6,"pen_color_control(): $Npens pens.");

  $color_list=array(1=>"black",
                    "red","green","blue","yellow","magenta","cyan"); 

  $title="Pen&nbsp;Color";
  if($Npens>1) $title.="s";

  echo "<div class=\"vindent\">";
  echo "<b>".$title.":</b><br/>";

  for($p=1;$p<=$Npens; $p++){
      $p0 = sprintf("%'02d", $p);    

    $item="pen_color_".$p0;
    $n = get_plot_option($item);
    if( empty($n) ) $n=$p;

    echo "&nbsp;&nbsp;$p:";
    echo auto_select_from_array($item, $color_list, $n);
	echo "<br />\n";
  }
  echo "</div>";
}


// Deal with a change to pen color control
//
function handle_pen_color(){  // process user input
    global $plot_options, $Npens;

    for($p=1;$p<=$Npens; $p++){
      $p0 = sprintf("%'02d", $p);    
        $item="pen_color_".$p0;
        if( !$x = handle_plot_option_item($item) ) continue;
        debug_msg(3,"handle_pen_color(Pen$p0): $x");
        if( !is_numeric($x) ) continue;
        set_pen_color_root_cmd($p0,$item);
    }
}

// ROOT commands to apply changes
//
function set_pen_color_root_cmd($p0,$item){  // apply changes
  global $plot_options, $Npens;

  $x = $plot_options[$item]->value;
  $y = 'Pen'.$p0; 
  $root_cmd =$y."->SetLineColor($x);\n";   
  $plot_options[$item]->root_cmd=$root_cmd;
}

?>
