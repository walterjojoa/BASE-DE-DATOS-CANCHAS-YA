-- =============================================================
-- V11 - Payment rules
--   * A cancelled reservation cannot be paid, and a confirmed one
--     cannot receive new payment attempts.
--   * The amount must be exactly the reservation's deposit.
--   * An APPROVED payment moves the reservation to CONFIRMED.
-- The backend (Reservation.registerPayment) does the same; this keeps
-- manual inserts consistent with the business rules.
-- =============================================================

CREATE OR REPLACE FUNCTION fn_apply_payment()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_status  VARCHAR(20);
    v_deposit NUMERIC(12,2);
BEGIN
    SELECT status, deposit_amount INTO v_status, v_deposit
    FROM reservations
    WHERE id = NEW.reservation_id
    FOR UPDATE;

    -- CONFIRMED is accepted only for the approving payment itself, because an ORM
    -- may flush the reservation update before the payment insert in the same
    -- transaction. A second approved payment is still blocked by
    -- uq_payments_one_approved (V09).
    IF v_status = 'CANCELLED'
       OR (v_status = 'CONFIRMED' AND NEW.status <> 'APPROVED') THEN
        RAISE EXCEPTION 'Reservation % is % and cannot be paid', NEW.reservation_id, v_status
            USING ERRCODE = 'check_violation';
    END IF;

    IF NEW.amount <> v_deposit THEN
        RAISE EXCEPTION 'Payment amount % does not match the deposit %', NEW.amount, v_deposit
            USING ERRCODE = 'check_violation';
    END IF;

    IF NEW.status = 'APPROVED' AND v_status = 'PENDING_PAYMENT' THEN
        UPDATE reservations SET status = 'CONFIRMED' WHERE id = NEW.reservation_id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_payments_apply
    BEFORE INSERT ON payments
    FOR EACH ROW
    EXECUTE FUNCTION fn_apply_payment();
