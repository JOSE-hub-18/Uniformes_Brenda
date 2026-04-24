import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart'; // Ajusta la ruta si tienes la barra en otra carpeta
import 'exito_screen.dart'; // Ajusta la ruta según tus carpetas

class AdministrarPrendaScreen extends StatelessWidget {
  
  const AdministrarPrendaScreen({super.key});

  void _mostrarDialogoConfirmacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          // 1. Bordes suavizados (20px de curvatura)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), 
          ),
          elevation: 8, // Sombra sutil para profundidad moderna
          // 2. Reduce el ancho del diálogo aumentando el margen exterior
          insetPadding: const EdgeInsets.symmetric(horizontal: 40), 
          child: Padding(
            padding: const EdgeInsets.only(top: 32, bottom: 24, left: 24, right: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Se encoge para abrazar al contenido
              children: [
                // Icono decorativo para llamar la atención sin ser agresivo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5FAFF), // El azul claro de tu fondo
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.info_outline, color: Color(0xFF1452BD), size: 40),
                ),
                const SizedBox(height: 24),
                
                const Text(
                  '¿Guardar cambios?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
                
                const SizedBox(height: 12),
                
                const Text(
                  'Se actualizará la información de esta prenda en el sistema.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Color(0xFF666666), height: 1.4),
                ),
                
                const SizedBox(height: 32),
                
                // Fila de botones "Tipo Píldora"
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancelar', style: TextStyle(color: Color(0xFF666666), fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); 
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ExitoScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50), // Verde de éxito
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Sí, guardar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF), // Fondo claro de la app
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_left, color: Color(0xFF1452BD), size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Administrar Prenda',
          style: TextStyle(color: Color(0xFF1452BD), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Textos informativos estáticos (Listos para recibir variables después)
            const Text(
              'Nombre de la escuela: (Nombre)',
              style: TextStyle(fontSize: 16, color: Color(0xFF666666), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            const Text(
              'Tipo de prenda: (Tipo)',
              style: TextStyle(fontSize: 16, color: Color(0xFF666666), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            const Text(
              'Talla: (Talla)',
              style: TextStyle(fontSize: 16, color: Color(0xFF666666), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),

            // Campo de Precio Editable (Caja blanca con sombra suave)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                initialValue: '(Precio)', // Aquí irá la variable del precio
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixText: 'Precio: ',
                  prefixStyle: TextStyle(color: Color(0xFF999999), fontSize: 16),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                style: const TextStyle(fontSize: 16, color: Color(0xFF333333)),
              ),
            ),

            const SizedBox(height: 40),

            // Cantidad disponible
            const Text(
              'Cantidad disponible: (Cantidad)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            
            const SizedBox(height: 12),

            // Botón Administrar Cantidad
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Lógica futura para abrir modal o pantalla de entradas/salidas
                },
                child: const Text(
                  'Administrar Cantidad',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1452BD), // Azul principal
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Botón Guardar Cambios
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _mostrarDialogoConfirmacion(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // Verde
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Guardar Cambios',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botón Eliminar Prenda
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Lógica futura para eliminar
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828), // Rojo
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Eliminar Prenda',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}