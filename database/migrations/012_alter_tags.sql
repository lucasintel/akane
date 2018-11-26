-- +migrate up
alter table tags
  add column attachment text,
  alter column guild_id set not null,
  alter column user_id set not null;

-- +migrate down
alter table tags
  drop column attachment,
  alter column guild_id drop not null,
  alter column user_id drop not null;
