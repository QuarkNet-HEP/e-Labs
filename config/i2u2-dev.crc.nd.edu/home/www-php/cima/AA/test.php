<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);


include '../templates/header.tpl';
echo '<form action="Classes.php" method="post">';
include '../templates/AA.tpl';

echo '<div class=row> <div class=col-md-6> <select name="tselect" size="6"> <option> test </option>';
echo '</select> <F5> </div>';

echo '<div class=col-md-3> <button type="submit" class="btn btn-primary btn-lg" name="changeA">change active status</button> </div>';
echo '<div class=col-md-3> <button type="submit" class="btn btn-primary btn-lg" name="delete">delete</button> </div>';
echo '</form>';
include '../templates/floor.tpl';

?>
