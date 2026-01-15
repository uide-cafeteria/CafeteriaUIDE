## Historia de Usuario #5 – RF-02  
**El sistema deberá mostrar las ofertas o promociones del día.**

### Como:
Usuario consumidor de la App

### Quiero:
Ver las promociones o descuentos vigentes.

### Para:
Aprovechar ofertas y tomar mejores decisiones de compra.

---

## Criterios de Aceptación

- **Dado que** el usuario ingresa a la aplicación  
  **Cuando** accede a la sección de promociones  
  **Entonces** deberá ver todas las promociones activas del día en un lugar visible.

- **Dado que** una promoción está disponible  
  **Cuando** se muestra en la app  
  **Entonces** deberá incluir: tipo de oferta, precio final y condiciones.

- **Dado que** el administrador actualiza o crea una promoción  
  **Cuando** el usuario visualiza nuevamente la sección  
  **Entonces** las promociones deberán actualizarse automáticamente sin necesidad de reiniciar la app.

- **Dado que** el usuario abre la sección de promociones  
  **Cuando** la app carga la información  
  **Entonces** el tiempo de carga no debe exceder los **600 ms** para garantizar fluidez.

---

## Notas Técnicas
- Consultar promociones desde base de datos o backend.  
- Implementar stream, listener o actualización reactiva para cambios en promociones.  
- Optimizar imágenes y datos para que la sección cargue rápido (< 600 ms).  
- Validar que solo se muestren promociones vigentes según fecha/hora actual.
