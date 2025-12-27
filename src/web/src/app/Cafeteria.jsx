import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Edit, Trash2, Plus, X, DollarSign, Tag, ImageIcon, Loader2 } from 'lucide-react';
import '../styles/cafeteria.css';

export default function Cafeteria({ onLogout }) {
  const navigate = useNavigate();

  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const [showModal, setShowModal] = useState(false);
  const [editingProduct, setEditingProduct] = useState(null);

  const [formData, setFormData] = useState({
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

  const [submitting, setSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState('');
  const [submitSuccess, setSubmitSuccess] = useState('');

  const categories = ['Desayuno', 'Almuerzo', 'Postre', 'Otro'];

  // CARGA LOS PRODUCTOS DEL BACKEND AL INICIAR
  useEffect(() => {
    const fetchProducts = async () => {
      try {
        const token = localStorage.getItem('authToken');

        const res = await fetch('http://localhost:3001/api/producto/mostrar', {
          headers: {
            'Content-Type': 'application/json',
            ...(token ? { Authorization: `Bearer ${token}` } : {})
          }
        });

        if (!res.ok) throw new Error('No se pudieron cargar los productos');

        const data = await res.json();
        const productos = data.productos || [];

        // El backend ya devuelve imagen = URL completa[](http://localhost:3001/uploads/...)
        const productosListos = productos.map(p => ({
          idProducto: p.idProducto,
          id: p.idProducto,
          nombre: p.nombre,
          name: p.nombre,
          descripcion: p.descripcion || '',
          precio: p.precio,
          categoria: p.categoria,
          category: p.categoria,
          ubicacion: p.ubicacion || 'cafeteria',
          imagen: p.imagen || '/placeholder.jpg',
          image: p.imagen || '/placeholder.jpg',
          activo: p.activo ?? true
        }));

        setProducts(productosListos);
      } catch (err) {
        console.error('Error cargando productos:', err);
        setError('No se pudieron cargar los productos. Revisa el backend.');
      } finally {
        setLoading(false);
      }
    };

    fetchProducts();
  }, []);

  // LOGOUT
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

  // MODAL
  const openModal = (product = null) => {
    if (product) {
      setEditingProduct(product);
      setFormData({
        name: product.nombre,
        descripcion: product.descripcion || '',
        precio: product.precio,
        categoria: product.categoria,
        ubicacion: product.ubicacion,
        activo: product.activo,
        imageFile: null,
        imagePreview: product.image,
        imageUrl: product.image
      });
    } else {
      setEditingProduct(null);
      setFormData({
        name: '', descripcion: '', precio: '', categoria: 'Desayuno',
        ubicacion: 'cafeteria', activo: true, imageFile: null, imagePreview: '', imageUrl: ''
      });
    }
    setShowModal(true);
  };

  const closeModal = () => {
    setShowModal(false);
    setEditingProduct(null);
    setSubmitError('');
    setSubmitSuccess('');
  };

  // CREAR O ACTUALIZAR
  const handleSubmit = async (e) => {
    e.preventDefault();
    setSubmitError('');
    setSubmitSuccess('');
    setSubmitting(true);

    const formDataToSend = new FormData();
    formDataToSend.append('nombre', formData.name);
    formDataToSend.append('descripcion', formData.descripcion || '');
    formDataToSend.append('precio', parseFloat(formData.precio) || 0);
    formDataToSend.append('categoria', formData.categoria);
    formDataToSend.append('ubicacion', formData.ubicacion);
    formDataToSend.append('activo', formData.activo);

    if (formData.imageFile) {
      formDataToSend.append('imagen', formData.imageFile);
    } else if (formData.imageUrl?.trim()) {
      formDataToSend.append('imagen', formData.imageUrl.trim());
    }

    const token = localStorage.getItem('authToken');

    try {
      const url = editingProduct
        ? `http://localhost:3001/api/producto/actualizar/${editingProduct.idProducto}`
        : 'http://localhost:3001/api/producto/crear';

      const res = await fetch(url, {
        method: editingProduct ? 'PUT' : 'POST',
        headers: { ...(token ? { Authorization: `Bearer ${token}` } : {}) },
        body: formDataToSend
      });

      const data = await res.json();
      if (!res.ok) throw new Error(data.message || 'Error al guardar');

      const nuevo = data.producto;

      if (editingProduct) {
        setProducts(prev => prev.map(p =>
          p.idProducto === editingProduct.idProducto
            ? { ...p, ...nuevo, image: nuevo.imagen }
            : p
        ));
        setSubmitSuccess('Producto actualizado');
      } else {
        setProducts(prev => [...prev, {
          idProducto: nuevo.idProducto,
          nombre: nuevo.nombre,
          name: nuevo.nombre,
          precio: nuevo.precio,
          precio: nuevo.precio,
          imagen: nuevo.imagen,
          image: nuevo.imagen,
          categoria: nuevo.categoria,
          category: nuevo.categoria,
          descripcion: nuevo.descripcion || '',
          ubicacion: nuevo.ubicacion || 'cafeteria',
          activo: nuevo.activo ?? true
        }]);
        setSubmitSuccess('Producto creado');
      }

      closeModal();
    } catch (err) {
      setSubmitError(err.message);
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = (idProducto) => {
    if (window.confirm('¿Seguro que quieres eliminar este producto?')) {
      setProducts(prev => prev.filter(p => p.idProducto !== idProducto));
      // Aquí puedes agregar llamada al backend para borrarlo físicamente si quieres
    }
  };

  // RENDER
  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center h-screen gap-4">
        <Loader2 className="animate-spin" size={48} />
        <p className="text-xl">Cargando menú...</p>
      </div>
    );
  }

  return (
    <div className="cafeteria-container">
      {/* HEADER */}
      <div className="cafeteria-header">
        <div className="cafeteria-header-content">
          <div>
            <h1 className="cafeteria-title">Cafetería Admin</h1>
            <p className="cafeteria-subtitle">Gestiona tu menú</p>
          </div>
          <button onClick={handleLogout} className="btn-logout">Cerrar sesión</button>
        </div>
      </div>

      {error && <div className="text-red-600 text-center py-4">{error}</div>}

      {/* MAIN */}
      <div className="cafeteria-main">
        <div className="stats-grid">
          <div className="stat-card orange">
            <div className="stat-label">Total Productos</div>
            <div className="stat-value orange">{products.length}</div>
          </div>
          <div className="stat-card green">
            <div className="stat-label">Precio Promedio</div>
            <div className="stat-value green">
              ${products.length > 0
                ? (products.reduce((a, p) => a + Number(p.precio || p.price || 0), 0) / products.length).toFixed(2)
                : '0.00'}
            </div>
          </div>
        </div>

        <div className="actions-bar">
          <h2 className="actions-title">Lista de Productos</h2>
          <button onClick={() => openModal()} className="btn-add">
            <Plus size={20} /> Agregar Producto
          </button>
        </div>

        <div className="products-grid">
          {products.length === 0 ? (
            <div className="col-span-full text-center py-16 text-gray-500">
              <p className="text-2xl mb-2">No hay productos</p>
              <p>¡Agrega el primero!</p>
            </div>
          ) : (
            products.map(product => (
              <div key={product.idProducto} className="product-card">
                <div className="product-image">
                  <img
                    src={product.image}
                    alt={product.name}
                    onError={(e) => { e.target.src = '/placeholder.jpg'; }}
                  />
                </div>
                <div className="product-content">
                  <div className="product-header">
                    <h3 className="product-name">{product.name}</h3>
                    <span className="product-category">{product.category}</span>
                  </div>
                  <p className="product-desc">{product.descripcion || 'Sin descripción'}</p>
                  <div className="product-price">${Number(product.precio || product.precio || 0).toFixed(2)}</div>
                  <div className="product-meta">
                    <span className="badge ubicacion">{product.ubicacion}</span>
                    <span className={`badge activo ${product.activo ? 'on' : 'off'}`}>
                      {product.activo ? 'Activo' : 'Inactivo'}
                    </span>
                  </div>
                  <div className="product-actions">
                    <button onClick={() => openModal(product)} className="btn-edit">
                      <Edit size={16} /> Editar
                    </button>
                    <button onClick={() => handleDelete(product.idProducto)} className="btn-delete">
                      <Trash2 size={16} />
                    </button>
                  </div>
                </div>
              </div>
            ))
          )}
        </div>
      </div>

      {/* MODAL - igual que antes, sin cambios */}
      {showModal && (
        <div className="modal-overlay" onClick={closeModal}>
          <div className="modal-content" onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <h2 className="modal-title">{editingProduct ? 'Editar' : 'Nuevo'} Producto</h2>
              <button onClick={closeModal} className="btn-close"><X size={24} /></button>
            </div>
            <form onSubmit={handleSubmit}>
              <div className="modal-body">
                {submitError && <div className="form-alert error">{submitError}</div>}
                {submitSuccess && <div className="form-alert success">{submitSuccess}</div>}
                {submitting && <div className="form-alert info">Guardando…</div>}

                <div className="form-group">
                  <label><Tag size={16} /> Nombre</label>
                  <input type="text" required value={formData.name}
                    onChange={e => setFormData({ ...formData, name: e.target.value })}
                    className="form-input" />
                </div>

                <div className="form-group">
                  <label><DollarSign size={16} /> Precio</label>
                  <input type="number" step="0.01" required value={formData.precio}
                    onChange={e => setFormData({ ...formData, precio: e.target.value })}
                    className="form-input" />
                </div>

                <div className="form-group">
                  <label>Categoría</label>
                  <select value={formData.categoria}
                    onChange={e => setFormData({ ...formData, categoria: e.target.value })}
                    className="form-select">
                    {categories.map(c => <option key={c} value={c}>{c}</option>)}
                  </select>
                </div>

                <div className="form-group">
                  <label>Descripción</label>
                  <textarea value={formData.descripcion}
                    onChange={e => setFormData({ ...formData, descripcion: e.target.value })}
                    className="form-textarea" rows={3} />
                </div>

                <div className="form-group">
                  <label>Ubicación</label>
                  <select value={formData.ubicacion}
                    onChange={e => setFormData({ ...formData, ubicacion: e.target.value })}
                    className="form-select">
                    <option value="cafeteria">Cafetería</option>
                    <option value="rooftop">Rooftop</option>
                    <option value="ambos">Ambos</option>
                  </select>
                </div>

                <div className="form-group">
                  <label><ImageIcon size={16} /> Imagen</label>
                  {(formData.imagePreview) && (
                    <div className="image-preview mb-4">
                      <img src={formData.imagePreview} alt="Preview" style={{ maxWidth: '100%', maxHeight: '220px', borderRadius: '8px', objectFit: 'cover' }} />
                    </div>
                  )}
                  <input type="file" accept="image/*"
                    onChange={e => {
                      const file = e.target.files[0];
                      if (file) {
                        setFormData({
                          ...formData,
                          imageFile: file,
                          imagePreview: URL.createObjectURL(file),
                          imageUrl: ''
                        });
                      }
                    }}
                    className="form-input" />
                  <small>O pega una URL:</small>
                  <input type="text" value={formData.imageUrl}
                    onChange={e => setFormData({ ...formData, imageUrl: e.target.value, imagePreview: e.target.value, imageFile: null })}
                    className="form-input mt-1" placeholder="https://..." />
                </div>

                {editingProduct && (
                  <div className="form-group">
                    <label className="flex items-center gap-2">
                      <input type="checkbox" checked={formData.activo}
                        onChange={e => setFormData({ ...formData, activo: e.target.checked })} />
                      Producto activo
                    </label>
                  </div>
                )}
              </div>

              <div className="modal-footer">
                <button type="button" onClick={closeModal} className="btn-cancel">Cancelar</button>
                <button type="submit" disabled={submitting} className="btn-submit">
                  {submitting ? 'Guardando...' : editingProduct ? 'Guardar' : 'Crear'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}