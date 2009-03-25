package gov.fnal.elab.util;

import java.util.*;
import java.io.*;
import org.apache.batik.transcoder.image.PNGTranscoder;
import org.apache.batik.transcoder.TranscoderInput;
import org.apache.batik.transcoder.TranscoderOutput;
import gov.fnal.elab.util.ElabException;

/**
 * Common utility functions usefull for Elab development.
 *
 * @author  Paul Nepywoda
 */
public class ElabCommon {

    /**
     * Convert a .svg image to a .png.
     *
     * @param   svgFilename     full path to the svg image
     * @param   pngFilename     full path to the png image to output
     * @param   pngHeight       pixel height of the png image
     */
    public static void svg2png(String svgFilename, String pngFilename, String pngHeight) throws ElabException{
        String svgFile = null;  //the image file as a string

        try{
            svgFile = (new File(svgFilename)).toURI().toURL().toString();
        } catch(Exception e){
            throw new ElabException("Error while opening svg file " + svgFilename + ": " + e);
        }

        PNGTranscoder trans = new PNGTranscoder();

        /* Do the transcoding */
        try {
            // Convert the SVG image to PNG using the Batik toolkit.
            // Thanks to the Batik website's tutorial for this code (http://xml.apache.org/batik/rasterizerTutorial.html).
            // Regular size image.
            trans.addTranscodingHint(PNGTranscoder.KEY_HEIGHT, new Float(pngHeight));
            TranscoderInput input = new TranscoderInput(svgFile);
            OutputStream ostream = new FileOutputStream(pngFilename);
            TranscoderOutput output = new TranscoderOutput(ostream);
            trans.transcode(input, output);
            ostream.flush();
            ostream.close();
        } catch (Exception e){
            throw new ElabException("Error while transcoding svg " + svgFilename + "to png filename " + pngFilename + " with height " + pngHeight + ":" + e);
        }
    }


    /**
     * Convert a .svg image to a .png and create a thumbnail of the image as well.
     *
     * @param   svgFilename     full path to the svg image
     * @param   pngFilename     full path to the png image to output
     * @param   thumbPngFilename  full path to the thumbnail png image to output
     * @param   pngHeight       pixel height of the png image
     * @param   thumbPngHeight    pixel height of the thumbnail png image
     */
    public static void svg2png(String svgFilename, String pngFilename, String thumbPngFilename, String pngHeight, String thumbPngHeight) throws ElabException{
        String svgFile = null;  //the image file as a string

        try{
            svgFile = (new File(svgFilename)).toURI().toURL().toString();
        } catch(Exception e){
            throw new ElabException("Error while opening svg file " + svgFilename + ": " + e);
        }

        PNGTranscoder trans = new PNGTranscoder();

        /* Normal size /*
        ElabCommon.svg2png(svgFilename, pngFilename, pngHeight);

        /* Thumbnail size */
        ElabCommon.svg2png(svgFilename, thumbPngFilename, thumbPngHeight);
    }
}
