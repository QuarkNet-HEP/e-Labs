
checkenv() {
	if [ "$2" == "" ]; then
		echo "$1 is not set"
		exit 1
	fi
}

checkenv JMETER_TEST_HOST $JMETER_TEST_HOST
HOST=$JMETER_TEST_HOST
checkenv JMETER_TEST_PORT $JMETER_TEST_PORT
PORT=$JMETER_TEST_PORT

MPWD=${PWD//\//\\\/}
for jmx in *.jmx; do
	echo "Updating host in $jmx"
	sed -e "s/<stringProp name=\"HTTPSampler.domain\">www.*<\/stringProp>/<stringProp name=\"HTTPSampler.domain\">$HOST<\/stringProp>/" $jmx >tmp
	if [ "$?" != "0" ]; then
		echo "Sed failed"
		exit 1
	fi
	rm -f $jmx
	mv tmp $jmx
	echo "Updating port in $jmx"
	sed -e "s/<stringProp name=\"HTTPSampler.port\">.*<\/stringProp>/<stringProp name=\"HTTPSampler.port\">$PORT<\/stringProp>/" $jmx >tmp
	if [ "$?" != "0" ]; then
		echo "Sed failed"
		exit 1
	fi
	rm -f $jmx
	mv tmp $jmx
	echo "Updating path to compare.sh in $jmx"
	sed -e "s/bin\/sh .*compare.sh/bin\/sh $MPWD\/compare.sh/" $jmx >tmp
	if [ "$?" != "0" ]; then
		echo "Sed failed"
		exit 1
	fi
	rm -f $jmx
	mv tmp $jmx
done

REFPATH=`pwd`
export REFPATH
checkenv JMETER_HOME $JMETER_HOME
checkenv JMETER_OUTPUT_DIR $JMETER_OUTPUT_DIR

for jar in $JMETER_HOME/lib/*.jar; do
	CLASSPATH=$jar:$CLASSPATH
done

echo $CLASSPATH
export CLASSPATH

ant -Djmeterhome=$JMETER_HOME -Doutputdir=$JMETER_OUTPUT_DIR all
ant -Djmeterhome=$JMETER_HOME -Doutputdir=$JMETER_OUTPUT_DIR htmlreports

