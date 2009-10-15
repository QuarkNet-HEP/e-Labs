package DBDefs;
use strict;
use warnings;
use Data::Dumper;
use Cwd;

sub new {
    my ($class) = @_;
    my $readfail = 0;

    my $self = {
	host => "localhost.localdomain",
	type => "mysql",
	db   => "ogredb",
	user => "ogre",
	pass => undef
    };

    my $counter = 0;
    my $dbdeffile = "dbconst.inc";

    if ( !(-f $dbdeffile) ) {
	$dbdeffile = "cgi-bin/$dbdeffile";
    }

    while ( !(-f $dbdeffile) && $counter++ < 5 ) {
	$dbdeffile = "../$dbdeffile";
    }

    my $whereami = Cwd::cwd();
    chomp($whereami);
    $dbdeffile = "$whereami/$dbdeffile";

    if ( !(-f $dbdeffile) ) {
        warn "$dbdeffile: $!\n";
	bless $self, $class;
	return $self;
    }

    open (DBINC, "<$dbdeffile") or $readfail=1;
    my @dbconsts = <DBINC>;
    close(DBINC);

    chomp(@dbconsts);
    foreach my $line (@dbconsts) {
	my ($param,$value) = split('=', $line);
	chomp($param);
	chomp($value);
	$param =~ s/ //g;
	$value =~ s/ //g;

	if ( $value ne "undef" && $value ne "null" ) {
	    $self->{$param} = $value;
	} else {
	    $self->{$param} = undef;
	}
    }

    bless $self, $class;
    return $self;
}

sub getHost {
    my ($self) = @_;
    return $self->{host};
}
sub getType {
    my ($self) = @_;
    return $self->{type};
}
sub getDB {
    my ($self) = @_;
    return $self->{db};
}
sub getUser {
    my ($self) = @_;
    return $self->{user};
}
sub getPass {
    my ($self) = @_;
    return $self->{pass} if $self->{pass} || undef;
}

return 1;
