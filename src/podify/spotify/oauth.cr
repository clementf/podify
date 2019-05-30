require "http/server"
require "oauth2"
require "uri"

require "./api"

module Spotify
  class OAuth

    TEMP_SERVER_PORT = 4567
    REDIRECT = "http://127.0.0.1:#{TEMP_SERVER_PORT}"
    SPOTIFY_CALLBACK_PATH = "/"

    @access_token : OAuth2::AccessToken?

    def initialize
      set_tokens
    end

    def authenticate_client(client)
      client.tap do |client|
        client.headers["Authorization"] = "Bearer #{@access_token.not_nil!.access_token}"
      end
    end

    private def set_tokens
      oauth2_client = OAuth2::Client.new("#{URI.parse(Spotify::Api::AUTH_URL).host}",
                                         Spotify::Api::CLIENT_ID, Spotify::Api::CLIENT_SECRET,
                                         authorize_uri: "/authorize",
                                         token_uri: "/api/token",
                                         redirect_uri: REDIRECT)

      authorize_uri = oauth2_client.get_authorize_uri(scope: "playlist-modify-private")

      # Ephemeral http server to handle oauth callback
      @temp_server = HTTP::Server.new do |context|

        # By default, Spotify would also request /favico, so only valid call is this one
        if context.request.path == SPOTIFY_CALLBACK_PATH
          context.response.content_type = "text/plain"
          context.response.print "All good! You're authenticated, now come back to Podify :)"

          authorization_code = context.request.query_params["code"]

          @access_token = oauth2_client.get_access_token_using_authorization_code(authorization_code)
          @temp_server.not_nil!.close
        end
      end

      address = @temp_server.not_nil!.bind_tcp(TEMP_SERVER_PORT)

      # open url in browser
      Process.run("open \"#{authorize_uri}\"", shell: true)

      @temp_server.not_nil!.listen
    end
  end
end
