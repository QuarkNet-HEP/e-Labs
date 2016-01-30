/**
  * HTML Javascript Adder - Wordpress plugin widget functions
  * v2.3 - Since 3.0
  * http://www.aakashweb.com/
**/

$j = jQuery.noConflict();

$j(document).ready(function() {

	var social = '<iframe src="//www.facebook.com/plugins/like.php?href=http%3A%2F%2Fwww.facebook.com%2Faakashweb&amp;send=false&amp;layout=button_count&amp;width=75&amp;show_faces=true&amp;action=like&amp;colorscheme=light&amp;font&amp;height=21&amp;appId=106994469342299" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:75px; height:21px;" allowTransparency="true"></iframe>';
	
	var links = '<span class="hjaLinks"> | <a href="#" class="hjaShare">Like</a> | <a href="http://bit.ly/hjaDonate" target="_blank" title="If you like this plugin, then just make a small Donation to continue this plugin development." class="hjaDonate">Donate !</a></span>';
	
	$j('.hjaAccord').live('click', function(){
		$j(this).parent().children('.hjaAccordWrap').hide();
		$j(this).next('.hjaAccordWrap').show();
	});
	
	$j('.hjaTb').live('click', function(){
		var cntId = $j(this).parent().attr('editorId');
		var openTag = $j(this).attr('openTag');
		var closeTag = $j(this).attr('closeTag');
		var action = $j(this).attr('action');
		return awQuickTags(cntId, openTag, closeTag, action);
	});
	
	$j('.hjaTb-preview').live('click', function(){
		var editId = $j(this).attr('editorId');
		hjaOpenPopup($j('#' + editId).val());
	});
	
	$j('.hjaShare').live('mouseenter', function(){
		$j(this).find('span').remove();
		$j(this).prepend('<span>' + social + '</span>');
	});
	
	$j('.hjaOverlayClose').click(function(){
		$j(this).parent().fadeOut('fast');
	});
	
	$j('div[id*="html_javascript_adder"]').find('.widget-control-actions .alignleft').append(links);
	
});

function hjaOpenPopup(content){
	
	hjaIframe.document.open();
	hjaIframe.document.write(content);
	hjaIframe.document.close();
	
	$j('.hjaWindow').fadeIn('fast');
}