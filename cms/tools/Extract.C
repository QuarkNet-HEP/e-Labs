Extract(char *file, char *leaf) {
	TFile *f = new TFile(file);
	Events->SetScanField(0);
	Events->Scan(leaf, "", "colsize=16 precision=4");
	gApplication->Terminate(0);
}