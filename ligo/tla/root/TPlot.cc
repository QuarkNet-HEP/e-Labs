/***********************************************************************\
 * TPlot.cc - plot a TSeries
 * 
 * Plots a time series, identified either by channel name or pointer to TSeries .
 * The optional second argument provides plotting options for Draw(),
 *
 * @(#) $Id: TPlot.cc,v 1.1 2007/05/14 22:20:49 myers Exp $
\***********************************************************************/

//--
// TPlot( ) by channel name

void TPlot(const char *name, const char *opts=0) {
    TSeries* ts = In.refData(name);
    if (!ts) {
        printf("TPlot: Could not find Time series for channel %s.\n", name);
        return;
    }
    TPlot(ts, opts);
}

//--
// TPlot( ) by ptr to a TSeries

void TPlot(const TSeries* ts, const char* opts=0) {
    //----------------------------------  Formatting parameters
    float ymargin = 0.1;  // Fractional margin in y.

    if (!ts) {
      fprintf(stderr, "TPlot(): Invalid TSeries pointer.");
      return;
    }

    //----------------------------------  Get the TSeries parameters.
    int nbin = ts->getNSample();
    float step = ts->getTStep().GetSecs();
    double stime = ts->getStartTime().totalS();

    int ROOT_GPS_seconds = 472953600;  // 1 Jan 1995 in GPS seconds
    // if start time is greater than this, assume GPS times, otherwise not
    if (stime < ROOT_GPS_seconds  )  stime = 0;    // (why bother?)

    //----------------------------------  Get the data and real length.
    float* DVec = new float[nbin];
    int nwd = ts->getData(nbin,DVec);
    float dtime = stime + step * nwd;

    //----------------------------------  Create and fill the histogram.
    TH1F* TS001  = (TH1F*) gROOT->FindObject("TS001");
    if (TS001) delete TS001;   // start fresh
    TS001 = new TH1F("TS001", ts->getName(), nwd, stime, dtime);
    float ymin = DVec[0];
    float ymax = DVec[0];
    for (int i=0 ; i<nwd ; i++) {

        //-----------------------------  Histogram content in bins 1-N. Bin 0
        //                               has UnderFlow, bin N+1 has OverFlow
        TS001->SetBinContent(i+1, DVec[i]);
        if (DVec[i] < ymin) ymin = DVec[i];
        if (DVec[i] > ymax) ymax = DVec[i];
    }
    delete[] DVec;

    float yavg = 0.5 * (ymin + ymax);
    float ydif = yavg - ymin;
    ymin = yavg - (1.0 + ymargin)*ydif;
    ymax = yavg + (1.0 + ymargin)*ydif;
    if (ymin < 0.0 && yavg-ydif >= 0.0) ymin = 0.0;
    // if we are "near" zero at the bottom then make that the lower limit
    if (ymin > 0.0 && ymin-ydif <= 0.0) ymin = 0.0;  
    TS001->SetMinimum(ymin);
    TS001->SetMaximum(ymax);

    //----------------------------------  Set the plotting options
    gStyle->SetOptStat(0);

    if( gROOT->GetSelectedPad() ) {
      (gROOT->GetSelectedPad()->GetCanvas())->cd();
    }
    else  {
      new TCanvas("cGDS", "GDS Canvas");  
    }

    TPad* padT = (TPad*) gROOT->FindObject("padT");
    if (padT) delete padT;      // start fresh
    padT = new TPad("padT", "Time Series", 0.00, 0.00, 1.00, 1.00);
    padT->Draw();
    padT->cd();
    padT->SetBottomMargin(0.12);
    padT->SetLeftMargin(0.16);
    padT->SetTicks(1,1);

    // Default settings can be changed after plot by modifying TS001

    TS001->GetYaxis()->SetTitle("ADC Signal (adc units)");
    TS001->GetYaxis()->CenterTitle(true);
    TS001->GetYaxis()->SetTitleOffset(1.2);

    TS001->GetXaxis()->CenterTitle(true);
    TS001->GetXaxis()->SetNdivisions(612);
    TS001->GetXaxis()->SetNoExponent(kTRUE);
    TS001->GetXaxis()->SetLabelOffset(0.025);
    TS001->GetXaxis()->SetLabelSize(0.025);
    TS001->GetXaxis()->SetTickLength(-0.025);
    TS001->GetXaxis()->SetTitleOffset(1.25);
    TS001->Draw(opts);

    /* Default X axis is to just show seconds/GPS seconds, 
       but uncomment this next line to turn on HH:MM style */
    // TS001->GetXaxis()->SetTimeDisplay(1);
    TS001->GetXaxis()->SetTimeOffset(ROOT_GPS_seconds, "gmt" ); 
    TS001->GetXaxis()->SetTimeFormat("#splitline{%I:%M %p}{%d %b %Y}");

    if (stime > ROOT_GPS_seconds  )  {
       TS001->GetXaxis()->SetTitle("GPS Time");
       TS001->GetXaxis()->SetNdivisions(510);
    }
    else {
       TS001->GetXaxis()->SetTitle("Time (seconds)");
    }

    padT->GetCanvas()->Update();
}

//EOF
