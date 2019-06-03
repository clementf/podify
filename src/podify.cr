require "dotenv"
Dotenv.load

require "logger"

require "./podify/podcast_feed"
require "./podify/spotify/track"
require "./podify/spotify/tracks_from_playlist"
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

    episodes.each do |episode|
      loop do
       puts "Do you want to add tracks for episode \"#{episode.title}\"? (y/n/q)"

        a = gets

        case a
        when "y"
          handle_episode(episode)
          break
        when "n"
          break
        when "q"
          exit(1)
        end
      end
    end
  end

  def self.handle_episode(episode)
    channel = Channel(Spotify::Track | Nil).new
    spotify_tracks = [] of Spotify::Track | Nil

    episode.tracks.each do |track|
      spawn do
        spotify_track = Spotify::Track.find(track)

        channel.send(spotify_track)
      end
    end

    episode.tracks.size.times { spotify_tracks << channel.receive }

    playlist = Spotify::Playlist.find_podify_playlist

    return unless playlist

    tracks_in_playlist = Spotify::Tracks.new(playlist.id)

    track = spotify_tracks.compact.each do |track|
      return unless track
      return if tracks_in_playlist.to_a.any? { |t| track.id == t.id }

      playlist.add(track)
    end
  end

  def self.logger
    @@logger ||= Logger.new(STDOUT, level: Logger::DEBUG)
  end
end
