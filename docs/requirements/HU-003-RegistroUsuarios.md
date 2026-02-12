## Historia de Usuario #3 – RF-08
El sistema deberá permitir la autenticación de usuarios mediante, Google, número de teléfono, incluyendo correo y contraseña.

### Como:
Usuario de la Aplicación

### Quiero:
Acceder al sistema utilizando mi método de autenticación por correo institucional.

### Para:
Tener una experiencia de acceso rápida, segura y adecuada a mis necesidades.

---

## Criterios de Aceptación

### 1. Autenticación mediante correo y contraseña
- **Dado que** el usuario desea iniciar sesión con correo y contraseña  
  **Cuando** ingresa credenciales válidas registradas en la base de datos del sistema  
  **Entonces** deberá ser autenticado correctamente y redirigido a la pantalla principal.

- **Dado que** el usuario ingresa un correo no registrado o contraseña incorrecta  
  **Cuando** intenta iniciar sesión  
  **Entonces** el sistema deberá mostrar un mensaje indicando que las credenciales son inválidas.

### 2. Autenticación mediante Correo Institucional
- **Dado que** el usuario selecciona el método "Iniciar sesión con correo Institucional"  
  **Cuando** completa el proceso de autenticación de correo institucional mediante validación OTP  
  **Entonces** el sistema deberá permitir el acceso y registrar su información.

### 3. Manejo de errores de autenticación
- **Dado que** ocurre un error (código inválido, correo ya usado, usuario bloqueado o red caída)  
  **Cuando** el usuario intenta autenticarse  
  **Entonces** el sistema deberá mostrar mensajes claros y específicos del problema.

---

# Notas Técnicas

### Autenticación por correo y contraseña
- Validar formato de correo.
- Almacenar contraseñas con hash seguro (bcrypt).
- Retornar un token de sesión o JWT.
- Enviar codigo OTP al correo institucional.
- Permitir correos institucionales (ej. `*@uide.edu`).

### Autenticación con Google (Firebase Authentication)
- Usar Firebase Auth con proveedor Google.
- Obtener:
  - `uid`
  - `displayName`
  - `email`
  - `photoURL`
- Guardar o actualizar usuario en tabla local si no existe.
- Manejar errores de Google: cancelación, permisos, usuario no válido.

### Gestión de sesiones
- El backend deberá generar y validar JWT o tokens de sesión.
- Mantener sesión persistente hasta que el usuario cierre sesión manualmente.
- Validar que usuarios eliminados o bloqueados no puedan iniciar sesión aunque Firebase los acepte.

### Seguridad
- Prevenir ataques:
  - Fuerza bruta (rate limit).
  - SQL injection (ORM o consultas preparadas).
  - Robo de sesión (tokens seguros, expiración).
- Sin exponer claves privadas de Firebase en el frontend.

