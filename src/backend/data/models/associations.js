// data/models/associations.js

import MenuDelDia from './menuDelDia.js';
import Producto from './producto.js';
import MenuDelDiaProducto from './menuDelDiaProducto.js';

export default function setupAssociations() {
    // Muchos a muchos: Menú del día ↔ Producto
    MenuDelDia.belongsToMany(Producto, {
        through: MenuDelDiaProducto,
        as: 'productos',
        foreignKey: 'idMenu',
        otherKey: 'idProducto'
    });

    Producto.belongsToMany(MenuDelDia, {
        through: MenuDelDiaProducto,
        as: 'menus_del_dia',
        foreignKey: 'idProducto',
        otherKey: 'idMenu'
    });

    // asociaciones explícitas en la tabla intermedia
    MenuDelDiaProducto.belongsTo(MenuDelDia, { foreignKey: 'idMenu' });
    MenuDelDiaProducto.belongsTo(Producto, { foreignKey: 'idProducto' });
    MenuDelDia.hasMany(MenuDelDiaProducto, { foreignKey: 'idMenu' });
    Producto.hasMany(MenuDelDiaProducto, { foreignKey: 'idProducto' });
}