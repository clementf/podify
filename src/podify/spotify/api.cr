require "cossack"

require "./playlist"
require "./track"
require "./search"
require "./user"
require "./oauth"

module Spotify
  class ServerError < Exception; end

  class Api
    CLIENT_ID     = ENV.fetch("SPOTIFY_CLIENT_ID")
    CLIENT_SECRET = ENV.fetch("SPOTIFY_CLIENT_SECRET")
    AUTH_URL      = "https://accounts.spotify.com"
    API_URL       = "https://api.spotify.com/v1"

    @@access_token : String?
    @@client : Cossack::Client?
    @@user_id : String?

    def initialize
    end

    def self.get(url)
      response = client.not_nil!.get(url)
      process_response(response)
    end

    def self.post(url, params)
      response = client.not_nil!.post(url, params)
      process_response(response)
    end

    def self.user_id
      @@user_id ||= Spotify::User.from_json(
        process_response(client.get("/me"))
      ).id
    end

    def self.client
      @@client ||= Spotify::OAuth.new.authenticate_client(cossack_client)
    end

    private def self.process_response(response : Cossack::Response | HTTP::Client::Response)
      case response.status
      when 200..299
        return response.body
      when 400
        raise ServerError.new("400: #{response.body}")
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

    private def self.cossack_client
      Cossack::Client.new(Spotify::Api::API_URL) do |client|
        client.use Cossack::RedirectionMiddleware, limit: 10
        client.use(StdoutLogMiddleware)
      end
    end
  end

  class StdoutLogMiddleware < Cossack::Middleware
    def call(request)
      Podify.logger.debug("#{request.method} #{request.uri}")
      app.call(request)
    end
  end
end
