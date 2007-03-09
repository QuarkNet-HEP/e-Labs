package gov.fnal.elab.cms.beans;

import java.util.Vector;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.ResultSet;

public class RunDataBean {

	private Connection conn=null;
	private String connAddress ="jdbc:postgresql://localhost/ogredb";
	private String connUser="ogre";
	private String connPass="";
	
	private Vector runDataVector;  //for internal use only !!!
	private String runOptionsArray="";
	private String runListArray="";
	private String muonArray="";
	private String pionArray="";
	private String elecArray="";
	private String calArray="";
	private String runDataArray="";

	public RunDataBean(){
		runDataVector=new Vector();
		System.out.println("Creating RunDataBeam");
	}
	
	
	public String getRunOptionsArray(){
		if (runOptionsArray.length()==0){
			System.out.println("Reading database data for run options selection field");
			runDataVector=getDBData("");
			for (int i=0;i<runDataVector.size();i++){
				runOptionsArray+="<option value='"+runDataVector.get(i)+"'> Run "+runDataVector.get(i)+"\n"; 
			}
		}
		return runOptionsArray;
	}
	
	public String getRunListArray(){
		if (runListArray.length()==0){
			System.out.println("Reading database data for run options selection field");
			runDataVector=getDBData("");
			runListArray="var runList = new Array(";
			for (int i=0;i<runDataVector.size();i++){
				runListArray+=runDataVector.get(i)+", "; 
			}
			runListArray+="null);";
		}
		return runListArray;
	}

	
	public String getMuonArray(){
		if (muonArray.length()==0){
			System.out.println("Reading database data for muons");
			runDataVector=getDBData("muon");
			muonArray="var muonRuns = new Array(";
			for (int i=0;i<runDataVector.size();i++){
				muonArray+=runDataVector.get(i)+", ";
			}
			muonArray+="null);";
		}
		return muonArray;
	}

	public String getPionArray(){
		if (pionArray.length()==0){
			System.out.println("Reading database data for pions");
			runDataVector=getDBData("pion");
			pionArray="var pionRuns = new Array(";
			for (int i=0;i<runDataVector.size();i++){
				pionArray+=runDataVector.get(i)+", ";
			}
			pionArray+="null);";
		}
		return pionArray;
	}
	
	public String getElecArray(){
		if (elecArray.length()==0){
			System.out.println("Reading database data for electrons");
			runDataVector=getDBData("elec");
			elecArray="var elecRuns = new Array(";
			for (int i=0;i<runDataVector.size();i++){
				elecArray+=runDataVector.get(i)+", ";
			}
			elecArray+="null);";
		}
		return elecArray;
	}

	public String getCalArray(){
		if (calArray.length()==0){
			System.out.println("Reading database data for calibration");
			runDataVector=getDBData("cal");
			calArray="var calRuns = new Array(";
			for (int i=0;i<runDataVector.size();i++){
				calArray+=runDataVector.get(i)+", ";
			}
			calArray+="null);";
		}
		return calArray;
	}

	//return lines like: "Run 11000 60000 events of 150GeV Mu-   \n",
	public String getRunDataArray(){
		
		if (runDataArray.length()==0){
			System.out.println("Reading database data");
			runDataArray="var runData = new Array(";
			if (conn==null){
				try{
					Class.forName("org.postgresql.Driver");

					conn=DriverManager.getConnection(connAddress,connUser,connPass);

				}catch(ClassNotFoundException cnfe){
					System.out.println(cnfe.getLocalizedMessage());
				}catch(SQLException sqle){
					System.out.println(sqle.getLocalizedMessage());
				}
			} //if conn=null
			try{
				Statement stmt=conn.createStatement();
				
				ResultSet rs=stmt.executeQuery("select run,nevents,energy,beam from rundb;");
				while(rs.next()){
					runDataArray+="\"Run "+rs.getString("run")+" "+rs.getString("nevents")+" events of "+rs.getString("energy")+"GeV "+rs.getString("beam")+"     \\n\",\n";
				}
				runDataArray+="null);";

				stmt.close();
			}catch(SQLException sqle){
				System.out.println(sqle.getLocalizedMessage());
			}
		}
		return runDataArray;
	}

	
	private Vector getDBData(String condition){
		Vector tableData=new Vector();
		System.out.println("Reading data from DB");
		if (conn==null){
			try{
				System.out.println("Creating a new database connection");
				Class.forName("org.postgresql.Driver");

				conn=DriverManager.getConnection(connAddress,connUser,connPass);

			}catch(ClassNotFoundException cnfe){
				System.out.println(cnfe.getLocalizedMessage());
			}catch(SQLException sqle){
				System.out.println(sqle.getLocalizedMessage());
			}
		} //if conn=null
		try{
			Statement stmt=conn.createStatement();
			ResultSet rs=null;
			if(condition.length()==0){
				rs=stmt.executeQuery("select run from rundb;");
			}
			if("muon".equalsIgnoreCase(condition)){
				rs=stmt.executeQuery("select run from rundb where beam='Mu-';");
			}
			if("pion".equalsIgnoreCase(condition)){
				rs=stmt.executeQuery("select run from rundb where beam='Pi-';");
			}
			if("elec".equalsIgnoreCase(condition)){
				rs=stmt.executeQuery("select run from rundb where beam='e-';");
			}
			if("cal".equalsIgnoreCase(condition)){
				rs=stmt.executeQuery("select run from rundb where beam='LED';");
			}
			while(rs.next()){
				tableData.add(rs.getString("run"));
			}
			stmt.close();
		}catch(SQLException sqle){
			System.out.println(sqle.getLocalizedMessage());
		}
		return tableData;
	}
	
}
