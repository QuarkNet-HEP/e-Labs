package ogreXML;
use strict;
use warnings;
use Data::Dumper;
use XML::Simple;
use Cwd;
use MySQL;
use File::Find;
use LWP::UserAgent;
use HTTP::Headers;

no warnings 'File::Find';

################################################################################################
# Define what happens to a new instance of the class                                           #
################################################################################################
sub new {
  my ($class,$xmlPath) = @_;
  my $ogreXMLRef;

  if ( !$xmlPath ) {
      my $mysql = new MySQL();
      $xmlPath = $mysql->getXMLPath();
      undef $mysql;
      if ( !$xmlPath ) {
	  $xmlPath = "../xml/ogre.xml";
      }
  }
  my $self = {
    _ogreXMLRef  => \$ogreXMLRef,
    _dataXMLRef  => undef
  };
  $ogreXMLRef = read_ogre_xml($xmlPath);

  $self->{_ogreXMLRef} = $ogreXMLRef if defined $ogreXMLRef || undef;
  bless $self, $class;

  return $self;
}

sub getOgreXMLRef {
  my ($self) = @_;
  if ( !(defined($self->{_ogreXMLRef})) ) {
    $self->read_ogre_xml();
  }
  return $self->{_ogreXMLRef} if defined $self->{_ogreXMLRef} || undef;;
}

sub getDataXMLRef {
  my ($self) = @_;

  if ( !(defined($self->{_dataXMLRef})) ) {
    $self->procXML();
  }
  return $self->{_dataXMLRef} if defined $self->{_dataXMLRef} || undef;
}

sub getOgreParam {
  my ($self, $param) = @_;
  return $self->{_ogreXMLRef}->{$param} if defined $self->{_ogreXMLRef}->{$param} || undef;
}

sub getDataParam {
  my ($self, $param) = @_;
  return $self->{_dataXMLRef}->{$param} if defined $self->{_dataXMLRef}->{$param} || undef;
}

sub dumpOgreXML {
  my ($self) = @_;

  if ( !(defined($self->{_ogreXMLRef})) ) {
    $self->read_ogre_xml();
  }

  my $ogre_dump = Dumper($self->{_ogreXMLRef});
  $ogre_dump =~ s/\$VAR1/ogreXML/;

  warn $ogre_dump;

  return;
}

sub dumpDataXML {
  my ($self) = @_;

  if ( !(defined($self->{_dataXMLRef})) ) {
    $self->procXML();
  }
  my $ogre_dump = Dumper($self->{_dataXMLRef});
  $ogre_dump =~ s/\$VAR1/dataXML/;    
  print $ogre_dump;

  return;
}


################################################################################################
# Little routine to convert strings to integers                                                #
################################################################################################
sub atoi {

  # Just to be sure....
  chomp($_[0]);

  my $isNegative = 0;
  my $t = 0;
  if ( index($_[0], "-") == 0 ) {
    $isNegative = 1;
    my @temp = split(/\-/,$_[0]);
    $_[0] = $temp[1];
  }

  foreach my $d (split(//, shift())) {
    $t = $t * 10 + $d;
  }
  if ( $isNegative > 0 ) {
    $t = -1 * $t;
  }
  return $t;

}

################################################################################################
# Bootstrap: Process the ogre.xml file defining basic program constants                        #
################################################################################################
sub read_ogre_xml(\$) {

  my $xml = XML::Simple->new(KeyAttr => []);
  my $data;
  my $xml_hash_ref;
  my $temp_hash_ref;

  # The ogre.xml file is in the same directory as this script.
  my $xmlFile = $_[0];   #."/ogre.xml";
  if ( -e $xmlFile ) {
    $data = $xml->XMLin($xmlFile);
  } else {
    die "Unable to process $xmlFile! $!";
  }

  foreach my $parameter (@{$data->{parameter}}) {
    if ( $parameter->{type} eq "int" || $parameter->{type} eq "integer" ) {

      $xml_hash_ref->{$parameter->{name}} = &atoi($parameter->{value});

      if ( $xml_hash_ref->{$parameter->{name}} <= 0 ) {
	$xml_hash_ref->{$parameter->{name}} = 1;
      }

    } else {

	$temp_hash_ref->{$parameter->{name}} = { 
	    type => $parameter->{type}, 
	    value => $parameter->{value} 
	};
    }

  }


  while ( my $temp = each(%$temp_hash_ref) ) {
      my $value = $temp_hash_ref->{$temp}->{value};
      my $type  = $temp_hash_ref->{$temp}->{type};

      if ( $type eq "relpath" ) {
	  $value = $temp_hash_ref->{baseDir}->{value} . "/" . $value;
      }
      $xml_hash_ref->{$temp} = $value;
  }

  return $xml_hash_ref;

}
################################################################################################

sub get_remote_xml(\$) {
  my $link = $_[0];

  my %options = ();
  my $ua = LWP::UserAgent->new( %options );
  my $request = HTTP::Request->new(GET => $link);

  $ua->timeout(30);
  my $response = $ua->request($request);

  if ( $response->is_success() ) {
    return $response->content;
  } else {
    return 0;
  }

  return;
}

################################################################################################
# Process the data XML file(s)                                                                 #
################################################################################################
sub procXML {
  my ($self) = @_;

  # Local variables to hold array elements for checking
  my $tree    = "";
  my $branch  = "";
  my $leaf    = "";
  my $formula = "";
  
  my $command_line = $ogre::cgi->getCGIHashRef();      # Command line/CGI hash reference
  my $mysql_data   = $ogre::MySQL->getMySQLHashRef();  # MySQL DB hash reference

  my %return_hash = ();                                # The values to return
  my $return_hash_ref = \%return_hash;                 # Reference to the values to return

  my $xml = XML::Simple->new(KeyAttr => []);
  my $xmlDir =  $self->{_ogreXMLRef}->{xmlDir};        # Where XML files are supposed to be stored
  my $xmlFile = "";                                    # Which XML file we're supposed to process
  my $xmlData = "";                                    # Where to store the raw XML data to be parsed

  my $counter = 0;
  my $DEBUG = $command_line->{'DEBUG'};

  # If no XML file was specified we're screwed. So invoke the 
  # default behavior & look in this directory for a data.xml file
  if ( exists $mysql_data->{xml} ) {
    $xmlFile = $xmlDir . "/" . $mysql_data->{xml};
  } elsif (exists $command_line->{"xmlFile"}) {
    $xmlFile = $xmlDir . "/" . $command_line->{"xmlFile"};
  } else {
    # See if a data.xml file exists...
    my $datafile;
    my $pattern  = "data.xml";
    File::Find::find( {wanted => sub {
			 my $file = $_;
			 $file =~ s,/,\\,g;
			 return unless -f $file;
			 return unless $file =~ /$pattern/;
			 return unless !$datafile;
			 $datafile = $File::Find::name;
			 return;
		       }
		      },
		      Cwd::cwd()
		    );

    if ( $datafile ) {
      # Make sure we got what we were after
      die unless -f $datafile;
      die unless $datafile =~ /$pattern/;

      chomp($datafile);
      $command_line->{xmlFile} = $datafile;
      $xmlFile = $datafile;
      ( $DEBUG ) && print "Using XML file $datafile\n";
    }
  }

  if ( !$xmlFile ) {
    die "Unable to find an XML file to read! Choking & dying now...\n";
  }

  # Check the XML file... is it local or remote? Does it exists?
  if ( $xmlFile =~ m/http/ ) {
    $xmlData = &get_remote_xml($xmlFile);
    if ( !$xmlData ) {
      die "Unable to read $xmlFile\n";
    }

  } else {
    if ( !(-e $xmlFile) ) {
      die "No such file $xmlFile\n";
    }
    open (XML, "<$xmlFile") || die "Unable to read $xmlFile: $!\n";
    while ( my $bytes = read(XML, my $buffer, 4096) ) {
      $xmlData = $xmlData . $buffer;
    }
  }

  # Read in the current XML file
  my $data = $xml->XMLin($xmlData);                    # Parsed XML data

  ($DEBUG) && print "Available data from ", $data->{type}, " data set in $xmlFile.\n";

  #
  ### Declare the variables we'll need to parse the XML file... and copy the arrays from 
  ### the command line hashes (ugly, but quick fix for modularizing things)
  #

  my @runNumbers = (exists $command_line->{runNumbers}) ? @{$command_line->{runNumbers}} : ();
  my @runTypes   = (exists $command_line->{runTypes})   ? @{$command_line->{runTypes}}   : ();

  # See what our plot requests looks like....
  # If nothing was specified... we're gonna die
  my $trees      = ($command_line->{trees})    ? $command_line->{trees}    : 0;
  my $branches   = ($command_line->{branches}) ? $command_line->{branches} : 0;
  my $leaves     = ($command_line->{leaves})   ? $command_line->{leaves}   : 0;
  my $formulas   = ($command_line->{formulas}) ? $command_line->{formulas} : 0;

  my @runFiles     = ();
  my @variableList = ();
  my @treeList     = ();
  my @labelXList   = ();
  my @labelYList   = ();
  my @labelZList   = ();
  my @titleList    = ();
  my @unitsList    = ();
  my @idList       = ();

  my $variable = 0;

  # Did we already get the dataset from MySQL?
  if ( exists ( $mysql_data->{files} ) && length ($mysql_data->{files}) > 0 ) {
    # We have at least one root file, copy the file list & skip the dataset from the XML file
    foreach my $file (@{$mysql_data->{files}}) {
      push(@runFiles, $file);
    }

    # See if this dataset has a global selection associated with it
    if ($mysql_data->{selection}) {
      if ( $command_line->{'global_cut'} ) {
	$command_line->{'global_cut'} = $command_line->{'global_cut'} . "&&" .
	  $mysql_data->{selection};
      } else {
	$command_line->{'global_cut'} = $mysql_data->{selection};
      }
    }
    goto(SKIP_XML_DATASETS);
  }

  my @dataset;
  my $set;

  # Test for multiple data sets
  eval { if ( exists ($data->{dataset}[0]) ) {;} };

  if ( !$@ ) {
    #
    ### There are multiple data sets available
    #
    my $i = 0;
    foreach $set (@{$data->{dataset}}) {
      #
      ### If a dataset list was given, only add this if it's on the list
      #
      if ( exists $command_line->{dataSets}[0] ) {

	my $thisset;
	foreach $thisset (@{$command_line->{dataSets}}) {
	  if ( $set->{name} eq $thisset ) {
	    $dataset[$i] = $set;

	    if ( $set->{'global_selection'} ) {
	      if ( $command_line->{'global_cut'} ) {
		$command_line->{'global_cut'} = $command_line->{'global_cut'} . "&&" . 
		  $set->{'global_selection'};
	      } else {
		$command_line->{'global_cut'} = $set->{'global_selection'};
	      }
	    }

	    $i++;
	  }
	}
      } else {
	#
	### If no data set was specified, just add 'em all
	#
	$dataset[$i++] = $set;
      }

    } # end foreach $set (@{$data->{dataset}})

  } else {
    #
    ### There''s only one data set available so we have to use it.
    #
    $dataset[0] = $data->{dataset};
    if ( $dataset[0]->{'global_selection'} ) {
      if ( $command_line->{'global_cut'} ) {
	$command_line->{'global_cut'} = $command_line->{'global_cut'} . "&&" . 
	  $dataset[0]->{'global_selection'};
      } else {
	$command_line->{'global_cut'} = $dataset[0]->{'global_selection'};
      }
    }

  }

  if ( $DEBUG ) {
    my $e;
    print "Using data from dataset(s) ";
    foreach $e (@dataset) {
      print $e->{name}, " located at ", $e->{location}, "\n";
    }
  }

  foreach $set (@dataset) {
    #
    ### Get the file list
    #
    eval { if ( exists ($set->{file}[0]) ) {;} };
    if ( !$@ ) {
      # There are multiple data files listed
      my $e;
      my $i = 0;
      foreach $e (@{$set->{file}}) {

	# If no run selection was given, take 'em all
	if ( $#runNumbers < 0 && $#runTypes < 0 ) {
	  $runFiles[$i++] = $set->{location}."/".$e->{filename};
	} elsif ( $#runNumbers >=0 ) {
	  # Otherwise Check each data file and see if it matches our criteria (-r/-e switches)
	  # First check.... is the request by run number?
	  # Yes.. request is by run number... is this run one of the requested runs?
	  foreach my $run (@runNumbers) {
	    if ( $e->{run} eq $run ) {
	      $runFiles[$i++] = $set->{location}."/".$e->{filename};
	    }
	  }
	} elsif ( $#runTypes >= 0 ) {
	  # If not by number.. is the request by beam type?
	  # If the request is for all of a certain type, 
	  # check this one to see if it's of that type
	  foreach my $beam_type (@runTypes) {
	    if ( $e->{runtype} eq $beam_type ) {
	      # This is one of the requeste beam types... add it to the list
	      $runFiles[$i++] = $set->{location}."/".$e->{filename};
	    }
	  }
	} else {                        # If not by number or type I don't understand. Scream & die.
	  die "Run selection makes no sense! Bailing right now!\n";
	}
      }
    } else {

      # Only one run file... it's pretty much this one by default
      $runFiles[0] = $set->{location}."/".$set->{file}->{filename};
    }
  }

 SKIP_XML_DATASETS:
  # We have our run list, we hope... dump it out on request
  if ( $#runFiles >= 0 ) {
    if ( $DEBUG ) {
      my $run;
      print "in files: ";
      for $run (@runFiles) {
	my @temp = split(/\//, $run);
	print $temp[$#temp], " ";
      }
      print "\n";
    }
  } else {
    #
    ### If there isn't an actual run list at this point. No sense in continuing. Just scream & die
    #
    die "No runs available meeting the selection criteria! Death is imminent!\n";
  }

  #
  ### Test for multiple trees
  #
  my @xmltrees;
  eval { if ( exists ($data->{tree}[0]) ) {;} };

  if ( !$@ ) {
    #
    ### There are multiple trees
    #
    my $e;
    my $i = 0;
    foreach $e (@{$data->{tree}}) {

      if ( $trees != 0 ) {               # If we got specific tree(s) to plot from check if this is them
	my $id = atoi($e->{id}) - 1;
	if ( $trees & 1<<$id ) {
	  $xmltrees[$i++] = $e;
	}
      } else {                           # Otherwise take 'em all.
	$xmltrees[$i++] = $e;
      }
    }

  } else {
    #
    ### Only one tree... we gotta use it
    #
    $xmltrees[0] = $data->{tree};
  }

  if ( $DEBUG ) {
    my $e;
    print "Using tree(s) ";
    foreach $e (@xmltrees) {
      print $e->{name}, " ";
    }
    print "\n";
  }

  #
  ### Now... loop over the trees and check...
  #
  ### the branches....
  my $t;
  foreach $t (@xmltrees) {
    #
    ### Test this tree to see if it has multiple branches
    #
    my @xmlbranches;
    eval { if ( exists ($t->{branch}[0]) ) {;} };

    if ( !$@ ) {
      #
      ### There are multiple branches
      #
      my $b;
      my $i = 0;
      foreach $b (@{$t->{branch}}) {
	
	if ( $branches != 0 ) {           # If we got specific branches to plot from check if this is them
	  my $id = atoi($b->{id}) - 1;
	  if ( $branches & 1<<$id ) {
	    $xmlbranches[$i++] = $b;
	  }
	} else {                          # Otherwise take 'em all.
	  $xmlbranches[$i++] = $b;
	}
      }
    } else {
      #
      ### Only one branch
      #
      if ( $branches != 0 ) {
	my $id = atoi($t->{branch}->{id}) - 1;
	  if ( $branches & 1<<$id ) {
	    $xmlbranches[0] = $t->{branch};
	  }
      } else {                            # Nothing specified. Assume that they want something and take this one
	$xmlbranches[0] = $t->{branch};
      }
    }

    if ( $DEBUG ) {
      print "On tree ", $t->{name}, " using branch(es) ";
      my $b;
      foreach $b (@xmlbranches) {
	print $b->{name}, " ";
      }
      print "\n";
    }

    #
    ### For every extant branch... see if it holds a leaf that we want to plot
    #
    my $b;
    foreach $b (@xmlbranches) {
      my @xmlleaves;
      eval { if ( exists ($b->{leaf}[0]) ) {;} };

      if ( !$@ ) {
	#
	### This branch has multiple leaves on it
	#
	my $l;
	my $i = 0;
	foreach $l (@{$b->{leaf}}) {
	  my $id = atoi($l->{id}) - 1;
	  if ( $leaves & (1<<$id) ) {
	    $xmlleaves[$i++] = $l;

	    my $leaf = $l->{name};
	    if ( $leaf =~ m/:/ ) {   # If we've got a box plot... prepend the branch to each leaf
		$variableList[$variable] = $b->{name}.".".$l->{name};
		$variableList[$variable] =~ s/:/:$b->{name}\./;
	    } else {
		$variableList[$variable] = $b->{name}.".".$l->{name};
	    }
	    $idList[$variable] = $id+1;
	    $treeList[$variable] = $t->{name};
	    $labelXList[$variable] = $l->{labelx};
	    $labelYList[$variable] = $l->{labely};
	    $labelZList[$variable] = $l->{labelz};
	    $titleList[$variable] = $l->{title};
	    $unitsList[$variable] = $l->{units};
	    $variable++;
	  }
	}
      } else {
	#
	### There aren't multiple leaves... are there any?
	#
	eval { if ( exists $b->{leaf} ) {;} };
	
	if ( !$@ ) {
	  #
	  ### There's one leaf see if it's the one we want
	  #
	  my $id = atoi($b->{leaf}->{id}) - 1;
	  if ( $leaves & (1<<$id) ) {

	      $xmlleaves[0] = $b->{leaf};

	      my $leaf = $b->{name};
	      if ( $leaf =~ m/:/ ) {   # If we've got a box plot... prepend the branch to each leaf
		  $variableList[$variable] = $b->{name}.".".$b->{leaf}->{name};
		  $variableList[$variable] =~ s/:/:$b->{name}\./;
	      } else {
		  $variableList[$variable] = $b->{name}.".".$b->{leaf}->{name};
	      }
	      $idList[$variable]     = $id+1;
	      $treeList[$variable]   = $t->{name};
	      $labelXList[$variable] = $b->{leaf}->{labelx};
	      $labelYList[$variable] = $b->{leaf}->{labely};
	      $labelZList[$variable] = $b->{leaf}->{labelz};
	      $titleList[$variable]  = $b->{leaf}->{title};
	      $unitsList[$variable]  = $b->{leaf}->{units};
	      $variable++;
	  }
	} else {
	  #
	  ### If the branch has no leaves it's a terminal variable... add it to the plot list
	  foreach $branch (@xmlbranches) {
	    if ( length($branch) <= 0 || $t->{branch}->{name} eq $branch ) {
	      $variableList[$variable] = $b->{name};
	      $idList[$variable]     = $b->{id};
	      $treeList[$variable]   = $t->{name};
	      $labelXList[$variable] = $b->{labelx};
	      $labelYList[$variable] = $b->{labely};
	      $labelZList[$variable] = $b->{labelz};
	      $titleList[$variable]  = $b->{title};
	      $unitsList[$variable]  = $b->{units};
	      $variable++;
	    }
	  }
	}
      }

      if ( $DEBUG ) {
	if ( $#xmlleaves >= 0 ) {
	  print "On branch ", $b->{name}, " using leaves ";
	  my $l;
	  foreach $l (@xmlleaves) {
	    print $l->{name}, " ";
	  }
	  print "\n";
	}
      }

    } # close foreach $b (@xmlbranches)

    #
    ### and the formulas
    #
    my @xmlformulas;
    eval { if (exists ($t->{formula}[0]) ) {;} };

    if (!$@ && $formulas) {
      #
      ### The tree has multiple formulas
      #
      my $f;
      my $i = 0;
      foreach $f (@{$t->{formula}}) {
	my $id = atoi($f->{id}) - 1;
	if ( $formulas & (1<<$id) ) {
	  $xmlformulas[$i++]       = $f;
	  $variableList[$variable] = $f->{name};
	  $treeList[$variable]     = $t->{name};
	  $labelXList[$variable]   = $f->{labelx};
	  $labelYList[$variable]   = $f->{labely};
	  $labelZList[$variable]   = $f->{labelz};
	  $titleList[$variable]    = $f->{title};
	  $unitsList[$variable]    = $f->{units};
	  $variable++;
	}
      }
    } elsif ($formulas) {

      #
      ### The tree has only one formula -- see if it was requested
      #
      my $id = atoi($t->{formula}->{id}) - 1;
      if ( $formulas & (1<<$id) ) {
	$xmlformulas[0]          = $t->{formula};
	$variableList[$variable] = $t->{formula}->{name};
	$treeList[$variable]     = $t->{name};
	$labelXList[$variable]   = $t->{formula}->{labelx};
	$labelYList[$variable]   = $t->{formula}->{labely};
	$labelZList[$variable]   = $t->{formula}->{labelz};
	$titleList[$variable]    = $t->{formula}->{title};
	$unitsList[$variable]    = $t->{formula}->{units};
	$variable++;
      }
    }

    if ($DEBUG && $#xmlformulas >= 0 ) {
      print "On tree ", $t->{name}, " using formula(s) ";
      my $f;
      foreach $f (@xmlformulas) {
	print $f->{name}, " ";
      }
      print "\n";
    }

  }           # close foreach $t (@xmltrees)

  # At this point we should have a list of variables to plot.. and a list of files to plot from
  # Check and make sure everything is kosher so that the plotting routines later on don't choke.
  if ( $#variableList < 0 ) {
    warn "Nothing to plot! I won't even try to figure this out.\n";
  }

  # See if the user request mathematical operations on the variables
  my @leaf_operations = @{$command_line->{leafOps}};

  my $line = join(' ', @leaf_operations);
  my @order = ();
  while ( $line =~ /leaf(\d+)/ ) {
      push(@order, int($1));
      $line =~ s/leaf\d+/none/;
  }

  # We'd damned well better have the same number of items in each list
  if ( $#idList != $#order ) {
      die "Kicking & screaming!\n";
  }

  # Sort the variable list so it matches the operations order....
  # Slapping up histograms onto a stack is order agnostic, so
  # it doesn't matter which order we found the variables in.
  # But for mathematical operations.... order matters. So fix it

  # Get a mapping of how to reorder the ID list from the XML file
  my %reorder = ();
  for ( my $i=0; $i<=$#order;  $i++ ) {
      for ( my $j=0; $j<=$#idList; $j++ ) {
	  if ( $idList[$j] == $order[$i] ) {
	      $reorder{$j} = $i;
	  }
      }
  }

  # Store things in a temp space....
  my @tempVar    = @variableList;
  my @tempLabelX = @labelXList;
  my @tempLabelY = @labelYList;
  my @tempLabelZ = @labelZList;
  my @tempTitle  = @titleList;
  my @tempID     = @idList;
  my @tempUnits  = @unitsList;

  # Remap all the various ordered stuff we've got hanging around
  while ( my ($key,$value)=each (%reorder) ) {
      $idList[$value] = int($tempID[$key]);

      $variableList[$value] = $tempVar[$key];
      $labelXList[$value]   = $tempLabelX[$key];
      $labelYList[$value]   = $tempLabelY[$key];
      $labelZList[$value]   = $tempLabelZ[$key];
      $titleList[$value]    = $tempTitle[$key];
      $unitsList[$value]    = $tempUnits[$key];
  }

  # Now that things are in proper order... 
  # Put them together into the requested operations
  my @temp = ();
  my $j = 0;
  if ( $#leaf_operations > -1 ) { # If so... we'll have to massage things a bit to get it right

      for ( my $i=0; $i<=$#leaf_operations; $i++ ) {
	  push(@temp,$leaf_operations[$i]);
	  while ( $temp[$#temp] =~ /leaf(\d+)/ ) {
	      $temp[$#temp] =~ s/leaf\d+/$variableList[$j++]/;
	  }
      }

      # Flush the variable list....
      @variableList = ();

      # And replace it with the full on operational list
      @variableList = @temp;

      # And do the same thing for the title(s)
      $j = 0;
      @temp = ();
      for ( my $i=0; $i<=$#leaf_operations; $i++ ) {
	  push(@temp, $leaf_operations[$i]);
	  while ( $temp[$#temp] =~ /leaf/ ) {
	      $temp[$#temp] =~ s/leaf\d+/$titleList[$j++]/;
	  }
      }
      # Flush the variable list....
      @titleList = ();

      # And replace it with the full on operational list
      @titleList = @temp;


      # And do the same thing for the labels
      $j = 0;
      @temp = ();
      for ( my $i=0; $i<=$#leaf_operations; $i++ ) {
	  push(@temp, $leaf_operations[$i]);
	  while ( $temp[$#temp] =~ /leaf/ ) {
	      $temp[$#temp] =~ s/leaf\d+/$labelXList[$j++]/;
	  }
      }
      # Flush the X-axis labels ....
      @labelXList = ();

      # And replace it with the full on operational list
      @labelXList = @temp;

      # Now do that same thing for the units....
      $j = 0;
      @temp = ();
      for ( my $i=0; $i<=$#leaf_operations; $i++ ) {
	  push(@temp, $leaf_operations[$i]);
	  while ( $temp[$#temp] =~ /leaf/ ) {
	      $temp[$#temp] =~ s/leaf\d+/$unitsList[$j++]/;
	  }
      }
      # Flush the units labels ....
      @unitsList = ();

      # And replace it with the full on operational list
      @unitsList = @temp;

      # Scan the request for scatter plots... 
      # which means we'll need to double up on the axis labels
      for ( my $i=0; $i<=$#leaf_operations; $i++ ) {
	  if ( $leaf_operations[$i] =~ /\:/ ) {
	      #print "Found scatter plot at $i\n";
	      #print "Splitting  $labelXList[$i] into \$labelYList[$i]\n";
	      @temp = split(/\:/, $labelXList[$i]);
	      $labelXList[$i] = $temp[0];
	      $labelYList[$i] = $temp[1];
	      $labelZList[$i] = ($temp[2]) ? $temp[2] : undef;

	      # Split up the units as well... and put 'em on each axis
	      @temp = split(/\:/, $unitsList[$i]);
	      $labelXList[$i] .= " ($temp[0])";
	      $labelYList[$i] .= " ($temp[1])";
	      $labelZList[$i] .= ($temp[2]) ? " ($temp[2])" : '';

	  } else {
	      $labelXList[$i] .= " ($unitsList[$i])";
	  }
      }

      # Clean up the lists so they all align
      for ( my $i=$#labelYList; $i>$#variableList; $i-- ) {
	  pop(@labelYList);
	  pop(@labelZList);
	  pop(@treeList);
      }
  }

  # If there's nothing in the Z-axis label list... remove it
  for ( my $i=$#labelZList; $i>=0; $i-- ) {
      if ( !($labelZList[$i]) ) {
	  $labelZList[$i] = '';
      }
  }

  if ($DEBUG) {
    # Dump out the list of variables to be plotted... it should be complete at this point
    if ( !$#variableList ) {
      print "\nPlot request:\n"
    } elsif ( $#variableList > 0 ) {
      print "\nPlot requests:\n";
    }

    for ( my $i=0; $i<=$#variableList; $i++) {
      print "\t", $treeList[$i],":",$variableList[$i],
	" labeled with Title: ", $titleList[$i],
	  " X: ", $labelXList[$i], 
	    " Y: ", $labelYList[$i], "\n";
    }
  }


  # Now build up the list of things we'll need to pass to root for the plotting
  $return_hash_ref->{files} = \@runFiles;
  $return_hash_ref->{trees} = \@treeList;
  $return_hash_ref->{plots} = \@variableList;
  $return_hash_ref->{title} = \@titleList;
  $return_hash_ref->{lblsX} = \@labelXList;
  $return_hash_ref->{lblsY} = \@labelYList;
  $return_hash_ref->{lblsZ} = \@labelZList;
  $return_hash_ref->{units} = \@unitsList;

  # And pass the hash reference back to the main program
  $self->{_dataXMLRef} = $return_hash_ref;

  # If verbosity was requested.... dump out everything here
  ($DEBUG) && $self->dumpDataXML();

  return;
} # close sub procXML
################################################################################################

return 1;
