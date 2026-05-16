// lib/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/home_provider.dart';
import '../providers/alertas_provider.dart';

import '../widgets/alertas_popup.dart';

import 'bottom_nav_bar.dart';
import 'nueva_orden_screen.dart';
import 'pedidos_pendientes_screen.dart';
import 'ventas_screen.dart';
import 'reportes_screen.dart';

import '../../business/services/backup_service.dart';

import '../../data/repositories/backup_repository.dart';

/// Pantalla principal de la aplicación.
/// 
/// Componente de tipo [StatelessWidget] que actúa como punto de entrada
/// a la interfaz principal después de la autenticación. Encamina la
/// construcción de la vista a la clase [HomeView].
class HomeScreen extends StatelessWidget {
  /// Constructor principal de la clase [HomeScreen].
  const HomeScreen({
    super.key,
  });

  /// Construye la jerarquía visual delegando la representación a [HomeView].
  /// 
  /// Este widget actúa como contenedor simple que devuelve la vista real
  /// implementada en [HomeView]. No mantiene estado propio.
  @override
  Widget build(
    BuildContext context,
  ) {
    return const HomeView();
  }
}

/// Vista interna que define la estructura visual de la pantalla principal.
/// 
/// Gestiona la disposición de los elementos del menú principal y establece
/// la conexión con el manejador de estado [HomeProvider] para delegar la lógica
/// de navegación cuando corresponde.
class HomeView extends StatelessWidget {
  /// Constructor principal de la clase [HomeView].
  const HomeView({
    super.key,
  });

  /// Construye la interfaz gráfica y los enlaces de navegación del menú.
  /// 
  /// - Obtiene instancias de proveedores mediante `Provider.of` para acceder
  ///   a la lógica de navegación y al estado de alertas.
  /// - Define la estructura `Scaffold` con `AppBar`, `body` y `bottomNavigationBar`.
  @override
  Widget build(
    BuildContext context,
  ) {
    // Enlace de estado: Obtiene la instancia actual del proveedor para operaciones de navegación.
    final provider =
        Provider.of<HomeProvider>(
      context,
    );

    // Enlace de estado: Proveedor que expone si hay alertas y el total de alertas.
    final alertasProvider =
        Provider.of<AlertasProvider>(
      context,
    );

    return Scaffold(
      // Estilo visual: Definición del color de fondo base de la superficie.
      backgroundColor:
          const Color(
        0xFFF3F8FD,
      ),

      appBar: AppBar(
        // Estilo visual: Configuración de la cabecera sin sombra y con color sólido.
        backgroundColor:
            Colors.transparent,

        elevation: 0,

        actions: [
          Padding(
            padding:
                const EdgeInsets.only(
              right: 14,
            ),

            // Contenedor que agrupa el icono de notificaciones y el badge de contador.
            child: Stack(
              clipBehavior:
                  Clip.none,

              children: [
                IconButton(
                  icon: const Icon(
                    Icons
                        .notifications_outlined,
                    size: 32,
                    color:
                        Color(
                      0xFF1452BD,
                    ),
                  ),

                  // Acción al pulsar el icono de notificaciones:
                  // abre un diálogo modal con el widget `AlertasPopup`.
                  onPressed: () {
                    // Inserción del enrutamiento hacia el módulo de notificaciones.
                    showDialog(
                      context: context,
                      barrierColor:
                          Colors.black45,
                      builder: (_) {
                        return const AlertasPopup();
                      },
                    );
                  },
                ),

                // Badge condicional: se muestra solo si el proveedor indica que hay alertas.
                if (alertasProvider
                    .hayAlertas)

                  Positioned(
                    right: 4,
                    top: 4,

                    // Badge circular con el número total de alertas.
                    child: Container(
                      padding:
                          const EdgeInsets
                              .all(5),

                      decoration:
                          const BoxDecoration(
                        color:
                            Colors.red,
                        shape:
                            BoxShape.circle,
                      ),

                      child: Text(
                        alertasProvider
                            .totalAlertas
                            .toString(),

                        // Estilo del texto del badge.
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize: 10,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      body: Padding(
        // Espaciado general del contenido principal.
        padding:
            const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 10,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          // Centralización vertical de los componentes del menú.
          children: [
            // Bloque de datos: Elemento textual de bienvenida estático.
            const SizedBox(
              height: 10,
            ),

            const Text(
              'Hola, Brenda',
              style: TextStyle(
                fontSize: 30,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(
                  0xFF1452BD,
                ),
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            const Text(
              'Selecciona una opcion',
              style: TextStyle(
                fontSize: 16,
                color:
                    Color(
                  0xFF666666,
                ),
              ),
            ),

            const SizedBox(
              height: 34,
            ),

            // Botón principal: Nueva Venta/Pedido.
            _HomeButton(
              label:
                  'Nueva Venta/Pedido',
              icon:
                  Icons.add_shopping_cart,
              backgroundColor:
                  const Color(
                0xFF1452BD,
              ),
              textColor:
                  Colors.white,
              iconColor:
                  Colors.white,

              // Navegación directa a la pantalla de agregar pedido.
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AgregarPedidoScreen(),
                  ),
                );
              },
            ),

            const SizedBox(
              height: 18,
            ),

            // Botón: Ver Pedidos (navegación a PedidosPendientesScreen).
            _HomeButton(
              label:
                  'Ver Pedidos',
              icon:
                  Icons.pending_actions,
              backgroundColor:
                  Colors.white,
              textColor:
                  const Color(
                0xFF333333,
              ),
              iconColor:
                  const Color(
                0xFF4A90E2,
              ),

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const PedidosPendientesScreen(),
                  ),
                );
              },
            ),

            const SizedBox(
              height: 18,
            ),

            // Botón: Ver Ventas (navegación a VentasScreen).
            _HomeButton(
              label:
                  'Ver Ventas',
              icon:
                  Icons.point_of_sale,
              backgroundColor:
                  Colors.white,
              textColor:
                  const Color(
                0xFF333333,
              ),
              iconColor:
                  const Color(
                0xFF34A853,
              ),

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const VentasScreen(),
                  ),
                );
              },
            ),

            const SizedBox(
              height: 18,
            ),

            // Botón: Inventario. La navegación se delega al proveedor [HomeProvider].
            _HomeButton(
              // Invocación de navegación gestionada mediante el proveedor de estado.
              label:
                  'Inventario',
              icon:
                  Icons.inventory_2_outlined,
              backgroundColor:
                  Colors.white,
              textColor:
                  const Color(
                0xFF333333,
              ),
              iconColor:
                  const Color(
                0xFFFF9800,
              ),

              // Uso del método del proveedor para manejar la navegación.
              onPressed: () {
                provider
                    .navigateToInventory(
                  context,
                );
              },
            ),

            const SizedBox(
              height: 18,
            ),

            // Botón: Generar Reportes (navegación a ReportesScreen).
            _HomeButton(
              label:
                  'Generar Reportes',
              icon:
                  Icons.bar_chart,
              backgroundColor:
                  Colors.white,
              textColor:
                  const Color(
                0xFF333333,
              ),
              iconColor:
                  const Color(
                0xFFE91E63,
              ),

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ReportesScreen(),
                  ),
                );
              },
            ),

            const Spacer(),

            Align(
              alignment:
                  Alignment.centerRight,

              // Botón para crear y compartir respaldo (backup).
              child:
                  SizedBox(
                height: 40,

                child:
                    ElevatedButton.icon(
                  onPressed:
                      () async {
                    // Creación del servicio de respaldo y ejecución de la operación.
                    final service =
                        BackupService(
                      backupRepository:
                          BackupRepository(),
                    );

                    // Llamada asíncrona que crea y comparte el backup.
                    final resultado =
                        await service
                            .crearYCompartirBackup();

                    // Verificación de que el contexto sigue montado antes de usarlo.
                    if (!context.mounted) {
                      return;
                    }

                    // Muestra un SnackBar con el mensaje devuelto por el servicio.
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          resultado.mensaje,
                        ),
                      ),
                    );
                  },

                  // Estilos del botón de respaldo.
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF1452BD,
                    ),
                    foregroundColor:
                        Colors.white,
                    elevation: 1,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),

                  icon:
                      const Icon(
                    Icons.save_alt,
                    size: 18,
                  ),

                  label:
                      const Text(
                    'Crear respaldo',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 14,
            ),
          ],
        ),
      ),

      // Barra de navegación inferior reutilizable.
      bottomNavigationBar:
          const BottomNavBar(),
    );
  }
}

/// Widget privado que representa un botón del menú principal.
/// 
/// Este componente encapsula la apariencia y comportamiento de los botones
/// del home (icono, texto, colores y acción). Se usa internamente en este archivo.
class _HomeButton extends StatelessWidget {

  /// Texto que se muestra en el botón.
  final String label;

  /// Icono que se muestra a la izquierda del texto.
  final IconData icon;

  /// Callback que se ejecuta al pulsar el botón.
  final VoidCallback
      onPressed;

  /// Color de fondo del botón.
  final Color
      backgroundColor;

  /// Color del texto del botón.
  final Color
      textColor;

  /// Color del icono del botón.
  final Color
      iconColor;

  /// Constructor que obliga a proporcionar todas las propiedades necesarias.
  const _HomeButton({

    required this.label,

    required this.icon,

    required this.onPressed,

    required this.backgroundColor,

    required this.textColor,

    required this.iconColor,
  });

  /// Construye el botón con estilo consistente.
  /// 
  /// - Usa `ElevatedButton.icon` para combinar icono y texto.
  /// - Aplica borde cuando el fondo es blanco para mantener contraste.
  @override
  Widget build(
    BuildContext context,
  ) {

    return SizedBox(

      width:
          double.infinity,

      height: 62,

      child:
          ElevatedButton.icon(

        onPressed:
            onPressed,

        style:
            ElevatedButton.styleFrom(

          backgroundColor:
              backgroundColor,

          foregroundColor:
              textColor,

          elevation: 1.5,

          padding:
              const EdgeInsets.symmetric(
            horizontal: 18,
          ),

          shape:
              RoundedRectangleBorder(

            borderRadius:
                BorderRadius.circular(
              16,
            ),

            // Regla visual: si el fondo es blanco, dibuja un borde gris claro.
            side:
                backgroundColor ==
                        Colors.white

                    ? const BorderSide(

                        color:
                            Color(
                          0xFFE5E5E5,
                        ),
                      )

                    : BorderSide.none,
          ),
        ),

        // Icono del botón con color configurable.
        icon:
            Icon(

          icon,

          size: 24,

          color:
              iconColor,
        ),

        // Etiqueta alineada a la izquierda para mantener consistencia visual.
        label:
            Align(

          alignment:
              Alignment.centerLeft,

          child: Text(

            label,

            style:
                TextStyle(

              fontSize: 17,

              fontWeight:
                  FontWeight.bold,

              color:
                  textColor,
            ),
          ),
        ),
      ),
    );
  }
}
