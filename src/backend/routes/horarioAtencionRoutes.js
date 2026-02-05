// routes/horarioAtencion.routes.js
import express from 'express';
import horarioAtencionController from '../controllers/horarioAtencionController.js';
import { verificarToken } from '../middleware/auth.js';

const router = express.Router();

// Ruta pública - para mostrar horarios al público / clientes
router.get('/mostrar', horarioAtencionController.obtenerHorariosPublicos);

// ────────────────────────────────────────────────
// CRUD y operaciones de administración
// ────────────────────────────────────────────────

// Crear un nuevo horario
router.post('/crear', verificarToken, horarioAtencionController.crearHorario);

// Editar un horario existente
router.put('/:idHorario', verificarToken, horarioAtencionController.actualizarHorario);

// Activar / desactivar horario (toggle)
router.put('/:idHorario/activar', verificarToken, horarioAtencionController.toggleEstadoHorario);

// Listar TODOS los horarios (para panel admin)
router.get('/mostrar/admin', verificarToken, horarioAtencionController.obtenerTodosHorariosAdmin);

// Eliminar un horario
router.delete('/eliminar/:idHorario', verificarToken, horarioAtencionController.eliminarHorario);

export default router;