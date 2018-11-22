-- name: insert_tag(tag)

insert into tags (guild_id, user_id, name, content)
     values (
       {{tag.guild_id}},
       {{tag.user_id}},
       {{tag.name}},
       {{tag.content}}
    );

-- name: delete_tag(guild_id : Discord::Snowflake, name : String)

delete from tags
      where guild_id = {{guild_id}}
        and name = {{name}};
