package gov.fnal.elab.cosmic.bless;

public enum BlessState {
	BLESSED,			// File is blessed 
	AWAITING_BLESSING,	// File is awaiting user or machine blessing
	CURSED, 			// File does not meet blessing requirements
	AWAITING_REVIEW,	// File needs to be reviewed by experts
	CANNOT_BLESS,		// File cannot be blessed
	UNKNOWN; 			// File state is unknown
	
	
	
}
