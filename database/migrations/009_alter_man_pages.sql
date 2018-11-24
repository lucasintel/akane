-- +migrate up
alter table man_pages
  add column content text,
  add column platform text not null;

drop index uix_man_pages_name;

create unique index uix_man_pages_name_platform on man_pages(name, platform)

-- +migrate down
alter table man_pages
  drop column content,
  drop column platform;
