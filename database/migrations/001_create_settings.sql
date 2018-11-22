-- +migrate up
create type visibility as enum ('private', 'public');
create type tag as enum ('everyone', 'admin');

create table users (
  id bigint primary key,
  visibility visibility default 'private' not null,
  slug text,
  added_at timestamptz default now() not null
);

create unique index uix_users_slug on users(slug);

create table guilds (
  id bigint primary key,
  visibility visibility default 'public' not null,
  tags tag default 'everyone' not null,
  slug text,
  added_at timestamptz default now() not null
);

create unique index uix_guilds_slug on guilds(slug);

-- +migrate down
drop table users;
drop table guilds;
drop type visibility;
drop type tag;
