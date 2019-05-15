require "./podify/podcast_feed"
require "./podify/spotify"
require "./podify/data_source/listen_notes_api"
require "./podify/podcast_feed"

module Podify
  VERSION = "0.1.0"

  feed_id = "a8de99afbb724950ab9107d739bad7be"
  spotify = Spotify::Api.new
  data_source = ListenNotesApi.new

  feed = PodcastFeed.new(feed_id, data_source)
  episode= feed.episodes.first

  episode.tracks.each do |track|
    puts track
    spotify_track = spotify.find_track(track)
    playlist = spotify.create_playlist(episode.name)
    playlist.add(spotify_track)
  end
end
