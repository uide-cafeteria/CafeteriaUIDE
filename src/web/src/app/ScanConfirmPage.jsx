import React, { useState, useEffect } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { Check, X, User, Loader2 } from 'lucide-react';

export default function ScanConfirmPage() {
  const [estudiante, setEstudiante] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [registrando, setRegistrando] = useState(false);
  const [resultado, setResultado] = useState(null);

  const location = useLocation();
  const navigate = useNavigate();

  const token = new URLSearchParams(location.search).get('token')
    || new URLSearchParams(location.search).get('loyalty_token');

  useEffect(() => {
    if (!token) {
      setError("No se encontró QR válido");
      setLoading(false);
      return;
    }
    buscarEstudiante(token);
  }, [token]);

  const buscarEstudiante = async (loyalty_token) => {
    try {
      const res = await fetch(`http://localhost:3001/api/historial/buscar/${loyalty_token}`);
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

  const registrarAlmuerzo = async () => {
    setRegistrando(true);
    try {
      const authToken = localStorage.getItem('authToken');
      const res = await fetch('http://localhost:3001/api/historial/registrar', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${authToken}`
        },
        body: JSON.stringify({ loyalty_token: token })
      });

      const data = await res.json();

      if (res.ok && data.status) {
        setResultado({
          success: true,
          mensaje: data.message,
          esGratis: data.data?.almuerzo?.es_gratis || false
        });
      } else {
        setResultado({ success: false, mensaje: data.message || "Error" });
      }
    } catch (err) {
      setResultado({ success: false, mensaje: "Error de conexión" });
    } finally {
      setRegistrando(false);
    }
  };

  if (loading) return (
    <div className="min-h-screen bg-gradient-to-br from-orange-500 to-red-600 flex items-center justify-center">
      <Loader2 className="animate-spin text-white" size={80} />
    </div>
  );

  return (
    <div className="min-h-screen bg-gradient-to-br from-orange-500 to-red-600 flex items-center justify-center p-6">
      <div className="bg-white rounded-3xl shadow-2xl max-w-lg w-full overflow-hidden">
        {/* Header decorativo opcional */}
        <div className="h-2 bg-gradient-to-r from-orange-500 to-red-600"></div>

        <div className="p-10 pb-12 text-center">

          {error ? (
            <>
              <div className="mx-auto w-32 h-32 bg-red-100 rounded-full flex items-center justify-center mb-8">
                <X className="w-20 h-20 text-red-600" />
              </div>
              <h1 className="text-4xl font-bold text-red-600 mb-4">Error</h1>
              <p className="text-xl text-gray-700 mb-10">{error}</p>
              <button
                onClick={() => navigate('/cafeteria')}
                className="bg-gray-600 hover:bg-gray-700 text-white px-10 py-5 rounded-full text-xl font-semibold transition"
              >
                Volver al panel
              </button>
            </>
          ) : !resultado ? (
            <>
              {/* Avatar del estudiante */}
              <div className="mx-auto w-40 h-40 bg-orange-100 rounded-full flex items-center justify-center mb-8 shadow-lg">
                <User className="w-24 h-24 text-orange-600" />
              </div>

              <h1 className="text-4xl font-bold text-gray-800 mb-6">¿Registrar almuerzo?</h1>
              <h2 className="text-3xl font-bold text-orange-600 mb-3">{estudiante?.nombre}</h2>
              <p className="text-2xl text-gray-600 mb-12">#{estudiante?.codigoUnico || 'Sin código'}</p>

              <div className="flex gap-6">
                <button
                  onClick={() => navigate('/cafeteria')}
                  className="flex-1 bg-gray-500 hover:bg-gray-600 text-white py-5 rounded-2xl text-xl font-bold transition shadow-md"
                >
                  Cancelar
                </button>
                <button
                  onClick={registrarAlmuerzo}
                  disabled={registrando}
                  className="flex-1 bg-green-600 hover:bg-green-700 text-white py-5 rounded-2xl text-xl font-bold transition shadow-md flex items-center justify-center gap-3"
                >
                  {registrando ? (
                    "Registrando..."
                  ) : (
                    <>
                      <Check size={36} />
                      Confirmar
                    </>
                  )}
                </button>
              </div>
            </>
          ) : (
            <>
              {resultado.success ? (
                <>
                  <div className="mx-auto w-40 h-40 bg-green-100 rounded-full flex items-center justify-center mb-8 shadow-lg animate-pulse">
                    <Check className="w-24 h-24 text-green-600" />
                  </div>
                  <h1 className="text-5xl font-bold text-green-600 mb-8">¡REGISTRADO!</h1>

                  {resultado.esGratis && (
                    <div className="inline-block bg-gradient-to-r from-green-500 to-emerald-600 text-white px-10 py-5 rounded-full text-3xl font-bold shadow-lg mb-8">
                      ALMUERZO GRATIS 🎉
                    </div>
                  )}

                  <p className="text-2xl text-gray-700 mb-12">{resultado.mensaje}</p>
                </>
              ) : (
                <>
                  <div className="mx-auto w-40 h-40 bg-red-100 rounded-full flex items-center justify-center mb-8">
                    <X className="w-24 h-24 text-red-600" />
                  </div>
                  <h1 className="text-5xl font-bold text-red-600 mb-8">ERROR</h1>
                  <p className="text-2xl text-gray-700 mb-12">{resultado.mensaje}</p>
                </>
              )}

              <button
                onClick={() => navigate('/scan-qr')}
                className="bg-gradient-to-r from-orange-600 to-red-600 hover:from-orange-700 hover:to-red-700 text-white px-12 py-6 rounded-full text-2xl font-bold transition shadow-lg"
              >
                Escanear otro QR
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  );
}