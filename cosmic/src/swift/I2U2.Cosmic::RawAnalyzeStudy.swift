type File {}

app (File out) RawAnalyze(File inf, string gatewidth) {
	RawAnalyze @filename(inf) @filename(out) gatewidth;
}

string gatewidth = @arg("gatewidth");
File inFile <single_file_mapper;file=@arg("inFile")>;
File outFile <single_file_mapper;file=@arg("outFile")>;

outFile = RawAnalyze(inFile, gatewidth);