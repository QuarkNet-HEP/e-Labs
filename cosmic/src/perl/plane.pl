#!/usr/bin/perl
#Using 3 points to determine the 3d "plane" of an incoming shower
# Paul Nepywoda - FNAL 1/2004
#
# usage: ./plane.pl 4 5 6 1 2 3 10 11 12

#assumptions: points are in the form x,y,z = longitude, latitude, altitude

#let the 2 vectors defining the plane be AB and AC (A B C are the three 3-point arguments to the program)
@A=@ARGV[0..2];
@B=@ARGV[3..5];
@C=@ARGV[6..8];
@AB=($B[0]-$A[0], $B[1]-$A[1], $B[2]-$A[2]);
@AC=($C[0]-$A[0], $C[1]-$A[1], $C[2]-$A[2]);

#n = AB x AC (normal vector equals the cross product of the 2 vectors)
@n=($AB[1]*$AC[2]-$AC[1]*$AB[2], $AB[2]*$AC[0]-$AC[2]*$AB[0], $AB[0]*$AC[1]-$AC[0]*$AB[1]);

#normal vector should point up (positive z value) so we can use it to find what quadrant we're in
if($n[2] < 0){
	@n=(-1*$n[0], -1*$n[1], -1*$n[2]);
}
print "normal vector=@n \n";

#find the 2 angles that define the normal vector (in radians)
$a1=atan2($n[1], $n[0]);				#atan2(Y/X)
$a2=atan2($n[2], sqrt($n[0]*$n[0]+$n[1]*$n[1]));	#atan2(Z/sqrt(A^2 + B^2))

#determine the xy quadrant we're in
if($n[0] > 0){
	if($a1 > 0){				#in quadrant 1
		$q="North of East";
	}
	else{					#in quadrant 4
		$q="South of East";
	}
}
else{
	if($a1 > 0){				#in quadrant 2
		$q="North of West";
	}
	else{					#in quadrant 3
		$q="South of West";
	}
}

#make our angles positive values, and change radians to degrees
$pi=3.1415926535897932;
$a1=abs($a1*180/$pi);
$a2=abs($a2*180/$pi);				#showers should never come from BELOW us

print "This shower comes from $a1 degrees $q, and $a2 degrees up\n";
