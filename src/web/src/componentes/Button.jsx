import React from 'react';

// Componente Button reutilizable para la cafetería
const Button = ({ 
  variant = 'primary',
  size = 'md',
  fullWidth = false,
  disabled = false,
  loading = false,
  icon = null,
  iconPosition = 'left',
  className = '',
  children,
  onClick,
  type = 'button',
  ...props 
}) => {
  // Estilos base para todos los botones
  const baseStyles = 'inline-flex items-center justify-center font-medium rounded-lg transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed';

  // Variantes de estilo (tema cafetería)
  const variantStyles = {
    primary: 'bg-amber-600 text-white hover:bg-amber-700 focus:ring-amber-500 shadow-md hover:shadow-lg',
    secondary: 'bg-yellow-500 text-gray-900 hover:bg-yellow-600 focus:ring-yellow-400 shadow-md hover:shadow-lg',
    outline: 'bg-transparent border-2 border-amber-600 text-amber-600 hover:bg-amber-50 focus:ring-amber-500',
    ghost: 'bg-transparent text-amber-700 hover:bg-amber-50 focus:ring-amber-500',
    danger: 'bg-red-600 text-white hover:bg-red-700 focus:ring-red-500 shadow-md',
    success: 'bg-green-600 text-white hover:bg-green-700 focus:ring-green-500 shadow-md',
    dark: 'bg-gray-800 text-white hover:bg-gray-900 focus:ring-gray-700 shadow-md',
  };

  // Tamaños
  const sizeStyles = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2 text-base',
    lg: 'px-6 py-3 text-lg',
    xl: 'px-8 py-4 text-xl',
  };

  // Ancho completo
  const widthStyle = fullWidth ? 'w-full' : '';

  const classes = [
    baseStyles,
    variantStyles[variant],
    sizeStyles[size],
    widthStyle,
    className,
  ].filter(Boolean).join(' ');

  return (
    <button
      type={type}
      className={classes}
      onClick={onClick}
      disabled={disabled || loading}
      {...props}
    >
      {loading ? (
        <>
          <svg 
            className="animate-spin -ml-1 mr-2 h-5 w-5" 
            xmlns="http://www.w3.org/2000/svg" 
            fill="none" 
            viewBox="0 0 24 24"
          >
            <circle 
              className="opacity-25" 
              cx="12" 
              cy="12" 
              r="10" 
              stroke="currentColor" 
              strokeWidth="4"
            />
            <path 
              className="opacity-75" 
              fill="currentColor" 
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            />
          </svg>
          Cargando...
        </>
      ) : (
        <>
          {icon && iconPosition === 'left' && <span className="mr-2">{icon}</span>}
          {children}
          {icon && iconPosition === 'right' && <span className="ml-2">{icon}</span>}
        </>
      )}
    </button>
  );
};

// Componente de demostración para la cafetería
export default function App() {
  const [loading, setLoading] = React.useState(false);
  const [orderCount, setOrderCount] = React.useState(0);

  const handleOrder = () => {
    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      setOrderCount(prev => prev + 1);
    }, 2000);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 via-yellow-50 to-orange-50 p-8">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <div className="text-center mb-12">
          <div className="text-6xl mb-4">☕</div>
          <h1 className="text-5xl font-bold text-amber-800 mb-2">
            Cafetería UID
          </h1>
          <p className="text-xl text-gray-600">
            Sistema de Botones para tu Aplicación
          </p>
        </div>

        {/* Grid de ejemplos */}
        <div className="grid gap-8">
          
          {/* Variantes */}
          <section className="bg-white rounded-2xl shadow-xl p-8">
            <h2 className="text-3xl font-bold text-gray-800 mb-6 flex items-center">
              <span className="mr-3">🎨</span> Variantes de Botones
            </h2>
            <div className="flex flex-wrap gap-4">
              <Button variant="primary">Primary</Button>
              <Button variant="secondary">Secondary</Button>
              <Button variant="outline">Outline</Button>
              <Button variant="ghost">Ghost</Button>
              <Button variant="danger">Danger</Button>
              <Button variant="success">Success</Button>
              <Button variant="dark">Dark</Button>
            </div>
          </section>

          {/* Tamaños */}
          <section className="bg-white rounded-2xl shadow-xl p-8">
            <h2 className="text-3xl font-bold text-gray-800 mb-6 flex items-center">
              <span className="mr-3">📏</span> Tamaños
            </h2>
            <div className="flex flex-wrap items-center gap-4">
              <Button size="sm">Pequeño</Button>
              <Button size="md">Mediano</Button>
              <Button size="lg">Grande</Button>
              <Button size="xl">Extra Grande</Button>
            </div>
          </section>

          {/* Con Iconos */}
          <section className="bg-white rounded-2xl shadow-xl p-8">
            <h2 className="text-3xl font-bold text-gray-800 mb-6 flex items-center">
              <span className="mr-3">⭐</span> Con Iconos
            </h2>
            <div className="flex flex-wrap gap-4">
              <Button variant="primary" icon="☕">
                Ordenar Café
              </Button>
              <Button variant="secondary" icon="🍰">
                Ver Postres
              </Button>
              <Button variant="success" icon="✓" iconPosition="right">
                Confirmar Pedido
              </Button>
              <Button variant="outline" icon="🛒">
                Carrito
              </Button>
            </div>
          </section>

          {/* Estados */}
          <section className="bg-white rounded-2xl shadow-xl p-8">
            <h2 className="text-3xl font-bold text-gray-800 mb-6 flex items-center">
              <span className="mr-3">⚙️</span> Estados
            </h2>
            <div className="flex flex-wrap gap-4">
              <Button variant="primary">Normal</Button>
              <Button variant="primary" disabled>Deshabilitado</Button>
              <Button variant="primary" loading>
                Cargando...
              </Button>
            </div>
          </section>

          {/* Ancho Completo */}
          <section className="bg-white rounded-2xl shadow-xl p-8">
            <h2 className="text-3xl font-bold text-gray-800 mb-6 flex items-center">
              <span className="mr-3">↔️</span> Ancho Completo
            </h2>
            <div className="space-y-3">
              <Button variant="primary" fullWidth icon="☕">
                Ordenar Café Americano - $3.50
              </Button>
              <Button variant="secondary" fullWidth icon="🥐">
                Agregar Croissant - $2.00
              </Button>
              <Button variant="success" fullWidth icon="💳">
                Proceder al Pago
              </Button>
            </div>
          </section>

          {/* Simulación de Menú */}
          <section className="bg-gradient-to-br from-amber-100 to-yellow-100 rounded-2xl shadow-xl p-8">
            <h2 className="text-3xl font-bold text-amber-900 mb-6 flex items-center">
              <span className="mr-3">📋</span> Ejemplo: Menú de Cafetería
            </h2>
            
            <div className="grid md:grid-cols-2 gap-6">
              {/* Bebidas */}
              <div className="bg-white rounded-xl p-6 shadow-lg">
                <h3 className="text-2xl font-bold text-gray-800 mb-4">☕ Bebidas</h3>
                <div className="space-y-3">
                  <div className="flex justify-between items-center">
                    <span className="text-gray-700">Café Americano</span>
                    <Button size="sm" variant="primary" icon="➕">$3.50</Button>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-gray-700">Cappuccino</span>
                    <Button size="sm" variant="primary" icon="➕">$4.00</Button>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-gray-700">Latte</span>
                    <Button size="sm" variant="primary" icon="➕">$4.50</Button>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-gray-700">Mocha</span>
                    <Button size="sm" variant="primary" icon="➕">$5.00</Button>
                  </div>
                </div>
              </div>

              {/* Comida */}
              <div className="bg-white rounded-xl p-6 shadow-lg">
                <h3 className="text-2xl font-bold text-gray-800 mb-4">🥐 Comida</h3>
                <div className="space-y-3">
                  <div className="flex justify-between items-center">
                    <span className="text-gray-700">Croissant</span>
                    <Button size="sm" variant="secondary" icon="➕">$2.00</Button>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-gray-700">Sandwich</span>
                    <Button size="sm" variant="secondary" icon="➕">$6.50</Button>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-gray-700">Muffin</span>
                    <Button size="sm" variant="secondary" icon="➕">$3.00</Button>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-gray-700">Bagel</span>
                    <Button size="sm" variant="secondary" icon="➕">$2.50</Button>
                  </div>
                </div>
              </div>
            </div>

            {/* Acciones de Pedido */}
            <div className="mt-6 bg-white rounded-xl p-6 shadow-lg">
              <div className="flex justify-between items-center mb-4">
                <span className="text-xl font-semibold text-gray-800">
                  Total de pedidos: {orderCount}
                </span>
                <Button variant="outline" size="sm" onClick={() => setOrderCount(0)}>
                  Limpiar
                </Button>
              </div>
              <div className="grid md:grid-cols-3 gap-3">
                <Button 
                  variant="success" 
                  fullWidth 
                  icon="✓"
                  onClick={handleOrder}
                  loading={loading}
                >
                  Confirmar
                </Button>
                <Button variant="outline" fullWidth icon="👁️">
                  Ver Carrito
                </Button>
                <Button variant="danger" fullWidth icon="❌">
                  Cancelar
                </Button>
              </div>
            </div>
          </section>

          {/* Código de Uso */}
          <section className="bg-white rounded-2xl shadow-xl p-8">
            <h2 className="text-3xl font-bold text-gray-800 mb-6 flex items-center">
              <span className="mr-3">💻</span> Cómo Usar
            </h2>
            <div className="bg-gray-900 text-green-400 p-6 rounded-lg font-mono text-sm overflow-x-auto">
              <div className="space-y-2">
                <div>{'<Button variant="primary" size="md">'}</div>
                <div className="ml-4">Ordenar Café</div>
                <div>{'</Button>'}</div>
                <div className="mt-4">{'<Button variant="outline" icon="☕" fullWidth>'}</div>
                <div className="ml-4">Con Icono y Ancho Completo</div>
                <div>{'</Button>'}</div>
                <div className="mt-4">{'<Button variant="success" loading>'}</div>
                <div className="ml-4">Procesando...</div>
                <div>{'</Button>'}</div>
              </div>
            </div>
          </section>

        </div>
      </div>
    </div>
  );
}