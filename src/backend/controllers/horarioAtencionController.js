// controllers/horarioAtencionController.js
import HorarioAtencion from "../data/models/horarioAtencion.js";
import { Op, Sequelize } from "sequelize";

const horarioAtencionController = {

    // 1. Obtener horarios visibles para el público (solo los activos)
    obtenerHorariosPublicos: async (req, res) => {
        try {
            const horarios = await HorarioAtencion.findAll({
                where: { activo: true },
                attributes: [
                    "idHorario",
                    "ubicacion",
                    "dia_semana",
                    "hora_apertura",
                    "hora_cierre"
                ],
                order: [
                    ["ubicacion", "ASC"],
                    // Orden personalizado de días (Lunes → Viernes)
                    [Sequelize.fn("FIELD", Sequelize.col("dia_semana"),
                        "Lunes", "Martes", "Miércoles", "Jueves", "Viernes"), "ASC"]
                ]
            });

            res.status(200).json({
                status: true,
                message: "Horarios de atención públicos obtenidos",
                horarios
            });
        } catch (error) {
            console.error("Error al obtener horarios públicos:", error);
            res.status(500).json({
                status: false,
                message: "Error al obtener horarios",
                error: error.message
            });
        }
    },

    // 2. Obtener TODOS los horarios (para admin) - incluye inactivos
    obtenerTodosHorariosAdmin: async (req, res) => {
        try {
            if (req.usuario.rol !== "administrador") {
                return res.status(403).json({
                    status: false,
                    message: "Acceso denegado - solo administradores"
                });
            }

            const horarios = await HorarioAtencion.findAll({
                order: [
                    ["ubicacion", "ASC"],
                    [Sequelize.fn("FIELD", Sequelize.col("dia_semana"),
                        "Lunes", "Martes", "Miércoles", "Jueves", "Viernes"), "ASC"]
                ]
            });

            res.status(200).json({
                status: true,
                message: "Todos los horarios obtenidos (admin)",
                horarios
            });
        } catch (error) {
            console.error("Error al listar todos los horarios:", error);
            res.status(500).json({
                status: false,
                message: "Error al obtener horarios",
                error: error.message
            });
        }
    },

    // 3. Crear un nuevo horario (solo admin)
    crearHorario: async (req, res) => {
        try {
            if (req.usuario.rol !== "administrador") {
                return res.status(403).json({
                    status: false,
                    message: "Acceso denegado - solo administradores"
                });
            }

            const { ubicacion, dia_semana, hora_apertura, hora_cierre } = req.body;

            // Validación básica
            if (!ubicacion || !dia_semana || !hora_apertura || !hora_cierre) {
                return res.status(400).json({
                    status: false,
                    message: "Faltan campos obligatorios"
                });
            }

            const nuevoHorario = await HorarioAtencion.create({
                ubicacion,
                dia_semana,
                hora_apertura,
                hora_cierre,
                activo: true   // por defecto activo al crear
            });

            res.status(201).json({
                status: true,
                message: "Horario creado exitosamente",
                horario: nuevoHorario
            });
        } catch (error) {
            // Captura error de unicidad (violación de unique key)
            if (error.name === "SequelizeUniqueConstraintError") {
                return res.status(409).json({
                    status: false,
                    message: `Ya existe un horario para ${req.body.ubicacion} el día ${req.body.dia_semana}`
                });
            }

            console.error("Error al crear horario:", error);
            res.status(500).json({
                status: false,
                message: "Error al crear el horario",
                error: error.message
            });
        }
    },

    // 4. Actualizar / editar un horario (solo admin)
    actualizarHorario: async (req, res) => {
        try {
            if (req.usuario.rol !== "administrador") {
                return res.status(403).json({ status: false, message: "Acceso denegado" });
            }

            const { idHorario } = req.params;
            const { hora_apertura, hora_cierre, activo } = req.body;

            const horario = await HorarioAtencion.findByPk(idHorario);
            if (!horario) {
                return res.status(404).json({
                    status: false,
                    message: "Horario no encontrado"
                });
            }

            // Solo permitimos cambiar estos campos
            await horario.update({
                hora_apertura: hora_apertura ?? horario.hora_apertura,
                hora_cierre: hora_cierre ?? horario.hora_cierre,
                activo: activo !== undefined ? activo : horario.activo
            });

            res.status(200).json({
                status: true,
                message: "Horario actualizado correctamente",
                horario
            });
        } catch (error) {
            console.error("Error al actualizar horario:", error);
            res.status(500).json({
                status: false,
                message: "Error al actualizar el horario",
                error: error.message
            });
        }
    },

    // 5. Activar / desactivar un horario (toggle) - solo admin
    toggleEstadoHorario: async (req, res) => {
        try {
            if (req.usuario.rol !== "administrador") {
                return res.status(403).json({ status: false, message: "Acceso denegado" });
            }

            const { idHorario } = req.params;

            const horario = await HorarioAtencion.findByPk(idHorario);
            if (!horario) {
                return res.status(404).json({
                    status: false,
                    message: "Horario no encontrado"
                });
            }

            const estadoAnterior = horario.activo;
            horario.activo = !horario.activo;
            await horario.save();

            res.status(200).json({
                status: true,
                message: `Horario ${horario.activo ? "activado" : "desactivado"} correctamente`,
                horario: {
                    idHorario: horario.idHorario,
                    ubicacion: horario.ubicacion,
                    dia_semana: horario.dia_semana,
                    activo: horario.activo
                }
            });
        } catch (error) {
            console.error("Error al cambiar estado del horario:", error);
            res.status(500).json({
                status: false,
                message: "Error al cambiar estado",
                error: error.message
            });
        }
    },

    // 6. Eliminar un horario (solo admin) - preferiblemente solo si no está activo
    eliminarHorario: async (req, res) => {
        try {
            if (req.usuario.rol !== "administrador") {
                return res.status(403).json({ status: false, message: "Acceso denegado" });
            }

            const { idHorario } = req.params;

            const horario = await HorarioAtencion.findByPk(idHorario);
            if (!horario) {
                return res.status(404).json({
                    status: false,
                    message: "Horario no encontrado"
                });
            }

            if (horario.activo) {
                return res.status(400).json({
                    status: false,
                    message: "No se puede eliminar un horario activo. Desactívalo primero."
                });
            }

            await horario.destroy();

            res.status(200).json({
                status: true,
                message: "Horario eliminado correctamente"
            });
        } catch (error) {
            console.error("Error al eliminar horario:", error);
            res.status(500).json({
                status: false,
                message: "Error al eliminar el horario",
                error: error.message
            });
        }
    }
};

export default horarioAtencionController;