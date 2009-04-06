/***********************************************************************\
 * ChannelInfo class
 *
 * @(#) $Id: channels.h,v 1.4 2008/10/17 15:31:22 myers Exp $
\***********************************************************************/

#ifndef _CHANNELS_H_
#define _CHANNELS_H_

class ChannelInfo : public TObject { // Information about a data channel
 public:
  unsigned int cid;	// channel id#
  TString name;		// channel name	
  TString realname;	// the _real_ name, what's in the frame files
  TString ttype;        // trend type (T=second, M=Minute, R=Raw, etc...)
  TString tcomp;        // trend component (mean,min,max,rms,N)
  TString rate;         // sampling rate, or trending rate, as appropriate
  TString  units;       // units of measurement 
  double calib_slope;   // calibration slope (linear scale factor)
  double calib_bias;    // calibration bias (DC offset = value when ADC=0) 
  bool   is_calibrated; // have we applied the calibration?

  void ChannelInfo(TString ChName);
  void set_units();
  void apply_calibration(const TSeries* ts);

  TString get_units(){return units;}

};


#endif

//EOF//
