package archive;
use strict;
use warnings;

use Archive::Tar;
use File::Copy;
use File::Path;
use File::Find;
use File::chdir;
use Cwd;

use ogreXML;
use MySQL;

sub new {
  my ($class,$dir,$active,$type,$overwrite,$final) = @_;

  # Get some of the basic structure information from the ogre.xml file
  my $ogreXML = new ogreXML();

  my $self = {
    _archivesDir => $ogreXML->getOgreParam('archiveDir'),
    _tmpDir      => $ogreXML->getOgreParam('tmpDir'),
    _resultsDir  => $ogreXML->getOgreParam('resultsDir'),
    _urlPath     => $ogreXML->getOgreParam('urlPath'),
    _active      => $active,
    _dir         => $dir,
    _type        => $type
  };


  if ( $overwrite ) {
      $self->{_overwrite} = $overwrite;
  } else {
      $self->{_overwrite} = 0;
  }

  if ( $final ) {
      $self->{_finalize} = $final;
  } else {
      $self->{_finalize} = 0;
  }

  bless $self, $class;
  return $self;
}

# If the user requests a stop... save everything as it is so far
# pack it up, zip it up, and move the archive over to a seperate 
# directory for safe keeping.
sub archiveStudy {
  my ($self) = @_;

#  my $html = new html();

  my $archivesDir = $self->{_archivesDir};
  my $resultsDir  = $self->{_resultsDir};
  my $dir         = $self->{_dir};
  my $tmpDir      = $self->{_tmpDir};
  my $type        = $self->{_type};
  my $active      = $self->{_active};
  my $finalize    = $self->{_finalize};

  my @files;
  my $compress = 1;

  # Make sure we don't overright an existing archive
  if ( -f "$archivesDir/study-$dir.tar.gz" && !$self->{_overwrite} ) {
    $dir = $self->moveStudy();
    $self->{_dir} = $dir;
  }

  # OK.... now that we're sure we aren't whacking something else.... 
  # Find all the files in the temp directory
  chdir($tmpDir) || warn "Unable to change directory: $!";
  find(sub {push @files,$File::Find::name},$dir);
  if ( !$#files ) {
      warn "No files found: $!";
      return 1;
  }

  # and archive them into the archives directory
  if ( !Archive::Tar->create_archive("$archivesDir/study-$dir.tar.gz",$compress,@files) ) {
      warn "Unable to create archive: $!";
      return 2;
  }

  # move the new the current plot into the archive directory
  my $canvas = sprintf("%s/canvas.%03i.%s",$dir,$active,$type);
  if ( !copy($canvas,"$archivesDir/canvas-$dir.$type") ) {
      warn "Can't move $canvas: $!";
      return 3;
  }

  if ( $finalize ) {
      # And clean up the temp directory and any archives there are
      rmtree("$tmpDir/$dir");
      chdir("-");
      move("$archivesDir/study-$dir.tar.gz","$resultsDir/study-$dir.tar.gz")
	  || warn "Unable to finalize archive: $!";
      move("$archivesDir/canvas-$dir.$type", $resultsDir) || 
	  warn "Unable to finalize $archivesDir/canvas-$dir.$type: $!";
  }

  return 0;
}

# On the other hand... if the user is all warm & fuzzy with what (s)he has done
# then push it all out to the results directory as a finished study...
sub finalizeStudy {
  my ($self) = @_;

  my $archivesDir = $self->{_archivesDir};
  my $tmpDir      = $self->{_tmpDir};
  my $resultsDir  = $self->{_resultsDir};
  my $urlPath     = $self->{_urlPath};
  my $dir         = $self->{_dir};
  my $active      = $self->{_active};
  my $type        = $self->{_type};

  # Make sure we don't overright an existing study
  if ( -f "$resultsDir/study-$dir.tar.gz" ) {
    $dir = $self->moveStudy();
    $self->{_dir} = $dir;
  }

  my $newScriptName  = "$resultsDir/script-$dir.C";
  my $newCanvasName  = "$resultsDir/canvas-$dir.$type";
  my $newArchiveName = "$resultsDir/study-$dir.tar.gz";

  my $canvas = sprintf("%s/%s/canvas.%03i.$type", $tmpDir, $dir, $active);
  my $script = sprintf("%s/%s/script.%03i.C",     $tmpDir, $dir, $active);

  # The scripts in the tmp directory have a lot of superfluous 
  # junk to track sizes & pixel conversions for the applet...
  # Dump all that junk for the final version
  open(SCRIPT, "<$script");
  my @temp = <SCRIPT>;
  close(SCRIPT);

  open(SCRIPT, ">$newScriptName");

  for ( my $i=0; $i<=$#temp; $i++ ) {
    if ( $temp[$i] =~ /SaveAs\(oFile\)/ ) {
      print SCRIPT $temp[$i], "\n";
      print SCRIPT "}\n";
      last;
    }
    print SCRIPT $temp[$i]
  }

  copy("$canvas", "$newCanvasName");

  # Archive all of the files in the results directory
  my $compress = 1;
  my @files;

  chdir($tmpDir);
  find(sub {push @files,$File::Find::name},$dir);
  Archive::Tar->create_archive("study-$dir.tar.gz",$compress,@files); 
  move("study-$dir.tar.gz",$resultsDir);
  rmtree("$tmpDir/$dir");
  chdir("-");

  if ( (-f "$archivesDir/study-$dir.tar.gz") ) {
    unlink("$archivesDir/study-$dir.tar.gz");
  }

#  my $html = new html();
#  $html->finalPage("$urlPath/results/", $type, $dir);
  return;
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

#
### Change the random directory assigned in case of a collision
#
sub moveStudy {
  my ($self) = @_;
  my $whichDir   = $self->{_tmpDir};
  my $curRand    = $self->{_dir};
  my $resultsDir = $self->{_resultsDir};
  my $archiveDir = $self->{_archiveDir};

  #
  ### Generate a random (< 32 character) hex number to distinguish temp files
  #
  my $decimal;
  my $hex = "";
  for ( my $i=0; $i<4; $i++ ) {
      $decimal = 100000000 + int(rand(999999999));
      $hex .= $self->dec_to_hex($decimal);
  }
  my $random = $hex;

  # Even though we can handle billions of simultaneous names.. technically,
  # We all know that when there were only two cars in the state of Kansas, 
  # they collided head on. So check... just to make sure
  while ( -d "$whichDir/$random" || -f "$resultsDir/script-$random.C" || -f "$archiveDir/study-$random.tar.gz" ) {
      for ( my $i=0; $i<4; $i++ ) {
	  $decimal = 100000000 + int(rand(999999999));
	  $hex .= $self->dec_to_hex($decimal);
      }
      $random = $hex;
  }

  # Was there a session ID? And did we have to change it to avoid collisions?
  if ( $random ne $curRand ) {
      my $db = new MySQL();          # Yup... update the DB with the new sessionID
      $db->updateSettingsDB($curRand, $random);
      undef $db;
  }

  ### Since the script runs & results depend on loading things
  ### from the temp directory... we have to go inside each one
  ### and change every instance of the old random number to the
  ### new random number.
  
  chdir("$whichDir/$curRand");

  my @fileList = getFiles('html', "./");
  foreach my $file (@fileList) {

    open (TEMP, "<$file");
    my @tempfile = <TEMP>;
    close (TEMP);

    my $htmlfile = join('',@tempfile);
    $htmlfile =~ s/$curRand/$random/g;

    open(HTML, ">$file");
    print HTML $htmlfile;
    close(HTML);

  }

  @fileList = getFiles('C', "./");
  foreach my $file (@fileList) {

    open (TEMP, "<$file");
    my @tempfile = <TEMP>;
    close (TEMP);

    my $Cfile = join('',@tempfile);
    $Cfile =~ s/$curRand/$random/g;

    open(C, ">$file");
    print C $Cfile;
    close(C);

  }

  chdir("-");

  move("$whichDir/$curRand", "$whichDir/$random");
  return $random;

}

#
### Find all files of type %findType in directory $directory & return a list
#
sub getFiles {

  my ($findType, $directory) = @_;
  my @list = ();
  opendir(DIR, $directory);
  my @files = readdir(DIR);
  closedir(DIR);

  for my $file (@files) {
    $file eq "."  and next;
    $file eq ".." and next;
    $file eq "map.$findType" and next;

    (my $thisType) = reverse(split(/\./,$file));

    ($thisType eq $findType) and push @list, $file;
  }
  chomp(@list);
  return @list;
}

return 1;

