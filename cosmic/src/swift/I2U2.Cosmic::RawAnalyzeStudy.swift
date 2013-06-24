type File {}

app (File out) RawAnalyze(File inf, string gatewidth) {
	RawAnalyze @filename(inf) @filename(out) gatewidth;
}

//string gatewidth = @arg("gatewidth");
string gatewidth[] = @strsplit(@arg("gatewidth"), "\\s");
File inFile[] <fixed_array_mapper;files=@arg("inFile")>;
File outFile[] <fixed_array_mapper;files=@arg("outFile")>;

foreach v, i in inFile, j in gatewidth {
	outFile[i] = RawAnalyze(inFile[i], gatewidth[j]);
}
