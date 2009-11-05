<%

# Create a random 32-byte hex number to use as a unique session ID
# Do this on the server so we can use a high-quality random number
# taken from /dev/urandom 

my @dec2hex = ( '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f' );
$Response->{expires} = -1;

my $rand;
open RND, "/dev/urandom";
read(RND, $rand, 32);
my @rand = split //, $rand;

my $hex = "";
foreach my $byte (@rand) {
    $hex .= $dec2hex[ord($byte)%16];
}
$Response->Write($hex);

#### Somewhat lower quality but slightly faster way to do the same thing
#for ( my $i=0; $i<4; $i++ ) {
#    my $decimal = int(4294967296*rand()+1);

#    $hex .= $dec2hex[ $decimal % 16 ];
#    $decimal = int($decimal/16);

#    while ( $decimal > 1 ) {
#	$hex .= $dec2hex[$decimal%16 ];
#	    $decimal = int($decimal/16);
#    }
#}

#print "$hex\n";


%>