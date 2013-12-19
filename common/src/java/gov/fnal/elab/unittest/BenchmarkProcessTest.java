package gov.fnal.elab.unittest;

import org.junit.*;
import static org.junit.Assert.*;
import gov.fnal.elab.Elab;
import gov.fnal.elab.cosmic.bless.*;
import java.util.*;

public class BenchmarkProcessTest {
	/*
	public Elab elab = Elab.getElab(null, "cosmic");
	
	@Test
	public void test_BlessDataFiles () {

		String answer = "";
		try {
			String detector = "6148";
			String benchmark = "6148.2013.0101.1";
			String[] filesToBless = {"6148.2013.0201.1", "6148.2013.0202.1"};
			BlessProcess bp = new BlessProcess();
			ArrayList<String> results = new ArrayList<String>();
			results = bp.BlessDatafiles(elab, detector, filesToBless, benchmark);
		} catch (Exception e) {
			answer = "There was an exception";
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
			answer = "There was an exception";
		}		
		try {
			BlessProcess bp = new BlessProcess();
			String formattedTime = bp.convertToHMS(null);
			assertTrue(formattedTime.equals(""));
		} catch (Exception e) {
			answer = "There was an exception";
		}
	}
	*/
}