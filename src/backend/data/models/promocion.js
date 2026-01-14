import { DataTypes } from 'sequelize';
import { sequelize } from '../config/db.js';

const Promocion = sequelize.define('Promocion', {
    idPromocion: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false
    },
    titulo: {
        type: DataTypes.STRING(150),
        allowNull: false,
        validate: {
            notEmpty: {
                msg: 'El título es requerido'
            },
            len: {
                args: [3, 150],
                msg: 'El título debe tener entre 3 y 150 caracteres'
            }
        }
    },
    descripcion: {
        type: DataTypes.TEXT,
        allowNull: true,
        defaultValue: null
    },
    precio: {
        type: DataTypes.DECIMAL(8, 2),
        allowNull: false,
        validate: {
            isDecimal: {
                msg: 'El precio debe ser un valor decimal válido'
            },
            min: {
                args: [0],
                msg: 'El precio no puede ser negativo'
            }
        }
    },
    imagen: {
        type: DataTypes.STRING(255),
        allowNull: true,
        defaultValue: null
    },
    fecha_inicio: {
        type: DataTypes.DATEONLY,  // Solo fecha (sin hora)
        allowNull: false,
        validate: {
            notNull: {
                msg: 'La fecha de inicio es requerida'
            },
            isDate: {
                msg: 'Formato de fecha inválido'
            }
        }
    },
    fecha_fin: {
        type: DataTypes.DATEONLY,
        allowNull: false,
        validate: {
            notNull: {
                msg: 'La fecha de fin es requerida'
            },
            isDate: {
                msg: 'Formato de fecha inválido'
            },
            isAfterInicio(value) {
                if (new Date(value) <= new Date(this.fecha_inicio)) {
                    throw new Error('La fecha de fin debe ser posterior a la fecha de inicio');
                }
            }
        }
    },
    activo: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: true
    }
}, {
    tableName: 'promocion',
    timestamps: false,
    indexes: [
        {
            fields: ['fecha_inicio', 'fecha_fin']
        },
        {
            fields: ['activo']
        }
    ]
});

export default Promocion;