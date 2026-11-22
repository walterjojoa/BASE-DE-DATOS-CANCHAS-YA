-- =============================================================
-- CanchaYa Pasto - full install
-- Creates the whole schema and (optionally) loads demo data.
--
--   psql "postgresql://user:pass@host/canchaya?sslmode=require" -f install.sql
--
-- Run it on an EMPTY database. To skip demo data, comment out the
-- "Demo data" block at the end.
-- =============================================================

\set ON_ERROR_STOP on
\echo '>> Creating schema'

BEGIN;
\ir migrations/V01__extensions.sql
\ir migrations/V02__create_users.sql
\ir migrations/V03__create_fields.sql
\ir migrations/V04__create_schedules.sql
\ir migrations/V05__create_reservations.sql
\ir migrations/V06__create_payments.sql
\ir migrations/V07__prevent_overlapping_reservations.sql
\ir migrations/V08__indexes.sql
\ir migrations/V09__one_approved_payment_per_reservation.sql
\ir migrations/V10__trigger_reservation_within_schedule.sql
\ir migrations/V11__trigger_confirm_on_approved_payment.sql
\ir migrations/V12__view_reservation_detail.sql
\ir migrations/V13__view_owner_monthly_income.sql
\ir migrations/V14__view_field_daily_occupancy.sql
\ir migrations/V15__function_available_slots.sql
\ir migrations/V16__fields_zone_and_reference.sql
COMMIT;

\echo '>> Loading demo data'
BEGIN;
\ir seeds/S01__demo_users.sql
\ir seeds/S02__pasto_fields.sql
\ir seeds/S03__pasto_schedules.sql
\ir seeds/S04__demo_reservations.sql
COMMIT;

\echo '>> Done'
SELECT 'users' AS table_name, count(*) FROM users
UNION ALL SELECT 'fields',       count(*) FROM fields
UNION ALL SELECT 'schedules',    count(*) FROM schedules
UNION ALL SELECT 'reservations', count(*) FROM reservations
UNION ALL SELECT 'payments',     count(*) FROM payments;
