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

(File out) EventSearch(File inf, string gate, string detectorCoincidence, string channelCoincidence,
	string eventCoincidence) {
	
	app {
		EventSearch @filename(inf) @filename(out) gate detectorCoincidence
			channelCoincidence eventCoincidence;
	}
}

(File out) EventChoice(File inf, string eventNum, string zeroZeroZeroID, string geoDir, File geoFiles[]) {
	app {
		EventChoice @filename(inf) @filename(out) eventNum zeroZeroZeroID @filename(geoDir);
	}
}

string channelCoincidence = @arg("channelCoincidence");
string detectorCoincidence = @arg("detectorCoincidence");
string eventCoincidence = @arg("eventCoincidence");
string eventNum = @arg("eventNum");
string gate = @arg("gate");
string zeroZeroZeroID = @arg("zeroZeroZeroID");

File eventCandidates <single_file_mapper;file=@arg("eventCandidates")>;
File eventFile <single_file_mapper;file=@arg("eventFile")>;

File rawData[] <fixed_array_mapper;files=@arg("rawData")>;
File thresholdAll[] <fixed_array_mapper;files=@arg("thresholdAll")>;
File wireDelayData[] <fixed_array_mapper;files=@arg("wireDelayData")>;

string  detectors[] = @strsplit(@arg("detector"), "\\s");
string  cpldfreqs[] = @strsplit(@arg("cpldfreqs"), "\\s");
string  firmwares[] = @strsplit(@arg("firmwares"), "\\s");
string 	singleChannel_require = @arg("singleChannel_require");
string 	singleChannel_veto = @arg("singleChannel_veto");

File combineOut <single_file_mapper;file=@arg("combineOut")>;
File sortOut <single_file_mapper;file=@arg("sortOut")>;

string geoDir = @arg("geoDir");
File geoFiles[] <fixed_array_mapper;files=@arg("geoFiles")>;
string plot_title = @arg("plot_title");
string sort_sortKey1 = @arg("sort_sortKey1");
string sort_sortKey2 = @arg("sort_sortKey2");

//the actual workflow
wireDelayData = WireDelayMultiple(thresholdAll, geoDir, geoFiles, detectors, firmwares);
combineOut = Combine(wireDelayData);
sortOut = Sort(combineOut, sort_sortKey1, sort_sortKey2);
eventCandidates = EventSearch(sortOut, gate, detectorCoincidence, channelCoincidence,
	eventCoincidence);
