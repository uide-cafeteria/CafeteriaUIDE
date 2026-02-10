// src/pages/HorarioAtencion.jsx
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Plus, Trash2, Edit, Loader2 } from 'lucide-react';

export default function HorarioAtencion() {
    const navigate = useNavigate();

    const [activeTab, setActiveTab] = useState('horario-atencion');
    const [horarios, setHorarios] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');

    const [formOpen, setFormOpen] = useState(false);
    const [formData, setFormData] = useState({
        ubicacion: 'cafeteria',
        dia_semana: 'Lunes',
        hora_apertura: '08:00',
        hora_cierre: '18:00',
    });
    const [editingId, setEditingId] = useState(null);
    const [saving, setSaving] = useState(false);

    const [togglingId, setTogglingId] = useState(null); // loading por horario específico

    const token = localStorage.getItem('authToken');

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
        background: #f59e0b;
        color: white;
        border: none;
        padding: 8px 14px;
        border-radius: 10px;
        cursor: pointer;
      }
      .btn-delete {
        background: #ef4444;
        color: white;
        border: none;
        padding: 8px 14px;
        border-radius: 10px;
        cursor: pointer;
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
      .badge {
        padding: 6px 12px;
        border-radius: 9999px;
        font-size: 0.875rem;
        font-weight: 600;
      }
      .badge-active { background: #dcfce7; color: #166534; }
      .badge-inactive { background: #fee2e2; color: #991b1b; }
      .form-container {
        background: white;
        padding: 24px;
        border-radius: 12px;
        margin-bottom: 32px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
      }
      .empty-state {
        background: white;
        border-radius: 20px;
        padding: 60px 30px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        text-align: center;
      }

      /* SWITCH - DISEÑO EXACTO COPIADO DE PROMOCIONPAGE */
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
      input:disabled + .slider {
        opacity: 0.5;
        cursor: not-allowed;
      }
    `}</style>
    );

    useEffect(() => {
        if (!token) {
            navigate('/login');
            return;
        }
        loadHorarios();
    }, [navigate, token]);

    const loadHorarios = async () => {
        setLoading(true);
        setError('');

        try {
            const res = await fetch(`${process.env.REACT_APP_API_URL}/api/horarios/mostrar/admin`, {
                headers: { Authorization: `Bearer ${token}` },
            });

            if (!res.ok) {
                const errData = await res.json().catch(() => ({}));
                throw new Error(errData.message || 'No se pudieron cargar los horarios');
            }

            const data = await res.json();
            setHorarios(data.horarios || []);
        } catch (err) {
            console.error('Error loadHorarios:', err);
            setError(err.message || 'Error desconocido al cargar horarios');
        } finally {
            setLoading(false);
        }
    };

    const handleChange = (e) => {
        setFormData({ ...formData, [e.target.name]: e.target.value });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSaving(true);

        const url = editingId
            ? `${process.env.REACT_APP_API_URL}/api/horarios/${editingId}`
            : `${process.env.REACT_APP_API_URL}/api/horarios/crear`;

        const method = editingId ? 'PUT' : 'POST';

        try {
            const res = await fetch(url, {
                method,
                headers: {
                    'Content-Type': 'application/json',
                    Authorization: `Bearer ${token}`,
                },
                body: JSON.stringify(formData),
            });

            if (!res.ok) {
                const errData = await res.json();
                throw new Error(errData.message || 'Error al guardar');
            }

            setFormOpen(false);
            setEditingId(null);
            setFormData({
                ubicacion: 'cafeteria',
                dia_semana: 'Lunes',
                hora_apertura: '08:00',
                hora_cierre: '18:00',
            });

            loadHorarios();
        } catch (err) {
            console.error('Error handleSubmit:', err);
            alert(err.message || 'No se pudo guardar el horario');
        } finally {
            setSaving(false);
        }
    };

    const startEdit = (horario) => {
        setFormData({
            ubicacion: horario.ubicacion ?? 'cafeteria',
            dia_semana: horario.dia_semana ?? 'Lunes',
            hora_apertura: horario.hora_apertura?.substring(0, 5) ?? '08:00',
            hora_cierre: horario.hora_cierre?.substring(0, 5) ?? '18:00',
        });
        setEditingId(horario.idHorario);
        setFormOpen(true);
    };

    const toggleActive = async (horario) => {
        console.log('toggleActive llamado con horario:', horario);

        const id = horario?.idHorario;
        if (!id) {
            console.error('ID de horario no encontrado');
            alert('ID de horario no encontrado');
            return;
        }

        setTogglingId(id);

        try {
            console.log('Llamando API toggle:', `${process.env.REACT_APP_API_URL}/api/horarios/${id}/activar`);

            const res = await fetch(`${process.env.REACT_APP_API_URL}/api/horarios/${id}/activar`, {
                method: 'PUT',
                headers: { Authorization: `Bearer ${token}` },
            });

            console.log('Respuesta API toggle - Status:', res.status);

            if (!res.ok) {
                const errData = await res.json().catch(() => ({}));
                throw new Error(errData.message || `Error ${res.status}: ${res.statusText}`);
            }

            const data = await res.json(); // ← lee la respuesta
            console.log('Respuesta completa del backend:', data); // ← DEBUG clave

            // Actualización optimista
            setHorarios(prev =>
                prev.map(h =>
                    h.idHorario === id ? { ...h, activo: !h.activo } : h
                )
            );

            // Refrescar desde servidor
            loadHorarios();
        } catch (err) {
            console.error('Error en toggleActive:', err);
            alert(`Error al cambiar estado: ${err.message}`);
        } finally {
            setTogglingId(null);
        }
    };

    const removeHorario = async (id) => {
        if (!window.confirm('¿Seguro que quieres eliminar este horario?')) return;

        try {
            const res = await fetch(`${process.env.REACT_APP_API_URL}/api/horarios/eliminar/${id}`, {
                method: 'DELETE',
                headers: { Authorization: `Bearer ${token}` },
            });

            if (!res.ok) throw new Error('No se pudo eliminar');
            loadHorarios();
        } catch (err) {
            alert(err.message || 'Error al eliminar');
        }
    };

    useEffect(() => {
        if (activeTab === 'productos') navigate('/cafeteria');
        if (activeTab === 'menu') navigate('/menu-diario');
        if (activeTab === 'historial') navigate('/historial-almuerzos');
        if (activeTab === 'promociones') navigate('/promociones');
        if (activeTab === 'catering') navigate('/catering');
        if (activeTab === 'horario-atencion') navigate('/horario-atencion');
    }, [activeTab, navigate]);

    if (error) {
        return (
            <div className="p-8 text-center text-red-600">
                <h2 className="text-2xl font-bold">Error</h2>
                <p>{error}</p>
                <button
                    onClick={() => navigate('/cafeteria')}
                    className="mt-6 px-6 py-3 bg-blue-600 text-white rounded-lg"
                >
                    Volver
                </button>
            </div>
        );
    }

    return (
        <div className="cafeteria-container">
            {globalStyles}

            <div className="cafeteria-header">
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <div>
                        <h1 className="cafeteria-title">Cafetería Admin</h1>
                        <p className="cafeteria-subtitle">Gestión de horarios de atención</p>
                    </div>
                    <button
                        onClick={() => {
                            localStorage.removeItem('authToken');
                            navigate('/login');
                        }}
                        className="btn-logout"
                    >
                        Cerrar sesión
                    </button>
                </div>
            </div>

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
                <button
                    className={`tab-button ${activeTab === 'promociones' ? 'active' : ''}`}
                    onClick={() => setActiveTab('promociones')}
                >
                    Promociones
                </button>
                <button
                    className={`tab-button ${activeTab === 'catering' ? 'active' : ''}`}
                    onClick={() => setActiveTab('catering')}
                >
                    Catering
                </button>
                <button
                    className={`tab-button ${activeTab === 'horario-atencion' ? 'active' : ''}`}
                    onClick={() => setActiveTab('horario-atencion')}
                >
                    Horarios de atención
                </button>
            </div>

            <div style={{ margin: '24px 0', textAlign: 'center' }}>
                <button
                    onClick={() => {
                        setEditingId(null);
                        setFormData({
                            ubicacion: 'cafeteria',
                            dia_semana: 'Lunes',
                            hora_apertura: '08:00',
                            hora_cierre: '18:00',
                        });
                        setFormOpen(true);
                    }}
                    className="btn-add"
                    style={{ fontSize: '17px', padding: '14px 32px' }}
                >
                    <Plus size={20} /> Crear nuevo horario
                </button>
            </div>

            {formOpen && (
                <div className="form-container" style={{ maxWidth: '700px', margin: '0 auto 32px' }}>
                    <h2 className="text-2xl font-bold mb-6">
                        {editingId ? 'Editar horario' : 'Nuevo horario de atención'}
                    </h2>

                    <form onSubmit={handleSubmit}>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label className="block mb-2 font-medium">Ubicación</label>
                                <select name="ubicacion" value={formData.ubicacion} onChange={handleChange} className="w-full p-3 border rounded" required>
                                    <option value="cafeteria">Cafetería</option>
                                    <option value="rooftop">Rooftop</option>
                                </select>
                            </div>

                            <div>
                                <label className="block mb-2 font-medium">Día</label>
                                <select name="dia_semana" value={formData.dia_semana} onChange={handleChange} className="w-full p-3 border rounded" required>
                                    <option>Lunes</option>
                                    <option>Martes</option>
                                    <option>Miércoles</option>
                                    <option>Jueves</option>
                                    <option>Viernes</option>
                                </select>
                            </div>

                            <div>
                                <label className="block mb-2 font-medium">Apertura</label>
                                <input type="time" name="hora_apertura" value={formData.hora_apertura} onChange={handleChange} className="w-full p-3 border rounded" required />
                            </div>

                            <div>
                                <label className="block mb-2 font-medium">Cierre</label>
                                <input type="time" name="hora_cierre" value={formData.hora_cierre} onChange={handleChange} className="w-full p-3 border rounded" required />
                            </div>
                        </div>

                        <div className="mt-8 flex justify-end gap-4">
                            <button type="button" onClick={() => setFormOpen(false)} className="px-6 py-3 bg-gray-200 text-gray-800 rounded-lg hover:bg-gray-300">
                                Cancelar
                            </button>
                            <button type="submit" disabled={saving} className="btn-add px-6 py-3">
                                {saving ? <Loader2 className="animate-spin inline mr-2" size={20} /> : null}
                                {editingId ? 'Guardar cambios' : 'Crear horario'}
                            </button>
                        </div>
                    </form>
                </div>
            )}

            <h2 className="text-2xl font-bold mb-6 text-center md:text-left">Horarios registrados</h2>

            {horarios.length === 0 ? (
                <div className="empty-state">
                    <p className="text-xl text-gray-600">Aún no hay horarios creados</p>
                    <p className="text-lg text-gray-500 mt-4">Usa el botón superior para agregar uno</p>
                </div>
            ) : (
                <table className="table-bordered">
                    <thead>
                        <tr>
                            <th>Ubicación</th>
                            <th>Día</th>
                            <th>Apertura</th>
                            <th>Cierre</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        {horarios.map(h => (
                            <tr key={h.idHorario}>
                                <td className="capitalize font-medium">{h.ubicacion}</td>
                                <td>{h.dia_semana}</td>
                                <td>{h.hora_apertura?.substring(0, 5) || '—'}</td>
                                <td>{h.hora_cierre?.substring(0, 5) || '—'}</td>
                                <td>
                                    <span className={`badge ${h.activo ? 'badge-active' : 'badge-inactive'}`}>
                                        {h.activo ? 'Activo' : 'Inactivo'}
                                    </span>
                                </td>
                                <td className="flex gap-3 flex-wrap items-center">
                                    <button onClick={() => startEdit(h)} className="btn-edit">
                                        <Edit size={16} /> Editar
                                    </button>

                                    <label className="switch">
                                        <input
                                            type="checkbox"
                                            checked={!!h.activo} // !! para evitar undefined/null
                                            disabled={togglingId === h.idHorario}
                                            onChange={() => toggleActive(h)} // pasa el objeto completo
                                        />
                                        <span className="slider"></span>
                                    </label>

                                    {togglingId === h.idHorario && (
                                        <Loader2 className="animate-spin text-blue-600" size={18} />
                                    )}

                                    <button onClick={() => removeHorario(h.idHorario)} className="btn-delete">
                                        <Trash2 size={18} />
                                    </button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            )}
        </div>
    );
}