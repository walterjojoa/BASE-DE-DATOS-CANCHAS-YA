-- =============================================================
-- S01 - Demo users
-- All demo passwords are "canchaya123" (BCrypt, compatible with the
-- Spring Security BCryptPasswordEncoder used by the backend).
--
-- referencias@canchaya.co owns the real Pasto fields loaded from public
-- data (S02). It is NOT a real owner: its password hash is not a valid
-- BCrypt hash, so nobody can log in with it.
-- =============================================================

INSERT INTO users (name, email, password_hash, role) VALUES
    ('CanchaYa - Canchas de referencia', 'referencias@canchaya.co', '!login-disabled',                                               'OWNER'),
    ('Carlos Owner',     'owner@canchaya.co',   '$2a$10$gsJVZAK4oPPphothsm0fS.q.vKrjkt3rpo147V9bcUzIOHVa7YYjO', 'OWNER'),
    ('Andres Player',    'player@canchaya.co',  '$2a$10$gsJVZAK4oPPphothsm0fS.q.vKrjkt3rpo147V9bcUzIOHVa7YYjO', 'PLAYER'),
    ('Laura Player',     'laura@canchaya.co',   '$2a$10$gsJVZAK4oPPphothsm0fS.q.vKrjkt3rpo147V9bcUzIOHVa7YYjO', 'PLAYER'),
    ('Mateo Player',     'mateo@canchaya.co',   '$2a$10$gsJVZAK4oPPphothsm0fS.q.vKrjkt3rpo147V9bcUzIOHVa7YYjO', 'PLAYER'),
    ('Admin CanchaYa',   'admin@canchaya.co',   '$2a$10$gsJVZAK4oPPphothsm0fS.q.vKrjkt3rpo147V9bcUzIOHVa7YYjO', 'ADMIN');
