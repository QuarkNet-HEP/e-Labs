/*
 * Created on Jun 29, 2007
 */
package gov.fnal.elab.test;

public class ElabTestQuestionAnswer {
    private String text;
    private int index;
    private boolean correct;
    
    public int getIndex() {
        return index;
    }
    
    public void setIndex(int index) {
        this.index = index;
    }
    
    public String getText() {
        return text;
    }
    
    public void setText(String text) {
        this.text = text;
    }

    public boolean isCorrect() {
        return correct;
    }

    public void setCorrect(boolean correct) {
        this.correct = correct;
    }

    public boolean equals(Object obj) {
        if (obj instanceof ElabTestQuestionAnswer) {
            ElabTestQuestionAnswer a = (ElabTestQuestionAnswer) obj;
            return a.index == index;
        }
        else {
            return false;
        }
    }

    public int hashCode() {
        return text.hashCode() + index;
    }
}
