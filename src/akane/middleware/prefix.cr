module Akane
  PREFIX = /!a |ak |<@#{ENV["CLIENT_ID"]}> /

  class Prefix
    def call(payload : Discord::Message, _ctx : Discord::Context)
      return unless payload.content.starts_with?(PREFIX)

      yield
    end
  end
end
