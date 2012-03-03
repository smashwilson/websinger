// Read and write functionality for the player controls at the top of each page.

function formatSeconds(seconds) {
  var minutes = Math.floor(seconds / 60);
  var remaining = Math.floor(seconds - (minutes * 60));

  var trailing = '';
  if (remaining < 10) {
    trailing = '0';
  }

  return minutes + ':' + trailing + remaining;
}

$(function () {
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
        var albumArtId = status.track_id || 'empty';
        $('.player .album-art').attr('src', '/tracks/' + albumArtId + '/album-art');
        $('.player .track .title').html(status.title || ' ');
        $('.player .track .artist').html(status.artist || ' ');
        $('.player .track .album').html(status.album || ' ');
      }

      // Display the error if one is present, or hide it if it has gone away.
      if (status.error == null) {
        $('.player .error').css('display', 'none');
      } else {
        $('.player .error').html(status.error).css('display', 'block');
      }

      // Update the progress bar and progress text.
      if (updateProgress) {
        var percentComplete = 0;
        if (status.length != null) {
          percentComplete = status.seconds * 100 / status.length;
        }

        $('.player .progress .bar').css('width', percentComplete + '%');
      }

      // Update the progress text.
      var progressText = '';
      if (status.playback_state != 'stopped') {
        progressText = formatSeconds(status.seconds) + ' / ' + formatSeconds(status.length);
      }
      $('.player .control-cluster .progress-text').html(progressText);

      // Update the volume control.
      if (updateVolume) {
        $('.player .volume .mask').css('height', (100 - status.volume) + '%');
      }

      lastStatus = status;
    })
  }
  heartbeat(refreshPlayer);

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
  $('.progress').mouseleave(function () {
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
  $('.volume').mouseleave(function () {
    $(this).unbind('mousemove', volumeTracker);
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
});
