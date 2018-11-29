require "rate_limiter"

module Akane
  class_property limiter = RateLimiter(UInt64 | Discord::Snowflake).new
  @@limiter.bucket(:commands, 5_u32, 10.seconds)

  class Limiter
    def initialize(@bucket : Symbol, @message : String? = nil)
    end

    def call(payload : Discord::Message, ctx : Discord::Context)
      if Akane.limiter.rate_limited?(@bucket, payload.author.id)
        if msg = @message
          client = ctx[Discord::Client]
          client.create_message(payload.channel_id, msg)
        end

        LOG.debug("User #{payload.author.id}_#{payload.channel_id} rate limited.")

        return
      end

      yield
    end
  end
end
