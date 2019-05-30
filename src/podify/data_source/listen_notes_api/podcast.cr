require "json"
require "./episode"

module ListenNotesApi
  class Podcast
    JSON.mapping({
      episodes: Array(Episode),
    })
  end
end
