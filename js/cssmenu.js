( function( $ ) {
$( document ).ready(function() {
var menu_ul = $('#cssmenu > ul > li > ul');
menu_ul.hide();

$('#cssmenu a').each(function(){
  var href = window.location.href.split('#')[0];
  if (this.href == href) {
    $(this)
      .parents('li,ul')
      .addClass('active')
      .show();
  }
});

$('#cssmenu > ul > li > a').click(function() {
  $li = $(this).closest('li');
  if (!$li.hasClass('has-sub')) {
    $('#cssmenu li').removeClass('active');
  }
  $li.addClass('active');
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
	$('<div>')
		.attr('id', 'mobile-search-button')
		.attr('class', 'fa fa-search')
		.click(function() {
			$('#search-box').toggleClass('open')
		})
		.prependTo('#header');

	$('<div>')
		.attr('id', 'mobile-hamburger')
		.attr('class', 'fa fa-bars')
		.click(function() {
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
		})
		.prependTo('#header');
});

} )( jQuery );
