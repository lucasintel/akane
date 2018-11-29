require "hardware"
require "humanize_time"
require "terminal_table"

module Akane
  module Meta
    include Cog

    @[Command(
      name: "ping",
      description: "Probably the most useless command",
      hidden: true
    )]
    def ping(client, payload, args)
      await = client.create_message(payload.channel_id, "Pong!")
      time = Time.now - payload.timestamp

      client.edit_message(await.channel_id, await.id, "Pong! #{time.milliseconds} ms.")
    end

    @[Command(
      name: "help",
      description: "Probably the most useful command",
      hidden: true
    )]
    def help(client, payload, args)
      commands = Akane::Command.list.each_value.reject(&.hidden)

      embed = Discord::Embed.new(
        title: "Commands",
        colour: 6844039_u32,
        description: String.build do |s|
          commands.each do |cmd|
            s << "**!a " << cmd.name << "** ~ " << cmd.description << "\n"
          end
        end,
        footer: Discord::EmbedFooter.new(
          text: "For more info on a command, use \"!a (cmd) --help\"."
        )
      )

      client.create_message(payload.channel_id, "", embed)
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

      String.build do |s|
        s << "Akane is a cute bot (totally not a NSA agent) that spy on guilds, showing \
              a myriad of stats about guilds and users. In addition, there's a lot of \
              commands related to programming, science, anime and novel.\n"
        s << "\n"
        s << "**[Web interface](https://madokami.pw/)**\n"
        s << "**[Let me join your guild!](" << ENV["INVITE_URL"] << ")**\n"
        s << "**[Github](https://github.com/kandayo/akane)**\n"
        s << "\n"
        s << "**```ini\n"
        s << "[ Cache Stats ]\n"
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
        s << "bytes_since_gc => " << gcf(GC.stats.bytes_since_gc) << " MB\n"
        s << "total_bytes    => " << gcf(GC.stats.total_bytes)    << " MB\n"
        s << "```**"
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
      name: "shard",
      description: "Show shards information",
      hidden: true
    )]
    def shard_info(client, payload, args)
      table = TerminalTable.new
      table.headings = ["Shard", "Status", "Time"]

      current_shard = Akane.shard(payload.guild_id).id

      Akane.shards.each do |shard|
        table << [
          "gaia #{shard.id}#{"*" if shard.id == current_shard}",
          shard.ready ? "ready" : "...",
          shard.created_at.to_s
        ]
      end

      info = String.build do |s|
        s << "**```prolog\n"
        s << table.render << "\n"
        s << "```**"
      end

      client.create_message(payload.channel_id, info)
    end

    @[Command(
      name: "uptime",
      description: "Shows the bot's uptime",
      hidden: true
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
