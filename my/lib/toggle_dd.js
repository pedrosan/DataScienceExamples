// execute only when the whole document is ready
$(document).ready(function() {
	
	// hide all sub heading lists
	$('#calendar_wrap dd').hide();
	$('div.abstract').hide();
	
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
});
