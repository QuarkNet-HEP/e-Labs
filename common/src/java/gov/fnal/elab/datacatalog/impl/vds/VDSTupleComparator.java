package gov.fnal.elab.datacatalog.impl.vds;

import java.util.Comparator;
import org.griphyn.vdl.annotation.Tuple;

public class VDSTupleComparator implements Comparator<Tuple> {

	@Override
	public int compare(Tuple o1, Tuple o2) {
		// TODO Auto-generated method stub
		return o1.getKey().compareTo(o2.getKey());
	}

}
