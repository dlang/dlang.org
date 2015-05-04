( function( $ ) {
$( document ).ready(function() {
var menu_ul = $('#cssmenu > ul > li > ul');
menu_ul.hide();

function baseName(str) {
  return str.split('/').pop();
}

// highlight menu entry of the current page
var href = window.location.href.split('#')[0];
var current;
var res = $('#cssmenu a').each(function (_, a) {
    if (a.href == href) {
        current = a;
        return false;
    }
});
current = $(current);
// direct li parent containing the link
current.parent('li').addClass('active');
// topmost li parent, e.g. 'std'
current.parents('#cssmenu li.has-sub').addClass('active')
// show menu tree
  .children('ul').show();


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

// ---------------------------------------------------------------------------

// [your code here] rotation for index.html
$(function() {
	var $examples = $('.your-code-here-extra > pre');
	if ($examples.length) {
		var n = Math.floor(Math.random() * ($examples.length+1));
		if (n)
			$('#your-code-here-default > pre').replaceWith($examples[n-1]);
	}
});