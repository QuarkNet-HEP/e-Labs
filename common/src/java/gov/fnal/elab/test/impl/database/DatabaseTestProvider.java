/*
 * Created on Jun 29, 2007
 */
package gov.fnal.elab.test.impl.database;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.ElabStudent;
import gov.fnal.elab.test.ElabTest;
import gov.fnal.elab.test.ElabTestProvider;
import gov.fnal.elab.test.ElabTestQuestion;
import gov.fnal.elab.test.ElabTestQuestionAnswer;
import gov.fnal.elab.util.DatabaseConnectionManager;
import gov.fnal.elab.util.ElabException;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class DatabaseTestProvider implements ElabTestProvider {

    private Elab elab;

    public DatabaseTestProvider(Elab elab) {
        this.elab = elab;
    }

    public ElabTest getTest(String name) throws ElabException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            ResultSet rs = s
                    .executeQuery("SELECT question, question_no, id, response1, response2, response3, "
                            + "response4, response5, answer "
                            + "FROM question WHERE question.project_id='"
                            + elab.getId()
                            + "' AND question.test_name='"
                            + name + "' ORDER BY question.question_no;");
            ElabTest test = new ElabTest(name);
            while (rs.next()) {
                ElabTestQuestion question = new ElabTestQuestion();
                question.setText(rs.getString("question"));
                question.setId(rs.getString("id"));
                for (int i = 1; i <= 5; i++) {
                    String r = rs.getString("response" + i);
                    if (r != null && !r.equals("")) {
                        ElabTestQuestionAnswer answer = new ElabTestQuestionAnswer();
                        answer.setText(r);
                        if (String.valueOf(i).equals(rs.getString("answer"))) {
                            answer.setCorrect(true);
                            question.setCorrectAnswer(answer);
                        }
                        question.addAnswer(answer);
                    }
                }
                test.addQuestion(question);
            }
            return test;
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }
    
    public ElabTestQuestion getTestQuestion(String testType, String questionId) throws ElabException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            ResultSet rs = s
                    .executeQuery("SELECT question, question_no, id, response1, response2, response3, "
                            + "response4, response5, answer "
                            + "FROM question WHERE question.project_id='"
                            + elab.getId()
                            + "' AND question.test_name='"
                            + testType + "' AND id = '" + questionId + "';");
            if (rs.next()) {
                ElabTestQuestion question = new ElabTestQuestion();
                question.setText(rs.getString("question"));
                question.setId(rs.getString("id"));
                for (int i = 1; i <= 5; i++) {
                    String r = rs.getString("response" + i);
                    if (r != null && !r.equals("")) {
                        ElabTestQuestionAnswer answer = new ElabTestQuestionAnswer();
                        answer.setText(r);
                        if (String.valueOf(i).equals(rs.getString("answer"))) {
                            answer.setCorrect(true);
                            question.setCorrectAnswer(answer);
                        }
                        question.addAnswer(answer);
                    }
                }
                return question;
            }
            else {
                throw new SQLException("No such question");
            }
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    public void recordTestAnswers(String type, String studentId, Map answers)
            throws ElabException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            conn.setAutoCommit(false);
            try {
                Iterator i = answers.entrySet().iterator();
                while (i.hasNext()) {
                    Map.Entry e = (Map.Entry) i.next();
                    String qid = (String) e.getKey();
                    String answer = (String) e.getValue();
                    s
                            .executeUpdate("INSERT INTO answer (question_id, student_id, answer) VALUES ('"
                                    + qid
                                    + "', '"
                                    + studentId
                                    + "', '"
                                    + answer + "');");
                }
                s.executeUpdate("INSERT INTO survey (project_id, student_id, "
                        + type + "survey) VALUES (" + elab.getId() + ", "
                        + studentId + ", 't');");
                conn.commit();
            }
            catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    public int getTotalStudents(ElabGroup group) throws ElabException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            String subquery = "SELECT student.id FROM student, research_group_student, "
                    + "research_group_project, survey WHERE research_group_student.research_group_id = "
                    + group.getId()
                    + " AND research_group_project.research_group_id = "
                    + group.getId()
                    + "  AND research_group_student.student_id=student.id AND survey.student_id=student.id "
                    + "AND survey.project_id=" + elab.getId();

            ResultSet rs = s
                    .executeQuery("SELECT COUNT(student_id) FROM survey WHERE project_id="
                            + elab.getId()
                            + " AND student_id IN ("
                            + subquery
                            + ");");
            if (rs.next()) {
                return Integer.parseInt(rs.getString(1));
            }
            else {
                return 0;
            }
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    public int getTotalTaken(ElabGroup group, String type) throws ElabException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            String subquery = "SELECT student.id FROM student, research_group_student, "
                    + "research_group_project, survey WHERE research_group_student.research_group_id = "
                    + group.getId()
                    + " AND research_group_project.research_group_id = "
                    + group.getId()
                    + "  AND research_group_student.student_id = student.id AND survey.student_id = student.id "
                    + "AND survey.project_id="
                    + elab.getId()
                    + " AND survey."
                    + type + "survey='t'";

            ResultSet rs = s
                    .executeQuery("SELECT count(student_id) FROM survey WHERE project_id="
                            + elab.getId()
                            + " AND student_id IN ("
                            + subquery
                            + ");");
            if (rs.next()) {
                return Integer.parseInt(rs.getString(1));
            }
            else {
                return 0;
            }
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    public boolean hasStudentTakenTest(String type, String studentId)
            throws ElabException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            ResultSet rs = s
                    .executeQuery("SELECT * FROM survey WHERE project_id = "
                            + elab.getId() + " AND student_id = " + studentId
                            + ";");
            if (rs.next()) {
                return rs.getBoolean(type + "survey");
            }
            else {
                return false;
            }
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    public Map getStudentTestStatus(ElabGroup group, String type)
            throws ElabException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            Map status = new HashMap();
            Iterator i = group.getStudents().iterator();
            while (i.hasNext()) {
                ElabStudent student = (ElabStudent) i.next();
                ResultSet rs = s.executeQuery("SELECT " + type
                        + "survey FROM survey WHERE project_id = "
                        + elab.getId() + " AND student_id = " + student.getId()
                        + ";");
                status.put(student, Boolean.valueOf(rs.getBoolean(1)));
            }
            return status;
        }
        catch (Exception e) {
            throw new ElabException(e);
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }
}
