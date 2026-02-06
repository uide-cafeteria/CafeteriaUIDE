// controllers/solicitudCateringController.js
import SolicitudCatering from "../data/models/catering.js";
import Usuario from "../data/models/usuario.js";
import { Op, Sequelize } from "sequelize";

const solicitudCateringController = {

    // 1. Crear una nueva solicitud (usuario normal o invitado)
    crearSolicitud: async (req, res) => {
        try {
            const {
                nombre_completo,
                correo,
                telefono,
                fecha_evento,
                hora_evento,
                tipo_evento,
                cantidad_personas,
                descripcion,
            } = req.body;

            // Campos obligatorios
            if (!nombre_completo || !correo || !telefono || !fecha_evento || !tipo_evento) {
                return res.status(400).json({
                    status: false,
                    message: "Faltan campos obligatorios",
                });
            }

            // Si hay usuario autenticado, asociamos el idUsuario
            let idUsuario = null;
            if (req.usuario) {
                idUsuario = req.usuario.idUsuario;
            }

            const nuevaSolicitud = await SolicitudCatering.create({
                idUsuario,
                nombre_completo,
                correo,
                telefono,
                fecha_evento,
                hora_evento: hora_evento || null,
                tipo_evento,
                cantidad_personas: cantidad_personas || null,
                descripcion: descripcion || null,
                estado: "pendiente",
            });

            res.status(201).json({
                status: true,
                message: "Solicitud de catering creada exitosamente",
                solicitud: nuevaSolicitud,
            });
        } catch (error) {
            console.error("Error al crear solicitud catering:", error);
            res.status(500).json({
                status: false,
                message: "Error al crear la solicitud",
                error: error.message,
            });
        }
    },

    // 2. Listar todas las solicitudes (solo admin)
    listarTodasSolicitudes: async (req, res) => {
        try {
            if (req.usuario.rol !== "administrador") {
                return res.status(403).json({
                    status: false,
                    message: "Acceso denegado - solo administradores",
                });
            }

            const solicitudes = await SolicitudCatering.findAll({
                include: [
                    {
                        model: Usuario,
                        as: "usuario",
                        attributes: ["idUsuario", "username", "correo"],
                        required: false,
                    },
                    {
                        model: Usuario,
                        as: "administradorRespuesta",
                        attributes: ["idUsuario", "username"],
                        required: false,
                    },
                ],
                order: [["fecha_solicitud", "DESC"]],
            });

            res.status(200).json({
                status: true,
                message: "Solicitudes obtenidas con éxito",
                solicitudes,
            });
        } catch (error) {
            console.error("Error al listar solicitudes:", error);
            res.status(500).json({
                status: false,
                message: "Error al obtener las solicitudes",
                error: error.message,
            });
        }
    },

    // 3. Obtener una solicitud específica por ID (admin o el propio usuario)
    obtenerSolicitudPorId: async (req, res) => {
        try {
            const { idSolicitud } = req.params;

            const solicitud = await SolicitudCatering.findByPk(idSolicitud, {
                include: [
                    {
                        model: Usuario,
                        as: "usuario",
                        attributes: ["idUsuario", "username", "correo"],
                    },
                    {
                        model: Usuario,
                        as: "administradorRespuesta",
                        attributes: ["username"],
                    },
                ],
            });

            if (!solicitud) {
                return res.status(404).json({
                    status: false,
                    message: "Solicitud no encontrada",
                });
            }

            // Permitir al usuario dueño o al admin
            if (
                req.usuario.rol !== "administrador" &&
                solicitud.idUsuario !== req.usuario.idUsuario
            ) {
                return res.status(403).json({
                    status: false,
                    message: "No tienes permiso para ver esta solicitud",
                });
            }

            res.status(200).json({
                status: true,
                solicitud,
            });
        } catch (error) {
            console.error("Error al obtener solicitud:", error);
            res.status(500).json({
                status: false,
                message: "Error al obtener la solicitud",
                error: error.message,
            });
        }
    },

    // 4. Responder / actualizar estado de una solicitud (solo admin)
    responderSolicitud: async (req, res) => {
        try {
            if (req.usuario.rol !== "administrador") {
                return res.status(403).json({
                    status: false,
                    message: "Acceso denegado - solo administradores",
                });
            }

            const { idSolicitud } = req.params;
            const { estado, respuesta } = req.body;

            if (!estado || !["confirmada", "rechazada", "cancelada"].includes(estado)) {
                return res.status(400).json({
                    status: false,
                    message: "Estado inválido. Debe ser: confirmada, rechazada o cancelada",
                });
            }

            const solicitud = await SolicitudCatering.findByPk(idSolicitud);
            if (!solicitud) {
                return res.status(404).json({
                    status: false,
                    message: "Solicitud no encontrada",
                });
            }

            if (solicitud.estado !== "pendiente") {
                return res.status(400).json({
                    status: false,
                    message: "Esta solicitud ya ha sido respondida",
                });
            }

            await solicitud.update({
                estado,
                respuesta: respuesta || null,
                respondida_por: req.usuario.idUsuario,
            });

            res.status(200).json({
                status: true,
                message: `Solicitud ${estado} correctamente`,
                solicitud,
            });
        } catch (error) {
            console.error("Error al responder solicitud:", error);
            res.status(500).json({
                status: false,
                message: "Error al responder la solicitud",
                error: error.message,
            });
        }
    },

    // 5. Listar solicitudes del usuario autenticado (para el cliente)
    misSolicitudes: async (req, res) => {
        try {
            if (!req.usuario) {
                return res.status(401).json({
                    status: false,
                    message: "Debes iniciar sesión",
                });
            }

            const solicitudes = await SolicitudCatering.findAll({
                where: { idUsuario: req.usuario.idUsuario },
                order: [["fecha_solicitud", "DESC"]],
                include: [
                    {
                        model: Usuario,
                        as: "administradorRespuesta",
                        attributes: ["username"],
                    },
                ],
            });

            res.status(200).json({
                status: true,
                message: "Tus solicitudes obtenidas",
                solicitudes,
            });
        } catch (error) {
            console.error("Error al obtener mis solicitudes:", error);
            res.status(500).json({
                status: false,
                message: "Error al obtener tus solicitudes",
                error: error.message,
            });
        }
    },

    // 6. Cancelar solicitud (solo el usuario dueño y si está pendiente)
    cancelarSolicitud: async (req, res) => {
        try {
            const { idSolicitud } = req.params;

            const solicitud = await SolicitudCatering.findByPk(idSolicitud);
            if (!solicitud) {
                return res.status(404).json({
                    status: false,
                    message: "Solicitud no encontrada",
                });
            }

            if (solicitud.idUsuario !== req.usuario.idUsuario) {
                return res.status(403).json({
                    status: false,
                    message: "No eres el dueño de esta solicitud",
                });
            }

            if (solicitud.estado !== "pendiente") {
                return res.status(400).json({
                    status: false,
                    message: "Solo puedes cancelar solicitudes pendientes",
                });
            }

            await solicitud.update({ estado: "cancelada" });

            res.status(200).json({
                status: true,
                message: "Solicitud cancelada correctamente",
                solicitud,
            });
        } catch (error) {
            console.error("Error al cancelar solicitud:", error);
            res.status(500).json({
                status: false,
                message: "Error al cancelar la solicitud",
                error: error.message,
            });
        }
    },
};

export default solicitudCateringController;