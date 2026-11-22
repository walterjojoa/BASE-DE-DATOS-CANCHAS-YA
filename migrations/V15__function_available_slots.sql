-- =============================================================
-- V15 - fn_available_slots(field_id, date)
-- Returns one row per opening hour of that day and whether it is
-- still free. Same answer as GET /api/fields/{id}/availability.
--
--   SELECT * FROM fn_available_slots(1, DATE '2026-12-05');
-- =============================================================

CREATE OR REPLACE FUNCTION fn_available_slots(p_field_id BIGINT, p_date DATE)
RETURNS TABLE (slot_hour INTEGER, available BOOLEAN)
LANGUAGE sql
STABLE
AS $$
    SELECT h AS slot_hour,
           NOT EXISTS (
               SELECT 1
               FROM reservations r
               WHERE r.field_id = p_field_id
                 AND r.date     = p_date
                 AND r.status  <> 'CANCELLED'
                 AND h >= r.start_hour
                 AND h <  r.end_hour
           ) AS available
    FROM schedules s
    CROSS JOIN LATERAL generate_series(s.opening_hour, s.closing_hour - 1) AS h
    WHERE s.field_id    = p_field_id
      AND s.day_of_week = to_char(p_date, 'FMDAY')
    ORDER BY h;
$$;

COMMENT ON FUNCTION fn_available_slots(BIGINT, DATE) IS 'Free/booked one-hour slots of a field on a date';
