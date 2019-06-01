require "json"

require "./track"

module Spotify
  class Search
    include JSON::Serializable

    @[JSON::Field(key: "tracks")]
    getter results : Spotify::SearchResult
  end

  class SearchResult
    include JSON::Serializable

    @[JSON::Field(key: "items")]
    getter tracks : Array(Spotify::Track)

  end
end
