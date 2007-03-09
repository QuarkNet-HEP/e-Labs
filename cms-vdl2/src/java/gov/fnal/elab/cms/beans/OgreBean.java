package gov.fnal.elab.cms.beans;

import java.util.Random;

public class OgreBean {

	// data options
	/**
	 * equivalent to the number of plots to be displayed
	 */
	private String number_of_variables; 
	private String[] leaf;
	private String[] formula;
	private String savedata;
	private String dataset_location;

	//run options
	private String[] muon_runs, pion_runs, elec_runs, cal_runs, all_runs; //run_type
	private String[] run_number; //run_number

	//graphics options
	private String gWidth, gHeight;
	private String type;
	private String[] allonone;
	
	//cut is the value that gives the cut limit
	//cuttype decides if there is going to be a cut or not
	private String[] color, cut, cuttype, cutf, colorf; 
	private String logx,logy;
	private String[] labelx, labely, title; // from tb_data.xml, tibi sent them from ogre.php
	private String[] root_leaf;

	//NOTE: support files
	private String randFileID;
	private String tempDir;
	private String cmsDataPath;

	
	private Random rand;
	
	public String[] getCutf() {
		return cutf;
	}

	public void setCutf(String[] cutf) {
		this.cutf = cutf;
	}

	public OgreBean(){
		//TODO: find out good defaults, in case not provided by the webpage
		muon_runs= pion_runs= elec_runs= cal_runs= all_runs=new String[] {"0"};
		run_number=new String[]{};
		gWidth="800";
		gHeight="600";
		type="1";
		allonone=new String[] {"0"};
		dataset_location="";
		leaf=new String[]{};
		cut=new String[]{};
		cuttype=new String[]{};
		cutf=new String[]{};
		formula=new String[]{};
		labelx=labely=title=new String[]{};
		color=new String[]{};
		colorf=new String[]{};
		root_leaf=new String[]{};
		logx= logy= savedata="0";
		randFileID="Script-x.C";
		tempDir="/tmp";
		rand=new Random();
		cmsDataPath=System.getProperty("cms.output.dir");
		savedata="0";

	}
	
	public String invokeWorkflow(){
				
		randFileID=""+rand.nextDouble();
		
		String rootScript="{\n";
		String errorCode="";
		String scanString="";
		String draw_options="";
		
		rootScript+="\n\t gROOT->Reset();";
		rootScript+="\n\t TCanvas *canvas = new TCanvas(\"c1\",\"\","+gWidth+","+gHeight+");";

		//rootScript+="\n\n\t DEBUG: leaf.length="+leaf.length+" formula.length= "+formula.length; 
		
		//get the number of leaves
		int noPlots=leaf.length+formula.length;
		
		if (!allonone[0].equalsIgnoreCase("1")){
			if (noPlots==4){
				rootScript+= "\n\t canvas->Divide(2,2);";
			} else if (noPlots==5 || noPlots==6){
				rootScript+= "\n\t canvas->Divide(3,2);";
			} else if (noPlots == 7 || noPlots == 8 ){
				rootScript += "\n\t canvas->Divide(4,2);";
			} else {
				rootScript+= "\n\t canvas->Divide(1,"+noPlots+");\n";
			}	
		}

		// Create a new chain, and add the requested files to it
		//String[] events=new String[] {"Event"};   
		//EVENT comes from the tb_data.xml, but is not passed by the webpage
		rootScript+= "\n\t TChain *chain = new TChain(\"Event\");";
		
		//generate the file names from location and run name
		//TODO: BIG ASSUMPTION: run-name (RUN) = file-name rRUN.root
		//chech what runs have been selected

		//check runs, v2: use run_number String array
		
		for (int i = 0; i < run_number.length; i++) {
		    rootScript+= "\n\t chain->Add(\""+dataset_location+"/r"+run_number[i]+".root\");";
		 }
		
		//Run through the variables and pop them onto the canvas
		for (int v=0; v<noPlots; v++) {
			
			int leafIndex=0;
			int formulaIndex=0;
			
			try{
				if (v<leaf.length){
					//leaves
					String leafIndexString=leaf[v]; 
					leafIndex = Integer.parseInt(leafIndexString, 10);
				}else{
					//formula
					String formulaIndexString=formula[v-leaf.length]; 
					formulaIndex = Integer.parseInt(formulaIndexString, 10);
				}
			}catch(NumberFormatException e){
				errorCode+=e.getLocalizedMessage();
				break;
			}
			
			//rootScript+="\n\n\t DEBUG: leaf.index="+leafIndex+" formula.index= "+formulaIndex; 

			int pad = v + 1;

		    // Set the focus to the next pad
		    if (!allonone[0].equalsIgnoreCase("1")) {
		    	rootScript+= "\n\t c1_"+pad+"->cd();";
		    }else{
		    	//TODO: this shows up twice on the root script !?!
		    	rootScript+= "\n\t gStyle->SetOptStat(0);";
		    }


		    // Set the axes to a log plot if requested
		    if ( !allonone[0].equalsIgnoreCase("1") ) {
		      if ( logx.equalsIgnoreCase("1") ) rootScript+= "\n\t c1_"+pad+"->SetLogx();";
		      if ( logy.equalsIgnoreCase("1") ) rootScript+=  "\n\t c1_"+pad+"->SetLogy();";
		    } else if ( v == 0 ) {
		    	if ( logx.equalsIgnoreCase("1") ) rootScript+=  "\n\t c1->SetLogx();";
		    	if ( logy.equalsIgnoreCase("1") ) rootScript+=  "\n\t c1->SetLogy();";
		    }

		    // Set the histogram fill color 
		    if(v<leaf.length){
			    rootScript+= "\n\t chain->SetFillColor("+color[leafIndex]+");";

			    //Build up the leaf names, to be used later with savedata
				scanString+="cluster."+root_leaf[leafIndex]+":";
				
				//Initialize the holding place for the arguments to the Draw() command
				draw_options = "\"cluster."+root_leaf[leafIndex]+"\"";
		    }else{
			    rootScript+= "\n\t chain->SetFillColor("+colorf[formulaIndex]+");";

			    //Build up the leaf names, to be used later with savedata
				scanString+="formula."+cutf[formulaIndex]+":";
				
				//Initialize the holding place for the arguments to the Draw() command
				draw_options = "\""+cutf[formulaIndex]+"\"";
		    	
		    }

			//Form the selection cuts: Any global cuts + any cuts for this variable and NULL if neither

			//FIXME: from where REDESIGNED LOGIC
			String global_cut="beam==1";
			//"beam==1&&c3x3.e>0"
			if ( cut[leafIndex].length() > 0 && cuttype[leafIndex].equalsIgnoreCase("1") ) {
			      draw_options += ", \""+global_cut+"&&"+root_leaf[leafIndex]+">"+cut[leafIndex]+"\"";
			} else if ( cut[leafIndex].length() > 0 && cuttype[leafIndex].equalsIgnoreCase("2") ) {
				draw_options += ", \""+global_cut+"&&"+root_leaf[leafIndex]+"<"+cut[leafIndex]+"\"";
			} else if ( cut[leafIndex].length() <= 0 && cuttype[leafIndex].equalsIgnoreCase("1") ) {
			      draw_options +=", \"$cuts[$v]\"";
			} else {              // no cuts: lengthl(global) <= 0 && not exists $cuts[$v]
			      draw_options += ", NULL";
			}
			
			//If we're stacking histograms on each other, then the options = "same", otherwise null.
			
			if ( allonone[0].equalsIgnoreCase("1") && v>0 ) {
				draw_options += ", \"same\"";
			} else {
			     draw_options +=", NULL";
			}
  
		    // Now that we have everything... Put this plot onto the pad
		    rootScript+= "\n\t chain->Draw("+draw_options+");";
		    		    
		    if ( !allonone[0].equalsIgnoreCase("1") ) {
		    	if(v<leaf.length){
			    	if ( labelx.length >leafIndex && labelx[leafIndex]!=null ) rootScript+= "\n\t htemp->GetXaxis()->SetTitle(\""+labelx[leafIndex]+"\");";
			    	if ( labely.length >leafIndex && labely[leafIndex]!=null ) rootScript+=  "\n\t htemp->GetYaxis()->SetTitle(\""+labely[leafIndex]+"\");";
			    	if ( title.length >leafIndex && title[leafIndex]!=null ) rootScript+=  "\n\t htemp->SetTitle(\""+title[leafIndex]+"\");";
		    	}else{
			    	if ( labelx.length >formulaIndex && labelx[9+formulaIndex]!=null ) rootScript+= "\n\t htemp->GetXaxis()->SetTitle(\""+labelx[9+formulaIndex]+"\");";
			    	if ( labely.length >formulaIndex && labely[9+formulaIndex]!=null ) rootScript+=  "\n\t htemp->GetYaxis()->SetTitle(\""+labely[9+formulaIndex]+"\");";
			    	if ( title.length >formulaIndex && title[9+formulaIndex]!=null ) rootScript+=  "\n\t htemp->SetTitle(\""+title[9+formulaIndex]+"\");";
		    	}
		    }

		  }
		
		
	    // If all the plots are on one canvas... make out own title out of all of them
		
		  if ( allonone[0].equalsIgnoreCase("1") ) {
		      String tmpTitle = "title[0]";
		      for (int v=1; v<=noPlots; v++) {
		    	  tmpTitle += ", "+ title[v];
		      }
		      
		      //rootScript +=labelx.length;
		      
		      if ( labelx[0]!=null ) rootScript+= "\n\t htemp->GetXaxis()->SetTitle(\""+labelx[0]+"\");";
		      if ( labely[0]!=null) rootScript+= "\n\t htemp->GetYaxis()->SetTitle(\""+labely[0]+"\");";
		      rootScript+= "\n\t htemp->SetTitle(\""+tmpTitle+"\");";

		    }

		  // Switch the focus to the base canvas, and redraw to finalize the postscript
	    rootScript+= "\n\t canvas->cd();";
	    rootScript+= "\n\t canvas->Update();";
	    //rootScript+= "\n\t canvas->SaveAs(\""+cmsDataPath.substring(1)+"/canvas-"+randFileID+"."+getType()+"\");";
	    rootScript+= "\n\t canvas->SaveAs(\"canvas-"+randFileID+"."+getType()+"\");";

	    //save the raw data to be displayed in a form, for later, external processing
	    if(savedata.equalsIgnoreCase("1")){
	    	rootScript+="\n\n\t chain->SetScanField(chain->GetEntries()+1);";
	    	rootScript+="\n\t chain->Scan(\""+scanString.substring(0, scanString.length()-1)+"\");";
	    }
	    
	    rootScript+="\n}\n";
		
	    
		return rootScript;
		
	}
	
	
	public Boolean validate(){
		return Boolean.TRUE;
	}
	
	public String getNumber_of_variables() {
		return number_of_variables;
	}

	public void setNumber_of_variables(String number_of_variables) {
		this.number_of_variables = number_of_variables;
	}

	public String getSavedata() {
		return savedata;
	}

	public void setSavedata(String savedata) {
		this.savedata = savedata;
	}

	public String[] getAll_runs() {
		return all_runs;
	}

	public void setAll_runs(String[] all_runs) {
		this.all_runs = all_runs;
	}

	public String[] getAllonone() {
		return allonone;
	}

	public void setAllonone(String[] allonone) {
		this.allonone = allonone;
	}

	public String[] getCal_runs() {
		return cal_runs;
	}

	public void setCal_runs(String[] cal_runs) {
		this.cal_runs = cal_runs;
	}

	public String[] getElec_runs() {
		return elec_runs;
	}

	public void setElec_runs(String[] elec_runs) {
		this.elec_runs = elec_runs;
	}

	public String getGHeight() {
		return gHeight;
	}

	public void setGHeight(String height) {
		gHeight = height;
	}

	public String getGWidth() {
		return gWidth;
	}

	public void setGWidth(String width) {
		gWidth = width;
	}

	public String[] getMuon_runs() {
		return muon_runs;
	}

	public void setMuon_runs(String[] muon_runs) {
		this.muon_runs = muon_runs;
	}

	public String[] getPion_runs() {
		return pion_runs;
	}

	public void setPion_runs(String[] pion_runs) {
		this.pion_runs = pion_runs;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String[] getRun_number() {
		return run_number;
	}

	public void setRun_number(String[] run_number) {
		this.run_number = run_number;
	}

	public String[] getLeaf() {
		return leaf;
	}

	public void setLeaf(String[] leaf) {
		this.leaf = leaf;
	}

	public String[] getColor() {
		return color;
	}

	public void setColor(String[] color) {
		this.color = color;
	}

	public String[] getCut() {
		return cut;
	}

	public void setCut(String[] cut) {
		this.cut = cut;
	}

	public String getLogx() {
		return logx;
	}

	public void setLogx(String logx) {
		this.logx = logx;
	}

	public String getLogy() {
		return logy;
	}

	public void setLogy(String logy) {
		this.logy = logy;
	}

	public String[] getRoot_leaf() {
		return root_leaf;
	}

	public void setRoot_leaf(String[] root_leaf) {
		this.root_leaf = root_leaf;
	}

	public String[] getCuttype() {
		return cuttype;
	}

	public void setCuttype(String[] cuttype) {
		this.cuttype = cuttype;
	}

	public String getDataset_location() {
		return dataset_location;
	}

	public void setDataset_location(String dataset_location) {
		this.dataset_location = dataset_location;
	}

	public String[] getLabelx() {
		return labelx;
	}

	public void setLabelx(String[] labelx) {
		this.labelx = labelx;
	}

	public String[] getLabely() {
		return labely;
	}

	public void setLabely(String[] labely) {
		this.labely = labely;
	}

	public String[] getTitle() {
		return title;
	}

	public void setTitle(String[] title) {
		this.title = title;
	}

	public String getRandFileID() {
		return randFileID;
	}

	public void setRandFileID(String randFileID) {
		this.randFileID = randFileID;
	}

	public String getTempDir() {
		return tempDir;
	}

	public void setTempDir(String tempDir) {
		this.tempDir = tempDir;
	}

	public String getCmsDataPath() {
		return cmsDataPath;
	}

	public String[] getFormula() {
		return formula;
	}

	public void setFormula(String[] formula) {
		this.formula = formula;
	}

	public String[] getColorf() {
		return colorf;
	}

	public void setColorf(String[] colorf) {
		this.colorf = colorf;
	}

}
