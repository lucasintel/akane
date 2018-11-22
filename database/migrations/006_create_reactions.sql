-- +migrate up
create table reactions (
  message_id bigint references messages on delete cascade,
  user_id bigint not null,
  reaction_id bigint,
  reaction text not null
);

create index ix_reactions_message on reactions(message_id);
create index ix_reactions_reaction on reactions(reaction);

-- +migrate down
drop table reactions;
