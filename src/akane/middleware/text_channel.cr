module Akane
  class TextChannel
    def call(payload, _ctx : Discord::Context)
      return unless payload.guild_id

      yield
    end
  end
end
