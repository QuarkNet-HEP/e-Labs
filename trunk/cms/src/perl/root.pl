use strict;
use warnings;

################################################################################################
# Create a root script based on the choices made on the command line                           #
################################################################################################
sub root(\$ \$ \$) {

  # Copy the necessary stuff from the hashes into local variables (easier to read that way)
  my $graphics_options = $_[0];
  my $cmdl_options     = $_[1];
  my $ogre_options     = $_[2];
  
  my $DEBUG = $cmdl_options->{DEBUG};

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
  my $random     = (exists $cmdl_options->{tempIndex})  ?    $cmdl_options->{tempIndex}  : int( rand(65535) + 1 );
  my $output     = ($cmdl_options->{output} ne "")      ?    $cmdl_options->{output}     : "$tmpdir/canvas-$random.$type";

  # Make sure we're using a supported output type
  if ( $type ne "eps" && $type ne "png" && $type ne "jpg" ) {
    ( $cmdl_options->{DEBUG} ) && warn "Unsupported output! Use eps, png, or jpg: Using png\n";
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

  my $variable = $#variableList;
  my $tree;   # Local variable to track the chains we need to build.

  my $scanlist = "";
  my $scancuts = "";

  my $fileHandle;
  my $filePath = "$tmpdir/script-$random.C";
  
  if ($DEBUG) {
  	print "tmpdir: $tmpdir\n"
  }

  open($fileHandle, ">$filePath") || die "unable to open script $fileHandle: $!\n";

  print $fileHandle "{\n\t/*\n";
  print $fileHandle "\tRun command:\n";
  print $fileHandle "\t  $rootbin -b -q -l -n \\\n";
  print $fileHandle "\t    $filePath\n\t*/\n\n";

  print $fileHandle "\t// Make sure we're starting fresh\n\tgROOT->Reset();\n\n";

  $tree = $treeList[0]; # Keep it simple for now... one tree at a time

  # Create a canvas to draw upon, and divide it into enough parts for the number of variables we have
  print $fileHandle "\t// Create a new object to hold the graphics\n";
  ( !$allonone ) && print $fileHandle "\t// and split it into pieces, one for each histogram\n";
  print $fileHandle "\tTCanvas *canvas = new TCanvas(\"c1\",\"\",$width,$height);\n";

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
  if ( length($global_cut) > 0 ) { #&& exists $cuts[$v] ) {
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

  if ( !$allonone ) {              # If we're plotting each histogram on it's own pad.....
    # Run through the variables and pop them onto the canvas
    for ( my $v=0; $v<=$variable; $v++ ) {
      my $pad = $v + 1;

      # Set the focus to the next pad
      print $fileHandle "\n\t// Set pad #$pad as active and render the histogram\n";
      print $fileHandle "\tc1_$pad->cd();\n";

      # Set the axes to a log plot if requested
      ( $logX ) && print $fileHandle "\tc1_$pad->SetLogx();\n";
      ( $logY ) && print $fileHandle "\tc1_$pad->SetLogy();\n";
      ( $logZ ) && print $fileHandle "\tc1_$pad->SetLogz();\n";

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
	$draw_options = $draw_options . ",\"$cuts[$v]\"";
	$scancuts = $scancuts . "$cuts[$v]" . "&&";
      } else {
	$draw_options = $draw_options . ", NULL, NULL";
      }

      # Now that we have everything... Put this plot onto the pad
      print $fileHandle "\tchain->Draw($draw_options);\n";
      # Is this a Root 5 specific thing?
      print $fileHandle "\tTH1F htemp = (TH1F) gPad->GetPrimitive(\"htemp\");\n";

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

    for ( my $v=0; $v<=$variable; $v++ ) {

      # Initialize the holding place for the arguments to the Draw() command
      my $draw_options = "\"$variableList[$v]\"";
      $scanlist = $scanlist . $variableList[$v] . ":";

      # Form the selection cuts: Any global cuts + any cuts for this variable and NULL if neither
      if ( exists $cuts[$v] ) {
	$draw_options = $draw_options . ",\"$cuts[$v]\"";
	$scancuts = $scancuts . "$cuts[$v]" . "&&";
      } else {
	$draw_options = $draw_options . ", NULL, NULL";
      }

      # Now that we have everything... Put this plot onto the pad
      print $fileHandle "\t// Render histogram $v onto the canvas\n";
      print $fileHandle "\tchain->Draw($draw_options);\n\n";

      # Ceate a new histogram to hold the current canvas
      print $fileHandle "\t// Create a new histogram to hold the current canvas\n";
      print $fileHandle "\th[$v] = new TH1F();\n";
      print $fileHandle "\th[$v] = (TH1F *)htemp->Clone();\n";
      print $fileHandle "\th[$v]->SetName(\"h$v\");\n";

      # Set the histogram fill color
      if ( exists $colors[$v] ) {
	print $fileHandle "\th[$v]->SetFillColor($colors[$v]);\n";
      } else {
	print $fileHandle "\th[$v]->SetFillColor(0);\n";
      }

      print $fileHandle "\n";
    }

    # Create a new stack and pop all the histograms onto it
    print $fileHandle "\t// Create a new stack and pop the histograms onto it\n";
    print $fileHandle "\t// This way the histograms are all on the same plot\n";
    print $fileHandle "\t// and the scales are adjusted automatically for us\n";
    print $fileHandle "\tstack = new THStack();\n";
    for ( my $v=0; $v<=$variable; $v++ ) {
      print $fileHandle "\tstack->Add(h[$v]);\n";
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
  print $fileHandle "\tcanvas->SaveAs(\"$output\");\n";

  # If we're saving the data... put the scan into the script
  if ( $savedata ) {
    print $fileHandle "\n\t// Since we want the actual numbers too, set the scan to show all\n";
    print $fileHandle "\t//  events and dump 'em to stdout. We'll massage it in perl later.\n";
    print $fileHandle "\tchain->SetScanField(chain->GetEntries()+1);\n";
    print $fileHandle "\tchain->Scan(\"$scanlist\",\"$scancuts\");\n";
  }

  # Close out the script & the file
  print $fileHandle "}\n";
  close($fileHandle);

  # Now that the script is generated... run it :D and whack the script when we're done
  my $redirect = "/dev/null";
  if ($DEBUG) {
  	$redirect = "$tmpdir/ogre-root-output.txt";
  }
  if ( $savedata ) {
    $redirect = "$tmpdir/scan.out";
  }
  if ( -e $rootbin ) {
	  if ( -e $filePath ) {
	    if ($DEBUG) {
	    	print "Running $rootbin -b -q -l -n $filePath >$redirect\n";
	    }
    	`$rootbin -b -q -l -n $filePath >$redirect 2>&1;echo $?` || warn "ROOT batch run failed: $!\n";
	  }
	  else {
	  	die "Script file missing: $filePath\n"
	  }
  }
  else {
  	  die "Root executable ($rootbin) does not exist\n";
  }

  if ($DEBUG) {
  	print "Root finished\n";
  }
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
  if (!$DEBUG) {
	  if ( -e $redirect ) {
    	unlink($redirect);
	  }
  }

  return $random;
}
################################################################################################

return 1;
