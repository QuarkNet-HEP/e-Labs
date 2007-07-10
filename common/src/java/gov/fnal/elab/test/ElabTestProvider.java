/*
 * Created on Jun 29, 2007
 */
package gov.fnal.elab.test;

import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.util.ElabException;

import java.util.Map;

public interface ElabTestProvider {
    ElabTest getTest(String name) throws ElabException;
    
    ElabTestQuestion getTestQuestion(String testType, String questionId) throws ElabException;
    
    void recordTestAnswers(String type, String studentId, Map answers) throws ElabException;
    
    int getTotalStudents(ElabGroup group) throws ElabException;
    
    int getTotalTaken(ElabGroup group, String type) throws ElabException;
    
    boolean hasStudentTakenTest(String type, String studentId) throws ElabException;
    
    Map getStudentTestStatus(ElabGroup group, String type) throws ElabException;
}
