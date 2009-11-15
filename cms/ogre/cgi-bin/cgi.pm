package cgi;
#
use strict;
use warnings;
#
use CGI;
use Cwd;
use MySQL;
use cmdLine;
use parseOps;
use Data::Dumper;

# define what happens what we instantiate a new instance of this class
sub new {
  my ($class) = @_;
  my $self = {
    _cgiHashRef => undef
  };
  bless $self, $class;
  return $self;
}

sub getCGIHashRef {
  my ($self) = @_;
  return $self->{_cgiHashRef} if defined $self->{_cgiHashRef} || undef;
}

sub getCGIParam {
  my ($self, $param) = @_;
  return $self->{_cgiHashRef}->{$param} if defined $self->{_cgiHashRef}->{$param} || undef;
}

#
### Little function to convert decimal numbers to hex
#
sub dec_to_hex {
    my ($dec) = @_;
    my @hex = ( '0', '1', '2', '3', '4', '5',
		'6', '7', '8', '9', 'a', 'b', 
		'c', 'd', 'e', 'f' );

    my $h = $hex[($dec%16)];
    $dec /= 16;
    while ( $dec >= 1 ) {
        $h = $hex[($dec%16)] . $h;
        $dec /= 16;
    }
   
    return $h;
}

# If this is a verbose run, dump the hashes to the terminal
sub dumpCGI {
  my ($self) = @_;

  # Since there's no way to know if this is 
  # a verbose run when ogreXML is created
  # Dump it out here if we're doing a DEBUG run
  $ogre::ogreXML->dumpOgreXML();

  my $cmdl_dump = Dumper($self->{_cgiHashRef});
  $cmdl_dump =~ s/\$VAR1/cmdLine/;

  warn $cmdl_dump;

  return;
}

# Process the post data... 
sub procCGI {
  my ($self) = @_;

  # See if we've been called by CGI
  my $query = new CGI;
  my @names = $query->param;

  if ( $#names < 1 ) {                                   # If no CGI query was found,
    my $cmdLine = new cmdLine();                         # try the command line
    my $cgi_hash = $cmdLine->getCmdlHashRef();           # located in cmdLine.pm

    # And pop on a switch that indicates that we're processing CGI data
    $cgi_hash->{isCGI} = 0;

    # Save a pointer to the hash data
    $self->{_cgiHashRef} = $cgi_hash;

    if ( $cgi_hash->{DEBUG} ) {
      $self->dumpCGI();
    }
    return;
  }

  my %cgi_hash;

  my $tmpDir  = $ogre::ogreXML->getOgreParam('tmpDir');
  my $baseDir = $ogre::ogreXML->getOgreParam('baseDir');

  my $resultsDir;
  my $archiveDir;

  if ( !$tmpDir || !$baseDir ) {
    my $ogreXML = new ogreXML();
    $tmpDir     = $ogreXML->getOgreParam('tmpDir');
    $baseDir    = $ogreXML->getOgreParam('baseDir');
    $resultsDir = $ogreXML->getOgreParam('resultsDir');
    $archiveDir = $ogreXML->getOgreParam('archiveDir');
  } else {
    $resultsDir = "$baseDir/results";
    $archiveDir = "$baseDir/archives";
  }

  #
  ### Check for the sessionID to distinguish temp files
  #
  my $random = 0;
  my $sessionID = $query->param("sID");
  if ( $sessionID ) {
      $random = $sessionID;
  }

  #
  ## If there was no session ID passed in... just toss a long random number
  ## and convert (them) to a hex character string (so it matches up with the
  ## session ID from the web page.

  if ( !$random ) {
      my $decimal;
      my $hex = "";
      for ( my $i=0; $i<4; $i++ ) {
	  $decimal = 100000000 + int(rand(999999999));
	  $hex .= $self->dec_to_hex($decimal);
      }
      $random = $hex;
  }

  # Even though we can handle billions of simultaneous names.. technically,
  # We all know that when there were only two cars in the state of Kansas, 
  # they collided head on. So check... just to make sure
  while ( -d "$tmpDir/$random" || -f "$resultsDir/script-$random.C" || -f "$archiveDir/study-$random.tar.gz" ) {
      # And if this directory already exists... get a new, random 32 character hex number
      my $decimal;
      my $hex = "";
      for ( my $i=0; $i<4; $i++ ) {
	  $decimal = 100000000 + int(rand(999999999));
	  $hex .= $self->dec_to_hex($decimal);
      }
      $random = $hex;
  }

  # Was there a session ID? And did we have to change it to avoid collisions?
  if ( $random ne $sessionID ) {
      my $db = new MySQL();          # Yup... update the DB with the new sessionID
      $db->updateSettingsDB($sessionID, $random);
      undef $db;
      $sessionID = $random;
  }

  $cgi_hash{tempIndex} = $random;

  # Save the URL encoded string that was made to produce this run
  my $url = $query->unescape($query->self_url);

  # Save the raw parameter string so we can restore the session if need be
  # (dumped out to a restore file in the tmp directory in html.pm)
  $cgi_hash{rawURL} = $url;

  my @temp = split(/\?/, $url);
  $url = $temp[1];

  $temp[0] =~ s/cgi-bin\/ogre.pl.cgi//;
  $cgi_hash{URL} = $temp[0];

  # If they're there... get the data set to use & the XML file to process
  if ( $query->param("dataset") ) {
    $cgi_hash{dataSets} = $query->param("dataset");
  }

  if ( $query->param("xmlfile") ) {
    $cgi_hash{xmlFile} = $query->param("xmlfile");
  }

  # Decide which variables we're plotting, and how
  @temp = $query->param("leaf");              # Get the request leaves to plot
  my $parser = new parseOps(@temp);           # Create a parser to deal with math operations

  my @leaves  = $parser->extractLeaves();     # Extract the individual leaf numbers (for ogreXML)

  my $leafmask = 0;
  for ( my $i=0; $i<=$#leaves; $i++ ) {
      if ( $leaves[$i] =~ /\d+/ ) {
	  $leafmask = $leafmask + (1<<($leaves[$i]-1));
      }
  }

  if ( $leafmask ) {
    $cgi_hash{leaves} = $leafmask;
  }

  @leaves = $parser->parse();                 # Now parse the full request and save it for when we get the ROOT names
  ($#leaves > -1) ? $cgi_hash{leafOps} = \@leaves : ();


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
  # See if we're selecting by type of run (really only a TB thing)
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

  # If not by type... are we selecting by run number?
  my @runNumbers;
  if ( $#runTypes < 0 ) {
    @runNumbers = $query->param("run_number");
    ( $#runNumbers >= 0 ) ? $cgi_hash{runNumbers} = \@runNumbers : ();
  }

  # See if we've done selection by trigger
  my @triggers;
  my @containers;
  my %logic = ();
  my $selection;

  if ( $query->param('triggers') ) {               # If so... assemble the trigger selection logic
      @triggers = $query->param('triggers');       # for use in MySQL.pm later on
      @containers = $query->param('holders');
      for (my $i=0; $i<=$#triggers; $i++) {
	  # Trigger logic.... DragContainer11 => OR
	  #                   DragContainer12 => AND
	  #                   DragContainer13 => XOR
	  #                   DragContainer15 => NOR
	  #                   DragContainer16 => NAND
	  #                   DragContainer17 => NXOR
	  if      ( $containers[$i] =~ m/^DragContainer11$/ ) {
	      $logic{OR} .= $triggers[$i] . ",";
	  } elsif ( $containers[$i] =~ m/^DragContainer12$/ ) {
	      $logic{AND} .= $triggers[$i] . ",";
	  } elsif ( $containers[$i] =~ m/^DragContainer13$/ ) {
	      $logic{XOR} .= $triggers[$i] . ",";
	  } elsif ( $containers[$i] =~ m/^DragContainer15$/ ) {
	      $logic{NOR} .= $triggers[$i] . ",";
	  } elsif ( $containers[$i] =~ m/^DragContainer16$/ ) {
	      $logic{NAND} .= $triggers[$i] . ",";
	  } elsif ( $containers[$i] =~ m/^DragContainer17$/ ) {
	      $logic{NXOR} .= $triggers[$i] . ",";
	  }
      }
  }

  for my $key ( keys %logic ) {
      chomp($logic{$key});     # Take out a trailing \n if it's there
      chop($logic{$key});      # Chop off the trailing ","
      
      if ( $key =~ m/^N/ ) {
	  $key =~ m/^N(\w{2,3})/;
	  my $conditional = $1;
	  $logic{$key} =~ s/,/ $conditional /g;
      } else {
	  $logic{$key} =~ s/,/ $key /g;
      }
      $logic{$key} = ($logic{$key}) ? "(" . $logic{$key} . ")" : "";
  }  

  if ($logic{OR} || $logic{AND} || $logic{XOR}) {
      $selection = "(";
      $selection .= ($logic{OR})  ? $logic{OR}  . " AND " : "";
      $selection .= ($logic{AND}) ? $logic{AND} . " AND " : "";
      $selection .= ($logic{XOR}) ? $logic{XOR} : "";
      $selection =~ s/ AND $//;
      $selection .= ")";
  }
  if ($logic{NOR} || $logic{NAND} || $logic{NXOR}) {
      $selection .= ($selection) ? " AND NOT (" : "NOT (";
      $selection .= ($logic{NOR})  ? $logic{NOR}  . " AND " : "";
      $selection .= ($logic{NAND}) ? $logic{NAND} . " AND " : "";
      $selection .= ($logic{NXOR}) ? $logic{NXOR} : "";
      $selection =~ s/ AND $//;
      $selection .= ")";
  }
  # And save the trigger selector in the hash
  $cgi_hash{triggers} = ($selection) ? $selection : "";

  # Get the various parameters associated with each variable to be plotted
  ($query->param("logx")) ? $cgi_hash{logX} = 1 : 0;
  ($query->param("logy")) ? $cgi_hash{logY} = 1 : 0;
  ($query->param("logz")) ? $cgi_hash{logZ} = 1 : 0;

  # Set the plot size
  $cgi_hash{width}  = ($query->param("gWidth"))  ? $query->param("gWidth")   : 800;
  $cgi_hash{height} = ($query->param("gHeight")) ? $query->param("gHeight")  : 600;

  # Plots are automagically stacked... but scatter plots don't work with ROOTs' TStack
  # So for scatter plots we have to do a few different things
  $cgi_hash{stacked} = ($query->param("stacked")) ? $query->param("stacked") : 0;

  # Should we save the raw data?
  $cgi_hash{savedata} = ($query->param("savedata")) ? $query->param("savedata") : 0;

  # Set the plot output file type
  $cgi_hash{type} = ($query->param("type")) ? $query->param("type") : "png";

  # Get the histogram fill colors
  my @colors = $query->param("color");

  # Consolidate the colors.... If there are more colors than
  # plots (easily possible since there could be many quantities that
  # go into a single plot now), arbitrarily take the first color 
  # as the color for the plot
  if ( $#colors > $#leaves ) {
      my $temp;
      my $colormap;
      my $j=0;
      for ( my $i=0; $i<=$#leaves; $i++ ) {
	  $temp = $leaves[$i];
	  while ( $temp =~ /leaf/ ) {
	      $temp =~ s/leaf/none/;
	      $colormap .= "$colors[$j++],";
	  }
	  ($colors[$i]) = split(/,/, $colormap);
	  $colormap = "";
      }
      for ( my $i=$#colors; $i>$#leaves; $i-- ) {
	  pop(@colors);
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

  $cgi_hash{rootLeaves} = \@rootleafList; 

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

  # See if the user is requesting a general selection
  my $db = new MySQL();
  if ( $query->param('mycuts') ) {
      $cgi_hash{mycuts} = $db->getSelection($sessionID);
      $db->setApplySavedCuts($sessionID);
  } else {
      $db->unsetApplySavedCuts($sessionID);
  }
  undef $db;


  # Add in a personal private switch for me when I'm testing
  $cgi_hash{DEBUG} = ($query->param("verbose")) ? $query->param("verbose") : 0;

  # And pop on a switch that indicates that we're processing CGI data
  $cgi_hash{isCGI} = 1;

  # Save a pointer to the hash data
  $self->{_cgiHashRef} = \%cgi_hash;

  if ( $cgi_hash{DEBUG} ) {
    $self->dumpCGI();
  }

  # Return the results to the main program
  return;
}

################################################################################################
return 1;
