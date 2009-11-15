#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use Switch;

use ogreXML;
use archive;
use html;
use MySQL;

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

my $numberOfCuts = 0;
$newscript =~ /.*TString cuts\[(\d+)\].*/;
if ( $1 ) {
    $numberOfCuts = $1;
}

# Get whatever was plotted, and the cuts applied
my @oldCutValues = grep( /cuts\[\d+\] = (.*)/, @temp1 );

for ( my $i=0; $i<=$#oldCutValues; $i++ ) {
    $oldCutValues[$i] =~ m/cuts\[\d+\] = (.*);/;
    if ( $1 ) {
	$oldCutValues[$i] = $1;
    }
}

################### Reset the cuts using the database ###################
my $mysql = new MySQL();

# Get the dataset the user is working with for annotating the image later on
my $dataset = $mysql->getUserDataSet($sessionID);

my $selection;
if ( $mysql->applySavedCuts($sessionID) ) {
    $selection = $mysql->getSelection($sessionID);
}

my @newCutValues;
my $globalCut = $mysql->getGlobalCut($sessionID);

for ( my $i=0; $i<$numberOfCuts; $i++ ) {

    if ( $globalCut && $selection ) {
	$newCutValues[$i] = "$globalCut&&$selection";
    } elsif ( $globalCut ) {
	$newCutValues[$i] = $globalCut;
    } elsif ( $selection ) {
	$newCutValues[$i] = $selection;
    }

    if ( $mysql->getCut($sessionID, $i) ) {
	if ( $newCutValues[$i] ) {
	    $newCutValues[$i] = $newCutValues[$i] . "&&" . $mysql->getCut($sessionID, $i);
	} else {
	    $newCutValues[$i] = $mysql->getCut($sessionID, $i);
	}
    }

    if ( !($newCutValues[$i] =~ /\"/) ) {
	$newCutValues[$i] = "\"$newCutValues[$i]\"";
    }
}

if ( $#oldCutValues > -1 ) {
    for ( my $i=0; $i<=$#newCutValues; $i++ ) {
	$newscript =~ s/$oldCutValues[$i]/$newCutValues[$i]/;
    }
} else {
    $newscript =~ /(.*TString cuts.*)/;
    my $oldSelect = $1;

    $selection = "$oldSelect\n";
    for ( my $i=0; $i<$numberOfCuts; $i++ ) {
	$selection .= "\tcuts\[$i\] = " . $newCutValues[$i] . ";\n";
    }

    $oldSelect =~ s/\[/\\[/;
    $oldSelect =~ s/\]/\\]/;

    $newscript =~ s/$oldSelect/$selection/ or warn "Unable to update $!\n";

}

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

my $width  = ($appletData->{'width'})  ? $appletData->{'width'}  : 640;
my $height = ($appletData->{'height'}) ? $appletData->{'height'} : 480;

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

################################# Massage the image a bit ##############################################
my $image=Image::Magick->new;
my $imageFile = "$path/$newPng.$type";
my $err;

$err = $image->Read("$type:$imageFile");

if ( !$image || $err ) {    # ROOT failed....
    $image=Image::Magick->new;

    my $geom = $width . 'x' . $height;
    $err = $image->Set(size=>"$geom");
    warn $err if $err;

    $err = $image->ReadImage('xc:white');
    warn $err if $err;

    $geom = "+" . int(0.2*$width) . "+" . int($height/2);
    $err = $image->Annotate(font=>'Generic.ttf', pointsize=>64,
			    fill=>'lightgray', stroke=>'black', strokewidth=>1,
			    geometry=>$geom,text=>"No Results!");
    warn $err if $err;
}

# Slap up disclaimers and so on right onto the graphic file
my $isData;
if ( $dataset =~ /mc/ ) {
    $isData = 0;
} else {
    $isData = 1;
}
annotateImage($width, $height, $image, $isData);

# Get the width/height from the image since ROOT 
# tends to shrink by 6% or so
($width,$height) = $image->Get('width','height');

$image->Write("$type:$imageFile");
##########################################################################################################

my $html = new html($width, $height,  $tmpDir, 
                    $dir,   $type,    $stacked, 
                    $path,  $urlPath, 0, $histVisible,
                    $logx,  $logy,    $units, @plotList);

# (re)Make the pages the user will need... and redirect the browser to it
$html->makeActivePage("temp.$activeNode.html", $index, $appletData);
$html->makeHistoryPage($cutList, $activeNode, $plot, @nodeList);
$html->redirectPage("temp.$activeNode.html");

#
### Routine for annotating the plot *before* it gets to
### the user... that way the disclaimers are there and
### difficult to remove with PhotShop/Gimp/etc
#
sub annotateImage {
    my ($width, $height, $image, $isData) = @_;

    ### Numericals.....
    my $geom;
    my $angle = -34;
    my $size;

    if ( $width == 640 ) {
	$geom  = '+70+440';
	$size  = 140;
    } elsif ( $width == 800 ) {
	$geom  = '+90+550';
	$size  = 175;
    } elsif ( $width == 1024 ) {
	$geom = '+120+720';
	$size = 230;
    } elsif ( $width == 1280 ) {
	$geom = '+160+930';
	$size = 290;
    } elsif ( $width == 1600 ) {
	$geom = '+200+1150';
	$size = 360;
    }
    
    # Alter the image file with dislaimers & such
    my $err;
    my $text;

    if ( $isData ) {
	$text = "Preliminary";
	$size = int(0.95*$size);
    } else {
	$text = "Simulation";
    }

    $err = $image->Annotate(font=>'Generic.ttf', pointsize=>$size,
			    fill=>'none', stroke=>'lightgray', strokewidth=>1,
			    rotate=>$angle, geometry=>$geom,
			    text=>$text);
    warn $err if $err;

    if ( $width == 640 ) {
	$geom = '+75+75';
	$size = 18;
    } elsif ( $width == 800 ) {
	$geom = '+100+90';
	$size = 20;
    } elsif ( $width == 1024 ) {
	$geom = '+120+100';
	$size = 24;
    } elsif ( $width == 1280 ) {
	$geom = '+160+130';
	$size = 28;
    } elsif ( $width == 1600 ) {
	$geom = '+180+150';
	$size = 36;
    }

    $err = $image->Annotate(font=>'Generic.ttf', pointsize=>$size,
			    fill=>'purple', geometry=>$geom,
			    text=>'Data courtesy the CMS Experiment Educational Data Stream');
    warn $err if $err;

    if ( $width == 640 ) {
	$geom = '+70+445';
	$size = 24;
    } elsif ( $width == 800 ) {
	$geom = '+100+565';
	$size = 26;
    } elsif ( $width == 1024 ) {
	$geom = '+120+720';
	$size = 24;
    } elsif ( $width == 1280 ) {
	$geom = '+160+980';
	$size = 28;
    } elsif ( $width == 1600 ) {
	$geom = '+180+1140';
	$size = 36;
    }
    
    $err = $image->Annotate(font=>'Generic.ttf', pointsize=>$size,
			    fill=>'red', geometry=>$geom,
			    text=>'http://cms.cern.ch/');
    warn $err if $err;

    # If we've got multiple plots.... put on a key
    if ( -e "$path/key" ) {
	open (KEY, "<$path/key");
	my @keys = <KEY>;
	close(KEY);

	my $vertPos;

	if ( $width == 640 ) {
	    $vertPos = 100;
	    $geom = '+' . int(0.667*$width) . '+' . $vertPos;
	    $size = 16;
	} elsif ( $width == 800 ) {
	    $vertPos = 120;
	    $geom = '+' . int(0.7*$width) . '+' . $vertPos;
	    $size = 18;
	} elsif ( $width == 1024 ) {
	    $vertPos = 140;
	    $geom = '+' . int(0.75*$width) . '+' . $vertPos;
	    $size = 20;
	} elsif ( $width == 1280 ) {
	    $vertPos = 180;
	    $geom = '+' . int(0.75*$width) . '+' . $vertPos;
	    $size = 24;
	} elsif ( $width == 1600 ) {
	    $vertPos = 200;
	    $geom = '+' . int(0.75*$width) . '+' . $vertPos;
	    $size = 28;
	}

	foreach my $key (@keys) {
	    my ($plotTitle, $color) = split(/,/,$key);
	    chomp($plotTitle);
	    chomp($color);

	    my $stroke = $color;
	    if ( $color eq 'none' ) {
		$stroke = 'black';
	    }

	    $err = $image->Annotate(font=>'Generic.ttf', pointsize=>$size,
				    fill=>$color, stroke=>$stroke, strokewidth=>1,
				    text=>$plotTitle,geometry=>$geom);
	    warn $err if $err;

	    if ( $width == 640 ) {
		$vertPos += 20;
		$geom = '+' . int(0.667*$width) . '+' . $vertPos;
	    } elsif ( $width == 800 ) {
		$vertPos += 20;
		$geom = '+' . int(0.7*$width) . '+' . $vertPos;
	    } elsif ( $width == 1024 ) {
		$vertPos += 20;
		$geom = '+' . int(0.75*$width) . '+' . $vertPos;
	    } elsif ( $width == 1280 ) {
		$vertPos += 30;
		$geom = '+' . int(0.75*$width) . '+' . $vertPos;
	    } elsif ( $width == 1600 ) {
		$vertPos += 30;
		$geom = '+' . int(0.75*$width) . '+' . $vertPos;
	    }
	}
    }
}

exit 0;
