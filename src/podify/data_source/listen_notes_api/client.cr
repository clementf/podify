require "cossack"

require "./podcast"
require "../data_source"

module ListenNotesApi

  API_TOKEN = ENV.fetch("LISTEN_NOTES_API_TOKEN")
  BASE_URL = "https://listen-api.listennotes.com/api/v2"

  class Client
    include DataSource

    def initialize
      @http_client = Cossack::Client.new(ListenNotesApi::BASE_URL) do |client|
        client.headers["X-ListenAPI-Key"] = API_TOKEN
        client.use Cossack::RedirectionMiddleware, limit: 10
      end
    end

    def episodes(feed_id : String)
      response = @http_client.get("/podcasts/#{feed_id}")
      body = process_response(response)
      Podcast.from_json(body).episodes
    end
  end
end

