use strict;
use warnings;
use Data::Dumper;
use XML::Simple;
use Cwd;

use File::Find;
use LWP::UserAgent;
use HTTP::Headers;

no warnings 'File::Find';

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
  my $xml_hash_ref; # = $_[0];

  # The ogre.xml file is in the same directory as this script.
  my $xmlFile = $_[0]."/ogre.xml";
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
      $xml_hash_ref->{$parameter->{name}} = $parameter->{value};
    }
  }

  while ( my ($key, $value) = each(%$xml_hash_ref) ) {
    if ( $key !~ /MetaDataSource/i && $key !~ /MAX_PLOTS/i  ) {
      if ( substr($value, 0, 1) ne "/" ) {
	$xml_hash_ref->{$key} = $xml_hash_ref->{'baseDir'} . "/" . $value;
      }
    }
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
sub procXML (\$ \$ \$) {

  # Local variables to hold array elements for checking
  my $tree    = "";
  my $branch  = "";
  my $leaf    = "";
  my $formula = "";

  my $command_line = $_[1];              # Command line hash reference
  my $mysql_data   = $_[2];              # MySQL DB hash reference

  my %return_hash = ();                  # The values to return
  my $return_hash_ref = \%return_hash;   # Reference to the values to return

  my $xml = XML::Simple->new(KeyAttr => []);
  my $xmlDir = $_[0];                    # Where XML files are supposed to be stored
  my $xmlFile = "";                      # Where the XML file is located
  my $xmlData = "";                      # Where to store the raw XML data to be parsed

  my $counter = 0;
  my $DEBUG = $command_line->{DEBUG};

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

  my @runFiles;
  my @variableList;
  my @treeList;
  my @labelXList;
  my @titleList;
  my @labelYList;

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
	    $variableList[$variable] = $b->{name}.".".$l->{name};
	    $treeList[$variable] = $t->{name};
	    $labelXList[$variable] = $l->{labelx};
	    $labelYList[$variable] = $l->{labely};
	    $titleList[$variable] = $l->{title};
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
	  ### There's one leaf use it or use nothing
	  #
	  $xmlleaves[0] = $b->{leaf};
	  $variableList[$variable] = $b->{name}.".".$b->{leaf}->{name};
	  $treeList[$variable] = $t->{name};
	  $labelXList[$variable] = $b->{leaf}->{labelx};
	  $labelYList[$variable] = $b->{leaf}->{labely};
	  $titleList[$variable] = $b->{leaf}->{title};
	  $variable++;
	} else {
	  #
	  ### If the branch has no leaves it's a terminal variable... add it to the plot list
	  foreach $branch (@xmlbranches) {
	    if ( length($branch) <= 0 || $t->{branch}->{name} eq $branch ) {
	      $variableList[$variable] = $b->{name};
	      $treeList[$variable] = $t->{name};
	      $labelXList[$variable] = $b->{labelx};
	      $labelYList[$variable] = $b->{labely};
	      $titleList[$variable] = $b->{title};
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
	  $xmlformulas[$i++] = $f;
	  $variableList[$variable] = $f->{name};
	  $treeList[$variable] = $t->{name};
	  $labelXList[$variable] = $f->{labelx};
	  $labelYList[$variable] = $f->{labely};
	  $titleList[$variable] = $f->{title};
	  $variable++;
	}
      }
    } elsif ($formulas) {

      #
      ### The tree has only one formula -- see if it was requested
      #
      my $id = atoi($t->{formula}->{id}) - 1;
      if ( $formulas & (1<<$id) ) {
	$xmlformulas[0] = $t->{formula};
	$variableList[$variable] = $t->{formula}->{name};
	$treeList[$variable] = $t->{name};
	$labelXList[$variable] = $t->{formula}->{labelx};
	$labelYList[$variable] = $t->{formula}->{labely};
	$titleList[$variable] = $t->{formula}->{title};
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

  if ($DEBUG) {
    # Dump out the list of variables to be plotted... it should be complete at this point
    my $v;
    if ( $variable == 1 ) {
      print "\nPlot request:\n"
    } elsif ( $variable > 1 ) {
      print "\nPlot requests:\n";
    }
    my $i = 0;
    for ($i=0; $i<$variable; $i++) {
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

  # And pass the hash reference back to the main program
  return $return_hash_ref;
} # close sub procXML
################################################################################################

return 1;
