package gov.fnal.elab.util;

public class ElabMemory {
	int megabytes = 1024*1024;
	double totalMemory = 0;
	double freeMemory = 0;
	double usedMemory = 0;
	double maxMemory = 0;
	
	Runtime runtime = null;
	
	public ElabMemory() {
		runtime = Runtime.getRuntime();
	}//end of constructor

	public void refresh() {
		totalMemory = runtime.totalMemory() / megabytes;
		maxMemory = runtime.maxMemory() / megabytes;
		usedMemory = (runtime.totalMemory() - runtime.freeMemory()) / megabytes;
		freeMemory = runtime.freeMemory() / megabytes;		
	}
	public double getTotalMemory() {
		return totalMemory;
	}
	public double getFreeMemory() {
		return freeMemory;
	}
	public double getUsedMemory() {
		return usedMemory;
	}
	public double getMaxMemory() {
		return maxMemory;
	}
	public boolean isCritical() {
		boolean isCritical = false;
		double remains = freeMemory / totalMemory;
		if (remains < 0.01) {
			isCritical = true;
		}
		return isCritical;
	}
	
}// end of ElabMemory