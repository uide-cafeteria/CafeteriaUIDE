import MenuDelDia from '../data/models/menuDelDia.js';
import MenuDelDiaProducto from '../data/models/menuDelDiaProducto.js';
import Producto from '../data/models/producto.js';
import { Op } from 'sequelize';
import { sendNotificationToTopic } from '../config/firebase.js';

const menuDelDiaController = {

    // 1. Obtener el menú ACTIVO del día actual (para clientes/app)
    obtenerMenuActivoHoy: async (req, res) => {
        try {
            const hoy = new Date();
            const diaSemanaMap = {
                0: 'Domingo',   // No usado
                1: 'Lunes',
                2: 'Martes',
                3: 'Miércoles',
                4: 'Jueves',
                5: 'Viernes',
                6: 'Sábado'     // No usado
            };
            const diaSemana = diaSemanaMap[hoy.getDay()];

            const menuActivo = await MenuDelDia.findOne({
                where: {
                    activo: true,
                    dia_semana: diaSemana
                },
                include: [{
                    model: Producto,
                    as: 'productos',
                    through: {
                        attributes: ['precio_especial', 'es_promocion']
                    },
                    where: { activo: true },
                    required: false
                }],
                order: [['creado_en', 'DESC']]
            });

            if (!menuActivo) {
                return res.status(404).json({
                    status: false,
                    message: 'No hay menú activo para hoy'
                });
            }

            res.status(200).json({
                status: true,
                message: 'Menú del día obtenido con éxito',
                menu: menuActivo
            });
        } catch (error) {
            console.error(error);
            res.status(500).json({
                status: false,
                message: 'Error al obtener el menú del día',
                error: error.message
            });
        }
    },

    // 2. Crear un nuevo menú completo (solo admin)
    crearMenu: async (req, res) => {
        try {
            if (req.usuario.rol !== 'administrador') {
                return res.status(403).json({ status: false, message: 'Acceso denegado' });
            }

            const { nombre, dia_semana, fecha_especifica } = req.body;

            const menu = await MenuDelDia.create({
                nombre,
                dia_semana,
                fecha_especifica: fecha_especifica || null,
                activo: false
            });

            res.status(201).json({
                status: true,
                message: 'Menú creado con éxito',
                menu
            });
        } catch (error) {
            res.status(500).json({
                status: false,
                message: 'Error al crear el menú',
                error: error.message
            });
        }
    },

    // 3. Agregar un producto a un menú específico (solo admin)
    agregarProductoAlMenu: async (req, res) => {
        try {
            if (req.usuario.rol !== 'administrador') {
                return res.status(403).json({ status: false, message: 'Acceso denegado' });
            }

            const { idMenu } = req.params;
            const { idProducto, precio_especial, es_promocion } = req.body;

            const producto = await Producto.findByPk(idProducto);
            if (!producto || !producto.activo) {
                return res.status(404).json({
                    status: false,
                    message: 'Producto no existe o no está activo'
                });
            }

            const menu = await MenuDelDia.findByPk(idMenu);
            if (!menu) {
                return res.status(404).json({ status: false, message: 'Menú no encontrado' });
            }

            const [relacion, created] = await MenuDelDiaProducto.findOrCreate({
                where: { idMenu, idProducto },
                defaults: {
                    precio_especial,
                    es_promocion: es_promocion || false,
                }
            });

            if (!created) {
                await relacion.update({ precio_especial, es_promocion });
            }

            res.status(200).json({
                status: true,
                message: 'Producto agregado/actualizado en el menú',
                relacion
            });
        } catch (error) {
            res.status(500).json({
                status: false,
                message: 'Error al agregar producto al menú',
                error: error.message
            });
        }
    },

    // 4. Activar un menú (desactiva los otros del mismo día) → AQUÍ ESTÁ LA MODIFICACIÓN
    activarMenu: async (req, res) => {
        try {
            if (req.usuario.rol !== 'administrador') {
                return res.status(403).json({ status: false, message: 'Acceso denegado' });
            }

            const { idMenu } = req.params;

            const menu = await MenuDelDia.findByPk(idMenu);
            if (!menu) {
                return res.status(404).json({ status: false, message: 'Menú no encontrado' });
            }

            const wasActive = menu.activo;  // Guardamos el estado anterior

            // Desactivar todos los menús del mismo día_semana (excepto el actual)
            await MenuDelDia.update(
                { activo: false },
                {
                    where: {
                        dia_semana: menu.dia_semana,
                        idMenu: { [Op.ne]: idMenu }
                    }
                }
            );

            // Cambiar estado del menú seleccionado
            menu.activo = !menu.activo;  // Toggle (activa si estaba inactivo, desactiva si estaba activo)
            await menu.save();

            // Enviar notificación SOLO cuando se ACTIVA (de inactivo → activo)
            if (!wasActive && menu.activo) {
                try {
                    await sendNotificationToTopic(
                        'menus_diarios',                           // topic al que los usuarios deben suscribirse
                        '🍽️ ¡Nuevo Menú del Día Disponible!',
                        `Menú para ${menu.dia_semana}: ${menu.nombre}`,
                        {
                            tipo: 'menu_del_dia',
                            menu_id: menu.idMenu.toString(),
                            dia_semana: menu.dia_semana,
                            timestamp: new Date().toISOString()
                        }
                    );
                    console.log(`Notificación enviada para menú activado: ${menu.nombre}`);
                } catch (notifError) {
                    console.error('Error al enviar notificación FCM:', notifError);
                    // No bloqueamos la respuesta al cliente si falla la notificación
                }
            }

            res.status(200).json({
                status: true,
                message: `Menú "${menu.nombre}" ${menu.activo ? 'activado' : 'desactivado'} para ${menu.dia_semana}`,
                menu
            });
        } catch (error) {
            console.error('Error en activarMenu:', error);
            res.status(500).json({
                status: false,
                message: 'Error al cambiar estado del menú',
                error: error.message
            });
        }
    },

    // 5. Listar todos los menús (para panel admin)
    listarTodosLosMenus: async (req, res) => {
        try {
            if (req.usuario.rol !== 'administrador') {
                return res.status(403).json({ status: false, message: 'Acceso denegado' });
            }

            const menus = await MenuDelDia.findAll({
                include: [{
                    model: Producto,
                    as: 'productos',
                    through: {
                        attributes: ['precio_especial', 'es_promocion']
                    }
                }],
                order: [['dia_semana', 'ASC'], ['nombre', 'ASC']]
            });

            res.status(200).json({
                status: true,
                message: 'Menús obtenidos con éxito',
                menus
            });
        } catch (error) {
            res.status(500).json({
                status: false,
                message: 'Error al listar menús',
                error: error.message
            });
        }
    },

    // 6. Eliminar un menú completo
    eliminarMenu: async (req, res) => {
        try {
            if (req.usuario.rol !== 'administrador') {
                return res.status(403).json({ status: false, message: 'Acceso denegado' });
            }

            const { idMenu } = req.params;

            const menu = await MenuDelDia.findByPk(idMenu);
            if (!menu) {
                return res.status(404).json({ status: false, message: 'Menú no encontrado' });
            }

            if (menu.activo) {
                return res.status(400).json({
                    status: false,
                    message: 'No se puede eliminar un menú activo. Desactívalo primero.'
                });
            }

            await menu.destroy();

            res.status(200).json({
                status: true,
                message: 'Menú eliminado con éxito'
            });
        } catch (error) {
            res.status(500).json({
                status: false,
                message: 'Error al eliminar menú',
                error: error.message
            });
        }
    },

    // 7. Quitar un producto de un menú
    quitarProductoDelMenu: async (req, res) => {
        try {
            if (req.usuario.rol !== 'administrador') {
                return res.status(403).json({ status: false, message: 'Acceso denegado' });
            }

            const { idMenu, idProducto } = req.params;

            const eliminado = await MenuDelDiaProducto.destroy({
                where: { idMenu, idProducto }
            });

            if (eliminado === 0) {
                return res.status(404).json({
                    status: false,
                    message: 'Producto no encontrado en este menú'
                });
            }

            res.status(200).json({
                status: true,
                message: 'Producto eliminado del menú'
            });
        } catch (error) {
            res.status(500).json({
                status: false,
                message: 'Error al quitar producto',
                error: error.message
            });
        }
    },

    // 8. Lista todos los productos en un menú diario mediante su id
    listarProductosPorMenu: async (req, res) => {
        try {
            const { idMenu } = req.params;

            const menu = await MenuDelDia.findByPk(idMenu);
            if (!menu) {
                return res.status(404).json({
                    status: false,
                    message: 'Menú no encontrado'
                });
            }

            const productos = await MenuDelDia.findOne({
                where: { idMenu },
                attributes: ['idMenu', 'nombre', 'dia_semana', 'activo'],
                include: [{
                    model: Producto,
                    as: 'productos',
                    through: {
                        attributes: ['precio_especial', 'es_promocion']
                    },
                    attributes: [
                        'idProducto',
                        'nombre',
                        'descripcion',
                        'precio',
                        'categoria',
                        'imagen',
                        'activo'
                    ],
                    where: { activo: true },
                    required: false
                }]
            });

            const productosLista = productos?.productos || [];

            res.status(200).json({
                status: true,
                message: 'Productos del menú obtenidos con éxito',
                menu: {
                    idMenu: menu.idMenu,
                    nombre: menu.nombre,
                    dia_semana: menu.dia_semana,
                    activo: menu.activo
                },
                productos: productosLista
            });
        } catch (error) {
            console.error('Error al listar productos del menú:', error);
            res.status(500).json({
                status: false,
                message: 'Error al obtener los productos del menú',
                error: error.message
            });
        }
    }
};

export default menuDelDiaController;