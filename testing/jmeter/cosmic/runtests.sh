#HOST=`hostname`
HOST=www12.i2u2.org
PORT=9080
JMETER_HOME=/home/quarkcat/sw/jmeter

for jar in $JMETER_HOME/lib/*.jar; do
	CLASSPATH=$jar:$CLASSPATH
done

for jmx in *.jmx; do
	echo "Updating host in $jmx"
	sed -e "s/<stringProp name=\"HTTPSampler.domain\">www.*<\/stringProp>/<stringProp name=\"HTTPSampler.domain\">$HOST<\/stringProp>/" $jmx >tmp
	if [ "$?" != "0" ]; then
		echo "Sed failed"
		exit 1
	fi
	rm -f $jmx
	mv tmp $jmx
	sed -e "s/<stringProp name=\"HTTPSampler.port\">.*<\/stringProp>/<stringProp name=\"HTTPSampler.port\">$PORT<\/stringProp>/" $jmx >tmp
	if [ "$?" != "0" ]; then
		echo "Sed failed"
		exit 1
	fi
	rm -f $jmx
	mv tmp $jmx
done
ant all
#ant htmlreports

