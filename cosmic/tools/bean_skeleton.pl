#!/usr/bin/env perl
# Creates a skeleton java file for a cosmic MappableBean
#
# Paul Nepywoda - FNAL 12/2004

use strict;
use warnings;

use Getopt::Long;

my @arguments = @ARGV;
my $scalar;
my $list;
my $file;
my $tr;
GetOptions("scalar=s" => \$scalar, 
    "list=s" => \$list, 
    "file=s" => \$file,
    "tr=s" => \$tr);

if($#ARGV == -1){
    print "Usage: $0 class_name [switches]\n";
    print "  --file=filename        where the transformations are defined\n";
    print "  --tr=fqtr              use with --file. Specify a fully-qualified TR name\n";
    print "  --scalar=\"one two ...\" manual listing of scalar values for the TR\n";
    print "  --list=\"one two ...\"   manual listing of list values for the TR\n";
    print "\nUse (--file AND --tr) OR (--scalar AND/OR --list)\n";
    print ".java file will be output to STDOUT. Redirect to a file as necessary\n";
    exit(0);
}


my $name = shift || die "Enter the name of your class\n";
our @scalar_vars;
our %scalar_vars_type;
our @list_vars;

defined($scalar) || 
    defined($list) || 
    defined($file) ||
    die "Enter either a list of space-separated values or a filename with a TR name.\n";

if(defined($scalar)){
    @scalar_vars = split / /, $scalar;
}
if(defined($list)){
    @list_vars = split / /, $list;
}
if(defined($file)){
   die "Enter a TR name (with --tr).\n" if(!defined($tr));
   open IN, $file or die "Cannot open $file";
   while(<IN>){
       if($_ =~ /TR $tr\(/){
           while(1){
               my $line = <IN>;
               if($line =~ /(input|output|inout|none) ([\w\[\]]*)/){
                   my ($type, $varname) = ($1, $2);
                   if($varname =~ /\[\]$/){
                       $varname = substr($varname, 0, length($varname)-2);
                       push @list_vars, $varname;
                   }
                   else{
                       push @scalar_vars, $varname;
                   }
                   $scalar_vars_type{$varname} = $type;
               }
               else{
                   last;
               }
           }
           last;
       }
   }
   if(!($#scalar_vars > -1 or $#list_vars > -1)){
       die "Couldn't find the TR $tr in $file\n";
   }
}


#header
print "package gov.fnal.elab.cosmic.beans;\n\n";
if(defined($scalar)){
    print "//made with: $0 --scalar \"$scalar\" --list \"$list\" $name\n\n";
}

print "import java.io.*;                   //String
import java.util.*;                 //List
import gov.fnal.elab.util.*;        //ElabException
import gov.fnal.elab.beans.*;       //MappableBean, ElabBean
import org.griphyn.vdl.classes.*;   //Derivation, Declare, LFN, List

public class $name extends ElabBean implements Serializable, MappableBean{

    //TR variables
";


#scalar variables
for my $i (@scalar_vars){
    print "    private String $i;\n";
}
#list variables
for my $i (@list_vars){
    print "    private java.util.List $i;\n";
}

#constructor
print "\n    //Constructor
    public $name(){
        this.reset();
    }
";

#get/set functions (scalar)
print "\n\n    //get/set methods (scalar)\n";
for my $i (@scalar_vars){
    my $j = $i;
    $j =~ s/(.)/\u$1/;
    print "    public void set$j(String s){
        $i = s;
    }

    public String get$j(){
        return $i;
    }

";
}
#get/set functions (list)
print "    //get/set methods (list)\n";
for my $i (@list_vars){
    my $j = $i;
    $j =~ s/(.)/\u$1/;
    print "    public void set$j(java.util.List s){
        $i = s;
    }

    public java.util.List get$j(){
        return $i;
    }

";
}

#isValid functions (scalar)
print "\n\n    //testing if the input is valid (scalar)\n";
for my $i (@scalar_vars){
    my $j = $i;
    $j =~ s/(.)/\u$1/;

print "    public boolean is$j"."Valid(){
        return true;
    }

";
}
#isValid functions (list)
print "\n    //testing if the input is valid (list)\n";
for my $i (@list_vars){
    my $j = $i;
    $j =~ s/(.)/\u$1/;

print "    public boolean is$j"."Valid(){
        if($i == null)
            return false;
        return true;
    }

";
}

#isValid: returns true if every key value is valid
print"\n    //returns true is every key value is valid
    public boolean isValid(){
        java.util.List badkeys = this.getInvalidKeys();
        return badkeys.size() > 0 ? false : true;
    }
";

#getInvalidKeys: get a list of invalid key values
my @vars = (@scalar_vars, @list_vars);
print "\n    //get a List of invalid keys
    public java.util.List getInvalidKeys(){
        java.util.List badkeys = new java.util.ArrayList();
";
for(my $i=0; $i<=$#vars; $i++){
    my $j = $vars[$i];
    $j =~ s/(.)/\u$1/;
print "        if(!is$j"."Valid()){
            badkeys.add(\"$vars[$i]\");
        }
";
}
print "        return badkeys;
    }
";


#mapToDV
print "\n\n    //returns a new Derivation with all your info in it
    public Derivation mapToDV(Transformation tr,
                            String ns,
                            String name,
                            String version,
                            String us,
                            String uses,
                            String min,
                            String max)
                            throws ElabException{
        java.util.List badkeys = getInvalidKeys();
        if(badkeys.size() > 0){
            String s = \"The following keys are invalid within the bean: \";
            for(Iterator i=badkeys.iterator(); i.hasNext(); ){
                s += (String)i.next() + \" \";
            }
            throw new ElabException(s);
        }

        //copy tr variable (used in addToDV)
        this.tr = tr;

        //create a new empty DV
        dv = new Derivation(ns, name, version, us, uses, min, max);

        //name these exactly as they're named in the TR in the VDC
";
for my $i (@vars){
print "        addToDV(\"$i\", $i);\n";
}
print "
        //return Derivation
        return dv;
    }
";

#mapToBean
print "\n\n    //sets the variables in this bean to values in the Derivation
    public void mapToBean(Derivation dv) throws ElabException{
        //copy dv variable (used in getDVValue)
        this.dv = dv;

";
for my $i (@scalar_vars){
print"        $i = getDVValue(\"$i\") == null ? \"\" : getDVValue(\"$i\");\n";
}
for my $i (@list_vars){
print"        $i = getDVValues(\"$i\");\n";
}
print "    }
";

#reset (scalar and list)
print "\n    //reset all variables to defaults
    public void reset(){
";
for my $i (@scalar_vars){
    if($scalar_vars_type{$i} eq "inout"){
        print"        $i = \"$i\";\n";
    }
    else{
        print"        $i = \"\";\n";
    }
}
for my $i (@list_vars){
print"        $i = null;\n";
}
print "    }

}
";

