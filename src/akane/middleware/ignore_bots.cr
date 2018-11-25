module Akane
  class IgnoreBots
    def call(payload : Discord::Message, _ctx : Discord::Context)
      return if payload.author.bot

      yield
    end
  end
end
