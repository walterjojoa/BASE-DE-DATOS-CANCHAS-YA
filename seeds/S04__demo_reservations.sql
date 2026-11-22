-- =============================================================
-- S04 - Demo reservations and payments
-- Dates are relative to CURRENT_DATE so the data always looks fresh.
-- Total = price_per_hour * hours, deposit = 30 % of the total.
-- Reservations are inserted as PENDING_PAYMENT; the approved payments
-- below move them to CONFIRMED through trg_payments_apply (V11).
-- All hours (17-22) fit every demo field's schedule on any day.
-- =============================================================

INSERT INTO reservations (field_id, player_id, date, start_hour, end_hour, total_amount, deposit_amount)
SELECT f.id, u.id, CURRENT_DATE + v.day_offset, v.start_hour, v.end_hour,
       f.price_per_hour * (v.end_hour - v.start_hour),
       round(f.price_per_hour * (v.end_hour - v.start_hour) * 0.30, 2)
FROM (VALUES
    -- field                  player                 day  start end
    ('Sintetica El Ejido',  'player@canchaya.co',  -14,  19,  21),
    ('Sintetica El Ejido',  'laura@canchaya.co',    -7,  18,  20),
    ('La Bombonera Pasto',  'mateo@canchaya.co',    -7,  20,  22),
    ('Cancha Torobajo',     'player@canchaya.co',   -3,  17,  18),
    ('Futbol 5 Pandiaco',   'laura@canchaya.co',    -1,  19,  21),
    ('Sintetica El Ejido',  'mateo@canchaya.co',     2,  19,  21),
    ('Sintetica El Ejido',  'laura@canchaya.co',     2,  21,  22),
    ('La Bombonera Pasto',  'player@canchaya.co',    3,  19,  20),
    ('Futbol 5 Pandiaco',   'mateo@canchaya.co',     5,  20,  22),
    ('Cancha Torobajo',     'laura@canchaya.co',     6,  18,  20)
) AS v(field_name, player_email, day_offset, start_hour, end_hour)
JOIN fields f ON f.name  = v.field_name
JOIN users  u ON u.email = v.player_email;

-- Approved deposits for every past reservation and two future ones.
INSERT INTO payments (reservation_id, amount, method, status, transaction_ref)
SELECT r.id, r.deposit_amount, v.method, 'APPROVED', v.method || '-SEED-' || r.id
FROM (VALUES
    ('player@canchaya.co', -14, 'WOMPI'),
    ('laura@canchaya.co',   -7, 'NEQUI'),
    ('mateo@canchaya.co',   -7, 'DAVIPLATA'),
    ('player@canchaya.co',  -3, 'NEQUI'),
    ('laura@canchaya.co',   -1, 'WOMPI'),
    ('mateo@canchaya.co',    2, 'NEQUI'),
    ('player@canchaya.co',   3, 'WOMPI')
) AS v(player_email, day_offset, method)
JOIN users u        ON u.email = v.player_email
JOIN reservations r ON r.player_id = u.id AND r.date = CURRENT_DATE + v.day_offset;

-- A declined attempt that stays pending (Mateo, Pandiaco, in 5 days).
INSERT INTO payments (reservation_id, amount, method, status, transaction_ref)
SELECT r.id, r.deposit_amount, 'DAVIPLATA', 'DECLINED', 'DAVI-DECLINED-' || r.id
FROM reservations r
JOIN users u ON u.id = r.player_id
WHERE u.email = 'mateo@canchaya.co' AND r.date = CURRENT_DATE + 5;

-- Laura cancels her Torobajo booking (in 6 days): the slot becomes free again.
UPDATE reservations r
SET status = 'CANCELLED'
FROM users u
WHERE u.id = r.player_id AND u.email = 'laura@canchaya.co' AND r.date = CURRENT_DATE + 6;
