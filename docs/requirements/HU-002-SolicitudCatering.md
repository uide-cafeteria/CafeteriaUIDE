## Historia de Usuario #2 – RF-07 
**El sistema permitirá recibir solicitudes de catering, en la cual el administrador puede responder a dicha solicitud**

### Como:
Administrador de la Aplicación  

### Quiero:
Recibir las solicitudes de catering con la información dada por el usuario.

### Para:
Gestionar las solicitudes, dar respuesta oportuna y aumentar la contratación del servicio.

---

## Criterios de Aceptación

### 1. Registrar solicitud
- **Dado que** un usuario desea solicitar el servicio de catering  
  **Cuando** llena el formulario con los datos requeridos (nombre, correo, teléfono, fecha, hora, tipo de evento y cantidad de personas)  
  **Entonces** el sistema deberá registrar la solicitud y guardarla con estado "pendiente".

### 2. Validaciones del formulario
- **Dado que** el usuario está completando el formulario  
  **Cuando** deja campos obligatorios vacíos o usa formatos inválidos  
  **Entonces** el sistema debe mostrar mensajes claros indicando qué debe corregir.

### 3. Confirmación de envío
- **Dado que** la información del formulario es válida  
  **Cuando** el usuario presiona "Enviar solicitud"  
  **Entonces** la app mostrará un mensaje: "Solicitud enviada correctamente" y almacenará la fecha y hora del envío.

### 4. Visualización por el administrador
- **Dado que** el administrador accede al panel de solicitudes  
  **Cuando** consulta la lista  
  **Entonces** deberá visualizar todas las solicitudes con su estado actual (pendiente, confirmada, rechazada, cancelada).

### 5. Responder solicitud
- **Dado que** el administrador selecciona una solicitud pendiente  
  **Cuando** escribe una respuesta y elige un estado (confirmada o rechazada)  
  **Entonces** el sistema guardará:
  - el usuario que respondió (`respondida_por`)
  - la respuesta
  - el nuevo estado de la solicitud

---

# Notas Técnicas

- Validar campos obligatorios:
  - `nombre_completo`
  - `correo`
  - `telefono`
  - `fecha_evento`
  - `tipo_evento`

- Validar formatos:
  - Correo válido (regex)
  - Teléfono numérico o con formato permitido
  - Fecha mayor o igual a la fecha actual

- Guardado de la solicitud:
  - Insertar registro en `solicitud_catering`
  - Estado inicial "pendiente"
  - Registrar automáticamente `fecha_solicitud`

- Gestión del administrador:
  - Actualizar `estado` (confirmada/rechazada/cancelada)
  - Guardar `respondida_por` (idUsuario administrador)
  - Guardar `respuesta`

- Panel del administrador:
  - Listar solicitudes
  - Permitir filtros por estado

- Opcional:
  - Enviar notificación al usuario al responder la solicitud mediante correo  electrónico