package gov.fnal.elab.cosmic.unittest;

import java.io.File;
import java.io.*;
import java.util.*;

import org.junit.*;
import static org.junit.Assert.*;
import gov.fnal.elab.Elab;
import gov.fnal.elab.cosmic.plot.*;
import org.apache.commons.io.*;

public class TimeOfFlightTest {
	public Elab elab = Elab.getElab(null, "cosmic");
	public TimeOfFlightDataStream tofds = null;
	public String analysisDir = "";
	
	@Test
	public void test_getTimeOfFlightStreamData() {
		//for this test, need to create a fixed directory inside /disks/i2u2-dev/cosmic/data/unittest/timeofflight/
		//the file for testing is the eventCandidates which needs to be in this folder
		//the *Benchmark files need to be there for comparison. These files were created with the 
		//code from TimeOfFlightDataStream as it is today, if this code changes, the *Benchmark files need to change
		analysisDir = elab.getProperties().getDataDir() + "/unittest/timeofflight";
		String answer = "";
		try {
			tofds = new TimeOfFlightDataStream(analysisDir, "", "");
		} catch (Exception e) {
			answer = "There was an exception";
		}
		assertTrue(answer.equals(""));
		assertTrue(tofds != null);
	}//end of test_getTimeOfFlightStreamData

	@Test
	public void test_getTimeDiff() {
		if (tofds != null) {
			List<TimeOfFlightDataStream.TimeDiff> tdGroup = tofds.getArrays();
			TimeOfFlightDataStream.TimeDiff td1 = tdGroup.get(0);
			int size = td1.getSize();
			String color = td1.getColor();
			assertTrue(color.equals("red"));
			TimeOfFlightDataStream.TimeDiff td2 = tdGroup.get(1);
			String symbol = td2.getSymbol();
			assertTrue(symbol.equals("triangle"));
		}		
	}//end of test_getTimeDiff
	
	
	@Test
	public void test_compareFilesToBenchmarks() {
		String answer = "";
		boolean isequal1 = false;
		boolean isequal2 = false;
		try {
			File fileCreated1 = new File(analysisDir+"/timeOfFlightPlotData");
			File fileCreated2 = new File(analysisDir+"/timeOfFlightRawData");
			
			File benchmark1 = new File(analysisDir+"/Benchmarks/timeOfFlightPlotDataBenchmark");
			File benchmark2 = new File(analysisDir+"/Benchmarks/timeOfFlightRawDataBenchmark");
			
			isequal1 = FileUtils.contentEquals(fileCreated1, benchmark1);
			isequal2 = FileUtils.contentEquals(fileCreated2, benchmark2);

		} catch (Exception ex) {
			answer = "There was an exception";
		}
		assertTrue(isequal1);
		assertTrue(isequal2);
	}
	
}//end of TimeOfFlightTest