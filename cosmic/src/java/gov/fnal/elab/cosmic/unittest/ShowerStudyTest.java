package gov.fnal.elab.cosmic.unittest;

import java.io.File;
import java.util.*;

import org.junit.*;
import static org.junit.Assert.*;
import gov.fnal.elab.Elab;
import gov.fnal.elab.cosmic.plot.*;

public class ShowerStudyTest {
	public Elab elab = Elab.getElab(null, "cosmic");

	@Test
	public void test_split() {
		//for this test, need to create a fixed directory inside /disks/etc
		String analysisDir = elab.getProperties().getDataDir() + "/unittest/shower";
		//first cleanup
		File split = new File(analysisDir+"/6119.2014.1008.0");
		File bless = new File(analysisDir+"/6119.2014.1008.0.bless");
		if (split.exists()) {
			split.delete();
		}
		if (bless.exists()) {
			bless.delete();
		}
		String rawdata = analysisDir+"/6119.2014.1016.ShortShower2fold.raw";
		String answer = "";
		String runInstructions = "perl /users/edit/quarkcat/sw/i2u2svn/cosmic/src/perl/Split.pl "+rawdata+ " "+analysisDir+" "+"6119";
		Process process;
		try {
			process = Runtime.getRuntime().exec(runInstructions); 
			process.waitFor();
			if (process.exitValue() == 0) {
				answer = "Success";
			} else {
				answer = "Failure";
			}
		} catch (Exception e) {
			answer = "There was an exception";
		}
		assertTrue(answer.equals("Success"));
	}//end of test_getTimeOfFlightStreamData

	@Test
	public void test_getTimeDiff() {
	}//end of test_getTimeDiff
	
}//end of ShowerStudyTest