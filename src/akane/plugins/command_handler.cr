module Akane
  struct Command
    getter name : String
    getter description : String
    getter hidden : Bool
    getter usage : String
    getter limiter : UInt8?
    getter args : Range(Int32, Int32)
    getter handle : Handle

    class_getter list = {} of String => Command

    alias Handle = Discord::Client, Discord::Message, Array(String) -> Nil

    def initialize( @name,
                    @description,
                    @hidden,
                    @usage,
                    @limiter,
                    &@handle : Handle )

      case @usage
      when "(codeblock)"
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

      extend self

      macro method_added(method)
        \{% if ann = method.annotation(Command) %}
          Akane::Command.new(
              \{{ann[:name]}},
              \{{ann[:description]}},
              \{{ann[:hidden]}} || false,
              \{{ann[:usage]}} || "",
              \{{ann[:limiter]}}
            ) do |client, payload, args|

            \{{method.name}}(client, payload, args)
          end
        \{% end %}
      end
    end
  end

  @[Discord::Plugin::Options(middleware: Middleware::Prefix.new)]
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
      message = payload.content.sub(PREFIX, "").split
      cmd, args = message.shift, message

      return unless command = Command[cmd]
      return unless command.args === args.size

      if limiter = command.limiter
        return unless rate_limited?(payload.author.id, cmd, limiter)
      else
        return unless rate_limited?(payload.author.id)
      end

      command.handle.call(client, payload, args)
    end
  end
end
