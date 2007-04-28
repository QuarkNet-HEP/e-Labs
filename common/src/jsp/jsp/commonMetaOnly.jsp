<%!
/**
  * Delete any annotation information associated
  * with the file.
  *
  * @bug                As of 10/7/2004 does not delete from the RC Catalog
  * @param  out         current JspWriter out handle
  * @param  lfn         logical filename to delete
  * @return             <code>true</code> if all 3 steps completed without error
  *                     <code>false</code> otherwise.
  */
public static boolean deleteLFNMeta(String lfn){
    String primary = lfn;
    String secondary = null;
    int kind = Annotation.CLASS_FILENAME;
    java.util.List metaTuples = null;       //list of metaTuples for this lfn
    boolean allModified = false;               //true if the database was successfully modified

    DatabaseSchema dbschema = null;
    // Connect to the database.
    try{
        String schemaName = ChimeraProperties.instance().getVDCSchemaName();

        Connect connect = new Connect();
        dbschema = connect.connectDatabase(schemaName);

        if (! (dbschema instanceof Annotation)) {
            throw new ElabException("The database does not support metadata!");
        }
        else {
            AnnotationSchema annotationschema = null;
            try {
                annotationschema = (AnnotationSchema)dbschema;
                metaTuples = annotationschema.loadAnnotation(lfn, null, kind);

                boolean setAllModified = false;
                boolean currModified = true;
                if(metaTuples.iterator().hasNext()){
                    setAllModified = true;  //if there is at least 1 thing to modify, assume success unless we get a failure
                }
                for(Iterator i=metaTuples.iterator(); i.hasNext(); ){
                    Tuple t = (Tuple)i.next();
                    String key = t.getKey();
                    try{
                        //currModified = annotationschema.deleteAnnotation(primary, secondary, kind, t.getKey());
                        currModified = annotationschema.deleteAnnotationFilename(primary, key);
                    }
                    catch(Exception e){
                        throw new ElabException("Error while deleting the annotation key: " + t.getKey() + " - " + e);
                    }
                        //throw new ElabException("GIVING: " + primary + secondary + kind + " " + key + " " + currModified + "<br>");
                        if(currModified == false){
                            setAllModified = false;
                        }
                }
                allModified = setAllModified;
            } catch (Exception e) {
                throw new ElabException("<CENTER><FONT color= red>Error deleting metadata...</FONT><BR><BR>" + e + "<BR></CENTER>");
            } finally {
                try {
                    if (annotationschema != null)
                        annotationschema.close();
                } catch (Exception ex) {}
            }
        } 
    } catch(Exception e){
        //throw new ElabException("<CENTER><FONT color= red>Error connecting to the database ...</FONT><BR><BR>" + e + "<BR></CENTER>");
        ;
    } finally {
        try {
            if (dbschema != null)
                dbschema.close();
        } catch (Exception ex) {}
    }

    try{
    //throw new ElabException("allmod: "+allModified+"|<BR>");
    }catch(Exception e){
        ;}

      //return allModified;
    return true;
}
%>

