-- +migrate up
create table attachments (
  id bigint primary key,
  message_id bigint references messages on delete cascade,
  extension text not null,
  size integer not null
);

create index ix_attachments_message on attachments(message_id);

-- +migrate down
drop table attachments;
