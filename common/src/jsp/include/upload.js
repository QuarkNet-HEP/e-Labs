/* Licence:
*   Use this however/wherever you like, just don't blame me if it breaks anything.
*
* Credit:
*   If you're nice, you'll leave this bit:
*
*   Class by Pierre-Alexandre Losson -- http://www.telio.be/blog
*   email : plosson@users.sourceforge.net
*/
function refreshProgress()
{
    UploadMonitor.getUploadInfo(updateProgress);
}

function updateProgress(uploadInfo)
{
    if (uploadInfo.inProgress)
    {
        document.getElementById('uploadbutton').disabled = true;
        document.getElementById('uf1').disabled = true;
        document.getElementById('uf2').disabled = true;
        document.getElementById('uf3').disabled = true;

        var fileIndex = uploadInfo.fileIndex;

        var progressPercent = Math.ceil((uploadInfo.bytesRead / uploadInfo.totalSize) * 100);

        document.getElementById('progressBarText').innerHTML = 'upload in progress: ' + progressPercent + '%';

        document.getElementById('progressBarBoxContent').style.width = parseInt(progressPercent * 3.5) + 'px';

        window.setTimeout('refreshProgress()', 100);
    }
    else
    {
        document.getElementById('uploadbutton').disabled = false;
        document.getElementById('uf1').disabled = false;
        document.getElementById('uf2').disabled = false;
        document.getElementById('uf3').disabled = false;
    }

    return true;
}

function startProgress()
{
    document.getElementById('progressBar').style.display = 'block';
    document.getElementById('progressBarText').innerHTML = 'upload in progress: 0%';
    document.getElementById('uploadbutton').disabled = true;

    // wait a little while to make sure the upload has started ..
    window.setTimeout("refreshProgress()", 3000);
    return true;
}
