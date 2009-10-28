#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use Switch;

use ogreXML;
use archive;
use html;

##################### Start main here ########################
my $query = new CGI;
my @names = $query->param;

# Check for the archive flag before doing anything else
my $archiveStudy = $query->param('archive');
my $finishStudy  = $query->param('finalize');
my $dir          = $query->param('directory');
my $prev         = $query->param('version');
my $min          = $query->param('cutMin');
my $max          = $query->param('cutMax');
my $type         = $query->param('type');
my $stacked      = $query->param('stacked');
my $histVisible  = $query->param('historyVisible');
my $units        = $query->param('units');
my $sessionID    = $query->param('sessionID');

# Grab hold of some of the global stuff we'll be needin
my $ogreXML      = new ogreXML();
my $path         = $ogreXML->getOgreParam('baseDir');
my $archivesDir  = $ogreXML->getOgreParam('archiveDir');
my $resultsDir   = $ogreXML->getOgreParam('resultsDir');
my $tmpDir       = $ogreXML->getOgreParam('tmpDir');
my $urlPath      = $ogreXML->getOgreParam('urlPath');
my $rootsys      = $ogreXML->getOgreParam('rootsys');
my $rootbin      = $ogreXML->getOgreParam('rootBinaryPath');

# Always set the ROOTSYS environment variable
# root will choke without it
$ENV{ROOTSYS} = $rootsys;

#
### Figure out what type of graphics file we're using
#

# Check if we're archiving the study
if ( $archiveStudy || $finishStudy ) {
  use archive;
  my $archive = new archive($dir, $prev, $type);

  if ($archiveStudy) {
    $archive->archiveStudy();
  } else {
    $archive->finalizeStudy();
  }
  exit 0;
}

# If we're here... then the action continues!
# Apply a new cut to the old data.....

# Redefine the $path variable now to point to our temp directory
$path = "$tmpDir/$dir";

my $index = 0;

if ( !$min && !$max ) {
  warn "AAAAAAARRRRRRGGGGGGG! Where'd our cuts go!?!\n";
}

# Find the index of the next version number
my $newVersionName = "$path/canvas.000.$type";
while ( -e $newVersionName ) {
  $newVersionName = sprintf("$path/canvas.%03i.$type", ++$index);
}

open (oldScript, "<$path/script.000.C");
my $newscript = "";
while (my $bytesread = read(oldScript, my $buffer, 1024)) {
  $newscript .=  $buffer;
}
close(oldScript);

# From the original script, get the histogram title...
my @temp1 = split(/\n/, $newscript);
my $plot;
if ( !$stacked ) {
  ($plot) = grep( /htemp->SetTitle/, @temp1);
} else {
  ($plot) = grep( /stack->SetTitle/, @temp1);
}
my @temp2 = split(/\"/, $plot);
$plot = $temp2[1];
($plot) = split(/:/, $plot);

my $logx = ( $newscript =~ m/SetLogx/ );
my $logy = ( $newscript =~ m/SetLogy/ );

# Get whatever was plotted, and the cuts applied
my @oldCutValues = grep( /cuts\[\d+\] = (.*)/, @temp1 );

for ( my $i=0; $i<=$#oldCutValues; $i++ ) {
    $oldCutValues[$i] =~ m/cuts\[\d+\] = (.*);/;
    if ( $1 ) {
	$oldCutValues[$i] = $1;
    }
}

my $oldMin;
my $oldMax;
my @newCutValues = ();

#for ( my $i=0; $i<=$#oldCutValues; $i++ ) {
#    $oldCutValues[$i] =~ m/>(\d+)/;
#    if ( $1 ) {
#	$oldMin = $1;
#	$newCutValues[$i] = $oldCutValues[$i];
#	$newCutValues[$i] =~ s/$oldMin/$min/;
#    }
#    $oldCutValues[$i] =~ m/<(\d+)/;
#    if ( $1 ) {
#	$oldMax = $1;
#	if ( exists $newCutValues[$i] ) {
#	    $newCutValues[$i] =~ s/$oldMax/$max/;
#	} else {
#	    $newCutValues[$i] = $oldCutValues[$i];
#	    $newCutValues[$i] =~ s/$oldMax/$max/;
#	}
#    }

    # Escape some special characters so that the RegExp replace works
#    $oldCutValues[$i] =~ s/\[/\\\[/;
#    $oldCutValues[$i] =~ s/\]/\\\]/;

    # No cut values around to modify :O 
    # probably a first pass with a global cut
#    if ( !$newCutValues[$i] ) {

	# We'll need to extract the variable name(s)
#	my ($variable) = grep( /test\[$i\]/, @temp1);
#	$variable =~ m/chain->Draw\("(.*)"/;
#	$variable = $1;

	### Place holder for dealing with box plots in linearCut.js ###
#	if ( $variable =~ m/:/ ) {
#	    $variable =~ m/.*:(.*)/;
#	    if ( $1 ) {
#		$variable = $1;
#	    }
#	}
	################################################################

	# Look for a global cut... 
#	if ( $oldCutValues[$i] =~ m/==/ ) {
#	    # Global cut... we'll have to append to it
#	    my $tempCut = $oldCutValues[$i];
#	    chop($tempCut);

#	    $newCutValues[$i] = "$tempCut&&$variable<$max&&$variable>$min\"";
#	} else {
	    # No global cut at all.... create a brand new cut for this
#	    $oldCutValues[$i] = "cuts\\[$i\\] = $oldCutValues[$i]";
#	    $newCutValues[$i] = "cuts\[$i\] = \"$variable<$max&&$variable>$min\"";
#	}
#    }

    # Now put the new values of the cuts into the new script
#    $newscript =~ s/$oldCutValues[$i]/$newCutValues[$i]/;
#}


################### Reset the cuts using the database ###################
use MySQL;
my $mysql = new MySQL();
my $selection = $mysql->getSelection($sessionID);
my $globalCut = $mysql->getGlobalCut($sessionID);

if ( $globalCut ) {
    $selection = "$globalCut&&$selection";
}
$selection = "\"$selection\";";

my $oldSelect;
$newscript =~ /.*cuts\[\d+\] = (.*)/;
if ( $1 ) {
    $oldSelect = $1;
    $newscript =~ s/$oldSelect/$selection/ or warn "Unable to update cuts: $!\n";
} else {

    $newscript =~ /(.*TString cuts.*)/;
    $oldSelect = $1;

    $selection = "$oldSelect\n\tcuts\[0\] = $selection\n";

    $oldSelect =~ s/\[/\\[/;
    $oldSelect =~ s/\]/\\]/;

    $newscript =~ s/$oldSelect/$selection/ or warn "Unable to update $!\n";

}
#########################################################################

#### No cuts in the initial file... so we'll have to build them from scratch
#if ( $#oldCutValues == -1 ) {
#    my @cuts;
#    @oldCutValues = grep( /chain->Draw/, @temp1 );
#    for ( my $i=0; $i<=$#oldCutValues; $i++ ) {
#	$oldCutValues[$i] =~ m/Draw."(.*)".*/;
#	if ( $1 ) {

#	    my $variable = $1;
	    ### Place holder for dealing with box plots in linearCut.js ###
#	    if ( $variable =~ m/:/ ) {
#		$variable =~ m/.*:(.*)/;
#		if ( $1 ) {
#		    $variable = $1;
#		}
#	    }
	    ################################################################

#	    push(@cuts, "cuts[$i] = \"$variable>$min&&$variable<$max\";");
#	}
#    }

#    my ($oldCut) = grep( /TString cuts/, @temp1 );
#    $oldCut =~ m/(TString.*)/;
#    $oldCut = $1;

#    my $newCut = $oldCut . "\n\t" . join("\n\t",@cuts);

#    $oldCut =~ s/\[/\\\[/;
#    $oldCut =~ s/\]/\\\]/;
#    $newscript =~ s/$oldCut/$newCut/;
#}

my @array1 = grep( /chain->Draw/, @temp1);
my @plotList = ();
foreach my $draw (@array1) {   
    my @temp3 = split(/\"/, $draw);
    my $var = $temp3[1];
    push(@plotList, $var);
}

(my $graphicWidth) = grep(/int width/, @temp1);
$graphicWidth =~ /^\tint width\s+=\s+(\d{3,4});$/;
$graphicWidth = $1;

(my $graphicHeight) = grep(/int height/, @temp1);
$graphicHeight =~ /^\tint height\s+=\s+(\d{3,4});$/;
$graphicHeight = $1;

my $oldPng = "canvas.000";
my $newPng = sprintf("canvas.%03i",$index);
$newscript =~ s/$oldPng/$newPng/g;

my $scriptName = sprintf("script.%03i.C", $index);
$newscript =~ s/script.000.C/$scriptName/g;

open (newScript, ">$path/$scriptName");
print newScript $newscript;
close(newScript);

chmod(0666, "$path/$scriptName");

my $filePath = "$path/$scriptName";

#
### Run root all over again with the new selection
#
my @output = `$rootbin -b -l -n -q $filePath 2>/dev/null`;

chmod(0666, "$path/$newPng.$type");

#
### Copy back the output of the script to put into the applet
#
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

my $width  = $appletData->{'width'};
my $height = $appletData->{'height'};

### Open the node map & get the relationship between the population nodes
my $filename = "$path/nodemap";

open (MAP, ">>$filename") || warn "Unable to open $filename: $!\n";

printf(MAP "%03i=>%03i\n", $index, $prev);
close(MAP);
my $activeNode = sprintf("%03i", $index);

open (MAP, "<$filename");
my @nodeList = <MAP>;
close(MAP);
chomp(@nodeList);

### Open the historical cut list
my $cutFile = "$path/cutList";
open (CUTS, "<$cutFile");

my @temp = <CUTS>;
chomp(@temp);
close(CUTS);

my $cutList;
foreach my $line (@temp) {

  my @elements = split( /,/, $line);

  if ( $elements[0] ne '' ) {
    if ( $elements[1] ) {
      $cutList->{$elements[0]}->{'base'} = $elements[1];
    }
    if ( $elements[2] ) {
      $cutList->{$elements[0]}->{'min'} = $elements[2];
    }
    if ( $elements[3] ) {
      $cutList->{$elements[0]}->{'max'} = $elements[3];
    }
  }
}

# Add in the current cut...
$cutList->{$activeNode} = {
			base => $cutList->{'000'}->{'base'},
			min  => $min,
			max  => $max
		       };
# And record it in the cut history
open(CUTS, ">>$cutFile");
if ( $cutList->{'000'}->{'base'} ) {
    printf(CUTS "%03i,%s,%.0f,%.0f\n", $activeNode, $cutList->{'000'}->{'base'}, $min, $max);
} else {
    printf(CUTS "%03i,,%.0f,%.0f\n", $activeNode, $min, $max);
}
close(CUTS);

my $html = new html($width, $height,  $tmpDir, 
                    $dir,   $type,    $stacked, 
                    $path,  $urlPath, 0, $histVisible,
                    $logx,  $logy,    $units, @plotList);

# (re)Make the pages the user will need... and redirect the browser to it
$html->makeHistoryPage($cutList, $activeNode, $plot, @nodeList);
$html->makeActivePage("temp.$activeNode.html", $index, $appletData);
$html->redirectPage("temp.$activeNode.html");

exit 0;
