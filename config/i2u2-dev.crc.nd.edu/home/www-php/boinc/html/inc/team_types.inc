<?php

require_once("../inc/forum.inc");


$team_types = array(
    "None",
    "Unclassified",
    "Elementary School",
    "Middle School",
    "High School",
    "School District",
    "Community College",
    "Private College",
    "University",
    "State Agency",
    "Government Laboratory",
     "Company",
);


function team_type_name($num) {
    global $team_types;
    if( $num>0 && $num< count($team_types) ) {
        return $team_types[$num];
    }
    return "Unknown";
}


function is_valid_team_type($name) {
    global $team_types;
    foreach ($team_types as $type) {
        if ($name == $type) return true;
    }
    return false;
}

function team_type_select($team){
    global $team_types;

    if(!empty($team)) $type=$team->type;
    else     $type = 1;
 
    return select_from_array('type', $team_types, $type);
}


?>
