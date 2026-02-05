// data/models/horarioAtencion.js  (versión con mapeo explícito)
import { DataTypes } from "sequelize";
import { sequelize } from "../config/db.js";

const HorarioAtencion = sequelize.define(
    "HorarioAtencion",
    {
        idHorario: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true,
            field: "idHorario",
        },
        ubicacion: {
            type: DataTypes.ENUM("cafeteria", "rooftop"),
            allowNull: false,
            field: "ubicacion",
        },
        dia_semana: {
            type: DataTypes.ENUM(
                "Lunes",
                "Martes",
                "Miércoles",
                "Jueves",
                "Viernes"
            ),
            allowNull: false,
            field: "dia_semana",        // ← snake_case en BD
        },
        hora_apertura: {
            type: DataTypes.TIME,
            allowNull: false,
            field: "hora_apertura",
        },
        hora_cierre: {
            type: DataTypes.TIME,
            allowNull: false,
            field: "hora_cierre",
        },
    },
    {
        tableName: "horario_atencion",
        timestamps: false,
        indexes: [
            {
                unique: true,
                fields: ["ubicacion", "dia_semana"],
                name: "unico_dia_ubicacion",
            },
            { fields: ["ubicacion"] },
            { fields: ["dia_semana"] },
        ],
    }
);

export default HorarioAtencion;