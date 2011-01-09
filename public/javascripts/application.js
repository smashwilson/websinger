// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function() {

  // By default, AJAX function responses should render in the #success or #failure divs of the application layout.
  // Handle any that are allowed to propagate to the document object.
  $('body').bind('ajax:success', function (event, data, status, xhr) {
    $('#success')
      .show()
      .html(data)
  })
  
  $('body').bind('ajax:error', function (event, xhr, status, error) {
    $('#failure')
      .show()
      .html(xhr.responseText)
  })
  
  // AJAX results are dismissable by a click.
  fadeCallback = function () { $(this).fadeOut('slow') }
  $('#success').click(fadeCallback)
  $('#failure').click(fadeCallback)
})
