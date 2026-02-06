import express from 'express';
import solicitudCateringController from '../controllers/cateringController.js';
import { verificarToken } from '../middleware/auth.js';

const router = express.Router();

// Públicas (cualquiera puede crear)
router.post('/crear', solicitudCateringController.crearSolicitud);

// Protegidas - usuario autenticado
router.get('/solicitudes', verificarToken, solicitudCateringController.misSolicitudes);
router.put('/:idSolicitud/cancelar', verificarToken, solicitudCateringController.cancelarSolicitud);

// Solo admin
router.get('/admin/todas', verificarToken, solicitudCateringController.listarTodasSolicitudes);
router.get('/admin/:idSolicitud', verificarToken, solicitudCateringController.obtenerSolicitudPorId);
router.put('/admin/:idSolicitud/responder', verificarToken, solicitudCateringController.responderSolicitud);

export default router;