package gov.fnal.elab.survey;

public class ElabSurveyQuestionAnswer implements Comparable {
	private String text; 
	private Integer id; 
		
	public int compareTo(Object o) {
		// TODO Auto-generated method stub
		return this.id.compareTo(((ElabSurveyQuestionAnswer) o).id);
	}

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
}
