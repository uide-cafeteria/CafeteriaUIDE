import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Edit, Plus, X, DollarSign, Loader2, Calendar, History } from 'lucide-react';
import '../styles/cafeteria.css';

export default function Cafeteria({ onLogout }) {
  const [activeTab, setActiveTab] = useState('productos');

  const fixedImageStyle = (
    <style>{`
      .product-image-fixed {
        width: 80px;
        height: 80px;
        object-fit: cover;
        border-radius: 12px;
        box-shadow: 0 3px 10px rgba(0,0,0,0.15);
      }
    `}</style>
  );

  const tableBorderStyle = (
    <style>{`
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
      }
      .table-bordered td {
        padding: 16px 12px;
        border-bottom: 1px solid #e5e7eb;
        vertical-align: middle;
      }
      tr:hover { background: #f9fafb; }
      .cafeteria-container { padding: 20px; min-height: 100vh; background: #f8fafc; }

      .cafeteria-header {
        background: linear-gradient(135deg, #1e293b, #0f172a);
        padding: 32px 40px;
        border-radius: 20px;
        margin-bottom: 24px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        color: white;
      }
      .cafeteria-title { font-size: 36px; font-weight: 800; margin: 0; }
      .cafeteria-subtitle { font-size: 18px; opacity: 0.9; margin-top: 8px; }

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

      .navbar-horizontal {
        display: flex;
        justify-content: center;
        gap: 20px;
        margin: 30px 0;
        flex-wrap: wrap;
      }
      .tab-button {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 16px 32px;
        background: #e2e8f0;
        color: #475569;
        border: none;
        border-radius: 18px;
        font-size: 17px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        box-shadow: 0 6px 15px rgba(0,0,0,0.1);
        min-width: 220px;
      }
      .tab-button:hover {
        background: #cbd5e1;
        transform: translateY(-4px);
        box-shadow: 0 12px 25px rgba(0,0,0,0.2);
      }
      .tab-button.active {
        background: linear-gradient(135deg, #3b82f6, #2563eb);
        color: white;
        box-shadow: 0 10px 30px rgba(59,130,246,0.4);
        transform: translateY(-2px);
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
      .actions-title { font-size: 22px; font-weight: 700; color: #0f172a; }
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
      .btn-add:hover { background: #2563eb; transform: translateY(-2px); }

      .btn-edit {
        background: #facc15;
        border: none;
        padding: 10px 16px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        gap: 6px;
        font-weight: 600;
        cursor: pointer;
        transition: 0.3s;
      }
      .btn-edit:hover { background: #eab308; transform: scale(1.05); }

      .switch { position: relative; display: inline-block; width: 52px; height: 28px; }
      .slider { position: absolute; inset: 0; background: #cbd5e1; border-radius: 28px; transition: .3s; }
      .slider:before { content: ""; position: absolute; width: 22px; height: 22px; left: 3px; top: 3px; background: white; border-radius: 50%; transition: .3s; box-shadow: 0 2px 6px rgba(0,0,0,0.3); }
      input:checked + .slider { background: #22c55e; }
      input:checked + .slider:before { transform: translateX(24px); }
    `}</style>
  );

  const navigate = useNavigate();

  const [products, setProducts] = useState([]);
  const [menusDelDia, setMenusDelDia] = useState([]);
  const [loadingProductos, setLoadingProductos] = useState(true);
  const [loadingMenus, setLoadingMenus] = useState(true);
  const [error, setError] = useState('');

  const [showModal, setShowModal] = useState(false);
  const [editingItem, setEditingItem] = useState(null); // puede ser producto o menú
  const [itemType, setItemType] = useState('producto'); // 'producto' o 'menu'

  const [formData, setFormData] = useState({
    name: '',
    descripcion: '',
    precio: '',
    categoria: 'Desayuno',
    ubicacion: 'cafeteria',
    activo: true,
    dia_semana: 'Lunes',
    imageFile: null,
    imagePreview: '',
    imageUrl: ''
  });

  const [submitting, setSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState('');
  const [submitSuccess, setSubmitSuccess] = useState('');
  const [togglingProduct, setTogglingProduct] = useState(null);
  const [togglingMenu, setTogglingMenu] = useState(null);

  const categories = ['Desayuno', 'Almuerzo', 'Postre', 'Otro'];
  const diasSemana = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];

  // Cargar productos
  useEffect(() => {
    if (activeTab === 'productos') {
      const fetchProducts = async () => {
        try {
          const token = localStorage.getItem('authToken');
          const res = await fetch('http://localhost:3001/api/producto/mostrar', {
            headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) }
          });
          if (!res.ok) throw new Error();
          const data = await res.json();
          const productosListos = (data.productos || []).map(p => ({
            idProducto: p.idProducto,
            nombre: p.nombre,
            name: p.nombre,
            descripcion: p.descripcion || '',
            precio: p.precio,
            categoria: p.categoria,
            ubicacion: p.ubicacion || 'cafeteria',
            imagen: p.imagen || '/placeholder.jpg',
            image: p.imagen || '/placeholder.jpg',
            activo: p.activo ?? true
          }));
          setProducts(productosListos.reverse());
        } catch (err) {
          console.error(err);
          setError('Error al cargar productos');
        } finally {
          setLoadingProductos(false);
        }
      };
      fetchProducts();
    }
  }, [activeTab]);

  // Cargar menús del día
  useEffect(() => {
    if (activeTab === 'menu') {
      const fetchMenus = async () => {
        try {
          const token = localStorage.getItem('authToken');
          const res = await fetch('http://localhost:3001/api/menu/mostrar/admin', {
            headers: { Authorization: `Bearer ${token}` }
          });
          if (!res.ok) throw new Error();
          const data = await res.json();
          setMenusDelDia(data.menus || []);
        } catch (err) {
          console.error(err);
          setError('Error al cargar menús');
        } finally {
          setLoadingMenus(false);
        }
      };
      fetchMenus();
    }
  }, [activeTab]);

  const handleLogout = async () => {
    const token = localStorage.getItem('authToken');
    try {
      await fetch('http://localhost:3001/api/usuario/logout/admin', {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}` }
      });
    } catch (err) { }
    localStorage.removeItem('authToken');
    if (onLogout) onLogout();
    navigate('/login');
  };

  const openModal = (type = 'producto', item = null) => {
    setItemType(type);
    setEditingItem(item);

    if (type === 'menu') {
      if (item) {
        setFormData({
          name: item.nombre,
          dia_semana: item.dia_semana,
          activo: item.activo,
          imageFile: null,
          imagePreview: '',
          imageUrl: ''
        });
      } else {
        setFormData({
          name: '',
          dia_semana: 'Lunes',
          activo: true,
          imageFile: null,
          imagePreview: '',
          imageUrl: ''
        });
      }
    } else {
      // producto
      if (item) {
        setFormData({
          name: item.nombre,
          descripcion: item.descripcion || '',
          precio: item.precio,
          categoria: item.categoria,
          ubicacion: item.ubicacion,
          activo: item.activo,
          imageFile: null,
          imagePreview: item.imagen,
          imageUrl: item.imagen
        });
      } else {
        setFormData({
          name: '',
          descripcion: '',
          precio: '',
          categoria: 'Desayuno',
          ubicacion: 'cafeteria',
          activo: true,
          imageFile: null,
          imagePreview: '',
          imageUrl: ''
        });
      }
    }
    setShowModal(true);
    setSubmitError('');
    setSubmitSuccess('');
  };

  const toggleStatus = async (product) => {
    setTogglingProduct(product.idProducto);
    const token = localStorage.getItem('authToken');
    const fd = new FormData();
    fd.append('nombre', product.nombre);
    fd.append('descripcion', product.descripcion || '');
    fd.append('precio', product.precio);
    fd.append('categoria', product.categoria);
    fd.append('ubicacion', product.ubicacion);
    fd.append('activo', !product.activo);
    fd.append('imagen', product.imagen);

    try {
      const res = await fetch(`http://localhost:3001/api/producto/actualizar/${product.idProducto}`, {
        method: 'PUT',
        headers: { ...(token ? { Authorization: `Bearer ${token}` } : {}) },
        body: fd
      });
      if (!res.ok) throw new Error();
      setProducts(prev => prev.map(p => p.idProducto === product.idProducto ? { ...p, activo: !p.activo } : p));
    } catch (err) {
      alert('No se pudo cambiar el estado');
    } finally {
      setTogglingProduct(null);
    }
  };

  const toggleMenuStatus = async (menu) => {
    setTogglingMenu(menu.idMenu);
    const token = localStorage.getItem('authToken');

    try {
      const res = await fetch(`http://localhost:3001/api/menu/${menu.idMenu}/activar`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`
        },
        body: JSON.stringify({ activo: !menu.activo })
      });
      if (!res.ok) throw new Error();
      setMenusDelDia(prev => prev.map(m => m.idMenu === menu.idMenu ? { ...m, activo: !m.activo } : m));
    } catch (err) {
      alert('No se pudo cambiar el estado del menú');
    } finally {
      setTogglingMenu(null);
    }
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setFormData(prev => ({
        ...prev,
        imageFile: file,
        imagePreview: URL.createObjectURL(file),
        imageUrl: ''
      }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSubmitError('');
    setSubmitSuccess('');
    setSubmitting(true);

    const token = localStorage.getItem('authToken');

    try {
      let url, method, body;

      if (itemType === 'menu') {
        const payload = {
          nombre: formData.name,
          dia_semana: formData.dia_semana,
          activo: formData.activo
        };

        if (editingItem) {
          url = `http://localhost:3001/api/menu/actualizar/${editingItem.idMenu}`;
          method = 'PUT';
        } else {
          url = 'http://localhost:3001/api/menu/crear'; // ← Tu endpoint solicitado
          method = 'POST';
        }
        body = JSON.stringify(payload);
        const headers = { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` };

        const res = await fetch(url, { method, headers, body });
        const data = await res.json();
        if (!res.ok) throw new Error(data.message || 'Error');

        if (editingItem) {
          setMenusDelDia(prev => prev.map(m => m.idMenu === editingItem.idMenu ? { ...m, ...data.menu } : m));
          setSubmitSuccess('Menú actualizado');
        } else {
          setMenusDelDia(prev => [data.menu, ...prev]);
          setSubmitSuccess('Menú creado correctamente');
        }
      } else {
        // Producto (código original)
        const fd = new FormData();
        fd.append('nombre', formData.name);
        fd.append('descripcion', formData.descripcion || '');
        fd.append('precio', parseFloat(formData.precio) || 0);
        fd.append('categoria', formData.categoria);
        fd.append('ubicacion', formData.ubicacion);
        fd.append('activo', formData.activo);
        if (formData.imageFile) fd.append('imagen', formData.imageFile);
        else if (formData.imageUrl?.trim()) fd.append('imagen', formData.imageUrl.trim());

        url = editingItem
          ? `http://localhost:3001/api/producto/actualizar/${editingItem.idProducto}`
          : 'http://localhost:3001/api/producto/crear';

        method = editingItem ? 'PUT' : 'POST';

        const res = await fetch(url, {
          method,
          headers: { ...(token ? { Authorization: `Bearer ${token}` } : {}) },
          body: fd
        });

        const data = await res.json();
        if (!res.ok) throw new Error(data.message || 'Error');

        const nuevo = data.producto;

        if (editingItem) {
          setProducts(prev => prev.map(p => p.idProducto === editingItem.idProducto ? { ...p, ...nuevo, image: nuevo.imagen } : p));
          setSubmitSuccess('Producto actualizado');
        } else {
          setProducts(prev => [{ idProducto: nuevo.idProducto, ...nuevo, image: nuevo.imagen, activo: nuevo.activo ?? true }, ...prev]);
          setSubmitSuccess('Producto creado');
        }
      }

      setShowModal(false);
    } catch (err) {
      setSubmitError(err.message || 'Error al guardar');
    } finally {
      setSubmitting(false);
    }
  };

  if (loadingProductos && activeTab === 'productos') {
    return (
      <div className="flex flex-col items-center justify-center h-screen gap-4 bg-gray-50">
        <Loader2 className="animate-spin text-blue-600" size={54} />
        <p className="text-2xl font-semibold text-gray-700">Cargando...</p>
      </div>
    );
  }

  return (
    <div className="cafeteria-container">

      {fixedImageStyle}
      {tableBorderStyle}

      <div className="cafeteria-header">
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <div>
            <h1 className="cafeteria-title">Cafetería Admin</h1>
            <p className="cafeteria-subtitle">Gestiona tu menú</p>
          </div>
          <button onClick={handleLogout} className="btn-logout">
            Cerrar sesión
          </button>
        </div>
      </div>

      {/* NAVBAR HORIZONTAL */}
      <div className="navbar-horizontal">
        <button
          className={`tab-button ${activeTab === 'productos' ? 'active' : ''}`}
          onClick={() => setActiveTab('productos')}
        >
          Lista de Productos
        </button>
        <button
          className={`tab-button ${activeTab === 'menu' ? 'active' : ''}`}
          onClick={() => setActiveTab('menu')}
        >
          Menú Diario
        </button>
        <button
          className={`tab-button ${activeTab === 'historial' ? 'active' : ''}`}
          onClick={() => setActiveTab('historial')}
        >
          Historial de Almuerzos
        </button>
      </div>

      {/* PESTAÑA: LISTA DE PRODUCTOS */}
      {activeTab === 'productos' && (
        <>
          <div className="actions-bar">
            <h2 className="actions-title">Lista de Productos</h2>
            <button onClick={() => openModal('producto')} className="btn-add">
              <Plus size={20} /> Agregar Producto
            </button>
          </div>

          {error && <p style={{ color: 'red' }}>{error}</p>}

          <div className="table-container-expanded">
            <table className="table-bordered">
              <thead>
                <tr>
                  <th>Imagen</th>
                  <th>Nombre</th>
                  <th>Categoría</th>
                  <th>Descripción</th>
                  <th>Precio</th>
                  <th>Ubicación</th>
                  <th>Estado</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                {products.length === 0 ? (
                  <tr>
                    <td colSpan="8" className="text-center py-16 text-gray-500 text-lg">
                      No hay productos registrados.
                    </td>
                  </tr>
                ) : (
                  products.map(product => (
                    <tr key={product.idProducto}>
                      <td>
                        <img
                          src={product.imagen}
                          alt={product.nombre}
                          className="product-image-fixed"
                          onError={e => e.target.src = '/placeholder.jpg'}
                        />
                      </td>
                      <td className="font-semibold">{product.nombre}</td>
                      <td>{product.categoria}</td>
                      <td className="text-gray-600">{product.descripcion || 'Sin descripción'}</td>
                      <td className="font-bold text-lg">${Number(product.precio).toFixed(2)}</td>
                      <td>
                        <span className="px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm">
                          {product.ubicacion}
                        </span>
                      </td>
                      <td>
                        <span className={`badge ${product.activo ? "on" : "off"}`}>
                          {product.activo ? "Activo" : "Inactivo"}
                        </span>
                      </td>
                      <td style={{ verticalAlign: "middle", padding: "20px 12px" }}>
                        <div style={{ display: "flex", alignItems: "center", justifyContent: "center", gap: "14px" }}>
                          <button className="btn-edit" onClick={() => openModal('producto', product)}>
                            <Edit size={18} /> Editar
                          </button>
                          <label className="switch">
                            <input
                              type="checkbox"
                              checked={product.activo}
                              disabled={togglingProduct === product.idProducto}
                              onChange={() => toggleStatus(product)}
                            />
                            <span className="slider"></span>
                          </label>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </>
      )}

      {/* PESTAÑA: MENÚ DIARIO */}
      {activeTab === 'menu' && (
        <>
          <div className="actions-bar">
            <h2 className="actions-title">Menú Diario</h2>
            <button onClick={() => openModal('menu')} className="btn-add">
              <Plus size={20} /> Agregar Menú
            </button>
          </div>

          {loadingMenus ? (
            <div className="flex flex-col items-center justify-center py-20">
              <Loader2 className="animate-spin text-blue-600" size={54} />
            </div>
          ) : menusDelDia.length === 0 ? (
            <div style={{ background: "white", borderRadius: "20px", padding: "60px 30px", boxShadow: "0 10px 30px rgba(0,0,0,0.1)", textAlign: "center" }}>
              <Calendar size={120} className="text-blue-600 mx-auto mb-8 opacity-80" />
              <p className="text-xl text-gray-600">Aún no has creado ningún menú del día</p>
              <p className="text-lg text-gray-500 mt-6">¡Empieza agregando uno!</p>
            </div>
          ) : (
            <div className="table-container-expanded">
              <table className="table-bordered">
                <thead>
                  <tr>
                    <th>Día de la semana</th>
                    <th>Nombre del menú</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  {menusDelDia.map(menu => (
                    <tr key={menu.idMenu}>
                      <td className="font-semibold text-lg">{menu.dia_semana}</td>
                      <td>{menu.nombre}</td>
                      <td>
                        <span className={`badge ${menu.activo ? "on" : "off"}`}>
                          {menu.activo ? "Activo" : "Inactivo"}
                        </span>
                      </td>
                      <td style={{ verticalAlign: "middle", padding: "20px 12px" }}>
                        <div style={{ display: "flex", alignItems: "center", justifyContent: "center", gap: "14px", flexWrap: "wrap" }}>
                          <button
                            className="btn-edit"
                            onClick={() => navigate(`/cafeteria/menu/${menu.idMenu}/productos`)}
                          >
                            <Plus size={18} /> Productos
                          </button>

                          <button
                            className="btn-edit"
                            onClick={() => openModal('menu', menu)}
                          >
                            <Edit size={18} /> Editar Menú
                          </button>

                          <label className="switch">
                            <input
                              type="checkbox"
                              checked={menu.activo}
                              disabled={togglingMenu === menu.idMenu}
                              onChange={() => toggleMenuStatus(menu)}
                            />
                            <span className="slider"></span>
                          </label>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </>
      )}

      {/* PESTAÑA: HISTORIAL */}
      {activeTab === 'historial' && (
        <div style={{ textAlign: "center", padding: "120px 20px", background: "white", borderRadius: "20px", boxShadow: "0 10px 30px rgba(0,0,0,0.1)" }}>
          <History size={100} className="text-green-600 mx-auto mb-8" />
          <h2 style={{ fontSize: "34px", fontWeight: "800", color: "#1e293b" }}>Historial de Almuerzos</h2>
          <p className="text-xl text-gray-600 mt-6">Aquí verás el historial de pedidos</p>
        </div>
      )}

      {/* MODAL */}
      {showModal && (
        <>
          <style>{`
            .modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.55); display: flex; justify-content: center; align-items: center; backdrop-filter: blur(6px); z-index: 1000; animation: fadeIn .3s ease; }
            @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
            .modal-content { background: white; padding: 32px; border-radius: 20px; width: 90%; max-width: 500px; box-shadow: 0 20px 40px rgba(0,0,0,0.2); animation: pop .3s ease; }
            @keyframes pop { from { transform: scale(0.9); opacity: 0; } to { transform: scale(1); opacity: 1; } }
            .modal-close { background: #dc2626; border: none; padding: 10px 14px; border-radius: 10px; color: white; cursor: pointer; font-weight: bold; }
            .modal-close:hover { background: #b91c1c; transform: scale(1.05); }
            .modal-input, .modal-select { width: 100%; padding: 12px 14px; border: 2px solid #e2e8f0; border-radius: 12px; margin-top: 8px; margin-bottom: 18px; font-size: 16px; transition: border 0.3s; }
            .modal-input:focus, .modal-select:focus { outline: none; border-color: #3b82f6; box-shadow: 0 0 0 4px rgba(59,130,246,0.15); }
            .modal-label { font-weight: 600; color: #1e293b; font-size: 15px; }
            .btn-submit { width: 100%; padding: 14px; background: linear-gradient(135deg, #3b82f6, #2563eb); border: none; border-radius: 12px; color: white; font-size: 18px; font-weight: 700; cursor: pointer; margin-top: 20px; transition: .3s; }
            .btn-submit:hover { transform: translateY(-3px); box-shadow: 0 10px 20px rgba(59,130,246,0.3); }
            .btn-submit:disabled { opacity: 0.7; cursor: not-allowed; }
          `}</style>

          <div className="modal-overlay" onClick={() => setShowModal(false)}>
            <div className="modal-content" onClick={e => e.stopPropagation()}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "24px" }}>
                <h2 style={{ fontSize: "26px", fontWeight: "800", color: "#1e293b" }}>
                  {itemType === 'menu'
                    ? (editingItem ? "Editar Menú Diario" : "Nuevo Menú Diario")
                    : (editingItem ? "Editar Producto" : "Nuevo Producto")
                  }
                </h2>
                <button className="modal-close" onClick={() => setShowModal(false)}>
                  X
                </button>
              </div>

              {submitSuccess && <p style={{ color: "green", fontWeight: "bold", textAlign: "center", marginBottom: "15px" }}>{submitSuccess}</p>}
              {submitError && <p style={{ color: "red", fontWeight: "bold", textAlign: "center", marginBottom: "15px" }}>{submitError}</p>}

              <form onSubmit={handleSubmit}>
                <label className="modal-label">Nombre</label>
                <input className="modal-input" type="text" name="name" value={formData.name} onChange={handleInputChange} required />

                {itemType === 'menu' && (
                  <>
                    <label className="modal-label">Día de la semana</label>
                    <select className="modal-input modal-select" name="dia_semana" value={formData.dia_semana} onChange={handleInputChange}>
                      {diasSemana.map(dia => <option key={dia} value={dia}>{dia}</option>)}
                    </select>
                  </>
                )}

                {itemType !== 'menu' && (
                  <>
                    <label className="modal-label">Descripción (opcional)</label>
                    <textarea className="modal-input" name="descripcion" value={formData.descripcion} onChange={handleInputChange} rows={3} />

                    <label className="modal-label">Precio</label>
                    <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
                      <DollarSign size={24} className="text-gray-600" />
                      <input className="modal-input" type="number" step="0.01" name="precio" value={formData.precio} onChange={handleInputChange} required />
                    </div>

                    <label className="modal-label">Categoría</label>
                    <select className="modal-input modal-select" name="categoria" value={formData.categoria} onChange={handleInputChange}>
                      {categories.map(cat => <option key={cat} value={cat}>{cat}</option>)}
                    </select>

                    <label className="modal-label">Ubicación</label>
                    <select className="modal-input modal-select" name="ubicacion" value={formData.ubicacion} onChange={handleInputChange}>
                      <option value="cafeteria">Cafetería</option>
                      <option value="rooftop">Rooftop</option>
                      <option value="ambos">Ambos</option>
                    </select>

                    <label className="modal-label">Imagen</label>
                    <input className="modal-input" type="file" accept="image/*" onChange={handleImageChange} />

                    {formData.imagePreview && (
                      <div style={{ margin: "15px 0", textAlign: "center" }}>
                        <img src={formData.imagePreview} alt="Preview" style={{ maxWidth: "100%", borderRadius: "16px", boxShadow: "0 4px 12px rgba(0,0,0,0.1)" }} />
                      </div>
                    )}
                  </>
                )}

                <button className="btn-submit" disabled={submitting}>
                  {submitting
                    ? "Guardando..."
                    : (itemType === 'menu'
                      ? (editingItem ? "Actualizar Menú" : "Crear Menú")
                      : (editingItem ? "Actualizar" : "Crear Producto")
                    )
                  }
                </button>
              </form>
            </div>
          </div>
        </>
      )}

    </div>
  );
}