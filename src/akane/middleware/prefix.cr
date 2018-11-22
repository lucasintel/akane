module Akane
  PREFIX = /!a |<@#{ENV["CLIENT_ID"]}> /

  module Middleware
    class Prefix
      def call(payload : Discord::Message, _ctx : Discord::Context)
        return unless payload.content.starts_with?(PREFIX)

        yield
      end
    end
  end
end
