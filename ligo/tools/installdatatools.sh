#!/bin/bash

LOG=$PWD/installdatatools.log
DIR=~/i2u2-ligo-tools
FORCE=
OVER=
BRANCH="trunk"

usage() {
	cat <<END
This is a tool used to install:
    1. ligotools
    2. FrameDataDump2 (which is a modified version of FrameDataDump)
    3. I2U2 LIGO data conversion tools

Usage:
    installdatatools.sh [-f] [-o] [-d <dir>] [-b <branch>]
where:
    -d install the tools in <dir> (default is ~/i2u2-ligo-tools)
    
    -f (force) force installation even if the script
       detects an existing installation

    -o (overwrite) when -f is specified, don't remove previous
       installation directory, but attempt to install over it
    
    -b (branch) the SVN branch (default "trunk") to get I2U2 stuff
       from
END
	exit 1
}

stepne() {
	step "$@"
	IGNOREERROR="yes"
}

step() {
	if [ "$FIRSTSTEP" = "no" ]; then
		if [ "$?" != "0" -a "$IGNOREERROR" != "yes" ]; then
			echo "Failed"
			exit 3
		else
			echo "Done"
		fi
	else
		FIRSTSTEP="no"
	fi
	IGNOREERROR="no"
	if [ "$1" != "" ]; then
		echo -n "$1..."
		echo "$1..." >>$LOG
	fi
}

fail() {
	echo $1
	echo "See log ($LOG) for details"
	exit 4
}

while [ $# -gt 0 ]; do
	case $1 in
		-f)
			FORCE=1
			shift 1
		;;
		-d)
			DIR=$2
			shift 2
		;;
		-o)
			OVER=1
			shift 1
		;;
		*)
			usage
		;;
	esac
done

echo >>$LOG
echo >>$LOG
echo "------------------------------" >>$LOG
date >>$LOG
echo "------------------------------" >>$LOG
echo >>$LOG

if [ "${DIR:0:1}" != "/" ]; then
	#relative path; prepend pwd
	DIR=$PWD/$DIR
fi

stepne "Checking for previous installation directory"
if [ -d $DIR/tmp ]; then
	if [ -n "$FORCE" ]; then
		if [ ! -n "$OVER" ]; then
			step "Removing previous installation directory"
			rm -rf $DIR >>$LOG 2>&1
			MKDIR=1
		else
			MKDIR=
		fi
	else
		step
		fail "Previous installation directory detected. Use -f (force) to re-install."
	fi
else
	MKDIR=1
fi
if [ -n "$MKDIR" ]; then
	step "Creating directory"
	mkdir -p $DIR/tmp >>$LOG 2>&1
fi

step "Changing directory to $DIR/tmp"
cd $DIR/tmp >>$LOG 2>&1


step "Downloading ligotools_init"
wget -o $LOG -O ligotools_init_2.4.tar http://www.ldas-sw.ligo.caltech.edu/ligotools/ligotools_init/ligotools_init_2.4.tar >>$LOG 2>&1


step "Unpacking ligotools_init"
tar -xvf ligotools_init_2.4.tar >>$LOG 2>&1


step "Running ligotools_init"
#1. path to ligotools
#2. path to bin (empty for default)
#3. path to lib (empty for default)
#4. path for include (empty for default)
#5. --~-- matlab --~--
#6. --~-- root --~--
#7. --~-- java --~--
cat <<END | ./ligotools_init >>$LOG 2>&1
$DIR/ligotools






END


step "Importing ligotools environment variables"
eval `$DIR/ligotools/bin/use_ligotools` >>$LOG 2>&1


step "Downloading tclexe"
wget -o $LOG -O tclexe_8.4.7_Linux.tar.gz http://www.ldas-sw.ligo.caltech.edu/ligotools/tclexe/8.4.7/tclexe_8.4.7_Linux.tar.gz >>$LOG 2>&1


step "Installing tclexe"
# "y" to "do you want to make this the active version?"
echo "y" | ligotools_install tclexe_8.4.7_Linux.tar.gz >>$LOG 2>&1


step "Installing Fr"
#1. download install and build?
#2. make default?
#3. type 'yes' to continue
cat <<END | ligotools_update Fr >>$LOG 2>&1
y
y
yes
END


step "Installing FrContrib"
cat <<END | ligotools_update FrContrib >>$LOG 2>&1
y
y
yes
END


step "Fetching FrameDataDump2 from SVN"
svn co --non-interactive --trust-server-cert \
https://svn.ci.uchicago.edu/svn/i2u2/trunk/ligo/tools/ligotools/packages/FrContrib/v8r08/extras/ \
$DIR/ligotools/packages/FrContrib/active/extras/ >>$LOG 2>&1


step "Patching FrContrib makefile"
cat <<END | patch $DIR/ligotools/packages/FrContrib/active/Makefile >>$LOG 2>&1
7c7
< all : bin/FrSplit bin/FrameDataDump bin/FrChannels bin/FrActivityFetcher bin/FrDiff bin/FrTrend bin/FrGeomDump bin/FrFileRanges bin/createframecache.pl bin/convertfflcache.pl bin/convertlalcache.pl bin/convertldascache.sh matlab/mkframe.mex* matlab/mkframe.m matlab/readframedata.m matlab/loadframecache.m
---
> all : bin/FrSplit bin/FrameDataDump bin/FrameDataDump2 bin/FrChannels bin/FrActivityFetcher bin/FrDiff bin/FrTrend bin/FrGeomDump bin/FrFileRanges bin/createframecache.pl bin/convertfflcache.pl bin/convertlalcache.pl bin/convertldascache.sh matlab/mkframe.mex* matlab/mkframe.m matlab/readframedata.m matlab/loadframecache.m
23a24,27
> 	
> bin/FrameDataDump2 : extras/FrameDataDump2.c \$(FRVER)/src/libFrame.a
> 	mkdir -p bin
> 	gcc -O -fexceptions -fPIC extras/FrameDataDump2.c \$(FRVER)/src/libFrame.a -I\$(FRVER)/src -lm -o bin/FrameDataDump2
END

step "Changing directory to FrContrib"
pushd $DIR/ligotools/packages/FrContrib/active >>$LOG 2>&1


step "Re-compiling FrContrib"
make >>$LOG 2>&1


step "Creating symlink for FrameDataDump2"
popd >>$LOG 2>&1
ln -s $DIR/ligotools/packages/FrContrib/active/bin/FrameDataDump2 $DIR/ligotools/bin/FrameDataDump2 >>$LOG 2>&1


step "Creating I2U2 data import tools directory"
mkdir -p $DIR/i2u2tools/java >>$LOG 2>&1
mkdir -p $DIR/i2u2tools/bin >>$LOG 2>&1


step "Fetching I2U2 data import tools from SVN"
svn co --non-interactive --trust-server-cert \
https://svn.ci.uchicago.edu/svn/i2u2/trunk/ligo/src/java \
$DIR/i2u2tools/java >>$LOG 2>&1


step "Compiling I2U2 data import tools"
javac -sourcepath $DIR/i2u2tools/java $DIR/i2u2tools/java/gov/fnal/elab/ligo/data/convert/*.java >>$LOG 2>&1


for F in ImportData CheckData; do
	step "Creating binary for $F"
	cat <<END >$DIR/i2u2tools/bin/$F 2>>$LOG
#!/bin/sh
java -cp $DIR/i2u2tools/java gov.fnal.elab.ligo.data.convert.$F
END
	chmod +x $DIR/i2u2tools/bin/$F >>$LOG 2>&1
done


step "Generating environment setup script"
cat <<END >$DIR/setenv.sh 2>>$LOG
eval \`$DIR/ligotools/bin/use_ligotools\`
export PATH=$DIR/i2u2tools/bin:\$PATH
END


step "Making environment setup script executable"
chmod +x $DIR/setenv.sh  >>$LOG 2>&1


step
echo "All done. Use 'source $DIR/setenv.sh' to set up your environment"