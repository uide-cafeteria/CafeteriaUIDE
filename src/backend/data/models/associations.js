// data/models/associations.js
import MenuDelDia from './menuDelDia.js';
import Producto from './producto.js';
import MenuDelDiaProducto from './menuDelDiaProducto.js';

export function setupMenuAssociations() {
    // Menú → muchos Productos (a través de la tabla intermedia)
    MenuDelDia.belongsToMany(Producto, {
        through: MenuDelDiaProducto,
        foreignKey: 'idMenu',
        otherKey: 'idProducto',
        as: 'productos'  // ← Alias que usarás en los includes
    });

    // Producto → muchos Menús
    Producto.belongsToMany(MenuDelDia, {
        through: MenuDelDiaProducto,
        foreignKey: 'idProducto',
        otherKey: 'idMenu',
        as: 'menus'
    });
}