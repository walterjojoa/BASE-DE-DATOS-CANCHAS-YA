-- =============================================================
-- Useful queries for the owner dashboard and the admin
-- =============================================================

-- 1. Free and booked hours of a field on a date
SELECT * FROM fn_available_slots(1, CURRENT_DATE + 2);

-- 2. Upcoming confirmed reservations of an owner's fields
SELECT reservation_id, date, start_hour, end_hour, field_name, player_name, remaining_amount
FROM v_reservation_detail
WHERE owner_name = 'CanchaYa - Canchas de referencia'
  AND status = 'CONFIRMED'
  AND date >= CURRENT_DATE
ORDER BY date, start_hour;

-- 3. Monthly income of every owner
SELECT owner_name, month, confirmed_reservations, booked_hours,
       collected_online, pending_at_field, total_income
FROM v_owner_monthly_income
ORDER BY month DESC, total_income DESC;

-- 4. Most booked fields (confirmed hours)
SELECT f.name, sum(r.end_hour - r.start_hour) AS booked_hours, count(*) AS reservations
FROM reservations r
JOIN fields f ON f.id = r.field_id
WHERE r.status = 'CONFIRMED'
GROUP BY f.name
ORDER BY booked_hours DESC;

-- 5. Peak hours: which start hours are booked the most
SELECT start_hour, count(*) AS reservations
FROM reservations
WHERE status <> 'CANCELLED'
GROUP BY start_hour
ORDER BY reservations DESC, start_hour;

-- 6. Players with the most confirmed reservations
SELECT u.name, u.email, count(*) AS confirmed
FROM reservations r
JOIN users u ON u.id = r.player_id
WHERE r.status = 'CONFIRMED'
GROUP BY u.name, u.email
ORDER BY confirmed DESC;

-- 7. Reservations still waiting for the deposit
SELECT reservation_id, date, start_hour, field_name, player_name, deposit_amount
FROM v_reservation_detail
WHERE status = 'PENDING_PAYMENT'
ORDER BY date, start_hour;

-- 8. Payments by method
SELECT method, status, count(*) AS payments, sum(amount) AS amount
FROM payments
GROUP BY method, status
ORDER BY method, status;

-- 9. Daily occupancy of each field
SELECT field_name, date, booked_hours, open_hours, occupancy_pct
FROM v_field_daily_occupancy
ORDER BY date, field_name;

-- 10. Cancellation rate per field
SELECT f.name,
       count(*) FILTER (WHERE r.status = 'CANCELLED')                       AS cancelled,
       count(*)                                                             AS total,
       round(100.0 * count(*) FILTER (WHERE r.status = 'CANCELLED') / count(*), 1) AS cancel_pct
FROM reservations r
JOIN fields f ON f.id = r.field_id
GROUP BY f.name
ORDER BY cancel_pct DESC;

-- 11. Fields per zone of Pasto (reference listings vs. fields managed by their owners)
SELECT zone,
       count(*)                                  AS fields,
       count(*) FILTER (WHERE reference_listing) AS reference_listings,
       count(*) FILTER (WHERE NOT reference_listing) AS owner_managed
FROM fields
WHERE active
GROUP BY zone
ORDER BY fields DESC;

-- 12. Fields of one zone, for the "search by sector" screen
SELECT id, name, address, latitude, longitude, price_per_hour, reference_listing
FROM fields
WHERE active AND zone = 'NORTH'
ORDER BY name;
