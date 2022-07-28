type File {}

type AxisParams {
	string low;
	string high;
	string label;
}

(File wireDelayData) WireDelay(File thresholdData, string geoDir, File geoFile, string detector, string firmware) {
	app {
		WireDelay @filename(thresholdData) @filename(wireDelayData) @filename(geoDir) detector firmware;
	}
}

(File wireDelayData[]) WireDelayMultiple(File thresholdData[], string geoDir, File geoFiles[], string detectors[], string firmwares[]) {
	foreach td, i in thresholdData {
		wireDelayData[i] = WireDelay(thresholdData[i], geoDir, geoFiles[i], detectors[i], firmwares[i]);
	}
}

(File combined) Combine(File data[]) {
	app {
		Combine @filenames(data) @filename(combined);
	}
}

(File out) Sort(File inf, string key1, string key2) {
	app {
		Sort @filename(inf) @filename(out) key1 key2;
	}
}

(File out, File ofile_feedback) ShowerLifetimeHybrid(File inf,  
	string gateWidth, string coincidence) {
	
	app {
		ShowerLifetimeHybrid @filename(inf) @filename(out) @filename(ofile_feedback) gateWidth coincidence;
	}
}



File	rawData[] <fixed_array_mapper;files=@arg("rawData")>;
File	thresholdAll[] <fixed_array_mapper;files=@arg("thresholdAll")>;
File	wireDelayData[] <fixed_array_mapper;files=@arg("wireDelayData")>;

string  detectors[] = @strsplit(@arg("detector"), "\\s");
string  cpldfreqs[] = @strsplit(@arg("cpldfreqs"), "\\s");
string  firmwares[] = @strsplit(@arg("firmwares"), "\\s");

File	hybridOut <single_file_mapper;file=@arg("hybridOut")>;
File	feedback <single_file_mapper;file=@arg("feedback")>;
string	hybrid_gatewidth = @arg("hybrid_gatewidth");
string	channel_coincidence = @arg("channel_coincidence");
File	combineOut <single_file_mapper;file=@arg("combineOut")>;
File	sortOut <single_file_mapper;file=@arg("sortOut")>;

string  geoDir = @arg("geoDir");
File	geoFiles[] <fixed_array_mapper;files=@arg("geoFiles")>;

string	sort_sortKey1 = @arg("sort_sortKey1");
string	sort_sortKey2 = @arg("sort_sortKey2");


wireDelayData = WireDelayMultiple(thresholdAll, geoDir, geoFiles, detectors, firmwares);
combineOut = Combine(wireDelayData);
sortOut = Sort(combineOut, sort_sortKey1, sort_sortKey2);

(hybridOut, feedback) = ShowerLifetimeHybrid(sortOut, hybrid_gatewidth, channel_coincidence);


