// src/pages/CateringAdmin.jsx
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Loader2, CheckCircle, XCircle, Ban, LogOut } from 'lucide-react';

export default function CateringAdmin() {
    const navigate = useNavigate();

    const [solicitudes, setSolicitudes] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [processingId, setProcessingId] = useState(null);

    // ────────────────────────────────────────────────
    // Estilos globales copiados y adaptados de MenuProductos
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
      .btn-confirm {
        background: #10b981;
        color: white;
        border: none;
        padding: 8px 14px;
        border-radius: 10px;
        cursor: pointer;
        font-weight: 600;
        transition: 0.2s;
      }
      .btn-confirm:hover:not(:disabled) { 
        background: #059669; 
        transform: scale(1.05); 
      }
      .btn-reject {
        background: #ef4444;
        color: white;
        border: none;
        padding: 8px 14px;
        border-radius: 10px;
        cursor: pointer;
        font-weight: 600;
        transition: 0.2s;
      }
      .btn-reject:hover:not(:disabled) { 
        background: #dc2626; 
        transform: scale(1.05); 
      }
      .btn-cancel {
        background: #6b7280;
        color: white;
        border: none;
        padding: 8px 14px;
        border-radius: 10px;
        cursor: pointer;
        font-weight: 600;
        transition: 0.2s;
      }
      .btn-cancel:hover:not(:disabled) { 
        background: #4b5563; 
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
      .badge {
        padding: 6px 12px;
        border-radius: 9999px;
        font-size: 0.875rem;
        font-weight: 600;
      }
      .badge-pendiente { background: #fef3c7; color: #92400e; }
      .badge-confirmada { background: #dcfce7; color: #166534; }
      .badge-rechazada { background: #fee2e2; color: #991b1b; }
      .badge-cancelada { background: #f3f4f6; color: #374151; }
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
        const fetchSolicitudes = async () => {
            const token = localStorage.getItem('authToken');
            if (!token) {
                navigate('/login');
                return;
            }

            try {
                const res = await fetch('http://localhost:3002/api/catering/admin/todas', {
                    headers: { Authorization: `Bearer ${token}` },
                });

                if (!res.ok) {
                    if (res.status === 403) throw new Error('Acceso denegado - solo administradores');
                    throw new Error('No se pudieron cargar las solicitudes');
                }

                const data = await res.json();
                setSolicitudes(data.solicitudes || []);
            } catch (err) {
                setError(err.message || 'Error al cargar solicitudes');
            } finally {
                setLoading(false);
            }
        };

        fetchSolicitudes();
    }, [navigate]);

    const handleResponder = async (idSolicitud, estado) => {
        if (!window.confirm(`¿Confirmar "${estado}" esta solicitud?`)) return;

        setProcessingId(idSolicitud);

        const token = localStorage.getItem('authToken');

        try {
            const res = await fetch(`http://localhost:3002/api/catering/admin/${idSolicitud}/responder`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                    Authorization: `Bearer ${token}`,
                },
                body: JSON.stringify({ estado }),
            });

            if (!res.ok) {
                const errData = await res.json();
                throw new Error(errData.message || 'No se pudo procesar');
            }

            // Actualizar lista local
            setSolicitudes(prev =>
                prev.map(s => (s.idSolicitud === idSolicitud ? { ...s, estado } : s))
            );

            alert(`Solicitud ${estado} correctamente`);
        } catch (err) {
            alert(err.message || 'Error al procesar solicitud');
        } finally {
            setProcessingId(null);
        }
    };

    const handleLogout = async () => {
        const token = localStorage.getItem('authToken');
        try {
            await fetch('http://localhost:3002/api/usuario/logout/admin', {
                method: 'POST',
                headers: { Authorization: `Bearer ${token}` },
            });
        } catch { }
        localStorage.removeItem('authToken');
        navigate('/login');
    };

    if (loading) {
        return (
            <div className="flex flex-col items-center justify-center h-screen gap-4 bg-gray-50">
                <Loader2 className="animate-spin text-blue-600" size={54} />
                <p className="text-2xl font-semibold text-gray-700">Cargando solicitudes de catering...</p>
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

            {/* Header */}
            <div className="cafeteria-header">
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <div>
                        <h1 className="cafeteria-title">Cafetería Admin</h1>
                        <p className="cafeteria-subtitle">Gestión de solicitudes de catering</p>
                    </div>
                    <button onClick={handleLogout} className="btn-logout">
                        <LogOut size={20} /> Cerrar sesión
                    </button>
                </div>
            </div>

            {/* Barra de acciones */}
            <div className="actions-bar" style={{ marginBottom: '32px' }}>
                <button onClick={() => navigate('/cafeteria')} className="btn-back">
                    <ArrowLeft size={20} /> Volver a Menús
                </button>

                <h2 className="actions-title">
                    Solicitudes de Catering ({solicitudes.length})
                </h2>
            </div>

            {/* Tabla de solicitudes */}
            {solicitudes.length === 0 ? (
                <div className="empty-state">
                    <p className="text-xl text-gray-600">No hay solicitudes de catering aún</p>
                    <p className="text-lg text-gray-500 mt-4">
                        Cuando los usuarios envíen solicitudes aparecerán aquí
                    </p>
                </div>
            ) : (
                <div className="table-container-expanded">
                    <table className="table-bordered">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Solicitante</th>
                                <th>Evento</th>
                                <th>Fecha / Hora</th>
                                <th>Personas</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            {solicitudes.map(s => (
                                <tr key={s.idSolicitud}>
                                    <td className="font-medium">#{s.idSolicitud}</td>
                                    <td>
                                        <div>
                                            <strong>{s.nombre_completo}</strong>
                                            <div style={{ fontSize: '0.875rem', color: '#64748b' }}>
                                                {s.correo} • {s.telefono}
                                            </div>
                                        </div>
                                    </td>
                                    <td>{s.tipo_evento}</td>
                                    <td>
                                        {new Date(s.fecha_evento).toLocaleDateString('es-ES')}
                                        {s.hora_evento ? ` ${s.hora_evento.substring(0, 5)}` : ''}
                                    </td>
                                    <td>{s.cantidad_personas ? `${s.cantidad_personas} pers.` : '—'}</td>
                                    <td>
                                        <span className={`badge badge-${s.estado}`}>
                                            {s.estado.charAt(0).toUpperCase() + s.estado.slice(1)}
                                        </span>
                                    </td>
                                    <td className="flex gap-2">
                                        {s.estado === 'pendiente' && (
                                            <>
                                                <button
                                                    onClick={() => handleResponder(s.idSolicitud, 'confirmada')}
                                                    disabled={processingId === s.idSolicitud}
                                                    className="btn-confirm"
                                                    title="Confirmar"
                                                >
                                                    {processingId === s.idSolicitud ? (
                                                        <Loader2 className="animate-spin" size={18} />
                                                    ) : (
                                                        <CheckCircle size={18} />
                                                    )}
                                                </button>

                                                <button
                                                    onClick={() => handleResponder(s.idSolicitud, 'rechazada')}
                                                    disabled={processingId === s.idSolicitud}
                                                    className="btn-reject"
                                                    title="Rechazar"
                                                >
                                                    <XCircle size={18} />
                                                </button>

                                                <button
                                                    onClick={() => handleResponder(s.idSolicitud, 'cancelada')}
                                                    disabled={processingId === s.idSolicitud}
                                                    className="btn-cancel"
                                                    title="Cancelar"
                                                >
                                                    <Ban size={18} />
                                                </button>
                                            </>
                                        )}
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            )}
        </div>
    );
}