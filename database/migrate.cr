require "pg"
require "migrate"

migrator = Migrate::Migrator.new(
  db: DB.open(ENV["DB_URL"]),
  logger: Logger.new(STDOUT),
  dir: File.join("database", "migrations")
)

migrator.to_latest
