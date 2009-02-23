package gov.fnal.elab.survey;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class ElabSurveyQuestion {
	private int id; 
	private List answers; 
	private String text; 
	private ElabSurveyQuestionAnswer correctAnswer; 
	
	public ElabSurveyQuestion(int id, String text) {
		this.id = id; 
		this.text = text; 
		this.answers = new ArrayList(); 
	}
	
	public void addAnswer(ElabSurveyQuestionAnswer a) {
		answers.add(a);
	}
	
	public int getId() {
		return id;
	}
	
	public String getText() {
		return text;
	}
	
	public List getAnswers() {
		return answers; 
	}

	public void setCorrectAnswer(ElabSurveyQuestionAnswer correctAnswer) {
		this.correctAnswer = correctAnswer;
	}

	public ElabSurveyQuestionAnswer getCorrectAnswer() {
		return correctAnswer;
	}
}
