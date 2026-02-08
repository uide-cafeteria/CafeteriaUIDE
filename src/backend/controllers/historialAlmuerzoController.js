import HistorialAlmuerzo from "../data/models/historialAlmuerzo.js";
import Usuario from "../data/models/usuario.js";
import { Op } from 'sequelize';

const historialAlmuerzoController = {

    // mostrar el historial para el usuario
    mostrarHistorialUsuario: async (req, res) => {
        try {
            const idUsuario = req.usuario.idUsuario;

            const historial = await HistorialAlmuerzo.findAll({
                where: { idUsuario },
                attributes: ['fecha', 'es_gratis', 'fecha_registro'],
                include: [
                    { model: Usuario, as: 'registradoPor', attributes: ['nombre'], required: false }
                ],
                order: [['fecha', 'DESC']]
            });

            // CÁLCULO DEL PROGRESO
            const pagados = historial.filter(h => !h.es_gratis).length;
            const gratisObtenidos = historial.filter(h => h.es_gratis).length;
            const hoy = new Date().toISOString().split('T')[0];
            const yaConsumioHoy = historial.some(h => h.fecha === hoy);
            const tieneGratisHoy = pagados % 10 === 0 && pagados > 0 && !yaConsumioHoy;
            const faltan = tieneGratisHoy ? 0 : (10 - (pagados % 10));

            res.status(200).json({
                status: true,
                message: 'Historial obtenido exitosamente',
                data: {
                    historial,
                    progreso: {
                        pagados,
                        gratis_obtenidos: gratisObtenidos,
                        total_almuerzos: historial.length,
                        faltan_para_gratis: faltan,
                        tiene_gratis_hoy: tieneGratisHoy,
                        ya_consumio_hoy: yaConsumioHoy
                    }
                }
            });

        } catch (error) {
            console.error("Error en mostrarHistorialUsuario:", error);
            res.status(500).json({
                status: false,
                message: 'Error al obtener historial',
                error: error.message
            });
        }
    },

    // mostrar el historial para el admin (filtrado por usuario)
    mostrarHistorialAdmin: async (req, res) => {
        try {
            if (req.usuario.rol !== 'administrador') {
                return res.status(403).json({ status: false, message: 'Acceso denegado' });
            }

            const idUsuario = req.params.idUsuario;

            // Obtener el historial para administradores
            const historial = await HistorialAlmuerzo.findAll({
                where: { idUsuario },
                attributes: ['fecha', 'es_gratis', 'fecha_registro'],
                include: [
                    {
                        model: Usuario,
                        as: 'cliente',
                        attributes: ['nombre', 'correo', 'codigoUnico'],
                        required: false
                    },
                    {
                        model: Usuario,
                        as: 'registradoPor',
                        attributes: ['nombre'],
                        required: false
                    }
                ]
            });

            res.status(200).json({
                status: true,
                message: 'Historial obtenido exitosamente',
                historial
            });
        } catch (error) {
            res.status(500).json({
                status: false,
                message: 'Error al mostrar el historial de almuerzos',
                error
            });
            console.log(error);
        };
    },

    // Mostrar historial global para el admin
    mostrarHistorialGlobalAdmin: async (req, res) => {
        try {
            if (req.usuario.rol !== 'administrador') {
                return res.status(403).json({
                    status: false,
                    message: 'Acceso denegado'
                });
            }

            const historial = await HistorialAlmuerzo.findAll({
                order: [['fecha_registro', 'DESC']], // lo más reciente primero
                include: [
                    {
                        model: Usuario,
                        as: 'cliente',
                        attributes: ['idUsuario', 'nombre', 'codigoUnico'],
                        required: true
                    },
                    {
                        model: Usuario,
                        as: 'registradoPor',
                        attributes: ['idUsuario', 'nombre'],
                        required: true
                    }
                ],
                attributes: [
                    'idHistorial',
                    'fecha',
                    'fecha_registro',
                    'es_gratis'
                ]
            });

            res.json({
                status: true,
                historial
            });

        } catch (error) {
            console.error("Error al obtener historial global admin:", error);
            res.status(500).json({
                status: false,
                message: 'Error al cargar el historial global',
                error: error.message
            });
        }
    },

    registrarAlmuerzo: async (req, res) => {
        try {
            if (req.usuario.rol !== 'administrador') {
                return res.status(403).json({ status: false, message: 'Acceso denegado' });
            }

            const { loyalty_token } = req.body;

            if (!loyalty_token || loyalty_token.trim() === '') {
                return res.status(400).json({
                    status: false,
                    message: 'El QR (loyalty_token) es requerido'
                });
            }

            const estudiante = await Usuario.findOne({
                where: {
                    loyalty_token: loyalty_token.trim(),
                    activo: true
                },
                attributes: ['idUsuario', 'nombre', 'correo']
            });

            if (!estudiante) {
                return res.status(404).json({
                    status: false,
                    message: 'Estudiante no encontrado o cuenta inactiva'
                });
            }

            const hoy = new Date().toISOString().split('T')[0];

            // 1. Encontrar el último almuerzo GRATIS del estudiante
            const ultimoGratis = await HistorialAlmuerzo.findOne({
                where: {
                    idUsuario: estudiante.idUsuario,
                    es_gratis: true
                },
                order: [['fecha_registro', 'DESC']], // el más reciente
                attributes: ['fecha_registro']
            });

            // 2. Contar SOLO los almuerzos PAGADOS después del último gratis (o todos si nunca ha tenido gratis)
            const wherePagados = {
                idUsuario: estudiante.idUsuario,
                es_gratis: false
            };

            if (ultimoGratis) {
                wherePagados.fecha_registro = {
                    [Op.gt]: ultimoGratis.fecha_registro  // > fecha del último gratis
                };
            }

            const pagadosDesdeUltimoGratis = await HistorialAlmuerzo.count({
                where: wherePagados
            });

            // 3. El siguiente almuerzo será gratis si ya lleva 9 pagados desde el último gratis
            // (porque +1 = 10)
            const esGratisHoy = (pagadosDesdeUltimoGratis + 1) % 10 === 0;

            // 4. Registrar el almuerzo
            const nuevoAlmuerzo = await HistorialAlmuerzo.create({
                idUsuario: estudiante.idUsuario,
                registrado_por: req.usuario.idUsuario,
                es_gratis: esGratisHoy,
                fecha: hoy,
            });

            // 5. Calcular progreso para la respuesta
            const pagadosTotales = await HistorialAlmuerzo.count({
                where: { idUsuario: estudiante.idUsuario, es_gratis: false }
            });

            const gratisTotales = await HistorialAlmuerzo.count({
                where: { idUsuario: estudiante.idUsuario, es_gratis: true }
            });

            // Para mostrar "faltan X para el próximo gratis"
            const faltanParaProximo = esGratisHoy ? 10 : (10 - ((pagadosDesdeUltimoGratis + 1) % 10));

            res.status(201).json({
                status: true,
                message: esGratisHoy
                    ? '¡ALMUERZO GRATIS REGISTRADO! Completó 10 almuerzos → contador reiniciado'
                    : 'Almuerzo registrado correctamente',
                data: {
                    estudiante: {
                        id: estudiante.idUsuario,
                        nombre: estudiante.nombre
                    },
                    almuerzo: {
                        fecha: hoy,
                        es_gratis: esGratisHoy
                    },
                    progreso: {
                        pagados_desde_ultimo_gratis: pagadosDesdeUltimoGratis + 1,
                        faltan_para_proximo_gratis: faltanParaProximo,
                        pagados_totales: pagadosTotales,
                        gratis_totales: gratisTotales
                    }
                }
            });

        } catch (error) {
            console.error("Error completo en registrarAlmuerzo:", error);
            res.status(500).json({
                status: false,
                message: 'Error al registrar almuerzo',
                error: error.message || 'Error interno del servidor'
            });
        }
    },

    //Endpoint para buscar al usuario por el loyalty_token
    buscarPorToken: async (req, res) => {
        try {
            const { token } = req.params;

            if (!token || token.trim() === '') {
                return res.status(400).json({
                    status: false,
                    message: 'Token requerido'
                });
            }

            const usuario = await Usuario.findOne({
                where: {
                    loyalty_token: token.trim(),
                    activo: true
                },
                attributes: ['idUsuario', 'nombre', 'codigoUnico', 'correo']
            });

            if (!usuario) {
                return res.status(404).json({
                    status: false,
                    message: 'Usuario no encontrado o cuenta inactiva'
                });
            }

            res.json({
                status: true,
                message: 'Usuario encontrado',
                usuario: {
                    idUsuario: usuario.idUsuario,
                    nombre: usuario.nombre,
                    codigoUnico: usuario.codigoUnico || null,
                    correo: usuario.correo
                }
            });

        } catch (error) {
            res.status(500).json({
                status: false,
                message: 'Error al buscar usuario por token',
                error
            });
        }
    }
}

export default historialAlmuerzoController;