-- =============================================================
-- S01 - Demo users
-- All passwords are "canchaya123" (BCrypt, compatible with the
-- Spring Security BCryptPasswordEncoder used by the backend).
-- =============================================================

INSERT INTO users (name, email, password_hash, role) VALUES
    ('Carlos Owner',     'owner@canchaya.co',   '$2a$10$gsJVZAK4oPPphothsm0fS.q.vKrjkt3rpo147V9bcUzIOHVa7YYjO', 'OWNER'),
    ('Diana Owner',      'owner2@canchaya.co',  '$2a$10$gsJVZAK4oPPphothsm0fS.q.vKrjkt3rpo147V9bcUzIOHVa7YYjO', 'OWNER'),
    ('Andres Player',    'player@canchaya.co',  '$2a$10$gsJVZAK4oPPphothsm0fS.q.vKrjkt3rpo147V9bcUzIOHVa7YYjO', 'PLAYER'),
    ('Laura Player',     'laura@canchaya.co',   '$2a$10$gsJVZAK4oPPphothsm0fS.q.vKrjkt3rpo147V9bcUzIOHVa7YYjO', 'PLAYER'),
    ('Mateo Player',     'mateo@canchaya.co',   '$2a$10$gsJVZAK4oPPphothsm0fS.q.vKrjkt3rpo147V9bcUzIOHVa7YYjO', 'PLAYER'),
    ('Admin CanchaYa',   'admin@canchaya.co',   '$2a$10$gsJVZAK4oPPphothsm0fS.q.vKrjkt3rpo147V9bcUzIOHVa7YYjO', 'ADMIN');
