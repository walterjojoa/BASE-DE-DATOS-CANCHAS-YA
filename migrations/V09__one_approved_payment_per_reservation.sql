-- =============================================================
-- V09 - A reservation's deposit can be charged only once
-- Declined attempts may repeat, but at most ONE approved payment
-- can exist per reservation (protects against double charging).
-- =============================================================

CREATE UNIQUE INDEX uq_payments_one_approved
    ON payments (reservation_id)
    WHERE status = 'APPROVED';
