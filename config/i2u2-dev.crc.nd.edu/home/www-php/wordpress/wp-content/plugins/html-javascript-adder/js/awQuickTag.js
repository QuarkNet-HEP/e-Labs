//AW Quick Tags by Aakash Chakravarthy 
//Version : 2.5
//Website : www.aakashweb.com

function awQuickTags(tbField, openTg, closeTg, btType) {
  
  contentBox =document.getElementById(tbField);
  var src; var href; var style; var divStyle; var divId;
  //IE Browser
  if (document.selection) {
    contentBox.focus();
    sel = document.selection.createRange();
		
		switch(btType){
	
			case 'a':
				sel.text = insertTagLink('', openTg, sel.text, closeTg, '');
			break;
			
			case 'img':
				sel.text = insertTagImage('', openTg, sel.text, closeTg, '');
			break;
			
			default:
				sel.text = insertTagsAll('', openTg, sel.text, closeTg, '');
			break;
			
		}
  }
  
 //Mozilla and Webkit Browsers
 
 else if (contentBox.selectionStart || contentBox.selectionStart == '0') {
 
		var startPos = contentBox.selectionStart;
		var endPos = contentBox.selectionEnd;
		var front = (contentBox.value).substring(0,startPos);  
		var back = (contentBox.value).substring(endPos,contentBox.value.length); 
		var selectedText = contentBox.value.substring(startPos, endPos);
		
		switch(btType){
			default: 
				contentBox.value = insertTagsAll(front, openTg, selectedText, closeTg, back);
				contentBox.selectionStart = startPos + contentBox.value.length;
				contentBox.selectionEnd = startPos + openTg.length + selectedText.length;
			break;
		
			case 'a':
				contentBox.value= insertTagLink(front, openTg, selectedText, closeTg, back);
				contentBox.selectionStart = startPos + contentBox.value.length;
				contentBox.selectionEnd = startPos + openTg.length + selectedText.length + 8 + href.length;
			break;
			
			case 'img':
				contentBox.value= insertTagImage(front, openTg, selectedText, closeTg, back);
				contentBox.selectionStart = startPos + contentBox.value.length;
				contentBox.selectionEnd = startPos + openTg.length + selectedText.length + 7 + src.length + closeTg.length;
			break;
			
			case 'replace':
				contentBox.value= insertTagReplacable(front, openTg, selectedText, closeTg, back);
				contentBox.selectionStart = startPos + contentBox.value.length;
				contentBox.selectionEnd = startPos + openTg.length;
			break;
 		}
	
	} else {
		contentBox.value += myValue;
		contentBox.focus();
	}
	
	//Tag Functions
	
	function insertTagsAll(frontText, openTag, selectedText, closeTag, backText){
		return frontText+ openTg+ selectedText + closeTg + backText;
	}
	
	function insertTagLink(frontText, openTag, selectedText, closeTag, backText){
		href = prompt('Enter the URL of the Link','http://');
		if (href!='http://' && href!=null){
			return frontText + openTg + 'href="' + href + '">' + selectedText + closeTg + backText;
		}else{
			return frontText + selectedText + backText;
		}
	}
	
	function insertTagImage(frontText, openTag, selectedText, closeTag, backText){
		src = prompt('Enter the URL of the Image','http://');
		if (src!='http://' && src!=null){
			return frontText + openTg + 'src="' + src + '" ' + closeTg + selectedText + backText;
		}else{
			return frontText + selectedText + backText;
		}
	}
	
	function insertTagImage(frontText, openTag, selectedText, closeTag, backText){
		src = prompt('Enter the URL of the Image','http://');
		if (src!='http://' && src!=null){
			return frontText + openTg + 'src="' + src + '" ' + closeTg + selectedText + backText;
		}else{
			return frontText + selectedText + backText;
		}
	}
	
	function insertTagReplacable(frontText, openTag, selectedText, closeTag, backText){
		return frontText + openTg + backText;
	}
	
	contentBox.focus();
	
}

//For Heading

function awQuickTagsHeading(tbField, headingBox){
	 contentBox = document.getElementById(tbField);
	 hBox = document.getElementById(headingBox);
	 contentBox.focus();
	 if (document.selection) {
		contentBox.focus();
		sel = document.selection.createRange();
		sel.text = '<h'+ hBox.value + '>' + sel.text + '</h' + hBox.value + '>';
	 }
	 
 else if (contentBox.selectionStart || contentBox.selectionStart == '0') {
 
 	var startPos = contentBox.selectionStart;
    var endPos = contentBox.selectionEnd;
	var front = (contentBox.value).substring(0,startPos);  
	var back = (contentBox.value).substring(endPos,contentBox.value.length); 
	var selectedText = contentBox.value.substring(startPos, endPos);
	
		contentBox.value = front + '<h'+ hBox.value + '>' + selectedText + '</h' + hBox.value + '>' + back;
		
		contentBox.selectionStart = startPos + contentBox.value.length;
		contentBox.selectionEnd = startPos + 4 + selectedText.length;
	}
}

// Extra toolbar Show/Hide Cookie

var expDate = new Date();
expDate.setDate(expDate.getDate()+365);

function awQuickTagTbGetCookie(tbId)
{
		var nameEQ = 'awQT-' + tbId + "=";
		var ca = document.cookie.split(';');
		for(var i=0;i < ca.length;i++) {
			var c = ca[i];
			while (c.charAt(0)==' ') c = c.substring(1,c.length);
			if (c.indexOf(nameEQ) == 0){ 
				return c.substring(nameEQ.length,c.length);
			}
		}
}

function awQuickTagInitiliaze(tbName){
	if(awQuickTagTbGetCookie(tbName)=='hide'){
		awQuickTagTbHide(tbName);
	}else{
		 awQuickTagTbShow(tbName);
	}
}

function awQuickTagTbToggle(tbId)
{
	if(awQuickTagTbGetCookie(tbId)== null || awQuickTagTbGetCookie(tbId)=='show'){
		awQuickTagTbHide(tbId);
	}else{
		awQuickTagTbShow(tbId);
	}

}

function awQuickTagTbShow(tbId)
{
	document.cookie = "awQT-" + tbId +"=show; expires=" + expDate.toGMTString();
	document.getElementById(tbId).style.display = 'block';
}

function awQuickTagTbHide(tbId)
{
	document.cookie = "awQT-" + tbId + "=hide; expires=" + expDate.toGMTString();
	document.getElementById(tbId).style.display = 'none';
}