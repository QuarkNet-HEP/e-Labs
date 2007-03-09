#!/bin/sh

# sanity check
ME=`whoami` 
if [ "$ME" != "quarkcat" ]; then
    echo "ERROR: su to quarkcat did not work. Check for bugs, why don't cha?"
    exit 1
fi

if [ "X${QN_HOME}" = "X" ]; then
    echo "Your QN_HOME variable is not set."
    echo -n "New value for QN_HOME: [/export/d1/quarknet]: "
    read SET_QN
    if [ "X$SET_QN" = "X" ]; then
        QN_HOME=/export/d1/quarknet
    else
        QN_HOME=$SET_QN
    fi
    export QN_HOME
fi

if [ "X${VDS_HOME}" = "X" ]; then
    echo "Your VDS_HOME is not set."
    echo -n "New value for VDS_HOME [/export/d1/quarknet/portal/vds]: "
    read SET_VDS
    if [ "X$SET_VDS" = "X" ]; then
        VDS_HOME=/export/d1/quarknet/portal/vds
    else
        VDS_HOME=$SET_VDS
    fi
    export VDS_HOME
fi

echo
echo "Taking down server."
$QN_HOME/tomcat/bin/shutdown.sh

echo
echo "Checking for new web files." 
if [ -e src/jsp ]; then
    echo "Found new web files; copying them. Backups in evitable:~egilbert/backups."
    cp -r src/jsp/* $QN_HOME/tomcat/webapps/elab/cosmic
else
    echo "No new web files found."
fi

echo
echo "Checking for new perl code."
if [ -e src/perl ]; then
    echo "Copying perl code to application directory."
    for PL in $( ls src/perl ); do
        if [ "$PL" != "CVS" ]; then
            if [ "$PL" = "src/perl/Split.pl" ]; then
                cp src/perl/$PL $QN_HOME/portal/application
            elif [ "$PL" = "src/perl/CommonSubs.pl" ]; then
                cp src/perl/$PL $QN_HOME/portal/application
            elif [ -d src/perl/$PL ]; then
                cp -r src/perl/$PL $QN_HOME/portal/application
            else
                cp src/perl/$PL $QN_HOME/portal/application/Quarknet.Cosmic__$PL
            fi
        fi
    done
else
    echo "No new perl code found."
fi

echo
echo "Checking for new transformations."
if [ -e "src/vdl/transformations.vdl" ]; then
    echo "New transformations found; loading them."
    PREV_DIR=`pwd`
    cd $VDS_HOME
    . setup-user-env.sh
    ./bin/vdlt2vdlx $PREV_DIR/src/vdl/transformations.vdl $PREV_DIR/src/vdl/transformations.vdlx
    ./bin/updatevdc $PREV_DIR/src/vdl/transformations.vdlx
    echo "REMINDER: Update tc.data if new perl nodes have been added to workflows."
    cd $PREV_DIR
else
    echo "No new transformations found."
fi

echo
echo "Checking if new elab.jar should be built."
if [ -e src/java ]; then
    echo "Building new elab.jar; must use CVS head versions for this."
    cd src/java
    HOST=`hostname | perl -pi -e 's/(\w*)\.(.*)/\1/g'`
    export HOST
    ant -f build.xml-$HOST dist
    if [ $? -ne 0 ]; then
        echo "ERROR: Compilation did not complete succesfully."
        echo "Not copying elab.jar. Take care of this manually."
    else
        echo "Copying elab.jar."
        cp dist/elab*.jar $QN_HOME/tomcat/webapps/elab/WEB-INF/lib/elab.jar
    fi
else
    echo "No new elab.jar required."
fi

echo
echo "Checking for new templates."
if [ -e templates ]; then
    echo "Found new templates; copying them."
    cp templates/*.htmt $QN_HOME/portal/templates
else
    echo "No new templates found."
fi

echo
echo "Restarting server."
$QN_HOME/tomcat/bin/startup.sh

echo
echo "Sleeping to let Tomcat catch its breath."
sleep 5

echo
echo "Returning to user $USER."
