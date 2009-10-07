# Class node
package node;
use strict;
use warnings;
use Data::Dumper;

sub new {
  my ($class, $nodeName, $parent) = @_;
  my $self = {
	      _active   => undef,
	      _nodeName => undef,
	      _parent   => undef,
	      _children => undef
	     };

  $self->{_nodeName} = $nodeName if defined($nodeName);
  $self->{_parent} = $parent if defined $parent || undef;

  bless $self, $class;
  return $self;
}

###### Accessor functions for the name of this node
sub setName {
  my ($self, $name) = @_;
  $self->{_nodeName} = $name if defined($name);
  return $self->{_nodeName} if defined($self->{_nodeName}) || undef;
}
sub getName {
  my ($self) = @_;
  return $self->{_nodeName} if defined($self->{_nodeName}) || undef;
}

###### Accessor functions for this nodes' active state
sub setActive {
  my ($self, $active) = @_;
  $self->{_active} = $active if defined($active);
  return $self->{_active} if defined($self->{_active}) || undef;
}
sub getActive {
  my ($self) = @_;
  return $self->{_active} if defined($self->{_active}) || undef;
}

##### Accssor function for this nodes' parent
sub setParent {
  my ($self, $parent) = @_;
  $self->{_parent} = $parent if defined $parent;
  return $self->{_parent} if defined $self->{_parent};
}
sub getParent {
  my ($self) = @_;
  return $self->{_parent} if defined($self->{_parent}) || undef;
}

##### Accessor functions for this nodes' direct descendents
sub setChildren {
  my ($self, $children) = @_;
  $self->{_children} = $children if defined($children);
  return $self->{_children} if defined($self->{_children}) || undef;
}
sub addChild {
  my ($self, $child) = @_;
  if ( defined($self->{_children}) ) {
    $self->{_children} .= ":$child" if defined $child;
  } else {
    $self->{_children} = $child if defined $child;
  }
  return $self->{_children} if defined($self->{_children}) || undef;
}
sub getChildren {
  my ($self) = @_;
  my @children;
  if ( defined($self->{_children}) ) {
    @children = split(/:/, $self->{_children});
  }
  if (!@children) {
    return;
  }
  return @children if @children;
}

##### Stock print functions to dump this out
sub print {
  my ($self) = @_;
  print "Node " . $self->{_nodeName};

  if ( defined($self->{_parent}) ) {
    print ": Parent " . $self->{_parent};
  } else {
    print ": Parent (None)";
  }

  if ( defined($self->{_children}) ) {
    print ": Children " . $self->{_children};
  } else {
    print ": Children (None)";
  }

  if ( !defined($self->{_active}) || $self->{_active} == 0 ) {
    print " is not ";
  } else {
    print " is ";
  }
  print "the active node\n";
  return;
}

return(1);
