package MySQL;
use strict;
use warnings;
use Data::Dumper;
use DBI;
use DBDefs;

# Define what happens to a new instance of the class
sub new {
  my ($class) = @_;

  my $dbdefs = new DBDefs();

  my $host = $dbdefs->getHost();
  my $dbtype = $dbdefs->getType();
  my $db = $dbdefs->getDB();
  my $user = $dbdefs->getUser();

  my $dbh = DBI->connect("DBI:$dbtype:$db:$host", "$user") or
    die "Unable to connect to DB: $!\n";

  my $self = {
    _MySQLHashRef => undef,
    _dbh          => $dbh,
    _table        => "",
    _query_run    => 0
  };

  bless $self, $class;
  return $self;
}

sub getUserDataSet {
    my ($self, $sID) = @_;
    my $query = "select dataSet from settings where sID='$sID'";
    my $data = $self->{_dbh}->prepare($query);
    $data->execute() || warn "Unable to get dataset for $sID\n";
    my ($set) = $data->fetchrow_array();

    if ( $set ) {
	return $set;
    } else {
	return 0;
    }
}

sub setApplySavedCuts {
    my ($self,$sID) = @_;
    my $query = "update settings set applyMyCuts=1 where sID='$sID'";
    my $data = $self->{_dbh}->prepare($query);
    $data->execute() || warn "Unable to get url!\n";
    return;
}

sub unsetApplySavedCuts {
    my ($self,$sID) = @_;
    my $query = "update settings set applyMyCuts=0 where sID='$sID'";
    my $data = $self->{_dbh}->prepare($query);
    $data->execute() || warn "Unable to get url!\n";
    return;
}

sub applySavedCuts {
    my ($self,$sID) = @_;
    my $query = "select applyMyCuts from settings where sID='$sID'";
    my $data = $self->{_dbh}->prepare($query);
    $data->execute() || warn "Unable to get url!\n";
    my ($apply) = $data->fetchrow_array();

    return $apply;
}

sub getCut {
    my ($self, $sID, $whichCut) = @_;

    my $query = "SELECT cut" . $whichCut . " from settings where sID='$sID'";
    my $data = $self->{_dbh}->prepare($query);
    $data->execute() || warn "Unable to get cut $whichCut!\n";
    my ($cut) = $data->fetchrow_array();

    if ( $cut ) {
	return $cut;
    } else {
	return 0;
    }
}

sub getSelection {
    my ($self,$sID) = @_;
    my $query = "select selection from settings where sID='$sID'";
    my $data = $self->{_dbh}->prepare($query);
    $data->execute() || warn "Unable to get selection!\n";
    my ($selection) = $data->fetchrow_array();

    if ( !$selection ) {
	return 1;
    }

    if ( $selection =~ /blah/ ) {
	$selection =~ s/blah&&//;
	$query = "update settings set selection='$selection' where sID='$sID'";
	$data = $self->{_dbh}->prepare($query);
	$data->execute() || warn "Unable to update selection!\n";
    }

    return $selection;
}

sub getGlobalCut {
    my ($self,$sID) = @_;

    my $query = "select dataSet from settings where sID='$sID'";
    my $data = $self->{_dbh}->prepare($query);
    $data->execute() || warn "Unable to update sessionID!\n";
    my ($set) = $data->fetchrow_array();

    $query = "select selection from datasets where name='$set'";
    $data = $self->{_dbh}->prepare($query);
    $data->execute() || warn "Unable to update sessionID!\n";

    my ($gCut) = $data->fetchrow_array();

    return $gCut;
}

sub updateSettingsDB {
  my ($self,$sID,$newSID) = @_;

  # See if the current session ID is already in the table...
  my $query = "select count(sID) from settings where sID='$sID'";
  my $data = $self->{_dbh}->prepare($query);
  $data->execute() || warn "Unable to update sessionID!\n";

  my ($numRows) = $data->fetchrow_array();

  if ( $numRows == 0 ) {  # Not there... insert the new sessionID
      $query = "insert into settings (sID) values('$newSID')";
  } else {                # otherwise... update the old ID to the new ID
      $query = "update settings set sID='$newSID' where sID='$sID'";
  }

  $data = $self->{_dbh}->prepare($query);
  $data->execute();

  return;
}

# Processes an arbitrary query to ogredb and returns
# a hash of arrays keyed on the first field in the query
sub processDBQuery {
    my ($self, $query) = @_;
    my %dbResult = ();

    my $data = $self->{_dbh}->prepare($query);
    $data->execute() || return;

    ### If this was a selection.... process the result(s)
    if ( $query =~ /select/i ) {
	while ( my (@row) = $data->fetchrow_array() ) {

	    @row = reverse(@row);
	    my $index = pop(@row);
	    @row = reverse(@row);

	    $dbResult{$index} = \@row;
	}
    }

    $data->finish();

    return %dbResult;
}

sub getMySQLHashRef {
  my ($self) = @_;
  return $self->{_MySQLHashRef} if defined $self->{_MySQLHashRef} || undef;
}

sub dumpMySQL {
  my ($self) = @_;

  my $mysql_dump = Dumper($self->{_MySQLHashRef});
  $mysql_dump =~ s/\$VAR1/MySQL/;
  print $mysql_dump;
  return;
}

sub getXMLPath {
    my ($self) = @_;
    my $dbh = $self->{_dbh};
    my $query = "select ogreXML from bootstrap";
    my $data = $dbh->prepare($query);
    $data->execute();

    my $xmlLoc = ($data->fetchrow_array);
    return $xmlLoc;
}

sub getXMLURL {
    my ($self) = @_;
    my $dbh = $self->{_dbh};
    my $query = "select xmlURL from bootstrap";
    
    my $data = $dbh->prepare($query);
    $data->execute();
    return ($data->fetchrow_array);
}

sub get_dataset(\$) {
  my ($self, $thisset) = @_;
  my $dbh = $self->{_dbh};

  my %ds = ();

  # Get the basic data from the datasets table
  my $ds_table = "datasets";
  my $ds_query = "select * from $ds_table where name=\"$thisset\"";

  my $ds_data = $dbh->prepare($ds_query);
  $ds_data->execute();

  my @row = $ds_data->fetchrow_array();
  $ds_data->finish();

  %ds = (
      'name'        => $row[0],
      'datatable'   => $row[1],
      'description' => $row[2],
      'location'    => $row[3],
      'xml'         => $row[4],
      'selection'   => $row[5],
      'access'      => $row[6]
      );

  # The dataset should contain a pointer to the runtime
  # table containing a description of the data to use..
  # If it does... use it.
  $self->{_table} = $ds{'datatable'} || "mcdb";

  return \%ds;
}

sub procDBRequest {
  my ($self) = @_;

  if ( $self->{_query_run} ) {
    warn "Reentrent!\n";
    return;
  }
  $self->{_query_run} = 1;

  my $dbh = $self->{_dbh};

  my $cmdl_options = $ogre::cgi->getCGIHashRef();
  my $DEBUG = $cmdl_options->{'DEBUG'};

  my %mysql_data = ();
  my $dataset;
  my $query;

  # See if we're specifying datasets
  if ( $cmdl_options->{dataSets} ) {
    eval { if ( exists( $cmdl_options->{dataSets}[0] ) ) {;} };

    if ( !$@ ) {
      foreach my $thisset (@{$cmdl_options->{dataSets}}) {

	# call the DB and grab the data from the dataset
        $dataset = $self->get_dataset( $thisset );

	my $table = $self->{_table};
	$query = "select filename from $table where (dataset=\"$thisset\" or ";

	# Save the results of the dataset search
	while ( my ($key, $value) = each(%$dataset) ) {
	  $mysql_data{$key} = $value;
	}
      }
    } else {
      my $set = $cmdl_options->{dataSets};
      # call the DB and grab the data from the dataset
      $dataset = $self->get_dataset( $set );

      my $table = $self->{_table};
      $query = "select filename from $table where (dataset=\"$set\" or ";

      # Save the results of the dataset search
      while ( my ($key, $value) = each(%$dataset) ) {
	$mysql_data{$key} = $value;
      }
    }

    $query =~ s/ or $//;
    $query = $query . ")";
  }

  # See if the user passed on a trigger list
  if ( $cmdl_options->{triggers} ) {
      # If we've already got a partial query... add an and to it
    if ( $query =~ m/dataset/ ) {
      $query = $query . " AND ";
    }
    $query = $query . "(" . $cmdl_options->{triggers} . ")";
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

  }
  $data->finish();

  $mysql_data{'files'} = \@runFiles;
  $self->{_MySQLHashRef} = \%mysql_data;

  if ( $ogre::cgi->getCGIParam('DEBUG') ) {
    $self->dumpMySQL();
  }

  return;
}

################################################################################################
return 1;
