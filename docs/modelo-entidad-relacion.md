# Modelo entidad-relación

GitHub dibuja este diagrama automáticamente (Mermaid).

```mermaid
erDiagram
    USERS ||--o{ FIELDS        : "publica (OWNER)"
    USERS ||--o{ RESERVATIONS  : "reserva (PLAYER)"
    FIELDS ||--o{ SCHEDULES    : "tiene horario"
    FIELDS ||--o{ RESERVATIONS : "es reservada"
    RESERVATIONS ||--o{ PAYMENTS : "se paga con"

    USERS {
        bigint      id PK
        varchar     name
        varchar     email UK
        varchar     password_hash
        varchar     role "PLAYER | OWNER | ADMIN"
        timestamptz created_at
    }
    FIELDS {
        bigint  id PK
        varchar name
        varchar address
        double  latitude
        double  longitude
        numeric price_per_hour
        bigint  owner_id FK
        boolean active
    }
    SCHEDULES {
        bigint  id PK
        bigint  field_id FK
        varchar day_of_week "MONDAY..SUNDAY"
        int     opening_hour
        int     closing_hour
    }
    RESERVATIONS {
        bigint      id PK
        bigint      field_id FK
        bigint      player_id FK
        date        date
        int         start_hour
        int         end_hour
        numeric     total_amount
        numeric     deposit_amount
        varchar     status "PENDING_PAYMENT | CONFIRMED | CANCELLED"
        timestamptz created_at
    }
    PAYMENTS {
        bigint      id PK
        bigint      reservation_id FK
        numeric     amount
        varchar     method "WOMPI | NEQUI | DAVIPLATA"
        varchar     status "APPROVED | DECLINED"
        varchar     transaction_ref
        timestamptz created_at
    }
```

## Cardinalidades

| Relación | Cardinalidad | Explicación |
|---|---|---|
| users → fields | 1 : N | Un dueño (OWNER) publica muchas canchas; cada cancha tiene un solo dueño |
| users → reservations | 1 : N | Un jugador hace muchas reservas; cada reserva es de un jugador |
| fields → schedules | 1 : 0..7 | Una cancha tiene como máximo un horario por día de la semana |
| fields → reservations | 1 : N | Una cancha recibe muchas reservas |
| reservations → payments | 1 : N | Una reserva puede tener varios intentos de pago, pero **solo uno aprobado** |

## Estados de una reserva

```mermaid
stateDiagram-v2
    [*] --> PENDING_PAYMENT : el jugador reserva
    PENDING_PAYMENT --> CONFIRMED : pago aprobado (trigger trg_payments_apply)
    PENDING_PAYMENT --> PENDING_PAYMENT : pago rechazado
    PENDING_PAYMENT --> CANCELLED : el jugador cancela
    CONFIRMED --> CANCELLED : el jugador cancela
    CANCELLED --> [*]
```
