<?php
/***********************************************************************\
 * Functions to support adding file attachments (and possibly other 
 * content managment features) to BOINC forums, as used by I2U2
 * (and tested on Pirates@Home).
 *
 * @(#) $Revision: 1.4 $ + $Date: 2008/07/31 12:09:13 $ + $Name:  $  
\***********************************************************************/

require_once('../include/forum_extras.php');   


// Configuration:
// directories are relative to $top_dir, the document root

define("UPLOAD_TMP_DIR", "upload_tmp");   // not public
define("ATTACH_DIR", "attachments");      // not public
define("VIEW_DIR", "view");          // public, under user/
define("IMG_PREVIEW_MAX_WIDTH",  150);
define("IMG_PREVIEW_MAX_HEIGHT", 200);


$top_dir = dirname($_SERVER['DOCUMENT_ROOT']); // top level, not public

$view_link_count=0;


// Maximum file attachment size:
//$max_file_size=512*1024;
// Increased for Fellows -EAM 29Aug2007
$max_file_size=5*1024*1024;

$file_type_list=array("image"=>"image/unknown",
                      "text"=>"text/unknown",   
                      "PDF document"=>"application/pdf",
                      "Postscript document"=>"application/postscript",
                      "MS word document"=>"application/msword",
                      "Placemarks"=>"application/vnd.google-earth.kmz",
                      "eXcel spreadsheet"=>"application/vnd.ms-excel",
                      "data"=>"data/unknown",
                      "Other"=>"unknown/unknown");

/**
 * Attachment file Information (matches DB table)
 */

class FileAttachment{
    var $caption;       // brief description of the file
    var $orig_filename; // original filename (when uploaded)
    var $ext;           // original file extension 
    var $filetype;      // MIME type (if possible)        
    var $filename;      // where the file lives now (in ATTACH_DIR)
    var $size;
    var $md5;
    var $hidden;        // turned off?

    function FileAttachment($name="",$type=""){    // Constructor: 
        $this->orig_filename=clean_filename($name);
        $this->filetype=$type;
    }

    function clear(){
        $this->orig_filename="";
        $this->filename="";
        $this->filetype="";
        $this->ext="";
        $this->size=0;
        $this->md5="";
    }
}



/**
 * Save an attachment file uploaded file while editing a posting.
 */

function save_uploaded_attachment($attach_file){
    global $top_dir, $logged_in_user, $attach_error;
    global $forumid;

    $tmpFile=$_FILES['attach_file']['tmp_name'];
    if( !is_uploaded_file($tmpFile) ){
        $attach_error="Failed to upload file.  File too large? ";
       debug_msg(1,$attach_error);
       return NULL;
    }

    $attach_file->orig_filename=
        clean_filename($_FILES['attach_file']['name']);  
    $attach_file->filetype=$_FILES['attach_file']['type'];
    $attach_file->size=$_FILES['attach_file']['size'];
    $attach_file->md5=md5_file($tmpFile);
    $attach_file->filename=$tmpFile;  // where it is now, for now

    $p = pathinfo($attach_file->orig_filename);
    $ext = $p['extension'];
    $attach_file->ext=$ext;

    // create a unique internal filename/path relative to $top_dir

    $userid = $logged_in_user->id;
    $tag = "F".$forumid."U".$userid."A1";
    if( !empty($ext) ) $tag .= ".".$ext;
    $filename= UPLOAD_TMP_DIR ."/" .$tag;
    $filepath=$top_dir ."/". $filename;

    debug_msg(2,"File ".$_FILES['attach_file']['name']." moving to ".$filepath);

    // Move the uploaded file to *our* temporary upload area

    if( !move_uploaded_file($tmpFile,$filepath) ){
        $attach_file->clear();
        $attach_error="File ".$tmpFile. " could not be moved. Bummer.";
        debug_msg(1,$attach_error);
        return NULL;
    }
    $attach_file->filename=$filename;  // new location
    return $attach_file;
}


/**********************
 * Add file attachment $attach_file to a forum posting, by 
 * copying the file to the attachments area and then making
 * a database entry for the attachment.
 */

function addPostAttachment($post, $user, $attach_file){
    global $top_dir;

    $postid=$post->id;
    $userid=$user->id;
    $filename= $attach_file->filename;
    if( empty($filename) ) {
        debug_msg(1, "No file name given for attachment file");
        return 0;
    }

    $tmpFilePath=$top_dir."/". $filename;
    
    if( !file_exists($tmpFilePath) ){
        debug_msg(1, "Cannot find attachment file $tmpFilePath");
        return 0;
    }

    $newname = "P".$postid."U".$userid."A1";
    $ext = $attach_file->ext;
    if( !empty($ext) ) $newname .= ".".$ext;
    $newname= ATTACH_DIR ."/". $newname;

    $newFilePath = $top_dir ."/". $newname;

    // move the file

    debug_msg(2,"File $tmpFilePath moving to ".$newFilePath);

    if( !rename($tmpFilePath, $newFilePath) ) {
        debug_msg(1,"Cannot move $tmpFilePath to $newFilePath. Bummer.");
        return; 
    }
    $attach_file->filename=$newname;      // change the name 

    // insert it into DB 

    $oname=$attach_file->orig_filename;
    $type=$attach_file->filetype;
    $caption=mysql_real_escape_string($attach_file->caption);
    $size=$attach_file->size;
    $md5=$attach_file->md5;

    $now=time();

    $sql = "INSERT INTO forum_attachment ( post, user, timestamp,
              orig_filename, filetype, filename, ext, caption, 
              size, md5 )
            VALUES ( $postid, $userid, $now,
              '$oname', '$type', '$newname', '$ext', '".$caption."',
                $size, '$md5' )";

    debug_msg(1,"mySQL: $sql");
    mysql_query($sql);
    $i = mysql_insert_id();
    return $i;
}




/**********************
 * Emit a viewing link for any attachment associated with this post,
 * or nothing if there is no attachment
 */

function getPostAttachment($postid){
    global $top_dir; 

    if( !is_numeric($postid) || $postid < 1 ) return "";
    $sql = "SELECT * FROM forum_attachment WHERE post=$postid";
    $result = mysql_query($sql);
    $N = mysql_num_rows($result);
    if( $N <=0  ) return "";
    $item= mysql_fetch_object($result);
    mysql_free_result($result); 

    $alt=basename($item->orig_filename);
    $caption=$item->caption;
    if($caption) $image_title=$caption;
    else         $image_title=$alt;
    return attachment_view_link($item,$image_title,$alt,$postid);
}





/**
 * View a file attachment. We do this in a somewhat complicated
 * way to provide a little bit of privacy for the files (it's not
 * perfect).  First, copy the file to the viewing area (along with 
 * a thumbnail if it exists).  Then ...
 */

function attachment_view_link($attach_file, $title="", $alt="", $postid=0){
    global $top_dir, $view_link_count;

    $filepath=$top_dir ."/". $attach_file->filename;

    if( !file_exists($filepath) ){
        debug_msg(1,"No file $filepath ");
        return "";
    }

    /* If the $postid is given then use that to construct a (public)
     * viewing name.  Only copy the file if it's not there already. */

    if( $postid && is_numeric($postid) && $postid>0 ) {
        $viewFile="$postid-".$attach_file->orig_filename;
        $viewPath= $top_dir . "/user/" .VIEW_DIR."/" . $viewFile;      

        if( !file_exists($viewPath) ) {
            if( !copy($filepath, $viewPath) ){
                debug_msg(1,"Failed to copy $filepath to $viewPath");
                return "";
            }
        }
    }
    else {// if we are preparing a post there is no $postid yet
        $viewFile = getenv('UNIQUE_ID');  // requires Apache module
        if( empty($viewFile) ){// punt
            $viewFile = $_SERVER['REQUEST_TIME'] . posix_getpid();
        }
        $view_link_count += 1;
        $viewFile .=   "-$view_link_count";  // sort of guessable.
        $ext = $attach_file->ext;
        if($ext) $viewFile=$viewFile .".". $ext;
        $viewPath= $top_dir . "/user/" .VIEW_DIR."/" . $viewFile;

        if( !copy($filepath, $viewPath) ){
            debug_msg(1,"Failed to copy $filepath to $viewPath");
            return "";
        }
    }


    /* construct link */  

    $viewURL="/".VIEW_DIR."/" . $viewFile;

    /* handle various file types */ 

    list($mime_major, $mime_minor) = split("/", $attach_file->filetype);

    $image = "/img/unknown.gif";
    $target="_viewer";
    $size_limit="" ;
    $orig_filename=$attach_file->orig_filename;

    // Image files:

    if($mime_major=="image"){
        // TODO: make the viewURL spawn a special image browsing window
        $image=$viewURL;
        $size_limit = ImageSizeLimit($filepath, IMG_PREVIEW_MAX_WIDTH,
                                     IMG_PREVIEW_MAX_HEIGHT );

        // if the image does not need resizing then no viewing URL
        if(empty($size_limit)) { 
            $viewURL="";
        }
    }


    // PDF files:  icon, no target

    if( $mime_minor=="pdf" || $attach_file->filetype=="PDF Document" ){
        $image="/img/pdf_icon.gif";
        $target="";   
    }

    // Postcript files:  icon, no target

    if( $mime_minor=="postscript" || $attach_file->filetype=="Postscript" ){
        $image="/img/ps.gif"; //TODO: need better PS icon here 
        $target="";   
    }

    // Postcript files:  icon, no target

    if( $mime_minor=="vnd.google-earth.kmz" || $attach_file->filetype=="Placemark" ){
        $image="/img/GoogleEarth.gif"; 
        $target="";   
    }

    // Text files

    if( $mime_major=="text" || $attach_file->filetype=="text" ){
        $image="/img/text.gif";
    }

    // Hidden files: blank out everything about the file


    if( $attach_file->hidden != 0 ) {
       $image = "/img/unknown.gif";
       $viewURL=""; 
       $target="";
       $alt="(Hidden)";
       $title="This attachment has been hidden by a forum moderator.";
       $orig_filename="(Hidden)";
       $size_limit="";
    }

    /* Construct the viewing link */

    if($target) $target="target='" .$target. "'";

    if($viewURL) $link="<a href='".$viewURL."' " . $target . ">        ";
    else     $link="";

    $text =  "\n <table class='view_link' align='right'>
        <tr><td align='center'>".$link."
            <image src='".$image."'  border='0' 
                   valign='top' align='center' $size_limit
                   title='".htmlspecialchars($title,ENT_QUOTES)."'
                   alt='".htmlspecialchars($alt,ENT_QUOTES)."' ></a> 
            </td></tr>
        <tr><td align='center'>".$orig_filename."</td></tr>
     </table>\n\n";

    return $text;
}

/**
 * Clean a filename: remove leading path, spaces, and any other
 * characters not allowed in filenames.
 */

function clean_filename($unclean){
    // remove enclosing spaces and leading path
    $t1 = basename(trim($unclean)); 

    // turn spaces into underscores

    $trans=array(" " => "_" , "'" => ""); 
    $t2= strtr($t1, $trans);

    // remove non-alphanumeric characters

    $pattern = "/[^a-zA-Z0-9_\.\-]/";  
    $t3= preg_replace($pattern, '', $t2);

    // collapse strings of underscores

    $t4= preg_replace("/__/", "", $t3,100);

    $clean=$t4;
    if( empty($clean) ) $clean="None";
    return $clean;
}



/**
 * Return a size limit argument for an HTML <image> tag appropriate
 * to the image named in $fileName, given the max width and height,
 * or an empty string if the image is smaller than the limits or we
 * cannot figure out what to do.
 */

function ImageSizeLimit($fileName, $maxWidth, $maxHeight){

    if( $maxWidth <= 0 || $maxHeight <= 0 ) return "";

    list($ow, $oh, $type) = getimagesize($fileName); 

    // Small enough to show ?
    if($ow <= $maxWidth && $oh <= $maxHeight) return ""; 


    // Not too wide, so just too high
    if( $ow <= $maxWidth ) return "height='$maxHeight' ";
  

    // Not too tall, so just too wide
    if( $oh <= $maxHeight ) return "width='$maxWidth' ";

    // Too large in general, so scale down appropriately.

    $ws = $ow/$maxWidth;
    $hs = $oh/$maxHeight;
    $scale = max($ws ,$hs);

    $w = intval($ow/$scale);
    $h = intval($oh/$scale);
    return "width='$w' height='$h'";
}

?>
