#!/bin/sh 
#
#  Run a ROOT script named on the command line.
#
#  The first command line argument $1 is a unique ID used for labeling 
#  ouput files.  The rest of the command line is passed to ROOT.
#
#  Locking and signalling is very crude here, for now.
#
#  This script may well need to be broken up into several separate
#  component scripts in the future.  But not right away.
#
#  This script does not launch a task in the background, but may
#  itself be running in the background. 
#
#  The following environment variables can be set ahead of time, but
#  the main point of this script is that if they are not set then
#  it hunts for the proper directory from a list of candidates, and
#  uses the first one it finds.  TLA is an abreviation for Bluestone.
#
#   TLA_ROOT_DIR    - Bluestone specific ROOT macros and libraries
#   PREFIX	    - location of other software, including ROOT itself
#   LIGOTOOLS       - where LIGOtools lives, if it is installed
#   ROOTYSYS        - main directory for a generic ROOT installation
#   DMT_ROOT_LIBS   - ROOT libraries specific to LIGO DMT
#   DMT_ROOT_MACROS - ROOT marcros specific to LIGO DMT
#   TLA_DATA_DIR    - top level data directory containing frames/trend/...
#   TLA_ROOT_DIR    - Bluestone specific ROOT macros and libraries
#   TLA_VI_DIR	    - Bluestone Virtual Instruments (nominally $TLA_ROOT_DIR/vi)
#
#
#  Error codes for this script should start at 20 or above.
#
# Eric Myers <myers@spy-hill.net>  - 21 April 2006
# @(#) $Id: run_dmtroot.sh,v 1.42 2009/03/24 15:33:10 myers Exp $
#######################################################################

DEBUG_LEVEL=${DEBUG_LEVEL-'1'}

echo `basename $0` $*
echo "Start:  `date` " 


##############
# Functions:

unlock_exit() {  # remove lock files and exit 
   RC=$1
   TIMESTAMP=`date +%s`    
   echo "$TIMESTAMP $RC"  > $DONEFILE
   /bin/rm -f $LOCKFILE
   /bin/rm -f $PIDFILE
   echo "End:  `date`   Return code: $RC "
   echo " "
   exit $RC
}


debug_msg() { # Show a message if debug level is high enough
    local LVL=$1
    [ -z "$LVL" ]  && return
    [ $LVL -gt 0 ] && shift
    local MSG="$*"
    if [ $DEBUG_LEVEL -ge $LVL ]; then 
      echo "> [$LVL] $MSG " >>/dev/stderr
    fi
}

debug_msg 1 "Debug level: $DEBUG_LEVEL "
debug_msg 2 HOME is $HOME
debug_msg 3 USER is $USER



##
# Job Control: Unique plot ID, used to identify files in the analysis
#     This can be used to identify the jobs submitted to the Grid.  

TaskID=$1 ; shift   
echo "Task ID: $TaskID"
if [ -z "$TaskID" ]; then
  echo "$0 requires a unique task ID "
  exit 21
fi

ROOT_CMD_LINE="$*"

if [ -z "$ROOT_CMD_LINE" ]; then
  echo "$0 requires a ROOT command"
  exit 23
fi


##
# SLOT:
#   We assume we are already in the working directory, called a "slot".
#   But if the parent directory is not named "slot" then ... who cares?

SLOT=`pwd`
D=`dirname $SLOT`
D=`basename $D`
if [ "$D" != "slot" ]; then
  echo "Not a 'slot' directory. (So what?!?)"
fi
export SLOT

echo "TLA version: $Name:  $ "
echo "Analysis Host: `hostname`"
echo "Working directory:  $SLOT"

# Go to the slot directory to do the work...

cd $SLOT


##########
# Job Control: Lockfile and image output files

DONEFILE=${TaskID}.done
LOCKFILE=${TaskID}.lock
PIDFILE=${TaskID}.pid
CMDFILE=${TaskID}.cmd

if [ -f $LOCKFILE -a ! -f $DONEFILE ]; then
  X=""
  if [ -s $PIDFILE ]; then 
    BG_PID=`tail $PIDFILE`
    BG_PS=`ps h -p $BG_PID`
    if [ -n "$BG_PS" ]; then
      X=$BG_PS[5]
      echo "process $BG_PID, $X appears to still be running."
      unlock_exit 29
    fi
  fi
fi


touch $LOCKFILE
/bin/rm -f $DONEFILE
echo $$ > $PIDFILE


######################################################################
# Primary Configuration:
#
#  Where the stuff we need lives on this machine.  We need this to
#  work at Hanford, Caltech, Spy Hill, Argonne, and possibly on a Grid
#  node where the software may be installed either in some
#  semi-permenant place or maybe in /tmp?  That's a lot of different
#  ways to have things arranged. 
#
#  The environment cannot be easily set by the invoking PHP script
#  because PHP scripts are not allowed to alter their environment (for
#  security reasons).  So we have to do it on the "outside", in
#  preparation to running ROOT. 
#
#  This part of the script performs the same general function as the
#  root-setup script in DMT, though with different results.
#
#  TODO: this section of the script could be moved to a separate script
#        which can then be sourced by any other script which would use ROOT
#        Call it perhaps env_dmtroot.sh and source it?


##
# TLA_ROOT_DIR is where we find our OWN version of ROOT macros, 
#  separate from those distributed with ROOT or with LIGOTOOLS or GDS  
#  It may or may not also contain DMT macros and GDS libraries as
#  subdirectories (so we will check for them here).
#
#  This tries to find TLA_ROOT_DIR by several methods:
#    1) inherited from environment variable TLA_ROOT_DIR
#    2) look at how this script itself was invoked (using $0 or $PWD)
#    3) look relative to the slot directory

LIST="$TLA_ROOT_DIR"
LIST="$LIST `dirname $0` $PWD "

# Relative to the slot...

D=`dirname $SLOT`
D=`dirname $D`
LIST="$LIST ${D}/root"
D=`dirname $D`
LIST="$LIST ${D}/root"
D=`dirname $D`
LIST="$LIST ${D}/root"

debug_msg 2 "TLA_ROOT_DIR candiates: $LIST"

TLA_ROOT_DIR=""
for DIR in $LIST
do
   debug_msg 4 "* Looking for TLA ROOT stuff in ${DIR}..."
   if [ -d $DIR ]; then
     if [ -x ${DIR}/run_dmtroot.sh ]; then      
       TLA_ROOT_DIR=${DIR}
       break
     fi
   fi
done

export TLA_ROOT_DIR
debug_msg 1 "setenv TLA_ROOT_DIR $TLA_ROOT_DIR "


# Directory containing transformations (Virtual Instrumens)
#
D=`dirname $TLA_ROOT_DIR`
D="$D/vi"

export TLA_VI_DIR=${TLA_VI_DIR-"$D"}
debug_msg 1 "setenv TLA_VI_DIR $TLA_VI_DIR "


##
# PREFIX is another likely place for software to be installed (including ROOT)
#    This could be set to /usr/local or /opt/lscsoft, etc...
#    No need to make it /opt, as we already also check there anyway.
#    For development /home/myers/opt is the likely place.

PREFIX=""
if [ -d /home/myers/opt ]; then
  PREFIX=/home/myers/opt
elif [ -d /net/moonflower/home/myers/opt ]; then
  PREFIX=/net/moonflower/home/myers/opt
fi

[ -d "$PREFIX" ] && debug_msg 1 "setenv PREFIX $PREFIX "
[ -d "$PREFIX" ] || echo "No PREFIX set" 


##########
# LIGOTOOLS is the top-level directory for LIGO software installed
#   via the LIGOtools package manager.   We need to know early on
#   if and where this may be installed, even though it is our last choice.
#
#   Right now I2U2 works using this to load DMT macros but not libraries 
#     or ROOT itself.
#   Someday it might be nice to get both libraries and macros via LIGOtools.
#   Or, I'd like to have it work even without LIGOtools installed.

LIST="$LIGOTOOLS"
LIST="$LIST /ligotools /opt/ligotools /usr/local/ligotools"
[ -d $PREFIX ] && LIST="${PREFIX}/ligotools $LIST" 

LIGOTOOLS=""
for DIR in $LIST
do
   if [ -d $DIR ]; then
     if [ -d $DIR/packages/dmtroot/active ]; then 
       LIGOTOOLS=$DIR
       break
     fi
   fi
done

if [ "x$LIGOTOOLS" = "x" -o ! -d $LIGOTOOLS ]; then
   echo "Cannot find LIGOTOOLS.  Boogers.  "
   # In the future it will not be an error to not have LIGOtools, 
   # provided we can still find the DMT macros.  But for now we need it.
   unlock_exit 27
else 
  export LIGOTOOLS
  debug_msg 1 "setenv LIGOTOOLS $LIGOTOOLS "
fi


##########
# ROOTYSYS is where the main ROOT executable lives, along with the
#   standard macros from CERN.   The version of ROOT used for an
#   analysis should match the version of ROOT used to compile the 
#   dynamic shared object libraries (.so libraries) from GDS.
#   That's highly likely if everything is via LIGOtools, but still
#   possible even if it's not.


LIST="$ROOTSYS"
[ -d $PREFIX ] && LIST="${PREFIX}/root $LIST " 
LIST="$LIST /opt/root";

# Versions on tekoa (which we don't currently use):
LIST="$LIST `ls -1d /opt/CERN/root_* 2>/dev/null` "

# Look for LIGOtools ROOT if nothing else is available
[ -d $LIGOTOOLS ] && LIST="$LIST $LIGOTOOLS/packages/root/active/root"

ROOTSYS=""
for DIR in $LIST
do
   if [ -d $DIR ]; then
     if [ -x $DIR/bin/root ]; then      
       ROOTSYS=$DIR
       ROOT_EXE=$ROOTSYS/bin/root
       break
     fi
   fi
done

if [ x$ROOTSYS = "x" -o ! -d $ROOTSYS ]; then
   echo "Cannot find ROOTSYS ($ROOTSYS) for ROOT executable."
   unlock_exit 22
fi
export ROOTSYS
debug_msg 1 "setenv ROOTSYS $ROOTSYS "


##
# DMT_ROOT_LIBS
#      Location of ROOT libraries for DMT.  These are the .so files
#      from LIGO GDS, and they have to have been built against the
#      same version of ROOT.

LIST="$DMT_ROOT_LIBS "
LIST="LIST $TLA_ROOT_DIR/rootlib "
[ -d $PREFIX ] && LIST="$LIST ${PREFIX}/lscsoft/gds/lib "
# /opt/lscsoft on alvarez
LIST="$LIST /opt/lscsoft/gds/lib " 
# Older GDS on tekoa
LIST="$LIST /opt/dmt/rev_2.10.3/lib/"

DMT_ROOT_LIBS=""
for DIR in $LIST
do
   if [ -d $DIR ]; then
     if [ -f ${DIR}/libgdsbase.so ]; then
       DMT_ROOT_LIBS=$DIR
       break
     fi
    fi
done

debug_msg 2 "DMT_ROOT_LIBS so far is $DMT_ROOT_LIBS"

# if LIGOtools exists and we've not found anything then use that
# This is a bit more complicated because there are several directories 

if [ "x$DMT_ROOT_LIBS" = "x" -a -d $LIGOTOOLS ]; then
  if [ -d ${LIGOTOOLS}/packages/dmtroot/active/rootlib ]; then
    if [ -d ${LIGOTOOLS}/packages/basegdsroot/active/rootlib ]; then
      DMT_ROOT_LIBS="${LIGOTOOLS}/packages/basegdsroot/active/rootlib"
      DMT_ROOT_LIBS="$DMT_ROOT_LIBS:${LIGOTOOLS}/packages/dmtroot/active/rootlib"
    fi
  fi
fi

export DMT_ROOT_LIBS
debug_msg 1 "setenv DMT_ROOT_LIBS $DMT_ROOT_LIBS "


##
# DMT_ROOT_MACROS
#      Location of ROOT macro files for DMT.
#      We start with $LIGOTOOLS/packages/dmtroot/active/macros
#      Because that is what has worked, but we will change that later
#      so that LIGOtools comes last

LIST="$DMT_ROOT_MACROS"
[ -d $LIGOTOOLS ] && LIST="$LIST ${LIGOTOOLS}/packages/dmtroot/active/macros"
LIST="$LIST $TLA_ROOT_DIR/macros "
# Fallback on tekoa
LIST="$LIST /opt/dmt/rev_2.10.3/root/macros "
LIST="$LIST ${TLA_ROOT_DIR}/macros "

DMT_ROOT_MACROS=""
for DIR in $LIST
do
   if [ -d $DIR ]; then
     if [ -f ${DIR}/uniqueName.cc ]; then 
       DMT_ROOT_MACROS=$DIR
       break
     fi
   fi
done

export DMT_ROOT_MACROS
debug_msg 1 "setenv DMT_ROOT_MACROS $DMT_ROOT_MACROS "


##
# TLA_DATA_DIR points to top level directory for LIGO data, 
#    ending with .../frames and containing a "trend" subdirectory
#  These are all candidates to look for, and we use the first found.

LIST="$TLA_DATA_DIR"
LIST="$LIST /data/ligo/frames" 
LIST="$LIST /disks/i2u2/ligo/data/frames"
LIST="$LIST /disks/i2u2-dev/ligo/data/frames"
LIST="$LIST /home/i2u2/ligo/data/frames/"
LIST="$LIST /net/rosebud/archive3/data/ligo/frames"
LIST="$LIST /usr04/i2u2/ligo/data/frames"
LIST="$LIST /disks1/myers/data/ligo/frames"
LIST="$LIST $HOME/i2u2/html/tla_dev/data/frames"

TLA_DATA_DIR=""
for DIR in $LIST
do
   if [ -d $DIR ]; then
     if [ -d $DIR/trend ]; then      
       TLA_DATA_DIR=$DIR
       break
     fi
   fi
done

export TLA_DATA_DIR
debug_msg 1 "setenv TLA_DATA_DIR $TLA_DATA_DIR "
echo "Data Directory: $TLA_DATA_DIR "


if [ ! -d "$TLA_DATA_DIR" ]; then
  echo "Cannot find data directory: $TLA_DATA_DIR "
  unlock_exit 26
fi 



##
# LD_LIBRARY_PATH
#    ROOT 4 will only load libraries from LD_LIBRARY_PATH, even if you 
#    specify a full path.  This is probably an attempt at security.
#    In any case, we need to set that correctly to match $ROOTSYS

LD_LIBRARY_PATH="."

if [ ! -z "$DMT_ROOT_LIBS" ]; then
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${DMT_ROOT_LIBS}
fi
if [ -d ${ROOTSYS}/lib ]; then
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ROOTSYS}/lib
fi


# If we don't have DMT_ROOT_LIBS set yet and we do have LIGOTOOLS set
# Then try to get the library path right via LIGOtools

if [ -z "$DMT_ROOT_LIBS" -a -d $LIGOTOOLS ]; then 
  LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${LIGOTOOLS}/packages/dmtroot/active/rootlib/"
  LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${LIGOTOOLS}/packages/basegdsroot/active/rootlib/"
  LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${LIGOTOOLS}/packages/eventtool/active/rootlib/"
  # add any others as needed
fi

export LD_LIBRARY_PATH
debug_msg 1 "setenv LD_LIBRARY_PATH $LD_LIBRARY_PATH "


##
# Execution Path: insert ours up front

OLDPATH=$PATH
PATH=${TLA_ROOT_DIR}
PATH=${PATH}:${ROOTSYS}/bin
PATH=${PATH}:${OLDPATH}

export PATH
debug_msg 2 PATH is $PATH


##
# Sanity checks.

if [ -z "$DMT_ROOT_MACROS" -o -z "$DMT_ROOT_LIBS" -o -z "$LD_LIBRARY_PATH" ]; then 
  echo "Houston, we have a problem.  "
  unlock_exit 24
fi

if [ -z "$TLA_ROOT_DIR" -o -z "$ROOTSYS" -o -z "TLA_$DATA_DIR" ]; then 
  echo "Houston, we have a REAL problem.  "
  unlock_exit 25
fi


# End of environment configuration
######################################################################
# ----------------cut here -----------------
######################################################################

##
# Clear out any previous graphics or result files

EPSFILE=${TaskID}.eps
JPGFILE=${TaskID}.jpg
PNGFILE=${TaskID}.png
SVGFILE=${TaskID}.svg
TMPFILE=${TaskID}.tmp

/bin/rm -f  $EPSFILE $JPGFILE $PNGFILE $SVGFILE $TMPFILE


## 
# Run ROOT

#  (assumes LIGOTOOLS/packages/dmtroot/active/macros/ is where dmtroot 
#  macros live) 

# Important! Unset DMTINPUT, or else dmtroot tries to read frame files from it!

unset DMTINPUT

# Build command line:

CMD="nice $ROOT_EXE -b -l -n -q ${ROOT_CMD_LINE}"

# TODO: right now plot_chan.C includes dmtroot.C itself, 
# but I would rather do this, if I can, someday.  It doesn't yet work.
#CMD="root -b -l -n -q  ${TLA_ROOT_DIR}/dmtroot.C  ${ROOT_CMD_LINLE} "

echo "% $CMD"
TIMESTAMP=`date +%s`    
echo "$TIMESTAMP $CMD" >> $CMDFILE
$CMD
ROOT_RC=$?

if [ $ROOT_RC -ne 0 ]; then
  echo "Error running ROOT. Return code: $ROOT_RC "
else
  echo "ROOT ran ok.  "
fi



###############################################################################
# ----------------cut here -----------------
#
# This is post-processing of the images which can be moved
# from this script to some other script, and run on the server
# not out on the Grid
#

#!/bin/sh
#
#  epsimg converts an EPS file to several image formats.
#         It uses ghostscript to convert EPS to JPEG.
#         It uses ghostscript to convert EPS to PNG
#         It inserts the proper XML header for an existing SVG
#
# TODO: this should probably become a separate script which
#       is invoked after SUCCESSFUL completion of a job
#       and is run on the server, not on the Grid node.

EPSFILE=${TaskID}.eps
JPGFILE=${TaskID}.jpg
PNGFILE=${TaskID}.png
SVGFILE=${TaskID}.svg
TMPFILE=${TaskID}.tmp

##
# EPS turned into JPG and PNG


if [ -f $EPSFILE ]; then

  /usr/bin/gs -dBATCH -dNOPAUSE -dQUIET  -sDEVICE=jpeg \
              -dEPSFitPage -dDEVICEWIDTHPOINTS=700 -dDEVICEHEIGHTPOINTS=500 \
              -sOutputFile=$JPGFILE   $EPSFILE 

  /usr/bin/gs -dBATCH -dNOPAUSE -dQUIET  -sDEVICE=png16m \
              -dEPSFitPage -dDEVICEWIDTHPOINTS=700 -dDEVICEHEIGHTPOINTS=500 \
              -sOutputFile=$PNGFILE   $EPSFILE 
fi

##
# SVG (Scalable Vector Graphics) output from ROOT requires an XML header

if [ -f $SVGFILE ]; then
  debug_msg 3 "Adding XML header line to SVG file..."
  echo "<?xml-stylesheet ?>"  >$TMPFILE
  /bin/cat $SVGFILE >> $TMPFILE
  /bin/mv -f $TMPFILE $SVGFILE
fi

# ----------------cut here -----------------
######################################################################
# Job Control: Finish

unlock_exit $ROOT_RC

##
