package gov.fnal.elab.survey;

import java.util.Collection;
import java.util.Iterator;
import java.util.SortedMap;
import gov.fnal.elab.util.ElabException;


public class ElabSurveyQuestion implements Cloneable {
	private int id; 
	private SortedMap answers; 
	private String text; 
	private ElabSurveyQuestionAnswer correctAnswer = null, givenAnswer = null; 
	
	public ElabSurveyQuestion(int id, String text) {
		this.id = id; 
		this.text = text; 
		this.answers = new java.util.TreeMap(); 
	}
	
	public void addAnswer(ElabSurveyQuestionAnswer a) {
		this.answers.put(a.getId(), a);
	}
	
	public int getId() {
		return id;
	}
	
	public String getText() {
		return text;
	}
	
	public Collection getAnswers() {
		return answers.values(); 
	}
	
	public void setCorrectAnswer(int id) {
		this.correctAnswer = (ElabSurveyQuestionAnswer) this.answers.get(new Integer(id));
	};

	public void setCorrectAnswer(ElabSurveyQuestionAnswer correctAnswer) {
		this.correctAnswer = correctAnswer;
	}

	public ElabSurveyQuestionAnswer getCorrectAnswer() {
		return correctAnswer;
	}
	
	public void setGivenAnswer(int id) {
		this.givenAnswer = (ElabSurveyQuestionAnswer) this.answers.get(new Integer(id));
	}

	public void setGivenAnswer(ElabSurveyQuestionAnswer givenAnswer) {
		this.givenAnswer = givenAnswer;
	}

	public ElabSurveyQuestionAnswer getGivenAnswer() {
		return givenAnswer;
	}
	
	public boolean getCorrectAnswerGiven() {
		if ((givenAnswer != null) && (correctAnswer!= null) && (correctAnswer == givenAnswer)) {
			return true;
		}
		return false; 
	}
	
	public Object clone() {
		ElabSurveyQuestion question = null;
		try {
			question = (ElabSurveyQuestion) super.clone();
			//for (Iterator i = answers.values().iterator(); i.hasNext(); ) {
			//	question.addAnswer((ElabSurveyQuestionAnswer) i.next());
			//}
			//question.setCorrectAnswer(this.correctAnswer);
			//question.setGivenAnswer(this.givenAnswer);
			
		}
		catch (CloneNotSupportedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} 
		return question; 
	}
}
