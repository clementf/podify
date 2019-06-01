require "dotenv"
Dotenv.load

require "./podify/podcast_feed"
require "./podify/spotify/track"
require "./podify/spotify/api"
require "./podify/data_source/listen_notes_api/client"
require "./podify/podcast_feed"

require "./podify/cli/cli"

module Podify
  VERSION = "0.1.0"

  Cli.run

  def self.start(feed_id)
    data_source = ListenNotesApi::Client.new
    episodes = PodcastFeed.new(feed_id, data_source).episodes

    # call client to authenticate before spawning a fiber for each track
    Spotify::Api.client

    channel = Channel(Spotify::Track | Nil).new
    spotify_tracks = [] of Spotify::Track | Nil

    episodes.last.tracks.each do |track|
      spawn do
        spotify_track = Spotify::Track.find(track)

        channel.send(spotify_track)
      end
    end

    episodes.last.tracks.size.times { spotify_tracks << channel.receive }

    playlist = Spotify::Playlist.find_podify_playlist

    track = spotify_tracks.compact.each do |track|
      playlist.add(track) unless (playlist.nil? || track.nil?)
    end
  end
end
