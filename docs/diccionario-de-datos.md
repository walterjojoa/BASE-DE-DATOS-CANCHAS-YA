# Diccionario de datos

## `users` — usuarios

| Columna | Tipo | Nulo | Restricciones | Descripción |
|---|---|---|---|---|
| id | BIGINT | No | PK, identity | Identificador |
| name | VARCHAR(120) | No | no vacío | Nombre completo |
| email | VARCHAR(160) | No | UNIQUE, en minúsculas | Correo de inicio de sesión |
| password_hash | VARCHAR(255) | No | | Hash BCrypt de la contraseña |
| role | VARCHAR(20) | No | `PLAYER`, `OWNER`, `ADMIN` | Rol del usuario |
| created_at | TIMESTAMPTZ | No | default `now()` | Fecha de registro |

## `fields` — canchas

| Columna | Tipo | Nulo | Restricciones | Descripción |
|---|---|---|---|---|
| id | BIGINT | No | PK, identity | Identificador |
| name | VARCHAR(120) | No | no vacío | Nombre de la cancha |
| address | VARCHAR(200) | No | | Dirección en Pasto |
| latitude | DOUBLE PRECISION | Sí | -90 a 90 | Latitud para el mapa |
| longitude | DOUBLE PRECISION | Sí | -180 a 180 | Longitud para el mapa |
| price_per_hour | NUMERIC(12,2) | No | > 0 | Precio por hora en COP |
| owner_id | BIGINT | No | FK → users.id | Dueño de la cancha |
| active | BOOLEAN | No | default `TRUE` | Si recibe reservas |

## `schedules` — horarios

| Columna | Tipo | Nulo | Restricciones | Descripción |
|---|---|---|---|---|
| id | BIGINT | No | PK, identity | Identificador |
| field_id | BIGINT | No | FK → fields.id (ON DELETE CASCADE) | Cancha |
| day_of_week | VARCHAR(10) | No | `MONDAY`…`SUNDAY`; UNIQUE con field_id | Día de la semana |
| opening_hour | INTEGER | No | ≥ 0 | Hora de apertura |
| closing_hour | INTEGER | No | ≤ 24 y > opening_hour | Hora de cierre |

## `reservations` — reservas

| Columna | Tipo | Nulo | Restricciones | Descripción |
|---|---|---|---|---|
| id | BIGINT | No | PK, identity | Identificador |
| field_id | BIGINT | No | FK → fields.id | Cancha reservada |
| player_id | BIGINT | No | FK → users.id | Jugador que reserva |
| date | DATE | No | | Día de la reserva |
| start_hour | INTEGER | No | ≥ 0 | Hora de inicio (incluida) |
| end_hour | INTEGER | No | ≤ 24 y > start_hour | Hora de fin (no incluida) |
| total_amount | NUMERIC(12,2) | No | > 0 | Valor total |
| deposit_amount | NUMERIC(12,2) | No | 0 ≤ anticipo ≤ total | Anticipo a pagar en línea |
| status | VARCHAR(20) | No | `PENDING_PAYMENT`, `CONFIRMED`, `CANCELLED` | Estado |
| created_at | TIMESTAMPTZ | No | default `now()` | Fecha de creación |

**Restricción de exclusión `ex_reservations_no_overlap`:** dos reservas no canceladas de la misma cancha y el mismo día no pueden compartir ninguna hora.

## `payments` — pagos

| Columna | Tipo | Nulo | Restricciones | Descripción |
|---|---|---|---|---|
| id | BIGINT | No | PK, identity | Identificador |
| reservation_id | BIGINT | No | FK → reservations.id (ON DELETE CASCADE) | Reserva pagada |
| amount | NUMERIC(12,2) | No | > 0, igual al anticipo (trigger) | Monto cobrado |
| method | VARCHAR(20) | No | `WOMPI`, `NEQUI`, `DAVIPLATA` | Medio de pago |
| status | VARCHAR(20) | No | `APPROVED`, `DECLINED` | Resultado |
| transaction_ref | VARCHAR(120) | Sí | | Referencia del proveedor |
| created_at | TIMESTAMPTZ | No | default `now()` | Fecha del intento |

**Índice único parcial `uq_payments_one_approved`:** máximo un pago aprobado por reserva.

## Objetos adicionales

| Objeto | Tipo | Para qué |
|---|---|---|
| `ex_reservations_no_overlap` | Restricción EXCLUDE (GiST) | Evita reservas cruzadas |
| `uq_payments_one_approved` | Índice único parcial | Evita cobrar dos veces |
| `trg_reservations_within_schedule` | Trigger | La reserva debe estar dentro del horario y la cancha activa |
| `trg_payments_apply` | Trigger | Valida el monto del pago y confirma la reserva |
| `v_reservation_detail` | Vista | Reserva con cancha, jugador y pago |
| `v_owner_monthly_income` | Vista | Ingresos mensuales por dueño |
| `v_field_daily_occupancy` | Vista | Porcentaje de ocupación diaria |
| `fn_available_slots(field, date)` | Función | Horas libres/ocupadas de un día |
