require "option_parser"

require "pg"
require "migrate"

class Migrater
  def initialize
    @migrator = Migrate::Migrator.new(
      dir: File.join("database", "migrations"),
      db: DB.open(ENV["DB_URL"]),
      logger: Logger.new(STDOUT)
    )
  end

  def parse_argv
    command = ""
    version = ""

    OptionParser.parse! do |parser|
      parser.banner = "Usage: bin/migrate [flags]"

      parser.on("-h", "--help", "Show this help") { puts parser }
      parser.on("-c", "--current", "Show current version") { command = "version" }
      parser.on("-l", "--latest", "Migrate to latest version") { command = "latest" }
      parser.on("-t version", "--to version", "Migrate to version") { |ver| command, version = "to", ver }
      parser.on("-d", "--down", "Migrate down") { command = "down" }
      parser.on("-u", "--up", "Migrate up") { command = "up" }

      parser.missing_option do |flag|
        STDERR.puts "ERROR: Missing required options for #{flag}."
        exit(1)
      end

      parser.invalid_option do |flag|
        STDERR.puts "ERROR: #{flag} is not a valid option."
        STDERR.puts parser
        exit(1)
      end
    end

    {command, version}
  end

  def run
    command, version = parse_argv

    case command
    when "latest"
      @migrator.to_latest
    when "up"
      @migrator.up
    when "down"
      @migrator.down
    when "version"
      puts "Current version: #{@migrator.current_version}."
    when "to"
      if v = version.to_i?
        @migrator.to(v)
      else
        puts "Version must be an integer."
        exit(1)
      end
    end
  end
end

migrater = Migrater.new
migrater.run
