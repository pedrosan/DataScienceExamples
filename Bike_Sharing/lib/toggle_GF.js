// execute only when the whole document is ready
$(document).ready(function() {

    // hide all sub heading lists
    $('pre.sourceCode').show();

    $('div.hideThisCode').next('pre.sourceCode').hide();
    $('button.toggle_code_alt').next('pre.sourceCode').hide();
    $('button.toggle_code').next('pre.sourceCode').hide();
    
//   // add a click handler to the heading links
//   $('pre.sourceCode').click(function(){
//   
//       // if the current sub heading list is already open
//       if($(this).next('pre.sourceCode:visible').length) {
//           // close the sub heading list
//           $(this).next('pre.sourceCode:visible').slideUp();
//       } else {
//           // close all open sub heading lists
//                   $('pre.sourceCode pre.sourceCode:visible').slideUp();
//           // slide open the next list
//           $(this).next('pre.sourceCode').slideToggle('normal');
//       }
//   
//   // return false to stop link following the href
//   return false;
//   });

//   // add a click handler to the heading links
//   $('div.hideThisCode').click(function(){
//   
//       // if the current sub heading list is already open
//       if($(this).next('pre.sourceCode:visible').length) {
//           // close the sub heading list
//           $(this).next('pre.sourceCode:visible').slideUp();
//       } else {
//           // close all open sub heading lists
//                   $('pre.sourceCode pre.sourceCode:visible').slideUp();
//           // slide open the next list
//           $(this).next('pre.sourceCode').slideToggle('normal');
//       }
//   
//   // return false to stop link following the href
//   return false;
//   });

    $(document).ready(function(){
        $("button").click(function(){
            $(this).next('pre.sourceCode').slideToggle('slow');
        });

        $('div.hideThisCode').click(function(){
            $(this).next('pre.sourceCode').slideToggle('slow');
        });

    });

});
