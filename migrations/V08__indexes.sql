-- =============================================================
-- V08 - Indexes for the queries the API runs most often
-- (primary keys and UNIQUE constraints already have their own index)
-- =============================================================

-- Owner dashboard: "my fields"
CREATE INDEX ix_fields_owner           ON fields (owner_id);

-- Public catalogue: only active fields, sorted by name
CREATE INDEX ix_fields_active_name     ON fields (name) WHERE active;

-- Availability of a field on a date (also used by the overlap check)
CREATE INDEX ix_reservations_field_date ON reservations (field_id, date);

-- "My reservations", newest first
CREATE INDEX ix_reservations_player    ON reservations (player_id, date DESC, start_hour DESC);

-- Payments of a reservation
CREATE INDEX ix_payments_reservation   ON payments (reservation_id);
