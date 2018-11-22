-- +migrate up
create type mention as enum('user', 'role', 'channel');

create table mentions (
  message_id bigint references messages on delete cascade,
  mentioned_type mention not null,
  mentioned_id bigint not null
);

create index ix_mentions_message on mentions(message_id);
create index ix_mentions_mentioned on mentions(mentioned_type, mentioned_id);

-- +migrate down
drop table mentions;
drop type mention;
