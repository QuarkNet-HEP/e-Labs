use strict;
use warnings;
use Data::Dumper;
use DBI;

# Basic data for connecting to the local database
my $host   = "leptoquark.hep.nd.edu";
my $dbtype = "mysql";
my $db     = "ogredb";
my $table  = "rundb";
my $user   = "ogre";
my $dbh;

sub get_dataset(\$) {

  my %ds = ();
  my $thisset = $_[0];

  # Get the basic data from the datasets table
  my $ds_table = "datasets";
  my $ds_query = "select * from $ds_table where name=\"$thisset\"";

  my $ds_data = $dbh->prepare($ds_query);
  $ds_data->execute();

  my @row = $ds_data->fetchrow_array();
  $ds_data->finish();

  %ds = (
	 'name'      => $row[0],
	 'location'  => $row[1],
	 'xml'       => $row[2],
	 'selection' => $row[3],
	 'access'    => $row[4]
	);

  return \%ds;
}

sub mysql(\$) {

  my $cmdl_options = $_[0];
  my $DEBUG = $cmdl_options->{DEBUG};

  $dbh = DBI->connect("DBI:$dbtype:$db:$host", "$user") or
    die "Unable to connect to DB: $!\n";

  my %mysql_data = ();
  my $dataset;
  my $query = "select filename from $table where ";

  # See if we're specifying datasets
  if ( $cmdl_options->{dataSets} ) {
    $query = $query . "(";

    eval { if ( exists( $cmdl_options->{dataSets}[0] ) ) {;} };

    if ( !$@ ) {
      foreach my $thisset (@{$cmdl_options->{dataSets}}) {

	my $thisset = @{$cmdl_options->{dataSets}}[0];
	$query = $query . "dataset=\"$thisset\" or ";

	# call the DB and grab the data from the dataset
	$dataset = &get_dataset( $thisset );

	# Save the results of the dataset search
	while ( my ($key, $value) = each(%$dataset) ) {
	  $mysql_data{$key} = $value;
	}
      }
    } else {
      my $thisset = $cmdl_options->{dataSets};
      $query = $query . "dataset=\"$thisset\" or ";

      # call the DB and grab the data from the dataset
      $dataset = &get_dataset( $thisset );

      # Save the results of the dataset search
      while ( my ($key, $value) = each(%$dataset) ) {
	$mysql_data{$key} = $value;
      }
    }

    $query =~ s/ or $//;
    $query = $query . ")";

  }

  # see if we're going to specify a run type
  if ( $cmdl_options->{runTypes} ) {
    # If we've already got a partial query... add an and to it
    if ( $query =~ m/dataset/ ) {
      $query = $query . " and ";
    }
    $query = $query . "(";
    foreach my $thistype (@{$cmdl_options->{runTypes}}) {
      $query = $query . "runtype=\"$thistype\" or ";
    }

    $query =~ s/ or $//;
    $query = $query . ")";
  }

  # See if we're selecting by run number
  if ( $cmdl_options->{runNumbers} ) {
    # If we've already got a partial query... add an and to it
    if ( $query =~ m/dataset/  or $query =~ m/runtype/) {
      $query = $query . " and ";
    }
    $query = $query . "(";
    foreach my $thisnumber (@{$cmdl_options->{runNumbers}}) {
      $query = $query . "run=$thisnumber or ";
    }

    $query =~ s/ or $//;
    $query = $query . ")";
  }
  if ( $DEBUG ) {
    print "Running MySQL query: $query\n";
  }

  my $data = $dbh->prepare($query);
  $data->execute();

  my @runFiles;
  while ( my ($filename) = $data->fetchrow_array() ) {
    push(@runFiles, "$mysql_data{'location'}/$filename");

### If we do a "select *" on the DB, this is how to handle it
#    my %runData = ( run      => $row[0],
#		    nevents  => $row[1],
#		    dataset  => $row[2],
#		    filename => $row[3],
#		    energy   => $row[4],
#		    beam     => $row[5],
#		    runtype  => $row[6],
#		    eta      => $row[7],
#		    phi      => $row[8],
#		    date     => $row[9],
#		    time     => $row[10]
#		  );

#    push(@runFiles, "$mysql_data{'location'}/$runData{'filename'}");
  }
  $data->finish();


  $mysql_data{'files'} = \@runFiles;
  return \%mysql_data;
}

################################################################################################
return 1;
