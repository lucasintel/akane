require "pg"
require "tren"

module Akane
  module DB
    extend self

    delegate query, query_one?, to: PG

    PG = ::DB.open(ENV["DB_URL"])

    Tren.load("database/tren/*.sql")
  end
end
