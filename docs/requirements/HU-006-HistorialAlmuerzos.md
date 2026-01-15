## Historia de Usuario #6 – RF-03  
**Los usuarios podrán consultar su historial de almuerzos acumulados para verificar si califican a promociones o beneficios.**

### Como:
Cliente registrado.

### Quiero:
Ver mi historial de almuerzos consumidos.

### Para:
Saber si califico para promociones o beneficios.

---

## Criterios de Aceptación

- **Dado que** el usuario ha iniciado sesión correctamente  
  **Cuando** accede a la sección de historial  
  **Entonces** sólo podrá visualizar su propio historial de almuerzos.

- **Dado que** el usuario ve su historial  
  **Cuando** el sistema muestra la información  
  **Entonces** deberá incluir fecha, producto consumido y el acumulado total de almuerzos.

- **Dado que** el usuario tiene un historial registrado  
  **Cuando** consulta la sección  
  **Entonces** el sistema deberá indicar si califica o no a una promoción.

- **Dado que** el usuario abre la sección de historial  
  **Cuando** carga la información  
  **Entonces** la consulta no deberá tardar más de **500 ms**, garantizando rapidez y fluidez.

---

## Notas Técnicas
- Requiere autenticación para limitar acceso al historial propio.  
- Consultar datos desde base de datos con filtros por ID de usuario.  
- Implementar lógica de cálculo para determinar si califica a promociones (ej. 10 almuerzos = 1 gratis).  
- Optimizar consultas para mantenerse bajo los **500 ms** de tiempo de respuesta.
