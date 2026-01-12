// src/pages/HistorialAlmuerzosPage.jsx
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { History, Loader2, RefreshCw, Eye } from 'lucide-react';

export default function HistorialAlmuerzosPage({ onLogout }) {
    const navigate = useNavigate();
    const [registros, setRegistros] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [activeTab] = useState('historial');

    // Estilos (incluyendo los del navbar)
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
      .btn-refresh {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 12px 20px;
        background: #f97316;
        color: white;
        border: none;
        border-radius: 12px;
        cursor: pointer;
        font-weight: 600;
        transition: 0.3s;
      }
      .btn-refresh:hover {
        background: #ea580c;
        transform: translateY(-2px);
      }
      .btn-refresh:disabled {
        opacity: 0.6;
        cursor: not-allowed;
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
      .table-container {
        background: #ffffff;
        border-radius: 16px;
        overflow: hidden;
        box-shadow: 0 4px 20px rgba(0,0,0,0.08);
      }
      .table-historial {
        border-collapse: collapse;
        width: 100%;
      }
      .table-historial th {
        background: #f1f5f9;
        padding: 16px 20px;
        text-align: left;
        font-weight: 600;
        color: #334155;
        border-bottom: 2px solid #e2e8f0;
      }
      .table-historial td {
        padding: 16px 20px;
        border-bottom: 1px solid #e5e7eb;
        color: #1e293b;
      }
      .table-historial tr:hover {
        background: #f8fafc;
      }
      .status-badge {
        padding: 6px 14px;
        border-radius: 999px;
        font-size: 0.875rem;
        font-weight: 600;
      }
      .badge-gratis {
        background: #dcfce7;
        color: #15803d;
      }
      .badge-pagado {
        background: #dbeafe;
        color: #1d4ed8;
      }
      .btn-ver {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 8px 16px;
        background: #3b82f6;
        color: white;
        border: none;
        border-radius: 10px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s;
      }
      .btn-ver:hover {
        background: #2563eb;
        transform: translateY(-1px);
      }
      .empty-state {
        padding: 100px 20px;
        text-align: center;
        color: #64748b;
      }
      .empty-icon {
        color: #3b82f6;
        opacity: 0.7;
      }
    `}</style>
    );

    const cargarRegistros = async () => {
        try {
            setLoading(true);
            setError('');

            const token = localStorage.getItem('authToken');
            if (!token) throw new Error('No hay sesión');

            const res = await fetch('http://localhost:3001/api/historial/admin/global', {
                headers: { Authorization: `Bearer ${token}` },
            });

            const data = await res.json();

            if (res.ok && data.status) {
                setRegistros(data.historial || []);
            } else {
                setError(data.message || 'No se pudo cargar los registros');
            }
        } catch (err) {
            setError('Error al conectar con el servidor');
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        cargarRegistros();
    }, []);

    const verHistorialEstudiante = (idUsuario) => {
        navigate(`/historial-usuario/${idUsuario}`);
    };

    const handleLogout = () => {
        localStorage.removeItem('authToken');
        if (onLogout) onLogout();
        navigate('/login');
    };

    return (
        <div className="cafeteria-container">
            {globalStyles}

            {/* Header */}
            <div className="cafeteria-header">
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <div>
                        <h1 className="cafeteria-title">Cafetería Admin</h1>
                        <p className="cafeteria-subtitle">Gestión y registros</p>
                    </div>
                    <button onClick={handleLogout} className="btn-logout">
                        Cerrar sesión
                    </button>
                </div>
            </div>

            {/* Navbar horizontal - igual que en la página principal */}
            <div className="navbar-horizontal">
                <button
                    className={`tab-button ${activeTab === 'historial' ? 'active' : ''}`}
                    onClick={() => navigate('/historial-almuerzos')}
                >
                    Historial de Almuerzos
                </button>
            </div>

            {/* Acciones superiores */}
            <div className="actions-bar">
                <h2 className="actions-title">Registros Recientes</h2>

                <button
                    onClick={cargarRegistros}
                    disabled={loading}
                    className="btn-refresh"
                >
                    <RefreshCw size={18} className={loading ? 'animate-spin' : ''} />
                    Actualizar
                </button>
            </div>

            {/* Contenido principal */}
            <div className="table-container">
                {loading ? (
                    <div className="p-20 text-center">
                        <Loader2 className="animate-spin mx-auto mb-6 text-blue-600" size={60} />
                        <p style={{ fontSize: '1.25rem', color: '#475569' }}>Cargando historial...</p>
                    </div>
                ) : error ? (
                    <div className="p-12 text-center text-red-600 text-xl font-medium">{error}</div>
                ) : registros.length === 0 ? (
                    <div className="empty-state">
                        <History size={100} className="empty-icon mx-auto mb-8" />
                        <h3 style={{ fontSize: '1.75rem', fontWeight: '700', color: '#1e293b', marginBottom: '12px' }}>
                            No hay registros aún
                        </h3>
                        <p style={{ fontSize: '1.125rem' }}>
                            Cuando los usuarios comiencen a registrar almuerzos aparecerán aquí
                        </p>
                    </div>
                ) : (
                    <div className="overflow-x-auto">
                        <table className="table-historial">
                            <thead>
                                <tr>
                                    <th>Usuario</th>
                                    <th>Fecha / Hora</th>
                                    <th className="text-center">Tipo</th>
                                    <th className="text-center">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                {registros.map((registro) => (
                                    <tr key={registro.idHistorial}>
                                        <td className="font-medium">{registro.cliente?.nombre || '—'}</td>
                                        <td style={{ color: '#475569' }}>
                                            {new Date(registro.fecha_registro).toLocaleString('es-EC', {
                                                dateStyle: 'medium',
                                                timeStyle: 'short',
                                            })}
                                        </td>
                                        <td className="text-center">
                                            {registro.es_gratis ? (
                                                <span className="status-badge badge-gratis">GRATIS</span>
                                            ) : (
                                                <span className="status-badge badge-pagado">PAGADO</span>
                                            )}
                                        </td>
                                        <td className="text-center">
                                            <button
                                                onClick={() => verHistorialEstudiante(registro.cliente?.idUsuario)}
                                                className="btn-ver"
                                                title="Ver historial completo del usuario"
                                            >
                                                <Eye size={18} />
                                                Ver historial
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