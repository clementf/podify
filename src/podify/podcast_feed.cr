require "./episode"

module Podify
  class PodcastFeed
    def initialize(feed_id : String, data_source : DataSource)
    end

    def episodes
      [] of Episode
    end
  end
end
