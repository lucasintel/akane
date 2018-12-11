module Akane
  module Stats
    include Cog

    struct Message
      ::DB.mapping(
        user_id: Int64,
        content: String,
        timestamp: Time
      )

      def self.first(guild_id, user_id)
        DB::PG.connection do |pg|
          from_rs(pg.query(DB.msg_get_first, guild_id, user_id))
        end
      end
    end

    @[Command(
      name: "stats",
      description: "",
      hidden: true
    )]
    def stats(client, payload, args)
      puts Akane::Command.list
    end

    @[SubCommand("stats", "--first-message", "(mention)")]
    def first_message(client, payload, args)
      return "No mention found." unless mention = Discord::Mention.parse(args).first?

      cache = client.cache.as(Discord::Cache)
      user = cache.resolve_user mention.as(Discord::Mention::User).id

      return "IGO" unless guild = payload.guild_id
      return "No message found" unless msg = Message.first(guild, user.id).first?

      Discord::Embed.new(
        author: Discord::EmbedAuthor.new(
          name: "#{user.username}##{user.discriminator}",
          icon_url: user.avatar_url
        ),
        description: msg.content,
        colour: 6844039_u32,
        timestamp: msg.timestamp
      )
    end
  end
end
