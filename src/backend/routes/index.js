import express from 'express';
import usuarioRoutes from './usuarioRoutes.js';
import productoRoutes from './productoRoutes.js';
import menuDelDiaRoutes from './menuDelDiaRoutes.js';
import historialAlmuerzoRoutes from './historialAlmuerzoRoutes.js';
import promocionRoutes from './promocionRoutes.js';

const router = express.Router();

router.use('/usuario', usuarioRoutes);
router.use('/producto', productoRoutes);
router.use('/menu', menuDelDiaRoutes);
router.use('/historial', historialAlmuerzoRoutes);
router.use('/promocion', promocionRoutes);

export default router;