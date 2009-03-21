#!/usr/bin/perl

use Getopt::Long;
use warnings;
use strict;

################################################################################################
# Process the command line arguments -- Long version                                           #
################################################################################################
sub procCMDLong () {

  # If an argument was passed in of the form -X<value> split it into two
  my $i=0;
  for ($i=0; $i<=$#ARGV; $i++) {

    if (substr($ARGV[$i], 0, 1) eq "-" && substr($ARGV[$i],1,1) ne "-" && length($ARGV[$i]) > 2) {
      # This is a short form argument without a space.
      # Now we have to add an extra argument to the entire array
      my $j;
      for ($j=$#ARGV+1; $j>$i+1; $j--) {
	$ARGV[$j] = $ARGV[$j-1];
      }
      $ARGV[$i+1] = substr($ARGV[$i], 2, length($ARGV[$i])-2);
      $ARGV[$i] = substr($ARGV[$i], 0, 2);
    }
  }

  #
  ### Initialize the hash
  #
  my $cmdl_hash;

  $cmdl_hash->{trees}      = 0;     # Plot variables on tree(s) (Integer bitmask)
  $cmdl_hash->{branches}   = 0;     # Plot variables from branch(es) X (Integer bitmask)
  $cmdl_hash->{leaves}     = 0;     # Plot these variables (Integer bitmask)
  $cmdl_hash->{formulas}   = 0;     # Plot these formulas from the XML file (Integer bitmask)
  $cmdl_hash->{global_cut} = "";    # Cut to apply to every single plot (string -- should be enquoted)
  $cmdl_hash->{savedata}   = 0;     # Should we dump out the raw numbers? (unimplemented)
  $cmdl_hash->{logX}       = 0;     # X-axis log style (boolean)
  $cmdl_hash->{logY}       = 0;     # Y-axis log style (boolean)
  $cmdl_hash->{logZ}       = 0;     # Z-axis log style (boolean)
  $cmdl_hash->{width}      = 800;   # How wide is the graphic (unsigned int)
  $cmdl_hash->{height}     = 600;   # How tall is the graphic (unsigned int)
  $cmdl_hash->{allonone}   = 0;     # Slap everything on one plot? (unimplemented) (boolean)
  $cmdl_hash->{DEBUG}      = 0;     # Print out gobs of useless verbosity? (boolean)
  $cmdl_hash->{type}       = "png"; # What type of graphic should we return? (string: png, jpg, or eps)
  $cmdl_hash->{output}     = "";    # The name of the output image

  # Declare intermediate variables since getopts doesn't
  # do a good job putting arrays into hashes
  my @runNumbers;    # Select files based on run number
  my @runTypes;      # Select files based on beam type
  my @runFiles;      # List of files to plot from (will be chained in the root script)
  my @dataSets;      # Select only runs from particular data sets
  my @xmlFiles;

  # Declare the arrays to hold the variables & associated options for plotting
  my @variableList;
  my @treeList;
  my @labelXList;
  my @titleList;
  my @labelYList;
  my @colors;
  my @cuts;

  #
  ### Handle the options from the command line
  #
  Getopt::Long::Configure ('no_ignore_case');
  GetOptions(                                       # Long form --option or Short form -o
	     'xml-file|X=s@'   => \@xmlFiles,
	     'data-set|d=s@'   => \@dataSets,
	     'run-number|n=s@' => \@runNumbers,
	     'run-type|r=s@'   => \@runTypes,

	     'color|c=s@'      => \@colors,
	     'selection|s=s@'  => \@cuts,

	     'trees|t=i'       => \$cmdl_hash->{trees},
	     'branches|b=i'    => \$cmdl_hash->{branches},
	     'leaves|l=i'      => \$cmdl_hash->{leaves},
	     'formula|f=i'     => \$cmdl_hash->{formulas},

	     'global|g=s'      => \$cmdl_hash->{'global_cut'},
	     'save|S'          => \$cmdl_hash->{savedata},
	     'logx|x'          => \$cmdl_hash->{logX},
	     'logy|y'          => \$cmdl_hash->{logY},
	     'logz|z'          => \$cmdl_hash->{logZ},
	     'allonone|a'      => \$cmdl_hash->{allonone},
	     'type|T=s'        => \$cmdl_hash->{type},
	     'width|w=i'       => \$cmdl_hash->{width},
	     'height|h=i'      => \$cmdl_hash->{height},
	     'output|o=s'      => \$cmdl_hash->{output},

	     'verbose|v'       => \$cmdl_hash->{DEBUG}
	    );
  #
  ### allow comma separated lists on the command line
  #
  # Data selection options
  @xmlFiles   = split(/,/,join(',',@xmlFiles));
  @dataSets   = split(/,/,join(',',@dataSets));
  @runNumbers = split(/,/,join(',',@runNumbers));
  @runTypes   = split(/,/,join(',',@runTypes));

  # Plot options
  @colors     = split(/,/,join(',',@colors));
  @cuts       = split(/,/,join(',',@cuts));

  ( $#xmlFiles   >= 0 ) ? $cmdl_hash->{xmlFile}    = $xmlFiles[0] : 0;
  ( $#dataSets   >= 0 ) ? $cmdl_hash->{dataSets}   = \@dataSets   : 0;
  ( $#runNumbers >= 0 ) ? $cmdl_hash->{runNumbers} = \@runNumbers : 0;
  ( $#runTypes   >= 0 ) ? $cmdl_hash->{runTypes}   = \@runTypes   : 0;

  ( $#colors     >= 0 ) ? $cmdl_hash->{colors}     = \@colors     : 0;
  ( $#cuts       >= 0 ) ? $cmdl_hash->{cuts}       = \@cuts       : 0;

  # Set the switch to tell us that this is a CLI run
  $cmdl_hash->{isCGI} = 0;

  return $cmdl_hash;
}
################################################################################################

return 1;
