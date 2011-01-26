// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var heartbeatCallbacks = []
var heartbeatDelay = 2000

// A heartbeat function that will be called every few seconds.
function heartbeat(callback) {
  heartbeatCallbacks.push(callback)
}

// Invoke the updates manually.
function beat() {
  $(heartbeatCallbacks).each(function () { this() })
}

$(function() {

  // By default, AJAX function responses should render in the #success or #failure divs of the application layout.
  // Handle any that are allowed to propagate to the document object.
  $('body').bind('ajax:success', function (event, data, status, xhr) {
    if( ! data.match(/^\W+$/) ) {
      $('#success')
        .show()
        .html(data)
    }
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
  
  // Update the player state.
  function refreshPlayer() {
    $.getJSON('/player', function (status) {
      var percent = 0
      var timeString = ''
      
      $('.player .controls a').removeClass('submitted')
      
      if( status.playback_state != 'playing' ) {
        $('#command_play').removeClass('disable')
        $('#command_pause').addClass('disable')
      } else {
        $('#command_play').addClass('disable')
        $('#command_pause').removeClass('disable')
      }
    
      $('.player .track .artist').html(status.artist)
      $('.player .track .title').html(status.title)
      $('.player .progress .bar').css('width', status.percent_complete + '%')
      $('.player .progress span').html(status.progress)
    })
  }
  
  $('.player .controls a').click(function () {
    $(this).addClass('submitted')
    refreshPlayer()
  })
  
  heartbeat(refreshPlayer);
  
  // Execute the heartbeat callback.
  function periodic() {
    beat()
    setTimeout(periodic, heartbeatDelay)
  }
  periodic()
})
