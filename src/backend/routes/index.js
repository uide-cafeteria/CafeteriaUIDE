import express from 'express';
import usuarioRoutes from './usuarioRoutes.js';
import productoRoutes from './productoRoutes.js';
import menuDelDiaRoutes from './menuDelDiaRoutes.js';
import historialAlmuerzoRoutes from './historialAlmuerzoRoutes.js';
import horarioAtencionRoutes from './horarioAtencionRoutes.js'
import promocionRoutes from './promocionRoutes.js';
import cateringRoutes from './cateringRoutes.js';

const router = express.Router();

router.use('/usuario', usuarioRoutes);
router.use('/producto', productoRoutes);
router.use('/menu', menuDelDiaRoutes);
router.use('/horarios', horarioAtencionRoutes);
router.use('/historial', historialAlmuerzoRoutes);
router.use('/promocion', promocionRoutes);
router.use('/catering', cateringRoutes);

export default router;