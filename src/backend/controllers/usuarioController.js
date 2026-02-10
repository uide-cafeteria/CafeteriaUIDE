import Usuario from '../data/models/usuario.js';
import admin from 'firebase-admin';
import jwt from 'jsonwebtoken';
import 'dotenv/config';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import bcrypt from 'bcrypt';
import { validationResult } from 'express-validator';
import crypto from 'crypto';
import { Sequelize } from 'sequelize';
import { GmailEmailService } from '../services/emailService.js'; // ← AJUSTA ESTA RUTA SI ES NECESARIO

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const SALT_ROUNDS = 12;

// Inicializa Firebase Admin
if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(
            join(__dirname, '../services/cafeteriauide-firebase.json')
        )
    });
}

// Instancia del servicio de email (se crea una sola vez)
const emailService = new GmailEmailService();

const usuarioController = {
    // Endpoint para registrar un cliente con Firebase (sin cambios)
    registroClienteFirebase: async (req, res) => {
        try {
            const { idToken } = req.body;
            if (!idToken) {
                return res.status(400).json({
                    status: false,
                    message: 'Token de identificación es requerido'
                });
            }

            const decoded = await admin.auth().verifyIdToken(idToken);
            const { email, name, uid } = decoded;

            let user = await Usuario.findOne({ where: { correo: email } });
            if (!user) {
                user = await Usuario.create({
                    username: name?.split(' ')[0].toLowerCase() || email.split('@')[0],
                    nombre: name || (name?.split(' ')[0] || email.split('@')[0]),
                    correo: email,
                    telefono: '0000000000',
                    codigoUnico: 'U' + Math.random().toString(36).slice(-4).toUpperCase(),
                    rol: 'cliente',
                    password_hash: null,
                    google_id: uid,
                    loyalty_token: crypto.randomUUID().replaceAll('-', '')
                });
            }

            const token = jwt.sign(
                { id: user.idUsuario, rol: user.rol },
                process.env.JWT_SECRET,
                { expiresIn: '8h' }
            );

            return res.status(200).json({
                status: true,
                message: 'Autenticacion exitosa',
                token,
                usuario: {
                    id: user.idUsuario,
                    username: user.username,
                    correo: user.correo,
                    telefono: user.telefono,
                    rol: user.rol,
                    codigoUnico: user.codigoUnico,
                    loyalty_token: user.loyalty_token
                }
            });
        } catch (error) {
            console.error('Firebase error:', error);
            return res.status(500).json({
                status: false,
                message: 'Error interno del servidor'
            });
        }
    },

    // Endpoint para registrar cliente por correo + contraseña + OTP
    registroClienteCorreo: async (req, res) => {
        try {
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json({
                    status: false,
                    errores: errors.array().map(e => e.msg)
                });
            }

            const { username, correo, telefono, contrasenia } = req.body;

            // Validación estricta de dominio UIDE
            const lowerCorreo = correo.toLowerCase().trim();
            const allowedDomains = ['@uide.edu.ec', '@estudiante.uide.edu.ec'];
            if (!allowedDomains.some(domain => lowerCorreo.endsWith(domain))) {
                return res.status(400).json({
                    status: false,
                    message: 'Solo se permiten correos institucionales de UIDE (@uide.edu.ec o @estudiante.uide.edu.ec)'
                });
            }

            // Verifica existencia
            let whereClause = { correo: lowerCorreo };
            if (telefono) {
                whereClause = { [Sequelize.Op.or]: [{ correo: lowerCorreo }, { telefono }] };
            }
            const existe = await Usuario.findOne({ where: whereClause });
            if (existe) {
                return res.status(409).json({
                    status: false,
                    message: existe.correo === lowerCorreo
                        ? 'Este correo ya está registrado'
                        : 'Este teléfono ya está registrado'
                });
            }

            // Generar OTP
            const otp = Math.floor(100000 + Math.random() * 900000).toString();
            const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutos

            // Hashear contraseña
            const hash = await bcrypt.hash(contrasenia, SALT_ROUNDS);

            // Crear usuario no verificado
            const user = await Usuario.create({
                username: username.trim(),
                nombre: username.trim(),
                correo: lowerCorreo,
                telefono: telefono || null,
                codigoUnico: 'U' + Math.random().toString(36).slice(-4).toUpperCase(),
                rol: 'cliente',
                password_hash: hash,
                loyalty_token: crypto.randomUUID().replaceAll('-', ''),
                email_verified: false,
                verification_code: otp,
                verification_code_expires: otpExpires
            });

            // Enviar OTP
            try {
                const mailOptions = {
                    to: lowerCorreo,
                    subject: 'Codigo de verificacion - La Cafeteria UIDE',
                    html: `
                        <h2>¡Bienvenido a La Cafetería UIDE!</h2>
                        <p>Tu código de verificación es:</p>
                        <h1 style="letter-spacing: 10px; font-size: 40px; text-align: center; background: #f5f5f5; padding: 15px; border-radius: 8px;">
                            ${otp}
                        </h1>
                        <p>Este código es válido por <strong>10 minutos</strong>.</p>
                        <p>No lo compartas con nadie.</p>
                        <p style="font-size: 12px; color: #666; margin-top: 20px;">
                            Si no solicitaste este registro, ignora este mensaje.
                        </p>
                    `
                };

                const emailResult = await emailService.sendEmail(mailOptions);

                if (!emailResult.success) {
                    await user.destroy();
                    return res.status(500).json({
                        status: false,
                        message: 'Error al enviar el código de verificación. Intenta nuevamente.'
                    });
                }

                return res.status(201).json({
                    status: true,
                    message: 'Cuenta creada. Revisa tu correo institucional para el código de verificación.',
                    userId: user.idUsuario
                });

            } catch (emailError) {
                console.error('Error enviando OTP:', emailError);
                await user.destroy();
                return res.status(500).json({
                    status: false,
                    message: 'Error al enviar el código. Intenta más tarde.'
                });
            }

        } catch (error) {
            console.error('Registro error:', error);
            return res.status(500).json({
                status: false,
                message: 'Error del servidor. Intenta más tarde'
            });
        }
    },

    // Nuevo endpoint: Verificar código OTP
    verificarCodigo: async (req, res) => {
        try {
            const { userId, codigo } = req.body;

            if (!userId || !codigo || codigo.length !== 6) {
                return res.status(400).json({
                    status: false,
                    message: 'userId y código de 6 dígitos son requeridos'
                });
            }

            const user = await Usuario.findByPk(userId);
            if (!user) {
                return res.status(404).json({
                    status: false,
                    message: 'Usuario no encontrado'
                });
            }

            if (user.email_verified) {
                return res.status(400).json({
                    status: false,
                    message: 'El correo ya está verificado'
                });
            }

            if (!user.verification_code || user.verification_code !== codigo) {
                return res.status(400).json({
                    status: false,
                    message: 'Código incorrecto'
                });
            }

            if (new Date() > user.verification_code_expires) {
                return res.status(400).json({
                    status: false,
                    message: 'El código ha expirado. Regístrate nuevamente.'
                });
            }

            // Verificado exitosamente
            user.email_verified = true;
            user.verification_code = null;
            user.verification_code_expires = null;
            await user.save();

            // Generar JWT
            const token = jwt.sign(
                { id: user.idUsuario, rol: user.rol },
                process.env.JWT_SECRET,
                { expiresIn: '30d' }
            );

            return res.status(200).json({
                status: true,
                message: 'Correo verificado correctamente. ¡Bienvenido!',
                token,
                usuario: {
                    id: user.idUsuario,
                    username: user.username,
                    correo: user.correo,
                    telefono: user.telefono,
                    rol: user.rol,
                    codigoUnico: user.codigoUnico,
                    loyalty_token: user.loyalty_token
                }
            });

        } catch (error) {
            console.error('Error verificando código:', error);
            return res.status(500).json({
                status: false,
                message: 'Error del servidor al verificar'
            });
        }
    },

    // Endpoint para autenticación de administrador (sin cambios)
    adminAuth: async (req, res) => {
        try {
            const { correo, contrasenia } = req.body;

            if (!correo || !contrasenia) {
                return res.status(400).json({
                    status: false,
                    message: 'Correo y contraseña son requeridos'
                });
            }

            const usuario = await Usuario.findOne({
                where: {
                    correo: correo.toLowerCase().trim(),
                    rol: 'administrador'
                }
            });
            if (!usuario) {
                return res.status(401).json({
                    status: false,
                    message: 'Credenciales inválidas'
                });
            }

            if (usuario.rol.toLowerCase() !== 'administrador') {
                return res.status(403).json({
                    status: false,
                    message: 'Acceso denegado'
                });
            }

            const valido = await bcrypt.compare(contrasenia, usuario.password_hash);
            if (!valido) {
                return res.status(401).json({
                    status: false,
                    message: 'Credenciales inválidas'
                });
            }

            const token = jwt.sign(
                { id: usuario.idUsuario, rol: usuario.rol },
                process.env.JWT_SECRET,
                { expiresIn: '8h' }
            );

            return res.status(200).json({
                status: true,
                message: 'Autenticación exitosa',
                token,
                admin: {
                    id: usuario.idUsuario,
                    username: usuario.username,
                    correo: usuario.correo,
                    rol: usuario.rol
                }
            });
        } catch (error) {
            console.error('Admin error:', error);
            return res.status(500).json({
                status: false,
                message: 'Error interno del servidor'
            });
        }
    },

    // Cerrar sesión administrador (sin cambios)
    logoutAdmin: async (req, res) => {
        try {
            res.clearCookie('token');
            return res.status(200).json({
                status: true,
                message: 'Sesión cerrada exitosamente'
            });
        } catch (error) {
            console.error('Logout error:', error);
            return res.status(500).json({
                status: false,
                message: 'Error al cerrar sesión'
            });
        }
    },

    // Login cliente (sin cambios)
    userAuth: async (req, res) => {
        try {
            const { correo, contrasenia } = req.body;

            if (!correo || !contrasenia) {
                return res.status(400).json({
                    status: false,
                    message: 'Correo y contraseña son requeridos'
                });
            }

            const usuario = await Usuario.findOne({
                where: {
                    correo: correo.toLowerCase().trim(),
                    rol: 'cliente'
                }
            });
            if (!usuario) {
                return res.status(401).json({
                    status: false,
                    message: 'Credenciales inválidas'
                });
            }

            if (usuario.rol.toLowerCase() !== 'cliente') {
                return res.status(403).json({
                    status: false,
                    message: 'Acceso denegado'
                });
            }

            const valido = await bcrypt.compare(contrasenia, usuario.password_hash);
            if (!valido) {
                return res.status(401).json({
                    status: false,
                    message: 'Credenciales inválidas'
                });
            }

            const token = jwt.sign(
                { id: usuario.idUsuario, rol: usuario.rol },
                process.env.JWT_SECRET,
                { expiresIn: '8h' }
            );

            return res.status(200).json({
                status: true,
                message: 'Autenticación exitosa',
                token,
                usuario: {
                    id: usuario.idUsuario,
                    username: usuario.username,
                    correo: usuario.correo,
                    rol: usuario.rol,
                    codigoUnico: usuario.codigoUnico,
                    loyalty_token: usuario.loyalty_token
                }
            });
        } catch (error) {
            console.error('Admin error: ', error);
            return res.status(500).json({
                status: false,
                message: 'Error interno del servidor'
            });
        }
    },
};

export default usuarioController;