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
		channel.put("1", "0");
		channel.put("2", "1");
		channel.put("3", "0 and 1");
		channel.put("4","2");
		channel.put("5","0 and 2");
		channel.put("6","1 and 2");
		channel.put("7","0, 1 and 2");
		channel.put("8","3");
		channel.put("9","0 and 3");
		channel.put("A","1 and 3");
		channel.put("B","0, 1 and 3");
		channel.put("C","2 and 3");
		channel.put("D","0, 2 and 3");
		channel.put("E","1, 2 and 3");
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