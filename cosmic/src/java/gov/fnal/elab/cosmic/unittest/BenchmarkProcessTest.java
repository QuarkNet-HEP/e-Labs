package gov.fnal.elab.cosmic.unittest;

import org.junit.*;
import static org.junit.Assert.*;
import gov.fnal.elab.Elab;
import gov.fnal.elab.cosmic.bless.*;
import gov.fnal.elab.datacatalog.query.ResultSet;
import java.text.SimpleDateFormat;
import java.util.*;

public class BenchmarkProcessTest {
	public Elab elab = Elab.getElab(null, "cosmic");
	public SimpleDateFormat DATEFORMAT = new SimpleDateFormat("MM/dd/yyyy");
	
	@Test
	public void test_BlessDataFiles () {

		String answer = "";
		try {
			String detector = "6148";
			String benchmark = Benchmark.getDefaultBenchmark(elab, 6148);
			Date startDate = DATEFORMAT.parse("01/01/2013");
			Date endDate = DATEFORMAT.parse("12/01/2013");
			ResultSet rs = Benchmark.getUnblessedWithBenchmark(elab, startDate, endDate);
			if (rs != null) {
				String[] filesToBless = rs.getLfnArray();
				BlessProcess bp = new BlessProcess();
				ArrayList<String> results = new ArrayList<String>();
				results = bp.BlessDatafiles(elab, detector, filesToBless, benchmark);
			}
		} catch (Exception e) {
			answer = "There was an exception " + e.getMessage();
		}
	}
	
	@Test
	public void test_convertToHMS() {
		String answer = "";
		try {
			BlessProcess bp = new BlessProcess();
			String formattedTime = bp.convertToHMS("60592");
			assertTrue(formattedTime.equals("16:49:52"));
		} catch (Exception e) {
			answer = "There was an exception " + e.getMessage();
		}		
		try {
			BlessProcess bp = new BlessProcess();
			String formattedTime = bp.convertToHMS(null);
			assertTrue(formattedTime.equals(""));
		} catch (Exception e) {
			answer = "There was an exception " + e.getMessage();
		}
	}
}