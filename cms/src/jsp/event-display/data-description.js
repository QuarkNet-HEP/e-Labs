var POINT = 0;
var LINE = 1;
var SURFACE = 2;
var SHAPE = 3;
var LINES = 4;
var TRACK = 5;
var CURVES = 6;

var WEIGHTS = { 0: 1, 1: 4, 2: 8, 3: 16, 4: 4, 5: 16, 6: 4 };

var d_descr = {
	"Tracks_V1": { type: CURVES, on: true, group: "Tracking", desc: "Tracks (reco.)",
		dataref: "Extras_V1", assoc: "TrackExtras_V1",
		fn: makeTrackCurves2, color: [1, 0.7, 0, 0.9], lineCaps: "square", lineWidth: 2 },
	"GsfTracks_V1": { type: CURVES, on: false, group: "Tracking", desc: "Tracks (GSF)",
		dataref: "GsfExtras_V1", assoc: "GsfTrackExtras_V1", 
		fn: makeTrackCurves2, color: [1, 0.9, 0, 0.9], lineCaps: "square", lineWidth: 1.5 },
	"SiStripDigis_V1": { type: POINT, on: false, group: "Tracking", desc: "Digis (Si Strips)",
		fn: makeSiStripDigis, color: [1, 0.5, 0, 0.6], shape: "+", lineWidth: 0.5 },
	"SiPixelClusters_V1": { type: POINT, on: false, group: "Tracking", desc: "Clusters (Si Pixels)",
		fn: makeSiStripDigis, color: [0.9, 0.6, 0, 1], shape: "x", lineWidth: 1 },
	"SiStripClusters_V1": { type: POINT, on: false, group: "Tracking", desc: "Clusters (Si Strips)",
		fn: makeSiStripDigis, color: [1, 0.6, 0, 1], shape: "x", lineWidth: 1 },
	"SiPixelRecHits_V1": { type: POINT, on: false, group: "Tracking", desc: "Rec. Hits (Si Pixels)", 
		fn: makeSiStripDigis, color: [1, 0, 0, 1], shape: "square", lineWidth: 0.5 },
	"TrackingRecHits_V1": { type: POINT, on: false, group: "Tracking", desc: "Rec. Hits (Tracking)", 
		fn: makeHit, color: [1, 1, 0, 1], fill: [1, 1, 0, 1], shape: "disc", lineWidth: 1 },
		
	"DTDigis_V1": { type: LINE, on: false, group: "Muon", desc: "DT Digis",
		fn: makeDTDigis, color: [0, 1, 0, 1], lineWidth: 1 },
	"DTRecHits_V1": { type: LINE, on: false, group: "Muon", desc: "DT Rec. Hits",
		fn: makeDTRecHits, color: [0, 1, 0, 1], lineWidth: 2 },
	"DTRecSegment4D_V1": { type: LINE, on: false, group: "Muon", desc: "DT Rec. Segments (4D)",
		fn: makeDTRecSegments, color: [1, 1, 0, 1], lineWidth: 3 },
	"CSCWireDigis_V1": { type: LINE, on: false, group: "Muon", desc: "CSC Wire Digis",
		fn: makeCSCWD, color: [0.8, 0, 0.8, 1], lineWidth: 0.5 },
	"CSCStripDigis_V1": { type: LINE, on: false, group: "Muon", desc: "CSC Strip Digis",
		fn: makeCSCSD, color: [0.8, 0, 0.8, 1], lineWidth: 0.5 },
	"RPCRecHits_V1": { type: LINES, on: false, group: "Muon", desc: "RPC Rec. Hits",
		fn: makeRPCRecHits, color: [0.8, 1, 0, 1], lineWidth: 3 },
		
	"EBRecHits_V1": { type: SHAPE, on: false, group: "ECAL", desc: "Barrel Rec. Hits", rank: "energy",
		fn: makeSimpleRecHits, color: [1, 0.2, 0, 1], fill: [1, 0.2, 0.2, 1], lineWidth: 1 },
	"EERecHits_V1": { type: SHAPE, on: false, group: "ECAL", desc: "Endcap Rec. Hits", rank: "energy",
		fn: makeSimpleRecHits, color: [1, 0.2, 0, 1], fill: [1, 0.2, 0.2, 1], lineWidth: 1 },
	"ESRecHits_V1": { type: SHAPE, on: false, group: "ECAL", desc: "Preshower Rec. Hits", rank: "energy",
		fn: makeSimpleRecHits, color: [1, 0.2, 0, 1], fill: [1, 0.2, 0.2, 1], lineWidth: 1 },
		
	"HBRecHits_V1": { type: SHAPE, on: false, group: "HCAL", desc: "Barrel Rec. Hits", rank: "energy",
		fn: makeRecHits, color: [0.2, 0.7, 1, 1], fill: [0.2, 0.7, 1, 1], lineWidth: 0.5 },
	"HERecHits_V1": { type: SHAPE, on: false, group: "HCAL", desc: "Endcap Rec. Hits", rank: "energy",
		fn: makeRecHits, color: [0.2, 0.7, 1, 0.4], fill: [0.2, 0.7, 1, 0.2], lineWidth: 0.5 },
	"HFRecHits_V1": { type: SHAPE, on: false, group: "HCAL", desc: "Forward Rec. Hits", rank: "energy",
		fn: makeRecHits, color: [0.2, 0.7, 1, 0.4], fill: [0.2, 0.7, 1, 0.2], lineWidth: 0.5 },
	"HORecHits_V1": { type: SHAPE, on: false, group: "HCAL", desc: "Outer Rec. Hits", rank: "energy",
		fn: makeRecHits, color: [0.2, 0.7, 1, 0.4], fill: [0.2, 0.7, 1, 0.2], lineWidth: 0.5 },
		
	"GsfPFRecTracks_V1": { type: TRACK, on: false, group: "Particle Flow", desc: "GSF Tracks",
		dataref: "PFTrajectoryPoints_V1", assoc: "GsfPFRecTrackTrajectoryPoints_V1", 
		fn: makeTrackPoints, color: [0, 1, 1, 1], lineCaps: "+", lineWidth: 1},
	"PFEBRecHits_V1": { type: SHAPE, on: false, group: "Particle Flow", desc: "ECAL Barrel Rec. Hits", rank: "energy",
		fn: makeRecHits, color: [1, 0, 1, 1], fill: [1, 0, 1, 1], lineWidth: 0.5},
	"PFEERecHits_V1": { type: SHAPE, on: false, group: "Particle Flow", desc: "ECAL Endcap Rec. Hits", rank: "energy",
		fn: makeRecHits, color: [1, 0, 1, 1], fill: [1, 0, 1, 1], lineWidth: 0.5},
	"PFBrems_V1": { type: TRACK, on: false, group: "Particle Flow", desc: "Bremsstrahlung candidate tangents",
		dataref: "PFTrajectoryPoints_V1", assoc: "PFBremTrajectoryPoints_V1", 
		fn: makeTrackPoints, color: [0, 1, 0.2, 1], lineCaps: "+", lineWidth: 1},
		
	"TrackerMuons_V1": { type: TRACK, on: false, group: "Physics Objects", desc: "Tracker Muons (Reco)",
		dataref: "Points_V1", assoc: "MuonTrackerPoints_V1", 
		fn: makeTrackPoints, color: [1, 0, 0.2, 1], lineCaps: "+", lineWidth: 1},
	"StandaloneMuons_V1": { type: TRACK, on: false, group: "Physics Objects", desc: "Stand-alone Muons (Reco)",
		dataref: "Points_V1", assoc: "MuonStandalonePoints_V1", 
		fn: makeTrackPoints, color: [1, 0, 0.2, 1], lineCaps: "+", lineWidth: 1},
	"GlobalMuons_V1": { type: TRACK, on: false, group: "Physics Objects", desc: "Global Muons (Reco)",
		dataref: "Points_V1", assoc: "MuonGlobalPoints_V1", 
		fn: makeTrackPoints, color: [1, 0, 0.2, 1], lineCaps: "+", lineWidth: 1},
	"CaloTowers_V1": { type: SHAPE, on: false, group: "Physics Objects", desc: "Calorimeter Energy Towers", rank: "energy",
		fn: makeCaloTowers, color: [0, 1, 0, 1], fill: [0, 1, 0, 1], lineWidth: 0.5 },
	"Jets_V1": { type: SHAPE, on: false, group: "Physics Objects", desc: "Jets", rank: "energy",
		fn: makeJet, color: [1, 1, 0, 1], fill: [1, 1, 0, 0.5] },
};

var d_groups = ["Tracking", "ECAL", "HCAL", "Muon", "Particle Flow", "Physics Objects"];