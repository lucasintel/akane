-- +migrate up
create table packets (
  name text primary key,
  times bigint default 1 not null
);

insert into packets (name, times)
     select name, count(*) as times
       from dispatches
      group by name;

drop table dispatches;

-- +migrate down
drop table packets;

create table dispatches (
  name text not null,
  "timestamp" timestamptz default now() not null
);

create index ix_dispatches_timestamp on dispatches("timestamp");
