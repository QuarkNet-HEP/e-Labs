# Class population
package population;
use strict;
use warnings;
use Data::Dumper;

use node;

sub new {
  my ($class, $baseName, $type, @list) = @_;
  my %population = ();
  my $self = {
	      _population => \%population,
	      _active     => undef,
	      _baseName   => undef,
              _type       => undef
	     };

  $self->{_baseName} = $baseName if defined $baseName || undef;
  $self->{_type}     = $type if defined $type || undef;

  bless $self, $class;

  # Add in the data for the nodes in this population tree
  for ( my $i=0; $i<=$#list; $i++ ) {

    my ($parent, $node) = split(/_/, $list[$i]);
    if ( $parent eq '' ) {
      $parent = undef;
    }
    $list[$i] = $node;
    my $name = $baseName;
    $name .= "." . $node . $type;

    my $newNode = $self->addNode($node, $name, $parent);
    if ( !defined $newNode ) {
      warn "Unable to add $node to the population!\n";
    }
  }

  foreach my $node (@list) {
    ( $node eq "0" ) and next;
    my $parent = $self->getNodeByName(($self->getNodeByName($node))->getParent($node));

    if ( defined($parent) ) {
      $parent->addChild($node) || warn "Unable to add $node as a child of $parent\n";
    } else {
      if ( $node ne '000' ) {
	warn "Unable to find parent of $node\n";
      }
    }
  }

  return $self;
}

sub getLineage {
  my ($self, $node) = @_;
  if ( !defined($node) ) {
    return undef;
  }
  my @list = ($node);

  my $parent = ($self->getNodeByName($node))->getParent();
  while ( defined($parent) ) {
    push(@list, $parent);
    $parent = ($self->getNodeByName($parent))->getParent();
  }
  return join(" ", @list) if @list || undef;
}

sub getGeneration {
  my ($self, $node) = @_;
  if ( !defined($node) ) {
    return undef;
  }
  my @list = ($node);

  my $parent = ($self->getNodeByName($node))->getParent();
  while ( defined($parent) ) {
    push(@list, $parent);
    $parent = ($self->getNodeByName($parent))->getParent();
  }
  return $#list if @list || 0;
}


my $x = 48;
my $y = 20;
my $maxX = 0;
my $maxY = 0;
my %plotPositions = ();

sub getDescendents {
  my ($self, $node, $seperation) = @_;
  my @kids = ($self->getNodeByName($node))->getChildren() if defined $node;

  my $generation = $self->getGeneration($node);

  if ( $node == 0 ) {
    my @temp = $self->getChildren($node);
    $x = 0.625*$seperation*$#temp + 20;
  }

  $plotPositions{$node}->{x} = $x;
  $plotPositions{$node}->{y} = $y;

  if ( !@kids || $#kids < 0 ) {
    $y = 20 + $generation*$seperation;
    $plotPositions{$node}->{x} = $x;
    $plotPositions{$node}->{y} = $y;
    $x += 1.25*$seperation;

    if ( $x > $maxX ) {
      $plotPositions{'max'}->{'x'} = $x;
      $maxX = $x;
    }
    if ( $y > $maxY ) {
      $plotPositions{'max'}->{'y'} = $y;
      $maxY = $y;
    }

    return %plotPositions if %plotPositions || undef;
  }

  $y = 20 + $generation*$seperation;
  $plotPositions{$node}->{x} = $x;
  $plotPositions{$node}->{y} = $y;

  if ( $x > $maxX ) {
    $plotPositions{'max'}->{'x'} = $x;
    $maxX = $x;
  }
  if ( $y > $maxY ) {
    $plotPositions{'max'}->{'y'} = $y;
    $maxY = $y;
  }

  if ($node eq "000") {
    $x = 20;
  }

  foreach my $child (@kids) {
    $self->getDescendents($child, $seperation);
  }

  return %plotPositions if %plotPositions || undef;
}

sub getChildren {
  my ($self, $node) = @_;
  my @kids = ($self->getNodeByName($node))->getChildren() if defined $node;
  return @kids if @kids;
}

sub getNodeChild {
  my ($self, $node) = @_;
  (my $kid) = ($self->getNodeByName($node))->getChildren() if defined $node;
  return $kid if $kid;
}

sub addNode {
  my ($self, $node, $name, $parent) = @_;
  $self->{_population}{$node} = new node($name, $parent)
    if defined($node);

  return $self->{_population}{$node} if defined $self->{_population}{$node} || undef ;
}

sub getNodeByName {
  my ($self, $node) = @_;
  return $self->{_population}{$node} if defined($node) || undef;
}

sub getNodeParent {
  my ($self, $node) =@_;
  my $parent = ($self->getNodeByName($node))->getParent();
  return $parent if defined $parent || undef;
}

sub setActive {
  my ($self, $node) = @_;
  if ( !defined $node ) {
    return 0;
  }
  $self->{_active} = $node || return 0;
  ($self->getNodeByName($node))->setActive(1) || return 0;
  return 1 if defined($self->{_active}) || 0;
}

sub getActive {
  my ($self) = @_;
  if ( defined $self->{_active} ) {
    return $self->{_active};
  }
  return undef;
}

sub setBaseName {
  my ($self, $name) = @_;
  if ( defined $name ) {
    $self->{_baseName} = $name;
    return 1;
  }
  return 0;
}

sub getBaseName {
  my ($self) = @_;
  if ( defined $self->{_baseName} ) {
    return $self->{_baseName};
  }
  return undef;
}

sub dump {
  my ($self) = @_;
  print Dumper($self);
  return;
}

sub print {
  my ($self) = @_;
  my $hashRef = $self->{_population};

  foreach my $key (keys %$hashRef ) {
    $self->printNode($key);
  }
  return;
}

sub printNode {
  my ($self, $node) = @_;
  if ( defined($node) && defined($self->{_population}{$node}) ) {
    $self->{_population}{$node}->print();
  } else {
    print "node $node not defined\n";
  }
  return;
}

return(1);
