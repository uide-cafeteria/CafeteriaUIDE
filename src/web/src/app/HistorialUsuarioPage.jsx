// src/pages/admin/HistorialUsuarioPage.jsx
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { History, Loader2, RefreshCw, ArrowLeft } from 'lucide-react';

export default function HistorialUsuarioPage({ onLogout }) {
    const { idUsuario } = useParams();
    const navigate = useNavigate();

    const [historial, setHistorial] = useState([]);
    const [nombreEstudiante, setNombreEstudiante] = useState('Estudiante');
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');

    // Estilos consistentes con Cafeteria y Historial global
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
      .btn-back {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 10px 16px;
        background: #64748b;
        color: white;
        border: none;
        border-radius: 12px;
        font-weight: 600;
        cursor: pointer;
        transition: 0.3s;
      }
      .btn-back:hover {
        background: #475569;
        transform: translateY(-1px);
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
      .btn-refresh:hover:not(:disabled) {
        background: #ea580c;
        transform: translateY(-2px);
      }
      .btn-refresh:disabled {
        opacity: 0.6;
        cursor: not-allowed;
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
        display: inline-block;
      }
      .badge-gratis {
        background: #dcfce7;
        color: #15803d;
      }
      .badge-pagado {
        background: #dbeafe;
        color: #1d4ed8;
      }
      .empty-state {
        padding: 100px 20px;
        text-align: center;
        color: #64748b;
      }
    `}</style>
    );

    const cargarHistorial = async () => {
        try {
            setLoading(true);
            setError('');

            const token = localStorage.getItem('authToken');
            if (!token) throw new Error('No hay sesión');

            const res = await fetch(
                `http://localhost:3001/api/historial/admin/mostrar/${idUsuario}`,
                {
                    headers: { Authorization: `Bearer ${token}` }
                }
            );

            const data = await res.json();

            if (res.ok && data.status) {
                setHistorial(data.historial || []);
                if (data.historial?.length > 0) {
                    setNombreEstudiante(data.historial[0].cliente?.nombre || 'Usuario');
                }
            } else {
                setError(data.message || 'No se pudo cargar el historial');
            }
        } catch (err) {
            setError('Error al conectar con el servidor');
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        if (idUsuario) {
            cargarHistorial();
        }
    }, [idUsuario]);

    const handleLogout = () => {
        localStorage.removeItem('authToken');
        if (onLogout) onLogout();
        navigate('/login');
    };

    return (
        <div className="cafeteria-container">
            {globalStyles}

            {/* Header principal */}
            <div className="cafeteria-header">
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <div>
                        <h1 className="cafeteria-title">Historial del Usuario</h1>
                        <p className="cafeteria-subtitle">{nombreEstudiante}</p>
                    </div>
                    <button onClick={handleLogout} className="btn-logout">
                        Cerrar sesión
                    </button>
                </div>
            </div>

            {/* Barra de acciones */}
            <div
                style={{
                    background: '#ffffff',
                    borderRadius: '14px',
                    padding: '18px 25px',
                    marginBottom: '24px',
                    boxShadow: '0 3px 10px rgba(0,0,0,0.1)',
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    flexWrap: 'wrap',
                    gap: '16px'
                }}
            >
                <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                    <button
                        onClick={() => navigate(-1)}
                        className="btn-back"
                    >
                        <ArrowLeft size={18} />
                        Volver
                    </button>

                    <h2 style={{
                        fontSize: '22px',
                        fontWeight: '700',
                        color: '#0f172a',
                        margin: 0
                    }}>
                        Registro completo
                    </h2>
                </div>

                <button
                    onClick={cargarHistorial}
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
                ) : historial.length === 0 ? (
                    <div className="empty-state">
                        <History size={90} style={{ color: '#3b82f6', opacity: 0.7 }} className="mx-auto mb-8" />
                        <h3 style={{ fontSize: '1.75rem', fontWeight: '700', color: '#1e293b', marginBottom: '12px' }}>
                            Sin registros aún
                        </h3>
                        <p style={{ fontSize: '1.125rem' }}>
                            Este usuario aún no tiene almuerzos registrados en el sistema
                        </p>
                    </div>
                ) : (
                    <div className="overflow-x-auto">
                        <table className="table-historial">
                            <thead>
                                <tr>
                                    <th>Fecha</th>
                                    <th className="text-center">Hora</th>
                                    <th className="text-center">Tipo</th>
                                    <th className="text-center">Registrado por</th>
                                </tr>
                            </thead>
                            <tbody>
                                {historial.map((item, index) => (
                                    <tr key={index}>
                                        <td className="font-medium">
                                            {new Date(item.fecha).toLocaleDateString('es-EC', {
                                                weekday: 'long',
                                                year: 'numeric',
                                                month: 'short',
                                                day: 'numeric'
                                            })}
                                        </td>
                                        <td className="text-center" style={{ color: '#475569' }}>
                                            {new Date(item.fecha_registro).toLocaleTimeString('es-EC', {
                                                hour: '2-digit',
                                                minute: '2-digit'
                                            })}
                                        </td>
                                        <td className="text-center">
                                            {item.es_gratis ? (
                                                <span className="status-badge badge-gratis">GRATIS</span>
                                            ) : (
                                                <span className="status-badge badge-pagado">PAGADO</span>
                                            )}
                                        </td>
                                        <td className="text-center" style={{ color: '#475569' }}>
                                            {item.registradoPor?.nombre || 'Sistema'}
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