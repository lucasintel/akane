-- +migrate up
create table dispatches (
  name text not null,
  "timestamp" timestamptz default now() not null
);

create index ix_dispatches_timestamp on dispatches("timestamp");

alter table dispatches set (
  autovacuum_enabled = false,
  toast.autovacuum_enabled = false
);

-- +migrate down
drop table dispatches;
