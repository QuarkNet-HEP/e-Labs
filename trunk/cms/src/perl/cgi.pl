#!/usr/bin/perl
use strict;
use warnings;
#
use CGI;
use Cwd;

# Process the post data... produce the same output as command_line.pl
sub cgi(\$ \$) {

  # See if we've been called by CGI
  my $query = new CGI;
  my @names = $query->param;

  # If we got nuttin' no sense goin' further. Give 'em back the same
  ($#names < 1) && return 0;

  my %cgi_hash;
  my $tmpDir  = $_[0];
  my $baseDir = $_[1];
  #
  ### Generate a random number to distinguish temp files
  #
  my $random = rand();
  $random = int( rand(65535) + 1 );
  # Even though we can handle thousnads of simultaneous names.. technically,
  # We all know that when there were only two cars in the state of Kansas, 
  # they collided head on. So check... just to make sure
  while ( -e "$tmpDir/post-$random" ) {
    $random++;
    if ($random>65535) {$random = 0;}
  }
  $cgi_hash{tempIndex} = $random;

  # Save the URL encoded string that was made to produce this run
###  my $url = $query->self_url;

###  my @temp = split(/\?/, $url);
###  $url = $temp[1];

  # Save the page that generated this request
###  &save_state($url, "$tmpDir/study-$random.html",$baseDir); # in save_state.pl

  # If they're there... get the data set to use & the XML file to process
  if ( $query->param("dataset") ) {
    $cgi_hash{dataSets} = $query->param("dataset");
  }

  if ( $query->param("xmlfile") ) {
    $cgi_hash{xmlFile} = $query->param("xmlfile");
  }

  # Decide which variables we're plotting, and how
  my @leaves = $query->param("leaf");
  my $leafmask = 0;
  for ( my $i=0; $i<=$#leaves; $i++ ) {
    $leafmask = $leafmask + (1<<($leaves[$i]-1));
  }
  if ( $leafmask ) {
    $cgi_hash{leaves} = $leafmask;
  }

  my @formula = $query->param("formula");
  my $formmask = 0;
  for ( my $i=0; $i<=$#formula; $i++ ) {
    $formmask = $formmask + (1<<($formula[$i]-1));
  }
  if ( $formmask ) {
    $cgi_hash{formulas} = $formmask;
  }

  #
  ### Set the data to plot
  #
  # See if we're plotting by type of run
  my @runTypes;
  if ( $query->param("all_runs") ) {
    $runTypes[++$#runTypes] = "all";
  }
  if ( $query->param("muon_runs") && $#runTypes >= 0 && $runTypes[0] ne "all" ) {
    $runTypes[++$#runTypes] = "muon";
  }
  if ( $query->param("pion_runs") && $#runTypes >= 0 && $runTypes[0] ne "all" ) {
    $runTypes[++$#runTypes] = "pion";
  }
  if ( $query->param("elec_runs") && $#runTypes >= 0 && $runTypes[0] ne "all" ) {
    $runTypes[++$#runTypes] = "electron";
  }
  if ( $query->param("cal_runs") && $#runTypes >= 0 && $runTypes[0] ne "all" ) {
    $runTypes[++$#runTypes] = "calibration";
  }
  ($#runTypes >= 0) ? $cgi_hash{runTypes} = \@runTypes : ();

  # If not by type... we'd better be plotting by run number
  my @runNumbers;
  if ( $#runTypes < 0 ) {
    @runNumbers = $query->param("run_number");
    ( $#runNumbers >= 0 ) ? $cgi_hash{runNumbers} = \@runNumbers : ();
  }

  # Get the various parameters associated with each variable to be plotted
  ($query->param("logx")) ? $cgi_hash{logX} = 1 : 0;
  ($query->param("logy")) ? $cgi_hash{logY} = 1 : 0;
  ($query->param("logz")) ? $cgi_hash{logZ} = 1 : 0;

  # Set the plot size
  $cgi_hash{width}  = ($query->param("gWidth"))  ? $query->param("gWidth")  : 800;
  $cgi_hash{height} = ($query->param("gHeight")) ?$query->param("gHeight")  : 600;

  # If there are many plots, should they be super imposed?
  $cgi_hash{allonone} = ($query->param("allonone")) ? $query->param("allonone") : 0;

  # Should we save the raw data?
  $cgi_hash{savedata} = ($query->param("savedata")) ? $query->param("savedata") : 0;

  # Set the plot output file type
  $cgi_hash{type} = ($query->param("type")) ? $query->param("type") : "png";

  # Get the histogram fill colors
  my @colors;

  # for the leaves...
  my @colorList = $query->param("color");
  for ( my $i=0; $i<=$#colorList; $i++ ) {
    if ( $leafmask & (1<<$i) ) {
      $colors[++$#colors] = $colorList[$i];
    }
  }

  # And formula...
  my @colorfList = $query->param("colorf");
  for ( my $i=0; $i<=$#colorfList; $i++ ) {
    if ( $formmask & (1<<$i) ) {
      $colors[++$#colors] = $colorfList[$i];
    }
  }

  # Inclue the global cut(s) if any
  $cgi_hash{global_cut} = ( $query->param("gcut") ) ? $query->param("gcut") : "";

  # Add 'em the the return hash
  ($#colors >= 0) ? $cgi_hash{colors} = \@colors : ();

  # And the individual cuts

  # on leaves...
  my @cuttypeList  = $query->param("cuttype");
  my @cutList      = $query->param("cut");
  my @rootleafList = $query->param("root_leaf");
  my @cuts;

  for ( my $i=0; $i<=$#cuttypeList; $i++ ) {
    if ( $leafmask & (1<<$i) ) {

      if ( $cuttypeList[$i] && $cutList[$i] ne "0" ) {
	$cuts[++$#cuts] = $rootleafList[$i];
	if ( $cuttypeList[$i] == 1 ) {
	  $cuts[$#cuts] = $cuts[$#cuts] . ">$cutList[$i]";
	} else {
	  $cuts[$#cuts] = $cuts[$#cuts] . "<$cutList[$i]";
	}
      } else {
	$cuts[++$#cuts] = "1";
      }
    }

  }

  # And formulas...
  my @cutfList = $query->param("cutf");
  for ( my $i=0; $i<=$#cutfList; $i++ ) {
    if ( $formmask & (1<<($i)) ) {
      if ( $cutfList[$i] ) {
	$cuts[++$#cuts] = $cutfList[$i];
      } else {
	$cuts[++$#cuts] = "1";
      }
    }
  }
  $cgi_hash{cuts} = ( $#cuts >= 0 ) ? \@cuts : ();

  # Add in a personal private switch for me when I'm testing
  $cgi_hash{DEBUG} = ($query->param("verbose")) ? $query->param("verbose") : 0;

  # And pop on a switch that indicates that we're processing CGI data
  $cgi_hash{isCGI} = 1;


  # Return the results to the main program
  return \%cgi_hash;
}

################################################################################################
return 1;
