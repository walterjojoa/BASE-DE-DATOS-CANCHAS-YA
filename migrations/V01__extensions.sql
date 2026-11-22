-- =============================================================
-- V01 - Extensions
-- btree_gist lets us combine "=" (field, date) and "&&" (hour range)
-- in one exclusion constraint, so the database itself forbids
-- overlapping reservations (see V07).
-- Available on Neon, Render and any standard PostgreSQL >= 12.
-- =============================================================

CREATE EXTENSION IF NOT EXISTS btree_gist;
