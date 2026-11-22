-- =============================================================
-- V07 - No double bookings
-- Two active (not cancelled) reservations of the same field on the
-- same date cannot share any hour. The backend already checks this,
-- but the database is the last line of defence: even two requests
-- arriving at the same millisecond cannot both succeed.
--
-- int4range(start, end) is half-open [start, end), so 19-21 and
-- 21-23 do NOT overlap, while 19-21 and 20-22 do.
-- =============================================================

ALTER TABLE reservations
    ADD CONSTRAINT ex_reservations_no_overlap
    EXCLUDE USING gist (
        field_id                         WITH =,
        date                             WITH =,
        int4range(start_hour, end_hour)  WITH &&
    )
    WHERE (status <> 'CANCELLED');
