-- =============================================================
-- V14 - v_field_daily_occupancy
-- For every field and every date that has active reservations:
-- booked hours vs. open hours that day, and the occupancy %.
-- =============================================================

CREATE OR REPLACE VIEW v_field_daily_occupancy AS
SELECT
    f.id                                                    AS field_id,
    f.name                                                  AS field_name,
    r.date,
    sum(r.end_hour - r.start_hour)                          AS booked_hours,
    s.closing_hour - s.opening_hour                         AS open_hours,
    round(100.0 * sum(r.end_hour - r.start_hour)
                / (s.closing_hour - s.opening_hour), 1)     AS occupancy_pct
FROM reservations r
JOIN fields    f ON f.id = r.field_id
JOIN schedules s ON s.field_id = r.field_id
                AND s.day_of_week = to_char(r.date, 'FMDAY')
WHERE r.status <> 'CANCELLED'
GROUP BY f.id, f.name, r.date, s.opening_hour, s.closing_hour;

COMMENT ON VIEW v_field_daily_occupancy IS 'Daily occupancy percentage of each field';
