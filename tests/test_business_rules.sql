-- =============================================================
-- Business-rule tests. Run AFTER install.sql (needs the demo data):
--
--   psql "<connection>" -f tests/test_business_rules.sql
--
-- Every test prints "OK ..." or stops with "TEST FAILED ...".
-- Everything runs inside a transaction that is rolled back at the
-- end, so the database is left untouched.
-- =============================================================

\set ON_ERROR_STOP on
BEGIN;

-- Helper: ids used by the tests
CREATE TEMP TABLE t AS
SELECT
    (SELECT id FROM fields WHERE name = 'Canchas Sintéticas Monumental')  AS monumental,
    (SELECT id FROM fields WHERE name = 'Cancha Sintética Mónaco')     AS monaco,
    (SELECT id FROM fields WHERE name = 'Planeta Fútbol Cancha Sintética')   AS planeta,
    (SELECT id FROM users  WHERE email = 'player@canchaya.co') AS player,
    (SELECT id FROM users  WHERE email = 'mateo@canchaya.co')  AS mateo;

-- 1. Overlapping reservation is rejected (Mateo has Monumental 19-21 in 2 days)
DO $$
DECLARE v t%ROWTYPE;
BEGIN
    SELECT * INTO v FROM t;
    BEGIN
        INSERT INTO reservations (field_id, player_id, date, start_hour, end_hour, total_amount, deposit_amount)
        VALUES (v.monumental, v.player, CURRENT_DATE + 2, 20, 22, 160000, 48000);
        RAISE EXCEPTION 'TEST FAILED: overlapping reservation was accepted';
    EXCEPTION WHEN exclusion_violation THEN
        RAISE NOTICE 'OK  1 overlapping reservation rejected';
    END;
END $$;

-- 2. Adjacent reservation is accepted (17-19 touches 19-21 but does not overlap)
DO $$
DECLARE v t%ROWTYPE;
BEGIN
    SELECT * INTO v FROM t;
    INSERT INTO reservations (field_id, player_id, date, start_hour, end_hour, total_amount, deposit_amount)
    VALUES (v.monumental, v.player, CURRENT_DATE + 2, 17, 19, 160000, 48000);
    RAISE NOTICE 'OK  2 adjacent reservation accepted';
END $$;

-- 3. A cancelled slot can be booked again (Laura cancelled Mónaco 18-20 in 6 days)
DO $$
DECLARE v t%ROWTYPE;
BEGIN
    SELECT * INTO v FROM t;
    INSERT INTO reservations (field_id, player_id, date, start_hour, end_hour, total_amount, deposit_amount)
    VALUES (v.monaco, v.player, CURRENT_DATE + 6, 18, 20, 140000, 42000);
    RAISE NOTICE 'OK  3 cancelled slot booked again';
END $$;

-- 4. Reservation outside opening hours is rejected (Monumental closes at 22)
DO $$
DECLARE v t%ROWTYPE;
BEGIN
    SELECT * INTO v FROM t;
    BEGIN
        INSERT INTO reservations (field_id, player_id, date, start_hour, end_hour, total_amount, deposit_amount)
        VALUES (v.monumental, v.player, CURRENT_DATE + 10, 22, 23, 80000, 24000);
        RAISE EXCEPTION 'TEST FAILED: reservation outside opening hours was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'OK  4 reservation outside opening hours rejected';
    END;
END $$;

-- 5. Inactive field does not accept new reservations
DO $$
DECLARE v t%ROWTYPE;
BEGIN
    SELECT * INTO v FROM t;
    UPDATE fields SET active = FALSE WHERE id = v.monaco;
    BEGIN
        INSERT INTO reservations (field_id, player_id, date, start_hour, end_hour, total_amount, deposit_amount)
        VALUES (v.monaco, v.player, CURRENT_DATE + 10, 10, 11, 70000, 21000);
        RAISE EXCEPTION 'TEST FAILED: inactive field accepted a reservation';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'OK  5 inactive field rejected the reservation';
    END;
    UPDATE fields SET active = TRUE WHERE id = v.monaco;
END $$;

-- 6. Invalid hours (end before start) are rejected
DO $$
DECLARE v t%ROWTYPE;
BEGIN
    SELECT * INTO v FROM t;
    BEGIN
        INSERT INTO reservations (field_id, player_id, date, start_hour, end_hour, total_amount, deposit_amount)
        VALUES (v.monumental, v.player, CURRENT_DATE + 10, 20, 18, 80000, 24000);
        RAISE EXCEPTION 'TEST FAILED: end_hour < start_hour was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'OK  6 invalid hours rejected';
    END;
END $$;

-- 7. Deposit larger than the total is rejected
DO $$
DECLARE v t%ROWTYPE;
BEGIN
    SELECT * INTO v FROM t;
    BEGIN
        INSERT INTO reservations (field_id, player_id, date, start_hour, end_hour, total_amount, deposit_amount)
        VALUES (v.monumental, v.player, CURRENT_DATE + 10, 10, 11, 80000, 90000);
        RAISE EXCEPTION 'TEST FAILED: deposit > total was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'OK  7 deposit greater than total rejected';
    END;
END $$;

-- 8. An approved payment confirms a pending reservation (Mateo, Planeta Fútbol, in 5 days)
DO $$
DECLARE v t%ROWTYPE; r reservations%ROWTYPE;
BEGIN
    SELECT * INTO v FROM t;
    SELECT * INTO r FROM reservations WHERE player_id = v.mateo AND date = CURRENT_DATE + 5;
    IF r.status <> 'PENDING_PAYMENT' THEN
        RAISE EXCEPTION 'TEST FAILED: expected PENDING_PAYMENT, got %', r.status;
    END IF;
    INSERT INTO payments (reservation_id, amount, method, status, transaction_ref)
    VALUES (r.id, r.deposit_amount, 'NEQUI', 'APPROVED', 'TEST-1');
    IF (SELECT status FROM reservations WHERE id = r.id) <> 'CONFIRMED' THEN
        RAISE EXCEPTION 'TEST FAILED: approved payment did not confirm the reservation';
    END IF;
    RAISE NOTICE 'OK  8 approved payment confirmed the reservation';
END $$;

-- 9. A second approved payment for the same reservation is rejected
DO $$
DECLARE v t%ROWTYPE; r reservations%ROWTYPE;
BEGIN
    SELECT * INTO v FROM t;
    SELECT * INTO r FROM reservations WHERE player_id = v.mateo AND date = CURRENT_DATE + 5;
    BEGIN
        INSERT INTO payments (reservation_id, amount, method, status, transaction_ref)
        VALUES (r.id, r.deposit_amount, 'WOMPI', 'APPROVED', 'TEST-2');
        RAISE EXCEPTION 'TEST FAILED: double charge was accepted';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'OK  9 second approved payment rejected';
    END;
END $$;

-- 10. A payment with the wrong amount is rejected
DO $$
DECLARE v t%ROWTYPE; r reservations%ROWTYPE;
BEGIN
    SELECT * INTO v FROM t;
    SELECT * INTO r FROM reservations
    WHERE field_id = v.monumental AND player_id = v.player AND date = CURRENT_DATE + 2;   -- created in test 2
    BEGIN
        INSERT INTO payments (reservation_id, amount, method, status, transaction_ref)
        VALUES (r.id, r.deposit_amount - 1, 'WOMPI', 'APPROVED', 'TEST-3');
        RAISE EXCEPTION 'TEST FAILED: wrong amount was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'OK 10 payment with wrong amount rejected';
    END;
END $$;

-- 11. A cancelled reservation cannot be paid
DO $$
DECLARE r reservations%ROWTYPE;
BEGIN
    SELECT * INTO r FROM reservations WHERE status = 'CANCELLED' LIMIT 1;
    BEGIN
        INSERT INTO payments (reservation_id, amount, method, status, transaction_ref)
        VALUES (r.id, r.deposit_amount, 'NEQUI', 'APPROVED', 'TEST-4');
        RAISE EXCEPTION 'TEST FAILED: cancelled reservation was paid';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'OK 11 cancelled reservation cannot be paid';
    END;
END $$;

-- 12. Duplicate and upper-case e-mails are rejected
DO $$
BEGIN
    BEGIN
        INSERT INTO users (name, email, password_hash, role) VALUES ('X', 'player@canchaya.co', 'x', 'PLAYER');
        RAISE EXCEPTION 'TEST FAILED: duplicate e-mail accepted';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'OK 12a duplicate e-mail rejected';
    END;
    BEGIN
        INSERT INTO users (name, email, password_hash, role) VALUES ('X', 'New@CanchaYa.co', 'x', 'PLAYER');
        RAISE EXCEPTION 'TEST FAILED: upper-case e-mail accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'OK 12b upper-case e-mail rejected';
    END;
END $$;

-- 13. fn_available_slots marks booked hours as unavailable
DO $$
DECLARE v t%ROWTYPE;
BEGIN
    SELECT * INTO v FROM t;
    IF (SELECT available FROM fn_available_slots(v.monumental, CURRENT_DATE + 2) WHERE slot_hour = 19) THEN
        RAISE EXCEPTION 'TEST FAILED: 19:00 should be booked';
    END IF;
    IF NOT (SELECT available FROM fn_available_slots(v.monumental, CURRENT_DATE + 2) WHERE slot_hour = 9) THEN
        RAISE EXCEPTION 'TEST FAILED: 09:00 should be free';
    END IF;
    IF (SELECT count(*) FROM fn_available_slots(v.monumental, CURRENT_DATE + 2)) <> 14 THEN
        RAISE EXCEPTION 'TEST FAILED: Monumental should have 14 one-hour slots (08-22)';
    END IF;
    RAISE NOTICE 'OK 13 fn_available_slots';
END $$;

-- 14. Real Pasto fields: all are reference listings with a valid zone
DO $$
BEGIN
    IF (SELECT count(*) FROM fields WHERE reference_listing AND zone IS NOT NULL) <> 38 THEN
        RAISE EXCEPTION 'TEST FAILED: expected 38 reference fields with zone, got %',
            (SELECT count(*) FROM fields WHERE reference_listing AND zone IS NOT NULL);
    END IF;
    IF (SELECT count(DISTINCT zone) FROM fields) <> 5 THEN
        RAISE EXCEPTION 'TEST FAILED: expected fields in the 5 zones of Pasto';
    END IF;
    BEGIN
        UPDATE fields SET zone = 'MARS' WHERE name = 'Canchas Sintéticas Monumental';
        RAISE EXCEPTION 'TEST FAILED: invalid zone accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'OK 14 reference fields and zones';
    END;
END $$;

ROLLBACK;
\echo 'All business-rule tests passed'
