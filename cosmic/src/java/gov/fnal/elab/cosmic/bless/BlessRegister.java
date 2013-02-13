/*
 * Class used to format control register labels
 * EPeronja - 02/13/2013 - 472- decided to set the channels starting at 1 rather than 0
 * 								to match the plot chart 
 */

package gov.fnal.elab.cosmic.bless;

import java.util.NavigableMap;
import java.util.TreeMap;

import org.globus.cog.karajan.workflow.nodes.functions.Map;

import EDU.oswego.cs.dl.util.concurrent.misc.Fraction;

public class BlessRegister {

	private String register;
	private String value;
	private NavigableMap<String, String> trigger;
	private NavigableMap<String, String> channel;
	
	public BlessRegister(String register) {
		if (register != null) {
			this.register = register;
		} else {
			this.register = "Unknown";
		}
		trigger = new TreeMap<String, String>();
		trigger.put("0","Singles");
		trigger.put("1","Two-fold");
		trigger.put("2","3-fold");
		trigger.put("3","4-fold");
		channel = new TreeMap<String, String>();
		channel.put("1", "1");
		channel.put("2", "2");
		channel.put("3", "1 and 2");
		channel.put("4","3");
		channel.put("5","1 and 3");
		channel.put("6","2 and 4");
		channel.put("7","1, 2 and 3");
		channel.put("8","4");
		channel.put("9","1 and 4");
		channel.put("A","2 and 4");
		channel.put("B","1, 2 and 4");
		channel.put("C","3 and 4");
		channel.put("D","1, 3 and 4");
		channel.put("E","2, 3 and 4");
		channel.put("F","All");
	}//end of constructor
	
	public String getRegisterValue() {
		String tr = getValue(0, trigger);
		String ch = getValue(1, channel);
		if (tr.equals("Unknown") && ch.equals("Unknown")) {
			value = register;
		} else {
		value = "Trigger: " + tr + " - Channel(s):" + ch;
		}
		return value;
	}
	
	private String getValue(int charposition, NavigableMap<String, String> map) {
		String value = "";
		if (register.equals("Unknown")) {
			value = register;
		} else {
			String tr = String.valueOf(register.charAt(charposition));
			for (NavigableMap.Entry<String, String> entry: map.entrySet())
			{
				String key = entry.getKey();
				if (key.equals(tr)) {
					value = (String) entry.getValue();
				}
			}
		}
		
		return value;
	}	
}