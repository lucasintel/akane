-- name: insert_tldr(name, description, url)

insert into man_pages (name, description, url)
     values (
       {{name}},
       {{description}},
       {{url}}
    );

-- name: find_man(name)

select description, url
  from man_pages
 where name = {{name}}
 limit 1;
