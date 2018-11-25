-- name: insert_msg(msg : Discord::Message)

insert into messages (id, guild_id, channel_id, user_id, tts, mention_everyone, embeds, content, "timestamp")
     values (
       {{msg.id}},
       {{msg.guild_id}},
       {{msg.channel_id}},
       {{msg.author.id}},
       {{msg.tts}},
       {{msg.mention_everyone}},
       {{msg.embeds.to_json}},
       {{msg.content || ""}},
       {{msg.timestamp}}
     );

-- name: update_msg(msg : Discord::Gateway::MessageUpdatePayload)

update messages
   set content = {{msg.content || ""}}, edited = true
 where id = {{msg.id}};

-- name: delete_msg(id : Discord::Snowflake)

delete from messages where id = {{id}};

-- name: insert_attach(mid : Discord::Snowflake, attach : Discord::Attachment)

insert into attachments (id, message_id, extension, size)
     values (
       {{attach.id}},
       {{mid}},
       {{File.extname(attach.filename)}},
       {{attach.size}}
     );

-- name: insert_mention(mid : Discord::Snowflake, m_type : String, m_id : Discord::Snowflake | UInt64)

insert into mentions (message_id, mentioned_type, mentioned_id)
     values ({{mid}}, {{m_type}}, {{m_id}});
