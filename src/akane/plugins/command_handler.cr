module Akane
  class Command
    getter name : String
    getter description : String
    getter hidden : Bool
    getter usage : String
    getter args : Range(Int32, Int32)
    getter handle : Handle

    property subcommands = [] of String

    class_getter list = {} of String => Command

    alias Return = Discord::Message | String | Discord::Embed | Nil
    alias Handle = Proc(Discord::Client, Discord::Message, String, Return)

    def initialize(@name, @description = "", @usage = "", @hidden = false, &@handle : Handle)
      case @usage
      when .includes?("codeblock"),
           .includes?("...")
        @args = 0..5000
      else
        arr = @usage.split
        min = arr.reject(&.includes?("?"))
        @args = (min.size)..(arr.size)
      end

      Command[@name] = self
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
              hidden:      \{{ann[:hidden]}} || false
            ) do |client, payload, args|

            \{{method.name}}(client, payload, args)
          end

          .subcommands << "--help"

          Akane::Command.new(
              name: "#{\{{ann[:name]}}} --help",
              hidden: true
            ) do |client, payload, command|

            command_help(client, payload, \{{ann[:name]}})
          end
        \{% end %}

        \{% if ann = method.annotation(SubCommand) %}
          raise "Undefined command" unless command = Akane::Command[\{{ann[0]}}]

          command.subcommands << "#{\{{ann[1]}}} #{\{{ann[2]}}}"

          Akane::Command.new(
              name: "#{\{{ann[0]}}} #{\{{ann[1]}}}",
              usage: "#{\{{ann[2]}}}",
              hidden: true
            ) do |client, payload, args|

           \{{method.name}}(client, payload, args)
          end
        \{% end %}
      end

      def command_help(client, payload, command)
        cmd = Akane::Command[command].as(Akane::Command)

        Discord::Embed.new(
          title: "#{cmd.name} #{cmd.usage}",
          description: String.build do |s|
            s << cmd.description << "\n"
            s << "\n"

            cmd.subcommands.each do |cmd|
              s << "**" << cmd << "** " << Akane::Command[cmd].try(&.usage) << "\n"
            end
          end,
          colour: 6844039_u32,
          footer: Discord::EmbedFooter.new(
            text: "The number of args must match the range #{cmd.args.to_s}."
          )
        )
      end
    end
  end

  @[Discord::Plugin::Options(middleware: {
    IgnoreBots.new,
    Limiter.new(:commands),
    Prefix.new,
    CommandParser.new(/^\w+(?:\s--\w+)?/),
    ArgumentParser.new,
    CommandLogger.new
  })]
  class CommandHandler
    include Discord::Plugin

    @[Discord::Handler(event: :message_create)]
    def handle(payload : Discord::Message, ctx : Discord::Context)
      command = ctx[CommandParser].command.as(Akane::Command)
      args = ctx[ArgumentParser].args.as(String)

      case res = command.handle.call(client, payload, args)
      when String
        client.create_message(payload.channel_id, res)
      when Discord::Embed
        client.create_message(payload.channel_id, "", res)
      end
    end
  end
end
