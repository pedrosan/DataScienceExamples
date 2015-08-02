// execute only when the whole document is ready
$(document).ready(function() {
	
	// hide all sub heading lists
	$('#calendar_wrap dd').hide();
	$('div.abstract').hide(); 
	/* $('span.talk_title').append(' <span style="font-size: xx-small;">[click title for abstract]</span>'); */
	// $('span.talk_title').after(' <span style="font-size: xx-small;">[click title for abstract]</span>');
	/* $("li").find('div.abstract').css("border", "1px solid red"); */
	
	// add a click handler to the heading links
	$('#calendar_wrap dt').click(function(){
		// if the current sub heading list is already open
		if($(this).next('dd:visible').length) {
			// close the sub heading list
			$(this).next('dd:visible').slideUp();
		} else {
			// close all open sub heading lists
			$('#calendar_wrap dd:visible').slideUp();
			// slide open the next list
			$(this).next('dd').slideToggle('normal');
		}
	
	// return false to stop link following the href
	return false;
	});

	// add a click handler to the heading links
	$('li span.talk_title').click(function(){
		/* $('li div.abstract').slideToggle("slow"); */
		/* $('div.abstract:visible').slideUp(); */
		/* $('li div.abstract:hidden').slideDown(); */

		// if the current sub heading list is already open
		if($(this).next('div.abstract:visible').length) {
			// close the sub heading list
			$(this).next('div.abstract:visible').slideUp();
		} else {
			// close all open sub heading lists
	                $('li div.abstract:visible').slideUp();
			// slide open the next list
			$(this).next('div.abstract').slideToggle('normal');
		}
	
	// return false to stop link following the href
	return false;
	});
});
