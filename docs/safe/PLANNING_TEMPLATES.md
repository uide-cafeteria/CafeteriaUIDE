# Plantilla de Planificación de Incremento de Programa (PI Planning)

**PI:** [Número, ej. 1]
**Fecha:** [Fecha]
**Duración:** [ej. 10 semanas / 5 Sprints]

## 1. Visión y Objetivos del PI
> Resumen de qué queremos lograr en este trimestre.

**Objetivos de Negocio (Business Objectives):**
- [ ] Objetivo 1 (con valor de negocio 1-10)
- [ ] Objetivo 2
- [ ] Objetivo 3

**Objetivos de Arquitectura/Enablers:**
- [ ] Objetivo Técnico (ej. Refactorizar API, Implementar CI/CD)

## 2. Top 10 Features
1. Feature A
2. Feature B
...

## 3. ROAM Board (Riesgos)
Clasificación de riesgos identificados durante el planning:
- **R (Resolved):** El equipo lo resolvió.
- **O (Owned):** Alguien tomó responsabilidad de gestionarlo.
- **A (Accepted):** Aceptamos el riesgo, no se puede hacer nada por ahora.
- **M (Mitigated):** Tenemos un plan B.

| Riesgo | Tipo (R/O/A/M) | Responsable/Plan |
| :--- | :---: | :--- |
| Retraso en aprobación de diseño | M | Usar diseños placeholder |
| Servidor no disponible | O | System Architect configurará local |

---

# Plantilla de Planificación de Iteración (Sprint Planning)

**Iteración:** [Número, ej. 1.1]
**Fechas:** [Inicio] - [Fin]
**Capacidad del Equipo:** [Total Puntos de Historia disponibles]

## 1. Objetivos de la Iteración (Iteration Goals)
- Qué debemos lograr funcionalmente al final de estas 2 semanas.

## 2. Historias Comprometidas (Sprint Backlog)
| ID Historia | Descripción | Puntos | Responsable |
| :--- | :--- | :---: | :--- |
| STORY-01 | Login con Google | 5 | Erick |
| STORY-02 | API de Menú | 3 | Savier |
| BUG-05 | Fix crash en iOS | 2 | Anderson |

## 3. Definición de Hecho (DoD) Checklist para este Sprint
- [ ] Code Review completado
- [ ] Tests unitarios pasando
- [ ] Desplegado en ambiente de pruebas
