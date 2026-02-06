// data/models/solicitudCatering.js
import { DataTypes } from "sequelize";
import { sequelize } from "../config/db.js";
import Usuario from "./usuario.js";

const SolicitudCatering = sequelize.define(
    "SolicitudCatering",
    {
        idSolicitud: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true,
        },
        idUsuario: {
            type: DataTypes.INTEGER,
            allowNull: true,
        },
        nombre_completo: {
            type: DataTypes.STRING(200),
            allowNull: false,
        },
        correo: {
            type: DataTypes.STRING(150),
            allowNull: false,
        },
        telefono: {
            type: DataTypes.STRING(20),
            allowNull: false,
        },
        fecha_evento: {
            type: DataTypes.DATEONLY,
            allowNull: false,
        },
        hora_evento: {
            type: DataTypes.TIME,
            allowNull: true,
        },
        tipo_evento: {
            type: DataTypes.STRING(100),
            allowNull: false,
        },
        cantidad_personas: {
            type: DataTypes.INTEGER,
            allowNull: true,
        },
        descripcion: {
            type: DataTypes.TEXT,
            allowNull: true,
        },
        estado: {
            type: DataTypes.ENUM("pendiente", "confirmada", "rechazada", "cancelada"),
            defaultValue: "pendiente",
            allowNull: false,
        },
        fecha_solicitud: {
            type: DataTypes.DATE,
            defaultValue: sequelize.literal("CURRENT_TIMESTAMP"),
            allowNull: false,
        },
        respondida_por: {
            type: DataTypes.INTEGER,
            allowNull: true,
        },
        respuesta: {
            type: DataTypes.TEXT,
            allowNull: true,
        },
    },
    {
        tableName: "solicitud_catering",
        timestamps: false,
        indexes: [
            { fields: ["idUsuario"] },
            { fields: ["fecha_evento"] },
            { fields: ["estado"] },
            { fields: ["respondida_por"] },
        ],
    }
);

// Relaciones
SolicitudCatering.belongsTo(Usuario, {
    foreignKey: "idUsuario",
    as: "usuario",
});

SolicitudCatering.belongsTo(Usuario, {
    foreignKey: "respondida_por",
    as: "administradorRespuesta",
});

// Relaciones inversas (útiles para consultas)
Usuario.hasMany(SolicitudCatering, {
    foreignKey: "idUsuario",
    as: "solicitudes_catering",
});

Usuario.hasMany(SolicitudCatering, {
    foreignKey: "respondida_por",
    as: "solicitudes_respondidas",
});

export default SolicitudCatering;