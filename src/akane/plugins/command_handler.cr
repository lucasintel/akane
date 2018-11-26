module Akane
  class Command
    getter name : String
    getter description : String
    getter hidden : Bool
    getter usage : String
    getter limiter : UInt8?
    getter args : Range(Int32, Int32)
    getter handle : Handle

    property subcommands = [] of String

    class_getter list = {} of String => Command

    alias Handle = Discord::Client, Discord::Message, String -> Nil

    def initialize( @name,
                    @description = "",
                    @usage = "",
                    @hidden = false,
                    @limiter = nil,
                    &@handle : Handle )

      case @usage
      when "(codeblock)", "..."
        @args = 0..5000
      else
        arr = @usage.split
        min = arr.reject(&.includes?("?"))
        @args = (min.size)..(arr.size)
      end

      Command[@name] = self
    end

    def sub_help : Array(String)
      @subcommands.map do |cmd|
        "**#{cmd}** #{Command[cmd].try(&.usage)}"
      end
    end

    def self.[]=(k : String, v : Command)
      @@list[k] = v
    end

    def self.[](k)
      @@list[k] if @@list.has_key?(k)
    end
  end

  module Cog
    macro included
      annotation Command
      end

      annotation SubCommand
      end

      extend self

      macro method_added(method)
        \{% if ann = method.annotation(Command) %}
          Akane::Command.new(
              name:        \{{ann[:name]}},
              description: \{{ann[:description]}},
              usage:       \{{ann[:usage]}} || "",
              hidden:      \{{ann[:hidden]}} || false,
              limiter:     \{{ann[:limiter]}}
            ) do |client, payload, args|

            \{{method.name}}(client, payload, args)
          end

          command = Akane::Command[\{{ann[:name]}}].as(Akane::Command)
          command.subcommands << "--help"

          Akane::Command.new(
              name: "#{\{{ann[:name]}}} --help",
              hidden: true
            ) do |client, payload, command|

            command_help(client, payload, \{{ann[:name]}})
          end
        \{% end %}

        \{% if ann = method.annotation(SubCommand) %}
          raise "Undefined command" unless command = Akane::Command[\{{ann[0]}}]
          command.subcommands << \{{ann[1]}}

          Akane::Command.new(
              name: "#{\{{ann[0]}}} #{\{{ann[1]}}}",
              usage: \{{ann[2]}} || "",
              hidden: true
            ) do |client, payload, args|

           \{{method.name}}(client, payload, args)
          end
        \{% end %}
      end

      def command_help(client, payload, command)
        cmd = Akane::Command[command].as(Akane::Command)

        embed = Discord::Embed.new(
          title: "#{cmd.name} #{cmd.usage}",
          description: String.build do |s|
            s << cmd.description << "\n"
            s << "\n"
            s << cmd.sub_help.join("\n")
          end,
          colour: 6844039_u32,
          footer: Discord::EmbedFooter.new(
            text: "The number of args must match the range #{cmd.args.to_s}."
          )
        )

        client.create_message(payload.channel_id, "", embed)
      end
    end
  end

  @[Discord::Plugin::Options(middleware: {Prefix.new, IgnoreBots.new})]
  class CommandHandler
    include Discord::Plugin

    alias Snowflake = Discord::Snowflake | UInt64

    def rate_limited?(id : Snowflake, namespace = "commands", max = 5_u8)
      query = "rate:#{id}:#{namespace}:#{Time.now.minute}"

      if limiter = REDIS.get(query)
        return false if limiter.to_u8 >= max
      end

      REDIS.multi do |multi|
        multi.incr(query)
        multi.expire(query, 59)
      end
    end

    @[Discord::Handler(event: :message_create)]
    def handle(payload : Discord::Message, ctx : Discord::Context)
      message = payload.content.sub(PREFIX, "")
      return unless cmd = message.match(/^\w+(?:\s--\w+)?/).try(&.[0])

      args = message.sub(cmd, "")

      return unless command = Command[cmd]
      return unless command.args === args.split.size

      if limiter = command.limiter
        return unless rate_limited?(payload.author.id, cmd, limiter)
      else
        return unless rate_limited?(payload.author.id)
      end

      command.handle.call(client, payload, args.lstrip)
    end
  end
end
