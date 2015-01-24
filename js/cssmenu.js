( function( $ ) {
$( document ).ready(function() {
var menu_ul = $('#cssmenu > ul > li > ul');
menu_ul.hide();

$('#cssmenu > ul > li > ul > li > a').each(function(){
  if ($(this)[0].href == window.location.href) {
    var p = $(this).parent();
    p.addClass('active');
    p = p.parent();
    p.addClass('active');
    p.show();
    p = p.parent();
    p.addClass('active');
  }
});

$('#cssmenu > ul > li > a').click(function() {
  /*$('#cssmenu li').removeClass('active');*/
  $(this).closest('li').addClass('active');
  var checkElement = $(this).next();
  if((checkElement.is('ul')) && (checkElement.is(':visible'))) {
    $(this).closest('li').removeClass('active');
    checkElement.slideUp('normal');
  }
  if((checkElement.is('ul')) && (!checkElement.is(':visible'))) {
    /* $('#cssmenu ul ul:visible').slideUp('normal'); */
    checkElement.slideDown('normal');
  }
  if($(this).closest('li').find('ul').children().length == 0) {
    return true;
  } else {
    return false;
  }
});
});

$(function() {
	var $searchBox = $('#search-box');
	var $mobileTitle = $('#mobile-title');
	var $mobileSearch = $('#mobile-search');
	var $top = $('#top');

	// move search box in mobile mode, 
	// could be done with html+css change
	$(window).on('resize', updateSearchBox);

	function updateSearchBox(){
		if($mobileTitle.is(':visible')){
			if(!$mobileSearch.has($searchBox).length > 0) $mobileSearch.append($searchBox.detach());
		}else{
			if(!$top.has($searchBox).length > 0) $top.append($searchBox.detach());
		}
	}
	updateSearchBox();

	$('#mobile-search-button').click(function() {
		$('#mobile-search').slideToggle();
	});
	$('#mobile-hamburger').click(function() {
		var duration = 500;
		$("#navigation").addClass('open');
		var $cancel = $('<div>')
			.attr('id', 'navigation-cancel')
			.click(function() {
				$("#navigation").removeClass('open');
				$cancel.fadeOut(duration, function() {
					$cancel.remove();
				});
				$cancel.off();
			})
			.hide()
			.appendTo('body')
			.fadeIn(500)
		;
	});
});

} )( jQuery );
