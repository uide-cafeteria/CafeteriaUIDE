# Roles y Responsabilidades (Configuración SAFe Essential para Equipo de 5)

Dado que este proyecto cuenta con un equipo de 5 personas, se adopta una configuración simplificada de **Essential SAFe**, donde el equipo actúa como un **Agile Team** que absorbe responsabilidades del Agile Release Train (ART).

## Estructura del Equipo (Agile Team)

Este equipo es **cross-functional**, capaz de definir, construir, probar y desplegar features.

### 1. Product Owner (PO)
**Responsable:** Alddrin Venegas
**Responsabilidades SAFe:**
-   **Owns the Team Backlog:** Es la única persona con autoridad para ordenar las historias en el backlog.
-   **Define Historias de Usuario:** Crea tickets detallados con criterios de aceptación claros.
-   **Acepta Historias:** Valida que el trabajo completado cumpla con la "Definition of Done" (DoD).
-   **Interacción con Stakeholders:** Actúa como proxy del cliente real (Dueña de cafetería/Profesor).

### 2. Scrum Master (SM)
**Responsable:** Anthony
**Responsabilidades SAFe:**
-   **Facilitador:** Dirige los eventos del equipo (Daily Stand-up, Iteration Planning, Review, Retrospective).
-   **Eliminador de Impedimentos:** Ayuda al equipo a desbloquearse (ej. problemas técnicos, falta de requisitos).
-   **Coach:** Guía al equipo en prácticas ágiles y SAFe (ej. asegurar que se use estimación por puntos).
-   **Calidad:** Fomenta la ingeniería de software moderna (CI/CD, pruebas).

### 3. Development Team (Dev Team)
**Responsables:** Todo el equipo (incluidos PO y SM si codean)
**Miembros:**
-   Savier Torres
-   Erick Morales
-   Anderson Calva
-   (Demás miembros)

**Responsabilidades SAFe:**
-   **Crear Incrementos:** Desarrollar, probar y desplegar historias de usuario.
-   **Colaboración:** Ayudarse mutuamente (Pair Programming) para evitar silos de conocimiento.
-   **Estimación:** Participar en el Planning Poker para estimar el esfuerzo de las historias.
-   **Diseño/Arquitectura:** Colaborar en decisiones técnicas (Backend, Base de Datos, Frontend).

---

## Roles a Nivel de Tren (ART) - Simplificado
En SAFe, estos roles gestionan múltiples equipos. Aquí, se distribuyen entre los miembros.

### System Architect / Engineering
**Responsable:** Savier Torres
**Funciones:**
-   Definir la arquitectura tecnológica (Node.js, Flutter, React).
-   Establecer estándares de código y prácticas de DevOps.
-   Asegurar que el sistema sea escalable (RNF-09) y seguro (RNF-04).

### Product Management (PM)
**Responsable:** Fusionado con el rol de **Product Owner** para este tamaño de equipo.
**Funciones:**
-   Definir la Visión del Producto.
-   Gestionar la hoja de ruta (Roadmap).

---

## Matriz de Asignación Sugerida

| Rol SAFe | Miembro Sugerido (A definir) | Notas |
| :--- | :--- | :--- |
| **Product Owner** | Alddrin Venegas | Quien tenga mejor visión del negocio/requisitos. |
| **Scrum Master** | Anthony | Quien sea más organizado/líder facilitador. |
| **System Architect** | Savier Torres | Líder técnico Backend/Fullstack. |
| **Dev Team** | Todos | Todos escriben código y tests. |

## Definition of Done (DoD) - Equipo Cafetería UIDE
Para que una Historia se considere "Terminada":
1.  [ ] Código completo y subido al repositorio.
2.  [ ] Pasa todas las pruebas automáticas (CI Pipeline en verde).
3.  [ ] Revisión de código (Code Review) aprobada por al menos 1 compañero.
4.  [ ] Desplegado en entorno de pruebas (si aplica).
5.  [ ] Aceptado por el Product Owner.
