import 'package:flutter/material.dart';

class ProfilePlaceholder extends StatelessWidget {
  final double size; // tamaño del círculo (por defecto 80)
  final VoidCallback? onEditTap;

  const ProfilePlaceholder({super.key, this.size = 80, this.onEditTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Círculo naranja de fondo
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF7043), // naranja similar al de tu imagen
            ),
          ),

          // Avatar centrado (imagen por defecto)
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(size * 0.08), // margen interno pequeño
              child: ClipOval(
                child: Image.network(
                  'https://i.imgur.com/EXAMPLE_AVATAR_URL.png', // reemplaza con tu URL real
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        color: Colors.grey[600],
                        size: size * 0.6,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Badge naranja con ícono de lápiz (editar)
          if (onEditTap != null)
            Positioned(
              bottom: -6,
              right: -6,
              child: GestureDetector(
                onTap: onEditTap,
                child: Container(
                  width: size * 0.35,
                  height: size * 0.35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF7043),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: size * 0.18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
