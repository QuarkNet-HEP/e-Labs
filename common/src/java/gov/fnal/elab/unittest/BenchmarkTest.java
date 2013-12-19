package gov.fnal.elab.unittest;

import org.junit.*;
import static org.junit.Assert.*;
import gov.fnal.elab.cosmic.bless.*;
import gov.fnal.elab.*;
import gov.fnal.elab.datacatalog.query.ResultSet;

public class BenchmarkTest {
	public Elab elab = Elab.getElab(null, "cosmic");

	@Test
	public void test_getDefaultBenchmark() {
		String answer = "";
		try {
			int detector = 6119;
			answer = Benchmark.getDefaultBenchmark(elab, detector);
		} catch (Exception e) {
			answer = "There was an exception";
		}
		try {
			answer = Benchmark.getDefaultBenchmark(elab, null);
		} catch (Exception e) {
			answer = "There was an exception";
		}
		try {
			int detector = 6148;
			answer = Benchmark.getDefaultBenchmark(null, detector);
		} catch (Exception e) {
			answer = "There was an exception";
		}
		try {
			int detector = -1;
			answer = Benchmark.getDefaultBenchmark(null, detector);
		} catch (Exception e) {
			answer = "There was an exception";
		}
	}

	@Test
	public void test_getBlessedDataFilesByBenchmark() {
		String answer = "";
		try {
			String splitFile = "6119.2013.0322.1";
			ResultSet rs = Benchmark.getBlessedDataFilesByBenchmark(elab, splitFile);
		} catch (Exception e) {
			answer = "There was an exception";
		}
		try {
			ResultSet rs = Benchmark.getBlessedDataFilesByBenchmark(elab, null);
		} catch (Exception e) {
			answer = "There was an exception";
		}
		try {
			String splitFile = "6148.2007.1005.0";
			ResultSet rs = Benchmark.getBlessedDataFilesByBenchmark(null, splitFile);
		} catch (Exception e) {
			answer = "There was an exception";
		}
		try {
			String splitFile = " ";
			ResultSet rs = Benchmark.getBlessedDataFilesByBenchmark(elab, splitFile);
		} catch (Exception e) {
			answer = "There was an exception";
		}
	}
	
	@Test
	public void test_getBenchmarkFileName() {
		String answer = "";
		try {
			int detector = 6119;
			ResultSet rs = Benchmark.getBenchmarkFileName(elab, detector);
		} catch (Exception e) {
			answer = "There was an exception";
		}
		try {
			ResultSet rs = Benchmark.getBenchmarkFileName(elab, null);
		} catch (Exception e) {
			answer = "There was an exception";
		}
		try {
			int detector = 6148;
			ResultSet rs = Benchmark.getBenchmarkFileName(null, detector);
		} catch (Exception e) {
			answer = "There was an exception";
		}
		try {
			int detector = -1;
			ResultSet rs = Benchmark.getBenchmarkFileName(null, detector);
		} catch (Exception e) {
			answer = "There was an exception";
		}
	}
	
}