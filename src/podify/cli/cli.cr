require "option_parser"

module Cli
  def self.run
    parse
  end

  private def self.parse
    OptionParser.parse! do |parser|
      parser.banner = "Usage: podify [arguments]"
      parser.on("-f FEED", "--feed_id=FEED", "Uses this Listen Notes feed_id as data source for for podcast episodes") { |feed_id| Podify.start(feed_id) }
      parser.on("-h", "--help", "Show this help") { puts parser }

      parser.invalid_option do |flag|
        STDERR.puts "ERROR: #{flag} is not a valid option."
        STDERR.puts parser
        exit(1)
      end
    end
  end
end
