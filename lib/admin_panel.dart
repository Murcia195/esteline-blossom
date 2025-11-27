import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

// Importar constantes de colores del main.dart
const Color primaryGold = Color(0xFFD4AF37);
const Color darkBg = Color(0xFF0A0A0A);
const Color cardBg = Color(0xFF1A1A1A);
const Color accentPink = Color(0xFFE91E63);
const Color darkPink = Color(0xFFC2185B);
const Color lightGray = Color(0xFFE0E0E0);
const Color mediumGray = Color(0xFF9E9E9E);

// Estados disponibles
const List<String> STATUS_OPTIONS = [
  'Pendiente',
  'Compra Realizada',
  'Compra Confirmada',
  'En Preparación',
  'Enviado',
  'Completada',
  'Cancelada',
];

// Emojis para cada estado
final Map<String, String> STATUS_EMOJIS = {
  'Pendiente': '⏳',
  'Compra Realizada': '✅',
  'Compra Confirmada': '✓',
  'En Preparación': '📦',
  'Enviado': '🚚',
  'Completada': '🎉',
  'Cancelada': '❌',
};

// Colores para cada estado
Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'pendiente':
      return Colors.orange;
    case 'compra realizada':
    case 'compra confirmada':
      return Colors.blue;
    case 'en preparación':
      return Colors.purple;
    case 'enviado':
      return Colors.cyan;
    case 'completada':
      return Colors.green;
    case 'cancelada':
      return Colors.red;
    default:
      return mediumGray;
  }
}

class AdminPanel extends StatefulWidget {
  final String currentUserEmail;
  final VoidCallback onStatusChanged;

  const AdminPanel({
    super.key,
    required this.currentUserEmail,
    required this.onStatusChanged,
  });

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  late final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pendingPurchases = [];
  bool isLoading = true;
  Timer? purchaseSubscription;

  @override
  void initState() {
    super.initState();
    _loadPendingPurchases();
    _subscribeToPurchaseChanges();
  }

  @override
  void dispose() {
    purchaseSubscription?.cancel();
    super.dispose();
  }

  // Cargar compras pendientes (solo al iniciar)
  Future<void> _loadPendingPurchases() async {
    try {
      final response = await supabase
          .from('purchases')
          .select()
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          pendingPurchases = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading purchases: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Suscribirse a cambios en tiempo real (polling)
  void _subscribeToPurchaseChanges() {
    // Usar polling cada 5 segundos PERO solo actualizar si hay cambios
    purchaseSubscription = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted && !isLoading) {
        _checkForUpdates();
      }
    });
  }

  // Verificar solo si hay cambios (evita flickering)
  Future<void> _checkForUpdates() async {
    try {
      final response = await supabase
          .from('purchases')
          .select()
          .order('created_at', ascending: false);

      final newPurchases = List<Map<String, dynamic>>.from(response);

      // Solo actualizar si los datos realmente cambiaron
      if (_hasChanges(pendingPurchases, newPurchases)) {
        setState(() {
          pendingPurchases = newPurchases;
        });
      }
    } catch (e) {
      debugPrint('Error checking updates: $e');
    }
  }

  // Verificar si hay cambios reales
  bool _hasChanges(
    List<Map<String, dynamic>> old,
    List<Map<String, dynamic>> new_,
  ) {
    if (old.length != new_.length) return true;

    for (int i = 0; i < old.length; i++) {
      if (old[i]['status'] != new_[i]['status'] ||
          old[i]['updated_at'] != new_[i]['updated_at']) {
        return true;
      }
    }
    return false;
  } // Actualizar estado de compra

  Future<void> _updatePurchaseStatus(
    String purchaseId,
    String newStatus,
  ) async {
    try {
      debugPrint('🔄 Iniciando actualización: $purchaseId -> $newStatus');

      final now = DateTime.now().toIso8601String();

      // Primero actualizar localmente para feedback inmediato
      if (mounted) {
        setState(() {
          final index = pendingPurchases.indexWhere(
            (p) => p['id'] == purchaseId,
          );
          if (index != -1) {
            pendingPurchases[index]['status'] = newStatus;
            pendingPurchases[index]['updated_at'] = now;
          }
        });
      }

      // Luego actualizar en Supabase - SIN .select()
      await supabase
          .from('purchases')
          .update({'status': newStatus, 'updated_at': now})
          .eq('id', purchaseId);

      debugPrint('✅ Compra actualizada en BD: $purchaseId -> $newStatus');
      debugPrint('Timestamp: $now');

      // Notificar cambios
      if (mounted) {
        widget.onStatusChanged();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Estado actualizado a: $newStatus'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Recargar datos después de un pequeño delay para asegurar sincronización
      await Future.delayed(const Duration(milliseconds: 500));
      _loadPendingPurchases();
    } catch (e) {
      debugPrint('❌ Error updating purchase: $e');

      // Revertir cambios locales si falla
      if (mounted) {
        _loadPendingPurchases();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Enviar notificación por WhatsApp
  Future<void> _sendWhatsAppNotification(
    Map<String, dynamic> purchase,
    String newStatus,
  ) async {
    try {
      final code = purchase['code'] ?? 'N/A';
      final emoji = STATUS_EMOJIS[newStatus] ?? '•';
      final total = purchase['total'] ?? 0;

      String message = '📱 *ACTUALIZACIÓN DE ESTADO*\n\n';
      message += '*Código de compra: $code*\n\n';
      message += '🔔 Tu compra ahora está: $emoji *$newStatus*\n\n';
      message += '💰 Total: \$$total\n\n';

      // Si hay comentario, agregarlo
      if (purchase['admin_comment'] != null &&
          purchase['admin_comment'].toString().isNotEmpty) {
        message += '💬 Comentario:\n${purchase['admin_comment']}\n\n';
      }

      message += '---\nGracias por tu compra 💄✨';

      // URL de WhatsApp (sin número de teléfono, el usuario lo agrega)
      final whatsappUrl = Uri.parse(
        'https://api.whatsapp.com/send?text=${Uri.encodeComponent(message)}',
      );

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error sending WhatsApp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Panel de Admin'),
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: primaryGold,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGold))
          : pendingPurchases.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.done_all, size: 64, color: mediumGray),
                  const SizedBox(height: 16),
                  const Text(
                    'Sin compras para actualizar',
                    style: TextStyle(
                      color: lightGray,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Todas las compras están al día',
                    style: TextStyle(color: mediumGray, fontSize: 12),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingPurchases.length,
              itemBuilder: (context, index) {
                final purchase = pendingPurchases[index];
                return _buildPurchaseCard(purchase);
              },
            ),
    );
  }

  // Construir tarjeta de compra editable
  Widget _buildPurchaseCard(Map<String, dynamic> purchase) {
    final code = purchase['code'] ?? 'N/A';
    final status = purchase['status'] ?? 'Pendiente';
    final total = purchase['total'] ?? 0;
    final createdAt = purchase['created_at'] != null
        ? DateTime.parse(purchase['created_at']).toLocal()
        : DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: getStatusColor(status).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Código: $code',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: primaryGold,
                    ),
                  ),
                  Text(
                    '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 11, color: mediumGray),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: getStatusColor(status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${STATUS_EMOJIS[status] ?? '•'} $status',
                  style: TextStyle(
                    fontSize: 11,
                    color: getStatusColor(status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Total
          Text(
            '💰 Total: \$$total',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: primaryGold,
            ),
          ),
          const SizedBox(height: 12),

          // Selector de estado
          Text(
            'Cambiar estado:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: lightGray,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: STATUS_OPTIONS.map((option) {
                final isSelected = status == option;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      _showCommentDialog(purchase['id'], option);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? getStatusColor(option)
                            : getStatusColor(option).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: getStatusColor(option),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        '${STATUS_EMOJIS[option] ?? '•'} $option',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : getStatusColor(option),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _sendWhatsAppNotification(purchase, status),
                  icon: const Icon(Icons.message),
                  label: const Text('📱 Notificar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _sendWhatsAppNotification(purchase, status),
                  icon: const Icon(Icons.share),
                  label: const Text('📤 Compartir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Dialog para cambiar el estado
  void _showCommentDialog(String purchaseId, String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Actualizar a: $newStatus'),
        titleTextStyle: const TextStyle(
          color: primaryGold,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        backgroundColor: cardBg,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: getStatusColor(newStatus).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${STATUS_EMOJIS[newStatus] ?? '•'} $newStatus',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: getStatusColor(newStatus),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Deseas confirmar este cambio de estado?',
              style: TextStyle(color: lightGray, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: mediumGray)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Mostrar indicador de carga
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⏳ Guardando...'),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 1),
                ),
              );

              await _updatePurchaseStatus(purchaseId, newStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGold,
              foregroundColor: darkBg,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
