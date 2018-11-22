require "hardware"
require "humanize_time"

module Akane
  module Util
    include Cog

    @[Command(
      name: "ping",
      description: "Probably the most useless command"
    )]
    def ping(client, payload, args)
      await = client.create_message(payload.channel_id, "Pong!")
      time = Time.now - payload.timestamp

      client.edit_message(await.channel_id, await.id, "Pong! #{time.milliseconds} ms.")
    end

    private def gcf(bytes)
      (bytes/1024.0/1024.0).round(2)
    end

    private def rf(attr, value)
      return unless md = attr.match(/\d+/)
      md[0].to_u32/value
    end

    private def description(cache)
      pid = Hardware::PID.new
      info = REDIS.info

      String.build do |s|
        s << "Akane is a cute bot (totally not a NSA agent) that spy on guilds, showing
              a myriad of stats about guilds and users. In addition, there's a lot of
              commands related to programming, science, anime and novel.".strip
        s << "\n\n"
        s << "**[Web interface](https://madokami.pw/)** (WIP)\n"
        s << "**[Let me join your guild!](" << ENV["INVITE_URL"] << ")**\n"
        s << "**[Github](https://github.com/kandayo/akane)**\n"
        s << "\n"
        s << "```ini\n"
        s << "[ Redis Stats ]\n"
        s << "used_memory   => " << info["used_memory_human"] << "\n"
        s << "keyspace_hits => " << info["keyspace_hits"]     << "\n"
        s << "\n"
        s << "[ Cache ]\n"
        s << "users    => " << cache.users.size    << "\n"
        s << "roles    => " << cache.roles.size    << "\n"
        s << "guilds   => " << cache.guilds.size   << "\n"
        s << "channels => " << cache.channels.size << "\n"
        s << "\n"
        s << "[ Memory Stats ]\n"
        s << "VmPeak => " << rf(pid.status["VmPeak"], 4000.0) << " MB\n"
        s << "VmSize => " << rf(pid.status["VmSize"], 4000.0) << " MB\n"
        s << "VmHWM  => " << rf(pid.status["VmHWM"], 1000.0)  << " MB\n"
        s << "VmRSS  => " << rf(pid.status["VmRSS"], 1000.0)  << " MB\n"
        s << "\n"
        s << "[ GC Stats ]\n"
        s << "heap_size      => " << gcf(GC.stats.heap_size)      << " MB\n"
        s << "free_bytes     => " << gcf(GC.stats.free_bytes)     << " MB\n"
        s << "unmaped_bytes  => " << gcf(GC.stats.unmapped_bytes) << " MB\n"
        s << "bytes_since_gc => " << gcf(GC.stats.bytes_since_gc) << " MB\n"
        s << "total_bytes    => " << gcf(GC.stats.total_bytes)    << " MB\n"
        s << "```"
      end
    end

    @[Command(
      name: "info",
      description: "Show stats about the bot"
    )]
    def info(client, payload, args)
      cache = client.cache.as(Discord::Cache)

      embed = Discord::Embed.new(
        thumbnail: Discord::EmbedThumbnail.new(url: cache.resolve_current_user.avatar_url),
        footer: Discord::EmbedFooter.new(text: "Use \"!a help\" for info on commands"),
        title: "朱音",
        description: description(cache),
        colour: 6844039_u32
      )

      client.create_message(payload.channel_id, "", embed)
    end

    @[Command(
      name: "uptime",
      description: "Shows the bot's uptime"
    )]
    def uptime(client, payload, args)
      embed = Discord::Embed.new(
        title: "Uptime",
        description: HumanizeTime.distance_of_time_in_words(START, Time.now)
      )

      client.create_message(payload.channel_id, "", embed)
    end

    @[Command(
      name: "invite",
      description: "Let me join your guild!",
      limiter: 1_u8
    )]
    def invite(client, payload, args)
      client.create_message(payload.channel_id, ENV["INVITE_URL"])
    end
  end
end
