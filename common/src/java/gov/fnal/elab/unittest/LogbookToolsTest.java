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
	public int newLogId = -1;
	public int newCommentId = -1;
	//student-logbook calls
	
	//this function retrieves if there are any entries for a group under the general keyword
	@Test
	public void test_getYesNoGeneral() {
		String message = "";
		String yesNo = "No";
		try {
			yesNo = LogbookTools.getYesNoGeneral("undergrads", 1, cosmicElab);
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
	public void test_getKeywordDetailsByProject() {
		String message = "";
		ResultSet rs = null;
		try {
			rs = LogbookTools.getKeywordDetailsByProject(1, "graphs", cosmicElab);	
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(rs != null);		
	    assertTrue(message.equals(""));		
	}//end of test_getLogbookKeywordItems

	@Test
	public void test_insertLogbookEntry() {
		String message = "";
		int log_id = -1;
		try {
			//140: undergrads
			log_id = LogbookTools.insertLogbookEntry(1, 140, 32, "Unit-testing log entry", "user", cosmicElab);
			newLogId = log_id;
		} catch (Exception e) {
			message = e.getMessage();
		}		
	    assertTrue(newLogId != -1);		
	    assertTrue(message.equals(""));				
	}//end of test_insertLogbookEntry	

	@Test
	public void test_insertComment() {
		String message = "";
		int comment_id = -1;
		try {
			//140: undergrads
			comment_id = LogbookTools.insertComment(newLogId, "Unit-testing comment entry", cosmicElab);
			newCommentId = comment_id;
		} catch (Exception e) {
			message = e.getMessage();
		}		
	    assertTrue(newCommentId != -1);		
	    assertTrue(message.equals(""));			
	}//end of test_insertComment
	
	@Test
	public void test_getLogbookEntries() {
		String message = "";
		ResultSet rs = null;
		try {
			rs = rs = LogbookTools.getLogbookEntries(32, cosmicElab, 1, 140);	
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(rs != null);		
	    assertTrue(message.equals(""));		
	}//end of test_getLogbookEntries
	
	@Test
	public void test_getCommentCount() {
		Long comment_count = 0L;
		String message = "";
		int comment_id = -1;
		try {
			//140: undergrads
			comment_count = LogbookTools.getCommentCount(newLogId, cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}		
	    assertTrue(comment_count == 1);		
	    assertTrue(message.equals(""));			
	}//end of test_getCommentCount

	@Test
	public void test_getCommentCountNew() {
		Long comment_new = 0L;
		String message = "";
		int comment_id = -1;
		try {
			//140: undergrads
			comment_new = LogbookTools.getCommentCountNew(newLogId, cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}		
	    assertTrue(comment_new == 1);		
	    assertTrue(message.equals(""));			
	}//end of test_getCommentCountNew
	//continue here
	//ArrayList commentDetails = LogbookTools.buildCommentDetails(log_id, comment_header, elab);													
	//LogbookTools.updateResetCommentsforLogbookEntry(logMark, elab);
}//end of LogbookToolsTest class