require "./api"
require "./track"

module Spotify
  class PlaylistCollection
    include JSON::Serializable

    @[JSON::Field(key: "items")]
    getter playlists : Array(Spotify::Playlist)

  end

  class Playlist
    include JSON::Serializable

    getter name : String
    getter id : String

    def self.find_podify_playlist
      podify_playlist = existing_playlist

      return podify_playlist unless podify_playlist.nil?

      create_podify_playlist
    end

    private def self.existing_playlist
      all_playlists = PlaylistCollection.from_json(
        Spotify::Api.get("/users/#{Spotify::Api.user_id}/playlists/")
      ).playlists

      podify_playlist = all_playlists.find { |playlist| playlist.name == "Podify" }
    end

    private def self.create_podify_playlist
      Spotify::Api.post("/users/#{Spotify::Api.user_id}/playlists", "{\"name\": \"Podify\"}")
      existing_playlist
    end

    def add(track : Spotify::Track)
      params = {"uris": [track.uri]}

      puts "Adding track #{track.title} to playlist #{name}"
      Spotify::Api.post("playlists/#{id}/tracks", params.to_json)
    end
  end
end
