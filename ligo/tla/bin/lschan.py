#!/usr/bin/env python
#
# Search recursively for directories which contain frame files.
# Since frames are collected in directories based on GPS times
# (or some other organizing feature) just report the super-directory
# which contains at least one directory which contains a frame file.
#
# List the channels within that frame file, using FrChannels
#
# Eric Myers <myers@spy-hill.net>  - 10 April 2006
# @(#) $Id: lschan.py,v 1.3 2006/04/13 15:29:38 myers Exp $
########################################################################

## CONFIG:

import sys, os

TOP_SOURCE_DIR="/archive/frames/trend"
#TOP_SOURCE_DIR="/net/moonflower/home/myers/proj"


########################################################################
## FUNCTIONS:

#-#
# List all the channels in file fname (assuming it has any).
# Returns 1 if it does, 0 on error.

def list_channels(fname):
    #print >>sys.stderr, "magic: "+fname
    try:
        hd = open(fname).read(4)
    except IOError,e:
        hd = ''
    if hd != 'IGWD':
        print >>sys.stderr,"Error: Not IGWD file: "+fname
        return

    #print >>sys.stderr, "% /ligotools/bin/FrChannels "+fname
    try:
        rc = os.system("/ligotools/bin/FrChannels "+fname+" >/tmp/lschan.tmp")
        return 1
    except OSError, e:
        return 0


#-#
# List the contents of a file, line by line

def cat(filepath):
    ih = open(filepath,'r')
    for line in ih.readlines():
        print line,

#-#
# Recursively process directories, looking for .gwf files
# Return name of directory above the directory containing it

def do_dir(dname):
    global Nlvl
    if not os.path.isdir(dname): return 0
    if dname.startswith('.'): return 0

    print >>sys.stderr, "] Searching "+dname
    #[TODO] clear out temp file
    
    Nerr=0

    for f in os.listdir(dname):
        if Nerr > 9: break
        if f.startswith('.'): continue
        path = os.path.join(dname,f)
        if os.path.islink(path): continue
        if os.path.isfile(path):
            if f.endswith('.gwf'):
                #print >>sys.stderr,"Found frame file: "+path
                if list_channels(path): 
                    # Just have to find one good file, so ignore the rest
                    return 1
                else:
                     Nerr = Nerr + 1
                #    print >>sys.stderr, "Error listing channels in "+path
        if os.path.isdir(path):  
            # ignore these subdirectories    
            if f == "burst": continue
            if f == "TEST":  continue    

            # test the subdirectory for frame files
            if do_dir(path):
                # [TODO] test here that tmp file is not empty
                #print >>sys.stderr, "Found frame files under "+path
                print "["+dname+"]"
                cat("/tmp/lschan.tmp")
                # found frames UNDER here, so stop looking HERE or UNDER
                break  
    return 0
        

########################################################################
## BEGIN:

if not os.path.isdir(TOP_SOURCE_DIR):
    print >>sys.stderr, "Error: Starting point "+TOP_SOURCE_DIR+" is not a directory."
    sys.exit(1)

#print  "OK: Staring point "+TOP_SOURCE_DIR+" is a directory.\n"
print >>sys.stderr, "Searching for all frame.gwf files under "+TOP_SOURCE_DIR

do_dir(TOP_SOURCE_DIR)

sys.exit(0)
##
