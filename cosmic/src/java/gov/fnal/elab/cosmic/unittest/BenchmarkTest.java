package gov.fnal.elab.cosmic.unittest;

import org.junit.*;
import static org.junit.Assert.*;
import gov.fnal.elab.cosmic.bless.*;
import gov.fnal.elab.*;
import gov.fnal.elab.datacatalog.impl.vds.*;
import gov.fnal.elab.datacatalog.DataCatalogProvider;
import gov.fnal.elab.datacatalog.query.ResultSet;
import java.text.*;
import java.util.Date;

public class BenchmarkTest {
	public Elab elab = Elab.getElab(null, "cosmic");
	public SimpleDateFormat DATEFORMAT = new SimpleDateFormat("MM/dd/yyyy");
	public DataCatalogProvider dcp = ElabFactory.getDataCatalogProvider(elab);
	
	@Test
	public void test_getUnblessedWithBenchmark() {
		ResultSet rs = null;
		String answer = "";
		try {
			Date startDate = DATEFORMAT.parse("01/01/2013");
			Date endDate = DATEFORMAT.parse("12/01/2013");
			rs = Benchmark.getUnblessedWithBenchmark(elab, startDate, endDate);
		} catch (Exception e) {
			answer = "There was an exception";
		}
		assertTrue(rs != null);
		assertTrue(answer.equals(""));
		try {
			rs = Benchmark.getUnblessedWithBenchmark(null, null, null);
		} catch (Exception e) {
			answer = "There was an exception";
		}
		assertTrue(answer.equals(""));
	}//end of test_getUnblessedWithBenchmark
	
	@Test
	public void test_getSplitBenchmarkInfoByInterval() {
		ResultSet rs = null;
		String answer = "";
		try {
			Date startDate = DATEFORMAT.parse("01/01/2013");
			Date endDate = DATEFORMAT.parse("12/01/2013");
			rs = Benchmark.getSplitBenchmarkInfoByInterval(elab, startDate, endDate);
		} catch (Exception e) {
			answer = "There was an exception";
		}
		assertTrue(rs != null);
		assertTrue(answer.equals(""));
		try {
			rs = Benchmark.getSplitBenchmarkInfoByInterval(null, null, null);
		} catch (Exception e) {
			answer = "There was an exception";
		}
		assertTrue(answer.equals(""));		
	}//end of test_getSplitBenchmarkInfoByInterval
	
	@Test
	public void test_getUnblessedSplitDetails() {
		ResultSet rs = null;
		String answer = "";
		try {
			Date startDate = DATEFORMAT.parse("01/01/2013");
			Date endDate = DATEFORMAT.parse("12/01/2013");
			rs = Benchmark.getUnblessedSplitDetails(elab, startDate, endDate);
		} catch (Exception e) {
			answer = "There was an exception";
		}
		assertTrue(rs != null);
		assertTrue(answer.equals(""));
		try {
			rs = Benchmark.getUnblessedSplitDetails(null, null, null);
		} catch (Exception e) {
			answer = "There was an exception";
		}
		assertTrue(answer.equals(""));		
	}//end of test_getUnblessedSplitDetails
	
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
		assertTrue(answer.equals(""));
	}//end of test_getDefaultBenchmark

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
		assertTrue(answer.equals(""));
	}//end of test_getBlessedDataFilesByBenchmark
	
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
		assertTrue(answer.equals(""));
	}//end of test_getBenchmarkFileName
	
	@Test
	public void test_getBenchmarkCandidates() {
		String answer = "";

		try {
			int detector = 6119;
			Date startDate = DATEFORMAT.parse("01/01/2013");
			Date endDate = DATEFORMAT.parse("12/01/2013");
			ResultSet rs = Benchmark.getBenchmarkCandidates(elab, detector, startDate, endDate);
		} catch (Exception e) {
			answer = "There was an exception";
		}
		try {
			int detector = 6118;
			Date startDate = DATEFORMAT.parse("01/01/2013");
			Date endDate = DATEFORMAT.parse("12/01/2013");
			ResultSet rs = Benchmark.getBenchmarkCandidates(null, detector, startDate, endDate);
		} catch (Exception e) {
			answer = "There was an exception";
		}
		try {
			int detector = -1;
			Date startDate = DATEFORMAT.parse("01/01/2013");
			Date endDate = DATEFORMAT.parse("12/01/2013");
			ResultSet rs = Benchmark.getBenchmarkCandidates(elab, detector, startDate, endDate);
		} catch (Exception e) {
			answer = "There was an exception";
		}		
		try {
			Date startDate = DATEFORMAT.parse("01/01/2013");
			Date endDate = DATEFORMAT.parse("12/01/2013");
			ResultSet rs = Benchmark.getBenchmarkCandidates(elab, null, startDate, endDate);
		} catch (Exception e) {
			answer = "There was an exception";
		}
		try {
			int detector = 6118;
			ResultSet rs = Benchmark.getBenchmarkCandidates(elab, null, null, null);
		} catch (Exception e) {
			answer = "There was an exception";
		}	
		assertTrue(answer.equals(""));
	}//end of test_getBenchmarkCandidates
	
	@Test
	public void test_setFileAsBenchmark() {

		String answer = "";
		try {
			String benchmark = "6119.2013.0101.1";
			String benchmarkLabel = "EP-Testing-benchmark-label";
			Long duration = Benchmark.setFileAsBenchmark(dcp, benchmark, benchmarkLabel);
		} catch (Exception e) {
			answer = "There was an exception";
		}	
		try {
			String benchmark = "6119.2013.0101.1";
			String benchmarkLabel = "EP-Testing-benchmark-label";
			Long duration = Benchmark.setFileAsBenchmark(null, benchmark, benchmarkLabel);
			assertTrue(duration == 0);
		} catch (Exception e) {
			answer = "There was an exception";
		}
		try {
			String benchmarkLabel = "EP-Testing-benchmark-label";
			Long duration = Benchmark.setFileAsBenchmark(dcp, null, benchmarkLabel);
			assertTrue(duration == 0);
		} catch (Exception e) {
			answer = "There was an exception";
		}
		try {
			String benchmark = "";
			String benchmarkLabel = "EP-Testing-benchmark-label";
			Long duration = Benchmark.setFileAsBenchmark(dcp, benchmark, benchmarkLabel);
			assertTrue(duration == 0);
		} catch (Exception e) {
			answer = "There was an exception";
		}		
		try {
			String benchmark = "6119.2013.0101.1";
			Long duration = Benchmark.setFileAsBenchmark(dcp, benchmark, null);
			assertTrue(duration == 0);
		} catch (Exception e) {
			answer = "There was an exception";
		}		
		assertTrue(answer.equals(""));
	}//end of test_setFileAsBenchmark
	
	@Test
	public void test_getIcons() {
		String answer = "";
		try {
			VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry("6119.2013.0322.1");
			String display = Benchmark.getIcons(entry);
		} catch (Exception e) {
			answer = "There was an exception";			
		}
		try {
			String display = Benchmark.getIcons(null);
		} catch (Exception e) {
			answer = "There was an exception";			
		}
		assertTrue(answer.equals(""));
	}//end of test_getIcons
	
	@Test
	public void test_getAllFilesByBenchmarkGeometry() {
		String answer = "";
		try {
			int detector = 6119;
			String benchmark = "6119.2013.0322.1";
			ResultSet rs = Benchmark.getAllFilesByBenchmarkGeometry(elab, detector, benchmark);
		} catch (Exception e) {
			answer = "There was an exception";			
		}				
		try {
			int detector = 6119;
			String benchmark = "6119.2013.0322.1";
			ResultSet rs = Benchmark.getAllFilesByBenchmarkGeometry(null, detector, benchmark);
		} catch (Exception e) {
			answer = "There was an exception";			
		}
		try {
			String benchmark = "6119.2013.0322.1";
			ResultSet rs = Benchmark.getAllFilesByBenchmarkGeometry(elab, null, benchmark);
		} catch (Exception e) {
			answer = "There was an exception";			
		}	
		try {
			int detector = 6119;
			ResultSet rs = Benchmark.getAllFilesByBenchmarkGeometry(elab, detector, null);
		} catch (Exception e) {
			answer = "There was an exception";			
		}			
		try {
			int detector = -1;
			String benchmark = "6119.2013.0322.1";
			ResultSet rs = Benchmark.getAllFilesByBenchmarkGeometry(elab, detector, benchmark);
		} catch (Exception e) {
			answer = "There was an exception";			
		}			
		try {
			int detector = 6119;
			String benchmark = "";
			ResultSet rs = Benchmark.getAllFilesByBenchmarkGeometry(elab, detector, benchmark);
		} catch (Exception e) {
			answer = "There was an exception";			
		}	
		assertTrue(answer.equals(""));
	}//end of test_getAllFilesByBenchmarkGeometry
	
	@Test
	public void test_getSplitBlessLink() {
		String answer = "";
		try {
			VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry("6119.2013.0322.1");
			String link = Benchmark.getSplitBlessLink(entry);
		} catch (Exception e) {
			answer = "There was an exception";			
		}
		try {
			String display = Benchmark.getSplitBlessLink(null);
		} catch (Exception e) {
			answer = "There was an exception";			
		}
		assertTrue(answer.equals(""));		
	}//end of test_getSplitBlessLink
	
	@Test
	public void test_getUnblessedFilesByBenchmarkGeometry() {
		String answer = "";
		try {
			int detector = 6119;
			String benchmark = "6119.2013.0322.1";
			ResultSet rs = Benchmark.getUnblessedFilesByBenchmarkGeometry(elab, detector, benchmark);
		} catch (Exception e) {
			answer = "There was an exception";			
		}				
		try {
			int detector = 6119;
			String benchmark = "6119.2013.0322.1";
			ResultSet rs = Benchmark.getUnblessedFilesByBenchmarkGeometry(null, detector, benchmark);
		} catch (Exception e) {
			answer = "There was an exception";			
		}
		try {
			String benchmark = "6119.2013.0322.1";
			ResultSet rs = Benchmark.getUnblessedFilesByBenchmarkGeometry(elab, null, benchmark);
		} catch (Exception e) {
			answer = "There was an exception";			
		}	
		try {
			int detector = 6119;
			ResultSet rs = Benchmark.getUnblessedFilesByBenchmarkGeometry(elab, detector, null);
		} catch (Exception e) {
			answer = "There was an exception";			
		}			
		try {
			int detector = -1;
			String benchmark = "6119.2013.0322.1";
			ResultSet rs = Benchmark.getUnblessedFilesByBenchmarkGeometry(elab, detector, benchmark);
		} catch (Exception e) {
			answer = "There was an exception";			
		}			
		try {
			int detector = 6119;
			String benchmark = "";
			ResultSet rs = Benchmark.getUnblessedFilesByBenchmarkGeometry(elab, detector, benchmark);
		} catch (Exception e) {
			answer = "There was an exception";			
		}		
		assertTrue(answer.equals(""));
	}//end of test_getUnblessedFilesByBenchmarkGeometry
}