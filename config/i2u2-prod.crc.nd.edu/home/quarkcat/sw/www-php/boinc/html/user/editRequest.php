<?php
ini_set('display_errors',1);

$to = "peronja@fnal.gov";
$subject = "Testing email";
$message = "You will laugh at your success";

$mail=mail($to, "Subject: $subject",$message );
if($mail){
 echo "success";
  }else{
 echo "failed."; 
  }


?>
