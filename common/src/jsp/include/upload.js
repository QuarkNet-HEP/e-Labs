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
        document.getElementById('uf2').disabled = true;
        document.getElementById('uf3').disabled = true;
        disableGroup('detector')
        
        var fileIndex = uploadInfo.fileIndex;

        var progressPercent = uploadInfo.progressPercent; 
        
        document.getElementById('progressBarText').innerHTML = 'Upload in progress: ' + progressPercent + '%';

        document.getElementById('progressBarBoxContent').style.width = parseInt(progressPercent * 3.5) + 'px';

        window.setTimeout('refreshProgress()', 1000);
    }
    else
    {
        document.getElementById('uploadbutton').disabled = false;
        document.getElementById('uf2').disabled = false;
        document.getElementById('uf3').disabled = false;
        enableGroup('detector');
    }

    return true;
}

function startProgress()
{
	document.getElementById('uploadwarning').style.display = 'block';
    document.getElementById('progressBar').style.display = 'block';
    document.getElementById('progressBarText').innerHTML = 'upload in progress: 0%';
    document.getElementById('uploadbutton').disabled = true;

    // wait a little while to make sure the upload has started ..
    window.setTimeout("refreshProgress()", 3000);
    return true;
}

function disableGroup(groupName)
{
	var thisGroup = document.getElementsByName('detector'); 
	for (var i = 0; i < thisGroup.length; ++i) {
		thisGroup[i].disable = true; 
	}
}

function enableGroup(groupName)
{
	var thisGroup = document.getElementsByName(groupName); 
	for (var i = 0; i < thisGroup.length; ++i) {
		thisGroup[i].disable = false; 
	}
}
