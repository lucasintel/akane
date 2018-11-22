require "discordcr"
require "discordcr-plugin"
require "redis"

require "./akane/*"
require "./akane/middleware/*"
require "./akane/plugins/*"
require "./akane/cogs/*"

START = Time.now

module Akane
  client = Discord::Client.new(ENV["TOKEN"], ENV["CLIENT_ID"].to_u64)
  cache = Cache.new(client)
  client.cache = cache

  REDIS = Redis.new(unixsocket: "/var/run/redis/redis.sock")

  Discord::Plugin.plugins.each do |plugin|
    client.register(plugin)
  end

  client.run
end
