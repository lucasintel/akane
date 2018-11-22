-- name: insert_reaction(reaction : Discord::Gateway::MessageReactionPayload)

insert into reactions (message_id, user_id, reaction_id, reaction)
     values (
       {{reaction.message_id}},
       {{reaction.user_id}},
       {{reaction.emoji.id || 0}},
       {{reaction.emoji.name}}
     );

-- name: delete_reaction(reaction : Discord::Gateway::MessageReactionPayload)

delete from reactions
      where message_id = {{reaction.message_id}}
        and user_id = {{reaction.user_id}}
        and reaction = {{reaction.emoji.name}};

-- name: delete_all_reactions(mid : UInt64 | Discord::Snowflake)

delete from reactions
      where message_id = {{mid}};
