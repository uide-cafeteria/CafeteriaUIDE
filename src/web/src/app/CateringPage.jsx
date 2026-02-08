// src/pages/CateringAdmin.jsx
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Loader2, CheckCircle, XCircle, Ban, LogOut } from 'lucide-react';

export default function CateringAdmin() {
    const navigate = useNavigate();

    const [activeTab, setActiveTab] = useState('catering');
    const [solicitudes, setSolicitudes] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [processingId, setProcessingId] = useState(null);

    // ────────────────────────────────────────────────
    // Estilos globales (unificados con las páginas de referencia)
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
                const res = await fetch(`${process.env.REACT_APP_API_URL}/api/catering/admin/todas`, {
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
            const res = await fetch(`${process.env.REACT_APP_API_URL}/api/catering/admin/${idSolicitud}/responder`, {
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
            await fetch(`${process.env.REACT_APP_API_URL}/api/usuario/logout/admin`, {
                method: 'POST',
                headers: { Authorization: `Bearer ${token}` },
            });
        } catch { }
        localStorage.removeItem('authToken');
        navigate('/login');
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

            {/* Header */}
            <div className="cafeteria-header">
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <div>
                        <h1 className="cafeteria-title">Cafetería Admin</h1>
                        <p className="cafeteria-subtitle">Gestión de solicitudes de catering</p>
                    </div>
                    <button onClick={handleLogout} className="btn-logout">
                        Cerrar sesión
                    </button>
                </div>
            </div>

            {/* Navbar horizontal – ahora igual al de referencia */}
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

            {/* Contenido principal */}
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
                                                    className="bg-emerald-500 text-white px-4 py-2 rounded-lg hover:bg-emerald-600 transition"
                                                >
                                                    {processingId === s.idSolicitud ? (
                                                        <Loader2 className="animate-spin inline" size={18} />
                                                    ) : (
                                                        <CheckCircle size={18} />
                                                    )}
                                                </button>

                                                <button
                                                    onClick={() => handleResponder(s.idSolicitud, 'rechazada')}
                                                    disabled={processingId === s.idSolicitud}
                                                    className="bg-red-500 text-white px-4 py-2 rounded-lg hover:bg-red-600 transition"
                                                >
                                                    <XCircle size={18} />
                                                </button>

                                                <button
                                                    onClick={() => handleResponder(s.idSolicitud, 'cancelada')}
                                                    disabled={processingId === s.idSolicitud}
                                                    className="bg-gray-500 text-white px-4 py-2 rounded-lg hover:bg-gray-600 transition"
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