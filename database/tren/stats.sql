-- name: msg_get_first

select user_id, content, "timestamp"
  from messages
 where guild_id = $1
   and user_id = $2
 order by "timestamp"
 limit 1;
