/*
 * Tools for the logbook
 * EPeronja-06/06/2014
 */
package gov.fnal.elab.logbook;

import java.util.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.util.Arrays;
import java.util.Collection;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.util.*;
import gov.fnal.elab.RawDataFileResolver;
import gov.fnal.elab.analysis.AnalysisRun;
import gov.fnal.elab.datacatalog.StructuredResultSet.File;
import gov.fnal.elab.datacatalog.StructuredResultSet.Month;
import gov.fnal.elab.datacatalog.StructuredResultSet.School;
import gov.fnal.elab.datacatalog.query.CatalogEntry;
import gov.fnal.elab.util.DatabaseConnectionManager;
import gov.fnal.elab.util.ElabException;

public class LogbookTools {
	///////KEYWORD TOOLS////////
	/*
	 * Check whether keyword general has any entries
	 */
	public static String getYesNoGeneral(int group_id, int project_id, Elab elab) throws ElabException {
		String yesno = "no";
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT DISTINCT keyword_id "+
            						   "  FROM log, research_group, keyword " +
            						   " WHERE keyword.keyword = 'general' "+
            						   "   AND keyword.id = log.keyword_id " +
            						   "   AND research_group.id = ? "+
            						   "   AND research_group.id = log.research_group_id "+
            						   "   AND log.project_id = ?;");

            try {              
            	ps.setInt(1, group_id); 
            	ps.setInt(2, project_id);
                rs = ps.executeQuery(); 
                if (rs.next()) {
                	yesno = "yes";
                }
            } catch (SQLException e) {
                throw e;
            }
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
        return yesno;
	}//end of getYesNoGeneral	

	/*
	 * Retrieve all keyword ids in the log for a research group
	 */
	public static ResultSet getKeywordTracker(int group_id, int project_id, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT DISTINCT keyword_id "+
            						   "  FROM log, research_group " + 
            						   " WHERE research_group.id = ? "+
            						   "   AND research_group.id = log.research_group_id "+
            						   "   AND project_id in (0, ?);");
            try {              
            	ps.setInt(1, group_id);
            	ps.setInt(2, project_id); 
                rs = ps.executeQuery(); 
            } catch (SQLException e) {
                throw e;
            }
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
        return rs;
	}//end of getKeywordTracker
	
	/*
	 * Retrieve all possible keyword items to make logs on based on the type constraint
	 */
	public static ResultSet getLogbookKeywordItems(int project_id, String groupName, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
    	String typeConstraint = " AND keyword.type IN ('SW','S') ";
    	if (groupName.startsWith("pd_") || groupName.startsWith("PD_")) {
    		typeConstraint = " AND keyword.type IN ('SW','W') ";
    	}
   	
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT id, keyword, description, section, section_id " + 
    								   "  FROM keyword "+
    								   " WHERE keyword.project_id in (0,?) " + typeConstraint + 
    				                   " ORDER by section, section_id;");
            try {              
        		ps.setInt(1, project_id);
                rs = ps.executeQuery(); 
            } catch (SQLException e) {
                throw e;
            }
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
        return rs;
	}//end of getLogbookItems	
	
	/*
	 * Retrieve keyword details by project
	 */
	public static ResultSet getKeywordDetailsByProject(int project_id, String keyword, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement(" SELECT id, keyword, description "+
            							"  FROM keyword " +
        								" WHERE keyword.project_id in (0, ?) " +
            							"   AND keyword= ?;");
            try {              
            	ps.setInt(1, project_id);
            	ps.setString(2, keyword);
                rs = ps.executeQuery(); 
            } catch (SQLException e) {
                throw e;
            }
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
        return rs;		
	}//end of getKeywordDetailsByProject

	
	/*
	 * Retrieve keyword details
	 */
	public static ResultSet getKeywordDetails(String keyword, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT id, description FROM keyword WHERE keyword = ?;");
        	ps.setString(1, keyword);
            rs = ps.executeQuery(); 
                
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
        return rs;		
	}//getKeywordDetails
	
	///////LOGBOOK TOOLS////////
	/*
	 * Retrieve all logbook entries for all groups
	 * 		-retrieveAll indicates whether only active research groups
	 */
	public static ResultSet getLogbookEntriesForAllGroups(Elab elab, int project_id, int research_group_id, boolean retrieveAll) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        String select = "SELECT log.id AS log_id, to_char(log.date_entered,'DD Mon YYYY HH12:MI AM') AS date_entered, " +
				   "	   log_text, log.ref_rg_id AS ref_rg_id, research_group.name as groupname "+
				   "  FROM log, research_group " +
				   " WHERE log.project_id = ? "+
				   "   AND log.research_group_id = ? "+
				   "   AND log.research_group_id = research_group.id "+
				   "   AND log.role = 'teacher' ";
				   if (!retrieveAll) {
					   select = select + "   AND log.ref_rg_id IN (SELECT id FROM research_group WHERE active = true AND role != 'teacher') ";
				   }
				   select = select + " ORDER BY log.ref_rg_id, log_id DESC;";
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement(select);


            try {              
                ps.setInt(1, project_id);
                ps.setInt(2, research_group_id);
                rs = ps.executeQuery(); 
            } catch (SQLException e) {
                throw e;
            }
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
        return rs;
    }//end of getLogbookEntriesForAllGroups

	/*
	 * Retrieve all logbook entries for a group
	 */
	public static ResultSet getLogbookEntriesForGroup(Elab elab, int project_id, int research_group_id, int ref_rg_id) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT log.id AS log_id, to_char(log.date_entered,'DD Mon YYYY HH12:MI AM') AS date_entered, " +
            						   "	   log_text, log.ref_rg_id AS ref_rg_id, research_group.name as groupname "+
            						   "  FROM log, research_group " +
            						   " WHERE log.project_id = ? "+
            						   "   AND log.research_group_id = ? "+
            						   "   AND log.research_group_id = research_group.id "+
            						   "   AND log.ref_rg_id = ? "+
            						   "   AND log.role='teacher' " +
            						   " ORDER BY log_id DESC;");

            
            try {              
                ps.setInt(1, project_id);
                ps.setInt(2, research_group_id);
               	ps.setInt(3, ref_rg_id);
                rs = ps.executeQuery(); 
            } catch (SQLException e) {
                throw e;
            }
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
        return rs;
    }//end of getLogbookEntriesForGroup

	/*
	 * Retrieve all logbook entries by keyword
	 * 		-retrieveAll indicates whether only active research groups
	 */
	public static ResultSet getLogbookEntriesKeyword(int keyword_id, int teacher_id, boolean retrieveAll, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
	    String select = "SELECT research_group.name AS rg_name, to_char(log.date_entered,'DD Mon YYYY HH12:MI AM') AS date_entered, "+
				"       log.log_text AS log_text,log.id AS log_id,log.new_log AS new "+
					"  FROM log, research_group " +
					" WHERE log.keyword_id = ? "+
					"   AND research_group.id = log.research_group_id "+
					"   AND research_group.teacher_id = ? "+
					"   AND research_group.role IN ('user', 'upload') ";
	    			if (!retrieveAll) {
	    			    select = select +	"   AND research_group.active = true ";
	    			}
		select = select + " ORDER BY research_group.name, log.id DESC;";

		try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement(select); 
            try {              
            	ps.setInt(1, keyword_id);
            	ps.setInt(2, teacher_id);            
                rs = ps.executeQuery();   
            } catch (SQLException e) {
                throw e;
            }
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
        return rs;			
	}//end of getLogbookEntriesKeyword

	/*
	 * Retrieve logbook entries to build entries plus comments
	 */
	public static ResultSet getLogbookEntriesTool(int project_id, int keyword_id, int research_group_id, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
	
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement( " SELECT log.id AS cur_id, to_char(log.date_entered,'DD Mon YYYY HH12:MI AM') AS date_entered, log.log_text AS cur_text "+
            							"   FROM log " + 
        								"  WHERE project_id = ? "+
            							"	 AND keyword_id = ? "+
        								"	 AND research_group_id = ? "+
            							"	 AND role = 'user' " +
        								"  ORDER BY cur_id DESC;");
            
            try {              
				ps.setInt(1, project_id);
				ps.setInt(2, keyword_id);
				ps.setInt(3, research_group_id);
                rs = ps.executeQuery();   
            } catch (SQLException e) {
                throw e;
            }
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
        return rs;			
		
	}//end of getLogbookEntriesTool	
	/*
	 * Retrieve logbook entries for show-logbook.jsp
	 */
	public static ResultSet getLogbookEntries(Integer keyword_id, Elab elab, int project_id, int research_group_id) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
    	String queryWhere = "";
    	if (keyword_id == null) {
    		queryWhere = " WHERE log.project_id = ? AND keyword.project_id in (0, ?) AND log.keyword_id = keyword.id and research_group_id = ? and role='user' ";
    	} else {
    		queryWhere = " WHERE log.project_id = ? and keyword.project_id  in (0, ?) and research_group_id = ? and log.keyword_id = keyword.id and keyword_id = ? and role='user' ";	
    	}

        String queryItems="SELECT log.id AS log_id, to_char(log.date_entered,'DD Mon YYYY HH12:MI AM') AS date_entered, log_text, " +
        				  " keyword.description AS description, keyword.id AS data_keyword_id, keyword.keyword AS keyword_name, keyword.section AS section, "+ 
        				  " keyword.section_id AS section_id, log.new_log AS new FROM log, keyword ";
        String querySort="ORDER BY keyword.section, keyword.section_id, log_id DESC;";
        
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement(queryItems + queryWhere + querySort);
            try {              
            	if (keyword_id == null) {
					ps.setInt(1, project_id);
					ps.setInt(2, project_id);
					ps.setInt(3, research_group_id);
            	} else {
					ps.setInt(1, project_id);
					ps.setInt(2, project_id);
					ps.setInt(3, research_group_id);
					ps.setInt(4, keyword_id);           		
            	}
                rs = ps.executeQuery(); 
                
            } catch (SQLException e) {
                throw e;
            }
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
        return rs;			
	}//end of getLogbookEntries
	/*
	 * Retrieve logbook entries by teacher
	 */
	public static ResultSet getLogbookEntriesTeacher(int project_id, int ref_rg_id, int research_group_id, String role, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
	
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement( "SELECT id AS cur_id, to_char(date_entered,'DD Mon YYYY HH12:MI AM') AS date_entered, log_text AS cur_text " +
            							"  FROM log " + 
            							" WHERE project_id = ? "+
            							"   AND research_group_id = ? "+
            							"   AND ref_rg_id = ? "+
            							"   AND role = ? " +
            							" ORDER BY cur_id;");            
            try {              
            	ps.setInt(1, project_id);
            	ps.setInt(2, research_group_id);
            	ps.setInt(3, ref_rg_id); 
            	ps.setString(4, role); 
                rs = ps.executeQuery();   
            } catch (SQLException e) {
                throw e;
            }
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
        return rs;			
		
	}//end of getLogbookEntriesTeacher
	
	/*
	 * Format section name
	 */
	public static String getSectionText(String this_section) throws ElabException {
		String section_text = "";
		char this_section_char = this_section.charAt(0);
		switch( this_section_char ) {
			case 'A': 
				section_text="Research Basics";
				break;
			case 'B': 
				section_text="A: Get Started";
				break;
			case 'C': 
				section_text="B: Figure it Out";
				break;      
			case 'D': 
				section_text="C: Tell Others";
				break;    
		}
		return section_text;
	}//end of getSectionText

	/*
	 * Insert entry for student
	 */
	public static int insertLogbookEntry(int project_id, int research_group_id, int keyword_id, String log_enter, String role, Elab elab) throws ElabException {
        int id = -1;
        ResultSet rs;
		Connection conn = null; 
        PreparedStatement ps = null; 		
        String insert = " INSERT INTO log (project_id, research_group_id, keyword_id, role, log_text, new_log) "+
        				" VALUES (?, ?, ?, ?, ?, 't') RETURNING id;";        	
        try {
			conn = DatabaseConnectionManager.getConnection(elab.getProperties());
			boolean ac = conn.getAutoCommit();
			try {
				conn.setAutoCommit(false);
				ps = conn.prepareStatement(insert);
				ps.setInt(1, project_id);
				ps.setInt(2, research_group_id);
				ps.setInt(3, keyword_id);
				ps.setString(4, role);
				ps.setString(5, log_enter);
			    rs = ps.executeQuery();
			    while (rs.next()) {
			    	id = rs.getInt("id");
			    }
			    conn.commit();
			} catch (SQLException ex) {
				conn.rollback();
				throw ex;
			} finally {
				conn.setAutoCommit(ac);
			}
		} catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
        return id;
	}//end of insertLogbookEntry

	/*
	 * Insert entry teacher
	 */
	public static void insertLogbookEntryTeacher(int project_id, int research_group_id, int ref_rg_id, String log_enter, String role, Elab elab) throws ElabException {
        Connection conn = null; 
        PreparedStatement ps = null; 		
        String insert = " INSERT INTO log (project_id, research_group_id, ref_rg_id, role, log_text, new_log) "+
        				" VALUES (?, ?, ?, ?, ?, 't') RETURNING id;";
        try {
			conn = DatabaseConnectionManager.getConnection(elab.getProperties());
			boolean ac = conn.getAutoCommit();
			try {
				conn.setAutoCommit(false);
				ps = conn.prepareStatement(insert);
				ps.setInt(1, project_id);
				ps.setInt(2, research_group_id);
				ps.setInt(3, ref_rg_id);
				ps.setString(4, role);
				ps.setString(5, log_enter);
				int i = ps.executeUpdate();
				conn.commit();
			} catch (SQLException ex) {
				conn.rollback();
				throw ex;
			} finally {
				conn.setAutoCommit(ac);
			}
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
	}//end of insertLogbookEntryTeacher
	
	/*
	 * Reset new logbook entry to false
	 */
	public static int updateResetLogbookEntry(int log_id, Elab elab) throws ElabException {
        Connection conn = null; 
        PreparedStatement ps = null;
        int i = 0;
        try {
			conn = DatabaseConnectionManager.getConnection(elab.getProperties());
			boolean ac = conn.getAutoCommit();
			try {
				conn.setAutoCommit(false);
				ps = conn.prepareStatement("UPDATE log "+
										   "   SET new_log = 'f' "+
										   " WHERE id = ?");
				ps.setInt(1, log_id); 
				i = ps.executeUpdate();
				conn.commit();
			} catch (SQLException ex) {
				conn.rollback();
				throw ex;
			} finally {
				conn.setAutoCommit(ac);
			}
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    
        return i;
	}//end of updateResetComment	
	
	public static void deleteLogbookEntry(int log_id, Elab elab) throws ElabException {
        Connection conn = null; 
        PreparedStatement ps = null;
        int i = 0;
        try {
			conn = DatabaseConnectionManager.getConnection(elab.getProperties());
			boolean ac = conn.getAutoCommit();
			try {
				conn.setAutoCommit(false);
				ps = conn.prepareStatement("DELETE"+
										   "  FROM log "+
										   " WHERE id = ?");
				ps.setInt(1, log_id); 
				i = ps.executeUpdate();
				conn.commit();
			} catch (SQLException ex) {
				conn.rollback();
				throw ex;
			} finally {
				conn.setAutoCommit(ac);
			}
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    		
	}//end of deleteLogbookEntry
	
	///////COMMENTS TOOLS////////
	/*
	 * Retrieve comment entries for log-comment.jsp
	 */
	public static ResultSet getCommentEntries(int keyword_id, int research_group_id, int project_id, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT log.id AS log_id, to_char(log.date_entered,'DD Mon YYYY HH12:MI AM') AS log_date, log.log_text AS log_text "+
            						   "  FROM log, keyword "+
            						   " WHERE log.keyword_id = keyword.id "+
            						   "   AND keyword.id = ? "+
            						   "   AND log.research_group_id = ? "+
            						   "   AND log.project_id = ?" +
         							   " ORDER BY log_id DESC;");
          	ps.setInt(1, keyword_id);
          	ps.setInt(2, research_group_id);
          	ps.setInt(3, project_id);
            rs = ps.executeQuery(); 
                
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
        return rs;		
	}//getCommentEntries
	
	/*
	 * Retrieve comment entries for show-comment-keyword.jsp
	 */
	public static ResultSet getCommentDetailsKeyword(int keyword_id, int research_group_id, int project_id, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT log.id AS log_id, to_char(log.date_entered,'DD Mon YYYY HH12:MI AM') AS log_date, log.log_text AS log_text, to_char(comment.date_entered,'MM/DD/YYYY HH12:MI') AS comment_date, comment.id AS comment_id, comment.comment AS comment, comment.new_comment AS new_comment "+ 
            						   "  FROM comment, log, keyword " +
            						   " WHERE log.id = comment.log_id "+
            						   "   AND log.keyword_id = keyword.id "+
            						   "   AND keyword.id = ? "+
            						   "  AND log.research_group_id = ? "+
            						   "  AND log.project_id = ? "+
            						   "  AND keyword.project_id in (0,?) " +
        							   " ORDER BY log_id DESC, comment_id DESC;");
        	ps.setInt(1, keyword_id); 
        	ps.setInt(2, research_group_id); 
        	ps.setInt(3, project_id); 
        	ps.setInt(4, project_id); 
            rs = ps.executeQuery(); 
                
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
        return rs;		
	}//getCommentDetailsKeyword	
	
	/*
	 * Retrieve comment entry by id
	 */
	public static ResultSet getCommentEntryById(int log_id_param, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
	
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement( "SELECT log.id AS log_id,to_char(log.date_entered,'DD Mon YYYY HH12:MI AM') AS log_date, log.log_text AS cur_log_text "+
            							"  FROM log "+
            							" WHERE log.id = ?;");
            
            try {              
            	ps.setInt(1, log_id_param);
                rs = ps.executeQuery();   
            } catch (SQLException e) {
                throw e;
            }
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
        return rs;			
		
	}//end of getCommentEntryById
	
	/*
	 * Insert new comment
	 */
	public static int insertComment(int log_id_param, String comment_enter, Elab elab) throws ElabException {
        Connection conn = null; 
        PreparedStatement ps = null; 
        ResultSet rs;
        int comment_id = -1;
        try {
			conn = DatabaseConnectionManager.getConnection(elab.getProperties());
			boolean ac = conn.getAutoCommit();
			try {
				conn.setAutoCommit(false);
				ps = conn.prepareStatement(" INSERT INTO comment (log_id, comment, new_comment) "+
										   " VALUES (?, ?, 't') returning id;");
				ps.setInt(1, log_id_param);
	  			ps.setString(2, comment_enter); 
				rs = ps.executeQuery();
				while (rs.next()) {
					comment_id = rs.getInt("id");
				}
				conn.commit();
			} catch (SQLException ex) {
				conn.rollback();
				throw ex;
			} finally {
				conn.setAutoCommit(ac);
			}
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
        return comment_id;
	}//end of insertComment
	
	/*
	 * Reset new comment to false
	 */
	public static int updateResetComment(int comment_id, Elab elab) throws ElabException {
        Connection conn = null; 
        PreparedStatement ps = null;
        int i = 0;
        try {
			conn = DatabaseConnectionManager.getConnection(elab.getProperties());
			boolean ac = conn.getAutoCommit();
			try {
				conn.setAutoCommit(false);
				ps = conn.prepareStatement("UPDATE comment "+
										   "   SET new_comment = 'f' "+
										   " WHERE id = ?;");
				ps.setInt(1, comment_id); 
				i = ps.executeUpdate();
				conn.commit();
			} catch (SQLException ex) {
				conn.rollback();
				throw ex;
			} finally {
				conn.setAutoCommit(ac);
			}
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    
        return i;
	}//end of updateResetComment	
	
	/*
	 * Reset new comments for a logbook entry to false
	 */
	public static int updateResetCommentsforLogbookEntry(int log_id, Elab elab) throws ElabException {
        Connection conn = null; 
        PreparedStatement ps = null;
        int i = 0;
        try {
			conn = DatabaseConnectionManager.getConnection(elab.getProperties());
			boolean ac = conn.getAutoCommit();
			try {
				conn.setAutoCommit(false);
				ps = conn.prepareStatement("UPDATE comment "+
										   "   SET new_comment = 'f' "+
										   " WHERE log_id = ?;");
				ps.setInt(1, log_id); 
				i = ps.executeUpdate();
				conn.commit();
			} catch (SQLException ex) {
				conn.rollback();
				throw ex;
			} finally {
				conn.setAutoCommit(ac);
			}
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    
        return i;
	}//end of updateResetCommentsforLogbookEntry	

	/*
	 * Retrieve count of comments
	 */
	public static Long getCommentCount(int log_id, Elab elab) throws ElabException {
		Long comment_count = 0L;
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT COUNT(id) AS comment_count "+
            						   "  FROM comment "+
            						   " WHERE log_id = ?;");
            try {              
            	ps.setInt(1, log_id);
                rs = ps.executeQuery(); 
                if (rs.next()) {
                	comment_count = (Long) rs.getObject("comment_count");
                }
            } catch (SQLException e) {
                throw e;
            }
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
        return comment_count;        
	}//end of getCommentCount

	/*
	 * Retrieve count of new comments
	 */
	public static Long getCommentCountNew(int log_id, Elab elab) throws ElabException {
		Long comment_count_new = 0L;
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT COUNT(comment.id) AS comment_new "+
            						   "  FROM comment "+
            						   " WHERE comment.new_comment = 't' "+
            						   "   AND log_id = ?;");

            try {              
            	ps.setInt(1, log_id);
                rs = ps.executeQuery(); 
                if (rs.next()) {
                	comment_count_new = (Long) rs.getObject("comment_new");
                }
            } catch (SQLException e) {
                throw e;
            }
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
        return comment_count_new;        
	}//end of getCommentCountNew	

	/*
	 * Retrieve comment id 
	 */
	public static int getCommentId(int log_id_param, String comment_enter, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        int log_id = -1;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT comment.id AS id "+
            						   "  FROM comment "+
            						   " WHERE log_id = ? "+
            						   "   AND comment = ? "+
            						   " ORDER BY comment.id DESC;");
 			ps.setInt(1, log_id_param);
 			ps.setString(2, comment_enter);
            rs = ps.executeQuery(); 
    		if (rs.next()) {
    			log_id = (Integer) rs.getObject("id");
    		}
                
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
        return log_id;	
	}//end of getCommentId

	/*
	 * Retrieve comment details
	 */
	public static ResultSet getCommentDetails(int cur_log_id, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT to_char(comment.date_entered,'DD Mon YYYY HH24:MI AM') AS comment_date, comment.comment AS comment " +
            						   "  FROM comment " + 
            						   " WHERE log_id = ?;");
    		ps.setInt(1, cur_log_id);
            rs = ps.executeQuery(); 
                
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
        return rs;			
	}// end of getCommentDetails
	
	/*
	 * Retrieve name for teacher's groups from the group id
	 */
	public static String getGroupNameFromId(int groupId, Elab elab) throws ElabException {
		String groupName = "";
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT research_group.name as groupname "+
            						   "  FROM research_group " +
            						   " WHERE research_group.id = ? ;");


            try {              
                ps.setInt(1, groupId);
                rs = ps.executeQuery(); 
                if (rs != null) {
                	while (rs.next()) {
                		groupName = rs.getString(1);
                	}
                }
            } catch (SQLException e) {
                throw e;
            }
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
	return groupName;
	}//end of getGroupNameFromId	

	//////BUILD LINKS TO DISPLAY ON THE PAGES/////
	/*
	 * Build links to each group
	 */
	public static String buildGroupLinks(ElabGroup user, String page_name) throws ElabException {
		String linksToEachGroup= "";
		//get all research groups and build links
		Collection<ElabGroup> rgTeacherGroups = user.getGroups();
		Iterator it = rgTeacherGroups.iterator();
		while (it.hasNext()){
			ElabGroup eg = (ElabGroup) it.next();
			if (eg.getRole().equals("user") || eg.getRole().equals("upload")) {
				//EPeronja-only display active research groups
				if (eg.getActive()) {
					linksToEachGroup = linksToEachGroup
							+ "<tr><td><A HREF='"+page_name +"?research_group_id="+ String.valueOf(eg.getId()) + "&research_group_name=" + eg.getName() + "'>" + eg.getName()+ "</A></td></tr>";
				}
			}
		}//end while loop
		return linksToEachGroup;
	}//end of buildLogbookLinkstoKeywords	

	/*
	 * Build links to each keyword
	 */
	public static String buildTeacherKeywordLinks(int project_id, String keyword, Elab elab) throws ElabException {
		String linksToEach= "";
		int keyword_id;
		String keyword_loop, keyword_description, keyword_text, keyColor;
		try {
			ResultSet rs = LogbookTools.getLogbookKeywordItems(project_id, "", elab);
			String current_section = "";
			while (rs.next()) {
				keyword_id = (Integer) rs.getObject("id");
				keyword_loop = rs.getString("keyword");
				keyword_text = keyword_loop.replaceAll("_", " ");
				keyword_description = rs.getString("description");
				String this_section = (String) (rs.getString("section"));
				if (!keyword_loop.equals("general")) {
					if (!this_section.equals(current_section)) {
						try {
							String section_text = LogbookTools.getSectionText(this_section);
							linksToEach = linksToEach
									+ "<tr><td>&nbsp;</td></tr><tr><td>"
									+ section_text + "</td></tr>";
							current_section = this_section;
						} catch (Exception e) {
							throw new ElabException(e);
						}
					}
					keyColor = "";
					if (keyword.equals(keyword_loop)) {
						keyColor = "color=\"#AA3366\"";
					}
					linksToEach = linksToEach
							+ "<tr><td><A HREF='teacher-logbook-keyword.jsp?keyword="
							+ keyword_loop + "'>"
							+ keyword_text + "</font></A></td></tr>";
				}
			}
		} catch (Exception e) {
			throw new ElabException(e);
		}
		return linksToEach;
	}//end of buildLogbookLinkstoKeywords	
	
	/*
	 * Build keyword links
	 */
	public static String buildStudentKeywordLinks(ResultSet rs, HashMap keywordTracker, String keyword) throws ElabException {
		String linksToEach = "";
		String current_section = "";
		try {
			while (rs.next()) {
				Integer keyword_id = (Integer) rs.getObject("id");
				String keyword_loop = rs.getString("keyword");
				String keyword_text = keyword_loop.replaceAll("_"," ");
				String keyword_description = rs.getString("description");
				String this_section = (String)(rs.getString("section"));
				String yesNo = "no";
				if (!keyword_loop.equals("general")) {
					if (!this_section.equals(current_section)) {
						String section_text = LogbookTools.getSectionText(this_section);
						linksToEach=linksToEach + "<tr><td>&nbsp;</td></tr><tr><td><font face='Comic Sans MS'>"+section_text+"</font></td></tr>";
						current_section = this_section;
					}
					if (keywordTracker.containsKey(keyword_id.intValue())) {
						yesNo="yes";
					}
					String keyColor="";
					if (keyword.equals(keyword_loop)) { 
						keyColor="color=\"#AA3366\"";
					}
					linksToEach=linksToEach + "<tr><td><img src=\"../graphics/log_entry_" + yesNo + ".gif\" border=0 align=center><a href='student-logbook.jsp?keyword="+keyword_loop+"'><font face='Comic Sans MS'"+keyColor+">"+keyword_text+"</face></a></td></tr>";		
				}
			}
		} catch (Exception e) {
	      throw new ElabException(e);
		}
		return linksToEach;
	}//end of buildLogbookLinkstoKeywords

	/*
	 * Build keyword links
	 */
	public static String buildGroupLinksToKeywords(ResultSet rs, HashMap keywordTracker, String keyword, String research_group_name, int group_id) throws ElabException {
		String linksToEach = "";
		String current_section = "";
		try {
			while (rs.next()) {
				Integer keyword_id = (Integer) rs.getObject("id");
				String keyword_loop = rs.getString("keyword");
				String keyword_text = keyword_loop.replaceAll("_"," ");
				String keyword_description = rs.getString("description");
				String this_section = (String)(rs.getString("section"));
				String yesNo = "no";
				if (!keyword_loop.equals("general")) {
					if (!this_section.equals(current_section)) {
						String section_text = LogbookTools.getSectionText(this_section);
						linksToEach=linksToEach + "<tr><td>&nbsp;</td></tr><tr><td><font face='Comic Sans MS'>"+section_text+"</font></td></tr>";
						current_section = this_section;
					}
					if (keywordTracker.containsKey(keyword_id.intValue())) {
						yesNo="yes";
					}
					String keyColor="";
					if (keyword.equals(keyword_loop)) { 
						keyColor="color=\"#AA3366\"";
					}
					linksToEach=linksToEach
							+ "<tr><td><img src=\"../graphics/log_entry_"
							+ yesNo
							+ ".gif\" border=0 align=center><A HREF='teacher-logbook-group.jsp?research_group_name="+ research_group_name + 
							"&research_group_id="+ String.valueOf(group_id) +
							"&keyword=" + keyword_loop + "'><FONT  " + keyColor + ">"+ keyword_text + "</font></A></td></tr>";				
				}
			}
		} catch (Exception e) {
	      throw new ElabException(e);
		}
		return linksToEach;
	}//end of buildGroupLinksToKeywords

	/*
	 * Build build comment details
	 */
	public static ArrayList buildCommentDetails(int log_id, String comment_info, int commentCnt, Elab elab) throws ElabException {
		ArrayList commentDetails = new ArrayList();								
		commentDetails.add(comment_info);
		int localCnt = commentCnt;
		try {
			ResultSet commentRs = LogbookTools.getCommentDetails(log_id, elab);
			String comment_date = "";
			String comment_text = "";
			String commentEntry = "";	
			while (commentRs.next()) {
				comment_date = commentRs.getString("comment_date");
				if (comment_date == null) {
					comment_date = "";
				}
				comment_text = "<strong>" + comment_date + "</strong>: " + commentRs.getString("comment");
				if (comment_text == null) {
					comment_text = "";
				}
				commentEntry = "";
				String comment_truncated;
				comment_truncated = comment_text.replaceAll(
							"\\<(.|\\n)*?\\>", "");
				if (comment_truncated.length() > 150) {
					comment_truncated = comment_truncated.substring(0, 138);
					commentEntry += "<div id=\"fullComment"+String.valueOf(localCnt)+"\" style=\"display:none; width: 300px; height: 100%;\">"+comment_text+"</div>"+
									"<div id=\"showComment"+String.valueOf(localCnt)+"\" style=\"width: 300px; height: 100%;\">"+comment_truncated+
									" . . .<a href=\'javascript:showFullComment(\"showComment"+String.valueOf(localCnt)+"\",\"fullComment"+String.valueOf(localCnt)+"\");\'>Read More</a></div>";
				} else {
					commentEntry += comment_text;
				}
				commentDetails.add(commentEntry);
				localCnt++;
			} //while for comments
		} catch (Exception e) {
			throw new ElabException(e);
		}
		return commentDetails;
	}//end of buildCommentDetails
	
	/*
	 * Called from log-entry.jsp
	 */
	public static String buildLogbookEntriesPlusComments(int project_id, int keyword_id, int research_group_id, String groupName, Elab elab) throws ElabException {
		String currentEntries = "";
		int itemCount = 0;
		String hrHtml = "";
		ResultSet rs = null;
		ResultSet innerRs = null;
		try {
			rs = LogbookTools.getLogbookEntriesTool(project_id, keyword_id, research_group_id, elab);
			while (rs.next()) {
				int cur_log_id = rs.getInt("cur_id");
				String log_date = rs.getString("date_entered");
				String cur_log_text = rs.getString("cur_text");
				String log_date_show = log_date;
				String log_text_show = cur_log_text;
				itemCount++;
				currentEntries = currentEntries + hrHtml;
				if (itemCount == 1) {
					currentEntries = currentEntries
							+ "<tr><th valign='center' align='right'><IMG SRC='../graphics/logbook.gif' align='middle'></th><th valign='center' align='left'>"
							+ groupName
							+ "\'s log entries</th><th><IMG SRC='../graphics/blue_square.gif' width='1' height='20' align='top'></th><th valign='center' align='right'><IMG SRC='../graphics/logbook_comments.gif' align='middle'></th><th valign='center' align='left'>teacher\'s comments</th></tr><tr><td colspan='5'><HR  color='#1A8BC8'></td></tr>";
				} //itemCount
	
				innerRs = LogbookTools.getCommentDetails(cur_log_id, elab);
				int commentCount = 0;
				String comment_date = "";
				String comment_existing = "";
				while (innerRs.next()) {
					comment_date = innerRs.getString("comment_date");
					comment_existing = innerRs.getString("comment");
					commentCount++;
					if (commentCount > 1) {
						log_text_show = " ";
						log_date_show = " ";
						hrHtml = "";
					} else {
						hrHtml = "<tr><td colspan='5'><HR color='#1A8BC8'></td></tr>";
					}
	
					currentEntries = currentEntries
							+ "<tr><td valign='top' width='100' align='right'>"
							+ log_date_show
							+ "</td><td width='300'  valign='top'>"
							+ log_text_show + "</td>";
					currentEntries = currentEntries
							+ "<td><IMG SRC='../graphics/blue_square.gif' width='1' height='20' align='top'><td valign='top' width='100' align='right'>"
							+ comment_date
							+ "</td><td width='300'  valign='top'>"
							+ comment_existing + "</td></tr>";
	
				} //while for comments
				if (commentCount == 0) {
					currentEntries = currentEntries
							+ "<tr><td valign='top' width='100' align='right'>"
							+ log_date
							+ "</td><td width='300'  valign='top'>"
							+ cur_log_text
							+ "</td><td><IMG SRC='../graphics/blue_square.gif' width='1' height='20' align='top'><td valign='top' width='100' align='right'>&nbsp;</td><td width='300'  valign='top'>No comments.</td></tr>";
				}
	
				if (itemCount == 0) {
					currentEntries = currentEntries
							+ "<tr><td colspan='4' align='center'><FONT  size='+1'>No comments on this item.</FONT></td></tr>";
				}
			} //while for log
		} catch (Exception e) {
			throw new ElabException(e);
		}
	    currentEntries = currentEntries.replace("''","'");

		
		return currentEntries;
	}//buildLogbookEntriesPlusComments

	/*
	 * Build existing comments for log-comments.jsp 
	 */
	public static String buildExistingComments(Integer keyword_id, int research_group_id, int project_id, String research_group_name, Elab elab) throws ElabException {
		String currentEntries = "";
	  	int itemCount = 0;
	  	String hrHtml = "";
	  	ResultSet sInner = null;
	  	try {
		  	// look for any previous log entries for this keyword
		  	ResultSet rs = LogbookTools.getCommentEntries(keyword_id, research_group_id, project_id, elab);
		  	while (rs.next()) {
		  		int log_id = rs.getInt("log_id");
		  		String log_date = rs.getString("log_date");
		  		String log_text = rs.getString("log_text");
		  		String log_date_show = log_date;
		  		String log_text_show = log_text;
		  		itemCount++;
		  		currentEntries = currentEntries + hrHtml;
		  		if (itemCount == 1) {
		  			currentEntries = currentEntries
		  					+ "<tr><th valign='center' align='right'><IMG SRC='../graphics/logbook.gif' align='middle'></th><th valign='center' align='left'>"
		  					+ research_group_name
		  					+ "\'s log entries</th><th><IMG SRC='../graphics/blue_square.gif' width='1' height='20' align='top'></th><th valign='center' align='right'><IMG SRC='../graphics/logbook_comments.gif' align='middle'></th><th valign='center' align='left'>teacher\'s comments</th></tr><tr><td colspan='5'><HR  color='#1A8BC8'></td></tr>";
		  		} //itemCount

		  		// look for comments associated with this log item
		  		sInner = LogbookTools.getCommentDetails(log_id, elab);
		  		int commentCount = 0;
		  		String comment_date = ""; // this makes baby dieties cry 
		  		String comment_existing = "";
		  		while (sInner.next()) {
		  			comment_date = sInner.getString("comment_date");
		  			comment_existing = sInner.getString("comment");
		  			commentCount++;
		  			if (commentCount > 1) {
		  				log_text_show = " ";
		  				log_date_show = " ";
		  				hrHtml = "";
		  			} else {
		  				hrHtml = "<tr><td colspan='5'><HR color='#1A8BC8'></td></tr>";
		  			}

		  			currentEntries = currentEntries
		  					+ "<tr><td valign='top' width='100' align='right'>"
		  					+ log_date_show
		  					+ "</td><td width='300'  valign='top'>"
		  					+ log_text_show + "</td>";
		  			currentEntries = currentEntries
		  					+ "<td><IMG SRC='graphics/blue_square.gif' width='1' height='20' align='top'><td valign='top' width='100' align='right'>"
		  					+ comment_date
		  					+ "</td><td width='300'  valign='top'>"
		  					+ comment_existing + "</td></tr>";

		  		} //while for comments
		  		if (commentCount == 0) {
		  			currentEntries = currentEntries
		  					+ "<tr><td valign='top' width='100' align='right'>"
		  					+ log_date
		  					+ "</td><td width='300'  valign='top'>"
		  					+ log_text
		  					+ "</td><td><IMG SRC='graphics/blue_square.gif' width='1' height='20' align='top'><td valign='top' width='100' align='right'>&nbsp;</td><td width='300'  valign='top'>No comments.</td></tr>";
		  		}

		  		if (itemCount == 0) {
		  			currentEntries = currentEntries
		  					+ "<tr><td colspan='4' align='center'><FONT  size='+1'>No comments on this item.</FONT></td></tr>";
		  		}
		  	} //while for log

	  	} catch (Exception e) {
            throw new ElabException(e);
        }
		
		return currentEntries;
	}//end of buildExistingComments

	
}//end of LogbookTools
