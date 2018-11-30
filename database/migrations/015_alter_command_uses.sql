-- +migrate up
alter table command_uses
  alter column args set not null,
  alter column args set default '';

-- +migrate down
alter table command_uses
  alter column args drop default,
  alter column args drop not null;
