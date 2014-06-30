/*
 * Created on Feb 9, 2010
 */
package gov.fnal.elab.ligo.data.convert;

public class ChannelName {
    public final String originalName, uniformName, subsystem;
    private boolean originalIsUniform;
    
    public ChannelName(String originalName) {
        this.originalName = originalName;
        this.uniformName = freqDashToUnderscore(originalName);
        this.subsystem = extractSubsystem(uniformName);
        originalIsUniform = originalName.equals(uniformName);
    }

    private String extractSubsystem(String name) {
        String[] parts = name.split("[_\\-]");
        if (name.endsWith("Hz")) {
            return parts[parts.length - 3] + "_" + parts[parts.length - 2] + "_" + parts[parts.length - 1];
        }
        else {
            return parts[parts.length - 1];
        }
    }

    private String freqDashToUnderscore(String s) {
        StringBuilder sb = new StringBuilder();
        
        boolean first = true;
        for(int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c == '-') {
                if (first) {
                    first = false;
                }
                else {
                    c = '_';
                }
            }
            sb.append(c);
        }
        return sb.toString();
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof ChannelName) {
            return uniformName.equals(((ChannelName) obj).uniformName);
        }
        else {
            return false;
        }
    }

    @Override
    public int hashCode() {
        return uniformName.hashCode();
    }

    @Override
    public String toString() {
        return originalIsUniform ? originalName : uniformName + " (" + originalName + ")"; 
    }

    public String getSubsystem() {
        return subsystem;
    }
}
