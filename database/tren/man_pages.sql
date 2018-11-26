-- name: insert_tldr(name, description, url)

insert into man_pages (name, description, url)
     values (
       {{name}},
       {{description}},
       {{url}}
    );

-- name: find_man

select name, description, url
  from man_pages
 where name = $1
 limit 1;
