require "discordcr-middleware/middleware/cached_routes"

module Akane
  module Middleware
    class TextChannel
      include DiscordMiddleware::CachedRoutes

      property channel : Discord::Channel?

      def call(payload, ctx : Discord::Context)
        client = ctx[Discord::Client]
        @channel = get_channel(client, payload.channel_id)

        return unless @channel.as(Discord::Channel).type.guild_text?

        yield
      end
    end
  end
end
