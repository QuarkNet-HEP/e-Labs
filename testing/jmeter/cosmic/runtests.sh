#HOST=`hostname`
HOST=www12.i2u2.org
PORT=9080
#JMETER_HOME=/home/mike/work/i2u2/jakarta-jmeter-2.3
#JMETER_HOME=/home/quarkcat/sw/jmeter
JMETER_HOME=/home/hategan/quarknet-t/jmeter

for jar in $JMETER_HOME/lib/*.jar; do
	CLASSPATH=$jar:$CLASSPATH
done

echo $CLASSPATH
export CLASSPATH

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
ant all
#ant htmlreports

