#!/bin/sh
#
# Deploy QuarkNet/Grid code based on a CVS tag.
# 
# usage: rollout.sh tag_name

if [ "X$1" = "X" ]; then
    echo "Usage: rollout.sh tag_name"
    echo "       tag_name indicates CVS tag name for this release."
    echo ""
    echo "Prerequisites:"
    echo "       Run as your normal login. It will switch to quarkcat."
    echo "       You must have run eval \`ssh-agent\` and ssh-add."
    echo "       You can set QN_HOME and VDS_HOME."
    exit 1
fi

# check out code from CVS
echo "Checking out tag $1 from CVS."
TEMP_DIR=_temp$RANDOM
mkdir $TEMP_DIR
cd $TEMP_DIR
cvs -d:ext:cvsuser@cdcvs.fnal.gov:/cvs/cd co -r $1 quarknet
if [ -e quarknet/src/java ]; then
    cvs -d:ext:cvsuser@cdcvs.fnal.gov:/cvs/cd co quarknet/src/java
    cd quarknet/src/java
    cvs update -A
    cd ../../..
fi
chgrp -R quarknet quarknet/
chmod -R g+w quarknet # gives quarkcat permission to build elab.jar
cd quarknet

echo
echo "Switching to quarkcat; please provide password."
su -m quarkcat -c "~/quarknet/tools/rollout-quarkcat.sh"

echo
echo "Checking for database patches."
if [ -e src/sql ]; then
    echo "Loading patch into database."
    for PATCH in $( ls src/sql/patch* ); do
        if [ `hostname` = "evitable.uchicago.edu" ]; then
            /opt/pgsql/bin/psql -f $PATCH userdbdev8085_2004_1215 vdsdev8085
        else
            /export/d2/pgsql/bin/psql -f $PATCH userdb8085_2004_0819 vds8085
        fi
    done
else
    echo "No database patches to load."
fi

echo
echo "Deleting temp directory $TEMP_DIR."
cd ../..
rm -fr $TEMP_DIR

echo
echo "Using wget to load the settings in common.jsp."
if [ `hostname` = "evitable.uchicago.edu" ]; then
    wget http://evitable.uchicago.edu:8085/elab/cosmic/rolloutLoad.jsp
    wget http://evitable.uchicago.edu:8085/elab/cosmic/cacheStats.jsp
else
    ssh evitable 'wget http://quarknet.uchicago.edu/elab/cosmic/rolloutLoad.jsp'
    ssh evitable 'wget http://quarknet.uchicago.edu/elab/cosmic/cacheStats.jsp'
fi

rm -fr rolloutLoad.jsp

exit 0
