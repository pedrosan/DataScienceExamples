// execute only when the whole document is ready
$(document).ready(function() {
	
	// hide all sub heading lists
	$('pre.sourceCode').show();
	
	// add a click handler to the heading links
	$('#calendar_wrap li').click(function(){
		// if the current sub heading list is already open
		if($(this).find('div.abstract').length) {
			// close the sub heading list
			$(this).find('div.abstract:visible').slideUp();
		} else {
			// close all open sub heading lists
			$('div.abstract:visible').slideUp();
			// slide open the next list
			$(this).find('div.abstract').slideToggle('normal');
		}
	
	// return false to stop link following the href
	return false;
	});
});
