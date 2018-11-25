-- +migrate up
create type vote as enum ('upvote', 'test');

alter table votes
  alter column "type" type vote using type::vote;

-- +migrate down
alter table votes
  alter column "type" type text;

drop type vote;
