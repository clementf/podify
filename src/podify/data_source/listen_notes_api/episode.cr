require "json"

module ListenNotesApi
  class Episode
    JSON.mapping({
      audio:            String,
      audio_length_sec: UInt16, # don't expect episodes with negative duration, or longer than ~18 hours
      description:      String,
      title:            String,
    })

    def tracks
      Description.new(description).extract_tracks
    end
  end

  class Description
    def initialize(@text : String); end

    def extract_tracks
      lines = @text.split("\n")
      lines.map do |line|
        track = nil

        matchers.each do |matcher|
          track = matcher.new(line).extract_track
          break if track
        end

        track
      end.compact
    end

    private def matchers
      [
        StrictMatcher,
        GenericMatcher
      ]
    end

  end

  # Will match a full track description, as the following
  # 20. Burn In Noise - Psychedelic Playground (Original Mix) [Label Name]
  class StrictMatcher
    def initialize(@data : String); end

    def regex
      /[0-9]{1,4}(\.|\))(.*)(\s-\s)(.*)?\s\((.*)\)(\s\[(.*)\])?/
    end

    def extract_track
      match = @data.match(regex)

      return unless match

      artist = match[2].strip
      title = match[4].strip
      version = match[5].strip
      label = match[7].strip
      Track.new(title, artist, version, label)
    end
  end

  # Will match everything as long as it starts with track number and contains artist and track name separated with a dash
  # So, it will match:
  # 20. Burn In Noise - Psychedelic Playground
  # As well as
  # 20. Burn In Noise - Psychedelic Playground (Original Mix) [Label Name]
  class GenericMatcher
    def initialize(@data : String); end

    def regex
      /([0-9]{1,4}\.|\)) (.*)? - (.*)?/
    end

    def extract_track
      match = @data.match(regex)

      return unless match

      artist = match[2].strip
      title = match[3].strip
      Track.new(title, artist, nil, nil)
    end
  end
end
