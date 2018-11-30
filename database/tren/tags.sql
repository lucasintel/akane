-- name: insert_tag(guild_id : Discord::Snowflake, user_id : Discord::Snowflake, name : String, content : String, attachment : String?)

insert into tags (guild_id, user_id, name, content, attachment)
     values (
       {{guild_id}},
       {{user_id}},
       {{name}},
       {{content}},
       {{attachment}}
     );

-- name: insert_tag_use(user_id : Discord::Snowflake, tag_id : Int32)

insert into tag_uses (user_id, tag_id)
     values (
       {{user_id}},
       {{tag_id}}
     );

-- name: delete_tag(guild_id : Discord::Snowflake, name : String)

delete from tags
      where guild_id = {{guild_id}}
        and name = {{name}};

-- name: find_tag

select *
  from tags
 where guild_id = $1
   and name = $2
 limit 1;

-- name: tag_exists

select 1
  from tags
 where guild_id = $1
   and name = $2
 limit 1;
