module Akane
  class ArgumentParser
    getter args : String?

    def initialize(@verbose : Bool = true)
    end

    private def format(args)
      case args
      when .== 1 then "one argument"
      when .== 2 then "two arguments"
      when .== 3 then "three arguments"
      when .== 4 then "four arguments"
      else "#{args} arguments"
      end
    end

    def call(payload : Discord::Message, ctx : Discord::Context)
      command = ctx[CommandParser].command.as(Akane::Command)
      message = ctx[CommandParser].message.as(String)

      @args = message.sub(command.name, "").lstrip

      args_size = @args.as(String).split.size

      unless command.args === args_size
        min_args = command.args.begin
        max_args = command.args.end

        client = ctx[Discord::Client]

        case args_size
        when .< min_args
          err_msg = "This command requires at least #{format(min_args)}."
        when .> max_args
          if min_args == 0 && max_args == 0
            err_msg = "This command takes no arguments."
          else
            err_msg = "This command takes no more then #{format(min_args)}."
          end
        end

        if err_msg && @verbose
          client.create_message(payload.channel_id, err_msg)
        end

        return
      end

      yield
    end
  end
end
