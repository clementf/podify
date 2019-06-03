# podify

Podify connects to data sources (For now [Listen Notes API](https://listennotes.com/api/)), extracts metadata from podcast feeds and adds tracks it finds to a Spotify playlist.

## Prerequisites
Have [Crystal](https://crystal-lang.org) installed.
On mac: `brew install crystal`

## Installation

`shards`

## Usage

Compile with: `crystal build src/podify.cr`

Run with `./podify -f listen_notes_feed_id`

Get help and available options with `./podify -h`

## Todo


## Contributing

1. Fork it (<https://github.com/clementf/podify/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Clement Ferey](https://github.com/clementf) - creator and maintainer
