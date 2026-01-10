import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Plus, Trash2, ArrowLeft, Loader2 } from 'lucide-react';

export default function MenuProductos() {
    const { idMenu } = useParams();
    const navigate = useNavigate();

    const [menu, setMenu] = useState(null);
    const [allProducts, setAllProducts] = useState([]);
    const [menuProducts, setMenuProducts] = useState([]); // productos ya en el menú
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [adding, setAdding] = useState(null);
    const [removing, setRemoving] = useState(null);

    // Reutilizamos los estilos inline que ya tienes en Cafeteria
    const fixedImageStyle = (
        <style>{`
      .product-image-fixed {
        width: 100px;
        height: 100px;
        object-fit: cover;
        border-radius: 12px;
        box-shadow: 0 3px 10px rgba(0,0,0,0.15);
      }
    `}</style>
    );

    useEffect(() => {
        const fetchData = async () => {
            const token = localStorage.getItem('authToken');
            if (!token) {
                navigate('/login');
                return;
            }

            try {
                // 1. Obtener información del menú
                const menuRes = await fetch(`http://localhost:3001/api/menu/${idMenu}/productos`, {
                    headers: { Authorization: `Bearer ${token}` }
                });
                if (!menuRes.ok) throw new Error('No se pudo cargar el menú');
                const menuData = await menuRes.json();
                setMenu(menuData.menu);

                // 2. Obtener TODOS los productos disponibles
                const productsRes = await fetch('http://localhost:3001/api/producto/mostrar', {
                    headers: { Authorization: `Bearer ${token}` }
                });
                if (!productsRes.ok) throw new Error('No se pudieron cargar productos');
                const productsData = await productsRes.json();
                setAllProducts(productsData.productos || []);

                // 3. Obtener productos que YA están en este menú
                const menuProductsRes = await fetch(`http://localhost:3001/api/menu/${idMenu}/productos`, {
                    headers: { Authorization: `Bearer ${token}` }
                });
                if (!menuProductsRes.ok) throw new Error('No se pudieron cargar productos del menú');
                const menuProductsData = await menuProductsRes.json();
                setMenuProducts(menuProductsData.productos || []);

            } catch (err) {
                setError(err.message || 'Error al cargar datos');
            } finally {
                setLoading(false);
            }
        };

        fetchData();
    }, [idMenu, navigate]);

    const addProductToMenu = async (idProducto) => {
        setAdding(idProducto);
        const token = localStorage.getItem('authToken');

        try {
            const res = await fetch(`http://localhost:3001/api/menu/agregar/${idMenu}/producto`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    Authorization: `Bearer ${token}`
                },
                body: JSON.stringify({ idProducto })
            });

            if (!res.ok) throw new Error('No se pudo agregar el producto');

            // Actualizar lista local
            const productoAgregado = allProducts.find(p => p.idProducto === idProducto);
            setMenuProducts(prev => [...prev, productoAgregado]);
        } catch (err) {
            alert(err.message || 'Error al agregar producto');
        } finally {
            setAdding(null);
        }
    };

    const removeProductFromMenu = async (idProducto) => {
        setRemoving(idProducto);
        const token = localStorage.getItem('authToken');

        try {
            const res = await fetch(`http://localhost:3001/api/menu/eliminar/${idMenu}/producto/${idProducto}`, {
                method: 'DELETE',
                headers: { Authorization: `Bearer ${token}` }
            });

            if (!res.ok) throw new Error('No se pudo quitar el producto');

            // Actualizar lista local
            setMenuProducts(prev => prev.filter(p => p.idProducto !== idProducto));
        } catch (err) {
            alert(err.message || 'Error al quitar producto');
        } finally {
            setRemoving(null);
        }
    };

    const handleLogout = async () => {
        const token = localStorage.getItem('authToken');
        try {
            await fetch('http://localhost:3001/api/usuario/logout/admin', {
                method: 'POST',
                headers: { Authorization: `Bearer ${token}` }
            });
        } catch { }
        localStorage.removeItem('authToken');
        navigate('/login');
    };

    if (loading) {
        return (
            <div className="flex flex-col items-center justify-center h-screen gap-4 bg-gray-50">
                <Loader2 className="animate-spin text-blue-600" size={54} />
                <p className="text-2xl font-semibold text-gray-700">Cargando productos del menú...</p>
            </div>
        );
    }

    if (error || !menu) {
        return (
            <div className="p-8 text-center text-red-600">
                <h2 className="text-2xl font-bold">Error</h2>
                <p>{error || 'Menú no encontrado'}</p>
                <button
                    onClick={() => navigate('/cafeteria')}
                    className="mt-6 px-6 py-3 bg-blue-600 text-white rounded-lg"
                >
                    Volver a Cafetería
                </button>
            </div>
        );
    }

    return (
        <div className="cafeteria-container">

            {fixedImageStyle}

            {/* Header igual que en Cafeteria */}
            <div className="cafeteria-header">
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                    <div>
                        <h1 className="cafeteria-title">Cafetería Admin</h1>
                        <p className="cafeteria-subtitle">
                            Gestión de productos • {menu.nombre} ({menu.dia_semana})
                        </p>
                    </div>
                    <button onClick={handleLogout} className="btn-logout">
                        Cerrar sesión
                    </button>
                </div>
            </div>

            {/* Botón volver + título */}
            <div className="actions-bar" style={{ marginBottom: '24px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                    <button
                        onClick={() => navigate('/cafeteria')}
                        className="flex items-center gap-2 px-4 py-2 bg-gray-200 text-gray-800 rounded-lg hover:bg-gray-300"
                    >
                        <ArrowLeft size={20} /> Volver a Menús
                    </button>
                    <h2 className="actions-title">
                        Productos del menú: <span style={{ color: '#3b82f6' }}>{menu.nombre}</span>
                    </h2>
                </div>
            </div>

            {/* Sección: Productos actuales en el menú */}
            <div className="mb-12">
                <h3 className="text-2xl font-bold mb-6">Productos actuales ({menuProducts.length})</h3>

                {menuProducts.length === 0 ? (
                    <div style={{
                        background: "white",
                        borderRadius: "20px",
                        padding: "60px 30px",
                        boxShadow: "0 10px 30px rgba(0,0,0,0.1)",
                        textAlign: "center"
                    }}>
                        <p className="text-xl text-gray-600">Este menú aún no tiene productos agregados</p>
                        <p className="text-lg text-gray-500 mt-4">¡Comienza agregando desde la lista de abajo!</p>
                    </div>
                ) : (
                    <div className="table-container-expanded">
                        <table className="table-bordered">
                            <thead>
                                <tr>
                                    <th>Imagen</th>
                                    <th>Nombre</th>
                                    <th>Precio</th>
                                    <th>Precio Especial</th>
                                    <th>Promoción</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                {menuProducts.map(prod => (
                                    <tr key={prod.idProducto}>
                                        <td>
                                            <img
                                                src={prod.imagen || '/placeholder.jpg'}
                                                alt={prod.nombre}
                                                className="product-image-fixed"
                                                onError={e => e.target.src = '/placeholder.jpg'}
                                            />
                                        </td>
                                        <td className="font-semibold">{prod.nombre}</td>
                                        <td className="font-bold text-lg">${Number(prod.precio).toFixed(2)}</td>
                                        <td>
                                            {prod.menu_del_dia_productos?.precio_especial
                                                ? `$${Number(prod.menu_del_dia_productos.precio_especial).toFixed(2)}`
                                                : '—'}
                                        </td>
                                        <td>
                                            {prod.menu_del_dia_productos?.es_promocion ? (
                                                <span className="px-3 py-1 bg-green-100 text-green-800 rounded-full text-sm">
                                                    Sí
                                                </span>
                                            ) : (
                                                <span className="px-3 py-1 bg-gray-100 text-gray-800 rounded-full text-sm">
                                                    No
                                                </span>
                                            )}
                                        </td>
                                        <td>
                                            <button
                                                onClick={() => removeProductFromMenu(prod.idProducto)}
                                                disabled={removing === prod.idProducto}
                                                className="text-red-600 hover:text-red-800"
                                            >
                                                {removing === prod.idProducto ? (
                                                    <Loader2 className="animate-spin" size={20} />
                                                ) : (
                                                    <Trash2 size={20} />
                                                )}
                                            </button>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>

            {/* Sección: Productos disponibles para agregar */}
            <div>
                <h3 className="text-2xl font-bold mb-6">Productos disponibles para agregar</h3>

                <div className="table-container-expanded">
                    <table className="table-bordered">
                        <thead>
                            <tr>
                                <th>Imagen</th>
                                <th>Nombre</th>
                                <th>Categoría</th>
                                <th>Precio</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            {allProducts
                                .filter(p => !menuProducts.some(mp => mp.idProducto === p.idProducto))
                                .map(prod => (
                                    <tr key={prod.idProducto}>
                                        <td>
                                            <img
                                                src={prod.imagen || '/placeholder.jpg'}
                                                alt={prod.nombre}
                                                className="product-image-fixed"
                                                onError={e => e.target.src = '/placeholder.jpg'}
                                            />
                                        </td>
                                        <td className="font-semibold">{prod.nombre}</td>
                                        <td>{prod.categoria}</td>
                                        <td className="font-bold text-lg">${Number(prod.precio).toFixed(2)}</td>
                                        <td>
                                            <button
                                                onClick={() => addProductToMenu(prod.idProducto)}
                                                disabled={adding === prod.idProducto}
                                                className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 disabled:opacity-50 flex items-center gap-2"
                                            >
                                                {adding === prod.idProducto ? (
                                                    <>
                                                        <Loader2 className="animate-spin" size={18} />
                                                        Agregando...
                                                    </>
                                                ) : (
                                                    <>
                                                        <Plus size={18} />
                                                        Agregar
                                                    </>
                                                )}
                                            </button>
                                        </td>
                                    </tr>
                                ))}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
}