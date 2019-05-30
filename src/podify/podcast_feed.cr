require "./episode"

module Podify
  class PodcastFeed
    def initialize(feed_id : String, data_source : DataSource)
      @data_source = data_source
      @feed_id = feed_id
    end

    def episodes
      @data_source.episodes(@feed_id)
    end
  end
end
