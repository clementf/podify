require "./playlist"
require "./track"

module Spotify
  class Api
    def find_track(track : ::Track)
      Spotify::Track.new
    end

    def create_playlist(name : String)
      Spotify::Playlist.new
    end
  end
end
