// Global Javascript functions.

var heartbeatCallbacks = [];
var heartbeatDelay = 2000;

// A heartbeat function that will be called every few seconds.
function heartbeat(callback) {
  heartbeatCallbacks.push(callback);
}

// Invoke the updates manually.
function beat() {
  $(heartbeatCallbacks).each(function () { this() });
}

$(function() {

  // By default, AJAX function responses should render in the #success or #failure divs of the application layout.
  // Handle any that are allowed to propagate to the document object.
  $('body').bind('ajax:success', function (event, data, status, xhr) {
    if( ! data.match(/^\W+$/) ) {
      $('#success').show().html(data);
    }
  })

  $('body').bind('ajax:error', function (event, xhr, status, error) {
    $('#failure').show().html(xhr.responseText);
  })

  // AJAX results are dismissable by a click.
  fadeCallback = function () { $(this).fadeOut('slow') };
  $('#success').click(fadeCallback);
  $('#failure').click(fadeCallback);

  // Execute the heartbeat callback.
  function periodic() {
    beat()
    setTimeout(periodic, heartbeatDelay)
  }
  periodic()
})
