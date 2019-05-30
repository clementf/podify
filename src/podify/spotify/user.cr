require "json"

module Spotify
  class User
    include JSON::Serializable

    getter id : String

    @[JSON::Field(key: "display_name")]
    getter name : String
  end
end
