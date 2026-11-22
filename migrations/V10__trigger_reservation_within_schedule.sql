-- =============================================================
-- V10 - A reservation must fall inside the field's opening hours
-- and new reservations are only accepted on active fields.
-- The backend (Field.book) validates this too; the trigger keeps the
-- data consistent even if someone inserts rows by hand.
-- =============================================================

CREATE OR REPLACE FUNCTION fn_check_reservation_schedule()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_day    VARCHAR(10) := to_char(NEW.date, 'FMDAY');   -- English, e.g. SATURDAY
    v_active BOOLEAN;
BEGIN
    SELECT active INTO v_active FROM fields WHERE id = NEW.field_id;

    IF TG_OP = 'INSERT' AND v_active IS FALSE THEN
        RAISE EXCEPTION 'Field % is not accepting reservations', NEW.field_id
            USING ERRCODE = 'check_violation';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM schedules s
        WHERE s.field_id    = NEW.field_id
          AND s.day_of_week = v_day
          AND NEW.start_hour >= s.opening_hour
          AND NEW.end_hour   <= s.closing_hour
    ) THEN
        RAISE EXCEPTION 'Field % is closed on % from %:00 to %:00',
            NEW.field_id, v_day, NEW.start_hour, NEW.end_hour
            USING ERRCODE = 'check_violation';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_reservations_within_schedule
    BEFORE INSERT OR UPDATE OF field_id, date, start_hour, end_hour
    ON reservations
    FOR EACH ROW
    EXECUTE FUNCTION fn_check_reservation_schedule();
