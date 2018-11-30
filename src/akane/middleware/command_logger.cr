module Akane
  class CommandLogger
    def call(payload : Discord::Message, ctx : Discord::Context)
      command = ctx[CommandParser].command.as(Akane::Command)
      args = ctx[ArgumentParser].args.as(String)

      DB.insert_command_use(command.name, args, payload)

      yield
    end
  end
end
