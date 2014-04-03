export CLASSPATH=
export JUNIT_HOME=/users/edit/i2u2Tests/junit
export JUNIT_LIBS=/users/edit/i2u2Tests/lib
export CLASSPATH=$CLASSPATH:$JUNIT_HOME/*:.
export CLASSPATH=$CLASSPATH:$JUNIT_LIBS/*:.
echo $CLASSPATH
javac -Xlint:unchecked TestSettings.java TestRunner.java CosmicAnalysisTest.java
java TestRunner