-- =============================================================
-- V12 - v_reservation_detail
-- One readable row per reservation: field, player, amounts and the
-- approved payment (if any). Handy for the admin and for reports.
-- =============================================================

CREATE OR REPLACE VIEW v_reservation_detail AS
SELECT
    r.id                                  AS reservation_id,
    r.date,
    r.start_hour,
    r.end_hour,
    r.end_hour - r.start_hour             AS hours,
    r.status,
    f.id                                  AS field_id,
    f.name                                AS field_name,
    o.name                                AS owner_name,
    p.id                                  AS player_id,
    p.name                                AS player_name,
    p.email                               AS player_email,
    r.total_amount,
    r.deposit_amount,
    r.total_amount - r.deposit_amount     AS remaining_amount,
    pay.method                            AS payment_method,
    pay.transaction_ref,
    pay.created_at                        AS paid_at,
    r.created_at
FROM reservations r
JOIN fields f      ON f.id = r.field_id
JOIN users  o      ON o.id = f.owner_id
JOIN users  p      ON p.id = r.player_id
LEFT JOIN payments pay ON pay.reservation_id = r.id AND pay.status = 'APPROVED';

COMMENT ON VIEW v_reservation_detail IS 'Reservations with field, player and approved payment data';
