/*
 * Created on Jun 29, 2007
 */
package gov.fnal.elab.test;

import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.ElabProvider;
import gov.fnal.elab.util.ElabException;

import java.util.Map;

public interface ElabTestProvider extends ElabProvider {
    /**
     * Returns a test object for the given test type
     */
    ElabTest getTest(String type) throws ElabException;

    /**
     * Returns a specific question. It so seems that question ids must be unique
     * across all tests.
     */
    ElabTestQuestion getTestQuestion(String type, String questionId)
            throws ElabException;

    /**
     * Records a set of test answers. The keys in the answers map must be
     * {@link String} objects representing question IDs, and the values must
     * also be {@link String} objects representing answer indices (string
     * conversions of {@link ElabTestQuestionAnswer.getIndex()}).
     */
    void recordTestAnswers(String type, String studentId, Map answers)
            throws ElabException;

    /**
     * Returns the total number of students in a group.
     */
    int getTotalStudents(ElabGroup group) throws ElabException;

    /**
     * Returns the total number of students in the specified group which have
     * taken the test of type indicated by the type parameter
     */
    int getTotalTaken(String type, ElabGroup group) throws ElabException;

    /**
     * Returns <code>true</code> if a student (with the specified id) has
     * taken a certain test (specified by the type parameter)
     */
    boolean hasStudentTakenTest(String type, String studentId)
            throws ElabException;

    /**
     * Returns a map indicating whether individual students in the specified
     * group have taken a test or not. The keys in the map are
     * {@link ElabStudent} objects, while the values are {@link Boolean}
     * objects.
     */
    Map getStudentTestStatus(String type, ElabGroup group) throws ElabException;

    /**
     * Returns a map containing test answers given by students in groups
     * belonging to the specified teacher for the specified test. The keys in
     * the map are {@link ElabStudent} objects, while the values are
     * {@link ElabTestQuestion} objects.
     */
    Map getStudentResultsForTeacher(String type, ElabGroup teacher)
            throws ElabException;
    
    public boolean hasTeacherAssignedTest(int teacherId) throws ElabException; 
}
