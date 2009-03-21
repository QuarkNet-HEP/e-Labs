#!/usr/bin/perl
use strict;
use warnings;
#
use File::Copy;

sub html(\$ \$ \$) {

  # Start with the header so browsers know it's html
  print "Content-type: text/html\n\n";

  # Toss a random number so as not to overwrite previous results
  my $random = rand();
  $random = int( rand(65535) + 1 );

  # This is the base of the ogre server...
  my $ogre_options = $_[0];

  # We'll need a few of the command line options to know where to move things
  my $cmdl_options = $_[1];

  # This is where we stored out results
  my $tmpval = $cmdl_options->{tempIndex};

  # Define common paths we'll need from the ogre.xml file
  my $resultsDir = $ogre_options->{resultsDir};
  my $donepage = $ogre_options->{htmlOut};
  my $tmpDir   = $ogre_options->{tmpDir};

  my $plotName;
  my $newName;
  my $newPlot  = 1;
  my $oldscriptName = "script-$tmpval.C";

  # Just in case... Make sure we don't overwrite
  # an existing set of results...
  while ( -e "$resultsDir/script-$random.C" ) {
    $random++;
    if ($random>65535) {$random = 0;}
  }
  my $newscriptName = "script-$random.C";

  # Save the URL encoded string that started this run
  move("$tmpDir/study-$tmpval.html", "$resultsDir/study-$random.html");

  if ( $cmdl_options->{type} ) {
    if ( $cmdl_options->{type} eq "png" ) {
      $plotName = "canvas-$tmpval.png";
      $newName  = "canvas-$random.png";
    } elsif ( $cmdl_options->{type} eq "jpg" ) {
      $plotName = "canvas-$tmpval.jpg";
      $newName  = "canvas-$random.jpg";
    } elsif ( $cmdl_options->{type} eq "eps" ) {
      $plotName = "canvas-$tmpval.eps";
      $newName  = "canvas-$random.eps";
    }
  } else {
    $plotName = "canvas-$tmpval.png";
    $newName  = "canvas-$random.png";
  }

  if (-e "$tmpDir/$plotName") {
    move("$tmpDir/$plotName", "$resultsDir/$newName");
    if ( !(-e "$resultsDir/$newName") ) {
      print "<H1><FONT color=\"red\">Unable to copy new histogram!</FONT></H1>\n";
      $newPlot = 0;
    }
  } else {
    print "<H1><FONT color=\"red\">Histograming Failed!</FONT></H1>\n";
    $newPlot = 0;
  }

  if (-e "$tmpDir/$oldscriptName") {
    move("$tmpDir/$oldscriptName", "$resultsDir/$newscriptName");

    if ( !(-e "$resultsDir/$newscriptName") ) {
      print "<H1><FONT color=\"red\">Unable to save ROOT script!</FONT></H1>\n";
    }
  }

  open (DONEFILE, "<$donepage");               # Read in the basic file
  my $outputPage;
  while (my $bytesread = read(DONEFILE, my $buffer, 4096)) {
    $outputPage =  $buffer;
  }

  my $url = $resultsDir;
  #$url =~ s/\/home\//\/~/;
  #$url =~ s/\/public_html//;
  $url =~ s/\/var\/lib\/tomcat5\/webapps//;
  $url = $url . "/$newName";

  if ( $newPlot > 0 ) {
    if ( $cmdl_options->{type} ne "eps" )  {                       # And put up the histogram
      $outputPage =~ s/<!-- Begin PNG Comment//;
      $outputPage =~ s/\/\/ End PNG Comment -->//;
      $outputPage =~ s/placeholder.png/$url/;
    } else {
      $outputPage =~ s/<!-- Begin EPS Comment//;
      $outputPage =~ s/\/\/ End EPS Comment -->//;
      $outputPage =~ s/placeholder.eps/results\/$newName/;
      $outputPage =~ s/placeholder.eps/$url/;
    }
  }

  if ( $cmdl_options->{savedata} ) {

    my $rawData = "$tmpDir/raw-data-$tmpval";
    if ( -e $rawData ) {
      $outputPage =~ s/<!-- Begin RAW Comment//;
      $outputPage =~ s/\/\/ End RAW Comment -->//;

      my $rawPage;
      open(RAWFILE, "<$rawData");
      while (my $bytesread = read(RAWFILE, my $buffer, 4096)) {
	$rawPage = $rawPage . "$rawPage$buffer";
      }

      $outputPage =~ s/readonly>/readonly>\n$rawPage\n/;
      move("$rawData", "$resultsDir/raw-data-$random.txt");
    }
    if ( -e $rawData ) {
      unlink($rawData);
    }
  }

  # Put the results back onto the clients browser
  print "$outputPage\n";

  # Clean up any temporary files we've left sitting around
  if ( -e "$tmpDir/$plotName" ) {
    unlink("$tmpDir/$plotName");
  }
  if ( -e "$tmpDir/$oldscriptName" ) {
    unlink("$tmpDir/$oldscriptName");
  }
  if ( -e "$tmpDir/study-$tmpval.html" ) {
    unlink("$tmpDir/study-$tmpval.html");
  }
  return 0;
}

################################################################################################
return 1;
