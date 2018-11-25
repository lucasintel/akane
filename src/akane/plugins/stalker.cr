module Akane
  @[Discord::Plugin::Options(middleware: TextChannel.new)]
  class MessageStalker
    include Discord::Plugin

    @[Discord::Handler(event: :message_reaction_add)]
    def reaction_add(payload, _ctx)
      DB.insert_reaction(payload)
    end

    @[Discord::Handler(event: :message_reaction_remove)]
    def reaction_remove(payload, _ctx)
      DB.delete_reaction(payload)
    end

    @[Discord::Handler(event: :message_reaction_remove_all)]
    def reaction_remove_all(payload, _ctx)
      DB.delete_all_reactions(payload.message_id)
    end

    @[Discord::Handler(event: :message_create)]
    def message_create(payload, ctx)
      channel = ctx[Middleware::TextChannel].channel.as(Discord::Channel)
      guild = channel.guild_id.as(Discord::Snowflake)

      DB.insert_msg(payload, guild)

      if md = payload.content.match(/<#(?<channel_id>\d+)>/)
        DB.insert_mention(payload.id, "channel", md["channel_id"].to_u64)
      end

      payload.mentions.each { |user| DB.insert_mention(payload.id, "user", user.id) }
      payload.mention_roles.each { |role| DB.insert_mention(payload.id, "role", role) }
      payload.attachments.each { |att| DB.insert_attach(payload.id, att) }
    end

    @[Discord::Handler(event: :message_update)]
    def message_update(payload, _ctx)
      DB.update_msg(payload)
    end

    @[Discord::Handler(event: :message_delete)]
    def message_delete(payload, _ctx)
      DB.delete_msg(payload.id)
    end
  end
end
