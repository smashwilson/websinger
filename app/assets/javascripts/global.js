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

  // Track and update the player state.
  var lastStatus = null;
  var updateProgress = true;
  var updateVolume = true;

  function refreshPlayer() {
    $.getJSON('/player', function (status) {
      $('.player .controls a').removeClass('submitted');

      if( status.playback_state != 'playing' ) {
        $('#command_play').removeClass('disable');
        $('#command_pause').addClass('disable');
      } else {
        $('#command_play').addClass('disable');
        $('#command_pause').removeClass('disable');
      }

      // Update track data.
      if (lastStatus == null || status.track_id != lastStatus.track_id) {
        var albumArtId = status.track_id || 'placeholder';
        $('.player .album-art').attr('src', '/tracks/' + albumArtId + '/album-art');
        $('.player .track .title').html(status.title || ' ');
        $('.player .track .artist').html(status.artist || ' ');
        $('.player .track .album').html(status.album || ' ');
      }

      // Update the progress bar.
      if (updateProgress) {
        $('.player .progress .bar').css('width', status.percent_complete + '%');
        $('.player .control-cluster .progress-text').html(status.progress);
      }

      // Update the volume control.
      if (updateVolume) {
        $('.player .volume .mask').css('height', (100 - status.volume) + '%');
      }

      lastStatus = status;
    })
  }

  $('.player .controls a').click(function () {
    $(this).addClass('submitted');
    refreshPlayer();
  })

  // Moving the mouse over the progress bar causes the progress bar to track the X coordinate of the mouse pointer.
  // Clicking the mouse on the progress bar executes a jump action with the percentage of the X coordinate as a
  // command parameter.
  function jumpTracker(event) {
    var pixels = event.pageX - $(this).offset().left;
    $('.player .progress .bar').css('width', pixels + 'px');
  }

  $('.progress').mouseenter(function () {
    updateProgress = false;
    $(this).mousemove(jumpTracker);
  });
  $('.progress').mouseout(function () {
    $(this).unbind('mousemove', jumpTracker);
    if (lastStatus != null) {
      $('.player .progress .bar').css('width', lastStatus.percent_complete + '%')
    }
    updateProgress = true;
  });
  $('.progress').click(function (event) {
    var percent = Math.floor((event.pageX - $(this).offset().left) * 100 / $(this).width());
    $.ajax({
      url: '/player',
      type: 'PUT',
      data: { 'command': 'jump', 'parameter': percent }
    });
  });

  // Moving the mouse over the volume control causes the volume mask to track the Y coordinate of the mouse pointer.
  // Clicking the mouse on the volume control sends a volume action with the percentage of the Y coordinate as a
  // command parameter.
  function volumeTracker(event) {
    var pixels = event.pageY - $(this).offset().top;
    $('.player .volume .mask').css('height', pixels + 'px');
  }

  $('.volume').mouseenter(function () {
    updateVolume = false;
    $(this).mousemove(volumeTracker);
  })
  $('.volume').mouseout(function () {
    $(this).unbind('mouseout', volumeTracker);
    if (lastStatus != null) {
      $('.player .volume .mask').css('height', (100 - lastStatus.volume) + '%');
    }
    updateVolume = true;
  })
  $('.volume').click(function (event) {
    var percent = 100 - Math.floor((event.pageY - $(this).offset().top) * 100 / $(this).height());
    $.ajax({
      url: '/player',
      type: 'PUT',
      data: { 'command': 'volume', 'parameter': percent }
    });
  })

  heartbeat(refreshPlayer);

  // Execute the heartbeat callback.
  function periodic() {
    beat()
    setTimeout(periodic, heartbeatDelay)
  }
  periodic()
})
