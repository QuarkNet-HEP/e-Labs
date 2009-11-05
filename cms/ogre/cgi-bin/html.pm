package html;
use strict;
use warnings;
#
use File::Copy;
use Image::Magick;
use Data::Dumper;

use ogreXML;
use population;

sub new {
  my ($class, $width, $height, $tmpdir, $random, $type, $stacked, $path, 
      $urlPath, $verbose, $histVisible, $logX, $logY, $units, @leaves) = @_;

  my $xml = new ogreXML();
  my $baseURL = $xml->getOgreParam('urlPath');
  my $baseDir = $xml->getOgreParam('baseDir');

  my $self = { 
    _width   => $width,
    _height  => $height,
    _tmpdir  => $tmpdir,
    _random  => $random,
    _type    => $type,
    _stacked => $stacked,
    _path    => $path,
    _urlPath => $urlPath,
    _verbose => $verbose,
    _hVisble => $histVisible,
    _logx    => $logX,
    _logy    => $logY,
    _units   => $units,
    _leaves  => \@leaves,
    _baseURL => $baseURL,
    _baseDir => $baseDir
	
  };
  bless $self, $class;
  return $self;
}

sub debug() {
  my ($self, $x) = @_;
  $x =~ /(\d+)/ if $x;
  warn "error $1: $x" if "$x" && defined $1;          # print the error message
  return;
}

sub getFiles {

  my ($findType, $directory) = @_;
  my @list = ();
  opendir(DIR, $directory);
  my @files = readdir(DIR);
  closedir(DIR);

  for my $file (@files) {
    $file eq "."  and next;
    $file eq ".." and next;
    $file eq "map.$findType" and next;

    (my $thisType) = reverse(split(/\./,$file));
    ($thisType eq $findType) and push @list, $file;
  }
  chomp(@list);
  return @list;
}

sub archivePage {

  my ($self, $dir) = @_;

  # Start with the header so browsers know it's html
  print "Content-type: text/html\n\n";

  # And announce to the user what session ID we've saved it as so they can get it later
  print "<html>\n<body>\n<H1>Study archived as session ID <font color=red>$dir</font>.";
  print " Please save this ID for future reference.</H1>\n</body>\n</html>\n";

  return;
}

sub finalPage {
  my ($self, $urlPath, $type, $random) = @_;

  my $outputPage = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n";
  $outputPage = $outputPage . "<html>\n";
  $outputPage = $outputPage . "  <META HTTP-EQUIV=\"Pragma\" content=\"no-cache\">\n";
  $outputPage = $outputPage . "  <head>\n";
  $outputPage = $outputPage . "      <title>OGRE - Results</title>\n";
  $outputPage = $outputPage . "  </head>\n";
  $outputPage = $outputPage . "  <body bgcolor=\"white\" onLoad=\"window.focus();\">\n";
  $outputPage = $outputPage . "    <center>\n";

  if ( $type ne "eps" ) {
    $outputPage = $outputPage . "      <img src=$urlPath/canvas-$random.$type>\n";
  } else {
    $outputPage = $outputPage . "      <embed src=$urlPath/canvas-$random.eps width=720 height=480>\n";
  }

  $outputPage = $outputPage . "      <!-- Begin RAW Comment\n";
  $outputPage = $outputPage . "      <H3><A HREF=\"RAWDATA\">Raw Data File</A></H3>\n";
  $outputPage = $outputPage . "      // End RAW Comment -->\n\n";

  $outputPage = $outputPage . "      <BR><input type=\"button\" value=\"close\" onClick=\"javascript:window.close();\">\n";
  $outputPage = $outputPage . "    </center>\n";
  $outputPage = $outputPage . "  </body>\n";
  $outputPage = $outputPage . "</html>\n";

  # Start with the header so browsers know it's html
  print "Content-type: text/html\n\n";

  # Put the results back onto the clients browser
  print "$outputPage\n";

  return;
}

use ogreXML;

sub redirectPage(\$) {
  my ($self, $whichPage) = @_;
  my $xml = new ogreXML();

  #################### Redirect the results page to the temp file we just created ################

  # Start with the header so browsers know it's html
  print "Content-type: text/html\n\n";

  # Get the tmp directory in a url friendly fashion
  my $tmp = $xml->getOgreParam('tmpURL');

  my $url = $self->{_urlPath} . "/$tmp/$self->{_random}/";
  if ( defined($whichPage) ) {
      $url .= $whichPage;
  }
#  $url .= (defined($whichPage)) && "$whichPage" || "index.html";

  my $tmpSite = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n";
  $tmpSite .= "<html>\n";
  $tmpSite .= "<head><meta http-equiv=\"REFRESH\" content=\"0;url=$url\"></head>\n";
  $tmpSite .= "</html>\n";
  print "$tmpSite";

  ################################################################################################

  return;
}

sub makeRestoreURL() {
    my ($self) = @_;

  # Grab a pointer to some of the saved path data for restoring the main page
  my $link;
  my $tmpdir = $self->{_tmpdir};
  my $random = $self->{_random};

  # if this is a first run... then use the existing hashes to form up the restore link
  if ( $ogre::cgi ) {
      my $restore = $ogre::cgi->getCGIHashRef()->{rawURL};
      my $baseDir = $ogre::ogreXML->getOgreParam('baseDir');

      # parse the url dump to get the proper restore path
      my $restore_path = "$tmpdir/$random/url";
  
      open(DUMP, ">$restore_path");
      print DUMP "$restore";
      close(DUMP);
      chmod(0666, "$restore_path");

      # While the full path is helpful for the open/write...
      # a relative path is better for the URL encoding...
      # So strip out the base path from the restore_path
      $restore_path =~ s/$baseDir\///;

      my $restore_url = $restore;

      my @temp = split(/\?/,$restore_url);
      $restore_url = $temp[1];
      $restore_url =~ m/.*(dataset=.*);xmlfile.*/;

      # OK... so these are the parameters we'd need
      # to pass to ogre.php in order to restore this
      # particular study... save 'em....
      my $restore_params = "?$1&restore=$restore_path";

      # Now then... from the split above temp[0] holds the
      # http:// ... part of the url... so massage it to get
      # the redirect url and tack on the restoration parameters
      my $index = index($temp[0], "cgi");
      $link = substr($temp[0], 0, $index) . "ogre.php" . $restore_params;
  } else {
      # Otherwise... we're coming in from applyLinearCut.pl.cgi
      # so just grab the link out of the history file

      # Read in the current history file
      my $histPath = "$tmpdir/$random/history.html";
      open( HIST, "<$histPath");
      my @hist = <HIST>;
      close(HIST);

      # and parse it to get the link
      ($link) = grep( /restore/, @hist);
      $link =~ m/fetch\("(.*)"\);/;
      $link = $1;

      undef @hist;
  }

  return $link;
}

sub makeHistoryPage {

  my ($self, $cutList, $activeNode, $plot, @nodeList) = @_;

  my $tmpdir = $self->{_tmpdir};
  my $random = $self->{_random};
  my $width  = $self->{_width};
  my $height = $self->{_height};
  my $type   = $self->{_type};
  my $DEBUG  = $self->{_verbose};
  my $path   = $self->{_path};
  my $urlPath = $self->{_urlPath};
  my $baseURL = $self->{_baseURL};

  # Get the restore link
  my $restore = $self->makeRestoreURL();

  ##
  ## Start building the graphical cut history
  ##
  my ($node, $parent);
  my @list = ();
  foreach my $entry (@nodeList) {
      ($node, $parent) = split(/=>/,$entry);
      push(@list, $parent . "_" . $node);
  }

  my $population = new population("canvas", $type, @list );
  $population->setActive($activeNode);

  my $active = $population->getActive();

  my $ancestors =
      $population->getLineage($active) if defined $active;

  my $image=Image::Magick->new;
  my $graphicFile = "$path/map.$type";
  my $htmlFile="$path/history.html";
  my $save = 1;
  my $x = 0;

  # Set the initial position & size of the first graphic
  my $X      = 0;
  my $Y      = 0;
  $width     = 64;
  $height    = 48;
  my $geom   = $width . "x" . $height;

  # Get the root node...
  my $rootNode;
  if ( defined($ancestors) ) {
      ($rootNode) = reverse(split(/ /, $ancestors));
  } else {
      $rootNode = "000";
  }

  # And all the descendents thereof...
  my %plotNode = $population->getDescendents($rootNode, $width);

  my $maxX = $plotNode{'max'}->{'x'} + 15;
  my $maxY = $plotNode{'max'}->{'y'} + 2*$height + 20;
  my $size = $maxX . "x" . $maxY;

  # Make a pretty background for the map....
  my $h = $maxY + 50;
  my $w = $maxX + 35;

  # Store it in the $self variable since we'll need it later
  $self->{_histHeight} = $h;
  $self->{_histWidth}  = $w;
  $image = Image::Magick->new;

  # Drop down through the population and place each child in the map
  @list = ();
  @list = getFiles($type, $path);
  @list = sort @list;

  $x = $image->Set(size=>$size);
  $self->debug($x) if $x && $DEBUG;

  $x = $image->Read("xc:#CCCCCC");
  $self->debug($x) if $x && $DEBUG;


  # Write the HTML header to our output HTML file
  open (HTML, ">$htmlFile");

  print HTML "<form id='mapSize'>\n";
  print HTML "  <input type='hidden' id='histWidth'  value=$maxX></input>\n";
  print HTML "  <input type='hidden' id='histHeight' value=$maxY></input>\n";
  print HTML "  <input type='hidden' id='histVisible' value=$self->{_hVisble}></input>\n";
  print HTML "</form>\n";

  print HTML "<img src=\"./map.$type\" border=\"0\" usemap=\"#map\" style=\"position:absolute;\"/>\n";
  print HTML "<map name=\"map\">\n";

  foreach my $node (keys %plotNode) {
      ($node eq "max") and next;
      if ($node > $#list ) {
	  last;
      }
      my ($version, $X, $Y) = ($node, $plotNode{$node}->{'x'}, $plotNode{$node}->{'y'}); #@_;
      my $thumb=Image::Magick->new;
      my $lineColor = "yellow";
      my $strokewidth = 0;
      my $x;

      # If this node is in the ancestor list... make it greenish
      my $thisNode = sprintf("%03i", $version);
      if ( defined($ancestors) ) {
	  if ( $ancestors =~ m/$thisNode/ ) {
	      $strokewidth = 2;
	      if ( $thisNode == $activeNode ) {
		  $lineColor = "lightgreen";
	      } else {
		  $lineColor = "green";
	      }
	  }
      } else {
	  $strokewidth = 2;
	  $lineColor = "lightgreen";
      }

      # Since the root node has no parents... skip it
      if ( $thisNode != $rootNode ) {

	  # Find this nodes parent
	  my $parent = $population->getNodeParent($thisNode);

	  # Plot a line leading from this node to it's parent
	  my $Xp = $plotNode{$parent}->{'x'};
	  my $Yp = $plotNode{$parent}->{'y'};

	  my $x1 = $X  + $width/2;
	  my $x2 = $Xp + $width/2;
	  my $y1 = $Y  + $height/2;
	  my $y2 = $Yp + $height/2;

	  if ( $parent ) {
	      # First along the Y-Axis... 
	      my $pointlist = $x1 . "," . $y1 . " " . $x1 . "," . $y2;
	      $x = $image->Draw(stroke=>$lineColor, primitive=>'line', points=>$pointlist, strokewidth=>$strokewidth);
	      $self->debug($x)if $x && $DEBUG;
	      
	      # Then along X
	      $pointlist = $x1 . "," . $y2 . " " . $x2 . "," . $y2;
	      $x = $image->Draw(fill=>'none', stroke=>$lineColor, primitive=>'line', points=>$pointlist, strokewidth=>$strokewidth);
	      $self->debug($x) if $x && $DEBUG;
	  }
      } elsif (0) {
	  # draw a line back to the OGRE link along X
	  my $x1 = $width/2 + 20;
	  my $x2 = 2*$width - $width/2;
	  my $y1 = 44;
	  my $y2 = 44;

	  $lineColor = "green";

	  my $pointlist = $x1 . "," . $y2 . " " . $x2 . "," . $y2;
	  $x = $image->Draw(fill=>'none', stroke=>$lineColor, primitive=>'line', points=>$pointlist, strokewidth=>$strokewidth);
	  $self->debug($x) if $x && $DEBUG;
      }
  }

  # put in the ogre thumbnail and a link back to the main page.
  my $thumb = Image::Magick->new;
  $x = $thumb->Read("$type:$path/ogre-thumbnail.$type");
  $self->debug($x) if $x && $DEBUG;

  $x = $thumb->Border(width=>'2', height=>'2', bordercolor=>'green');
  $self->debug($x) if $x && $DEBUG;

  $x = $image->Composite(image=>$thumb, compose=>'over', y=>'0', x=>'0'); #y=>'20');
  $self->debug($x) if $x && $DEBUG;
  
  print HTML "  <area shape='rectangle' coords='0000,0000,0032,0024' href='javascript:fetch(\"$restore\");'\n";
  print HTML "    onMouseOver='Tip(\"Stop calling me Shrek!\");' onMouseOut='UnTip();'/>\n";
 
  undef $thumb;

  foreach my $node (keys %plotNode) {
      ($node eq "max") and next;
      if ($node > $#list ) {
	  return;
      }
 
      my ($version, $X, $Y) = ($node, $plotNode{$node}->{'x'}, $plotNode{$node}->{'y'});#@_;
      my $thumb=Image::Magick->new;
      my $x;

      # Read in the image....
      $x = $thumb->Read("$type:$path/$list[$version]");
      $self->debug($x) if $x && $DEBUG;

      # Make it a thumbnail....
      $x = $thumb->Scale(geometry=>$geom);
      $self->debug($x) if $x && $DEBUG;

      # If this node is in the ancestor list... make it greenish
      my $thisNode = sprintf("%03i", $version);
      if ( defined($ancestors) ) {
	  if ( $ancestors =~ m/$thisNode/ ) {
	      if ( $thisNode == $activeNode ) {
		  $x = $thumb->Border(width=>'2', height=>'2', bordercolor=>'lightgreen');
		  $self->debug($x) if $x && $DEBUG;
	      } else {
		  $x = $thumb->Border(width=>'2', height=>'2', bordercolor=>'green');
		  $self->debug($x) if $x && $DEBUG;
	      }
	  }
      } else {
	  $x = $thumb->Border(width=>'2', height=>'2', bordercolor=>'lightgreen');
	  $self->debug($x) if $x && $DEBUG;
      }

      # And composite it on to the background
      $x = $image->Composite(image => $thumb, compose => 'over', x => $X, y => $Y);
      $self->debug($x) if $x && $DEBUG;

      $x = $image->Write("$type:$graphicFile");
      $self->debug($x) if $x && $DEBUG;

      # Make sure the file is deletable by the apache user later on
      chmod(0666, $graphicFile);

      # Write out the results to HTML map file....
      my $coords = sprintf("%04i, %04i, %04i, %04i", $X, $Y, $X+$width, $Y+$height);

      my $cutText = "$plot";
      if ( $cutList ) {

	  if ( $cutList->{$version}->{'base'} ) {
	      $cutText = "$plot : " . $cutList->{$version}->{'base'};
	      if ( $cutList->{$version}->{'min'} ) {
		  $cutText .= " && (" . $cutList->{$version}->{'min'} . " < " . $plot;
	      }
	      if ( $cutList->{$version}->{'max'} ) {
		  $cutText .= " < " . $cutList->{$version}->{'max'} . ")";
	      }
	  } else {
	      if ( $cutList->{$version}->{'min'} ) {
		  $cutText .= "(" . $cutList->{$version}->{'min'} . " < " . $plot;
	      }
	      if ( $cutList->{$version}->{'max'} ) {
		  $cutText .= " < " . $cutList->{$version}->{'max'} . ")";
	      }
	  }
      }
      print HTML "  <area shape='rectangle' coords='$coords' href='javascript:fetch(\"./temp.$version.html\");' onMouseOver='Tip(\"$cutText\");' onMouseOut='UnTip();'/>\n";

      undef $thumb;

  }

  if ( $save ) {
      $x = $image->Write("$type:$graphicFile");
      $self->debug($x) if $x && $DEBUG;
  } else {
      $image->Display(":0.0");
      $self->debug($x) if $x && $DEBUG;
  }

# Write the HTML trailer and close it up
  print HTML "</map>\n";
  close(HTML);

# Make sure we can delete the file later on...
  chmod(0666, "$htmlFile");

# Clean up our mess....
  undef $image;

  return;
}

sub makeActivePage(\$ \%) {
    my ($self, $newFile, $version, $appletData) = @_;

    my $tmpdir  = $self->{_tmpdir};
    my $random  = $self->{_random};
    my $type    = $self->{_type};
    my $stacked = $self->{_stacked};
    my @leaves  = @{$self->{_leaves}};
    my $logx    = $self->{_logx};
    my $logy    = $self->{_logy};
    my $units   = $self->{_units};
    my $baseURL = $self->{_baseURL};

    my $width   = $appletData->{'width'};
    my $height  = $appletData->{'height'};
    my $file    = $appletData->{'file'};
    my $xmin    = $appletData->{'xmin'};
    my $xmax    = $appletData->{'xmax'};
    my $pmin    = $appletData->{'pmin'};
    my $pmax    = $appletData->{'pmax'};
    my $Xcst    = $appletData->{'Xcst'};
    my $X2px    = $appletData->{'X2px'};

    my $hHeight = $self->{_histHeight};
    my $hWidth  = $self->{_histWidth};

    #
    ########################### Create the new web page #############################
    #
    my $fileHandle;
    open($fileHandle, ">$tmpdir/$random/$newFile");

    # And dump the page to the browser
    print $fileHandle "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"";
    print $fileHandle "\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n";
    print $fileHandle "<html xmlns=\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n";
    print $fileHandle "  <head>\n";
    print $fileHandle "    <meta HTTP-EQUIV=\"CACHE-CONTROL\" CONTENT=\"NO-CACHE\">\n";
    print $fileHandle "    <meta HTTP-EQUIV=\"PRAGMA\"        CONTENT=\"NO-CACHE\">\n";
    print $fileHandle "    <title>OGRE Selection</title>\n";
    print $fileHandle "    <link rel=\"stylesheet\" type=\"text/css\" href=\"$baseURL/stylesheets/linearCut.css\"/>\n";
    print $fileHandle "    <link rel=\"shortcut icon\" href=\"$baseURL/graphics/ogre.icon.png\" type=\"image/x-icon\" />\n";

    print $fileHandle "    <script>\n";
    print $fileHandle "      var cuts='";
    print $fileHandle "$leaves[0]>$xmin&&$leaves[0]<$xmax";
    for ( my $i=1; $i<=$#leaves; $i++ ) {
	print $fileHandle "&&$leaves[$i]>$xmin&&$leaves[$i]<$xmax";
    }
    print $fileHandle "';\n";
    print $fileHandle "      var sessionID ='";

    #save the session ID here
    print $fileHandle "$self->{_random}";
    print $fileHandle "';\n";
    print $fileHandle "      var xmlTheme = \"$baseURL/xml/ogre-theme.xml\";\n";
    print $fileHandle "      var baseURL  = \"$baseURL\";\n";
    print $fileHandle "      function fetch(url) {\n";
    print $fileHandle "        parent.location = url;\n";
    print $fileHandle "      }\n\n";
    print $fileHandle "      var replaceTip = 'Replace the selection from \"My Cuts\" with the current selection';\n";
    print $fileHandle "      var appendTip  = 'Append the current selection to the selection from \"My Cuts\"';\n";
    print $fileHandle "      var clearTip   = 'Clear the selection criteria from \"My Cuts\"';\n";
    print $fileHandle "    </script>\n";
    print $fileHandle "    <script type=\"Text/JavaScript\" src=\"$baseURL/javascript/linearCut.js\"></script>\n";
    print $fileHandle "    <script type=\"Text/JavaScript\" src=\"$baseURL/javascript/jsWindowlet.js\"></script>\n";

    print $fileHandle "  </head>\n\n";

    print $fileHandle "  <body onload='javascript:pageLoad();'>\n\n";
    
    print $fileHandle "    <script type=\"Text/JavaScript\" src=\"$baseURL/javascript/wz_tooltip.js\"></script>\n";
    print $fileHandle "    <div class=\"wrapper\" id=\"wrapper\">\n";
    print $fileHandle "    <div class=\"background\" id=\"background\"\n";
    print $fileHandle "         onMouseDown='javascript:bkgClick(event);'>\n";
    print $fileHandle "    </div>\n\n";

    print $fileHandle "    <div class='header' id='header'>\n";
    print $fileHandle "      <div id='buttonWrapperTop'>\n";
    print $fileHandle "    	<input type=SUBMIT   class='button' value='Apply Selection'   onClick='javascript:submitForm(document.forms[\"recut\"]);'/>\n";
    print $fileHandle "    	<input type=BUTTON   class='button' value='Save Current Work' onClick='javascript:archiveStudy(document.forms[\"recut\"]);'/>\n";
    print $fileHandle "    	<input type=BUTTON   class='button' value='Finalize Study'    onClick='javascript:finalizeStudy(document.forms[\"recut\"]);'/>\n\n";

    print $fileHandle "    	<input type=BUTTON   class='rbutton' value='Clear'   onClick='javascript:clearCuts();'\n";
    print $fileHandle "    	  onMouseOver='javascript:Tip(clearTip);' onMouseOut='javascript:UnTip();'/>\n";
    print $fileHandle "    	<input type=BUTTON   class='rbutton' value='Append'  onClick='javascript:appendCuts();'\n";
    print $fileHandle "    	  onMouseOver='javascript:Tip(appendTip);' onMouseOut='javascript:UnTip();'/>\n";
    print $fileHandle "    	<input type=BUTTON   class='rbutton' value='Replace' onClick='javascript:replaceCuts();'\n";
    print $fileHandle "    	  onMouseOver='javascript:Tip(replaceTip);' onMouseOut='javascript:UnTip();'/>\n";
    print $fileHandle "    	<h4 class='hdrTxt'>Selection:&nbsp;</h4>\n\n";

    print $fileHandle "       </div>\n";
    print $fileHandle "     </div> <!-- End of header div -->\n";

    print $fileHandle "    <div id='controls'>\n";
    print $fileHandle "      <form  method=POST action='$baseURL/cgi-bin/applyLinearCut.pl.cgi' id='recut'>\n";
    print $fileHandle "        <input type='hidden' name='cutMin'/>\n";
    print $fileHandle "        <input type='hidden' name='cutMax'/>\n";
    print $fileHandle "        <input type='hidden' name='directory' value='$random'/>\n";
    print $fileHandle "        <input type='hidden' name='version'   value='$version'/>\n";
    print $fileHandle "        <input type='hidden' name='stacked'   value='$stacked'/>\n";
    print $fileHandle "        <input type='hidden' name='type'      value='$type'/>\n";
    print $fileHandle "        <input type='hidden' name='archive'   value='0'/>\n";
    print $fileHandle "        <input type='hidden' name='finalize'  value='0'/>\n\n";

    print $fileHandle "        <input type=SUBMIT   class='button' value='Apply Selection'   onClick='javascript:submitForm(this.form);'/>\n";
    print $fileHandle "        <input type=BUTTON   class='button' value='Save Current Work' onClick='javascript:archiveStudy(this.form);'/>\n";
    print $fileHandle "        <input type=BUTTON   class='button' value='Finalize Study'    onClick='javascript:finalizeStudy(this.form);'/>\n";
    print $fileHandle "      </form>\n\n";

    print $fileHandle "      <br><br><hr width=100%><br>\n";

#    print $fileHandle "      <input type=BUTTON class='button' value='Clear Saved Cuts'  onClick='javascript:clearCuts();'/>\n";
    print $fileHandle "      <input type=BUTTON class='button' value='Selection History' onClick='javascript:hstWin.show();'/>\n\n";
    print $fileHandle "      <input type=BUTTON class='button' value='Show Graph'        onClick='javascript:cutWin.show();'/>\n";

    print $fileHandle "      <!-- Selection for changing themes -->\n";
    print $fileHandle "      <select class='buttons' id='themes'\n";
    print $fileHandle "          onChange='javascript:callMenu(this.options[this.selectedIndex].value);'>\n";
    print $fileHandle "        <option value=0>Select Theme</option>\n";
    print $fileHandle "        <option value=12 selected>&nbsp;&nbsp;Standard</option>\n";
    print $fileHandle "        <option value=13>&nbsp;&nbsp;Simple</option>\n";
    print $fileHandle "      </select>\n\n";

    print $fileHandle "      <br><br><hr width=100%><br>\n\n";

    print $fileHandle "    	<h4 class='winTxt'>Selection:&nbsp;&nbsp;</h4>\n";
    print $fileHandle "    	<input type=BUTTON   class='button' value='Append'  onClick='javascript:appendCuts();'\n";
    print $fileHandle "    	  onMouseOver='javascript:Tip(appendTip);' onMouseOut='javascript:UnTip();'/>\n";
    print $fileHandle "    	<input type=BUTTON   class='button' value='Replace' onClick='javascript:replaceCuts();'\n";
    print $fileHandle "    	  onMouseOver='javascript:Tip(replaceTip);' onMouseOut='javascript:UnTip();'/>\n";
    print $fileHandle "    	<input type=BUTTON   class='button' value='Clear'   onClick='javascript:clearCuts();'\n";
    print $fileHandle "    	  onMouseOver='javascript:Tip(clearTip);' onMouseOut='javascript:UnTip();'/>\n\n";

    print $fileHandle "    	<br><br><hr class='bottomLine' width=100%><br>\n\n";

    print $fileHandle "      <div class='address buttons' id='address'>\n";
    print $fileHandle "        <address><a href=# onClick='javascript:callMenu(8);'>Bug the OGRE</a></address>\n";
    print $fileHandle "      </div>\n";
    print $fileHandle "    </div> <!-- End of controls div -->\n";

    print $fileHandle "    <div id='hist'></div>\n";

    print $fileHandle "      <div id=\"graph\">\n"; 
    print $fileHandle "        <img id='image' src=\"$file\" name=\"canvas\" width='$width'/>\n";
    print $fileHandle "       </div>\n";

    print $fileHandle "     <form name='hiddenInput' id='hiddenInput'>\n";
    print $fileHandle "      <input type='hidden' name='width'  value='$width'/>\n";
    print $fileHandle "      <input type='hidden' name='height' value='$height'/>\n";
    print $fileHandle "      <input type='hidden' name='xmin'   value='$xmin'/>\n";
    print $fileHandle "      <input type='hidden' name='xmax'   value='$xmax'/>\n";
    print $fileHandle "      <input type='hidden' name='pmin'   value='$pmin'/>\n";
    print $fileHandle "      <input type='hidden' name='pmax'   value='$pmax'/>\n";
    print $fileHandle "      <input type='hidden' name='Xcst'   value='$Xcst'/>\n";
    print $fileHandle "      <input type='hidden' name='X2px'   value='$X2px'/>\n";
    print $fileHandle "      <input type='hidden' name='logX'   value='$self->{_logx}'/>\n";
    print $fileHandle "      <input type='hidden' name='logY'   value='$self->{_logy}'/>\n";
    print $fileHandle "      <input type='hidden' name='units'  value='$units'/>\n";
    print $fileHandle "    </form>\n\n";

    print $fileHandle "    <div id='ctlHlp'>\n";
    print $fileHandle "    <H2>Using OGRE Controls</H2>\n";
    print $fileHandle "       <div id=\"text\" class=\"text\">\n";
    print $fileHandle "Use the <i>Apply Selection</i> button to enlarge your previously made selection to fill the x-axis. You can make another selection from this point should you wish to. Clicking the <i>Save Current Work</i> button will allow you to save the work you've done so you can come back to it later. <i>Finalize Study</i> will save your final plot for use in a poster and pack the rest of your work into an archive file. Clicking on <i>Clear Saved Cuts</i> will clear out your selection cuts so you can make another cut to use in while building plots. <i>Selection History</i> will allow you to view a tree of all plots you've made by making selection cuts. This allows you to travel back to any plot you've made. The small ogre icon in the top left corner will also allow you to go back to the initial OGRE windows with your selections intact so that you can make modifications without having to start over\n";
    print $fileHandle "       </div> <!-- End of text div -->\n";
    print $fileHandle "     </div>   <!-- end of ctlhlp div -->\n\n";

    print $fileHandle "    <div id='cuthelp'>\n";
    print $fileHandle "      <H2>Refining Data Selection</H2>\n";
    print $fileHandle "      <div id=\"text\" class=\"text\">\n";
    print $fileHandle "Moving your cursor sideways moves a vertical red line across your plot. This line will indicate the exact x-axis value it is aligned with. You can also use this red line to refine your data selection. If you click and drag across the plot, the red line will highlight a section in pale yellow. The end x-coordinates of the selected section will be shown at the top of the plot. You will be able to work further with this selection if you move to the <i>OGRE Controls</i> window.\n";
    print $fileHandle "       </div> <!-- End of text div -->\n";
    print $fileHandle "     </div>   <!-- end of cuthelp div -->\n\n";

    print $fileHandle "     <div id='footer'>\n";
    print $fileHandle "       <div id='buttonWrapperBtm'>\n";
#    print $fileHandle "         <input type=BUTTON class='button' value='Clear Saved Cuts'  onClick='javascript:clearCuts();'/>\n";
    print $fileHandle "         <input type=BUTTON class='button' value='Selection History' onClick='javascript:hstWin.show();'/>\n";
    print $fileHandle "         <input type=BUTTON class='button' value='Show Graph'        onClick='javascript:cutWin.show();'/>\n\n";
 
    print $fileHandle "         <!-- Selection for changing themes -->\n";
    print $fileHandle "         <select class='buttons' id='themesBtm'\n";
    print $fileHandle "     	        onChange='javascript:callMenu(this.options[this.selectedIndex].value);'>\n";
    print $fileHandle "           <option value=0>Select Theme</option>\n";
    print $fileHandle "           <option value=12 selected>&nbsp;&nbsp;Standard</option>\n";
    print $fileHandle "           <option value=13>&nbsp;&nbsp;Simple</option>\n";
    print $fileHandle "         </select>\n";
    print $fileHandle "       </div>\n";
    print $fileHandle "     </div> <!-- End of Footer DIV -->\n\n";

    print $fileHandle "     <div id='alertdiv'>\n";
    print $fileHandle "       <div id='alerttext'></div>\n";
    print $fileHandle "     </div>\n\n";
    print $fileHandle "  </body>\n";
    print $fileHandle "</html>\n";

    close($fileHandle);

    # Make sure we can delete the file later on...
    chmod(0666, "$tmpdir/$random/$newFile");

    return;
}

################################################################################################
return 1;
