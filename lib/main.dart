import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'dart:math';
import 'admin_panel.dart';
import 'premium_features.dart';

// Colores Premium - Definidos globalmente
const Color primaryGold = Color(0xFFD4AF37);
const Color darkBg = Color(0xFF0A0A0A);
const Color cardBg = Color(0xFF1A1A1A);
const Color accentPink = Color(0xFFE91E63);
const Color darkPink = Color(0xFFC2185B);
const Color lightGray = Color(0xFFE0E0E0);
const Color mediumGray = Color(0xFF9E9E9E);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jenjelfbnpkxeevgmfjs.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImplbmplbGZibnBreGVldmdtZmpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIwMzc0NzYsImV4cCI6MjA3NzYxMzQ3Nn0.RNyuDvvd_hr3kJUYzCetsvIC-VNhIZNdbdyPi5gsQ68',
  );

  // Inicializar notificaciones en tiempo real
  await RealtimeNotificationService.initializeNotifications();
  await RealtimeNotificationService.setupRealtimeListener();

  runApp(const TiendaMaquillajeApp());
}

// Comentarios automáticos bonitos - Solo comentarios sin nombres
final List<String> automaticComments = [
  '¡Producto de excelente calidad! Muy recomendado 💕',
  'Entrega rápida y producto perfecto! ✨',
  'Superó todas mis expectativas! Volveré a comprar 🎉',
  'El mejor servicio que he visto. Muy profesionales! 👏',
  'Me encanta! Calidad premium garantizada 💎',
  'Atención excelente y productos de lujo! ⭐',
  'Totalmente satisfecha con mi compra! Gracias 🌹',
  'Recomiendo ampliamente esta tienda! Top tier! 🏆',
];

// Función helper para obtener URL de imagen desde Supabase Storage
String getSupabaseImageUrl(String fileName) {
  if (fileName.isEmpty) return '';
  // URL base de Supabase Storage: https://PROJECT_ID.supabase.co/storage/v1/object/public/BUCKET/
  return 'https://jenjelfbnpkxeevgmfjs.supabase.co/storage/v1/object/public/productos/$fileName';
}

// Sistema de Notificaciones en Tiempo Real
class RealtimeNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static RealtimeChannel? _channel;

  static Future<void> initializeNotifications() async {
    const InitializationSettings initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String payload = '',
  }) async {
    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'esteline_channel',
        'Notificaciones Esteline',
        channelDescription: 'Notificaciones de cambios en productos',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(0, title, body, details, payload: payload);
  }

  static Future<void> setupRealtimeListener() async {
    try {
      final supabase = Supabase.instance.client;

      // Escuchar cambios en tiempo real en la tabla de productos
      _channel = supabase.channel('public:productos')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'productos',
          callback: (payload) {
            if (payload.eventType == PostgresChangeEvent.insert) {
              showNotification(
                title: '✨ Nuevo Producto',
                body: 'Un nuevo producto ha sido agregado a la tienda',
                payload: 'nuevo_producto',
              );
            } else if (payload.eventType == PostgresChangeEvent.update) {
              showNotification(
                title: '🔄 Producto Actualizado',
                body: 'Un producto ha sido actualizado con nuevos detalles',
                payload: 'producto_actualizado',
              );
            }
          },
        )
        ..subscribe();
    } catch (e) {
      print('Error configurando notificaciones: $e');
    }
  }

  static Future<void> dispose() async {
    await _channel?.unsubscribe();
  }
}

class TiendaMaquillajeApp extends StatefulWidget {
  const TiendaMaquillajeApp({super.key});

  @override
  State<TiendaMaquillajeApp> createState() => _TiendaMaquillajeAppState();
}

class _TiendaMaquillajeAppState extends State<TiendaMaquillajeApp> {
  late ThemeNotifier _themeNotifier;

  @override
  void initState() {
    super.initState();
    _themeNotifier = ThemeNotifier();
    _themeNotifier.initialize().then((_) {
      _themeNotifier.addListener(() {
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _themeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Esteline Blossom',
      debugShowCheckedModeBanner: false,
      theme: _themeNotifier.getTheme(),
      home: const LoginOrApp(),
    );
  }
}

class LoginOrApp extends StatefulWidget {
  const LoginOrApp({super.key});

  @override
  State<LoginOrApp> createState() => _LoginOrAppState();
}

class _LoginOrAppState extends State<LoginOrApp> {
  Map<String, dynamic>? currentUser;
  bool isLoading = false;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Inicializar SharedPreferences
    prefs = await SharedPreferences.getInstance();
    // Verificar si existe usuario guardado
    await _checkStoredUser();
  }

  Future<void> _checkStoredUser() async {
    try {
      // Obtener datos guardados
      final savedEmail = prefs.getString('user_email');
      final savedName = prefs.getString('user_name');
      final savedId = prefs.getString('user_id');

      if (savedEmail != null && savedName != null && savedId != null) {
        debugPrint('✅ Sesión recuperada: $savedEmail');

        setState(() {
          currentUser = {
            'id': savedId,
            'name': savedName,
            'email': savedEmail,
            'photo_url': null,
          };
        });
      }
    } catch (e) {
      debugPrint('Error al recuperar sesión: $e');
    }
  }

  Future<void> _loginWithEmail(String email, String name) async {
    try {
      setState(() => isLoading = true);

      final supabase = Supabase.instance.client;

      // Validar conexión a Supabase primero
      debugPrint('🔍 Conectando a Supabase...');

      try {
        // Intentar obtener o crear usuario
        final existingUser = await supabase
            .from('users')
            .select('id, email')
            .eq('email', email.toLowerCase());

        String userId;

        if (existingUser.isEmpty) {
          // Crear nuevo usuario (sin usar .select())
          debugPrint('📝 Insertando nuevo usuario: $email');
          await supabase.from('users').insert({
            'name': name,
            'email': email.toLowerCase(),
          });

          // Obtener el usuario que acabamos de crear
          final newUser = await supabase
              .from('users')
              .select('id')
              .eq('email', email.toLowerCase())
              .single();

          userId = newUser['id'];
          debugPrint('✅ Usuario registrado: $email con ID: $userId');
        } else {
          userId = existingUser[0]['id'];
          debugPrint('✅ Usuario existente: $email');
        }

        // Guardar sesión en SharedPreferences
        await prefs.setString('user_email', email.toLowerCase());
        await prefs.setString('user_name', name);
        await prefs.setString('user_id', userId);

        setState(() {
          currentUser = {
            'id': userId,
            'name': name,
            'email': email.toLowerCase(),
            'photo_url': null,
          };
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Bienvenido! Acceso concedido'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on PostgrestException catch (e) {
        debugPrint('❌ Error de base de datos: ${e.message}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error BD: ${e.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error al iniciar sesión: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _signOut() async {
    // Eliminar datos guardados
    await prefs.remove('user_email');
    await prefs.remove('user_name');

    setState(() => currentUser = null);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Sesión cerrada'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // En web, omitir login y ir directo a productos
    if (kIsWeb) {
      return ProductsPage(
        currentUser: {
          'email': 'web_user@esteline.com',
          'name': 'Web User',
          'id': 'web_user',
        },
        onSignOut: _signOut,
      );
    }

    if (currentUser == null) {
      return LoginScreen(isLoading: isLoading, onLogin: _loginWithEmail);
    } else {
      return ProductsPage(currentUser: currentUser!, onSignOut: _signOut);
    }
  }
}

// Pantalla de Login
class LoginScreen extends StatefulWidget {
  final bool isLoading;
  final Function(String email, String name) onLogin;

  const LoginScreen({
    super.key,
    required this.isLoading,
    required this.onLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();

    // Validación
    if (email.isEmpty || name.isEmpty) {
      setState(() => _errorMessage = 'Por favor llena todos los campos');
      return;
    }

    if (!email.contains('@')) {
      setState(() => _errorMessage = 'Email inválido');
      return;
    }

    setState(() => _errorMessage = '');
    widget.onLogin(email, name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo con animación mejorada
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeInOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.5 + (value * 0.5),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 120 + (value * 30),
                            height: 120 + (value * 30),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  primaryGold.withOpacity(
                                    (0.4 * value).clamp(0.0, 1.0),
                                  ),
                                  primaryGold.withOpacity(
                                    (0.1 * value).clamp(0.0, 1.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  primaryGold.withOpacity(0.9),
                                  accentPink.withOpacity(0.8),
                                ],
                              ),
                              border: Border.all(color: primaryGold, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryGold.withOpacity(0.6),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: accentPink.withOpacity(0.4),
                                  blurRadius: 15,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 3000),
                                  curve: Curves.linear,
                                  builder: (context, rotValue, child) {
                                    return Transform.rotate(
                                      angle: rotValue * 6.28,
                                      child: const Icon(
                                        Icons.favorite,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Título Principal
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [primaryGold, accentPink],
                  ).createShader(bounds),
                  child: const Text(
                    'ESTELINE BLOSSOM',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '✨ Premium Beauty ✨',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: accentPink,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Mensaje de Bienvenida Profesional con Animación
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                primaryGold.withOpacity(0.1),
                                accentPink.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryGold.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryGold.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [primaryGold, accentPink],
                                ).createShader(bounds),
                                child: const Text(
                                  '¡Bienvenida a la Experiencia Premium!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Accede a nuestra colección exclusiva de maquillaje de lujo. Productos cuidadosamente seleccionados para realzar tu belleza natural.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: mediumGray,
                                  height: 1.6,
                                  letterSpacing: 0.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              // Beneficios con iconos
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildBenefitItem('🎁', 'Ofertas'),
                                  _buildBenefitItem('⚡', 'Rápido'),
                                  _buildBenefitItem('💎', 'Premium'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Mensaje de error
                if (_errorMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                if (_errorMessage.isNotEmpty) const SizedBox(height: 16),

                // Campo Nombre con animación
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: TextField(
                          controller: _nameController,
                          enabled: !widget.isLoading,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Tu nombre',
                            labelStyle: TextStyle(color: mediumGray),
                            hintText: 'Ej: María López',
                            hintStyle: TextStyle(
                              color: mediumGray.withOpacity(0.5),
                            ),
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Colors.white70,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryGold,
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: accentPink,
                                width: 2,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: mediumGray,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Campo Email con animación
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: TextField(
                          controller: _emailController,
                          enabled: !widget.isLoading,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Tu email',
                            labelStyle: TextStyle(color: mediumGray),
                            hintText: 'ejemplo@gmail.com',
                            hintStyle: TextStyle(
                              color: mediumGray.withOpacity(0.5),
                            ),
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.white70,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryGold,
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: accentPink,
                                width: 2,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: mediumGray,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Botón Continuar con efecto
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1400),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: 0.8 + (value * 0.2),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: widget.isLoading ? null : _handleLogin,
                            icon: widget.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        darkBg,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.login),
                            label: Text(
                              widget.isLoading
                                  ? 'Iniciando sesión...'
                                  : 'Continuar',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGold,
                              foregroundColor: darkBg,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 8,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Tu privacidad es importante.\nSolo guardamos tu nombre y email para tus compras.',
                  style: TextStyle(
                    fontSize: 12,
                    color: mediumGray,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String icon, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: primaryGold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class ProductsPage extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final VoidCallback onSignOut;

  const ProductsPage({
    super.key,
    required this.currentUser,
    required this.onSignOut,
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with TickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> products = [];
  bool loading = true;
  String searchQuery = '';
  int cartCount = 0;
  int currentPage = 0;
  List<Map<String, dynamic>> cartItems = [];
  Set<String> favoriteIds = {};
  List<Map<String, dynamic>> purchaseHistory = [];
  late AnimationController _fabController;
  late AnimationController _cartSlideController;

  // Nuevas variables para filtros y ordenamiento
  String selectedCategory = 'Todos';
  String sortBy = 'nombre'; // nombre, precio_asc, precio_desc, mas_vendidos
  List<String> categories = [];

  // Variables de seguridad para el panel de administrador
  int adminLoginAttempts = 0;
  DateTime? lastFailedAttempt;
  bool isAdminLocked = false;
  List<Map<String, dynamic>> loginAttemptLog = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
    // Cargar compras del usuario al iniciar la página
    loadUserPurchases(widget.currentUser['id'] as String);
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cartSlideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    // Inicia la animación del carrito automáticamente
    _cartSlideController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _cartSlideController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await supabase.from('products').select();
      final productsList = List<Map<String, dynamic>>.from(response);

      // Extraer categorías únicas
      final uniqueCategories = <String>{'Todos'};
      for (final product in productsList) {
        final category = product['category'] as String?;
        if (category != null && category.isNotEmpty) {
          uniqueCategories.add(category);
        }
      }

      setState(() {
        products = productsList;
        categories = uniqueCategories.toList()..sort();
        loading = false;
      });
    } catch (e) {
      debugPrint('Error al obtener productos: $e');
      setState(() => loading = false);
    }
  }

  // Función para obtener productos filtrados y ordenados
  List<Map<String, dynamic>> getFilteredAndSortedProducts() {
    var filtered = products;

    // Filtrar por categoría
    if (selectedCategory != 'Todos') {
      filtered = filtered
          .where((p) => p['category'] == selectedCategory)
          .toList();
    }

    // Filtrar por búsqueda
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (p) =>
                (p['name'] as String).toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                (p['description'] as String).toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    // Ordenar
    switch (sortBy) {
      case 'precio_asc':
        filtered.sort(
          (a, b) => (a['price'] as num).compareTo(b['price'] as num),
        );
        break;
      case 'precio_desc':
        filtered.sort(
          (a, b) => (b['price'] as num).compareTo(a['price'] as num),
        );
        break;
      case 'mas_vendidos':
        // Ordenar por stock (menos stock = más vendido)
        filtered.sort(
          (a, b) => (a['stock'] as num).compareTo(b['stock'] as num),
        );
        break;
      default: // nombre
        filtered.sort(
          (a, b) => (a['name'] as String).compareTo(b['name'] as String),
        );
    }

    return filtered;
  }

  Future<void> loadUserPurchases(String userId) async {
    try {
      // Cargar todas las compras del usuario
      final purchasesResponse = await supabase
          .from('purchases')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // Para cada compra, cargar sus items
      final purchases = <Map<String, dynamic>>[];
      for (final purchase in purchasesResponse) {
        final purchaseId = purchase['id'];

        // Cargar items de esta compra
        final itemsResponse = await supabase
            .from('purchase_items')
            .select()
            .eq('purchase_id', purchaseId);

        purchases.add({
          'id': purchaseId,
          'total_amount': (purchase['total_amount'] as num?)?.toDouble() ?? 0.0,
          'status': purchase['status'] ?? 'Pendiente',
          'payment_method': purchase['payment_method'] ?? 'Transferencia',
          'shipping_address': purchase['shipping_address'] ?? 'Por definir',
          'date': DateTime.parse(
            purchase['created_at'] ?? DateTime.now().toIso8601String(),
          ),
          'items': List<Map<String, dynamic>>.from(itemsResponse),
        });
      }

      setState(() {
        purchaseHistory = purchases;
      });

      debugPrint('✅ Compras cargadas: ${purchaseHistory.length} compra(s)');
    } catch (e) {
      debugPrint('⚠️ Error al cargar compras: $e');
    }
  }

  void openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void sendWhatsAppMessage(String message, String purchaseCode) async {
    final String encodedMessage = Uri.encodeComponent(message);
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/31519371?text=$encodedMessage',
    );
    if (await canLaunchUrl(whatsappUri)) {
      // Guardar en Supabase
      await savePurchaseToSupabase(purchaseCode);

      // Limpiar carrito
      setState(() {
        cartItems.clear();
        cartCount = 0;
      });

      // Recargar compras del usuario desde Supabase
      await loadUserPurchases(widget.currentUser['id'] as String);

      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  String generatePurchaseCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomPart = (DateTime.now().microsecond % 1000).toString().padLeft(
      3,
      '0',
    );
    return 'COMP-${timestamp.substring(timestamp.length - 4)}$randomPart';
  }

  Future<void> savePurchaseToSupabase(String purchaseCode) async {
    try {
      // Calcular total
      final totalAmount = cartItems.fold<double>(
        0,
        (sum, item) => sum + (item['price'] as num? ?? 0).toDouble(),
      );

      // 1. Insertar en tabla purchases
      final purchaseResponse = await supabase.from('purchases').insert({
        'user_id': widget.currentUser['id'],
        'total_amount': totalAmount,
        'status': 'Pendiente',
        'payment_method': 'Transferencia',
        'shipping_address': widget.currentUser['address'] ?? 'Por definir',
      }).select();

      if (purchaseResponse.isEmpty) {
        throw Exception('No se pudo crear la compra');
      }

      final purchaseId = purchaseResponse[0]['id'];

      // 2. Insertar cada item en purchase_items
      for (final item in cartItems) {
        await supabase.from('purchase_items').insert({
          'purchase_id': purchaseId,
          'product_id': item['id'],
          'quantity': item['quantity'] ?? 1,
          'unit_price': item['price'],
        });
      }

      debugPrint(
        '✅ Compra guardada en Supabase: $purchaseCode (ID: $purchaseId, Usuario: ${widget.currentUser['email']})',
      );
    } catch (e) {
      debugPrint('⚠️ Error guardando en Supabase: $e');
    }
  }

  Future<void> checkPurchaseUpdates() async {
    try {
      // Recargar compras del usuario actual desde Supabase
      if (widget.currentUser.isNotEmpty) {
        await loadUserPurchases(widget.currentUser['id'] as String);
      }
    } catch (e) {
      debugPrint('Error verificando actualizaciones: $e');
    }
  }

  String generateCartMessage(
    String purchaseCode, {
    String clientName = 'Cliente',
  }) {
    if (cartItems.isEmpty) {
      return 'Hola, quisiera hacer una consulta sobre sus productos.';
    }

    String message = '🛍️ *NUEVA ORDEN DE COMPRA*\n';
    message += '*CÓDIGO: $purchaseCode*\n';
    message += '*CLIENTE: $clientName*\n\n';
    message += 'Hola, me interesa comprar los siguientes productos:\n\n';

    for (int i = 0; i < cartItems.length; i++) {
      final item = cartItems[i];
      final name = item['name'] ?? 'Producto sin nombre';
      final price = item['price'] ?? 0;
      message += '${i + 1}. ${name}\n   💰 Precio: L ${price}\n\n';
    }

    final total = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item['price'] as num? ?? 0).toDouble(),
    );
    message += '═══════════════════════════════════\n';
    message += '💰 *TOTAL: L ${total.toStringAsFixed(2)}*\n\n';
    message += 'Por favor, confirma disponibilidad y detalles de envío.\n\n';
    message += '⏳ *Responde con: CONFIRMAR $purchaseCode*\n';
    message += '(para marcar tu compra como confirmada en la app)';

    return message;
  }

  // Obtener color según el estado de la compra
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendiente':
      case 'pending':
        return Colors.orange;
      case 'compra realizada':
      case 'compra confirmada':
      case 'confirmed':
        return Colors.blue;
      case 'en preparación':
      case 'preparing':
        return Colors.purple;
      case 'enviado':
      case 'shipped':
        return Colors.cyan;
      case 'completada':
      case 'completed':
        return Colors.green;
      case 'cancelada':
      case 'cancelled':
        return Colors.red;
      default:
        return mediumGray;
    }
  }

  // Obtener emoji según el estado
  String _getStatusEmoji(String status) {
    switch (status.toLowerCase()) {
      case 'pendiente':
      case 'pending':
        return '⏳';
      case 'compra realizada':
      case 'compra confirmada':
      case 'confirmed':
        return '✅';
      case 'en preparación':
      case 'preparing':
        return '📦';
      case 'enviado':
      case 'shipped':
        return '🚚';
      case 'completada':
      case 'completed':
        return '🎉';
      case 'cancelada':
      case 'cancelled':
        return '❌';
      default:
        return '•';
    }
  }

  List<Map<String, dynamic>> get filteredProducts {
    return getFilteredAndSortedProducts();
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      cartItems.add(product);
      cartCount++;
    });

    // Animar FAB
    _fabController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _fabController.reverse();
      });
    });

    // Repetir animación del carrito cada vez que se añade un producto
    _cartSlideController.reset();
    _cartSlideController.forward();

    // Mostrar modal bonito de success
    _showAddToCartAnimation(context, product);
  }

  void _showAddToCartAnimation(
    BuildContext context,
    Map<String, dynamic> product,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [cardBg, cardBg.withOpacity(0.95)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: primaryGold, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: primaryGold.withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header con animación
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryGold.withOpacity(0.15),
                                accentPink.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 800),
                                builder: (context, animValue, child) {
                                  return Transform.rotate(
                                    angle: animValue * 6.28,
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: primaryGold.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: primaryGold,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.check_circle,
                                        color: primaryGold,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                '¡AGREGADO CON ÉXITO!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: primaryGold,
                                  letterSpacing: 1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                product['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: lightGray,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Comentarios
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Clientes felices 💬',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: mediumGray,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...(automaticComments..shuffle())
                                  .take(2)
                                  .map(
                                    (comment) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: primaryGold.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: primaryGold.withOpacity(0.2),
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                comment,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: mediumGray,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Row(
                                              children: List.generate(
                                                5,
                                                (i) => const Padding(
                                                  padding: EdgeInsets.only(
                                                    right: 1,
                                                  ),
                                                  child: Icon(
                                                    Icons.star,
                                                    size: 10,
                                                    color: primaryGold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                        // Botones
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            children: [
                              // Botón de Favoritos
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentPink.withOpacity(
                                      0.2,
                                    ),
                                    foregroundColor: accentPink,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(
                                        color: accentPink,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    final productId =
                                        product['id']?.toString() ?? '';
                                    if (productId.isNotEmpty &&
                                        !favoriteIds.contains(productId)) {
                                      setState(
                                        () => favoriteIds.add(productId),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            '¡Agregado a favoritos! ❤️',
                                          ),
                                          duration: Duration(milliseconds: 800),
                                          backgroundColor: accentPink,
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.favorite_outline,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Agregar a Favoritos',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Botón Continuar Comprando
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryGold,
                                    foregroundColor: darkBg,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Continuar comprando',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar diferentes páginas según currentPage (solo 4 botones abajo)
    if (currentPage == 1) {
      return _buildFavoritesPage();
    } else if (currentPage == 2) {
      // Recargar compras cuando se abre la página de Compras
      Future.microtask(() {
        loadUserPurchases(widget.currentUser['id'] as String);
      });
      return _buildCartPage();
    } else if (currentPage == 3) {
      return _buildInfoPage();
    }

    // Por defecto mostrar la página de productos (currentPage == 0)
    return _buildProductsPage();
  }

  Widget _buildFavoritesPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos ❤️'),
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: primaryGold,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: favoriteIds.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_outline, size: 64, color: mediumGray),
                  const SizedBox(height: 16),
                  Text(
                    'Sin favoritos aún',
                    style: TextStyle(color: mediumGray, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega productos a favoritos desde la tienda',
                    style: TextStyle(
                      color: mediumGray.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: products
                  .where((p) => favoriteIds.contains(p['id']?.toString()))
                  .length,
              itemBuilder: (context, index) {
                final product = products
                    .where((p) => favoriteIds.contains(p['id']?.toString()))
                    .toList()[index];
                final productId = product['id']?.toString() ?? '';
                return ProductCard(
                  product: product,
                  onAddToCart: () => _addToCart(product),
                  onOpenUrl: openUrl,
                  onFavoriteToggle: (id, isFav) {
                    setState(() {
                      if (isFav) {
                        favoriteIds.add(id);
                      } else {
                        favoriteIds.remove(id);
                      }
                    });
                  },
                  isFav: favoriteIds.contains(productId),
                );
              },
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCartPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Compras 📦'),
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: primaryGold,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: cartItems.isEmpty && purchaseHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_shipping, size: 64, color: mediumGray),
                  const SizedBox(height: 16),
                  const Text(
                    'Sin compras aún',
                    style: TextStyle(
                      color: lightGray,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tus compras aparecerán aquí una vez las envíes',
                    style: TextStyle(color: mediumGray, fontSize: 12),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Sección del carrito actual
                if (cartItems.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accentPink, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '🛒 Mi Carrito Actual',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: accentPink,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: accentPink.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${cartItems.length} items',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: accentPink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...cartItems.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: idx < cartItems.length - 1 ? 10 : 0,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: darkBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'] ?? 'Producto',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: lightGray,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Qty: ${item['quantity'] ?? 1}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: mediumGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'L ${(item['price'] as num?)?.toStringAsFixed(2) ?? '0'}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: primaryGold,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: accentPink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Carrito:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: lightGray,
                                ),
                              ),
                              Text(
                                'L ${cartItems.fold<double>(0, (sum, item) => sum + (item['price'] as num? ?? 0).toDouble()).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: accentPink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (purchaseHistory.isNotEmpty)
                    Text(
                      'Historial de Compras',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: primaryGold,
                      ),
                    ),
                  if (purchaseHistory.isNotEmpty) const SizedBox(height: 12),
                ],
                // Historial de compras
                if (purchaseHistory.isNotEmpty)
                  ...purchaseHistory.reversed.map((purchase) {
                    final items =
                        purchase['items'] as List<Map<String, dynamic>>;
                    final total = purchase['total_amount'] as double;
                    final date = purchase['date'] as DateTime;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: primaryGold.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Compra: ${purchase['id'].toString().substring(0, 8).toUpperCase()}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: primaryGold,
                                      ),
                                    ),
                                    Text(
                                      '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: mediumGray,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      purchase['status'] ?? 'Pendiente',
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _getStatusColor(
                                        purchase['status'] ?? 'Pendiente',
                                      ),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    _getStatusEmoji(
                                          purchase['status'] ?? 'Pendiente',
                                        ) +
                                        ' ${purchase['status'] ?? 'Pendiente'}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _getStatusColor(
                                        purchase['status'] ?? 'Pendiente',
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (purchase['payment_method'] != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Text('💳 ', style: TextStyle(fontSize: 12)),
                                    Expanded(
                                      child: Text(
                                        'Pago: ${purchase['payment_method']}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: mediumGray,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (purchase['shipping_address'] != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Text('📍 ', style: TextStyle(fontSize: 12)),
                                    Expanded(
                                      child: Text(
                                        'Entrega: ${purchase['shipping_address']}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: mediumGray,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: darkBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Productos (${items.length})',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: lightGray,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...items.asMap().entries.map((entry) {
                                    final idx = entry.key;
                                    final item = entry.value;
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: idx < items.length - 1 ? 8 : 0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${idx + 1}. Producto ID: ${item['product_id']}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: mediumGray,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  'Cantidad: ${item['quantity']}',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: lightGray,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            'L ${(item['unit_price'] as num?)?.toStringAsFixed(2) ?? '0'}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: primaryGold,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Pagado:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: mediumGray,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'L ${total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: primaryGold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Función 2 (duplicada y corrupta - eliminada)

  Widget _buildInfoPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información 📱'),
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: primaryGold,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryGold.withOpacity(0.2),
                    accentPink.withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryGold, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: primaryGold.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [primaryGold, accentPink],
                    ).createShader(bounds),
                    child: const Text(
                      'ESTELINE BLOSSOM',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '✨ Tu tienda premium de maquillaje y productos de belleza',
                    style: TextStyle(
                      fontSize: 14,
                      color: mediumGray,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: primaryGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primaryGold, width: 0.5),
                    ),
                    child: const Text(
                      '⭐ Calidad Premium • Envios Rápidos • Mejor Precio',
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryGold,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Contacto
            _buildInfoCard(
              icon: Icons.phone_enabled,
              title: 'Contáctanos por WhatsApp',
              description: 'Responde rápido a tus dudas y consultas',
              onTap: () => openUrl('https://wa.me/31519371'),
              phoneNumber: '+57 315-193-71',
              actionText: 'Abrir WhatsApp',
            ),
            const SizedBox(height: 16),

            // Instagram
            _buildInfoCard(
              icon: Icons.camera_alt,
              title: 'Síguenos en Instagram',
              description: 'Mira nuestras últimas colecciones y tendencias',
              onTap: () =>
                  openUrl('https://www.instagram.com/esteline_blossom'),
              phoneNumber: '@esteline_blossom',
              actionText: 'Ir a Instagram',
            ),
            const SizedBox(height: 28),

            // Sobre Nosotros Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primaryGold.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: primaryGold, size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Sobre Nosotros',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: lightGray,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Somos una tienda especializada en productos de maquillaje y belleza de la más alta calidad. Nuestro compromiso es ofrecerte los mejores productos al mejor precio con envios rápidos a todo el país.\n\nCada producto en nuestra tienda es seleccionado cuidadosamente para garantizar tu satisfacción.',
                    style: TextStyle(
                      fontSize: 13,
                      color: mediumGray,
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Valores Section
            const Text(
              'Nuestros Valores',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: lightGray,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildValueCard(
                    icon: Icons.favorite,
                    title: 'Calidad',
                    description: 'Productos premium seleccionados',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildValueCard(
                    icon: Icons.flash_on,
                    title: 'Rapidez',
                    description: 'Envios rápidos y seguro',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildValueCard(
                    icon: Icons.attach_money,
                    title: 'Precio',
                    description: 'Los mejores precios del mercado',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildValueCard(
                    icon: Icons.headset_mic,
                    title: 'Soporte',
                    description: 'Atención al cliente disponible',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Créditos Profesionales
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryGold.withOpacity(0.15),
                    accentPink.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primaryGold.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryGold.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.code, color: primaryGold, size: 20),
                      const SizedBox(width: 10),
                      const Text(
                        'Desarrollo Profesional',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: lightGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Developer 1
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: darkBg.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: primaryGold.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [primaryGold, accentPink],
                          ).createShader(bounds),
                          child: const Text(
                            'Manuel Murcia',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.email, color: primaryGold, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'manuelmurcia071@gmail.com',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: mediumGray,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Developer 2
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: darkBg.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: primaryGold.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [accentPink, primaryGold],
                          ).createShader(bounds),
                          child: const Text(
                            'Estefany Rodriguez',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.email, color: accentPink, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'gigiss2106@gmail.com',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: mediumGray,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: darkBg,
                border: Border.all(
                  color: primaryGold.withOpacity(0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      '© 2025 ESTELINE BLOSSOM',
                      style: TextStyle(
                        fontSize: 12,
                        color: mediumGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Todos los derechos reservados',
                      style: TextStyle(
                        fontSize: 11,
                        color: mediumGray.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required String phoneNumber,
    required String actionText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryGold.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: primaryGold, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: lightGray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(fontSize: 11, color: mediumGray),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              phoneNumber,
              style: const TextStyle(
                fontSize: 12,
                color: primaryGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 16),
              label: Text(actionText),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                foregroundColor: darkBg,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryGold.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryGold, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: lightGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 10, color: mediumGray, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCart() {
    // No mostrar carrito cuando estamos en la página de Compras
    if (cartItems.isEmpty || currentPage == 2) {
      return const SizedBox.shrink();
    }

    // Crear animación de deslizamiento
    final slideAnimation =
        Tween<Offset>(begin: const Offset(1.5, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _cartSlideController,
            curve: Curves.elasticOut,
          ),
        );

    // Crear animación de fade
    final fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cartSlideController, curve: Curves.easeIn),
    );

    final totalPrice = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item['price'] as num? ?? 0).toDouble(),
    );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Positioned(
          bottom: 100,
          right: 16,
          child: GestureDetector(
            onTap: () => _showCartModal(context),
            child: Container(
              width: 280,
              constraints: const BoxConstraints(maxHeight: 320),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentPink, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: accentPink.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Encabezado
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentPink, accentPink.withOpacity(0.8)],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '🛒 Mi Carrito',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${cartItems.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Lista de items
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: cartItems.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: darkBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] ?? 'Producto',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: lightGray,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Qty: ${item['quantity'] ?? 1}',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: mediumGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'L ${(item['price'] as num?)?.toStringAsFixed(2) ?? '0'}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: primaryGold,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Total
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: accentPink.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                      border: Border(
                        top: BorderSide(color: accentPink.withOpacity(0.3)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 11,
                            color: lightGray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'L ${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: accentPink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCartModal(BuildContext context) {
    final totalPrice = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item['price'] as num? ?? 0).toDouble(),
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600, maxWidth: 450),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentPink, width: 2),
            boxShadow: [
              BoxShadow(
                color: accentPink.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            children: [
              // Encabezado
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentPink, accentPink.withOpacity(0.8)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🛒 Mi Carrito Completo',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Lista de items con opción de eliminar
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: darkBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryGold.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] ?? 'Producto',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: lightGray,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Cantidad: ${item['quantity'] ?? 1}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: mediumGray,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'L ${(item['price'] as num?)?.toStringAsFixed(2) ?? '0'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: primaryGold,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                cartItems.removeAt(index);
                                cartCount--;
                              });
                              if (cartItems.isEmpty) {
                                Navigator.pop(context);
                              }
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Total y botones
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: primaryGold.withOpacity(0.2)),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 14,
                            color: lightGray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'L ${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: accentPink,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Botón WhatsApp
                    GestureDetector(
                      onTap: () {
                        final purchaseCode =
                            'CART-${DateTime.now().millisecondsSinceEpoch}';
                        final clientName =
                            widget.currentUser['name'] ?? 'Cliente';
                        final message = generateCartMessage(
                          purchaseCode,
                          clientName: clientName,
                        );
                        sendWhatsAppMessage(message, purchaseCode);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green[600]!, Colors.green[700]!],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.message,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Enviar por WhatsApp',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        border: const Border(top: BorderSide(color: primaryGold, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: primaryGold.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomAppBar(
        color: darkBg,
        elevation: 0,
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavButton(
              icon: Icons.home,
              label: 'Inicio',
              isActive: currentPage == 0,
              onTap: () => setState(() => currentPage = 0),
            ),
            _buildNavButton(
              icon: Icons.favorite_outline,
              label: 'Favoritos',
              isActive: currentPage == 1,
              onTap: () => setState(() => currentPage = 1),
            ),
            _buildNavButton(
              icon: Icons.shopping_bag,
              label: 'Compras',
              isActive: currentPage == 2,
              onTap: () => setState(() => currentPage = 2),
            ),
            _buildNavButton(
              icon: Icons.info_outline,
              label: 'Info',
              isActive: currentPage == 3,
              onTap: () => setState(() => currentPage = 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsPage() {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium Header
          SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            backgroundColor: darkBg,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(0),
              child: Center(
                child: ClipOval(
                  child: Image.asset(
                    'imagenes/LogoEsteline.jpg',
                    width: 220,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showAdminLoginDialog(),
                      child: Tooltip(
                        message: 'Acceso Administrador',
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: primaryGold, width: 1.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.admin_panel_settings,
                                color: primaryGold,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Admin',
                                style: TextStyle(
                                  color: primaryGold,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserProfilePage(),
                          ),
                        );
                      },
                      child: Tooltip(
                        message: 'Mi Perfil',
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryGold, width: 1.5),
                            color: cardBg,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person_outline,
                              color: primaryGold,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [darkBg, darkBg.withOpacity(0.7)],
                  ),
                  border: const Border(
                    bottom: BorderSide(color: primaryGold, width: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryGold.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Contenido principal del banner
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo con efectos de maquillaje
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 1500),
                              curve: Curves.easeInOutBack,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: 0.8 + (value * 0.2),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Aura dorada pulsante
                                      Container(
                                        width: 100 + (value * 20),
                                        height: 100 + (value * 20),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              primaryGold.withOpacity(
                                                (0.4 * value).clamp(0.0, 1.0),
                                              ),
                                              primaryGold.withOpacity(
                                                (0.1 * value).clamp(0.0, 1.0),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Logo interior con gradiente
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              primaryGold.withOpacity(0.9),
                                              accentPink.withOpacity(0.8),
                                            ],
                                          ),
                                          border: Border.all(
                                            color: primaryGold,
                                            width: 2.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryGold.withOpacity(
                                                0.6,
                                              ),
                                              blurRadius: 20,
                                              spreadRadius: 2,
                                            ),
                                            BoxShadow(
                                              color: accentPink.withOpacity(
                                                0.4,
                                              ),
                                              blurRadius: 15,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            TweenAnimationBuilder<double>(
                                              tween: Tween(begin: 0, end: 1),
                                              duration: const Duration(
                                                milliseconds: 3500,
                                              ),
                                              curve: Curves.linear,
                                              builder:
                                                  (context, rotValue, child) {
                                                    return Transform.translate(
                                                      offset: Offset(
                                                        sin(rotValue * 6.28) *
                                                            8,
                                                        cos(
                                                              rotValue * 6.28 +
                                                                  1,
                                                            ) *
                                                            10,
                                                      ),
                                                      child: Transform.rotate(
                                                        angle: rotValue * 6.28,
                                                        child: const Icon(
                                                          Icons.favorite,
                                                          color: Colors.white,
                                                          size: 38,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                            ),
                                            // Brillo decorativo
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.white,
                                                      blurRadius: 6,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 24),
                            // Texto del título
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [primaryGold, accentPink],
                                    ).createShader(bounds),
                                    child: const Text(
                                      'ESTELINE',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 2.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'BLOSSOM',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                      color: primaryGold,
                                      letterSpacing: 3,
                                      shadows: [
                                        Shadow(
                                          color: primaryGold.withOpacity(0.3),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '✨ Premium Beauty ✨',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: accentPink,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sección de saludo
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'ESTELINE BLOSSOM',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Hola, ${widget.currentUser['name']}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: primaryGold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (cartCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accentPink,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$cartCount',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert, color: primaryGold),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            onTap: widget.onSignOut,
                            child: const Row(
                              children: [
                                Icon(Icons.logout, color: accentPink),
                                SizedBox(width: 8),
                                Text('Cerrar sesión'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Buscar productos...',
                      hintStyle: TextStyle(color: mediumGray, fontSize: 14),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: primaryGold,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: cardBg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: primaryGold,
                          width: 1.5,
                        ),
                      ),
                    ),
                    style: const TextStyle(color: lightGray, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  // Filtros de Categoría
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...categories.map((cat) {
                          final isSelected = selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(cat),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() => selectedCategory = cat);
                              },
                              backgroundColor: cardBg,
                              selectedColor: primaryGold.withOpacity(0.3),
                              labelStyle: TextStyle(
                                color: isSelected ? primaryGold : mediumGray,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? primaryGold
                                    : mediumGray.withOpacity(0.3),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Ordenamiento
                  Row(
                    children: [
                      Icon(Icons.sort, color: primaryGold, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: sortBy,
                          isDense: true,
                          dropdownColor: cardBg,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => sortBy = value);
                            }
                          },
                          items: [
                            DropdownMenuItem(
                              value: 'nombre',
                              child: Text(
                                'Ordenar por: Nombre',
                                style: TextStyle(color: lightGray),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'precio_asc',
                              child: Text(
                                'Ordenar por: Precio (menor)',
                                style: TextStyle(color: lightGray),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'precio_desc',
                              child: Text(
                                'Ordenar por: Precio (mayor)',
                                style: TextStyle(color: lightGray),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'mas_vendidos',
                              child: Text(
                                'Ordenar por: Más vendidos',
                                style: TextStyle(color: lightGray),
                              ),
                            ),
                          ],
                          style: const TextStyle(
                            color: primaryGold,
                            fontSize: 12,
                          ),
                          underline: Container(
                            height: 1,
                            color: primaryGold.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (searchQuery.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${filteredProducts.length} resultados encontrados',
                          style: TextStyle(color: mediumGray, fontSize: 12),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => searchQuery = ''),
                          child: const Text(
                            'Limpiar',
                            style: TextStyle(
                              color: primaryGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Content
          if (loading)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1500),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: 0.8 + (value * 0.2),
                            child: const CircularProgressIndicator(
                              color: Color.fromARGB(255, 207, 173, 61),
                              strokeWidth: 3,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando colección premium...',
                      style: TextStyle(
                        color: mediumGray,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredProducts.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryGold.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 48,
                        color: primaryGold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      searchQuery.isEmpty
                          ? 'No hay productos disponibles'
                          : 'No se encontraron resultados',
                      style: const TextStyle(
                        fontSize: 16,
                        color: lightGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      searchQuery.isEmpty
                          ? 'Vuelve pronto'
                          : 'Intenta con otros términos',
                      style: TextStyle(fontSize: 12, color: mediumGray),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = filteredProducts[index];
                  final productId = product['id']?.toString() ?? '';
                  return ProductCard(
                    product: product,
                    onAddToCart: () => _addToCart(product),
                    onOpenUrl: openUrl,
                    onFavoriteToggle: (id, isFav) {
                      setState(() {
                        if (isFav) {
                          favoriteIds.add(id);
                        } else {
                          favoriteIds.remove(id);
                        }
                      });
                    },
                    isFav: favoriteIds.contains(productId),
                  );
                }, childCount: filteredProducts.length),
              ),
            ),
        ],
      ),

      // Chat Flotante - Profesional
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Carrito animado
          _buildAnimatedCart(),
          // Botón de reseñas
          Container(
            margin: const EdgeInsets.only(bottom: 80, right: 16),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: primaryGold.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductReviewsPage(),
                  ),
                );
              },
              backgroundColor: primaryGold,
              elevation: 8,
              child: const Icon(Icons.star, color: Colors.black, size: 24),
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: const Border(top: BorderSide(color: primaryGold, width: 0.5)),
          boxShadow: [
            BoxShadow(
              color: primaryGold.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomAppBar(
          color: darkBg,
          elevation: 0,
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavButton(
                icon: Icons.home,
                label: 'Inicio',
                isActive: currentPage == 0,
                onTap: () => setState(() => currentPage = 0),
              ),
              _buildNavButton(
                icon: Icons.favorite_outline,
                label: 'Favoritos',
                isActive: currentPage == 1,
                onTap: () => setState(() => currentPage = 1),
              ),
              _buildNavButton(
                icon: Icons.shopping_bag,
                label: 'Compras',
                isActive: currentPage == 2,
                onTap: () => setState(() => currentPage = 2),
              ),
              _buildNavButton(
                icon: Icons.info_outline,
                label: 'Info',
                isActive: currentPage == 3,
                onTap: () => setState(() => currentPage = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isActive ? primaryGold : mediumGray, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? primaryGold : mediumGray,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dialog de login para Admin
  void _showAdminLoginDialog() {
    // Verificar si está bloqueado por rate limiting
    if (isAdminLocked) {
      final now = DateTime.now();
      final lockDuration = const Duration(minutes: 15);
      final timeSinceLastAttempt = now.difference(lastFailedAttempt ?? now);

      if (timeSinceLastAttempt < lockDuration) {
        final remainingSeconds =
            lockDuration.inSeconds - timeSinceLastAttempt.inSeconds;
        final minutes = remainingSeconds ~/ 60;
        final seconds = remainingSeconds % 60;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🔒 Cuenta bloqueada. Intenta en ${minutes}m ${seconds}s',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      } else {
        // Desbloquear después de 15 minutos
        isAdminLocked = false;
        adminLoginAttempts = 0;
      }
    }

    final adminPasswordController = TextEditingController();
    final adminEmailController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🔐 Acceso Administrador'),
        titleTextStyle: const TextStyle(
          color: primaryGold,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: cardBg,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa tus credenciales de administrador',
              style: TextStyle(color: lightGray, fontSize: 12),
            ),
            const SizedBox(height: 8),
            if (adminLoginAttempts > 0)
              Text(
                'Intentos restantes: ${3 - adminLoginAttempts}/3',
                style: TextStyle(
                  color: adminLoginAttempts >= 2 ? Colors.orange : accentPink,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 20),
            // Campo Email Admin
            TextField(
              controller: adminEmailController,
              style: const TextStyle(color: lightGray),
              decoration: InputDecoration(
                labelText: 'Email de Admin',
                labelStyle: TextStyle(color: mediumGray),
                hintText: 'admin@tienda.com',
                hintStyle: TextStyle(color: mediumGray.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.email, color: primaryGold),
                filled: true,
                fillColor: darkBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: primaryGold.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: primaryGold.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: primaryGold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Campo Contraseña
            TextField(
              controller: adminPasswordController,
              obscureText: true,
              style: const TextStyle(color: lightGray),
              decoration: InputDecoration(
                labelText: 'Contraseña',
                labelStyle: TextStyle(color: mediumGray),
                hintText: '••••••••',
                hintStyle: TextStyle(color: mediumGray.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.lock, color: primaryGold),
                filled: true,
                fillColor: darkBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: primaryGold.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: primaryGold.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: primaryGold),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              adminEmailController.dispose();
              adminPasswordController.dispose();
            },
            child: const Text('Cancelar', style: TextStyle(color: mediumGray)),
          ),
          ElevatedButton(
            onPressed: () {
              final email = adminEmailController.text.trim();
              final password = adminPasswordController.text.trim();

              // Credenciales de admin (CAMBIAR ESTOS VALORES)
              const String ADMIN_EMAIL = 'admin@tienda.com';
              const String ADMIN_PASSWORD = 'admin123';

              // Registrar intento de inicio de sesión
              loginAttemptLog.add({
                'email': email,
                'timestamp': DateTime.now(),
                'success': email == ADMIN_EMAIL && password == ADMIN_PASSWORD,
              });

              if (email == ADMIN_EMAIL && password == ADMIN_PASSWORD) {
                // Credenciales correctas - resetear intentos
                adminLoginAttempts = 0;
                isAdminLocked = false;
                lastFailedAttempt = null;

                Navigator.pop(context);
                adminEmailController.dispose();
                adminPasswordController.dispose();

                // Acceder al Panel Admin
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminPanel(
                      currentUserEmail: widget.currentUser['email'],
                      onStatusChanged: () {
                        debugPrint('Estado de compra actualizado');
                        setState(() {});
                      },
                    ),
                  ),
                );
              } else {
                // Credenciales incorrectas - incrementar intentos
                adminLoginAttempts++;
                lastFailedAttempt = DateTime.now();

                if (adminLoginAttempts >= 3) {
                  // Bloquear después de 3 intentos
                  isAdminLocked = true;
                  Navigator.pop(context);
                  adminEmailController.dispose();
                  adminPasswordController.dispose();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '🔒 Cuenta bloqueada por 15 minutos después de 3 intentos fallidos',
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 4),
                    ),
                  );
                } else {
                  // Mostrar error con contador de intentos
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '❌ Email o contraseña incorrecta (${3 - adminLoginAttempts} intentos restantes)',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGold,
              foregroundColor: darkBg,
            ),
            child: const Text('Acceder'),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onAddToCart;
  final Function(String) onOpenUrl;
  final Function(String, bool) onFavoriteToggle;
  final bool isFav;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onOpenUrl,
    required this.onFavoriteToggle,
    required this.isFav,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool hovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final name = product['name'] ?? 'Producto';
    final price = product['price'] ?? 0;
    final imageUrl = product['image_url'] ?? '';
    final rating = (product['rating'] as num?)?.toDouble() ?? 4.8;
    final isFavorite = widget.isFav;

    return MouseRegion(
      onEnter: (_) {
        setState(() => hovering = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => hovering = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: () => _showProductModal(context, product),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform.scale(
            scale: 1 + (_controller.value * 0.05),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: cardBg,
                border: Border.all(
                  color: hovering ? primaryGold : primaryGold.withOpacity(0.15),
                  width: hovering ? 1.5 : 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: hovering
                        ? primaryGold.withOpacity(0.25)
                        : Colors.black26,
                    blurRadius: hovering ? 16 : 6,
                    offset: Offset(0, hovering ? 8 : 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                          child: Container(
                            color: cardBg,
                            width: double.infinity,
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    getSupabaseImageUrl(imageUrl),
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                              color: primaryGold,
                                              strokeWidth: 2,
                                            ),
                                          );
                                        },
                                    errorBuilder: (context, error, st) =>
                                        const Icon(
                                          Icons.image,
                                          color: primaryGold,
                                        ),
                                  )
                                : const Icon(
                                    Icons.image_not_supported,
                                    color: primaryGold,
                                  ),
                          ),
                        ),
                        // Rating badge
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: darkBg.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: primaryGold,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 10,
                                  color: primaryGold,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: primaryGold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Favorite button
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              final productId = product['id']?.toString() ?? '';
                              widget.onFavoriteToggle(productId, !isFavorite);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: darkBg.withOpacity(0.9),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isFavorite ? accentPink : primaryGold,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isFavorite ? accentPink : primaryGold)
                                            .withOpacity(0.4),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_outline,
                                size: 14,
                                color: isFavorite ? accentPink : primaryGold,
                              ),
                            ),
                          ),
                        ),
                        // Hover overlay
                        if (hovering)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(14),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Info
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: lightGray,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryGold.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: primaryGold.withOpacity(0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                'L ${price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: primaryGold,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            if (hovering)
                              GestureDetector(
                                onTap: widget.onAddToCart,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: primaryGold,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 14,
                                    color: darkBg,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(width: 28),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showProductModal(BuildContext context, Map<String, dynamic> product) {
    final name = product['name'] ?? 'Producto';
    final price = product['price'] ?? 0;
    final description = product['description'] ?? '';
    final imageUrl = product['image_url'] ?? '';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryGold, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: primaryGold.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con imagen (clickeable para zoom)
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Mostrar imagen en zoom
                        showDialog(
                          context: context,
                          builder: (ctx) => Dialog(
                            backgroundColor: Colors.black.withOpacity(0.9),
                            insetPadding: EdgeInsets.zero,
                            child: Stack(
                              children: [
                                Center(
                                  child: imageUrl.isNotEmpty
                                      ? InteractiveViewer(
                                          boundaryMargin: const EdgeInsets.all(
                                            20,
                                          ),
                                          minScale: 1.0,
                                          maxScale: 4.0,
                                          child: Image.network(
                                            getSupabaseImageUrl(imageUrl),
                                            fit: BoxFit.contain,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.image,
                                          size: 100,
                                          color: primaryGold,
                                        ),
                                ),
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(ctx),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: darkBg.withOpacity(0.8),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: primaryGold,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                getSupabaseImageUrl(imageUrl),
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 250,
                                color: cardBg,
                                child: const Icon(
                                  Icons.image,
                                  size: 60,
                                  color: primaryGold,
                                ),
                              ),
                      ),
                    ),
                    // Icono de zoom
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: darkBg.withOpacity(0.8),
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryGold, width: 0.5),
                        ),
                        child: const Icon(
                          Icons.zoom_in,
                          color: primaryGold,
                          size: 18,
                        ),
                      ),
                    ),
                    // Close button
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: darkBg.withOpacity(0.8),
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryGold, width: 0.5),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: primaryGold,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre y rating
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: primaryGold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    ...List.generate(
                                      5,
                                      (i) => const Padding(
                                        padding: EdgeInsets.only(right: 2),
                                        child: Icon(
                                          Icons.star,
                                          size: 14,
                                          color: primaryGold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '4.8 (120 reviews)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: mediumGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Precio
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryGold.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Precio',
                              style: TextStyle(color: lightGray, fontSize: 13),
                            ),
                            Text(
                              'L ${price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: primaryGold,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Descripción
                      Text(
                        'Descripción',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: lightGray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description.isEmpty
                            ? 'Producto premium de alta calidad'
                            : description,
                        style: TextStyle(
                          fontSize: 13,
                          color: mediumGray,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Botones de acción
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGold,
                                foregroundColor: darkBg,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onAddToCart();
                              },
                              child: const Text(
                                'Agregar al carrito',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: darkPink,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                    color: primaryGold,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                widget.onOpenUrl('https://wa.me/31519371');
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Contactar',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
