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

(File out, File ofile_feedback) LifetimeAdvanced(File inf,  
	string gateWidth, string lifetime_muon_coincidence, string lifetime_muon_gate, 
	string lifetime_muon_singleChannel_require, string lifetime_muon_singleChannel_veto,
	string lifetime_electron_coincidence, string lifetime_electron_gate,
	string lifetime_electron_singleChannel_require, string lifetime_electron_singleChannel_veto,
	string lifetime_minimum_delay, string geoDir, File geoFiles[]) {
	
	app {
		LifetimeAdvanced @filename(inf) @filename(out) @filename(ofile_feedback) gateWidth 
		 lifetime_muon_coincidence lifetime_muon_gate lifetime_muon_singleChannel_require lifetime_muon_singleChannel_veto
		 lifetime_electron_coincidence lifetime_electron_gate lifetime_electron_singleChannel_require lifetime_electron_singleChannel_veto
		 lifetime_minimum_delay @filename(geoDir);
	}
}

(File out) Frequency(File inf, string binType, string binValue, string col) {
	app {
		Frequency @filename(inf) @filename(out) col binType binValue;
	}
}

(File out, File rawFunctionFile) ExtraFunctions(File inf, string alphaG,
	string alphaVar, string constantG, string constantVar, 
	string lifetimeG, string lifetimeVar, string etype,
	string xLowerBound, string xUpperBound, string turnedOn) {
	
	app {
		ExtraFunctions @filename(inf) @filename(out) @filename(rawFunctionFile)
			etype 
			xLowerBound xUpperBound alphaG alphaVar lifetimeG
			lifetimeVar constantG constantVar turnedOn;
	}
}

(File image, File outfile_param) Plot(string ptype, string caption, string plot_semilog, AxisParams x, AxisParams y, 
	AxisParams z, string title, File infile, File extraFun) {
	
	app {
		Plot 
			"-file" @filename(infile)
			"-extra" @filename(extraFun)
			"-param" @filename(outfile_param)
			"-svg" @filename(image)
			"-type" ptype
			"-title" title
			"-xlabel" x.label
			"-ylabel" y.label
			"-zlabel" z.label
			"-caption" caption
			"-plot_semilog" plot_semilog
			"-lowx" x.low
			"-highx" x.high
			"-lowy" y.low
			"-highy" y.high
			"-lowz" z.low
			"-highz" z.high;
	}
}

(File png) SVG2PNG(File svg, string height) {
	app {
		SVG2PNG "-h" height "-w" height @filename(svg) @filename(png);
	}
}


File	rawData[] <fixed_array_mapper;files=@arg("rawData")>;
File thresholdAll[] <fixed_array_mapper;files=@arg("thresholdAll")>;
//This is done to avoid corruption of threshold files when created
//concurrently by multiple runs
//File 	thresholdAll[] <structured_regexp_mapper;source=rawData,match=".*/(.*)",transform="\\1.thresh">;
File	wireDelayData[] <fixed_array_mapper;files=@arg("wireDelayData")>;

string  detectors[] = @strsplit(@arg("detector"), "\\s");
string  cpldfreqs[] = @strsplit(@arg("cpldfreqs"), "\\s");
string  firmwares[] = @strsplit(@arg("firmwares"), "\\s");

string	extraFun_alpha_guess = @arg("extraFun_alpha_guess");
string	extraFun_alpha_variate = @arg("extraFun_alpha_variate");
string	extraFun_constant_guess = @arg("extraFun_constant_guess");
string	extraFun_constant_variate = @arg("extraFun_constant_variate");
string	extraFun_lifetime_guess = @arg("extraFun_lifetime_guess");
string	extraFun_lifetime_variate = @arg("extraFun_lifetime_variate");
string	extraFun_maxX = @arg("extraFun_maxX");
string	extraFun_minX = @arg("extraFun_minX");
string	extraFun_type = @arg("extraFun_type");
string	extraFun_turnedOn = @arg("extraFun_turnedOn");
File	extraFun_out <single_file_mapper;file=@arg("extraFun_out")>;
File	extraFun_rawFile <single_file_mapper;file=@arg("extraFun_rawFile")>;

string	freq_binType = @arg("freq_binType");
string	freq_binValue = @arg("freq_binValue");
string	freq_col = @arg("freq_col");
File	frequencyOut <single_file_mapper;file=@arg("frequencyOut")>;

File	lifetimeOut <single_file_mapper;file=@arg("lifetimeOut")>;
File	feedback <single_file_mapper;file=@arg("feedback")>;
string	lifetime_gatewidth = @arg("lifetime_gatewidth");
string	lifetime_muon_coincidence = @arg("lifetime_muon_coincidence");
string	lifetime_muon_gate = @arg("lifetime_muon_gate");
string	lifetime_muon_singleChannel_require = @arg("lifetime_muon_singleChannel_require");
string	lifetime_muon_singleChannel_veto = @arg("lifetime_muon_singleChannel_veto");
string	lifetime_electron_coincidence = @arg("lifetime_electron_coincidence");
string	lifetime_electron_gate = @arg("lifetime_electron_gate");
string	lifetime_electron_singleChannel_require = @arg("lifetime_electron_singleChannel_require");
string	lifetime_electron_singleChannel_veto = @arg("lifetime_electron_singleChannel_veto");
string	lifetime_minimum_delay = @arg("lifetime_minimum_delay");
File	combineOut <single_file_mapper;file=@arg("combineOut")>;
File	sortOut <single_file_mapper;file=@arg("sortOut")>;

string  geoDir = @arg("geoDir");
File	geoFiles[] <fixed_array_mapper;files=@arg("geoFiles")>;

string	plot_caption = @arg("plot_caption");

string 	plot_semilog = @arg("plot_semilog");

AxisParams x, y, z;

x.high = @arg("plot_highX");
x.low  = @arg("plot_lowX");
x.label = @arg("plot_xlabel");

y.high = @arg("plot_highY");
y.low  = @arg("plot_lowY");
y.label = @arg("plot_ylabel");

z.high = @arg("plot_highZ");
z.low  = @arg("plot_lowZ");
z.label = @arg("plot_zlabel");


File	plot_outfile_param <single_file_mapper;file=@arg("plot_outfile_param")>;

string	plot_plot_type = @arg("plot_plot_type");
string	plot_title = @arg("plot_title");
string	sort_sortKey1 = @arg("sort_sortKey1");
string	sort_sortKey2 = @arg("sort_sortKey2");


wireDelayData = WireDelayMultiple(thresholdAll, geoDir, geoFiles, detectors, firmwares);
combineOut = Combine(wireDelayData);
sortOut = Sort(combineOut, sort_sortKey1, sort_sortKey2);

(lifetimeOut, feedback) = LifetimeAdvanced(sortOut,
	lifetime_gatewidth, lifetime_muon_coincidence, lifetime_muon_gate,
	lifetime_muon_singleChannel_require, lifetime_muon_singleChannel_veto,
	lifetime_electron_coincidence, lifetime_electron_gate,
	lifetime_electron_singleChannel_require, lifetime_electron_singleChannel_veto,
	lifetime_minimum_delay, geoDir, geoFiles);
frequencyOut = Frequency(lifetimeOut, freq_binType, freq_binValue, freq_col);

(extraFun_out, extraFun_rawFile)  = ExtraFunctions(
	frequencyOut,
	extraFun_alpha_guess, extraFun_alpha_variate,
	extraFun_constant_guess, extraFun_constant_variate,
	extraFun_lifetime_guess, extraFun_lifetime_variate,
	extraFun_type,
	extraFun_minX, extraFun_maxX,
	extraFun_turnedOn);
	
File svg <"plot.svg">;
(svg, plot_outfile_param) = Plot(plot_plot_type, plot_caption, plot_semilog, x, y, z, plot_title,
	frequencyOut, extraFun_out);

File png <single_file_mapper;file=@arg("plot_outfile_image")>;

string plot_size = @arg("plot_size");
png = SVG2PNG(svg, plot_size);
File thumb <single_file_mapper;file=@arg("plot_outfile_image_thumbnail")>;
string plot_thumbnail_height = @arg("plot_thumbnail_height");
thumb = SVG2PNG(svg, plot_thumbnail_height);
