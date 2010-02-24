/*
 * Created on Feb 23, 2010
 */
package gov.fnal.elab.ligo.data.engine;

import gov.fnal.elab.ligo.data.convert.ChannelName;

public interface LIGOFileReaderFactory {

    LIGOFileReader newReader(ChannelName name, ChannelProperties props, String type);

}
