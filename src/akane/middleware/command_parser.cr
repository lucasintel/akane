module Akane
  class CommandParser
    getter command : Akane::Command?
    getter message : String?

    def initialize(@command_regex : Regex)
    end

    def call(payload : Discord::Message, _ctx : Discord::Context)
      @message = payload.content.sub(PREFIX, "")

      return unless cmd = @message.as(String).match(@command_regex).try(&.[0])
      return unless @command = Command[cmd.downcase]

      LOG.debug("#{payload.author.id} executed command \"#{cmd}\"")

      yield
    end
  end
end
