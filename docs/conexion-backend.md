# Conectar el backend

El backend ([BACKEND-CANCHAS-YA](https://github.com/walterjojoa/BACKEND-CANCHAS-YA)) usa Spring Boot + JPA. Las tablas y columnas de esta base tienen **exactamente** los nombres que Hibernate espera para sus entidades:

| Entidad Java | Tabla |
|---|---|
| `com.canchaya.domain.User` | `users` |
| `com.canchaya.domain.Field` | `fields` |
| `com.canchaya.domain.Schedule` | `schedules` |
| `com.canchaya.domain.Reservation` | `reservations` |
| `com.canchaya.domain.Payment` | `payments` |

## Pasos

1. Crear la base (Neon o Docker) y ejecutar `install.sql`.
2. Arrancar el backend con el perfil `prod` y estas variables:

```bash
SPRING_PROFILES_ACTIVE=prod
DATABASE_URL=jdbc:postgresql://<host>/<base>?sslmode=require
DATABASE_USERNAME=<usuario>
DATABASE_PASSWORD=<contraseña>
JWT_SECRET=<texto aleatorio de 32+ caracteres>
SEED_DEMO_DATA=false        # los datos de prueba ya los carga seeds/
```

Con Docker local:

```bash
DATABASE_URL=jdbc:postgresql://localhost:5432/canchaya
DATABASE_USERNAME=canchaya
DATABASE_PASSWORD=canchaya
```

3. Recomendado: cambiar en el backend `spring.jpa.hibernate.ddl-auto=update` por `validate`, para que Hibernate solo verifique que el esquema coincide y los cambios de estructura se hagan siempre con scripts de este repositorio.

## Qué valida la base además del backend

Las reglas importantes están en los dos lados (defensa en profundidad):

| Regla | Backend | Base de datos |
|---|---|---|
| No hay reservas cruzadas | `Reservation.overlaps()` + bloqueo de la cancha | `ex_reservations_no_overlap` |
| Reserva dentro del horario | `Field.book()` | `trg_reservations_within_schedule` |
| Pago = anticipo, una sola vez | `Reservation.registerPayment()` | `trg_payments_apply` + `uq_payments_one_approved` |
| Valores y horas válidos | Bean Validation en los DTOs | `CHECK` constraints |

Si el backend recibe un error de la base (por ejemplo dos peticiones simultáneas por la misma hora), la restricción garantiza que solo una reserva quede guardada.
