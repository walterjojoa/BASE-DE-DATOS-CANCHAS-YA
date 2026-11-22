-- =============================================================
-- S03 - Opening hours of the demo fields
-- =============================================================

-- El Ejido: every day 08:00-22:00
INSERT INTO schedules (field_id, day_of_week, opening_hour, closing_hour)
SELECT f.id, d.day, 8, 22
FROM fields f
CROSS JOIN unnest(ARRAY['MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY']) AS d(day)
WHERE f.name = 'Sintetica El Ejido';

-- La Bombonera: weekdays and Saturday 14:00-23:00, Sunday 09:00-23:00
INSERT INTO schedules (field_id, day_of_week, opening_hour, closing_hour)
SELECT f.id, d.day, CASE WHEN d.day = 'SUNDAY' THEN 9 ELSE 14 END, 23
FROM fields f
CROSS JOIN unnest(ARRAY['MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY']) AS d(day)
WHERE f.name = 'La Bombonera Pasto';

-- Torobajo: every day 06:00-22:00
INSERT INTO schedules (field_id, day_of_week, opening_hour, closing_hour)
SELECT f.id, d.day, 6, 22
FROM fields f
CROSS JOIN unnest(ARRAY['MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY']) AS d(day)
WHERE f.name = 'Cancha Torobajo';

-- Pandiaco: every day 08:00-24:00
INSERT INTO schedules (field_id, day_of_week, opening_hour, closing_hour)
SELECT f.id, d.day, 8, 24
FROM fields f
CROSS JOIN unnest(ARRAY['MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY']) AS d(day)
WHERE f.name = 'Futbol 5 Pandiaco';
