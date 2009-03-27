package gov.fnal.elab.survey;

public class ElabSurveyQuestionAnswer implements Comparable<ElabSurveyQuestionAnswer> {
	private String text; 
	private Integer id; 

	public ElabSurveyQuestionAnswer(int id, String text ) {
		this.id = new Integer(id);
		this.text = text; 
	}
	
	public void setText(String text) {
		this.text = text;
	}

	public String getText() {
		return text;
	}

	public void setId(int id) {
		this.id = new Integer(id);
	}

	public Integer getId() {
		return id;
	} 
	
	public int compareTo(ElabSurveyQuestionAnswer o) {
		// TODO Auto-generated method stub
		return this.id.compareTo(o.id);
	}
	
	public boolean equals(ElabSurveyQuestionAnswer o) {
		return this.compareTo(o) == 0;
	}
}
