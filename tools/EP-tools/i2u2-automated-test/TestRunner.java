import org.junit.runner.JUnitCore;
import org.junit.runner.Result;
import org.junit.runner.notification.Failure;
import java.util.*;

public class TestRunner {
	
	public TestRunner() {
	}
	
	public static void main (String[] args) {
		String runningFrom = "";
		if (args.length > 0) {
			runningFrom = args[0];
		}
		List<Class> testCases = new ArrayList();
		testCases.add(LoginAllElabs.class);
		//testCases.add(CosmicAnalysisTest.class);
		
		System.out.println("Running automated tests: total of " + String.valueOf(testCases.size()));
		int i = 1;
		for (Class testCase : testCases) {
			System.out.println(String.valueOf(i) + "-Running test for class: " + testCase.getName());
			String message = runTestCase(testCase);
			System.out.println(message);
			i++;
		}
	}
	
	private static String runTestCase(Class testCase) {
		String message = "";
		try {
			Result result = JUnitCore.runClasses(testCase);
			for (Failure failure : result.getFailures()) {
				message = failure.getTrace() + "\n" + failure.toString() + "\n"+ failure.getMessage()+ "\n" + failure.getException();
			}
			message += "Tested OK: " + result.getFailures().toString();
			
		} catch (Exception e) {
			message = e.getMessage();
		}
		return message;
	}
}

//need to add all libraries to CLASSPATH
/*
 * create folders
 *  /users/whoever/i2u2Tests
 * 
 * copy all java code + lib + junit folders
 * then
 * 
 * echo $CLASSPATH
 * export JUNIT_HOME=/users/edit/i2u2Tests/junit
 * export JUNIT_LIBS=/users/edit/i2u2Tests/lib
 * export CLASSPATH=$CLASSPATH:$JUNIT_HOME/*:.
 * export CLASSPATH=$CLASSPATH:$JUNIT_LIBS/*:.
 * echo $CLASSPATH
 *
 *  
 * compile
 *  
 *  javac -Xlint:unchecked TestSettings.java TestRunner.java CosmicAnalysisTest.java
 *  
 * run
 *  
 *  java TestRunner
 */

