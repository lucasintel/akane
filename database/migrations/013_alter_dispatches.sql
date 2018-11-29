-- +migrate up
alter table dispatches set (
  autovacuum_enabled = true,
  toast.autovacuum_enabled = true
);

-- +migrate down
alter table dispatches set (
  autovacuum_enabled = false,
  toast.autovacuum_enabled = false
);
