/***********************************************************************\
 * ROOT utilities common to all Virtual Instruments
 *
 *
 * Eric Myers <Eric.Myers@ligo.org> - 21 August 2008
 * @(#) $Id: util.C,v 1.1 2008/08/22 21:41:03 myers Exp $
\***********************************************************************/

/****
 * Output canvas as JPEG, EPS, etc...
 */

void save_plots(TString plot_id){

  TCanvas* cGDS = gPad->GetCanvas();    // get the current canvas
  cGDS->Modified();			// make sure it's updated
  cGDS->Update();

  if( gROOT->IsBatch() ) {

    Int_t Nplot=1;

    plot_id =  plot_id + "_" + "1";  
    cerr << "New plot_id is " << plot_id << endl;

    TString fname;
    fname = plot_id + ".C";  
    cGDS->SaveAs(fname);

    fname = plot_id + ".jpg";  
    cGDS->SaveAs(fname);

    fname = plot_id + ".eps";  
    cGDS->SaveAs(fname);

    fname = plot_id + ".svg";  
    cGDS->SaveAs(fname);
    
    fname = plot_id + ".png";
    cGDS->SaveAs(fname);
  }
}

