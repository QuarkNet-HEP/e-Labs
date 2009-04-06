/***********************************************************************\
 * Detector Channel objects & utilities 
 *
 * Channels are described by a ChannelInfo object, which has methods
 * for getting the units, applying calibration, etc.
 *
 * Some channel names have changed over time, so we have the general
 * (and current) channel name 
 *
 * @(#) $Id: channels.C,v 1.9 2008/10/29 21:17:48 myers Exp $
\***********************************************************************/

#include "channels.h"		// ChannelInfo object

// Constructor: by channel name
//
void
ChannelInfo::ChannelInfo(TString ChName){
  cid = 0;
  name=ChName;
  realname=ChName;
  ttype="M";
  tcomp="mean";
  units="";
  calib_slope=1.0;
  calib_bias=0.0;
  is_calibrated=0;  // FALSE
}

// Constructor: by channel name and "real" name
//
void
ChannelInfo::ChannelInfo(TString ChName, TString RealName){
  cid = 0;
  name=ChName;
  realname=RealName;
  ttype="M";
  tcomp="mean";
  units="";
  calib_slope=1.0;
  calib_bias=0.0;
  is_calibrated=0;  // FALSE
}



// Fix channel naming exceptions
//
TString
ChannelInfo::RealChannelName(Int_t GPS_time){
  TString ChName = name;
  return getRealChannelName(ChName,  GPS_time);
}


// Set calibration constants for a channel.
// (Does not apply the calibration, just sets the constants)
//
void
ChannelInfo::set_calibration(){
  TString ChName = name;

  is_calibrated = 0;  // since we may be changin something
  calib_bias=0.0;

  // PEM SEISMIC (non DMT)
  if( ChName.Contains("_SEIS")  ) {
    calib_slope=-0.0076;
    return;
  }

  // PEM MAGNETIC
  if( ChName.Contains("_MAG")  ) {
    calib_slope=6.10;
    return;
  }

  // PEM TILT meters
  if( ChName.Contains("_TILT")  ) {
    calib_slope=0.0061;
    return;
  }
}


// Set units (ONLY)
//
void
ChannelInfo::set_units(){
  TString ChName = name;

  if( !is_calibrated ){
    calib_bias=0.0;
    calib_slope=1.0;
  }
  units = getChannelUnits(ChName, is_calibrated);
  return;
}


// Get the units for a channel, given the name 
// and whether or not it is calibrated
// TODO! These are only correct for mean/max/min
//       Must also handle rms and N trend types 
//

TString
ttype_units(TString ChName, TString units){
  //TODO: look at ChName, and
  //	* if it ends in .rms then     "square" the units.
  //    * if it ends in .N then clear the units  i 
  return units;
}





TString
getChannelUnits(TString ChName, bool is_calibrated){
  TString units;

  // DMT SEISMIC
  if( ChName.Contains("DMT-BRMS") ){
    if( is_calibrated ) units="microns/s";
    else                units="(microns/s)^2";
    return ttype_units(ChName, units);
  }

  // GDS Earthquake
  if( ChName.Contains("GDS-EARTHQUAKE")  ) {
    units="1/0";
    return ttype_units(ChName, units);
  }

  // It's all PEM beyond this, mmKay?
  //
  if( !ChName.Contains("PEM-") ){
    cerr << "ChanelInfo::set_units() unknown  channel " << ChName << endl;
    return "unknown";
  }


  // PEM RAIN
  if( ChName.Contains("_RAIN")  ) {
    units = "mm";
    return ttype_units(ChName, units);
  }

  // PEM WIND in MPH (check for this second!)
  if( ChName.Contains("_WINDMPH")  ) {
    units = "mph";
    return ttype_units(ChName, units);
  }

  // PEM WIND 
  if( ChName.Contains("_WIND")  ) {
    units = "m/s";
    return ttype_units(ChName, units);
  }

  // ADC channels beyond this
  if( !is_calibrated ) return "ADC counts (raw)";

  // PEM SEISMIC (non DMT)
  if( ChName.Contains("_SEIS")  ) {
    units = "microns/s";
  }

  // PEM MAGNETIC
  if( ChName.Contains("_MAG")  ) {
    units = "pT";
  }

  // PEM TILT meters
  if( ChName.Contains("_TILT")  ) {
    units = "microRadians";
  }
  return ttype_units(ChName, units);
}





// Apply calibration (AND set units)
//
void
ChannelInfo::apply_calibration(const TSeries* ts){
  int i;
  double x;

  TString ChName = name;

  int nbin = ts->getNSample();          // number of samples
  double* p = ts->refData();            // ptr to start


  // DMT SEISMIC channels are RMS squares, so take square root
  //
  if( ChName.Contains("DMT-BRMS") ||
      ChName.Contains("SEIS") && ChName.Contains("Hz") ){
    for(i=0; i<nbin; ++i){
      //TODO: what if *p is a negative value?  It should not be, but
      // there are in fact negative values in the RDS.
      *p = ((*p<0.0)? -1 : 1 ) * pow(fabs(*p),0.5);
      p++;
    }
    units="microns/s";
    is_calibrated=1;
    cerr << "Applied calibration to " << name
         << " with units set to " << units << endl;
    return;
  }

  // :PEM SEISMIC .rms components need both calibration factor 
  // (not negative) and to take the square root to get units righ
  //
  if( ChName.Contains(":PEM") || ChName.Contains("SEIS")
      && ChName.EndsWith("rms") ){
    for(i=0; i<nbin; ++i){
      *p = calib_bias + fabs(calib_slope)* (*p);
      *p = pow(fabs(*p),0.5);
      p++;
    }
    units="microns/s";
    is_calibrated=1;
    cerr << "Applied calibration to " << name
         << " with units set to " << units << endl;
    return;
  }



  // Other channels just need rescaling
  //
  if( calib_bias != 0.0 || calib_slope != 1.0 ){
    for(i=0; i<nbin; ++i){
      *p = calib_bias + calib_slope* (*p);
      p++;
    }
    is_calibrated=1;
    this->set_units();  // reset units
    cerr << "Applied calibration to " << name
         << " with units set to " << units << endl;
    return;
  }

  cerr << "No calibration actually applied. " << endl;
}

//


/***********************************************************************\
 * Non object functions: Channel names and filepaths
 */

/**
 * Channel name alteration.
 * DMT BLRMS channel names changed on Oct 8 2005.  The leading "PEM-" was
 * replaced with "DMT-BRMS_PEM_", (except that for one frame the "PEM_"
 * was "PEM-" (ouch)), and the bandwidth range separator changed from 
 * a hyphen ("-") to an underscore ("_").
 * So we extract the channel name as a char ptr and account for this.
 */

TString getRealChannelName(TString Channel, Int_t GPS_time){
  int i;

  if( GPS_time >= 812840400 ) return Channel;
  if( !Channel.Contains("DMT-BRMS_PEM_")) return Channel;
 
  TString altChannel = Channel;  

  if( GPS_time == 812836800 ) {  // small change for one frame
    altChannel.Replace(12,4,"PEM-",4);
    cerr << "Special case! Change 'PEM_' to 'PEM-' " << endl;
    return altChannel;
  }
  else {
    // Change "DMT-BRMS_PEM_" to just "PEM-"
    altChannel.Replace(3,13, "PEM-",4);
  }

  // and change final underbar between freq to hyphen

  if( !Channel.Contains("Hz")) return Channel;

  i = altChannel.Last('_');
  if( i!=0 )  altChannel.Replace(i,1, "-",1);

  cerr << "Altered channel name to " << altChannel << endl;
  return altChannel;
}



/**
 * Construct frame filepath:
 * Given the GPS_time, trend type and source device, construct a file path 
 * to a frame file, (relative to DATA_DIR).
 */

TString frame_filepath(Int_t GPS_time,  TString ttype="M",
                       TString site="H"){

  Int_t   frame_length = 3600;
  Int_t   GPS_block = 1e6;
  TString samp_path = "/trend/minute-trend/";
  TString filepath = "";

  if( ttype == "M" ) {
    frame_length = 3600;
    samp_path = "/trend/minute-trend/";
  }

  if( ttype == "T" ) {
    frame_length = 60;
    samp_path = "/trend/second-trend/";
  }

  if( ttype == "R" ) { // what if it's not S5?  Deal with it then.
    frame_length = 32;
    samp_path = "/S5/L0/";
    GPS_block = 1e5;
  }

  Int_t GPS_prefix = GPS_time/GPS_block;
  Int_t GPS_stamp = frame_length * (int) (GPS_time/frame_length);


  filepath = samp_path+"L"+site+"O";
  filepath += "/H-"+ttype+"-";
  filepath +=  GPS_prefix;
  filepath +=  "/H-"+ttype+"-";
  filepath += GPS_stamp;
  filepath += "-";
  filepath += frame_length;
  filepath += ".gwf";
  return filepath;
}

//EOF//
