-- +migrate up
create table messages (
  id bigint primary key,
  guild_id bigint not null,
  channel_id bigint not null,
  user_id bigint not null,
  tts bool not null,
  mention_everyone bool not null,
  embeds json,
  content text default '' not null,
  keypresses integer default 0 not null,
  edited boolean default false not null,
  "timestamp" timestamptz not null
);

create index ix_messages_channel on messages(channel_id);
create index ix_messages_guild on messages(guild_id);
create index ix_messages_user on messages(user_id);
create index ix_messages_timestamp on messages("timestamp");

-- +migrate start
create function messages_set_keypresses() returns trigger as $$
  begin
    new.keypresses := length(new.content);
    return new;
  end;
$$ language plpgsql;
-- +migrate end;

create trigger messages_before_update_content
  before insert or update of content on messages
  for each row
  execute procedure messages_set_keypresses();

-- +migrate down
drop table messages;
drop function messages_set_keypresses;
