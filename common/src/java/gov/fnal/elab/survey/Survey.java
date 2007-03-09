/*
 * Created on Mar 6, 2007
 */
package gov.fnal.elab.survey;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabUser;
import gov.fnal.elab.util.DatabaseConnectionManager;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class Survey {
    public static int questionCount(Elab elab) throws SQLException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            ResultSet rs;
            rs = s.executeQuery("SELECT count(*) FROM question "
                    + "WHERE question.project_id="
                    + elab.getId()
                    + " AND question.test_name='pretest';");
            if (rs.next()) {
                return rs.getInt("count");
            }
            else {
                return 0;
            }
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }

    public static int studentCount(Elab elab, ElabUser user)
            throws SQLException {
        Statement s = null;
        Connection conn = null;
        try {
            conn = DatabaseConnectionManager
                    .getConnection(elab.getProperties());
            s = conn.createStatement();
            ResultSet rs;
            String countQuery = "SELECT count(*) FROM student,research_group_student,"
                    + "research_group_project,survey "
                    + "WHERE research_group_student.research_group_id="
                    + user.getGroupID()
                    /*
                     * [Mihael] ?!?! Twice? 
                     * + " AND
                     * research_group_project.research_group_id=" + groupID
                     */
                    + " AND research_group_student.student_id=student.id"
                    + " AND survey.student_id=student.id AND survey.project_id="
                    + elab.getId() + " AND NOT(survey.presurvey);";
            rs = s.executeQuery(countQuery);
            if (rs.next()) {
                return rs.getInt("count");
            }
            else {
                return 0;
            }
        }
        finally {
            DatabaseConnectionManager.close(conn, s);
        }
    }
}
