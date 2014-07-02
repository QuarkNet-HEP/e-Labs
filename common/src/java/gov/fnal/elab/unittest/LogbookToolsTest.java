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
	//student-logbook calls
	//this function retrieves if there are any entries for a group under the general keyword
	@Test
	public void test_getYesNoGeneral() {
		String message = "";
		String yesNo = "No";
		try {
			yesNo = LogbookTools.getYesNoGeneral(140, 1, cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(yesNo.equals("yes"));		
	    assertTrue(message.equals(""));		
	}//end of test_getYesNoGeneral

	@Test
	public void test_getKeywordTracker() {
		//getKeywordTracker(String groupName, int project_id, Elab elab)
		String message = "";
		ResultSet rs = null;
		try {
			rs = LogbookTools.getKeywordTracker(140, 1, cosmicElab);
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
		} catch (Exception e) {
			message = e.getMessage();
		}		
	    assertTrue(log_id != -1);		
	    assertTrue(message.equals(""));	
	    insertComment(log_id);
	    getCommentCount(log_id);
	    getCommentCountNew(log_id);
	    buildCommentDetails(log_id);
	    updateResetCommentForLogbookEntry(log_id);
	    deleteLogbookEntry(log_id);
	}//end of test_insertLogbookEntry	

	@Test
	public void insertComment(int log_id) {
		String message = "";
		int comment_id = -1;
		try {
			//140: undergrads
			comment_id = LogbookTools.insertComment(log_id, "Unit-testing comment entry", cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}		
	    assertTrue(comment_id != -1);		
	    assertTrue(message.equals(""));			
	}//end of insertComment
	
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
	
	public void getCommentCount(int log_id) {
		Long comment_count = 0L;
		String message = "";
		int comment_id = -1;
		try {
			//140: undergrads
			comment_count = LogbookTools.getCommentCount(log_id, cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}		
	    assertTrue(comment_count == 1);		
	    assertTrue(message.equals(""));			
	}//end of getCommentCount

	public void getCommentCountNew(int log_id) {
		Long comment_new = 0L;
		String message = "";
		int comment_id = -1;
		try {
			//140: undergrads
			comment_new = LogbookTools.getCommentCountNew(log_id, cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}		
	    assertTrue(comment_new == 1);		
	    assertTrue(message.equals(""));			
	}//end of getCommentCountNew
	
	public void buildCommentDetails(int log_id) {
		ArrayList commentDetails = null;
		String message = "";
		try {
			//140: undergrads
			commentDetails = LogbookTools.buildCommentDetails(log_id, "Unit Testing: comment header", 1, cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}		
	    assertTrue(commentDetails != null);		
	    assertTrue(message.equals(""));					
	}//end of buildCommentDetails

	public void updateResetCommentForLogbookEntry(int log_id) {
        String message = "";
        int result = -1;
        try {
	         result = LogbookTools.updateResetCommentsforLogbookEntry(log_id, cosmicElab);
        } catch (Exception e) {
        	message = e.getMessage();
        }        
        assertTrue(result != -1);        
        assertTrue(message.equals(""));             
	}//end of updateResetCommentForLogbookEntry

	public void deleteLogbookEntry(int log_id) {
        String message = "";
        try {
	         LogbookTools.deleteLogbookEntry(log_id, cosmicElab);
        } catch (Exception e) {
        	message = e.getMessage();
        }        
        assertTrue(message.equals(""));      		
	}//end of deleteLogbookEntry
	
}//end of LogbookToolsTest class