// execute only when the whole document is ready
$(document).ready(function() {

    // hide all sub heading lists
    $('pre.sourceCode').show();

    $('div.hideThisCode').next('pre.sourceCode').hide();
    // $('button.toggle_code_alt').next('pre.sourceCode').hide();
    $('button.toggle_code').next('pre.sourceCode').hide();
    $('button.toggle_plot_code').next('pre.sourceCode').hide();

    // $('div.narrow_table').next('table').attr("class","narrow");
    // $('div.narrow_table').next('table').addClass("narrow_table");

    $('div.narrow_table').next('table').hide();

    $('.table').addClass("narrow");
    // $('h3').css('background', 'yellow'); // THIS WORKED

    // $('table').attr("class","narrow_table");
    

    // $(document).ready(function(){
        $("button").click(function(){
            $(this).next('pre.sourceCode').slideToggle('slow');
        });

        $('div.hideThisCode').click(function(){
            $(this).next('pre.sourceCode').slideToggle('slow');
        });

    // });

});
