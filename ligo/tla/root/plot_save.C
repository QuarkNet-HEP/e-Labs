/***********************************************************************\ 
 * Save a plot.   Find the current canvas and save it.
 * Filename is constructed from the plot_id  and Nplot.
 *
 * Eric Myers <myers@spy-hill.net>  - 24 May 2006
 * @(#) $Id: plot_save.C,v 1.3 2008/10/07 20:55:09 myers Exp $
\***********************************************************************/

plot_save(TString plot_id,  int Nplot){


  TCanvas* cGDS = (TCanvas*) gROOT->FindObject("cGDS");
  if( !cGDS ) cGDS = (TCanvas*) gROOT->FindObject("cGDS");
  if( !cGDS && gROOT->GetSelectedPad() ) { // or gPAD?
    cGDS = gROOT->GetSelectedPad()->GetCanvas();
  }


  if (!cGDS) {
    cerr << "Cannot find an active canvas." << endl;
    exit -3;
  }


  // Find and redraw the pad
  //
  TPad *padT = (TPad*) gROOT->FindObject("padT");
  if (!padT) {
    cerr << "Cannot find an existing pad to draw." << endl;
    exit -4;
  }
  padT->Draw();

  cGDS->Modified();
  cGDS->Update();

  plot_id =  plot_id + "_" + Nplot;
  cout << "plot_save(): new plot_id is " << plot_id << endl;

  TString fname;
  fname = plot_id + ".C";  
  cGDS->SaveAs(fname);
  //cGDS->SaveAs("next3.C");

  fname = plot_id + ".jpg";  
  cGDS->SaveAs(fname);

  //fname = plot_id + ".eps";  
  //cGDS->SaveAs(fname);

  fname = plot_id + ".svg";  
  cGDS->SaveAs(fname);
  
  fname = plot_id + ".png";
  cGDS->SaveAs(fname);
}

//EOF
