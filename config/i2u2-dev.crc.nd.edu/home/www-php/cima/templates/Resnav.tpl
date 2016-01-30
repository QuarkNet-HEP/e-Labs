<nav class="navbar navbar-default" role="navigation">
  <div class="container-fluid">
    <!-- Brand and toggle get grouped for better mobile display -->
    <div class="navbar-header">
      <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <a class="navbar-brand" href="Classes.php">Back</a>
    </div>

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
      <ul class="nav navbar-nav">
         <?php echo '<li '; if($script==1){ echo 'class="active"';} echo '>';?>
	<?php
		if(isset($_GET["i"])){
			echo '<a href="hist.php?i='.$_GET["i"].'">';
		}else{
			echo '<a href="hist.php">';
		}
		?> Mass Histogram</a></li>
         <?php echo '<li '; if($script==2){ echo 'class="active"';} echo '>';?>
   	<?php
		//print_r($_GET);
		if(isset($_GET["i"])){
			echo '<a href="results.php?i='.$_GET["i"].'">';
		}else{
			echo '<a href="results.php">';
		}
		?> Results </a></li>


        <li class="dropdown">
          <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"><?php 
	if(isset($_GET["i"])){ 
		$ct=GetTableByID($_SESSION["tables"][$_GET["i"]]);
		echo $ct["name"];
	}else{
		echo "All";
	}?> <span class="caret"></span></a>
          <ul class="dropdown-menu" role="menu">
	   <li><a <?php echo 'href="'.$basescript.'">';?> All</a></li>
	    <?php 
	    foreach($_SESSION["tables"] as $i => $t){
		$ct=GetTableByID($t);
            	echo '<li><a href="'.$basescript.'?i='.$i.'">'.$ct["name"].'</a></li>';
	    }
	  ?>
          </ul>
        </li>        </ul>
    </div><!-- /.navbar-collapse -->
  </div><!-- /.container-fluid -->
</nav>
