require "cossack"

require "./playlist"
require "./track"
require "./search"

module Spotify
  class ServerError < Exception; end

  class Api
    CLIENT_ID = ENV.fetch("SPOTIFY_CLIENT_ID")
    CLIENT_SECRET = ENV.fetch("SPOTIFY_CLIENT_SECRET")
    AUTH_URL = "https://accounts.spotify.com"
    API_URL = "https://api.spotify.com/v1/"

    @@access_token : String?
    @@client : Cossack::Client?

    def initialize
    end

    def self.get(url)
      c = client
      return "" if c.nil?
      response = c.get(url)
      process_response(response)
    end

    def self.client
      @@client ||= configure_client
    end

    private def self.process_response(response : Cossack::Response | HTTP::Client::Response)
      case response.status
      when 200..299
        return response.body
      when 404
        return ""
      when 429
        raise ServerError.new("429: Quota exceeded")
      when 500
        raise ServerError.new("500: Internal Server Error")
      else
        raise ServerError.new("Server returned error #{response.status}")
      end
    end

    private def self.configure_client
      authenticate

      Cossack::Client.new(Spotify::Api::API_URL) do |client|
        client.headers["Authorization"] = "Bearer #{@@access_token}"
        client.use Cossack::RedirectionMiddleware, limit: 10
        client.use(StdoutLogMiddleware)
      end
    end

    private def self.authenticate
      auth_client = Cossack::Client.new(Spotify::Api::AUTH_URL) do |client|
        client.headers["Authorization"] = "Basic #{encoded_credentials}"
        client.headers["Content-Type"] = "application/x-www-form-urlencoded"
        client.use(Cossack::RedirectionMiddleware, limit: 10)
        client.use(StdoutLogMiddleware)
      end

      response = auth_client.post("/api/token", "grant_type=client_credentials")
      body = JSON.parse(response.body)
      @@access_token = body["access_token"].to_s
    end

    private def self.encoded_credentials
      creds = "#{Spotify::Api::CLIENT_ID}:#{Spotify::Api::CLIENT_SECRET}"
      encoded_credentials = Base64.strict_encode(creds)
    end
  end

  class StdoutLogMiddleware < Cossack::Middleware
    def call(request)
      puts "#{request.method} #{request.uri}"
      app.call(request)
    end
  end
end
