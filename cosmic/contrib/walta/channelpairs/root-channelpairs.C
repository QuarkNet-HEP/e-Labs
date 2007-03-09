{
/*
 * Template with energy X axis
 *
 * Updated script that reads in and displays exactly one histogram
 * taking all needed parameters from the histogram output so no user
 * modification of this script is needed to simply view data.
 *
 * In this case I have undone some of the sophistication I used to have
 * here
 *
 *
 * read histogram data from one or several ascii file,
 * one data set per file in the bin ## ## format.
 * then display the histogram.
*/
 
gROOT->Reset();

Int_t i=0,bin=0,val=0,ncols=0,nlines=0;
Float_t fval=0.0,nevents,nentries=1;

char titlestring[64], Xaxisstring[64], Yaxisstring[64];
char htitle[10], filename[12][256], string[256], word[3][128];

//specify the number of bins.
  Int_t num=4096;

//If I don't scale x axis, firstbin and binsperdecade to zero.
//If they do need adjusting, use binsperdecade to scale.
//Example, the input histogram uses bins 0 through 64 to represent 
//         energies of 0 through 6.4 keV.  set binsperdecade = 10.
//Next example, the input histogram uses bins 0 though 10 
//              to represent distances from 0 to 50.  set binsperdace to 0.2
Int_t numbins=num;
Int_t firstbin = -(num/2) * 24 / 32;
Float_t binsperdecade = 32./24.;//1.;//24./32.;

//Specify axis titles.
strcpy(titlestring, "Time between two edges");
strcpy(Yaxisstring, "Number observed in dataset");
strcpy(Xaxisstring, "nanoseconds");

//Specify number of files, which files, and which histograms.
//by setting read_by_number and read_by_shorttitle = 0 you get the first hist.
Int_t files=6;
strcpy(filename[0],"channelpairs.txt");
strcpy(filename[1],filename[0]);
strcpy(filename[2],filename[0]);
strcpy(filename[3],filename[0]);
strcpy(filename[4],filename[0]);
strcpy(filename[5],filename[0]);
//strcpy(filename[1],"../iron/histmci20020418.txt");
//strcpy(filename[2],"histmcp20020418.txt");

int read_by_number = 1;  i = 0;
int whichnumber[12] = {0,1,2,3,4,5,6,i,i,i,i,i}; 
//int whichnumber[12] = {2,2,1,1,1,1,1,1,1,1,1,1};

int read_by_shorttitle = 0; 
char whichtitle[12][256];
     strcpy(whichtitle[0], "thistitle");
strcpy(whichtitle[1], "thistitle");

//Set up the bins, including possible scaling.
  Float_t bins[numbins+1];
  {
    Int_t i;
    for(i=0;i<numbins+1;i++)
      {
	bins[i] = firstbin + (Float_t)(i) / (binsperdecade);
      }
  }


// Change the style and other settings.
  gROOT->SetStyle("Plain");
//gStyle->SetOptStat(kFALSE);
  //these style options do not all work properly.
  //in particular, the label font 
  gStyle->SetPadBorderMode(0);
  gStyle->SetPadColor(0);
  gStyle->SetCanvasColor(0);
  gStyle->SetTitleColor(1);
  gStyle->SetStatColor(0);
  gStyle->SetTitleOffset(1.2,"xyz");
  gStyle->SetTitleFont(132);
  gStyle->SetLabelFont(132,"xyz");
  gStyle->SetDrawBorder(0);
  gStyle->SetFrameLineColor(10);
   //gStyle->SetTitleOffset(1.2,"xyz");


//Start the main loop to create and fill the histograms.
  TH1F *h[files];
  for(i=0;i<files;i++)
  {
    //open the file.
    FILE *fp;
    fp = fopen(filename[i],"r");


    //Make a very basic title for each histogram
    strcpy(htitle,"h00");
    if(i>=10){htitle[1] = '1';htitle[2] = (char)('0'+ i - 10);}
    else htitle[2] = (char)('0' + i);

    //instantiate a histogram.
    h[i] = new TH1F(htitle,titlestring,numbins,bins);


    //loop through the file, find and fill the correct histogram.
    int is_correct_hist=0;
    int found_data = 0;
    for(;;)
      {
	fgets(string,256,fp);
        ncols = sscanf(string,"%s %s %s",word[0],word[1],word[2]);
	//printf("mystring %s, bin=%8i, val=%f\n",mystring,bin,fval);

	//break at end of file, skip blank lines, notice end of histogram.
        if(feof(fp))break;
        if(ncols < 0)continue;
	if(!strcmp(word[0],"</histogram>"))
	  {
	    if(is_correct_hist)break;
	    else continue;
	  }

	//test for correct histogram.
	if(!read_by_shorttitle && !read_by_number)
	  {
	    //assume there is only one histogram
	    //if there is more than one, this takes only the first one.
	    is_correct_hist = 1;
	  }
        else if(read_by_shorttitle && !strcmp(word[0],"<shorttitle>"))

	  {
	    if(!strcmp(whichtitle[i],word[1]))is_correct_hist=1;
	  }
        else if(read_by_number && !strcmp(word[0],"<idnumber>"))
	  {
	    int tempidnumber;
	    tempidnumber = atoi(word[1]);
	    if(tempidnumber == whichnumber[i])is_correct_hist=1;
	  }

	if(!is_correct_hist)continue;
	else
	  {
	    //this block runs if I am in the middle of the correct histogram.
	    if(!strcmp(word[0],"<Nevents>"))nevents=atof(word[1]);
	    if(!strcmp(word[0],"<Nentries>"))nentries=atof(word[1]);
	    if(!strcmp(word[0],"<data>")){found_data = 1; continue;};
	    if(!strcmp(word[0],"</data>")){found_data = 0; continue;};
            //if((strcmp(word[0],"bin") && strcmp(word[0],"Bin"))  || !found_data)continue;
	    if(!strcmp(word[0],"bin") || !strcmp(word[0],"Bin") || found_data)
	      {
		if(ncols == 3)
		  {
		    fval = atof(word[2]);
		    bin = atoi(word[1]);
		  }
		else if(ncols == 2)
		  {
		    fval = atof(word[1]);
		    bin = atoi(word[0]);
		  }
		
//Any tranformation of fval goes here.

		Float_t newbin = ((Float_t)(firstbin)  +
				  (Float_t)bin / (binsperdecade));
	
		h[i]->Fill((newbin),fval);
		//else h[i]->Fill(bin,0.);
	      }
	  }
      }
    fclose(fp);

    //gPad->SetLogx(1);
    //gPad->SetLogy(1);
 
    //Draw the histograms.
    h[i]->SetXTitle(Xaxisstring);
    h[i]->SetYTitle(Yaxisstring);

    h[i]->SetMarkerStyle(21);
    h[i]->SetMarkerColor(i+1);
    h[i]->SetLineColor(i+1);
    //h[i]->SetTitleFont(22);
    if(!i)h[i]->Draw("");
    else h[i]->Draw("Same");
    //gStyle->SetFrameLineColor(21);
  }
c1->GetFrame()->SetLineColor(10);
c1->Update();
}






