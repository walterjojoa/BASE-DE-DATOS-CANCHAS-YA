-- =============================================================
-- S02 - Demo fields in Pasto (approximate coordinates)
-- ORDER BY keeps the ids predictable on an empty database:
-- 1 El Ejido, 2 La Bombonera, 3 Torobajo, 4 Pandiaco.
-- =============================================================

INSERT INTO fields (name, address, latitude, longitude, price_per_hour, owner_id)
SELECT v.name, v.address, v.lat, v.lng, v.price, u.id
FROM (VALUES
    (1, 'Sintetica El Ejido',  'Cra. 27 #10-35, Pasto',            1.2089, -77.2793,  80000, 'owner@canchaya.co'),
    (2, 'La Bombonera Pasto',  'Av. Panamericana #18-20, Pasto',   1.2213, -77.2846,  90000, 'owner@canchaya.co'),
    (3, 'Cancha Torobajo',     'Calle 18 #50-12, Torobajo, Pasto', 1.2322, -77.2921,  70000, 'owner2@canchaya.co'),
    (4, 'Futbol 5 Pandiaco',   'Av. Boyaca #30-40, Pasto',         1.2241, -77.2875, 100000, 'owner2@canchaya.co')
) AS v(ord, name, address, lat, lng, price, owner_email)
JOIN users u ON u.email = v.owner_email
ORDER BY v.ord;
