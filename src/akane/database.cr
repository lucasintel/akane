require "pg"
require "pool/connection"
require "tren"

module Akane
  module DB
    extend self

    PG = ConnectionPool.new(capacity: 99) do
      ::PG.connect(ENV["DB_URL"])
    end

    Tren.load("database/tren/*.sql")
  end
end
