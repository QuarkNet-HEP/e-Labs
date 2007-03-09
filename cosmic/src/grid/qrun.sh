#!/bin/bash

# Inputs: qrun.sh dax_file research_group study_type

if [ -d $HOME/vds-nightly/vds ]; then
      VDS_HOME=$HOME/vds-nightly/vds
      export VDS_HOME
      unset CLASSPATH
      . $VDS_HOME/setup-user-env.sh
      PATH=$VDS_HOME/bin/linux:$PATH
fi

./prepare_qjob.pl $1

DIR=`pwd`

vds-plan -Dwf.final.output=gsiftp://evitable.uchicago.edu$DIR $1 | egrep 'vds-run' > $DIR/rundir

JOB_DIR=`cat $DIR/rundir | perl -pi -e 's/vds-run\s+(.*) (.*)/\2/g'`

vds-run $JOB_DIR

./monitor_qjob.pl $JOB_DIR $2 "$3" &

sleep 2
