# CanchaYa Pasto — Base de datos

Base de datos **PostgreSQL** de CanchaYa Pasto, la plataforma para reservar canchas sintéticas en Pasto. Es la que usa el [backend en Spring Boot](https://github.com/walterjojoa/BACKEND-CANCHAS-YA) y está pensada para desplegarse en **Neon**.

> Los nombres de tablas, columnas y el código SQL están en inglés, igual que el backend. La documentación está en español.

## Contenido

```
├── migrations/      Esquema en orden (V01 … V16): tablas, restricciones, triggers, vistas, funciones
├── data/            Canchas reales de Pasto (CSV) y generador de seeds
├── seeds/           Usuarios de prueba, 38 canchas reales de Pasto, horarios, reservas y pagos
├── tests/           Pruebas de las reglas de negocio en SQL
├── queries/         Consultas de reportes para el dueño y el administrador
├── docs/            Modelo entidad-relación, diccionario de datos, conexión con el backend
├── docker/          Script de arranque del contenedor
├── install.sql      Instala todo (esquema + datos de prueba)
├── uninstall.sql    Borra todo
└── docker-compose.yml
```

## Modelo

```mermaid
erDiagram
    USERS ||--o{ FIELDS        : "publica"
    USERS ||--o{ RESERVATIONS  : "reserva"
    FIELDS ||--o{ SCHEDULES    : "tiene"
    FIELDS ||--o{ RESERVATIONS : "recibe"
    RESERVATIONS ||--o{ PAYMENTS : "se paga con"
```

| Tabla | Qué guarda |
|---|---|
| `users` | Jugadores (`PLAYER`), dueños de canchas (`OWNER`) y administradores (`ADMIN`) |
| `fields` | Canchas: nombre, dirección, coordenadas, precio por hora, dueño |
| `schedules` | Horario de cada cancha por día de la semana |
| `reservations` | Reservas por horas enteras, con valor total, anticipo y estado |
| `payments` | Intentos de pago del anticipo (Wompi, Nequi, Daviplata) |

Diagrama completo con columnas y estados: [docs/modelo-entidad-relacion.md](docs/modelo-entidad-relacion.md) · Detalle de cada columna: [docs/diccionario-de-datos.md](docs/diccionario-de-datos.md)

## Reglas que garantiza la base de datos

| Regla | Cómo |
|---|---|
| Nunca dos reservas cruzadas en la misma cancha | Restricción `EXCLUDE USING gist` sobre `(field_id, date, int4range(start_hour, end_hour))`, ignorando las canceladas |
| La reserva debe estar dentro del horario de la cancha y la cancha activa | Trigger `trg_reservations_within_schedule` |
| El pago debe ser igual al anticipo y no se puede pagar una reserva cancelada | Trigger `trg_payments_apply` |
| Un pago aprobado confirma la reserva automáticamente | Trigger `trg_payments_apply` |
| Nunca se cobra dos veces la misma reserva | Índice único parcial `uq_payments_one_approved` |
| Horas entre 0 y 24, montos positivos, anticipo ≤ total, roles y estados válidos | Restricciones `CHECK` |
| Correos únicos y en minúsculas | `UNIQUE` + `CHECK` |

## Instalación

### Opción 1 — Docker (local)

```bash
docker compose up -d
```

Crea PostgreSQL 16 en `localhost:5432` (base `canchaya`, usuario `canchaya`, contraseña `canchaya`), instala el esquema, carga los datos de prueba y corre las pruebas.

### Opción 2 — Neon o cualquier PostgreSQL

```bash
psql "postgresql://<usuario>:<contraseña>@<host>/<base>?sslmode=require" -f install.sql
```

Se ejecuta sobre una base **vacía**. Si no quieres los datos de prueba, comenta el bloque *Demo data* al final de `install.sql`.

En Neon también puedes pegar los archivos de `migrations/` en orden en el *SQL Editor* (y luego los de `seeds/`).

### Probar las reglas

```bash
psql "<conexión>" -f tests/test_business_rules.sql
```

Corre 14 pruebas (reservas cruzadas, horarios, cancha inactiva, pagos dobles, montos, correos, horas libres, zonas…) dentro de una transacción que se deshace al final, así que no modifica los datos.

### Desinstalar

```bash
psql "<conexión>" -f uninstall.sql
```

## Canchas sintéticas reales de Pasto

La base trae **38 canchas sintéticas reales de Pasto**, tomadas de las fichas públicas de Google Maps (noviembre de 2026) y clasificadas por **zona** de la ciudad:

| Zona (`zone`) | Canchas |
|---|---|
| Norte (`NORTH`) | 8 |
| Centro (`CENTER`) | 10 |
| Occidente (`WEST`) | 2 |
| Oriente (`EAST`) | 3 |
| Sur (`SOUTH`) | 15 |

- La fuente única es [`data/pasto_fields.csv`](data/pasto_fields.csv) (nombre, dirección, coordenadas, zona, horario). Los scripts `seeds/S02` y `seeds/S03` se generan con `python data/generate_field_seeds.py`; el backend carga el mismo CSV en desarrollo.
- Son **negocios reales que no se han unido a CanchaYa**, por eso se marcan con `reference_listing = TRUE` y pertenecen a la cuenta `referencias@canchaya.co`, en la que nadie puede iniciar sesión.
- **Precio ($80.000/hora) y horario (08:00–22:00) son estimados**: ninguna cancha publica su tarifa. Solo La Pasión del Fútbol publica su horario (06:00–22:00).
- La zona se asignó por coordenadas con límites aproximados.
- No se guardan teléfonos ni calificaciones de Google.
- Se excluyeron canchas públicas o de colegios no confirmadas y un duplicado (La Cancha Club Deportivo = La Pelotera).

## Usuarios y reservas de prueba

Todos los usuarios de prueba tienen la contraseña **`canchaya123`** (hash BCrypt compatible con el backend):

| Correo | Rol |
|---|---|
| `owner@canchaya.co` | OWNER (sin canchas; puede publicar las suyas) |
| `player@canchaya.co`, `laura@canchaya.co`, `mateo@canchaya.co` | PLAYER |
| `admin@canchaya.co` | ADMIN |
| `referencias@canchaya.co` | OWNER técnico de las canchas de referencia (sin acceso) |

Las reservas y pagos de prueba son **ficticios** (las canchas no los conocen). Usan fechas relativas a `CURRENT_DATE` (pasadas y futuras), con pagos aprobados, uno rechazado y una reserva cancelada.

## Vistas y funciones

| Objeto | Ejemplo |
|---|---|
| `fn_available_slots(field_id, date)` | `SELECT * FROM fn_available_slots(1, CURRENT_DATE + 2);` |
| `v_reservation_detail` | `SELECT * FROM v_reservation_detail WHERE status = 'CONFIRMED';` |
| `v_owner_monthly_income` | `SELECT * FROM v_owner_monthly_income ORDER BY month DESC;` |
| `v_field_daily_occupancy` | `SELECT * FROM v_field_daily_occupancy WHERE date = CURRENT_DATE;` |

Más consultas (horas pico, canchas más reservadas, tasa de cancelación…) en [queries/reports.sql](queries/reports.sql).

## Conexión con el backend

Ver [docs/conexion-backend.md](docs/conexion-backend.md): variables de entorno, correspondencia entidad ↔ tabla y qué regla valida cada capa.

## Convenciones

- Tablas en plural y `snake_case`, igual que la estrategia de nombres de Hibernate.
- Prefijos: `fk_`/`uq_`/`ck_`/`ex_` para restricciones, `ix_` para índices, `trg_` triggers, `fn_` funciones, `v_` vistas.
- Las migraciones siguen el formato de Flyway (`V01__descripcion.sql`), por si el backend adopta Flyway más adelante.
- Los estados y roles se guardan como texto con `CHECK` (no como `ENUM` de PostgreSQL) para que coincidan con `@Enumerated(EnumType.STRING)` de JPA.
