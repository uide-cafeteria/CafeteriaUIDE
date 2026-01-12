// src/pages/MenuDiarioPage.jsx
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Plus, Loader2, Calendar, Edit } from 'lucide-react';

export default function MenuDiarioPage({ onLogout }) {
    const navigate = useNavigate();
    const [activeTab, setActiveTab] = useState('menu');
    const [menusDelDia, setMenusDelDia] = useState([]);
    const [loadingMenus, setLoadingMenus] = useState(true);
    const [error, setError] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [editingMenu, setEditingMenu] = useState(null);
    const [formData, setFormData] = useState({
        name: '',
        dia_semana: 'Lunes',
        activo: true
    });
    const [submitting, setSubmitting] = useState(false);
    const [submitError, setSubmitError] = useState('');
    const [submitSuccess, setSubmitSuccess] = useState('');
    const [togglingMenu, setTogglingMenu] = useState(null);

    const diasSemana = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];

    // Estilos inline (exactamente iguales a Cafeteria)
    const globalStyles = (
        <style>{`
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
      .btn-logout:hover { background: #b91c1c !important; transform: scale(1.05); }
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
      .actions-title { font-size: 22px; font-weight: 700; color: #0f172a; margin: 0; }
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
      .modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.55); display: flex; justify-content: center; align-items: center; backdrop-filter: blur(6px); z-index: 1000; }
      .modal-content { background: white; padding: 32px; border-radius: 20px; width: 90%; max-width: 500px; box-shadow: 0 20px 40px rgba(0,0,0,0.2); }
      .modal-close { background: #dc2626; border: none; padding: 10px 14px; border-radius: 10px; color: white; cursor: pointer; font-weight: bold; }
      .modal-close:hover { background: #b91c1c; transform: scale(1.05); }
      .modal-input, .modal-select { width: 100%; padding: 12px 14px; border: 2px solid #e2e8f0; border-radius: 12px; margin-top: 8px; margin-bottom: 18px; font-size: 16px; }
      .modal-input:focus, .modal-select:focus { outline: none; border-color: #3b82f6; box-shadow: 0 0 0 4px rgba(59,130,246,0.15); }
      .modal-label { font-weight: 600; color: #1e293b; font-size: 15px; }
      .btn-submit { width: 100%; padding: 14px; background: linear-gradient(135deg, #3b82f6, #2563eb); border: none; border-radius: 12px; color: white; font-size: 18px; font-weight: 700; cursor: pointer; margin-top: 20px; transition: .3s; }
      .btn-submit:hover { transform: translateY(-3px); box-shadow: 0 10px 20px rgba(59,130,246,0.3); }
      .btn-submit:disabled { opacity: 0.7; cursor: not-allowed; }
    `}</style>
    );

    useEffect(() => {
        const fetchMenus = async () => {
            try {
                setLoadingMenus(true);
                const token = localStorage.getItem('authToken');
                const res = await fetch('http://localhost:3001/api/menu/mostrar/admin', {
                    headers: { Authorization: `Bearer ${token}` }
                });
                if (!res.ok) throw new Error();
                const data = await res.json();
                setMenusDelDia(data.menus || []);
            } catch (err) {
                setError('Error al cargar menús');
            } finally {
                setLoadingMenus(false);
            }
        };
        fetchMenus();
    }, []);

    const handleLogout = async () => {
        const token = localStorage.getItem('authToken');
        try {
            await fetch('http://localhost:3001/api/usuario/logout/admin', {
                method: 'POST',
                headers: { Authorization: `Bearer ${token}` }
            });
        } catch { }
        localStorage.removeItem('authToken');
        if (onLogout) onLogout();
        navigate('/login');
    };

    const openModal = (menu = null) => {
        setEditingMenu(menu);
        if (menu) {
            setFormData({
                name: menu.nombre,
                dia_semana: menu.dia_semana,
                activo: menu.activo
            });
        } else {
            setFormData({
                name: '',
                dia_semana: 'Lunes',
                activo: true
            });
        }
        setShowModal(true);
        setSubmitError('');
        setSubmitSuccess('');
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

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSubmitError('');
        setSubmitSuccess('');
        setSubmitting(true);
        const token = localStorage.getItem('authToken');
        const payload = {
            nombre: formData.name,
            dia_semana: formData.dia_semana,
            activo: formData.activo
        };
        try {
            let url, method;
            if (editingMenu) {
                url = `http://localhost:3001/api/menu/actualizar/${editingMenu.idMenu}`;
                method = 'PUT';
            } else {
                url = 'http://localhost:3001/api/menu/crear';
                method = 'POST';
            }
            const res = await fetch(url, {
                method,
                headers: {
                    'Content-Type': 'application/json',
                    Authorization: `Bearer ${token}`
                },
                body: JSON.stringify(payload)
            });
            const data = await res.json();
            if (!res.ok) throw new Error(data.message || 'Error');
            if (editingMenu) {
                setMenusDelDia(prev => prev.map(m => m.idMenu === editingMenu.idMenu ? { ...m, ...data.menu } : m));
                setSubmitSuccess('Menú actualizado');
            } else {
                setMenusDelDia(prev => [data.menu, ...prev]);
                setSubmitSuccess('Menú creado correctamente');
            }
            setShowModal(false);
        } catch (err) {
            setSubmitError(err.message || 'Error al guardar menú');
        } finally {
            setSubmitting(false);
        }
    };
    // Redirigir a otras páginas cuando cambie la pestaña
    useEffect(() => {
        if (activeTab === 'cafeteria') navigate('/cafeteria');
        if (activeTab === 'menu') navigate('/menu-diario');
        if (activeTab === 'historial') navigate('/historial-almuerzos');
        if (activeTab === 'promociones') navigate('/promociones');
    }, [activeTab, navigate]);
    return (
        <div className="cafeteria-container">
            {globalStyles}

            <div className="cafeteria-header">
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <div>
                        <h1 className="cafeteria-title">Cafetería Admin</h1>
                        <p className="cafeteria-subtitle">Gestión de Menú Diario</p>
                    </div>
                    <button onClick={handleLogout} className="btn-logout">
                        Cerrar sesión
                    </button>
                </div>
            </div>

            <div className="navbar-horizontal">
                <button className={`tab-button ${activeTab === 'productos' ? 'active' : ''}`} onClick={() => setActiveTab('cafeteria')}>
                    Lista de Productos
                </button>
                <button className={`tab-button ${activeTab === 'menu' ? 'active' : ''}`} onClick={() => setActiveTab('menu')}>
                    Menú Diario
                </button>
                <button className={`tab-button ${activeTab === 'historial' ? 'active' : ''}`} onClick={() => setActiveTab('historial')}>
                    Historial de Almuerzos
                </button>
                <button className={`tab-button ${activeTab === 'promociones' ? 'active' : ''}`} onClick={() => setActiveTab('promociones')}>
                    Promociones
                </button>
            </div>

            <div className="actions-bar">
                <h2 className="actions-title">Menú Diario</h2>
                <button onClick={() => openModal()} className="btn-add">
                    <Plus size={20} /> Agregar Menú
                </button>
            </div>

            {error && <p style={{ color: 'red', textAlign: 'center' }}>{error}</p>}

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
                                                onClick={() => openModal(menu)}
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

            {showModal && (
                <div className="modal-overlay" onClick={() => setShowModal(false)}>
                    <div className="modal-content" onClick={e => e.stopPropagation()}>
                        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "24px" }}>
                            <h2 style={{ fontSize: "26px", fontWeight: "800", color: "#1e293b" }}>
                                {editingMenu ? "Editar Menú Diario" : "Nuevo Menú Diario"}
                            </h2>
                            <button className="modal-close" onClick={() => setShowModal(false)}>X</button>
                        </div>
                        {submitSuccess && <p style={{ color: "green", fontWeight: "bold", textAlign: "center", marginBottom: "15px" }}>{submitSuccess}</p>}
                        {submitError && <p style={{ color: "red", fontWeight: "bold", textAlign: "center", marginBottom: "15px" }}>{submitError}</p>}
                        <form onSubmit={handleSubmit}>
                            <label className="modal-label">Nombre</label>
                            <input className="modal-input" type="text" name="name" value={formData.name} onChange={handleInputChange} required />
                            <label className="modal-label">Día de la semana</label>
                            <select className="modal-input modal-select" name="dia_semana" value={formData.dia_semana} onChange={handleInputChange}>
                                {diasSemana.map(dia => <option key={dia} value={dia}>{dia}</option>)}
                            </select>
                            <button className="btn-submit" disabled={submitting}>
                                {submitting ? "Guardando..." : (editingMenu ? "Actualizar Menú" : "Crear Menú")}
                            </button>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}