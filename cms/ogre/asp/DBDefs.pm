package DBDefs;

sub new {
    my ($class) = @_;

    # Basic data for connecting to the ogre database
    my $self = {
	_host   => "localhost",
	_dbtype => "mysql",
	_db     => "ogredb",
	_user   => "ogre",
	_dbpass => undef
    };

    bless $self, $class;
    return $self;
}

sub getHost {
    my ($self) = @_;
    return $self->{_host};
}
sub getType {
    my ($self) = @_;
    return $self->{_dbtype};
}
sub getDB {
    my ($self) = @_;
    return $self->{_db};
}
sub getUser {
    my ($self) = @_;
    return $self->{_user};
}
sub getDBPass {
    my ($self) = @_;
    return $self->{_dbpass};
}

return 1;
