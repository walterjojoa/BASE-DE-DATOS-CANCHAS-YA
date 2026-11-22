-- =============================================================
-- V16 - Zone of the city and "reference listing" flag
--   zone               sector of Pasto, used to filter fields
--   reference_listing  TRUE for real fields loaded from public
--                      information (Google Maps) whose owners have
--                      NOT joined the platform: price and opening
--                      hours are estimates, not the owner's data.
-- Maps to com.canchaya.domain.Field (zone, referenceListing).
-- =============================================================

ALTER TABLE fields
    ADD COLUMN zone               VARCHAR(20),
    ADD COLUMN reference_listing  BOOLEAN NOT NULL DEFAULT FALSE,
    ADD CONSTRAINT ck_fields_zone CHECK (zone IS NULL OR zone IN ('NORTH', 'CENTER', 'WEST', 'EAST', 'SOUTH'));

CREATE INDEX ix_fields_zone ON fields (zone) WHERE active;

COMMENT ON COLUMN fields.zone              IS 'NORTH | CENTER | WEST | EAST | SOUTH (sector of Pasto)';
COMMENT ON COLUMN fields.reference_listing IS 'TRUE = real field from public data, owner not on the platform; price/hours estimated';
