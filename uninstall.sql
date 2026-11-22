-- =============================================================
-- CanchaYa Pasto - remove every object (DESTROYS ALL DATA)
--   psql "<connection>" -f uninstall.sql
-- =============================================================

\set ON_ERROR_STOP on

BEGIN;
DROP VIEW     IF EXISTS v_field_daily_occupancy, v_owner_monthly_income, v_reservation_detail;
DROP FUNCTION IF EXISTS fn_available_slots(BIGINT, DATE);
DROP TABLE    IF EXISTS payments, reservations, schedules, fields, users CASCADE;
DROP FUNCTION IF EXISTS fn_apply_payment();
DROP FUNCTION IF EXISTS fn_check_reservation_schedule();
COMMIT;
