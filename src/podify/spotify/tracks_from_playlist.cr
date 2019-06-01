require "json"

require "./api"

module Spotify
  class TrackFromPlaylist
    include JSON::Serializable

    getter track : Spotify::Track
  end

  class TracksFromPlaylist
    include JSON::Serializable

    @[JSON::Field(key: "items")]
    getter tracks : Array(Spotify::TrackFromPlaylist)

    @[JSON::Field(key: "total")]
    getter total_size : Int32

  end

  class Tracks
    include Iterator(Spotify::Track)

    ENDPOINT_LIMIT = 100

    def initialize(@playlist_id : String)
      @index = 0
      @total_size = -1
      @tracks = [] of Spotify::TrackFromPlaylist
      @retrieved = [] of Spotify::Track
    end

    def next
      get_total_size if @total_size == -1

      return stop if end_of_stream?

      fetch if needs_to_fetch?

      res = current_element
      @index += 1
      res
    end

    def rewind
      @index = 0
    end

    private def end_of_stream?
      @index >= @total_size - 1
    end

    private def current_element
      @retrieved[@index]
    end

    private def needs_to_fetch?
      @index == @retrieved.size - 1
    end

    # This calls fetch, to get the total size, and preloads the first batch as part of the same request
    private def get_total_size
      fetch
    end

    private def fetch
      offset = @index
      result = Spotify::TracksFromPlaylist.from_json(
        Spotify::Api.get("/playlists/#{@playlist_id}/tracks?limit=#{ENDPOINT_LIMIT}&offset=#{offset}")
      )

      @total_size = result.total_size

      result.tracks.each do |track_from_playlist|
        @retrieved << track_from_playlist.track
      end
    end
  end
end
