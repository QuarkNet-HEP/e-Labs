package gov.fnal.elab.survey.impl.database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Savepoint;
import java.sql.Timestamp;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabProvider;
import gov.fnal.elab.survey.ElabSurvey;
import gov.fnal.elab.survey.ElabSurveyProvider;
import gov.fnal.elab.survey.ElabSurveyQuestion;
import gov.fnal.elab.survey.ElabSurveyQuestionAnswer;
import gov.fnal.elab.test.ElabTestQuestionAnswer;
import gov.fnal.elab.util.DatabaseConnectionManager;
import gov.fnal.elab.util.ElabException;

public class DatabaseSurveyProvider implements ElabSurveyProvider, ElabProvider {
	
	private Elab elab;
	private Map tests; 
	
	public DatabaseSurveyProvider()  {
		tests = new HashMap();
	}
	
	public void setElab(Elab elab) {
        this.elab = elab;
    }

	public ElabSurvey getSurvey(int id) throws ElabException {
		synchronized (tests) {
            if (tests.containsKey(new Integer(id))) {
                return (ElabSurvey) tests.get(new Integer(id));
            }
        }		
		
		ElabSurvey survey = new ElabSurvey(null);
		Connection con = null; 
		try {
			con = DatabaseConnectionManager.getConnection(elab.getProperties());
			PreparedStatement ps = con.prepareStatement(
					"SELECT q.question_no, q.question_text, q.answer_id, r.id, r.response_text " +
					"FROM \"newSurvey\".questions AS q " + 
					"LEFT OUTER JOIN \"newSurvey\".responses AS r " +
					"ON (q.id = r.question_id) " +
					"WHERE q.test_id = ? " +
					"ORDER BY q.question_no, r.response_no;");
					
			ps.setInt(1, id);
			ResultSet rs = ps.executeQuery();
			
			ElabSurveyQuestion currentQuestion = null; 
			while (rs.next()) {
				int thisQuestionId = rs.getInt("question_no");
				String thisQuestionText = rs.getString("question_text");
				int thisQuestionCorrectAnswerId = rs.getInt("answer_id");
				
				int thisAnswerId = rs.getInt("id");
				String thisAnswerText = rs.getString("response_text");
				
				// If ID changes or this is the first row (null question), make a new question
				if ((currentQuestion == null) || (currentQuestion.getId() != thisQuestionId)) {
					if (currentQuestion != null) {
						survey.addQuestion(currentQuestion);
					}
					currentQuestion = new ElabSurveyQuestion(thisQuestionId, thisQuestionText);
				}
				
				// Create an answer
				ElabSurveyQuestionAnswer currentAnswer = new ElabSurveyQuestionAnswer(thisAnswerId, thisAnswerText);
				
				// Add the answer into the current question
				currentQuestion.addAnswer(currentAnswer);
				
				// TODO: Add the images into the current question? 
				// No - will continue to inline it into the question text 
				
				// If this is the correct answer, set it. 
				if (thisAnswerId == thisQuestionCorrectAnswerId) {
					currentQuestion.setCorrectAnswer(currentAnswer);
				}
			}
			if (currentQuestion != null) {
				survey.addQuestion(currentQuestion);
			}
			
		}
		catch (Exception e) {
			throw new ElabException(e);
		}
		finally {
			DatabaseConnectionManager.close(con, null);
		}
		
		return survey; 
		
	}
	
	public void RecordCompletion(int studentId, int testId, String type, List answers) throws ElabException {
		
		//TODO: FIX THIS
		Timestamp ts = (Timestamp) new Date();
		
		Savepoint svpt = null; 
		Connection con = null;
		
		try {
			ResultSet rs = null; 
			con = DatabaseConnectionManager.getConnection(elab.getProperties());
			
			// Set rollback point in case the transaction fails. 
			svpt = con.setSavepoint();
			con.setAutoCommit(false);
			
			// TODO: Insert a new completion for the student
			// Need student ID, test ID, time, type
			PreparedStatement insertCompletion = con.prepareStatement(
					"INSERT INTO \"newSurvey\".completions " +
					"(testId, time, student_id, type) " +
					"VALUES (?, ?, ?, ?);");
			insertCompletion.setInt(1, testId);
			insertCompletion.setInt(3, studentId);
			insertCompletion.setTimestamp(2, ts); 
			insertCompletion.setString(4, type);
			insertCompletion.executeUpdate(); 
			
			// TODO: Get lastval() for for the generated completion ID 
			int completionId = -1;
			PreparedStatement queryCompletionId = con.prepareStatement("SELECT lastval(); ");
			rs = queryCompletionId.executeQuery(); 
			completionId = rs.getInt(1);
			
			// TODO: Insert all the answers
			// Need question ID, completion ID; 
			for (Iterator i = answers.iterator(); i.hasNext(); ) {
				ElabTestQuestionAnswer answer = (ElabTestQuestionAnswer) i.next();
				PreparedStatement insertAnswer = con.prepareStatement(
						"INSERT INTO \"newSurvey\".answers " +
						"(response_id, completion_id) " +
						"VALUES (?, ?); ");
				insertAnswer.setInt(1, answer.getId());
				insertAnswer.setInt(2, completionId);
				insertAnswer.executeUpdate();
			}
			
			// Commit the transaction. 
			con.commit();
			con.setAutoCommit(true);
		}
		catch (Exception e) {
			try {
				if (con != null) {
					con.rollback(svpt);
					con.setAutoCommit(true);
				}
			}
			catch (SQLException ex) {
				throw new ElabException(ex);
			}
			finally {
				DatabaseConnectionManager.close(con, null);
			}
			throw new ElabException(e);
		}
		finally {
			DatabaseConnectionManager.close(con, null);
		}
	}
	
	public boolean hasStudentTakenTest(int testID, String type, int studentID) throws ElabException {
		// TODO: Probably should have an enumerated type! 
		
		boolean taken = false; 
		Connection con = null;
		
		try {
			con = DatabaseConnectionManager.getConnection(elab.getProperties()); 
			
			PreparedStatement ps = con.prepareStatement(
					"SELECT * FROM \"newSurvey\".completions " +
					"WHERE student_id = ? AND test_id = ? AND type = ?;");
			ps.setInt(1, studentID);
			ps.setInt(2, testID); 
			ps.setString(3, type.toLowerCase());
			
			ResultSet rs = ps.executeQuery(); 
			
			if (rs.next()) {
				taken = true;
			}
		}
		catch (Exception e) {
			throw new ElabException(e); 
		}
		finally {
			DatabaseConnectionManager.close(con, null);
		}
		
		return taken; 
	}

}
