/*
 * Created on Jun 29, 2007
 */
package gov.fnal.elab.test.impl.database;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.ElabProvider;
import gov.fnal.elab.ElabStudent;
import gov.fnal.elab.test.ElabTest;
import gov.fnal.elab.test.ElabTestProvider;
import gov.fnal.elab.test.ElabTestQuestion;
import gov.fnal.elab.test.ElabTestQuestionAnswer;
import gov.fnal.elab.util.DatabaseConnectionManager;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.util.ElabUtil;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class DatabaseTestProvider implements ElabTestProvider, ElabProvider {

    private Elab elab;
    private Map tests;

    public DatabaseTestProvider() {
        tests = new HashMap();
    }

    public void setElab(Elab elab) {
        this.elab = elab;
    }

    public ElabTest getTest(String type) throws ElabException {
        synchronized (tests) {
            if (tests.containsKey(type)) {
                return (ElabTest) tests.get(type);
            }
        }

        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            ResultSet rs = s
                    .executeQuery("SELECT question, question_no, id, response1, response2, response3, "
                            + "response4, response5, answer "
                            + "FROM question WHERE project_id='"
                            + elab.getId()
                            + "' AND "
                            + thingsShouldBeConsistentlyNamed(type, "")
                            + " ORDER BY question_no;");
            ElabTest test = new ElabTest(type);
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
            synchronized (tests) {
                tests.put(type, test);
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

    private String thingsShouldBeConsistentlyNamed(String type, String table) {
        // the backwards compatibility bit
        // eventually, the questions in the database should contain the proper
        // test
        // name
        String bctype = null;
        if (type.equals("presurvey")) {
            bctype = "pretest";
        }
        if (type.equals("postsurvey")) {
            bctype = "posttest";
        }
        String typeConstraint = table + "test_name='"
                + ElabUtil.fixQuotes(type) + "'";
        if (type != null) {
            typeConstraint = "(" + typeConstraint + " OR " + table
                    + "test_name='" + bctype + "')";
        }
        return typeConstraint;
    }

    public ElabTestQuestion getTestQuestion(String type, String questionId)
            throws ElabException {
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
                            + "' AND "
                            + thingsShouldBeConsistentlyNamed(type, "question.")
                            + " AND id = '" + questionId + "';");
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
                s.executeUpdate("UPDATE survey SET " + type
                        + "='t' WHERE project_id=" + elab.getId()
                        + " AND student_id=" + studentId + ";");
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

    public int getTotalTaken(String type, ElabGroup group) throws ElabException {
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
                    + type + "='t'";

            ResultSet rs = s
                    .executeQuery("SELECT count(student_id) FROM survey WHERE project_id="
                            + elab.getId()
                            + " AND student_id IN ("
                            + subquery
                            + ") AND " + ElabUtil.fixQuotes(type) + ";");
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
                return rs.getBoolean(type);
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

    public Map getStudentTestStatus(String type, ElabGroup group)
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
                        + " FROM survey WHERE project_id = " + elab.getId()
                        + " AND student_id = " + student.getId() + ";");
                if (rs.next()) {
                    status.put(student, Boolean.valueOf(rs.getBoolean(1)));
                }
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

    public Map getStudentResultsForTeacher(String type, ElabGroup group)
            throws ElabException {
        Statement s = null;
        Connection conn = null;
        ElabTest test = this.getTest(type);
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            Map status = new HashMap();
            Iterator i = group.getGroups().iterator();
            while (i.hasNext()) {
                ElabGroup g = (ElabGroup) i.next();
                if (!g.getSurvey()) {
                	continue;
                }
                Iterator j = g.getStudents().iterator();
                while (j.hasNext()) {
                    ElabStudent student = (ElabStudent) j.next();
                    List questions = new ArrayList();
                    Iterator k = test.getQuestions().iterator();
                    while (k.hasNext()) {
                        ElabTestQuestion question = (ElabTestQuestion) k.next();
                        ResultSet rs = s
                                .executeQuery("SELECT answer FROM answer WHERE student_id = '"
                                        + student.getId()
                                        + "' AND question_id = "
                                        + question.getId() + ";");
                        if (rs.next()) {
                            ElabTestQuestion q2 = new ElabTestQuestion(question);
                            questions.add(q2);
                            q2
                                    .setGivenAnswer(q2.getAnswer(rs
                                            .getInt("answer")));
                        }
                    }
                    status.put(student, questions);
                }
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
