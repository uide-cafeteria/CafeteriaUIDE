import express from 'express';
import promocionController from '../controllers/promocionController.js';
import { verificarToken } from '../middleware/auth.js';
import { upload } from '../middleware/upload.js';

const router = express.Router();

// listar promociones
router.get('/mostrar', promocionController.obtenerPromocionesActivas);
router.get('/mostrar/admin', verificarToken, promocionController.obtenerPromocionesAdmin);

//CRUD promociones
router.post('/crear', verificarToken, upload.single('imagen'), promocionController.crearPromocion);
router.put('/actualizar/:idPromocion', verificarToken, upload.single('imagen'), promocionController.actualizarPromocion);
router.put('/estado/:idPromocion', verificarToken, promocionController.actualizarEstadoPromocion);

export default router;