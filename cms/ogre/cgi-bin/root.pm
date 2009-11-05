package root;
use strict;
use warnings;

use html;

# Define what happens when a new instance of this class is created
sub new {
  my ($class) = @_;

  my $rootsys   = $ogre::ogreXML->getOgreParam('rootsys');
  my $rootbin   = $ogre::ogreXML->getOgreParam('rootBinaryPath');
  my $cutStyle  = $ogre::ogreXML->getOgreParam('activeCut') || "javaapplet";

  if ( !(-e $rootbin) ) {    warn "Unable to find root binary $rootbin!";
    exit 1;
  }
  my $self = {
    _scanlist  => undef,
    _titleList => undef,
    _cutlist   => undef,
    _rootsys   => $rootsys,
    _rootbin   => $rootbin
  };

  bless $self, $class;
  return $self;
}

################################################################################################
# Create a root script based on the choices made on the command line / web page                #
################################################################################################
sub makeRootScript {
  my ($self)= @_;

  # Copy the necessary stuff from the hashes into local variables (easier to read that way)
  my $graphics_options = $ogre::ogreXML->getDataXMLRef();
  my $cmdl_options     = $ogre::cgi->getCGIHashRef();
  my $ogre_options     = $ogre::ogreXML->getOgreXMLRef();

  #
  ### Make sure $ROOTSYS is defined, otherwise root will crash
  #
  if (  !$ENV{ROOTSYS} ) {
    # We've got it from the XML file use it
    if ( $ogre_options->{rootsys} ) {
      $ENV{ROOTSYS} = $ogre_options->{rootsys};
    } else {
      # Oops... well.. see if root is even there
      my $rootsys = `which root`;
      if ( $rootsys ) {
	my @temp = split(/\//, $rootsys);
	$rootsys =~ s/\/$temp[$#temp]//;
	$rootsys =~ s/\/$temp[$#temp-1]//;
	if ($rootsys) {
	  $ENV{ROOTSYS} = $rootsys;
	}
      }
      if ( !$ENV{ROOTSYS} ) {
	die "Unable to set ROOTSYS environment variable!\n";
      }
    }
  }

  my $allonone   = (exists $cmdl_options->{allonone})   ?    $cmdl_options->{allonone}   : 0;
  my $logX       = (exists $cmdl_options->{logX})       ?    $cmdl_options->{logX}       : 0;
  my $logY       = (exists $cmdl_options->{logY})       ?    $cmdl_options->{logY}       : 0;
  my $logZ       = (exists $cmdl_options->{logZ})       ?    $cmdl_options->{logZ}       : 0;
  my $global_cut = (exists $cmdl_options->{global_cut}) ?    $cmdl_options->{global_cut} : "1";
  my $width      = (exists $cmdl_options->{width})      ?    $cmdl_options->{width}      : 800;
  my $height     = (exists $cmdl_options->{height})     ?    $cmdl_options->{height}     : 600;
  my $type       = (exists $cmdl_options->{type})       ?    $cmdl_options->{type}       : "png";
  my $rootbin    = (exists $ogre_options->{rootbin})    ?    $ogre_options->{rootbin}    : "$ENV{ROOTSYS}/bin/root";
  my $tmpdir     = (exists $ogre_options->{tmpDir})     ?    $ogre_options->{tmpDir}     : "/tmp";
  my $savedata   = (exists $cmdl_options->{savedata})   ?    $cmdl_options->{savedata}   : 0;
  my $random     = (exists $cmdl_options->{tempIndex})  ?    $cmdl_options->{tempIndex}  : int( rand(4294967295) + 1 );
  my $mycuts     = (exists $cmdl_options->{mycuts})     ?    $cmdl_options->{mycuts}     : 0;


  # Make sure we're using a supported output type
  if ( $type ne "eps" && $type ne "png" && $type ne "jpg" && $type ne "svg" ) {
    ( $cmdl_options->{DEBUG} ) && warn "Unsupported output! Use eps, png, svg, or jpg: Using png\n";
    $type = "png";
  }


  my @treeList     = ($#{$graphics_options->{trees}}  >= 0 ) ? @{$graphics_options->{trees}}  : ();
  my @colors       = ($#{$cmdl_options->{colors}}     >= 0 ) ? @{$cmdl_options->{colors}}     : ();
  my @cuts         = ($#{$cmdl_options->{cuts}}       >= 0 ) ? @{$cmdl_options->{cuts}}       : ();
  my @variableList = ($#{$graphics_options->{plots}}  >= 0 ) ? @{$graphics_options->{plots}}  : ();
  my @runFiles     = ($#{$graphics_options->{files}}  >= 0 ) ? @{$graphics_options->{files}}  : ();
  my @labelXList   = ($#{$graphics_options->{lblsX}}  >= 0 ) ? @{$graphics_options->{lblsX}}  : ();
  my @labelYList   = ($#{$graphics_options->{lblsY}}  >= 0 ) ? @{$graphics_options->{lblsY}}  : ();
  my @labelZList   = ($#{$graphics_options->{lblsZ}}  >= 0 ) ? @{$graphics_options->{lblsZ}}  : ();
  my @titleList    = ($#{$graphics_options->{title}}  >= 0 ) ? @{$graphics_options->{title}}  : ();

  if ( $mycuts ) {
      if ( $global_cut ) {
	  $global_cut .= "&&$mycuts";
      } else {
	  $global_cut = $mycuts;
      }
  }

  my $variable = $#variableList;
  my $tree;   # Local variable to track the chains we need to build.

  my $scanlist = "";
  my $scancuts = "";

  my $fileHandle;
  my $filePath = "$tmpdir/$random/script.000.C";

  mkdir("$tmpdir/$random", 0777)  || die "Unable to make temp directory $tmpdir/$random: $!\n";
  chmod(0777, "$tmpdir/$random");  # Stoopid fucking perl thinks it know what I want.... X-(
  open($fileHandle, ">$filePath") || die "unable to open $fileHandle: $!\n";

  print $fileHandle "{\n\t/*\n";
  print $fileHandle "\tRun command:\n";
  print $fileHandle "\t  $rootbin -b -q -l -n \\\n";
  print $fileHandle "\t    $filePath\n\t*/\n\n";

  print $fileHandle "\t// Make sure we're starting fresh\n\tgROOT->Reset();\n\tgStyle->SetOptStat(1110);\n\n";
  print $fileHandle "\t// Define the plot size\n\tint width  = $width;\n\tint height = $height;\n\n";
  print $fileHandle "\t// Define a test variable to make sure we didn't cut out";
  print $fileHandle " every event\n\tint test[", $variable+1, "];\n\n";
  print $fileHandle "\t// Define the output file names\n";
  print $fileHandle "\tchar *oFile = \"$tmpdir/$random/canvas.000.$type\";\n\n";
#  print $fileHandle "\tchar *rFile = \"$tmpdir/$random/canvas.000.root\";\n\n";

  $tree = $treeList[0]; # Keep it simple for now... one tree at a time

  # Create a canvas to draw upon, and divide it into enough parts for the number of variables we have
  print $fileHandle "\t// Create a new object to hold the graphics\n";
  ( !$allonone ) && print $fileHandle "\t// and split it into pieces, one for each histogram\n";
  print $fileHandle "\tTCanvas *canvas = new TCanvas(\"c1\",\"\",width,height);\n";

  if ( !$allonone ) {
    if ( $variable == 4 ) {
      print $fileHandle "\tcanvas->Divide(2,2);\n";
    } elsif ( $variable == 5 || $variable ==6 ) {
      print $fileHandle "\tcanvas->Divide(3,2);\n";
    } elsif ( $variable == 7 || $variable ==8 ) {
      print $fileHandle "\tcanvas->Divide(4,2);\n";
    } else {
      print $fileHandle "\tcanvas->Divide(1,",$variable+1,");\n";
    }
  }

  # Create a new chain, and add the requested files to it
  print $fileHandle "\n\t// Create a new chain, and add all the requested data files to it\n";
  print $fileHandle "\tTChain *chain = new TChain(\"$tree\");\n";
  my $i = 0;
  for ($i = 0; $i <= $#runFiles; $i++) {
    print $fileHandle "\tchain->Add(\"".$runFiles[$i]."\");\n";
  }

  # If we have individual cut & global cuts.... stitch 'em together
  if ( length($global_cut) > 0 ) {
    for ( my $v=0; $v<=$variable; $v++ ) {
      if ( exists $cuts[$v] ) {
	if (  $cuts[$v] ne "1" ) {
	  $cuts[$v] = $global_cut . "&&" . $cuts[$v];
	} else {
	  $cuts[$v] = $global_cut;
	}
      } else {
	$cuts[$v] = $global_cut;
      }
    }
  }

  # If this is a log plot... restrict the variable to >0 since log(0) = -inf
  if ( $logX ) {
      for ( my $v=0; $v<=$variable; $v++ ) {
	  if ( exists $cuts[$v] ) {
	      $cuts[$v] .= "&&$variableList[$v]>0";
	  } else {
	      $cuts[$v] = "$variableList[$v]>0";
	  }
      }
  }

  if ( !$allonone ) {              # If we're plotting each histogram on it's own pad.....
    # Run through the variables and pop them onto the canvas
    for ( my $v=0; $v<=$variable; $v++ ) {
      #my $pad = $v + 1;
      # Set the focus to the next pad
      #print $fileHandle "\n\t// Set pad #$pad as active and render the histogram\n";
      #print $fileHandle "\tc1_$pad->cd();\n";

      # Set the focus to the canvas
      print $fileHandle "\n\t// Set the canvas as the active pallette and render the histogram(s)\n";
      print $fileHandle "\tc1->cd();\n";
      print $fileHandle "\tc1->SetBorderMode(0);\n\n";

      # Set the axes to a log plot if requested
      ( $logX ) && print $fileHandle "\tc1->SetLogx();\n";
      ( $logY ) && print $fileHandle "\tc1->SetLogy();\n";
      ( $logZ ) && print $fileHandle "\tc1->SetLogz();\n";

      # Set the histogram fill color
      if ( exists $colors[$v] ) {
	print $fileHandle "\tchain->SetFillColor($colors[$v]);\n";
      } else {
	print $fileHandle "\tchain->SetFillColor(0);\n";
      }

      # Initialize the holding place for the arguments to the Draw() command
      my $draw_options = "\"$variableList[$v]\"";
      $scanlist = $scanlist . $variableList[$v] . ":";

      # Form the selection cuts: Any global cuts + any cuts for this variable and NULL if neither
      if ( exists $cuts[$v] ) {
	#$draw_options = $draw_options . ",\"$cuts[$v]\"";
	$scancuts = $scancuts . "$cuts[$v]" ."&&";
      } #else {
	#$draw_options = $draw_options; . ", NULL, NULL";
      #}

      my $cuts = $scancuts;
      $cuts =~ s/&&$//;

      # Now that we have everything... Put this plot onto the pad
      print $fileHandle "\n\tTString cuts[1];\n"; 
      if ( $cuts ) {
	  print $fileHandle "\tcuts[0] = \"$cuts\";\n";
      }
      print $fileHandle "\ttest[$v] = chain->Draw($draw_options, cuts[0]);\n";
      print $fileHandle "\tif ( !test[$v] ) {\n";
      print $fileHandle "\t  TString lo  = cuts(cuts.First(\">\")+1,3);\n";
      print $fileHandle "\t  TString hi  = cuts(cuts.First(\"<\")+1,3);\n";
      print $fileHandle "\t  float   lof = atof( (const char *)lo );\n";
      print $fileHandle "\t  float   hif = atof( (const char *)hi );\n";
      print $fileHandle "\t  TH1F *htemp = new TH1F(\"htemp\",\"\",100, lof, hif);\n";
      print $fileHandle "\t}\n";

      # And set the titles for the pads
      ( exists $labelXList[$v] ) && print $fileHandle "\thtemp->GetXaxis()->SetTitle(\"$labelXList[$v]\");\n";
      ( exists $labelYList[$v] ) && print $fileHandle "\thtemp->GetYaxis()->SetTitle(\"$labelYList[$v]\");\n";
      ( exists $labelZList[$v] ) && print $fileHandle "\thtemp->GetZaxis()->SetTitle(\"$labelZList[$v]\");\n";

      # For the title... if there was a cut applied stick it on here
      if ( exists $titleList[$v] ) {
	if ( exists $cuts[$v] ) {
	  print $fileHandle "\thtemp->SetTitle(\"$titleList[$v]:$cuts[$v]\");\n";
	} else {
	  print $fileHandle "\thtemp->SetTitle(\"$titleList[$v]\");\n";
	}
      }
    }
  } else {              # Else we're stacking the histograms on top of each other

    print $fileHandle "\n\t// Declare a set of histograms and a stack to plot everything on\n";
    print $fileHandle "\tTH1F *h[",$variable+1,"];\n\tTHStack *stack;\n\n";

    # Set the focus to the canvas
    print $fileHandle "\t// Set the canvas as the active pallette and render the histogram(s)\n";
    print $fileHandle "\tc1->cd();\n";
    print $fileHandle "\tc1->SetBorderMode(0);\n\n";

    print $fileHandle "\t// Set up the cuts array\n";
    my $arraySize = $variable+1;
    print $fileHandle "\tTString cuts[$arraySize];\n\n";

    # Fill in the cuts array if there are existing cuts...
    for ( my $v=0; $v<=$variable; $v++ ) {
	if (exists $cuts[$v] ) {
	    print $fileHandle "\tcuts[$v] = \"$cuts[$v]\";\n";
	}
    }
    print $fileHandle "\n";

    for ( my $v=0; $v<=$variable; $v++ ) {

      # Initialize the holding place for the arguments to the Draw() command
      my $draw_options = "\"$variableList[$v]\"";
      $scanlist = $scanlist . $variableList[$v] . ":";

      # Now that we have everything... Put this plot onto the pad
      print $fileHandle "\t// Render histogram $v onto the canvas\n";
      print $fileHandle "\ttest[$v] = chain->Draw($draw_options, cuts[$v]);\n\n";
      print $fileHandle "\tif ( test[$v] ) {\n";

      # Ceate a new histogram to hold the current canvas
      print $fileHandle "\t  // Create a new histogram to hold the current canvas\n";
      print $fileHandle "\t  h[$v] = new TH1F();\n";
      print $fileHandle "\t  h[$v] = (TH1F *)htemp->Clone();\n";
      print $fileHandle "\t  h[$v]->SetName(\"h$v\");\n";

      # Set the histogram fill color
      if ( exists $colors[$v] ) {
	print $fileHandle "\t  h[$v]->SetFillColor($colors[$v]);\n";
      } else {
	print $fileHandle "\t  h[$v]->SetFillColor(0);\n";
      }

      print $fileHandle "\t}\n\n";
    }

    # Create a new stack and pop all the histograms onto it
    print $fileHandle "\t// Create a new stack and pop the histograms onto it\n";
    print $fileHandle "\t// This way the histograms are all on the same plot\n";
    print $fileHandle "\t// and the scales are adjusted automatically for us\n";
    print $fileHandle "\tstack = new THStack();\n";
    for ( my $v=0; $v<=$variable; $v++ ) {
      print $fileHandle "\t(test[$v]) && stack->Add(h[$v]);\n";
    }
    print $fileHandle "\n";

    print $fileHandle "\t// Clear the canvas, and render the stack\n";
    print $fileHandle "\tcanvas->Clear();\n";
    ( $logX ) && print $fileHandle "\tcanvas->SetLogx();\n";
    ( $logY ) && print $fileHandle "\tcanvas->SetLogy();\n";
    ( $logZ ) && print $fileHandle "\tcanvas->SetLogz();\n";
    print $fileHandle "\n";

    # Make our own title out of all of the stacked plots
    my $title = "";
    for (my $v=0; $v<=$variable; $v++) {
      if ( length($title) == 0 ) {
	if ( exists $cuts[$v] ) {
	  $title = $titleList[$v] . ":" . $cuts[$v];
	} else {
	  $title = $titleList[$v];
	}
      } else {
	if ( exists $cuts[$v] ) {
	  $title = "$title, $titleList[$v]:$cuts[$v]";
	} else {
	  $title = "$title, $titleList[$v]";
	}
      }
    }
    if ( length($title) > 0 ) {
      print $fileHandle "\tstack->SetTitle(\"$title\");\n";
    }
    print $fileHandle "\tgStyle->SetOptStat(0);\n";
    print $fileHandle "\tstack->Draw(\"nostack\");\n\n";

    if ( exists $labelXList[0] || exists $labelYList[0] || exists $labelZList[0] ) {
      print $fileHandle "\t// Set the labels on the axes\n";

      ( exists $labelXList[0] ) && print $fileHandle "\tstack->GetXaxis()->SetTitle(\"$labelXList[0]\");\n";
      ( exists $labelYList[0] ) && print $fileHandle "\tstack->GetYaxis()->SetTitle(\"$labelYList[0]\");\n";
      ( exists $labelZList[0] ) && print $fileHandle "\tstack->GetZaxis()->SetTitle(\"$labelZList[0]\");\n";

      print $fileHandle "\n\t// Since we've got axis labels we have to redraw the plot\n";
      print $fileHandle "\t// (no axes existed until it was drawn in the first place\n";
      print $fileHandle "\t//  so we have to draw it, create the labels, and draw it again)\n";
      print $fileHandle "\tstack->Draw(\"nostack\");\n";
    }

  } ### End if-then-else (!$allonone)

  # Clean up the scan list & cuts
  $scanlist =~ s/:$//;
  $scancuts =~ s/&&$//;

  # Switch the focus to the base canvas, and redraw to finalize the postscript
  print $fileHandle "\n\t// Make the main canvas active, update it, and save it to a file\n";
  print $fileHandle "\tcanvas->cd();\n";
  print $fileHandle "\tcanvas->Update();\n";
  print $fileHandle "\tcanvas->SaveAs(oFile);\n\n";
#  print $fileHandle "\t//canvas->SaveAs(rFile);\n\n";

  # If we're saving the data... put the scan into the script
  if ( $savedata ) {
    print $fileHandle "\n\t// Since we want the actual numbers too, set the scan to show all\n";
    print $fileHandle "\t//  events and dump 'em to stdout. We'll massage it in perl later.\n";
    print $fileHandle "\tchain->SetScanField(chain->GetEntries()+1);\n";
    print $fileHandle "\tchain->Scan(\"$scanlist\",\"$scancuts\");\n";
  }

  # Put in the stuff for the graphical cut analysis
  print $fileHandle "\t// Get a handle to the X-Axis\n";
  if ( !$allonone ) {
    print $fileHandle "\tTAxis *x = new TAxis();\n\tx = htemp->GetXaxis();\n\n";
  } else {
    print $fileHandle "\tTAxis *x = new TAxis();\n\tx = stack->GetXaxis();\n\n";
  }
  print $fileHandle "\t// Get the range information from the plot\n";
  print $fileHandle "\tdouble min = x->GetXmin();\n";
  print $fileHandle "\tdouble max = x->GetXmax();\n\n";

  print $fileHandle "\t// Get the pixel-to-plot coordinate transformations\n";
  print $fileHandle "\tint    pixelMin   = c1->XtoPixel(min);\n";
  print $fileHandle "\tint    pixelMax   = c1->XtoPixel(max);\n";
  print $fileHandle "\tdouble graphMin   = c1->PixeltoX(0);\n";
  print $fileHandle "\tdouble graphMax   = c1->PixeltoX(width);\n";
  print $fileHandle "\tdouble conversion = (graphMax - graphMin)/(double)width;\n\n";

  print $fileHandle "\t// Now output the parameters we'll need to put up the cut page\n";
  print $fileHandle "\tcout << \"file=\"   << \"canvas.000.$type\" << \"\\n\";\n";
  print $fileHandle "\tcout << \"width=\"  << width      << \"\\n\";\n";
  print $fileHandle "\tcout << \"height=\" << height     << \"\\n\";\n";
  print $fileHandle "\tcout << \"xmin=\"   << min        << \"\\n\";\n";
  print $fileHandle "\tcout << \"xmax=\"   << max        << \"\\n\";\n";
  print $fileHandle "\tcout << \"pmin=\"   << pixelMin   << \"\\n\";\n";
  print $fileHandle "\tcout << \"pmax=\"   << pixelMax   << \"\\n\";\n";
  print $fileHandle "\tcout << \"Xcst=\"   << graphMin   << \"\\n\";\n";
  print $fileHandle "\tcout << \"X2px=\"   << conversion << \"\\n\";\n\n";

  # Close out the script & the file
  print $fileHandle "}\n";
  close($fileHandle);
  chmod (0666, $filePath);

  # Save the information for color keys
  my $keyHandle;
  my @imColors = ('','black','red','green','blue','yellow','purple','','','','white');
  open ($keyHandle, ">$tmpdir/$random/key");
  for (my $i=0; $i<=$#titleList; $i++) {
      print $keyHandle "$titleList[$i]," . $imColors[$colors[$i]] . "\n";
  }
  close($keyHandle);
  chmod (0666, "$tmpdir/$random/key");


  # Now that the script is generated... run it :D and whack the script when we're done
#  my $redirect = "/dev/null";
#  if ( $savedata ) {
#    $redirect = "$tmpdir/scan.out";
#  }
#  if ( -e $filePath ) {
#    `$rootbin -b -q -l -n $filePath >$redirect 2>/dev/null;echo $?` || warn "ROOT batch run failed: $!\n";
#  }

  $self->{_titleList} = \@titleList;
  $self->{_cutlist}   = \@cuts;
  $self->{_scanList}  = \$scanlist;

  $self->runRootScript();
  return;
}

############################### Run the script we created above #####################################
sub runRootScript() {
  my ($self) = @_;

  my $rootsys = $self->{_rootsys};
  my $rootbin = $self->{_rootbin};

  if ( !(-e $rootbin) ) {
    warn "Unable to find root binary $rootbin!";
    exit 1;
  }

  # Always set the ROOTSYS environment variable
  # root will choke without it
  $ENV{ROOTSYS} = $rootsys;

  use Switch;
  use File::Copy;

  my $tmpdir  = $ogre::ogreXML->getOgreParam('tmpDir');
  my $random  = $ogre::cgi->getCGIParam('tempIndex');
  my $width   = $ogre::cgi->getCGIParam('width');
  my $height  = $ogre::cgi->getCGIParam('height');
  my $type    = $ogre::cgi->getCGIParam('type');
  my $stacked = $ogre::cgi->getCGIParam('allonone');
  my $gCut    = $ogre::cgi->getCGIParam('global_cut');

  # Make some of the files we'll need to track the user interactions
  my $fileHandle;
  open($fileHandle, ">$tmpdir/$random/cutList");
  print $fileHandle "000\n";
  close($fileHandle);

  open($fileHandle, ">$tmpdir/$random/nodemap");
  print $fileHandle "000=>\n";
  close($fileHandle);

  open($fileHandle, ">$tmpdir/$random/.htaccess");
  print $fileHandle "Options -Indexes -FollowSymLinks -ExecCGI\nDirectoryIndex temp.000.html\n";
  close($fileHandle);

  copy("$tmpdir/../graphics/ogre-thumbnail.$type",  "$tmpdir/$random/ogre-thumbnail.$type");

  # Set the permissions on the new files so we can delete them later on
  chmod(0666, "$tmpdir/$random/cutList");
  chmod(0666, "$tmpdir/$random/nodemap");
  chmod(0666, "$tmpdir/$random/.htaccess");
  chmod(0666, "$tmpdir/$random/ogre-thumbnail.$type");

  # If there's a global cut... stick it into the cutList
  if ( $gCut ) {
      my $cutPath = "$tmpdir/$random/cutList";
      open(CUTS, "<$cutPath");
      my ($list) = <CUTS>;
      close(CUTS);

      chomp($list);
      $list .= ",$gCut";

      open (CUTS, ">$cutPath");
      print CUTS $list, "\n";
      close(CUTS);

      chmod(0666,$cutPath);

  }

  my $filePath = "$tmpdir/$random/script.000.C";
  my @output = `$rootbin -b -l -n -q $filePath 2>/dev/null`;

  chmod(0666,"$tmpdir/$random/canvas.000.$type");

  my $appletData;
  for (my $i=2; $i<=$#output; $i++) {
    chomp($output[$i]);
    my @temp = split(/=/,$output[$i]);

    switch($temp[0]) {
      case "file"   { $appletData->{'file'}   = $temp[1]};
      case "width"  { $appletData->{'width'}  = $temp[1]};
      case "height" { $appletData->{'height'} = $temp[1]};
      case "xmin"   { $appletData->{'xmin'}   = $temp[1]};
      case "xmax"   { $appletData->{'xmax'}   = $temp[1]};
      case "pmin"   { $appletData->{'pmin'}   = $temp[1]};
      case "pmax"   { $appletData->{'pmax'}   = $temp[1]};
      case "Xcst"   { $appletData->{'Xcst'}   = $temp[1]};
      case "X2px"   { $appletData->{'X2px'}   = $temp[1]};
    }
  }

  $width  = $appletData->{'width'};
  $height = $appletData->{'height'};

  my @cuts      = ($#{$self->{_cutlist}}   >= 0 ) ? @{$self->{_cutlist}}   : ();
  my @titleList = ($#{$self->{_titleList}} >= 0 ) ? @{$self->{_titleList}} : ();

  my $savedata = 0; #$ogre::cgi->getCGIParam('savedata');
  my $redirect = "/dev/null";
#  if ( $savedata ) {
#    $redirect = "$tmpdir/scan.out";
#  }

  my $scanlist = $self->{_scanlist};

  # Clean up the output dump if we're saving the data
  if ( $savedata && -e $redirect ) {
    my $rawdata = `cat $redirect`;

    # Get rid of the header & trailer crap
    $rawdata =~ s/Warning.+\n//g;
    $rawdata =~ s/Processing.+\n\*{20,}\n\*\s+Row.+\*.+\n//g;
    $scanlist =~ s/:/,/g;
    $rawdata =~ s/\*{20,}/$scanlist/;
    $rawdata =~ s/\*{20,}\n==>.+\n//;

    # Now, process lines containing the actual data
    $rawdata =~ s/\*\n/\n/g;
    $rawdata =~ s/\* +\n//g;
    $rawdata =~ s/^\n$//g;
    $rawdata =~ s/\*\s{2,}\d+\s\*\s//g;
    $rawdata =~ s/\s\*\s/,/g;
    $rawdata =~ s/,\s+/,/g;
    $rawdata =~ s/^\s+//g;

    open (RAWOUT, ">$tmpdir/raw-data-$random");
    print RAWOUT $rawdata;
    close (RAWOUT);
  }
  if ( -e $redirect ) {
    unlink($redirect);
  }

  # Take the labels axis labels apart and get the units
  my $graphics_options = $ogre::ogreXML->getDataXMLRef();
  my @labelXList   = ($#{$graphics_options->{lblsX}}  >= 0 ) ? @{$graphics_options->{lblsX}}  : ();

  my $units = "";
  foreach my $label (@labelXList) {
      $label =~ m/\((.*)\)/;            # Units *should* be in parantheses
      if ( $1 ) {
	  if ( !($units =~ m/$1/) ) {
	      $units .= "$1,";
	  }
      }
  }
  $units =~ s/,,/,/g;
  chop($units);

  $width     = $ogre::cgi->getCGIParam('width');
  $height    = $ogre::cgi->getCGIParam('height');
  $random    = $ogre::cgi->getCGIParam('tempIndex');
  $type      = $ogre::cgi->getCGIParam('type');
  $stacked   = $ogre::cgi->getCGIParam('allonone');
  $tmpdir    = $ogre::ogreXML->getOgreParam('tmpDir');

  my $baseDir   = $ogre::ogreXML->getOgreParam('baseDir'); #"/home/ogre/public_html/";
  my $urlPath   = $ogre::cgi->getCGIParam('URL');
  my $verbose   = $ogre::cgi->getCGIParam('DEBUG');
  my $path      = "$tmpdir/$random";
  my $logX      = $ogre::cgi->getCGIParam('logX') || 0;
  my $logY      = $ogre::cgi->getCGIParam('logY') || 0;
  my @variables = @{$graphics_options->{plots}};


################################# Massage the image a bit ##############################################
  my $image=Image::Magick->new;
  my $imageFile = "$tmpdir/$random/canvas.000.$type";

  $image->Read("$type:$imageFile");

  # Get the "draft" overlay
  my $draft = Image::Magick->new;
  $draft->Read("png:$baseDir/graphics/draft.png");

  # Scale the "draft" image to the correct size
  if ( $width != 640 ) {
      $draft->Scale(width=>$width, height=>$height);
  }

  # Get the width/height from the image since ROOT 
  # tends to shrink by 6% or so
  ($width,$height) = $image->Get('width','height');

  # Alter the image file with dislaimers & such
  my $err;

  if ( -e "$path/key" ) {
      open(KEY, "<$path/key");
      my @keys = <KEY>;
      close(KEY);

      my $vertPos = 100;
      foreach my $key (@keys) {
	  my ($plotTitle, $color) = split(/,/,$key);
	  $err = $image->Annotate(font=>'Generic.ttf', pointsize=>'16',
				  fill=>$color, text=>$plotTitle,
				  scale=>'1', x=>0.667*$width, y=>$vertPos);
          warn $err if $err;
          $vertPos += 20;
      }
  }
  $err = $image->Composite(image=>$draft);
  warn $err if $err;

  $image->Write("$type:$imageFile");
##########################################################################################################

  my $html = new html($width,  $height,  $tmpdir, 
		      $random, $type,    $stacked, 
		      $path,   $urlPath, $verbose, 1,
		      $logX,   $logY,    $units, @variables);

  # Call the routines in the HTML class to make the necessary output pages
  $html->makeActivePage("temp.000.html", "000", $appletData);
  $html->makeHistoryPage(undef, 0, $titleList[0], ("000=>"));

  # Once the pages are made... redirect the browser to the new directory
  # to continue the study
  $html->redirectPage();

  return;
}
################################################################################################


return 1;
