package parseOps;
use strict;
use warnings;

#################################################################
# Package to take an array of leaves and associated operations  #
# and massage them into an acceptable form for plotting in root #
#################################################################
sub new {
    my ($class, @temp) = @_;  # Create a new instance and give the array
    my $self = {
	_temp => \@temp
    };

    bless $self, $class;
    return $self;
}

sub parse {                   # Parse the array into seperate plot based on operations and seperators
    my ($self) = @_;
    my @temp = @{$self->{_temp}};

    for ( my $i=0; $i<=$#temp; $i++ ) {
	if ( $temp[$i] eq "plus" ) {
	    $temp[$i] = "+";
	} elsif ( $temp[$i] =~ /^(\d+)$/ ) {
	    $temp[$i] = "leaf" . $temp[$i];
	}
    }

# The only operation that makes sense in front is - or (
    if ( $temp[0] =~ /\+|\-|\/|\*|\(|\)|\|/ ) {
	if ( $temp[0] ne "(" && $temp[0] ne "-" ) {
	    @temp = reverse(@temp);
	    pop(@temp);
	    @temp = reverse(@temp);
	}
    }

# Likewise... the only trailing operation that makes sense is ")"
    while ( !($temp[$#temp] =~ /^leaf/) ) {
	if ( $temp[$#temp] ne ')' ) {
	    pop(@temp);
	} else {
	    last;
	}
    }

# If no operations at all where passed in... each line is a plot
    my $areOps = 0;
    for ( my $i=0; $i<=$#temp; $i++ ) {
	if ( !($temp[$i] =~ /^leaf/) ) {
	    $areOps = 1;
	    last;
	}
    }

# Produce the return product
    my @leaves;
    if ( $areOps ) {
	my $line = join('', @temp);
	@leaves = split(/\|/, $line);
    } else {
	@leaves = @temp;
    }

    return @leaves;
}

sub extractLeaves {           # Ignore the operations and just extract the leaf numbers 
    my ($self) = @_;
    my @temp = @{$self->{_temp}};
    my @leaves = ();

    for ( my $i=0; $i<=$#temp; $i++ ) {
	if ( $temp[$i] =~ /\d+/ ) {
	    push(@leaves, $temp[$i]);
	}
    }
    return @leaves;
}

return 1;
