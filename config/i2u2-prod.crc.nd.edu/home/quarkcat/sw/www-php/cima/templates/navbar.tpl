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
      <a class="navbar-brand" href="index.php">Back</a>
    </div>

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
      <ul class="nav navbar-nav" style="width: 95%;">
         <?php echo '<li '; if($script==0){ echo 'class="active"';} echo "><a href='fillOut.php'>Events Table (Group ".$_SESSION["groupNo"].")</a></li>";?>
         <?php echo '<li '; if($script==1){ echo 'class="active"';} echo "><a href='hist.php'>Mass Histogram (".$_SESSION["database"].")</a></li>";?>
         <?php echo '<li '; if($script==2){ echo 'class="active"';} echo "><a href='results.php'>Results (".$_SESSION["database"].")</a></li>";?>
	<li style="float: right !important; align : right;"> <a href="https://www.i2u2.org/elab/cms/ispy-webgl/" target="_blank"><span class="glyphicon glyphicon-share-alt"></span> Event Display</a> </li>
      </ul>
    </div><!-- /.navbar-collapse -->
  </div><!-- /.container-fluid -->
</nav>
