import Promocion from '../data/models/promocion.js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';
import { Op } from 'sequelize';

dotenv.config();

// Para usar __dirname en ES Modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const promocionController = {
    // 1. Obtener promociones activas (para usuarios - frontend público)
    obtenerPromocionesActivas: async (req, res) => {
        try {
            const hoy = new Date();
            hoy.setHours(0, 0, 0, 0);

            const promociones = await Promocion.findAll({
                where: {
                    activo: true,
                    fecha_inicio: { [Op.lte]: hoy },
                    fecha_fin: { [Op.gte]: hoy }
                },
                order: [['fecha_inicio', 'ASC']],
                attributes: ['idPromocion', 'titulo', 'descripcion', 'imagen', 'fecha_inicio', 'fecha_fin']
            });

            const baseUrl = `${req.protocol}://${req.get('host')}`;

            const promocionesConUrlCompleta = promociones.map(p => {
                const data = p.toJSON();
                if (data.imagen && !data.imagen.startsWith('http')) {
                    data.imagen = `${baseUrl}${data.imagen}`;
                }
                return data;
            });

            res.status(200).json({
                status: true,
                message: 'Promociones activas obtenidas exitosamente',
                promociones: promocionesConUrlCompleta
            });
        } catch (error) {
            console.error('Error al obtener promociones activas:', error);
            res.status(500).json({
                status: false,
                message: 'Error al obtener las promociones activas'
            });
        }
    },

    // 2. Obtener TODAS las promociones (solo ADMIN)
    obtenerPromocionesAdmin: async (req, res) => {
        try {
            if (req.usuario.rol !== 'administrador') {
                return res.status(403).json({ status: false, message: 'Acceso denegado' });
            }

            const promociones = await Promocion.findAll({
                order: [['fecha_inicio', 'DESC']]
            });

            const baseUrl = `${req.protocol}://${req.get('host')}`;

            const promocionesConUrlCompleta = promociones.map(p => {
                const data = p.toJSON();
                if (data.imagen && !data.imagen.startsWith('http')) {
                    data.imagen = `${baseUrl}${data.imagen}`;
                }
                return data;
            });

            res.status(200).json({
                status: true,
                message: 'Todas las promociones obtenidas exitosamente',
                promociones: promocionesConUrlCompleta
            });
        } catch (error) {
            console.error('Error al obtener todas las promociones:', error);
            res.status(500).json({
                status: false,
                message: 'Error al obtener el listado de promociones'
            });
        }
    },

    // 3. Crear nueva promoción (ADMIN)
    crearPromocion: async (req, res) => {
        try {
            if (req.usuario.rol !== 'administrador') {
                return res.status(403).json({ status: false, message: 'Acceso denegado' });
            }

            const { titulo, descripcion, fecha_inicio, fecha_fin, activo } = req.body;

            if (!titulo || !fecha_inicio || !fecha_fin) {
                return res.status(400).json({
                    status: false,
                    message: 'Faltan campos obligatorios: titulo, fecha_inicio, fecha_fin'
                });
            }

            let imagen = null;

            // Guardar siempre URL relativa o completa en BD
            if (req.file) {
                imagen = `${process.env.IMAGES_PATH}/${req.file.filename}`;
            }
            // Si enviaron URL externa
            else if (req.body.imagen && req.body.imagen.trim() !== '') {
                const url = req.body.imagen.trim();
                imagen = url.startsWith('http') ? url : `${process.env.IMAGES_PATH}/${url}`;
            }

            const promocion = await Promocion.create({
                titulo: titulo.trim(),
                descripcion: descripcion?.trim() || null,
                imagen,
                fecha_inicio,
                fecha_fin,
                activo: activo !== 'false',
            });

            const baseUrl = `${req.protocol}://${req.get('host')}`;
            const promocionResponse = promocion.toJSON();
            if (promocionResponse.imagen && !promocionResponse.imagen.startsWith('http')) {
                promocionResponse.imagen = `${baseUrl}${promocionResponse.imagen}`;
            }

            res.status(201).json({
                status: true,
                message: 'Promoción creada con éxito',
                promocion: promocionResponse
            });
        } catch (error) {
            console.error('Error al crear promoción:', error);

            // Borrar archivo temporal si se subió y falló
            if (req.file) {
                const filePath = path.join(process.cwd(), process.env.IMAGES_PATH, req.file.filename);
                fs.unlink(filePath, (err) => err && console.error('Error borrando archivo temporal:', err));
            }

            res.status(500).json({
                status: false,
                message: 'Error al crear la promoción',
                error: error.message
            });
        }
    },

    // 4. Actualizar promoción (ADMIN) - con manejo de imagen antigua
    actualizarPromocion: async (req, res) => {
        try {
            if (req.usuario.rol !== 'administrador') {
                return res.status(403).json({ status: false, message: 'Acceso denegado' });
            }

            const { idPromocion } = req.params;
            const { titulo, descripcion, fecha_inicio, fecha_fin, activo } = req.body;

            const promocion = await Promocion.findByPk(idPromocion);
            if (!promocion) {
                return res.status(404).json({ status: false, message: 'Promoción no encontrada' });
            }

            let nuevaImagen = promocion.imagen;

            // Caso 1: Nueva imagen subida → borrar antigua si era local
            if (req.file) {
                if (promocion.imagen && !promocion.imagen.startsWith('http')) {
                    const oldPath = path.join(__dirname, '..', process.env.IMAGES_PATH, path.basename(promocion.imagen));
                    fs.unlink(oldPath, (err) => err && console.error('Error borrando imagen antigua:', err));
                }
                nuevaImagen = `${process.env.IMAGES_PATH}/${req.file.filename}`;
            }
            // Caso 2: Nueva URL externa
            else if (req.body.imagen && req.body.imagen.trim() !== '') {
                const url = req.body.imagen.trim();
                if (url.startsWith('http')) {
                    if (promocion.imagen && !promocion.imagen.startsWith('http')) {
                        const oldPath = path.join(__dirname, '..', process.env.IMAGES_PATH, path.basename(promocion.imagen));
                        fs.unlink(oldPath, () => { });
                    }
                    nuevaImagen = url;
                }
            }

            // Actualizar campos
            promocion.titulo = titulo?.trim() || promocion.titulo;
            promocion.descripcion = descripcion?.trim() || null;
            promocion.fecha_inicio = fecha_inicio || promocion.fecha_inicio;
            promocion.fecha_fin = fecha_fin || promocion.fecha_fin;
            promocion.activo = activo !== undefined ? (activo !== 'false') : promocion.activo;
            promocion.imagen = nuevaImagen;

            await promocion.save();

            const baseUrl = `${req.protocol}://${req.get('host')}`;
            const promocionResponse = promocion.toJSON();
            if (promocionResponse.imagen && !promocionResponse.imagen.startsWith('http')) {
                promocionResponse.imagen = `${baseUrl}${promocionResponse.imagen}`;
            }

            res.status(200).json({
                status: true,
                message: 'Promoción actualizada con éxito',
                promocion: promocionResponse
            });
        } catch (error) {
            console.error('Error actualizando promoción:', error);

            // Limpiar archivo si se subió y falló
            if (req.file) {
                const filePath = path.join(process.cwd(), process.env.IMAGES_PATH, req.file.filename);
                fs.unlink(filePath, () => { });
            }

            res.status(500).json({
                status: false,
                message: 'Error al actualizar la promoción',
                error: error.message
            });
        }
    },

    // 5. Cambiar estado activo/inactivo (ADMIN)
    actualizarEstadoPromocion: async (req, res) => {
        try {
            if (req.usuario.rol !== 'administrador') {
                return res.status(403).json({ status: false, message: 'Acceso denegado' });
            }

            const { idPromocion } = req.params;

            const promocion = await Promocion.findByPk(idPromocion);
            if (!promocion) {
                return res.status(404).json({ status: false, message: 'Promoción no encontrada' });
            }

            if (promocion.activo != true) {
                promocion.activo = true;
                await promocion.save();
            } else {
                promocion.activo = false;
                await promocion.save();
            }

            res.status(200).json({
                status: true,
                message: `Promoción "${promocion.titulo}" estado cambiado`,
                promocion
            });
        } catch (error) {
            res.status(500).json({
                status: false,
                message: 'Error al cambiar el estado de la promoción',
                error: error.message
            });
        }
    }
};

export default promocionController;