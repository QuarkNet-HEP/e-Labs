var csv_files = [
  {
    id:"Jpismumu",
    name: "J/&psi;&rarr;&mu;&mu;",
    descr:"dimuon events with invariant mass between 2-5 GeV",
    file:"data/dimuon-Jpsi.csv",
    type:"two_lepton"
  },
  {
    id:"Jpsiee",
    name: "J/&psi;&rarr;ee",
    descr:"dielectron events with invariant mass between 2-5 GeV",
    file:"data/dielectron-Jpsi.csv",
    type:"two_lepton"
  },
  {
    id:"Yee",
    name: "Y&rarr;ee",
    descr:"dielectron events with invariant mass between 8-12 GeV",
    file:"data/dielectron-Upsilon.csv",
    type:"two_lepton"
  },
  {
    id:"Zee",
    name: "Z&rarr;ee;",
    descr:"dielectron events around the Z boson mass",
    file:"data/Zee.csv",
    type:"two_lepton"
  },
  {
    id:"Zmumu",
    name: "Z&rarr;&mu;&mu;",
    descr:"dimuon events around the Z boson mass",
    file:"data/Zmumu.csv",
    type:"two_lepton"
  },
  {
    id:"Wenu",
    name: "W&rarr;e;&nu;",
    descr:"W bosons decaying to an electron and a neutrino",
    file:"data/Wenu.csv",
    type:"lepton_neutrino"
  },
  {
    id:"Wmuu",
    name: "W&rarr;&mu;&nu;",
    descr:"W bosons decaying to a muon and a neutrino",
    file:"dtaa/Wmunu.csv",
    type:"lepton_neutrino"
  },
  {
    id:"dimuon",
    name: "Dimuons",
    descr:"dimuon events with invariant mass between 2-110 GeV",
    file:"data/MuRun2010B_0.csv",
    type:"two_lepton"
  },
];


// We know the names of the parameters that we have produced in the csv files.
// We also have only two event types in the csv: lepton_neutrino and two_lepton.
// We therefore provide some information on the parameters.
var event_types = {
    "two_lepton":
    [
      {name:"E1", unit:"GeV", description:"The total energy of the first lepton (electron or muon)"},
      {name:"pt1", unit:"GeV", description:"The transverse momentum of the first lepton (electron or muon)"},
      {name:"eta1", unit:null, description:"The pseudorapidity of the first lepton (electron or muon)"},
      {name:"phi1", unit:"radians", description:"The phi angle of the first lepton (electron or muon) direction"},
      {name:"Q1", unit:null, description:"The charge of the first lepton (electron or muon)"},
      {name:"E2", unit:"GeV", description:"The total energy of the second lepton (electron or muon)"},
      {name:"pt2", unit:"GeV", description:"The transverse momentum of the second lepton (electron or muon)"},
      {name:"eta2", unit:null, description:"The pseudorapidity of the second lepton (electron or muon)"},
      {name:"phi2", unit:"radians", description:"The phi angle of the second lepton (electron or muon)"},
      {name:"Q2", unit:null, description:"The charge of the second lepton (electron or muon)"},
      {name:"M", unit:"GeV", description:"The invariant mass of the two leptons (electrons or muons)"}
     ],
     "lepton_neutrino":
     [
      {name:"E", unit:"GeV", description:"The total energy of the lepton (electron or muon)"},
      {name:"MET", unit:"GeV", description:"The missing transverse energy due to the neutrino"},
      {name:"Q", unit:null, description:"The charge of the lepton (electron or muon)"},
      {name:"phiMET", unit:"radians", description:"The phi angle of the missing transverse energy"},
      {name:"eta", unit:null, description:"The pseudorapidity of the lepton (electron or muon)"},
      {name:"phi", unit:"radians", description:"The phi angle of the lepton (electron or muon) direction"},
      {name:"pt", unit:"GeV", description:"The transverse momentum of the lepton (electron or muon)"}
     ]
};

// Some fields aren't numbers, or it doesn't make sense to plot them, or they are redundant.
// Therefore exclude them.
var excluded = ["Run","Event","Type","Type1","Type2","px1","py1","pz1","px2","py2","pz2","px","py","pz"];

function is_excluded(key) {
  if ( excluded.indexOf(key) === -1 ) {
    return false;
  }
  return true;
}

function get_parameter_info(name, type) {
  for ( var i = 0; i < type.length; i++ ) {
    if ( name === type[i].name ) {
      if ( type[i].unit !== null ) {
        return type[i].description + ' ['+ type[i].unit +']';
      } else {
        return type[i].description;
      }
    }
  }
}
