package gov.fnal.elab.unittest;

import org.junit.*;

import static org.junit.Assert.*;
import gov.fnal.elab.logbook.*;
import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabFactory;
import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.ElabProperties;

import java.sql.ResultSet;
import java.util.*;

public class LogbookToolsTest {
	public Elab cosmicElab = Elab.getElab(null, "cosmic");

	//this function retrieves if there are any entries for a group under the general keyword
	@Test
	public void test_getYesNoGeneral() {
		String message = "";
		String yesNo = "No";
		try {
			yesNo = LogbookTools.getYesNoGeneral("TestTeacher", 1, cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(yesNo.equals("Yes"));		
	    assertTrue(message.equals(""));		
	}//end of test_getYesNoGeneral

	@Test
	public void test_getKeywordTracker() {
		//getKeywordTracker(String groupName, int project_id, Elab elab)
		String message = "";
		ResultSet rs = null;
		try {
			rs = LogbookTools.getKeywordTracker("undergrads", 1, cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(rs != null);		
	    assertTrue(message.equals(""));		
	}//end of test_getKeywordTracker

	@Test
	public void test_getLogbookKeywordItems() {
		//LogbookTools.getLogbookKeywordItems(project_id, typeConstraint, elab);
		String message = "";
		ResultSet rs = null;
		try {
			rs = LogbookTools.getLogbookKeywordItems(1, " AND keyword.type IN ('SW','S') ",cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(rs != null);		
	    assertTrue(message.equals(""));		
	}//end of test_getLogbookKeywordItems

	
	@Test
	public void test_getLogId() {
		String message = "";
		int log_id = -1;
		try {
			//undergrads, cosmic, keyword_id, role, elab
			log_id = LogbookTools.getLogId(140, 1, 32, "user", cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(log_id == 8904);		
	    assertTrue(message.equals(""));		
	}//end of test_getLogId
	

	
}//end of LogbookToolsTest class