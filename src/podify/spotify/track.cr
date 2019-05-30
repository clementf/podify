require "json"

require "./api"

module Spotify
  class Track
    include JSON::Serializable

    getter id : String
    getter external_urls : ExternalUrl

    def self.find(track : ::Track)
      query = URI.escape("track:#{track.title} artist:#{track.artist}")
      url = "/search?type=track&q=#{query}"

      found_tracks = Search
        .from_json(Spotify::Api.get(url))
        .results
        .tracks

      return nil if found_tracks.empty?

      found_tracks.first
    end

    def link
      external_urls.spotify
    end
  end

  class ExternalUrl
    include JSON::Serializable

    getter spotify : String
  end
end
