package gov.fnal.elab.cosmic.unittest;

import java.io.File;
import java.util.*;

import org.apache.commons.io.FileUtils;
import org.junit.*;

import static org.junit.Assert.*;
import gov.fnal.elab.Elab;
import gov.fnal.elab.cosmic.analysis.ThresholdTimes;
import gov.fnal.elab.cosmic.plot.*;

public class ShowerStudyTest {
	public Elab elab = Elab.getElab(null, "cosmic");
	//for this test, need to create a fixed directory inside /disks/etc
	public String analysisDir = elab.getProperties().getDataDir() + "/unittest/shower";
	public String perlDir = "perl /home/quarkcat/sw/i2u2svn/cosmic/src/perl/";
	//public String perlDir = "perl /users/edit/quarkcat/sw/i2u2svn/cosmic/src/perl/";
	
	@Test
	public void test_split() {
		//first cleanup
		File split = new File(analysisDir+"/6119/6119.2014.1008.0");
		File bless = new File(analysisDir+"/6119/6119.2014.1008.0.bless");
		if (split.exists()) {
			split.delete();
		}
		if (bless.exists()) {
			bless.delete();
		}
		split = new File(analysisDir+"/6148/6148.2014.1008.0");
		bless = new File(analysisDir+"/6148/6148.2014.1008.0.bless");
		if (split.exists()) {
			split.delete();
		}
		if (bless.exists()) {
			bless.delete();
		}
		String rawdata = analysisDir+"/6119.2014.1016.ShortShower2fold.raw";
		String answer = "";
		String runInstructions = perlDir+"Split.pl "+rawdata+" "+analysisDir+"/6119"+" "+"6119";
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
		rawdata = analysisDir+"/6148.2014.1008.ShortShower2fold.raw";
		answer = "";
		runInstructions = perlDir+"Split.pl "+rawdata+" "+analysisDir+"/6148"+" "+"6148";
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
	}//end of test_split

	@Test
	public void test_compareSplitFilesToBenchmarks() {
		String answer = "";
		boolean isequal1 = false;
		boolean isequal2 = false;
		boolean isequal3 = false;
		boolean isequal4 = true;
		boolean isequal5 = true;
		boolean isequal6 = true;
		boolean isequal7 = true;
		boolean isequal8 = true;
		try {
			File fileCreated1 = new File(analysisDir+"/6119/6119.2014.1008.0");
			File fileCreated2 = new File(analysisDir+"/6119/6119.2014.1008.0.bless");
			File fileCreated3 = new File(analysisDir+"/6119.2014.1016.ShortShower2fold.raw.errors");
			File fileCreated4 = new File(analysisDir+"/6119.2014.1016.ShortShower2fold.raw.meta");
			File fileCreated5 = new File(analysisDir+"/6148/6148.2014.1008.0");
			File fileCreated6 = new File(analysisDir+"/6148/6148.2014.1008.0.bless");
			File fileCreated7 = new File(analysisDir+"/6148.2014.1008.ShortShower2fold.raw.errors");
			File fileCreated8 = new File(analysisDir+"/6148.2014.1008.ShortShower2fold.raw.meta");
			
			File benchmark1 = new File(analysisDir+"/Benchmarks/6119.2014.1008.0.benchmark");
			File benchmark2 = new File(analysisDir+"/Benchmarks/6119.2014.1008.0.bless.benchmark");
			File benchmark3 = new File(analysisDir+"/Benchmarks/6119.2014.1016.ShortShower2fold.raw.errors.benchmark");
			File benchmark4 = new File(analysisDir+"/Benchmarks/6119.2014.1016.ShortShower2fold.raw.meta.benchmark");
			File benchmark5 = new File(analysisDir+"/Benchmarks/6148.2014.1008.0.benchmark");
			File benchmark6 = new File(analysisDir+"/Benchmarks/6148.2014.1008.0.bless.benchmark");
			File benchmark7 = new File(analysisDir+"/Benchmarks/6148.2014.1008.ShortShower2fold.raw.errors.benchmark");
			File benchmark8 = new File(analysisDir+"/Benchmarks/6148.2014.1008.ShortShower2fold.raw.meta.benchmark");
			
			isequal1 = FileUtils.contentEquals(fileCreated1, benchmark1);
			isequal2 = FileUtils.contentEquals(fileCreated2, benchmark2);
			isequal3 = FileUtils.contentEquals(fileCreated3, benchmark3);
			isequal4 = FileUtils.contentEquals(fileCreated4, benchmark4);
			isequal5 = FileUtils.contentEquals(fileCreated5, benchmark5);
			isequal6 = FileUtils.contentEquals(fileCreated6, benchmark6);
			isequal7 = FileUtils.contentEquals(fileCreated7, benchmark7);
			isequal8 = FileUtils.contentEquals(fileCreated8, benchmark8);

		} catch (Exception ex) {
			answer = "There was an exception";
		}
		assertTrue(isequal1);
		assertTrue(isequal2);
		assertTrue(isequal3);
		//cannot compare the meta file because the creation date should be different :)
		assertTrue(!isequal4);
		assertTrue(isequal5);
		assertTrue(isequal6);
		assertTrue(isequal7);
		//cannot compare the meta file because the creation date should be different :)
		assertTrue(!isequal8);
	}//end of test_compareSplitFilesToBenchmarks
	
	@Test
	public void test_ThresholdFile() {
		String answer = "";
		File thresh = new File(analysisDir+"/6119/6119.2014.1008.0.thresh");
		if (thresh.exists()) {
			thresh.delete();
		}
		String[] inputFiles = {"6119.2014.1008.0"};
		Elab threshElab = Elab.getElab(null, "showertest");
		try {
			ThresholdTimes t = new ThresholdTimes(threshElab, inputFiles, "6119");
			t.createThresholdFiles();
		} catch (Exception ex) {
			answer = "There was an exception";
		}		
		thresh = new File(analysisDir+"/6148/6148.2014.1008.0.thresh");
		if (thresh.exists()) {
			thresh.delete();
		}
		inputFiles[0] = "6148.2014.1008.0";
		try {
			ThresholdTimes t = new ThresholdTimes(threshElab, inputFiles, "6148");
			t.createThresholdFiles();
		} catch (Exception ex) {
			answer = "There was an exception";
		}		
	}//end of test_ThresholdFile

	@Test
	public void test_compareThreshFileToBenchmark() {
		String answer = "";
		boolean isequal1 = false;
		boolean isequal2 = false;
		try {
			File fileCreated1 = new File(analysisDir+"/6119/6119.2014.1008.0.thresh");
			File fileCreated2 = new File(analysisDir+"/6148/6148.2014.1008.0.thresh");
			File benchmark1 = new File(analysisDir+"/Benchmarks/6119.2014.1008.0.thresh.benchmark");			
			File benchmark2 = new File(analysisDir+"/Benchmarks/6148.2014.1008.0.thresh.benchmark");			
			isequal1 = FileUtils.contentEquals(fileCreated1, benchmark1);
			isequal2 = FileUtils.contentEquals(fileCreated2, benchmark2);

		} catch (Exception ex) {
			answer = "There was an exception";
		}
		assertTrue(isequal1);
		assertTrue(isequal2);
	}//end of test_compareThreshFileToBenchmark

	@Test
	public void test_wiredelay() {
		//first cleanup
		File wd = new File(analysisDir+"/Analysis/6119.wd");
		if (wd.exists()) {
			wd.delete();
		}
		wd = new File(analysisDir+"/Analysis/6148.wd");
		if (wd.exists()) {
			wd.delete();
		}
		String answer = "";
		String arguments = analysisDir+"/6119/6119.2014.1008.0.thresh "+analysisDir+"/Analysis/6119.wd "+analysisDir+"/ 6119.geo 6119 1.12";
		String runInstructions = perlDir+"WireDelay.pl "+arguments;
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
		arguments = analysisDir+"/6148/6148.2014.1008.0.thresh "+analysisDir+"/Analysis/6148.wd "+analysisDir+"/ 6148.geo 6148 1.12";
		runInstructions = perlDir+"WireDelay.pl "+arguments;
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
	}//end of test_wiredelay
	
	@Test
	public void test_compareWireDelayToBenchmark() {
		String answer = "";
		boolean isequal1 = false;
		boolean isequal2 = false;
		try {
			File fileCreated1 = new File(analysisDir+"/Analysis/6119.wd");
			File fileCreated2 = new File(analysisDir+"/Analysis/6148.wd");
			File benchmark1 = new File(analysisDir+"/Benchmarks/6119.wd.benchmark");			
			File benchmark2 = new File(analysisDir+"/Benchmarks/6148.wd.benchmark");			
			isequal1 = FileUtils.contentEquals(fileCreated1, benchmark1);
			isequal2 = FileUtils.contentEquals(fileCreated2, benchmark2);

		} catch (Exception ex) {
			answer = "There was an exception";
		}
		assertTrue(isequal1);
		assertTrue(isequal2);
	}//end of test_compareWireDelayToBenchmark
	
	@Test
	public void test_combine() {
		//first cleanup
		File combine = new File(analysisDir+"/Analysis/combine.out");
		if (combine.exists()) {
			combine.delete();
		}
		String answer = "";
		String arguments = analysisDir+"/Analysis/6119.wd "+analysisDir+"/Analysis/6148.wd "+analysisDir+"/Analysis/combine.out ";
		String runInstructions = perlDir+"Combine.pl "+arguments;
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
	}//end of test_wiredelay

	@Test
	public void test_compareCombineToBenchmark() {
		String answer = "";
		boolean isequal1 = false;
		try {
			File fileCreated1 = new File(analysisDir+"/Analysis/combine.out");
			File benchmark1 = new File(analysisDir+"/Benchmarks/combine.out.benchmark");			
			isequal1 = FileUtils.contentEquals(fileCreated1, benchmark1);

		} catch (Exception ex) {
			answer = "There was an exception";
		}
		assertTrue(isequal1);
	}//end of test_compareCombineToBenchmark	

	@Test
	public void test_sort() {
		//first cleanup
		File sort = new File(analysisDir+"/Analysis/sort.out");
		if (sort.exists()) {
			sort.delete();
		}
		String answer = "";
		String arguments = analysisDir+"/Analysis/combine.out "+analysisDir+"/Analysis/sort.out 2 3 ";
		String runInstructions = perlDir+"Sort.pl "+arguments;
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
	}//end of test_sort

	@Test
	public void test_sortToBenchmark() {
		String answer = "";
		boolean isequal1 = false;
		try {
			File fileCreated1 = new File(analysisDir+"/Analysis/sort.out");
			File benchmark1 = new File(analysisDir+"/Benchmarks/sort.out.benchmark");			
			isequal1 = FileUtils.contentEquals(fileCreated1, benchmark1);

		} catch (Exception ex) {
			answer = "There was an exception";
		}
		assertTrue(isequal1);
	}//end of test_sortToBenchmark	

	@Test
	public void test_eventSearch() {
		//first cleanup
		File eventCandidates = new File(analysisDir+"/Analysis/eventCandidates");
		if (eventCandidates.exists()) {
			eventCandidates.delete();
		}
		String answer = "";
		String arguments = analysisDir+"/Analysis/sort.out "+analysisDir+"/Analysis/eventCandidates 1000 2 1 1 ";
		String runInstructions = perlDir+"EventSearch.pl "+arguments;
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
	}//end of test_eventSearch

	@Test
	public void test_eventCandidatesToBenchmark() {
		String answer = "";
		boolean isequal1 = false;
		try {
			File fileCreated1 = new File(analysisDir+"/Analysis/eventCandidates");
			File benchmark1 = new File(analysisDir+"/Benchmarks/eventCandidates.benchmark");			
			isequal1 = FileUtils.contentEquals(fileCreated1, benchmark1);

		} catch (Exception ex) {
			answer = "There was an exception";
		}
		assertTrue(isequal1);
	}//end of test_sortToBenchmark	


}//end of ShowerStudyTest