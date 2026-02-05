// src/pages/HorariosAtencion.jsx   (o donde prefieras guardarla)
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Plus, Trash2, Edit, Loader2, ArrowLeft } from 'lucide-react';

export default function HorarioAtencion() {
    const navigate = useNavigate();

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

    const token = localStorage.getItem('authToken');

    // ────────────────────────────────────────────────
    // Estilos copiados y ligeramente adaptados de tu página de referencia
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
            const res = await fetch('http://localhost:3002/api/horarios/mostrar/admin', {
                headers: { Authorization: `Bearer ${token}` },
            });

            if (!res.ok) {
                throw new Error('No se pudieron cargar los horarios');
            }

            const data = await res.json();
            setHorarios(data.horarios || []);
        } catch (err) {
            setError(err.message || 'Error desconocido');
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
            ? `http://localhost:3002/api/horarios/${editingId}`
            : 'http://localhost:3002/api/horarios/crear';

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
            alert(err.message || 'No se pudo guardar el horario');
        } finally {
            setSaving(false);
        }
    };

    const startEdit = (horario) => {
        setFormData({
            ubicacion: horario.ubicacion,
            dia_semana: horario.dia_semana,
            hora_apertura: horario.hora_apertura?.substring(0, 5) || '08:00',
            hora_cierre: horario.hora_cierre?.substring(0, 5) || '18:00',
        });
        setEditingId(horario.idHorario);
        setFormOpen(true);
    };

    const toggleActive = async (id) => {
        try {
            const res = await fetch(`http://localhost:3002/api/horarios/${id}/activar`, {
                method: 'PUT',
                headers: { Authorization: `Bearer ${token}` },
            });

            if (!res.ok) throw new Error('No se pudo cambiar el estado');
            loadHorarios();
        } catch (err) {
            alert(err.message || 'Error al cambiar estado');
        }
    };

    const removeHorario = async (id) => {
        if (!window.confirm('¿Seguro que quieres eliminar este horario?')) return;

        try {
            const res = await fetch(`http://localhost:3002/api/horarios/eliminar/${id}`, {
                method: 'DELETE',
                headers: { Authorization: `Bearer ${token}` },
            });

            if (!res.ok) throw new Error('No se pudo eliminar');
            loadHorarios();
        } catch (err) {
            alert(err.message || 'Error al eliminar');
        }
    };

    if (loading) {
        return (
            <div className="flex flex-col items-center justify-center h-screen gap-4 bg-gray-50">
                <Loader2 className="animate-spin text-blue-600" size={54} />
                <p className="text-2xl font-semibold text-gray-700">Cargando horarios...</p>
            </div>
        );
    }

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

            {/* Header igual al de la página de referencia */}
            <div className="cafeteria-header">
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <div>
                        <h1 className="cafeteria-title">Cafetería Admin</h1>
                        <p className="cafeteria-subtitle">Gestión de horarios de atención</p>
                    </div>
                    <button onClick={() => {
                        localStorage.removeItem('authToken');
                        navigate('/login');
                    }} className="btn-logout">
                        Cerrar sesión
                    </button>
                </div>
            </div>

            {/* Barra de acciones */}
            <div className="actions-bar">
                <button
                    onClick={() => navigate('/cafeteria')}
                    className="btn-back"
                >
                    <ArrowLeft size={20} /> Volver a Menús
                </button>

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
                >
                    <Plus size={20} /> Crear horario
                </button>
            </div>

            {/* Formulario (crear o editar) */}
            {formOpen && (
                <div className="form-container">
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
                            <button type="button" onClick={() => setFormOpen(false)} className="btn-back px-6 py-3">
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

            {/* Lista de horarios */}
            <h2 className="text-2xl font-bold mb-6">Horarios registrados</h2>

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
                                    {h.activo ? (
                                        <span className="badge badge-active">Activo</span>
                                    ) : (
                                        <span className="badge badge-inactive">Inactivo</span>
                                    )}
                                </td>
                                <td className="flex gap-3">
                                    <button onClick={() => startEdit(h)} className="btn-edit">Editar</button>
                                    <button
                                        onClick={() => toggleActive(h.idHorario)}
                                        className={h.activo ? 'btn-delete' : 'btn-add'}
                                    >
                                        {h.activo ? 'Desactivar' : 'Activar'}
                                    </button>
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