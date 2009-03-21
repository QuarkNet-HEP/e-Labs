{

gROOT->Reset();
gROOT->SetStyle("Plain");

gStyle->SetOptStat(kFALSE);
gStyle->SetPadBorderMode(0);
gStyle->SetPadColor(0);
gStyle->SetCanvasColor(0);
gStyle->SetTitleColor(1);
gStyle->SetStatColor(0);
gStyle->SetTitleOffset(1.2,"xy");
gStyle->SetTitleFont(132);
gStyle->SetLabelFont(132,"xy");
gStyle->SetMarkerStyle(21);  //21 = box, 24 = open circle
gStyle->SetMarkerSize(0.2);  //0.2 is nice.



ifstream in("twodeltat.ntuple.txt");
//ifstream in("temp.txt");
if(!in){cout << "could not open infile" << endl;}

Int_t ncols;
Int_t nlines;

TNtuple *ntuple = new TNtuple("ntuple","data from ascii file","x:y");



for(int i=0; !in.eof(); i++){
  double x,y,z;
  in >> x >> y;
  if(i<5)cout << x << " " << y << " " << endl;

  // add dithering.
  double randomx = gRandom->Rndm(1);
  double randomy = gRandom->Rndm(1);
  x = x + randomx - 0.5;
  y = y + randomy - 0.5;

  if(x<0)x=0; if(y<0)y=0;
  ntuple->Fill(x*24./32.,y*24./32.);
}
in.clear();
in.close();

 ntuple->SetMarkerStyle(24);
 ntuple->SetMarkerSize(0.4);
 ntuple->Draw("x:y","x<600 && y<600");
 //ntuple->Draw("x:y","y<1500","surf2");
 htemp->GetYaxis()->SetTitle("Tb - Ta (nanoseconds)");
 htemp->GetYaxis()->SetTitleFont(132);
 htemp->GetYaxis()->SetTitleColor(1);
 htemp->GetYaxis()->SetTitleSize(0.05);
 htemp->GetYaxis()->SetTitleOffset(1.2); 
 htemp->GetYaxis()->SetLabelSize(0.05);
 htemp->GetXaxis()->SetTitle("Tc - Tb (nanoseconds)");
 htemp->GetXaxis()->SetTitleFont(132);
 htemp->GetXaxis()->SetTitleColor(1);
 htemp->GetXaxis()->SetTitleSize(0.05);
 htemp->GetXaxis()->SetTitleOffset(1.0); 
 htemp->GetXaxis()->SetLabelSize(0.05);
//ntuple->Draw(y:x);
//ntuple->Draw("x:y>>myhist","y>0","thishist");
//myhist->SetMarkerStyle(24);
//myhist->SetMarkerSize(0.5);
//myhist->Fit("pol1","","same");
c1->SetTickx();
c1->SetTicky();
  c1->Update(); 
}
