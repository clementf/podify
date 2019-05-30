require "dotenv"
Dotenv.load

require "./podify/podcast_feed"
require "./podify/spotify/track"
require "./podify/data_source/listen_notes_api/client"
require "./podify/podcast_feed"

module Podify
  VERSION = "0.1.0"


  feed_id = "a8de99afbb724950ab9107d739bad7be"
  data_source = ListenNotesApi::Client.new

  feed = PodcastFeed.new(feed_id, data_source)

  # feed.episodes.each do |episode|

  track = feed.episodes.last.tracks[2]
  feed.episodes.last.tracks.each do |track|
      spotify_track = Spotify::Track.find(track)

      next if spotify_track.nil?

      puts "Found #{spotify_track.link}"

      # command = "open #{spotify_track.link}"
      # Process.run(command, shell: true)

      # playlist = spotify.create_playlist(episode.title)
      # playlist.add(spotify_track)
    end
  # end
end
