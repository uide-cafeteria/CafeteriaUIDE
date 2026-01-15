## Historia de Usuario #4 – RF-04
El sistema debe mostrar la hora de apertura y cierre del establecimiento, y habilitar o deshabilitar automáticamente las funcionalidades de la aplicación según el horario definido por el administrador.

### Como:
Administrador del Sistema (Backend)

### Quiero:
Configurar los horarios de apertura y cierre del establecimiento y que el sistema verifique estos horarios automáticamente.

### Para:
Controlar el uso de la aplicación únicamente dentro del horario autorizado y mejorar la gestión operativa.

---

## Criterios de Aceptación

### 1. Definición del horario por parte del administrador
- **Dado que** el administrador ingresa al panel de configuración del sistema  
  **Cuando** establece o actualiza la hora de apertura y de cierre  
  **Entonces** el backend deberá guardar correctamente estos horarios en la base de datos.

### 2. Consulta del horario desde la aplicación
- **Dado que** un usuario abre la aplicación  
  **Cuando** el frontend consulta la API  
  **Entonces** el backend deberá retornar la hora de apertura y cierre vigentes.

### 3. Verificación automática del estado (abierto/cerrado)
- **Dado que** el sistema tiene un horario de apertura y cierre definido  
  **Cuando** el backend recibe solicitudes de funcionalidades restringidas (por ejemplo, realizar pedidos)  
  **Entonces** debe validar automáticamente si la hora actual está dentro del horario permitido.

### 4. Bloqueo fuera de horario
- **Dado que** el usuario intenta acceder a funcionalidades que solo operan dentro del horario del establecimiento  
  **Cuando** la hora actual esté fuera del horario definido  
  **Entonces** el backend deberá retornar una respuesta indicando que el establecimiento está cerrado.

### 5. Respuestas claras del backend
- **Dado que** el backend determina el estado del establecimiento  
  **Cuando** una operación esté permitida o denegada por horario  
  **Entonces** deberá responder con:
  - `abierto: true | false`
  - Mensaje descriptivo:  
    - "El establecimiento está abierto"  
    - "El establecimiento está cerrado. Horario: HH:MM - HH:MM"

---

# Notas Técnicas

### Almacenamiento del horario
- Crear una tabla o sección de configuración, por ejemplo:

```
horario_atencion (
    idHorario INT PRIMARY KEY AUTO_INCREMENT,
    ubicacion ENUM('cafeteria', 'rooftop') NOT NULL,
    dia_semana ENUM('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes') NOT NULL,
    hora_apertura TIME NOT NULL,
    hora_cierre TIME NOT NULL,
    abierto BOOLEAN DEFAULT true,
    UNIQUE KEY unico_dia_ubicacion (ubicacion, dia_semana)
);
```

### Lógica de verificación automática
- Cada endpoint crítico (pedidos, reservas, solicitudes, etc.) debe ejecutar una función de validación:

```
isWithinSchedule(hora_apertura, hora_cierre, hora_actual)
```

- Considerar casos especiales:
  - Apertura y cierre dentro del mismo día (ej: 08:00 - 18:00)
  - Apertura que cruza medianoche (ej: 20:00 - 02:00)

### Respuesta API recomendada
```
{
  "abierto": true,
  "message": "El establecimiento está abierto",
  "hora_apertura": "08:00",
  "hora_cierre": "18:00"
}
```

### Reglas del backend
- El frontend **decide si está abierto o cerrado**, pero automáticamente muestra lo que dice el backend.
- Validación debe hacerse antes de procesar operaciones sensibles.
- Actualizar horarios debe invalidar caché o recargar configuración inmediatamente.

### Seguridad
- Solo administradores autenticados pueden modificar horarios.
- Validar formato de hora.

