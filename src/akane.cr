require "discordcr"
require "discordcr-plugin"
require "discordcr-dbl"
require "redis"

require "./akane/*"
require "./akane/middleware/*"
require "./akane/plugins/*"
require "./akane/cogs/*"

REDIS = Redis.new(unixsocket: "/var/run/redis/redis.sock")
START = Time.now

module Akane
  class Shard
    getter client : Discord::Client
    getter id : Int32
    getter ready : Bool?

    delegate run, to: client

    def initialize(cache, shard_id, shards)
      @client = Discord::Client.new(
        token: ENV["TOKEN"],
        client_id: ENV["CLIENT_ID"].to_u64,
        shard: { shard_id: shard_id, num_shards: shards }
      )

      @id = shard_id

      @client.cache = cache
      @client.on_ready { @ready = true }

      register_plugins
    end

    def register_plugins
      Discord::Plugin.plugins.each do |plugin|
        client.register(plugin)
      end
    end
  end

  class_property num_shards = 1
  class_property shards = [] of Shard

  def self.shard(guild_id : UInt64 | Discord::Snowflake | Nil = nil)
    return @@shards.first unless guild_id

    shard_id = (guild_id.to_u64 >> 22) % @@num_shards
    @@shards[shard_id]
  end

  def self.register_dbl(cache)
    dbl_client = Dbl::Client.new(ENV["DBL_TOKEN"], cache)
    dbl_client.start

    dbl = Dbl::Server.new(ENV["DBL_PASS"])

    dbl.on_vote do |payload|
      DB.insert_vote(payload)
    end
  end

  def self.run
    rest_client = Discord::Client.new(ENV["TOKEN"], ENV["CLIENT_ID"].to_u64)
    cache = Discord::Cache.new(rest_client)

    shards = @@num_shards = rest_client.get_gateway_bot.shards

    shards.times do |shard_id|
      shard = Shard.new(cache, shard_id, shards)
      @@shards << shard
      spawn { shard.run }
    end

    register_dbl(cache)
  end
end
