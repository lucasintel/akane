-- name: insert_command_use(command : String, args : String, payload : Discord::Message)

insert into command_uses (command, args, user_id, message_id)
     values (
       {{command}},
       {{args}},
       {{payload.author.id}},
       {{payload.id}}
     );
