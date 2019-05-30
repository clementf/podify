require "./playlist"
require "./track"

require "oauth2"
module Spotify
  class Api
    CLIENT_ID = ENV.fetch("SPOTIFY_CLIENT_ID")
    CLIENT_SECRET = ENV.fetch("SPOTIFY_CLIENT_SECRET")
    AUTH_URL = "https://accounts.spotify.com"

    @access_token : String?

    def initialize
      authenticate
      puts @access_token
    end

    def find_track(track : ::Track)
      Spotify::Track.new
    end

    def create_playlist(name : String)
      Spotify::Playlist.new
    end

    private def authenticate
      http_client = Cossack::Client.new(Spotify::Api::AUTH_URL) do |client|
        client.headers["Authorization"] = "Basic #{encoded_credentials}"
        client.headers["Content-Type"] = "application/x-www-form-urlencoded"
        client.use(Cossack::RedirectionMiddleware, limit: 10)
      end

      response = http_client.post("/api/token", "grant_type=client_credentials")
      body = JSON.parse(response.body)
      @access_token = body["access_token"].to_s
    end

    private def encoded_credentials
      creds = "#{Spotify::Api::CLIENT_ID}:#{Spotify::Api::CLIENT_SECRET}"
      encoded_credentials = Base64.strict_encode(creds)
    end
  end
end
