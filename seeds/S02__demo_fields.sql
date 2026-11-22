-- =============================================================
-- S02 - Demo fields in Pasto (approximate coordinates)
-- =============================================================

INSERT INTO fields (name, address, latitude, longitude, price_per_hour, owner_id)
SELECT v.name, v.address, v.lat, v.lng, v.price, u.id
FROM (VALUES
    ('Sintetica El Ejido',  'Cra. 27 #10-35, Pasto',           1.2089, -77.2793,  80000, 'owner@canchaya.co'),
    ('La Bombonera Pasto',  'Av. Panamericana #18-20, Pasto',  1.2213, -77.2846,  90000, 'owner@canchaya.co'),
    ('Cancha Torobajo',     'Calle 18 #50-12, Torobajo, Pasto', 1.2322, -77.2921,  70000, 'owner2@canchaya.co'),
    ('Futbol 5 Pandiaco',   'Av. Boyaca #30-40, Pasto',        1.2241, -77.2875, 100000, 'owner2@canchaya.co')
) AS v(name, address, lat, lng, price, owner_email)
JOIN users u ON u.email = v.owner_email;
