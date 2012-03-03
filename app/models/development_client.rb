# This client is for interactive development mode (even on the same system that the real websinger-player is running
# on.) It simulates the "playing" of music and advancement through tracks in real-time with a background thread, but
# doesn't actually produce any audio.
class DevelopmentClient < Client
end
