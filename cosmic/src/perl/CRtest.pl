#!/usr/bin/perl

open S, "(stty 19200; stty clocal; tee) < /dev/cu.USA19QW623P1.1 |";
#open STDIN, "| tee /dev/cu.USA19QW623P1.1";
while($s=<S>){
	#$s=<STDIN>;
	#if(length(<STDIN>) > 0){
	#}
	#read(STDIN, $r, 2);
	#`echo -n "$r" > /dev/cu.USA19QW623P1.1`;
	print $s;
}
