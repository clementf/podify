require "json"

module ListenNotesApi
  class Episode
    JSON.mapping({
      audio: String,
      audio_length_sec: UInt16, # don't expect episodes with negative duration, or longer than ~18 hours
      description: String,
      title: String,
    })

    def tracks
      Description.new(description).extract_tracks
    end
  end

  class Description
    def initialize(@text : String); end

    def extract_tracks
      lines = @text.split("\n")
      regex = /[0-9]{1,4}(\.|\))(.*)(\s-\s)(.*)?\s\((.*)\)(\s\[(.*)\])?/
      lines.map do |line|
        match_data = line.match(regex)
        next unless match_data

        artist = match_data[2].strip
        title = match_data[4].strip
        version =  match_data[5].strip
        label = match_data[7].strip
        Track.new(title, artist, version, label)
      end.compact
    end
  end

end
