// src/pages/PromocionPage.jsx
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Edit, Plus, X, Loader2, Image as ImageIcon } from 'lucide-react';

export default function PromocionPage({ onLogout }) {
    const navigate = useNavigate();
    const [activeTab, setActiveTab] = useState('promociones');
    const [promociones, setPromociones] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [editingPromo, setEditingPromo] = useState(null);
    const [formData, setFormData] = useState({
        titulo: '',
        descripcion: '',
        imagen: '',
        fecha_inicio: '',
        fecha_fin: '',
        activo: true,
        imageFile: null,
        imagePreview: ''
    });
    const [submitting, setSubmitting] = useState(false);
    const [submitError, setSubmitError] = useState('');
    const [submitSuccess, setSubmitSuccess] = useState('');
    const [togglingPromo, setTogglingPromo] = useState(null);

    // Todos los estilos inline necesarios (iguales a Cafeteria)
    const globalStyles = (
        <>
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
        .actions-title {
          font-size: 22px;
          font-weight: 700;
          color: #0f172a;
          margin: 0;
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
        .btn-edit:hover {
          background: #eab308;
          transform: scale(1.05);
        }
        .switch {
          position: relative;
          display: inline-block;
          width: 52px;
          height: 28px;
        }
        .slider {
          position: absolute;
          inset: 0;
          background: #cbd5e1;
          border-radius: 28px;
          transition: .3s;
        }
        .slider:before {
          content: "";
          position: absolute;
          width: 22px;
          height: 22px;
          left: 3px;
          top: 3px;
          background: white;
          border-radius: 50%;
          transition: .3s;
          box-shadow: 0 2px 6px rgba(0,0,0,0.3);
        }
        input:checked + .slider {
          background: #22c55e;
        }
        input:checked + .slider:before {
          transform: translateX(24px);
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
        }
        .table-bordered td {
          padding: 16px 12px;
          border-bottom: 1px solid #e5e7eb;
          vertical-align: middle;
        }
        tr:hover {
          background: #f9fafb;
        }
        .promo-image-fixed {
          width: 80px;
          height: 80px;
          object-fit: cover;
          border-radius: 12px;
          box-shadow: 0 3px 10px rgba(0,0,0,0.15);
        }
        .date-badge {
          padding: 6px 12px;
          background: #e0f2fe;
          color: #0369a1;
          border-radius: 999px;
          font-size: 0.875rem;
        }
      `}</style>

            {/* Estilos del modal */}
            <style>{`
        .modal-overlay {
          position: fixed;
          inset: 0;
          background: rgba(0,0,0,0.55);
          display: flex;
          justify-content: center;
          align-items: center;
          backdrop-filter: blur(6px);
          z-index: 1000;
        }
        .modal-content {
          background: white;
          padding: 32px;
          border-radius: 20px;
          width: 90%;
          max-width: 550px;
          box-shadow: 0 20px 40px rgba(0,0,0,0.2);
        }
        .modal-close {
          background: #dc2626;
          border: none;
          padding: 10px 14px;
          border-radius: 10px;
          color: white;
          cursor: pointer;
          font-weight: bold;
        }
        .modal-close:hover {
          background: #b91c1c;
          transform: scale(1.05);
        }
        .modal-input, .modal-select, .modal-textarea {
          width: 100%;
          padding: 12px 14px;
          border: 2px solid #e2e8f0;
          border-radius: 12px;
          margin: 8px 0 18px;
          font-size: 16px;
        }
        .modal-input:focus, .modal-select:focus, .modal-textarea:focus {
          outline: none;
          border-color: #3b82f6;
          box-shadow: 0 0 0 4px rgba(59,130,246,0.15);
        }
        .modal-label {
          font-weight: 600;
          color: #1e293b;
          font-size: 15px;
          display: block;
          margin-bottom: 6px;
        }
        .btn-submit {
          width: 100%;
          padding: 14px;
          background: linear-gradient(135deg, #3b82f6, #2563eb);
          border: none;
          border-radius: 12px;
          color: white;
          font-size: 18px;
          font-weight: 700;
          cursor: pointer;
          margin-top: 20px;
        }
        .btn-submit:hover {
          transform: translateY(-3px);
          box-shadow: 0 10px 20px rgba(59,130,246,0.3);
        }
        .btn-submit:disabled {
          opacity: 0.7;
          cursor: not-allowed;
        }
      `}</style>
        </>
    );

    // Cargar promociones (solo admin)
    useEffect(() => {
        if (activeTab === 'promociones') {
            const fetchPromociones = async () => {
                try {
                    setLoading(true);
                    const token = localStorage.getItem('authToken');
                    const res = await fetch('http://localhost:3001/api/promocion/mostrar/admin', {
                        headers: {
                            Authorization: `Bearer ${token}`
                        }
                    });
                    if (!res.ok) throw new Error('Error al cargar promociones');
                    const data = await res.json();
                    if (data.status) {
                        setPromociones(data.promociones || []);
                    } else {
                        setError(data.message || 'No se pudieron cargar las promociones');
                    }
                } catch (err) {
                    console.error(err);
                    setError('Error al cargar promociones');
                } finally {
                    setLoading(false);
                }
            };
            fetchPromociones();
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

    const openModal = (promo = null) => {
        setEditingPromo(promo);
        if (promo) {
            setFormData({
                titulo: promo.titulo,
                descripcion: promo.descripcion || '',
                imagen: promo.imagen || '',
                fecha_inicio: promo.fecha_inicio ? promo.fecha_inicio.split('T')[0] : '',
                fecha_fin: promo.fecha_fin ? promo.fecha_fin.split('T')[0] : '',
                activo: promo.activo,
                imageFile: null,
                imagePreview: promo.imagen || ''
            });
        } else {
            setFormData({
                titulo: '',
                descripcion: '',
                imagen: '',
                fecha_inicio: '',
                fecha_fin: '',
                activo: true,
                imageFile: null,
                imagePreview: ''
            });
        }
        setShowModal(true);
        setSubmitError('');
        setSubmitSuccess('');
    };

    const toggleStatus = async (promo) => {
        setTogglingPromo(promo.idPromocion);
        const token = localStorage.getItem('authToken');
        try {
            const res = await fetch(`http://localhost:3001/api/promocion/estado/${promo.idPromocion}`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                    Authorization: `Bearer ${token}`
                },
                body: JSON.stringify({ activo: !promo.activo })
            });
            if (!res.ok) throw new Error();
            setPromociones(prev =>
                prev.map(p => p.idPromocion === promo.idPromocion ? { ...p, activo: !p.activo } : p)
            );
        } catch (err) {
            alert('No se pudo cambiar el estado');
        } finally {
            setTogglingPromo(null);
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
                imagen: '' // Limpiamos la URL anterior si se sube archivo nuevo
            }));
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSubmitError('');
        setSubmitSuccess('');
        setSubmitting(true);

        const token = localStorage.getItem('authToken');
        const fd = new FormData();
        fd.append('titulo', formData.titulo.trim());
        fd.append('descripcion', formData.descripcion.trim() || '');
        fd.append('fecha_inicio', formData.fecha_inicio);
        fd.append('fecha_fin', formData.fecha_fin);
        fd.append('activo', formData.activo);

        if (formData.imageFile) {
            fd.append('imagen', formData.imageFile);
        } else if (formData.imagen?.trim()) {
            fd.append('imagen', formData.imagen.trim());
        }

        try {
            let url, method;
            if (editingPromo) {
                url = `http://localhost:3001/api/promocion/actualizar/${editingPromo.idPromocion}`;
                method = 'PUT';
            } else {
                url = 'http://localhost:3001/api/promocion/crear';
                method = 'POST';
            }

            const res = await fetch(url, {
                method,
                headers: { ...(token ? { Authorization: `Bearer ${token}` } : {}) },
                body: fd
            });

            const data = await res.json();
            if (!res.ok) throw new Error(data.message || 'Error al guardar');

            if (editingPromo) {
                setPromociones(prev =>
                    prev.map(p =>
                        p.idPromocion === editingPromo.idPromocion ? { ...p, ...data.promocion } : p
                    )
                );
                setSubmitSuccess('Promoción actualizada');
            } else {
                setPromociones(prev => [{ ...data.promocion }, ...prev]);
                setSubmitSuccess('Promoción creada correctamente');
            }

            setShowModal(false);
        } catch (err) {
            setSubmitError(err.message || 'Error al guardar promoción');
        } finally {
            setSubmitting(false);
        }
    };

    return (
        <div className="cafeteria-container">
            {globalStyles}

            {/* Header */}
            <div className="cafeteria-header">
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <div>
                        <h1 className="cafeteria-title">Cafetería Admin</h1>
                        <p className="cafeteria-subtitle">Gestión de promociones</p>
                    </div>
                    <button onClick={handleLogout} className="btn-logout">
                        Cerrar sesión
                    </button>
                </div>
            </div>

            {/* Navbar */}
            <div className="navbar-horizontal">
                <button
                    className={`tab-button ${activeTab === 'promociones' ? 'active' : ''}`}
                    onClick={() => setActiveTab('promociones')}
                >
                    Promociones
                </button>
            </div>

            {/* Contenido principal */}
            {activeTab === 'promociones' && (
                <>
                    <div className="actions-bar">
                        <h2 className="actions-title">Lista de Promociones</h2>
                        <button onClick={() => openModal()} className="btn-add">
                            <Plus size={20} /> Agregar Promoción
                        </button>
                    </div>

                    {error && <p style={{ color: 'red', textAlign: 'center' }}>{error}</p>}

                    {loading ? (
                        <div className="flex flex-col items-center justify-center py-20">
                            <Loader2 className="animate-spin text-blue-600" size={54} />
                            <p style={{ marginTop: 16, color: '#475569' }}>Cargando promociones...</p>
                        </div>
                    ) : promociones.length === 0 ? (
                        <div style={{ background: 'white', borderRadius: '20px', padding: '60px 30px', boxShadow: '0 10px 30px rgba(0,0,0,0.1)', textAlign: 'center' }}>
                            <ImageIcon size={120} className="text-blue-600 mx-auto mb-8 opacity-80" />
                            <p className="text-xl text-gray-600">Aún no hay promociones registradas</p>
                            <p className="text-lg text-gray-500 mt-6">¡Crea una ahora!</p>
                        </div>
                    ) : (
                        <div className="table-container-expanded">
                            <table className="table-bordered">
                                <thead>
                                    <tr>
                                        <th>Imagen</th>
                                        <th>Título</th>
                                        <th>Descripción</th>
                                        <th>Inicio</th>
                                        <th>Fin</th>
                                        <th>Estado</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {promociones.map(promo => (
                                        <tr key={promo.idPromocion}>
                                            <td>
                                                <img
                                                    src={promo.imagen || '/placeholder.jpg'}
                                                    alt={promo.titulo}
                                                    className="promo-image-fixed"
                                                    onError={e => e.target.src = '/placeholder.jpg'}
                                                />
                                            </td>
                                            <td className="font-semibold">{promo.titulo}</td>
                                            <td className="text-gray-600">{promo.descripcion || 'Sin descripción'}</td>
                                            <td>
                                                <span className="date-badge">
                                                    {new Date(promo.fecha_inicio).toLocaleDateString('es-EC')}
                                                </span>
                                            </td>
                                            <td>
                                                <span className="date-badge">
                                                    {new Date(promo.fecha_fin).toLocaleDateString('es-EC')}
                                                </span>
                                            </td>
                                            <td>
                                                <span className={`badge ${promo.activo ? 'on' : 'off'}`}>
                                                    {promo.activo ? 'Activa' : 'Inactiva'}
                                                </span>
                                            </td>
                                            <td style={{ verticalAlign: 'middle', padding: '20px 12px' }}>
                                                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '14px' }}>
                                                    <button className="btn-edit" onClick={() => openModal(promo)}>
                                                        <Edit size={18} /> Editar
                                                    </button>
                                                    <label className="switch">
                                                        <input
                                                            type="checkbox"
                                                            checked={promo.activo}
                                                            disabled={togglingPromo === promo.idPromocion}
                                                            onChange={() => toggleStatus(promo)}
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

            {/* MODAL */}
            {showModal && (
                <div className="modal-overlay" onClick={() => setShowModal(false)}>
                    <div className="modal-content" onClick={e => e.stopPropagation()}>
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
                            <h2 style={{ fontSize: '26px', fontWeight: '800', color: '#1e293b' }}>
                                {editingPromo ? 'Editar Promoción' : 'Nueva Promoción'}
                            </h2>
                            <button className="modal-close" onClick={() => setShowModal(false)}>X</button>
                        </div>

                        {submitSuccess && <p style={{ color: 'green', fontWeight: 'bold', textAlign: 'center', marginBottom: '15px' }}>{submitSuccess}</p>}
                        {submitError && <p style={{ color: 'red', fontWeight: 'bold', textAlign: 'center', marginBottom: '15px' }}>{submitError}</p>}

                        <form onSubmit={handleSubmit}>
                            <label className="modal-label">Título</label>
                            <input
                                className="modal-input"
                                type="text"
                                name="titulo"
                                value={formData.titulo}
                                onChange={handleInputChange}
                                required
                            />

                            <label className="modal-label">Descripción (opcional)</label>
                            <textarea
                                className="modal-textarea"
                                name="descripcion"
                                value={formData.descripcion}
                                onChange={handleInputChange}
                                rows={3}
                            />

                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                                <div>
                                    <label className="modal-label">Fecha de inicio</label>
                                    <input
                                        className="modal-input"
                                        type="date"
                                        name="fecha_inicio"
                                        value={formData.fecha_inicio}
                                        onChange={handleInputChange}
                                        required
                                    />
                                </div>
                                <div>
                                    <label className="modal-label">Fecha de fin</label>
                                    <input
                                        className="modal-input"
                                        type="date"
                                        name="fecha_fin"
                                        value={formData.fecha_fin}
                                        onChange={handleInputChange}
                                        required
                                    />
                                </div>
                            </div>

                            <label className="modal-label">Imagen</label>
                            <input
                                className="modal-input"
                                type="file"
                                accept="image/*"
                                onChange={handleImageChange}
                            />
                            {(formData.imagePreview || formData.imagen) && (
                                <div style={{ margin: '15px 0', textAlign: 'center' }}>
                                    <img
                                        src={formData.imagePreview || formData.imagen}
                                        alt="Preview"
                                        style={{ maxWidth: '100%', maxHeight: '200px', borderRadius: '16px', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' }}
                                        onError={e => e.target.src = '/placeholder.jpg'}
                                    />
                                </div>
                            )}

                            <button className="btn-submit" disabled={submitting}>
                                {submitting ? 'Guardando...' : (editingPromo ? 'Actualizar Promoción' : 'Crear Promoción')}
                            </button>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}