-- =============================================================
-- V13 - v_owner_monthly_income
-- Income report per owner and month, based on CONFIRMED reservations:
--   collected_online  = deposits already paid through the platform
--   pending_at_field  = what players still pay at the field
-- =============================================================

CREATE OR REPLACE VIEW v_owner_monthly_income AS
SELECT
    o.id                                         AS owner_id,
    o.name                                       AS owner_name,
    date_trunc('month', r.date)::date            AS month,
    count(*)                                     AS confirmed_reservations,
    sum(r.end_hour - r.start_hour)               AS booked_hours,
    sum(r.deposit_amount)                        AS collected_online,
    sum(r.total_amount - r.deposit_amount)       AS pending_at_field,
    sum(r.total_amount)                          AS total_income
FROM reservations r
JOIN fields f ON f.id = r.field_id
JOIN users  o ON o.id = f.owner_id
WHERE r.status = 'CONFIRMED'
GROUP BY o.id, o.name, date_trunc('month', r.date);

COMMENT ON VIEW v_owner_monthly_income IS 'Monthly income of each owner from confirmed reservations';
