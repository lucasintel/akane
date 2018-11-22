-- +migrate up
create table man_pages (
  id int generated by default as identity primary key,
  name text not null,
  description text,
  url text not null,
  created_at timestamptz default now() not null
);

create unique index uix_man_pages_name on man_pages(name);

-- +migrate down
drop table man_pages;