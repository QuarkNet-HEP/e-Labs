#!/usr/bin/perl

use Math::BigFloat;

$regular_float = 0.3794038301496964;
$regular_float -= 0.3794038301498352; 
$regular_cpld = 41666647.5;
$regular_secs = 86400;
$regular_billion = 1e9;
$big_float = Math::BigFloat->new('0.3794038301496964');
$big_float = $big_float->copy()->bsub(Math::BigFloat->new('0.3794038301498352'));
$big_cpld = Math::BigFloat->new('41666647.5');
$big_secs = Math::BigFloat->new('86400');
$big_billion = Math::BigFloat->new('1E+9');
Math::BigFloat->accuracy(36);
Math::BigFloat->precision(-36);

#print "$big_float\n";
#print "$regular_float\n";
#$big_float = $big_float->badd($big_cpld);
#print "$big_float\n";

# Do some typical ops from ThresholdTimes.pl here.
for my $i (0..10) {
    $regular_float = ($regular_float / ($regular_cpld * $regular_cpld)) - $regular_float;
    $big_float = ($big_float / ($big_cpld * $big_cpld)) - $big_float;
}

$regular_float = $regular_float * $regular_billion;
$big_float = $big_float * $big_billion;

print "Regular float: $regular_float\n";
print "Big float: $big_float\n";
