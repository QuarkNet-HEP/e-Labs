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
		String yesNo = "no";
		try {
			yesNo = LogbookTools.getYesNoGeneral(140, 1, cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(yesNo.equals("yes"));		
	    assertTrue(message.equals(""));		
		message = "";
		yesNo = "no";
		try {
			yesNo = LogbookTools.getYesNoGeneral(0, -1, null);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(yesNo.equals("no"));		
	    assertTrue(message.equals(""));		
	}//end of test_getYesNoGeneral

	@Test
	public void test_getNewCommentsGeneral() {
		String message = "";
		String newFlag = "";
		try {
			newFlag = LogbookTools.getNewCommentsGeneral(140, 1, cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(message.equals(""));		
		message = "";
		try {
			newFlag = LogbookTools.getNewCommentsGeneral(0, -1, null);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(message.equals(""));			
	}//end of test_getNewCommentsGeneral

	@Test
	public void test_getNewLogEntriesGeneral() {
		String message = "";
		String newFlag = "";
		try {
			newFlag = LogbookTools.getNewLogEntriesGeneral(140, 1, cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(message.equals(""));		
		message = "";
		try {
			newFlag = LogbookTools.getNewLogEntriesGeneral(0, -1, null);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(message.equals(""));			
	}//end of test_getNewLogEntriesGeneral	
	
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
	    message = "";
	    rs = null;
		try {
			rs = LogbookTools.getKeywordTracker(0, -1, null);
		} catch (Exception e) {
			message = e.getMessage();
		}
		assertTrue(rs == null);
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
	    message = "";
	    rs = null;
		try {
			rs = LogbookTools.getLogbookKeywordItems(-1, null, null);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(rs == null);		
	    assertTrue(message.equals(""));		    
	}//end of test_getLogbookKeywordItems

	@Test
	public void test_getLogbookKeywordItemsNewLogs() {
		String message = "";
		ResultSet rs = null;
		try {
			rs = LogbookTools.getLogbookKeywordItems(1, " AND keyword.type IN ('SW','S') ",cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(rs != null);		
	    assertTrue(message.equals(""));		
	    message = "";
	    rs = null;
		try {
			rs = LogbookTools.getLogbookKeywordItems(-1, "x", cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(rs != null);		
	    assertTrue(message.equals(""));			
	}//end of test_getLogbookKeywordItemsNewLogs
	
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
	    message = "";
	    rs = null;
		try {
			rs = LogbookTools.getKeywordDetailsByProject(1, null, cosmicElab);	
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(rs != null);		
	    assertTrue(message.equals(""));		    
	}//end of test_getLogbookKeywordItems

	@Test
	public void test_buildGroupLinks() {
		String message = "";
		String links = "";
		try {
			ElabGroup user = cosmicElab.authenticate("TestTeacher", "i2u2tt");
			links = LogbookTools.buildGroupLinks(user, "teacher-logbook-group.jsp");
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(!links.equals(""));		
	    assertTrue(message.equals(""));	
	    message = "";
	    links = "";
		try {
			links = LogbookTools.buildGroupLinks(null, null);
		} catch (Exception e) {
			message = e.getMessage();
		}
		assertTrue(links.equals(""));
		assertTrue(message.equals(""));
	}//end of test_buildGroupLinks
	
	@Test
	public void test_buildLinksToKeywords() {
		String message = "";
		String groupLinks = "";
		String links = "";
		HashMap keywordTracker = new HashMap();
		ResultSet rs = null;
		try {
			rs = LogbookTools.getKeywordTracker(140, 1, cosmicElab);
			while (rs.next()){
				if (rs.getObject("keyword_id") != null) {
					Integer keyword_id= (Integer) rs.getObject("keyword_id");
					Object new_comments = rs.getObject("new_comments");
					keywordTracker.put(keyword_id.intValue(), new_comments);
				} 
			}
			rs = LogbookTools.getLogbookKeywordItems(1, " AND keyword.type IN ('SW','S') ",cosmicElab);
			groupLinks = LogbookTools.buildGroupLinksToKeywords(rs, keywordTracker, "general", "undergrads", 140);
			links = LogbookTools.buildStudentKeywordLinks(rs, keywordTracker, "general");
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(rs != null);		
	    assertTrue(keywordTracker.size() > 0);
	    assertTrue(!groupLinks.equals(""));
	    assertTrue(message.equals(""));		
	}//end of test_buildGroupLinksToKeywords
	
	@Test
	public void test_buildTeacherKeywordLinks() {
		String message = "";
		String links = "";
		try {
			links = LogbookTools.buildTeacherKeywordLinks(1, "general", 2, cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(!links.equals(""));		
	    assertTrue(message.equals(""));	
	    message = "";
	    links = "";
		try {
			links = LogbookTools.buildTeacherKeywordLinks(-1, null, -1, null);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(links.equals(""));		
	    assertTrue(message.equals(""));		    
	}//end of test_buildTeacherKeywordLinks
	

	//up to here
	@Test
	public void test_getKeywordDetails() {
		String message = "";
		ResultSet rs = null;
		try {
			rs = LogbookTools.getKeywordDetails("general", cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(rs != null);		
	    assertTrue(message.equals(""));		
		try {
			rs = LogbookTools.getKeywordDetails(null, cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(message.equals(""));	
	}//end of test_getKeywordDetails
	
	@Test
	public void test_getLogbookEntriesForAllGroups() {
		String message = "";
		ResultSet rs = null;
		try {
			rs = LogbookTools.getLogbookEntriesForAllGroups(cosmicElab, 1, 694, true);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(rs != null);		
	    assertTrue(message.equals(""));		
	}//end of test_getLogbookEntriesForAllGroups
	
	@Test
	public void test_getLogbookEntriesForGroup() {
		String message = "";
		ResultSet rs = null;
		try {
			rs = LogbookTools.getLogbookEntriesForGroup(cosmicElab, 1, 694, 140);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(rs != null);		
	    assertTrue(message.equals(""));				
	}//end of test_getLogbookEntriesForGroup

	@Test
	public void test_getLogbookEntriesKeyword() {
		String message = "";
		ResultSet rs = null;
		try {
			rs = LogbookTools.getLogbookEntriesKeyword(32, 694, true, cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(rs != null);		
	    assertTrue(message.equals(""));						
	}//end of test_getLogbookEntriesKeyword

	@Test
	public void test_getLogbookEntries() {
		String message = "";
		ResultSet rs = null;
		try {
			rs = LogbookTools.getLogbookEntries(32, cosmicElab, 1, 140);	
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(rs != null);		
	    assertTrue(message.equals(""));		
	}//end of test_getLogbookEntries

	@Test
	public void test_getLogbookEntriesTeacher() {
		String message = "";
		ResultSet rs = null;
		try {
			rs = LogbookTools.getLogbookEntriesTeacher(1, 140, 694, "teacher", cosmicElab);	
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(rs != null);		
	    assertTrue(message.equals(""));		
	}//end of test_getLogbookEntriesTeacher
	
	@Test
	public void test_getLogbookEntriesTools() {
		String message = "";
		ResultSet rs = null;
		try {
			rs = LogbookTools.getLogbookEntriesTool(1, 32, 140, cosmicElab);	
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(rs != null);		
	    assertTrue(message.equals(""));		
	}//end of test_getLogbookEntriesTools
	
	@Test
	public void test_buildExistingComments() {
		String commentDetails = null;
		String message = "";
		try {
			//140: undergrads
			commentDetails = LogbookTools.buildExistingComments(32, 140, 1, "undergrads", cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}		
	    assertTrue(message.equals(""));			
	    commentDetails = null;
	    message = "";
		try {
			commentDetails = LogbookTools.buildExistingComments(-1, -1, -1, null, cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}		
	    assertTrue(message.equals(""));
	}//end of test_buildExistingComments

	@Test
	public void test_getCommentEntries() {
		String message = "";
		ResultSet rs = null;
		try {
			rs = LogbookTools.getCommentEntries(32, 140, 1, cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(rs != null);		
	    assertTrue(message.equals(""));			
	}//end of test_getCommentEntries
	
	@Test
	public void test_buildLogbookEntriesPlusComments() {
		String commentDetails = null;
		String message = "";
		try {
			//140: undergrads
			commentDetails = LogbookTools.buildLogbookEntriesPlusComments(1, 32, 140, "undergrads", cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}		
	    assertTrue(message.equals(""));			
		try {
			commentDetails = LogbookTools.buildLogbookEntriesPlusComments(-1, -1, -1, null, cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}		
	    assertTrue(message.equals(""));			
	}//end of test_buildLogbookEntriesPlusComments

	@Test
	public void test_getCommentDetailsKeyword() {
		String message = "";
		ResultSet rs = null;
		try {
			rs = LogbookTools.getCommentDetailsKeyword(32, 140, 1, cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(rs != null);		
	    assertTrue(message.equals(""));		
	}//end of test_getLogbookEntries
	
	@Test
	public void test_getGroupNameFromId() {
		String groupName = "";
		String message = "";
		try {
			//140: undergrads
			groupName = LogbookTools.getGroupNameFromId(140, cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}		
	    assertTrue(groupName.equals("undergrads"));		
	    assertTrue(message.equals(""));			
	    message = "";
		try {
			groupName = LogbookTools.getGroupNameFromId(-1, null);
		} catch (Exception e) {
			message = e.getMessage();
		}		
	    assertTrue(message.equals(""));			
	}//end of test_getGroupNameFromId
	
	@Test
	public void test_getSectionText() {
		String section = "";
		String message = "";
		try {
			section = LogbookTools.getSectionText("A");
		} catch (Exception e) {
			message = e.getMessage();
		}		
	    assertTrue(!section.equals(""));		
	    assertTrue(message.equals(""));					
	}//end of test_getSectionText
	
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
	    getCommentDetails(log_id);
	    buildCommentDetails(log_id);
	    updateResetCommentForLogbookEntry(log_id);
	    deleteLogbookEntry(log_id);
	}//end of test_insertLogbookEntry	

	@Test
	public void test_insertLogbookEntryTeacher() {
		String message = "";
		int log_id = -1;
		try {
			log_id = LogbookTools.insertLogbookEntryTeacher(1, 694, 140, "Unit-testing log entry", "teacher", cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}		
	    assertTrue(log_id != -1);		
	    assertTrue(message.equals(""));	
	    updateResetLogbookEntry(log_id);
	    deleteLogbookEntry(log_id);
	}//end of test_insertLogbookEntryTeacher
	
	public void updateResetLogbookEntry(int log_id) {
        String message = "";
        int result = -1;
        try {
	         result = LogbookTools.updateResetLogbookEntry(log_id, cosmicElab);
        } catch (Exception e) {
        	message = e.getMessage();
        }        
        assertTrue(result != -1);        
        assertTrue(message.equals(""));   		
	}//end of updateResetLogbookEntry
	
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
	
	public void getCommentDetails(int log_id) {
		String message = "";
		ResultSet rs = null;
		try {
			rs = LogbookTools.getCommentDetails(log_id, cosmicElab);
		} catch (Exception e) {
			message = e.getMessage();
		}
	    assertTrue(rs != null);		
	    assertTrue(message.equals(""));				
	}//end of getCommentDetails
	
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