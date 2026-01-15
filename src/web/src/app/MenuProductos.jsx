import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Plus, Trash2, ArrowLeft, Loader2 } from 'lucide-react';

export default function MenuProductos() {
    const { idMenu } = useParams();
    const navigate = useNavigate();

    const [menu, setMenu] = useState(null);
    const [allProducts, setAllProducts] = useState([]);
    const [menuProducts, setMenuProducts] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [adding, setAdding] = useState(null);
    const [removing, setRemoving] = useState(null);

    // ────────────────────────────────────────────────
    // Estilos globales copiados y adaptados de MenuDiarioPage
    // ────────────────────────────────────────────────
    const globalStyles = (
        <style>{`
      .cafeteria-container { 
        padding: 20px; 
        min-height: 100vh; 
        background: #f8fafc; 
      }
      .cafeteria-header {
        background: linear-gradient(135deg, #1e293b, #0f172a);
        padding: 32px 40px;
        border-radius: 20px;
        margin-bottom: 24px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        color: white;
      }
      .cafeteria-title { 
        font-size: 36px; 
        font-weight: 800; 
        margin: 0; 
      }
      .cafeteria-subtitle { 
        font-size: 18px; 
        opacity: 0.9; 
        margin-top: 8px; 
      }
      .btn-logout {
        background: #dc2626 !important;
        color: white !important;
        padding: 12px 24px;
        border-radius: 14px;
        border: none;
        cursor: pointer;
        font-weight: 600;
        font-size: 15px;
        transition: all 0.2s ease;
      }
      .btn-logout:hover { 
        background: #b91c1c !important; 
        transform: scale(1.05); 
      }
      .actions-bar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 18px 25px;
        margin: 18px 0;
        background: #ffffff;
        border-radius: 14px;
        box-shadow: 0 3px 10px rgba(0,0,0,0.1);
      }
      .actions-title { 
        font-size: 22px; 
        font-weight: 700; 
        color: #0f172a; 
        margin: 0; 
      }
      .btn-back {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 12px 20px;
        background: #e2e8f0;
        color: #475569;
        border: none;
        border-radius: 12px;
        cursor: pointer;
        font-weight: 600;
        transition: 0.3s;
      }
      .btn-back:hover { 
        background: #cbd5e1; 
        transform: translateY(-2px); 
      }
      .btn-add {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 12px 20px;
        background: #3b82f6;
        color: white;
        border: none;
        border-radius: 12px;
        cursor: pointer;
        font-weight: 600;
        transition: 0.3s;
      }
      .btn-add:hover { 
        background: #2563eb; 
        transform: translateY(-2px); 
      }
      .btn-remove {
        background: #ef4444;
        color: white;
        border: none;
        padding: 8px 14px;
        border-radius: 10px;
        cursor: pointer;
        font-weight: 600;
        transition: 0.2s;
      }
      .btn-remove:hover:not(:disabled) { 
        background: #dc2626; 
        transform: scale(1.05); 
      }
      .table-bordered {
        border-collapse: collapse;
        width: 100%;
        background: #ffffff;
        border-radius: 12px;
        overflow: hidden;
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
      }
      .table-bordered th {
        background: #f1f5f9;
        padding: 14px;
        border-bottom: 2px solid #e2e8f0;
        font-weight: 600;
        color: #334155;
        text-align: left;
      }
      .table-bordered td {
        padding: 16px 12px;
        border-bottom: 1px solid #e5e7eb;
        vertical-align: middle;
      }
      tr:hover { background: #f9fafb; }
      .product-image-fixed {
        width: 80px;
        height: 80px;
        object-fit: cover;
        border-radius: 10px;
        box-shadow: 0 3px 10px rgba(0,0,0,0.15);
      }
      .badge {
        padding: 6px 12px;
        border-radius: 9999px;
        font-size: 0.875rem;
        font-weight: 600;
      }
      .badge-yes { background: #dcfce7; color: #166534; }
      .badge-no  { background: #f3f4f6; color: #374151; }
      .empty-state {
        background: white;
        border-radius: 20px;
        padding: 60px 30px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        text-align: center;
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
                // Menú + productos ya asociados
                const menuRes = await fetch(`http://localhost:3001/api/menu/${idMenu}/productos`, {
                    headers: { Authorization: `Bearer ${token}` }
                });
                if (!menuRes.ok) throw new Error('No se pudo cargar el menú');
                const menuData = await menuRes.json();
                setMenu(menuData.menu);
                setMenuProducts(menuData.productos || []);

                // Todos los productos disponibles
                const productsRes = await fetch('http://localhost:3001/api/producto/mostrar', {
                    headers: { Authorization: `Bearer ${token}` }
                });
                if (!productsRes.ok) throw new Error('No se pudieron cargar productos');
                const productsData = await productsRes.json();
                setAllProducts(productsData.productos || []);

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

            if (!res.ok) {
                const errData = await res.json();
                throw new Error(errData.message || 'No se pudo agregar');
            }

            const productoAgregado = allProducts.find(p => p.idProducto === idProducto);
            if (productoAgregado) {
                setMenuProducts(prev => [...prev, productoAgregado]);
            }
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
            {globalStyles}

            {/* Header idéntico */}
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

            {/* Barra de acciones */}
            <div className="actions-bar" style={{ marginBottom: '32px' }}>
                <button
                    onClick={() => navigate('/cafeteria')}
                    className="btn-back"
                >
                    <ArrowLeft size={20} /> Volver a Menús
                </button>

                <h2 className="actions-title">
                    Productos del menú: <span style={{ color: '#3b82f6' }}>{menu.nombre}</span>
                </h2>
            </div>

            {/* Productos actuales */}
            <div className="mb-16">
                <h3 className="text-2xl font-bold mb-6 text-gray-800">
                    Productos actuales ({menuProducts.length})
                </h3>

                {menuProducts.length === 0 ? (
                    <div className="empty-state">
                        <p className="text-xl text-gray-600">Este menú aún no tiene productos agregados</p>
                        <p className="text-lg text-gray-500 mt-4">
                            ¡Comienza agregando desde la lista de abajo!
                        </p>
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
                                                onError={e => { e.target.src = '/placeholder.jpg'; }}
                                            />
                                        </td>
                                        <td className="font-semibold">{prod.nombre}</td>
                                        <td className="font-bold text-lg">
                                            ${Number(prod.precio).toFixed(2)}
                                        </td>
                                        <td>
                                            {prod.menu_del_dia_productos?.precio_especial
                                                ? `$${Number(prod.menu_del_dia_productos.precio_especial).toFixed(2)}`
                                                : '—'}
                                        </td>
                                        <td>
                                            {prod.menu_del_dia_productos?.es_promocion ? (
                                                <span className="badge badge-yes">Sí</span>
                                            ) : (
                                                <span className="badge badge-no">No</span>
                                            )}
                                        </td>
                                        <td>
                                            <button
                                                onClick={() => removeProductFromMenu(prod.idProducto)}
                                                disabled={removing === prod.idProducto}
                                                className="btn-remove"
                                            >
                                                {removing === prod.idProducto ? (
                                                    <Loader2 className="animate-spin" size={20} />
                                                ) : (
                                                    'Quitar'
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

            {/* Productos disponibles */}
            <div>
                <h3 className="text-2xl font-bold mb-6 text-gray-800">
                    Productos disponibles para agregar
                </h3>

                {allProducts.length === menuProducts.length ? (
                    <div className="empty-state">
                        <p className="text-xl text-gray-600">No hay más productos disponibles</p>
                    </div>
                ) : (
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
                                                    onError={e => { e.target.src = '/placeholder.jpg'; }}
                                                />
                                            </td>
                                            <td className="font-semibold">{prod.nombre}</td>
                                            <td>{prod.categoria || '—'}</td>
                                            <td className="font-bold text-lg">
                                                ${Number(prod.precio).toFixed(2)}
                                            </td>
                                            <td>
                                                <button
                                                    onClick={() => addProductToMenu(prod.idProducto)}
                                                    disabled={adding === prod.idProducto}
                                                    className="btn-add"
                                                >
                                                    {adding === prod.idProducto ? (
                                                        <>
                                                            <Loader2 className="animate-spin" size={18} />
                                                            Agregando...
                                                        </>
                                                    ) : (
                                                        <>
                                                            <Plus size={18} /> Agregar
                                                        </>
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
        </div>
    );
}