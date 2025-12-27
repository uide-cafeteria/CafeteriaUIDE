// src/pages/ScanQRPage.jsx
import React, { useState, useEffect, useRef } from 'react';
import { Html5Qrcode } from 'html5-qrcode';
import { CheckCircle, XCircle, User, AlertCircle, QrCode, Check } from 'lucide-react';

export default function ScanQRPage() {
    const [scanning, setScanning] = useState(true);
    const [estudiante, setEstudiante] = useState(null);
    const [loading, setLoading] = useState(false);
    const [result, setResult] = useState(null);
    const [error, setError] = useState('');

    // Usamos useRef para guardar la instancia del escáner
    const scannerRef = useRef(null);

    useEffect(() => {
        if (!scanning) return;

        const html5QrCode = new Html5Qrcode("reader");
        scannerRef.current = html5QrCode; // Guardamos la referencia

        const config = {
            fps: 10,
            qrbox: { width: 280, height: 280 },
            aspectRatio: 1,
        };

        html5QrCode.start(
            { facingMode: "environment" },
            config,
            async (decodedText) => {
                setScanning(false);
                await buscarEstudiante(decodedText.trim());
            },
            () => { }
        ).catch((err) => {
            setError("No se pudo acceder a la cámara");
            setScanning(false);
        });

        // LIMPIEZA SEGURA
        return () => {
            if (scannerRef.current) {
                scannerRef.current.stop()
                    .then(() => {
                        scannerRef.current = null;
                    })
                    .catch(() => { }); // ignoramos errores al detener
            }
        };
    }, [scanning]);

    const buscarEstudiante = async (token) => {
        setLoading(true);
        try {
            const res = await fetch(`http://localhost:3001/api/usuario/buscar-por-token/${token}`);
            const data = await res.json();

            if (res.ok && data.status) {
                setEstudiante(data.usuario);
            } else {
                setError(data.message || "Estudiante no encontrado");
            }
        } catch (err) {
            setError("Error de conexión");
        } finally {
            setLoading(false);
        }
    };

    const confirmarRegistro = async () => {
        setLoading(true);
        try {
            const token = localStorage.getItem('authToken');
            const res = await fetch('http://localhost:3001/api/almuerzo/registrar', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify({ loyalty_token: estudiante.loyalty_token })
            });

            const data = await res.json();

            if (res.ok && data.status) {
                // SONIDO + VIBRACIÓN
                const audio = new Audio('data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAAAAA=');
                audio.play().catch(() => { });
                if (navigator.vibrate) navigator.vibrate([200, 100, 200]);

                setResult({
                    success: true,
                    nombre: estudiante.nombre,
                    esGratis: data.data?.almuerzo?.es_gratis || false,
                    mensaje: data.message
                });
            } else {
                setResult({ success: false, mensaje: data.message || "Error" });
            }
        } catch (err) {
            setResult({ success: false, mensaje: "Error de conexión" });
        } finally {
            setLoading(false);
        }
    };

    const volverAEscanear = () => {
        setEstudiante(null);
        setResult(null);
        setError('');
        setScanning(true);
    };

    return (
        <div className="min-h-screen bg-gray-900 flex flex-col">
            <div className="bg-orange-600 text-white p-4 text-center">
                <h1 className="text-2xl font-bold">Escanear Almuerzo</h1>
                <p className="text-sm opacity-90">Apunta la cámara al QR del estudiante</p>
            </div>

            <div className="flex-1 flex flex-col items-center justify-center p-4">
                {!result ? (
                    <>
                        <div id="reader" className="w-full max-w-md rounded-2xl overflow-hidden shadow-2xl"></div>

                        {error && (
                            <div className="mt-4 bg-red-600 text-white p-4 rounded-lg flex items-center gap-3">
                                <AlertCircle size={24} />
                                <span>{error}</span>
                            </div>
                        )}

                        <button
                            onClick={() => setScanning(false)}
                            className="mt-6 bg-red-600 text-white px-8 py-3 rounded-full font-bold text-lg"
                        >
                            Cancelar
                        </button>
                    </>
                ) : (
                    <div className="bg-white rounded-3xl shadow-2xl p-8 max-w-md w-full text-center animate-pulse">
                        {result.success ? (
                            <>
                                <CheckCircle size={100} className="text-green-500 mx-auto mb-6" />
                                <h2 className="text-4xl font-bold text-green-600 mb-4">
                                    ¡REGISTRADO!
                                </h2>
                                <div className="bg-gray-100 rounded-2xl p-6 mb-6">
                                    <User size={60} className="text-orange-600 mx-auto mb-4" />
                                    <h3 className="text-2xl font-bold">{result.estudiante}</h3>
                                    {result.esGratis && (
                                        <div className="mt-4 bg-green-100 text-green-800 px-6 py-3 rounded-full text-xl font-bold">
                                            ALMUERZO GRATIS
                                        </div>
                                    )}
                                </div>
                                <p className="text-gray-600 text-lg mb-8">{result.mensaje}</p>
                            </>
                        ) : (
                            <>
                                <XCircle size={100} className="text-red-500 mx-auto mb-6" />
                                <h2 className="text-4xl font-bold text-red-600 mb-4">ERROR</h2>
                                <p className="text-xl text-gray-700">{result.mensaje}</p>
                            </>
                        )}

                        <button
                            onClick={volverAEscanear}
                            className="mt-8 bg-orange-600 text-white px-12 py-4 rounded-full font-bold text-xl hover:bg-orange-700 transition-all transform hover:scale-105"
                        >
                            Escanear otro
                        </button>
                    </div>
                )}
            </div>
        </div>
    );
}