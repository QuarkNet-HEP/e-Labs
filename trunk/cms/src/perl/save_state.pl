#!/usr/bin/perl
use strict;
use warnings;
#

################################################################################################
sub make_hash(\$) {
  my @list = split(/\;/,$_[0]);
  my @unique_names = ();
  my $hash_ref;

  # get the unique elements in the list
  foreach my $element (@list) {

    my ($name) = split(/=/,$element);
    my @temp = grep { $_ eq $name } @unique_names;

    if ( $#temp == -1 ) {
      push(@unique_names, $name);
    }
  }

  foreach my $name (@unique_names) {
    my $string = $name ."=";
    my @temp = grep(/^$string/, @list);

    my @values = ();

    foreach my $value (@temp) {
      my ($name, $number) = split(/=/, $value);
      push(@values, $number);
    }

    $hash_ref->{$name} = \@values;
  }

  return $hash_ref;
}
################################################################################################

sub save_state(\$ \$ \$) {

return;

  my $state   = $_[0];
  my $htmlout = $_[1];
  my $baseDir = $_[2];
  my $newDir  = "$baseDir/xml";

  chomp($state);
  my @elements = split(";", $state);

  # Make a hash of arrays to hold the page state at submission
  my $ref = &make_hash($state);

  # Read in the base webpage to be modified
  my $htmlpage = `cat $baseDir/ogre.php`;
  $htmlpage =~ s/\.\/xml/$newDir/;

  open OUTFILE, ">$baseDir/tmp.php";
  print OUTFILE $htmlpage;
  close OUTFILE;

  my @html = `php $baseDir/tmp.php`;
  unlink("$baseDir/tmp.php");

  # Create the JavaScript function to replicate the page state
  my $new_script = "\t  <Script Language=\"JavaScript\" Type=\"Text/JavaScript\">\n\t    function setOptions() {\n";
  for my $key ( keys %{$ref} ) {

    my @values = @{ $ref->{$key} };
    for ( my $i=0; $i<=$#values; $i++ ) {

      # Make sure this isn't a hidden variable on the webpage
      my $vartag = "name=\"$key\"";
      my @lines = grep { /$vartag/ } @html;

      my $hidetag = "type=\"hidden\"";
      my @hidden = grep ( /$hidetag/, @lines );

      if ( $#lines > -1 && $#hidden == -1 ) {

	# Now we gotta figure out what type of element this is... and set it accordingly
	if ( $lines[0] =~ "type=\"checkbox\"" ) {
	  $new_script = $new_script . "\t\tdocument.getData.$key\[$values[$i]\].checked = true\n";
	} elsif ( $lines[0] =~ "type=\"radio\"" ) {
	  if ( $values[$i] eq "jpg" ) {
	    $new_script = $new_script . "\t\tdocument.getData.type[1].checked = true;\n";
	  } elsif ( $values[$i] eq "eps" ) {
	    $new_script = $new_script . "\t\tdocument.getData.type[2].checked = true;\n";
	  } else {
	    $new_script = $new_script . "\t\tdocument.getData.type[0].checked = true;\n";
	  }
	} elsif ( $lines[0] =~ "select name=" || $lines[0] =~ "type=\"entry\""  || $lines[0] =~ "type=\"text\"" ) {
	  if ( $#values > 0 ) {
	    $new_script = $new_script . "\t\tdocument.getData.$key\[$i\].value = $values[$i];\n";
	  } else {
	    $new_script = $new_script . "\t\tdocument.getData.$key.value = $values[$i];\n";
	  }
	}
      }
    }
  }
  $new_script      = $new_script . "\t    }\n\t  </Script>\n\t</head>";
  my $end_head_tag = "</head>";
  my $body_tag     = "<body>";
  my $new_body_tag = "<body onLoad=\"javascript:setOptions();\">";
  my $htmlPage     = "@html";

  # Insert the new javascript into the page.... and instruct the engine to run it on load
  $htmlPage =~ s/$end_head_tag/$new_script/i;
  $htmlPage =~ s/$body_tag/$new_body_tag/i;

  # Write the new page to a file for saving into the results directory....
  open(CGI_OUT, ">$htmlout") || warn "Unable to save CGI query: $!\n";
  print CGI_OUT $htmlPage;
  close(CGI_OUT);

  return;
}

################################################################################################
return 1;
