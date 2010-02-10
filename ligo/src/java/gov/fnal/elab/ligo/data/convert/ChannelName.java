/*
 * Created on Feb 9, 2010
 */
package gov.fnal.elab.ligo.data.convert;

public class ChannelName {
    public final String originalName, uniformName;
    private boolean originalIsUniform;
    
    public ChannelName(String originalName) {
        this.originalName = originalName;
        this.uniformName = freqDashToUnderscore(originalName);
        originalIsUniform = originalName.equals(uniformName);
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
    
    
}
