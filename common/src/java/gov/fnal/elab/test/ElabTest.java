/*
 * Created on Jun 29, 2007
 */
package gov.fnal.elab.test;

import java.util.ArrayList;
import java.util.List;

public class ElabTest {
    private String type;
    private List<ElabTestQuestion> questions;
    
    public ElabTest(String type) {
        this.type = type;
        this.questions = new ArrayList<ElabTestQuestion>();
    }
    
    public List<ElabTestQuestion> getQuestions() {
        return questions;
    }
    
    public int getQuestionCount() {
        return questions.size();
    }
    
    public void addQuestion(ElabTestQuestion question) {
        if (question.getIndex() == 0) {
            question.setIndex(questions.size() + 1);
        }
        questions.add(question);
    }
    
    public String getType() {
        return type;
    }
}
