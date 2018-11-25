require "discordcr"
require "discordcr-plugin"
require "discordcr-dbl"
require "redis"

require "./akane/*"
require "./akane/middleware/*"
require "./akane/plugins/*"
require "./akane/cogs/*"

START = Time.now

module Akane
  client = Discord::Client.new(ENV["TOKEN"], ENV["CLIENT_ID"].to_u64)
  cache = Discord::Cache.new(client)
  client.cache = cache

  REDIS = Redis.new(unixsocket: "/var/run/redis/redis.sock")

  dbl_client = Dbl::Client.new(ENV["DBL_TOKEN"], client)
  dbl = Dbl::Server.new(ENV["DBL_PASS"])

  dbl.on_vote do |payload|
    DB.insert_vote(payload)
  end

  Discord::Plugin.plugins.each do |plugin|
    client.register(plugin)
  end

  client.run
end
