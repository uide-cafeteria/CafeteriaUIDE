# Borrador de Especificación de Requerimientos de Software (SRS)  
**Cafetería UIDE**

**Autores**  
- Alddrin Venegas  
- Anthony Sánchez  
- Savier Torres  
- Erick Morales  
- Anderson Calva  

**Asignatura:** LTI_05A_INS – Ingeniería del Software  

---

## Resumen Ejecutivo

En la actualidad, la cafetería UIDE no cuenta con un sistema eficiente que facilite la consulta de información por parte de los estudiantes y la comunidad universitaria. Muchos usuarios desconocen el menú, las ofertas del día y los horarios de atención, lo que genera dudas al momento de adquirir los productos y provoca desorden en el servicio.

Por ello, se propone desarrollar una **aplicación móvil** que permita:  
- Consultar el menú diario  
- Visualizar promociones vigentes  
- Conocer los horarios de atención  
- Realizar solicitudes de servicio de catering  
- Consultar el historial de almuerzos adquiridos (para la promoción de almuerzo gratis)  

Esta solución busca mejorar la experiencia del usuario, optimizar la atención y brindar información clara y oportuna.

---

## 1. Introducción y Contexto

La cafetería universitaria presenta problemas relacionados con la falta de información accesible para los estudiantes, lo que genera indecisión al seleccionar alimentos, desconocimiento del menú diario, de las ofertas disponibles y de los horarios de atención. Esta situación provoca demoras, filas largas y una experiencia de servicio mejorable para toda la comunidad universitaria.

Se propone el desarrollo de una aplicación móvil que facilite la consulta del menú actualizado, muestre las promociones del día, informe los horarios de atención, permita solicitar servicio de catering y mantenga un historial de almuerzos para la promoción vigente. El objetivo es mejorar la organización, agilizar la atención y ofrecer una experiencia más clara, informada y eficiente.

---

## 2. Stakeholders del Proyecto

### 2.1 Lista de Stakeholders

| Stakeholder                                  | Interés / Necesidad principal                                      | Cómo se ve afectado o beneficiado                                      |
|----------------------------------------------|--------------------------------------------------------------------|-------------------------------------------------------------------------|
| Administrador del sistema en cocina          | Gestionar menú, ofertas, disponibilidad y responder solicitudes de catering | Ver información actualizada y apoyar en la toma de decisiones          |
| Personal de la cafetería                     | Mejorar la atención, reducir consultas manuales y tener información clara | Ahorra tiempo, evita confusiones y mejora la eficiencia del servicio   |
| Personal del rooftop                         | Gestionar menú y promociones                                       | Disponibilidad de información actualizada sin consultas manuales       |
| Estudiantes                                  | Consultar menú, promociones, horarios y revisar historial de consumo | Mejora su experiencia al informarse rápidamente y decidir qué consumir |
| Docentes y personal administrativo de la UIDE | Consultar menú y promociones, solicitar catering para eventos     | Facilidad para gestionar solicitudes sin procesos presenciales         |
| Usuarios particulares / externos             | Consultar menú y promociones sin pertenecer a la universidad       | Acceso rápido a la información sin estar en la cafetería               |
| Grupo de Desarrollo                          | Implementar y mantener el sistema funcionando correctamente        | Mejor retroalimentación para mejora continua del sistema               |

### 2.2 Matriz de Influencia-Interés

| Actor                                        | Influencia | Interés | Aportes / Necesidades                                                                 |
|----------------------------------------------|------------|---------|---------------------------------------------------------------------------------------|
| Administrador del sistema en cocina          | Alta       | Alto    | Actualizar menú, promociones, horarios y gestión de la promoción de almuerzo gratis   |
| Personal de la cafetería                     | Media      | Alto    | Información clara y en tiempo real para mejorar atención y organización              |
| Personal del rooftop                         | Media      | Media   | Usan la información para orientar a los usuarios                                      |
| Estudiantes                                  | Media      | Alto    | Consultan menú, promociones, horarios e historial; aportan retroalimentación          |
| Docentes y Personal de administración        | Media      | Medio   | Consultan menú y solicitan catering; reportan necesidades institucionales             |
| Usuarios particulares / Personal externo     | Alto       | Medio   | Utilizan la aplicación para informarse sin depender de personal interno               |
| Grupo de Desarrollo                          | Alta       | Alto    | Mantienen el sistema, garantizan estabilidad, implementan mejoras y reciben feedback  |

---

## 3. Actores / Usuarios del Sistema

- **Administradores en cocina**: Agregar menú, agregar promociones, ver comentarios y sugerencias.  
- **Personal de la cafetería**: Agregar menú, agregar promociones, ver comentarios, registrar almuerzos consumidos para la promoción vigente.  
- **Estudiantes**: Ver menú, ver historial de almuerzos, dar comentarios y sugerencias.  
- **Docentes**: Ver menú, ver historial de almuerzos, dar comentarios y sugerencias.  
- **Personal administrativo**: Ver menú, ver historial de almuerzos, dar comentarios y sugerencias.  
- **Usuarios particulares**: Ver menú, ver historial de almuerzos, dar comentarios y sugerencias.  
- **Grupo de desarrollo**: Mantener el sistema, garantizar estabilidad, implementar mejoras y recibir retroalimentación.

---

## 4. Alcance del Sistema (MVP)

**La aplicación SÍ incluirá:**

- Visualización del menú del día  
- Presentación de ofertas o promociones del día  
- Historial para promoción de almuerzo gratis  
- Reserva de catering  
- Mostrar horarios de apertura y cierre de la cafetería  

**La aplicación NO incluirá (por ahora):**

- Pedidos anticipados  
- Pagos en la plataforma  

---

## 5. Requerimientos Funcionales (RF)

- **RF-01**: El sistema debe permitir ver el menú del día, incluyendo el nombre, descripción, lista de ingredientes, imagen y precio de cada producto.  
- **RF-02**: El sistema debe mostrar las ofertas o promociones del día.  
- **RF-03**: El sistema debe permitir a los usuarios consultar su historial de almuerzos acumulados para verificar si califican a la promoción disponible.  
- **RF-04**: El sistema debe mostrar la hora de apertura y de cierre del establecimiento.  
- **RF-05**: El sistema debe permitir al personal de la cafetería y rooftop agregar, editar o eliminar productos y ofertas.  
- **RF-06**: El sistema debe permitir al usuario solicitar el servicio de catering mediante un formulario con datos como fecha, hora, tipo de evento y contacto, con al menos 48 horas de anticipación.  
- **RF-07**: El sistema debe permitir la autenticación de usuarios mediante correo, Google o número de teléfono.  
- **RF-08**: El sistema debe permitir la carga de imágenes de productos, menús y ofertas desde la interfaz de administración.
- **RF-09**: El sistema debe permitir a los usuarios enviar sugerencias, comentarios o reclamos a la administración.
- **RF-10**: El sistema debe presentar de forma visualmente distinta el "Menú del Día" y las "Promociones" para evitar confusiones.

---

## 6. Requerimientos No Funcionales (RNF)

### Rendimiento
- **RNF-01**: El sistema debe cargar la página principal en un tiempo máximo de 800 ms bajo condiciones normales de red.  
- **RNF-02**: El sistema debe responder a cualquier acción del usuario (consulta de menú, promociones, historial) en un máximo de 500 ms.  
- **RNF-03**: El sistema debe soportar al menos 100 usuarios conectados simultáneamente sin degradar el rendimiento.

### Seguridad
- **RNF-04**: Los usuarios administradores deben autenticarse mediante credenciales.  
- **RNF-05**: El sistema debe realizar copias de seguridad automáticas cada 24 horas para evitar pérdida de datos.

### Usabilidad
- **RNF-06**: Las funciones principales (ver menú, promociones y horarios) deben ejecutarse con máximo tres interacciones desde la pantalla inicial.  
- **RNF-07**: La interfaz debe ser intuitiva y no requerir capacitación formal para usuarios finales.  
- **RNF-08**: Los elementos de navegación deben presentar consistencia visual (colores, tipografía, jerarquía y distribución).

### Escalabilidad
- **RNF-09**: El sistema debe permitir aumentar la cantidad de usuarios simultáneos a 300 o más sin rediseño completo de la arquitectura.

### Fiabilidad
- **RNF-10**: Los datos críticos (menú, promoción, horarios, historial) deben mantenerse íntegros después de reinicios del sistema.

### Mantenibilidad
- **RNF-11**: El código debe estar documentado en al menos el 80% de las funciones, clases o módulos.

### Compatibilidad
- **RNF-12**: El sistema debe ser compatible con dispositivos móviles Android y iOS.

### Restricciones
- **RNF-13**: Toda decisión de diseño debe alinearse con las políticas tecnológicas institucionales de la UIDE.

---

## 7. Fuentes y Técnicas de Elicitación

La información se obtuvo mediante:  
- Conversaciones informales  
- Observación directa con estudiantes, docentes y personal de la cafetería  
- Comentarios y recomendaciones de la dueña de la cafetería  
- Análisis del grupo de WhatsApp donde actualmente se gestionan menús y promociones

**Evidencias:**  
https://www.canva.com/design/DAG6lpsHhHI/-cjr5J-1LoyRBixKqA6P_A/edit?utm_content=DAG6lpsHhHI&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton

---
https://www.canva.com/design/DAG4vKO4px4/W45nUe_pXHoEJd_VQ0fewg/edit