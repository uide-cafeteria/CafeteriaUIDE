## Historia de Usuario #3 – RF-08
El sistema deberá permitir la autenticación de usuarios mediante, Google, número de teléfono, incluyendo correo y contraseña.

### Como:
Usuario de la Aplicación

### Quiero:
Acceder al sistema utilizando mi método de autenticación preferido (correo, Google o número de teléfono).

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

### 2. Autenticación mediante Google (Firebase)
- **Dado que** el usuario selecciona el método "Iniciar sesión con Google"  
  **Cuando** completa el proceso de autenticación de Google mediante Firebase  
  **Entonces** el sistema deberá permitir el acceso y registrar/actualizar su información básica (nombre, correo, foto).

### 3. Autenticación mediante número de teléfono
- **Dado que** el usuario elige iniciar sesión con número de teléfono  
  **Cuando** ingresa su número y recibe un código de verificación  
  **Entonces** deberá poder autenticarse correctamente al ingresar el código validado por Firebase.

### 4. Manejo de errores de autenticación
- **Dado que** ocurre un error (código inválido, correo ya usado, usuario bloqueado o red caída)  
  **Cuando** el usuario intenta autenticarse  
  **Entonces** el sistema deberá mostrar mensajes claros y específicos del problema.

---

# Notas Técnicas

### Autenticación por correo y contraseña
- Validar formato de correo.
- Almacenar contraseñas con hash seguro (bcrypt).
- Retornar un token de sesión o JWT.
- Permitir correos institucionales (ej. `*@institucion.edu`).

### Autenticación con Google (Firebase Authentication)
- Usar Firebase Auth con proveedor Google.
- Obtener:
  - `uid`
  - `displayName`
  - `email`
  - `photoURL`
- Guardar o actualizar usuario en tabla local si no existe.
- Manejar errores de Google: cancelación, permisos, usuario no válido.

### Autenticación con número de teléfono
- Usar Firebase Phone Auth.
- Enviar OTP al número ingresado.
- Validar OTP mediante Firebase.
- Guardar número en la base de datos local si no existe.

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

