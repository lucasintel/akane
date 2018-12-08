-- name: insert_dispatch(name : String)

insert into packets(name)
     values ({{name}})
         on conflict(name)
         do
     update
        set times = packets.times + 1;
