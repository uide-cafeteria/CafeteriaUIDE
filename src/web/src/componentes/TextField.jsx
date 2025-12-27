import React from 'react';

// Componente Text reutilizable
const Text = ({ 
  variant = 'body',
  size = 'md',
  weight = 'normal',
  color = 'gray-900',
  align = 'left',
  className = '',
  children,
  ...props 
}) => {
  // Mapeo de variantes a etiquetas HTML
  const variantMap = {
    h1: 'h1',
    h2: 'h2',
    h3: 'h3',
    h4: 'h4',
    h5: 'h5',
    h6: 'h6',
    body: 'p',
    span: 'span',
    label: 'label',
    small: 'small',
  };

  // Estilos de tamaño
  const sizeStyles = {
    xs: 'text-xs',
    sm: 'text-sm',
    md: 'text-base',
    lg: 'text-lg',
    xl: 'text-xl',
    '2xl': 'text-2xl',
    '3xl': 'text-3xl',
    '4xl': 'text-4xl',
  };

  // Estilos de peso
  const weightStyles = {
    thin: 'font-thin',
    light: 'font-light',
    normal: 'font-normal',
    medium: 'font-medium',
    semibold: 'font-semibold',
    bold: 'font-bold',
    extrabold: 'font-extrabold',
  };

  // Estilos de alineación
  const alignStyles = {
    left: 'text-left',
    center: 'text-center',
    right: 'text-right',
    justify: 'text-justify',
  };

  const Component = variantMap[variant] || 'p';

  const classes = [
    sizeStyles[size],
    weightStyles[weight],
    `text-${color}`,
    alignStyles[align],
    className,
  ].filter(Boolean).join(' ');

  return (
    <Component className={classes} {...props}>
      {children}
    </Component>
  );
};

// Componente de demostración
export default function App() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-8">
      <div className="max-w-4xl mx-auto bg-white rounded-2xl shadow-xl p-8 space-y-8">
        <div className="text-center border-b pb-6">
          <Text variant="h1" size="4xl" weight="bold" color="indigo-600">
            Componente Text
          </Text>
          <Text variant="body" size="lg" color="gray-600" className="mt-2">
            Un componente flexible y reutilizable para todo tu texto
          </Text>
        </div>

        <section className="space-y-4">
          <Text variant="h2" size="2xl" weight="semibold" color="gray-800">
            Encabezados
          </Text>
          <div className="space-y-3 bg-gray-50 p-6 rounded-lg">
            <Text variant="h1" size="3xl" weight="bold">Heading 1 - Título principal</Text>
            <Text variant="h2" size="2xl" weight="semibold">Heading 2 - Subtítulo</Text>
            <Text variant="h3" size="xl" weight="medium">Heading 3 - Sección</Text>
            <Text variant="h4" size="lg">Heading 4 - Subsección</Text>
          </div>
        </section>

        <section className="space-y-4">
          <Text variant="h2" size="2xl" weight="semibold" color="gray-800">
            Tamaños de Texto
          </Text>
          <div className="space-y-3 bg-gray-50 p-6 rounded-lg">
            <Text size="xs">Extra pequeño (xs) - Notas al pie</Text>
            <Text size="sm">Pequeño (sm) - Texto secundario</Text>
            <Text size="md">Mediano (md) - Texto por defecto</Text>
            <Text size="lg">Grande (lg) - Texto destacado</Text>
            <Text size="xl">Extra grande (xl) - Títulos</Text>
          </div>
        </section>

        <section className="space-y-4">
          <Text variant="h2" size="2xl" weight="semibold" color="gray-800">
            Pesos de Fuente
          </Text>
          <div className="space-y-3 bg-gray-50 p-6 rounded-lg">
            <Text weight="light">Light - Texto ligero</Text>
            <Text weight="normal">Normal - Texto regular</Text>
            <Text weight="medium">Medium - Texto medio</Text>
            <Text weight="semibold">Semibold - Texto semi-negrita</Text>
            <Text weight="bold">Bold - Texto en negrita</Text>
          </div>
        </section>

        <section className="space-y-4">
          <Text variant="h2" size="2xl" weight="semibold" color="gray-800">
            Alineación
          </Text>
          <div className="space-y-4 bg-gray-50 p-6 rounded-lg">
            <Text align="left">Texto alineado a la izquierda</Text>
            <Text align="center">Texto centrado</Text>
            <Text align="right">Texto alineado a la derecha</Text>
            <Text align="justify">
              Texto justificado. Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
              Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
            </Text>
          </div>
        </section>

        <section className="space-y-4">
          <Text variant="h2" size="2xl" weight="semibold" color="gray-800">
            Colores
          </Text>
          <div className="space-y-3 bg-gray-50 p-6 rounded-lg">
            <Text color="gray-900">Texto gris oscuro</Text>
            <Text color="blue-600">Texto azul</Text>
            <Text color="green-600">Texto verde</Text>
            <Text color="red-600">Texto rojo</Text>
            <Text color="purple-600">Texto morado</Text>
            <Text color="amber-600">Texto ámbar</Text>
          </div>
        </section>

        <section className="space-y-4">
          <Text variant="h2" size="2xl" weight="semibold" color="gray-800">
            Ejemplo Práctico
          </Text>
          <div className="bg-gradient-to-r from-purple-50 to-pink-50 p-6 rounded-lg space-y-3">
            <Text variant="h3" size="xl" weight="bold" color="purple-800">
              Bienvenido a nuestra aplicación
            </Text>
            <Text size="lg" color="gray-700">
              Este es un ejemplo de cómo usar el componente Text en un contexto real.
            </Text>
            <Text color="gray-600">
              Puedes combinar diferentes propiedades para crear la jerarquía visual 
              perfecta para tu aplicación. El componente es completamente personalizable.
            </Text>
            <Text size="sm" color="gray-500" className="italic">
              Última actualización: Noviembre 2025
            </Text>
          </div>
        </section>

        <section className="bg-indigo-50 p-6 rounded-lg">
          <Text variant="h3" size="lg" weight="semibold" color="indigo-800" className="mb-3">
            💡 Cómo usar
          </Text>
          <Text color="gray-700" className="mb-2">
            Importa el componente y úsalo con las props que necesites:
          </Text>
          <div className="bg-white p-4 rounded border-l-4 border-indigo-500 font-mono text-sm">
            <Text size="sm" className="text-gray-800">
              {`<Text variant="h1" size="2xl" weight="bold" color="blue-600">`}
            </Text>
            <Text size="sm" className="text-gray-800 ml-4">
              Tu texto aquí
            </Text>
            <Text size="sm" className="text-gray-800">
              {`</Text>`}
            </Text>
          </div>
        </section>
      </div>
    </div>
  );
}