package gov.fnal.elab.logbook;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.util.Arrays;
import java.util.Collection;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.RawDataFileResolver;
import gov.fnal.elab.analysis.AnalysisRun;
import gov.fnal.elab.datacatalog.StructuredResultSet.File;
import gov.fnal.elab.datacatalog.StructuredResultSet.Month;
import gov.fnal.elab.datacatalog.StructuredResultSet.School;
import gov.fnal.elab.datacatalog.query.CatalogEntry;
import gov.fnal.elab.util.DatabaseConnectionManager;
import gov.fnal.elab.util.ElabException;

public class LogbookTools {
 
	public static ResultSet getAllGroupEntries(Elab elab, int project_id, int research_group_id) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT log.id AS log_id, to_char(log.date_entered,'MM/DD/YYYY HH12:MI') AS date_entered, " +
            						   "	   log_text, log.ref_rg_id AS ref_rg_id, research_group.name as groupname FROM log, research_group " +
            						   " WHERE log.project_id = ? AND log.research_group_id = ? AND log.research_group_id = research_group.id and log.role = 'teacher' " +
            						   " ORDER BY log.ref_rg_id, log_id DESC;");


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
    }//end of getAllGroupEntries
	
	public static ResultSet getGroupEntries(Elab elab, int project_id, int research_group_id, int ref_rg_id) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT log.id AS log_id, to_char(log.date_entered,'MM/DD/YYYY HH12:MI') AS date_entered, " +
            						   "	   log_text, log.ref_rg_id AS ref_rg_id, research_group.name as groupname FROM log, research_group " +
            						   " WHERE log.project_id = ? AND log.research_group_id = ? AND log.research_group_id = research_group.id AND log.ref_rg_id = ? AND log.role='teacher' " +
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
    }//end of getGroupEntries
	
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
	
	public static String getYesNo(String groupName, int project_id, Elab elab) throws ElabException {
		String yesno = "no";
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT DISTINCT keyword_id "+
            						   "  FROM log, research_group, keyword " +
            						   " WHERE keyword.keyword = 'general' AND keyword.id = log.keyword_id and research_group.name ILIKE ? "+
            						   "   AND research_group.id = log.research_group_id AND log.project_id = ?;");

            try {              
            	ps.setString(1, groupName); 
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
	}//end of getYesNo
	
	public static ResultSet getKeywordTracker(String groupName, int project_id, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT DISTINCT keyword_id "+
            						   "  FROM log,research_group " + 
            						   " WHERE research_group.name ILIKE ? and research_group.id = log.research_group_id and project_id in (0, ?);");
            try {              
            	ps.setString(1, groupName);
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
	
	public static ResultSet getLogbookItems(int project_id, String typeConstraint, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT id, keyword, description, section, section_id " + 
    								   "  FROM keyword where keyword.project_id in (0,?) " + typeConstraint + 
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
	
	public static ResultSet getEntriesByKeyword(int project_id, String keyword, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT id, keyword, description FROM keyword " +
        			"WHERE keyword.project_id in (0, ?) and keyword= ?;");
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
	}//end of getEntriesByKeyword
	
	

	public static ResultSet getCommentEntries(int log_id_param, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
	
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement( "SELECT log.id AS log_id,to_char(log.date_entered,'MM/DD/YYYY HH12:MI') AS log_date, log.log_text AS cur_log_text FROM log WHERE log.id = ?;");
            
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
		
	}//end of getLogbookEntries

	
	public static ResultSet getLogbookEntries(int project_id, int keyword_id, int research_group_id, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
	
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement( " SELECT log.id AS cur_id, to_char(log.date_entered,'MM/DD/YYYY HH12:MI') AS date_entered, log.log_text AS cur_text "+
            							"   FROM log " + 
        								"  WHERE project_id = ? AND keyword_id = ? AND research_group_id = ? AND role = 'user' " +
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
		
	}//end of getLogbookEntries

	public static ResultSet getLogbookEntriesByGroup(int keyword_id, int teacher_id, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
	
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement( "SELECT research_group.name AS rg_name, to_char(log.date_entered,'MM/DD/YYYY HH12:MI') AS date_entered, log.log_text AS log_text,log.id AS log_id,log.new_log AS new FROM log, research_group " +
        			"WHERE log.keyword_id = ? AND research_group.id = log.research_group_id AND research_group.teacher_id = ? AND research_group.role IN ('user', 'upload') " + 
        			"ORDER BY research_group.name, log.id DESC;"); 
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
	}//end of getLogbookEntries
	
	public static ResultSet getLogbookEntriesTeacher(int project_id, int ref_rg_id, int research_group_id, String role, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
	
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement( "SELECT id AS cur_id, to_char(date_entered,'MM/DD/YYYY HH12:MI') AS date_entered, log_text AS cur_text " +
            							"  FROM log " + 
            							" WHERE project_id = ? AND research_group_id = ? AND ref_rg_id = ? AND role = ? " +
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
		
	}//end of getLogbookEntries

	public static ResultSet getLogbookDetails(String queryWhere, Elab elab, int project_id, int research_group_id, int keyword_id) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        String queryItems="SELECT log.id AS log_id, to_char(log.date_entered,'MM/DD/YYYY HH12:MI') AS date_entered, log_text, " +
        				  " keyword.description AS description, keyword.id AS data_keyword_id, keyword.keyword AS keyword_name, keyword.section AS section, "+ 
        				  " keyword.section_id AS section_id, log.new_log AS new FROM log, keyword ";
        String querySort="ORDER BY keyword.section, keyword.section_id, log_id DESC;";
        
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement(queryItems + queryWhere + querySort);
            try {              
            	if (keyword_id == -1) {
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
	}//end of getLogbookDetails
	
	public static Long getCommentCount(int log_id, Elab elab) throws ElabException {
		Long comment_count = 0L;
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT COUNT(id) AS comment_count FROM comment WHERE log_id = ?;");

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

	public static Long getCommentCountNew(int log_id, Elab elab) throws ElabException {
		Long comment_count_new = 0L;
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT COUNT(comment.id) AS comment_new FROM comment WHERE comment.new_comment = 't' AND log_id = ?;");

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
	}//end of getCommentCount

	public static ResultSet getCommentDetails(int cur_log_id, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT to_char(comment.date_entered,'MM/DD/YYYY HH12:MI') AS comment_date, comment.comment AS comment FROM comment WHERE log_id = ?;");
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

	public static ResultSet getCommentDetails(int keyword_id, int research_group_id, int project_id, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT log.id AS log_id, to_char(log.date_entered,'MM/DD/YYYY HH12:MI') AS log_date, log.log_text AS log_text, to_char(comment.date_entered,'MM/DD/YYYY HH12:MI') AS comment_date, comment.id AS comment_id, comment.comment AS comment, comment.new_comment AS new_comment FROM comment, log, keyword " +
        			"WHERE log.id = comment.log_id AND log.keyword_id = keyword.id AND keyword.id = ? AND log.research_group_id = ? AND log.project_id = ? AND keyword.project_id in (0,?) " +
        			"ORDER BY log_id DESC, comment_id DESC;");
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
	}//getKeywordDetails

	public static ResultSet getEntryDetails(int keyword_id, int research_group_id, int project_id, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT log.id AS log_id, to_char(log.date_entered,'MM/DD/YYYY HH12:MI') AS log_date, log.log_text AS log_text FROM log, keyword " +
          			"WHERE log.keyword_id = keyword.id AND keyword.id = ? AND log.research_group_id = ? AND log.project_id = ?" +
         			"ORDER BY log_id DESC;");
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
	}//getKeywordDetails
	
	public static int updateLogbookEntry(String log_enter, int log_id, Elab elab) throws ElabException {
        Connection conn = null; 
        PreparedStatement ps = null;
        int i = 0;
        try {
			conn = DatabaseConnectionManager.getConnection(elab.getProperties());
			conn.prepareStatement("UPDATE log SET log_text = ? WHERE  id = ?;");
			ps.setString(1, log_enter);
			ps.setInt(2, log_id);
			i = ps.executeUpdate();
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    
        return i;
	}//end of updateLogbookEntry

	public static int updateComment(int comment_id, Elab elab) throws ElabException {
        Connection conn = null; 
        PreparedStatement ps = null;
        int i = 0;
        try {
			conn = DatabaseConnectionManager.getConnection(elab.getProperties());
			conn.prepareStatement("UPDATE comment SET new_comment = 'f' WHERE id = ?;");
			ps.setInt(1, comment_id); 
			i = ps.executeUpdate();
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    
        return i;
	}//end of updateLogbookEntry

	public static int updateComment(int comment_id, String comment_enter, Elab elab) throws ElabException {
        Connection conn = null; 
        PreparedStatement ps = null;
        int i = 0;
        try {
			conn = DatabaseConnectionManager.getConnection(elab.getProperties());
			conn.prepareStatement("UPDATE comment SET comment = ? WHERE id = ?; ");
			ps.setString(1, comment_enter);
			ps.setInt(2, comment_id);
			i = ps.executeUpdate();
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    
        return i;
	}//end of updateLogbookEntry
	
	public static void insertLogbookEntry(int project_id, int research_group_id, int keyword_id, String log_enter, String role, Elab elab) throws ElabException {
        Connection conn = null; 
        PreparedStatement ps = null; 		
        try {
			conn = DatabaseConnectionManager.getConnection(elab.getProperties());
			ps = conn.prepareStatement("INSERT INTO log (project_id, research_group_id, keyword_id, role, log_text, new_log) VALUES (?, ?, ?, ?, ?, 't');");
			ps.setInt(1, project_id);
			ps.setInt(2, research_group_id);
			ps.setInt(3, keyword_id);
			ps.setString(4, role);
			ps.setString(5, log_enter); 
			int i = ps.executeUpdate();
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
	}//end of insertLogbookEntry

	public static void insertComment(int log_id_param, String comment_enter, Elab elab) throws ElabException {
        Connection conn = null; 
        PreparedStatement ps = null; 		
        try {
			conn = DatabaseConnectionManager.getConnection(elab.getProperties());
			ps = conn.prepareStatement("INSERT INTO comment (log_id, comment, new_comment) VALUES (?, ?, 't');");
			ps.setInt(1, log_id_param);
  			ps.setString(2, comment_enter); 
			int i = ps.executeUpdate();
        } catch (SQLException e) {
            throw new ElabException(e);
        } finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }    	
	}//end of insertLogbookEntry
	
	public static int getLogId(int research_group_id, int project_id, int keyword_id, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        int log_id = -1;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT id FROM log " + 
    						"WHERE research_group_id = ? AND project_id = ? and keyword_id = ? AND role = 'user' " + 
    						"ORDER BY id DESC;");
    		ps.setInt(1, research_group_id);
    		ps.setInt(2, project_id);
    		ps.setInt(3, keyword_id);
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

	}//end of getLogId
	
	public static int getCommentId(int log_id_param, String comment_enter, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement ps; 
        ResultSet rs;
        int log_id = -1;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = conn.prepareStatement("SELECT comment.id AS id FROM comment WHERE log_id = ? and comment = ? ORDER BY comment.id DESC;");
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

	}//end of getLogId	
}//end of LogbookTools
