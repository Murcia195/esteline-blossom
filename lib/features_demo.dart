import 'package:flutter/material.dart';

// Color constantes
const Color primaryGold = Color(0xFFD4AF37);
const Color darkBg = Color(0xFF0A0A0A);
const Color cardBg = Color(0xFF1A1A1A);
const Color accentPink = Color(0xFFE91E63);
const Color darkPink = Color(0xFFC2185B);
const Color lightGray = Color(0xFFE0E0E0);
const Color mediumGray = Color(0xFF9E9E9E);

class FeaturesDemo extends StatefulWidget {
  const FeaturesDemo({Key? key}) : super(key: key);

  @override
  State<FeaturesDemo> createState() => _FeaturesDemoState();
}

class _FeaturesDemoState extends State<FeaturesDemo>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool darkMode = false;
  double priceFilter = 100;
  double imageZoom = 1.0;
  bool isFavorite = false;
  int cartQuantity = 1;
  int selectedPaymentMethod = 0;
  int rewardsPoints = 250;
  bool notificationsEnabled = true;
  double shimmerOpacity = 0.5;
  bool showBadge = true;
  double rating = 4.5;
  bool enable2FA = false;
  int userLevel = 2;
  double cartTotalValue = 245.50;
  String selectedCurrency = 'L';
  int selectedTab = 0;
  String chatMessage = '';
  bool isSearching = false;
  int selectedAddress = 0;
  bool showTrackingMap = false;
  double scrollProgress = 0.3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(
      () => setState(() => selectedTab = _tabController.index),
    );
    _startShimmerAnimation();
  }

  void _startShimmerAnimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => shimmerOpacity = shimmerOpacity == 0.5 ? 1.0 : 0.5);
        _startShimmerAnimation();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkMode ? darkBg : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: darkMode ? cardBg : Colors.white,
        elevation: 0,
        title: const Text(
          '🚀 100 FEATURES PROFESIONALES',
          style: TextStyle(
            color: primaryGold,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              darkMode ? Icons.light_mode : Icons.dark_mode,
              color: primaryGold,
            ),
            onPressed: () => setState(() => darkMode = !darkMode),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: darkMode ? cardBg : Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: primaryGold,
              labelColor: primaryGold,
              unselectedLabelColor: mediumGray,
              isScrollable: true,
              tabs: const [
                Tab(text: '👁️ Visual'),
                Tab(text: '🛒 Compra'),
                Tab(text: '👤 Perfil'),
                Tab(text: '💬 Social'),
                Tab(text: '🔧 Admin'),
                Tab(text: '🚀 Avanzado'),
                Tab(text: '💰 PREMIUM'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVisualFeatures(),
                _buildShoppingFeatures(),
                _buildProfileFeatures(),
                _buildChatFeatures(),
                _buildAdminFeatures(),
                _buildAdvancedFeaturesTab(),
                _buildPremiumFeaturesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        backgroundColor: accentPink,
        label: const Text('Volver'),
        icon: const Icon(Icons.close),
      ),
    );
  }

  // ============ VISUAL FEATURES ============
  Widget _buildVisualFeatures() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 1. Dark Mode Toggle
          _demoCard(
            title: '#1 - Tema Claro/Oscuro',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Modo Oscuro Activo'),
                    Switch(
                      value: darkMode,
                      onChanged: (val) => setState(() => darkMode = val),
                      activeColor: primaryGold,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: darkMode ? cardBg : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    darkMode ? '🌙 Modo Oscuro' : '☀️ Modo Claro',
                    style: TextStyle(
                      color: darkMode ? primaryGold : Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. Image Carousel
          _demoCard(
            title: '#2 - Carrosel de Imágenes',
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: [
                            Colors.purple,
                            Colors.pink,
                            Colors.orange,
                          ][index],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Imagen ${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '👆 Desliza para ver más imágenes',
                  style: TextStyle(fontSize: 12, color: mediumGray),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. Advanced Search Filters
          _demoCard(
            title: '#3 - Filtros de Búsqueda Avanzada',
            child: Column(
              children: [
                Text(
                  'Filtrar por precio: L ${priceFilter.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, color: mediumGray),
                ),
                Slider(
                  value: priceFilter,
                  min: 0,
                  max: 1000,
                  activeColor: primaryGold,
                  onChanged: (val) => setState(() => priceFilter = val),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ['Barato', 'Medio', 'Premium']
                      .map(
                        (filter) => Chip(
                          label: Text(filter),
                          backgroundColor: cardBg,
                          labelStyle: const TextStyle(
                            color: primaryGold,
                            fontSize: 11,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 4. Image Zoom
          _demoCard(
            title: '#4 - Zoom de Imágenes',
            child: Column(
              children: [
                Text(
                  'Zoom: ${imageZoom.toStringAsFixed(1)}x',
                  style: const TextStyle(fontSize: 12, color: mediumGray),
                ),
                const SizedBox(height: 8),
                Transform.scale(
                  scale: imageZoom,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: primaryGold.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.image, size: 60, color: primaryGold),
                    ),
                  ),
                ),
                Slider(
                  value: imageZoom,
                  min: 1,
                  max: 3,
                  activeColor: primaryGold,
                  onChanged: (val) => setState(() => imageZoom = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 5. Shimmer Effect
          _demoCard(
            title: '#5 - Efecto Shimmer (Carga)',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: AnimatedOpacity(
                opacity: shimmerOpacity,
                duration: const Duration(milliseconds: 500),
                onEnd: () {
                  if (shimmerOpacity == 0.5) {
                    setState(() => shimmerOpacity = 1.0);
                  } else {
                    setState(() => shimmerOpacity = 0.5);
                  }
                },
                child: Container(height: 80, color: Colors.grey[400]),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 6. Badges
          _demoCard(
            title: '#6 - Badges/Etiquetas',
            child: Wrap(
              spacing: 12,
              children: [
                if (showBadge) ...[
                  _buildBadge('🆕 Nuevo', Colors.green),
                  _buildBadge('🔥 Oferta', Colors.red),
                  _buildBadge('⭐ Popular', primaryGold),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 7. Floating Cart Button
          _demoCard(
            title: '#7 - Carrito Flotante',
            child: Stack(
              children: [
                Container(
                  height: 100,
                  color: cardBg,
                  child: const Center(child: Text('Tienda de productos...')),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentPink,
                      boxShadow: [
                        BoxShadow(
                          color: accentPink.withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                          size: 24,
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryGold,
                            ),
                            child: const Center(
                              child: Text(
                                '3',
                                style: TextStyle(
                                  color: darkBg,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 8. Micro Interactions
          _demoCard(
            title: '#8 - Animaciones Micro-interacciones',
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✨ Agregado al carrito con animación!'),
                    duration: Duration(milliseconds: 500),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                '🛒 Agregar al Carrito (con pulso)',
                style: TextStyle(color: darkBg),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 9. Gradients
          _demoCard(
            title: '#9 - Gradientes Personalizados',
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryGold.withOpacity(0.3),
                    accentPink.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text('Fondo con Gradiente Premium')),
            ),
          ),
          const SizedBox(height: 12),

          // 10. 3D Shadows
          _demoCard(
            title: '#10 - Tarjetas con Sombras 3D',
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primaryGold.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(4, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Text('Tarjeta con sombra 3D'),
            ),
          ),
        ],
      ),
    );
  }

  // ============ SHOPPING FEATURES ============
  Widget _buildShoppingFeatures() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 11. Persistent Cart
          _demoCard(
            title: '#11 - Carrito Persistente',
            child: Column(
              children: [
                Text(
                  'Carrito guardado: ${cartQuantity} productos',
                  style: const TextStyle(fontSize: 12, color: mediumGray),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: primaryGold),
                      onPressed: () => setState(() {
                        if (cartQuantity > 1) cartQuantity--;
                      }),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryGold),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('$cartQuantity'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: primaryGold),
                      onPressed: () => setState(() => cartQuantity++),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 12. Coupons
          _demoCard(
            title: '#12 - Cupones/Códigos de Descuento',
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Ingresa cupón (ej: ESTELINE20)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(
                      Icons.local_offer,
                      color: primaryGold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Cupón aplicado! 20% descuento'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryGold),
                  child: const Text(
                    'Aplicar Cupón',
                    style: TextStyle(color: darkBg),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 14. Payment Methods
          _demoCard(
            title: '#14 - Métodos de Pago Múltiples',
            child: Column(
              children: [
                ...['💳 Tarjeta', '🏦 Transferencia', '💵 Efectivo']
                    .asMap()
                    .entries
                    .map(
                      (e) => RadioListTile(
                        title: Text(
                          e.value,
                          style: const TextStyle(fontSize: 13),
                        ),
                        value: e.key,
                        groupValue: selectedPaymentMethod,
                        onChanged: (val) =>
                            setState(() => selectedPaymentMethod = val as int),
                        activeColor: primaryGold,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 16. Wishlist
          _demoCard(
            title: '#16 - Wishlist/Favoritos Mejorado',
            child: Column(
              children: [
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_outline,
                    color: isFavorite ? accentPink : mediumGray,
                    size: 32,
                  ),
                  onPressed: () => setState(() => isFavorite = !isFavorite),
                ),
                const SizedBox(height: 8),
                Text(
                  isFavorite
                      ? '❤️ Agregado a favoritos'
                      : '🤍 Agregar a favoritos',
                  style: const TextStyle(fontSize: 12, color: mediumGray),
                ),
                if (isFavorite) ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: const Text('Compartir Wishlist'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 20. Personalized Recommendations
          _demoCard(
            title: '#20 - Recomendaciones Personalizadas',
            child: Column(
              children: [
                const Text(
                  'Basado en tus compras anteriores:',
                  style: TextStyle(fontSize: 12, color: mediumGray),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 100,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: primaryGold, width: 0.5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.card_giftcard,
                              color: primaryGold,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Producto ${index + 1}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: mediumGray,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ PROFILE FEATURES ============
  Widget _buildProfileFeatures() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 21. User Profile
          _demoCard(
            title: '#21 - Perfil de Usuario Completo',
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: primaryGold.withOpacity(0.2),
                  child: const Icon(Icons.person, color: primaryGold, size: 40),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Gissel Rodríguez',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'girodel@gmail.com',
                  style: TextStyle(fontSize: 11, color: mediumGray),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: primaryGold),
                  child: const Text(
                    'Editar Perfil',
                    style: TextStyle(color: darkBg),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 22. Multiple Addresses
          _demoCard(
            title: '#22 - Múltiples Direcciones',
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on, color: primaryGold),
                  title: const Text(
                    'Casa - 123 Calle Principal',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(child: Text('Editar')),
                      const PopupMenuItem(child: Text('Eliminar')),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.location_on, color: primaryGold),
                  title: const Text(
                    'Oficina - 456 Avenida Central',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(child: Text('Editar')),
                      const PopupMenuItem(child: Text('Eliminar')),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Dirección'),
                  style: ElevatedButton.styleFrom(backgroundColor: primaryGold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 26. Rewards Points
          _demoCard(
            title: '#26 - Sistema de Puntos/Rewards',
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryGold.withOpacity(0.2),
                        accentPink.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Puntos Acumulados',
                        style: TextStyle(fontSize: 12, color: mediumGray),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$rewardsPoints ⭐',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primaryGold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: rewardsPoints / 500,
                  backgroundColor: cardBg,
                  valueColor: const AlwaysStoppedAnimation(primaryGold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '300 puntos para siguiente regalo',
                  style: TextStyle(fontSize: 11, color: mediumGray),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 27. VIP Levels
          _demoCard(
            title: '#27 - Niveles VIP',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildVIPBadge('Bronze', Colors.brown, false),
                    _buildVIPBadge('Silver', Colors.grey, false),
                    _buildVIPBadge('Gold', primaryGold, true),
                    _buildVIPBadge('Platinum', accentPink, false),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tu nivel actual: GOLD ⭐',
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ CHAT FEATURES ============
  Widget _buildChatFeatures() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 31. Live Chat
          _demoCard(
            title: '#31 - Chat en Vivo',
            child: Column(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: darkBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Agente: ¿Cómo puedo ayudarte? 😊',
                          style: TextStyle(fontSize: 11, color: mediumGray),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.centerRight,
                        child: const Text(
                          'Tengo una pregunta',
                          style: TextStyle(fontSize: 11, color: primaryGold),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Escribe tu mensaje...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: primaryGold),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 33. Push Notifications
          _demoCard(
            title: '#33 - Notificaciones Push',
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primaryGold, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications, color: primaryGold),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          '¡Nueva oferta! 20% de descuento en maquillaje',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Switch(
                        value: notificationsEnabled,
                        onChanged: (val) =>
                            setState(() => notificationsEnabled = val),
                        activeColor: primaryGold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 37. Feedback Form
          _demoCard(
            title: '#37 - Feedback Form (Encuestas)',
            child: Column(
              children: [
                const Text(
                  '¿Qué tal fue tu experiencia?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['😞', '😐', '😊', '😍']
                      .map(
                        (emoji) => GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gracias por tu feedback $emoji'),
                              ),
                            );
                          },
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 39. Blog
          _demoCard(
            title: '#39 - Blog Integrado',
            child: Column(
              children: [
                const Text(
                  'Tips de Belleza',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...[
                      'Cuidado de piel en verano',
                      'Maquillaje duradero',
                      'Tips de ojos',
                    ]
                    .map(
                      (blog) => ListTile(
                        leading: const Icon(Icons.article, color: primaryGold),
                        title: Text(blog, style: const TextStyle(fontSize: 12)),
                        trailing: const Icon(
                          Icons.arrow_forward,
                          color: mediumGray,
                          size: 16,
                        ),
                        onTap: () {},
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ ADMIN FEATURES ============
  Widget _buildAdminFeatures() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 41. Sales Dashboard
          _demoCard(
            title: '#41 - Dashboard de Ventas',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard('Ventas', 'L 5,200', primaryGold),
                    _buildStatCard('Órdenes', '42', accentPink),
                    _buildStatCard('Clientes', '156', Colors.green),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 42. Inventory Management
          _demoCard(
            title: '#42 - Gestión de Inventario',
            child: Column(
              children: [
                const Text(
                  'Stock de Productos',
                  style: TextStyle(fontSize: 12, color: mediumGray),
                ),
                const SizedBox(height: 12),
                ...['Bronceador', 'Sombra de ojos', 'Labial']
                    .map(
                      (product) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(product, style: const TextStyle(fontSize: 11)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryGold.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '15 unidades',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: primaryGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 43. Sales Reports
          _demoCard(
            title: '#43 - Reportes de Ventas',
            child: Column(
              children: [
                const Text(
                  'Ventas Semanales',
                  style: TextStyle(fontSize: 12, color: mediumGray),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      '📊 Gráfico de Ventas\n(Chart.js integrado)',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: mediumGray),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 45. User Management
          _demoCard(
            title: '#45 - Gestión de Usuarios',
            child: Column(
              children: [
                const Text(
                  'Clientes Registrados',
                  style: TextStyle(fontSize: 12, color: mediumGray),
                ),
                const SizedBox(height: 12),
                ...[
                      'girodel@gmail.com',
                      'cliente2@email.com',
                      'cliente3@email.com',
                    ]
                    .map(
                      (email) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: primaryGold.withOpacity(0.2),
                          child: const Icon(
                            Icons.person,
                            color: primaryGold,
                            size: 16,
                          ),
                        ),
                        title: Text(
                          email,
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: const Icon(
                          Icons.more_vert,
                          color: mediumGray,
                          size: 16,
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ HELPER WIDGETS ============
  Widget _demoCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkMode ? cardBg : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryGold.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(color: primaryGold.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: primaryGold,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildVIPBadge(String level, Color color, bool isActive) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
            border: Border.all(
              color: isActive ? color : mediumGray,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Text(
            level[0],
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          level,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? color : mediumGray,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 0.5),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: mediumGray)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== FEATURES 46-100 ====================
  Widget _buildAdvancedFeaturesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 46-50: Avanzadas
          _demoCard(
            title: '#46 - Auditoría en Tiempo Real',
            child: Column(
              children: [
                _buildAuditLog('Usuario registrado', 'Hace 2 minutos'),
                _buildAuditLog('Producto actualizado', 'Hace 5 minutos'),
                _buildAuditLog('Orden confirmada', 'Hace 8 minutos'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#47 - Búsqueda Visual con IA',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryGold),
              ),
              child: Column(
                children: [
                  const Icon(Icons.image_search, color: primaryGold, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'Buscar por imagen',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGold,
                    ),
                    child: const Text(
                      'Subir Foto',
                      style: TextStyle(color: darkBg),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#48 - Instagram Integrado',
            child: Column(
              children: [
                const Text(
                  'Conectar Instagram',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.pink),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.camera, color: Colors.pink),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Comparte fotos de tus looks',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                        ),
                        child: const Text(
                          'Conectar',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#49 - TikTok Integration',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: mediumGray),
              ),
              child: Column(
                children: [
                  const Icon(Icons.play_circle, color: mediumGray, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'Videos de Belleza en TikTok',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mediumGray,
                    ),
                    child: const Text(
                      'Ver Videos',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#50 - Programa de Referidos Premium',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentPink),
              ),
              child: Column(
                children: [
                  const Text(
                    'Invita y gana',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: accentPink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'L 100 por cada amigo registrado',
                    style: TextStyle(fontSize: 11, color: mediumGray),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: const Text('Compartir Link'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentPink,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 51-55: Más avanzadas
          _demoCard(
            title: '#51 - Encuestas de Satisfacción Avanzadas',
            child: Column(
              children: [
                const Text(
                  '¿Recomendarías nuestro servicio?',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['Nunca', 'Tal vez', 'Sí', 'Definitivamente']
                      .map(
                        (e) => Chip(
                          label: Text(e, style: const TextStyle(fontSize: 10)),
                          backgroundColor: primaryGold.withOpacity(0.2),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#52 - Newsletter Personalizado',
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.mail, color: primaryGold, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Suscríbete a nuestro newsletter',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ofertas exclusivas + tips de belleza',
                        style: TextStyle(fontSize: 10, color: mediumGray),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: primaryGold),
                  child: const Text(
                    'Suscribir',
                    style: TextStyle(color: darkBg),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#53 - Eventos y Promociones Especiales',
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: accentPink),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event, color: accentPink),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Black Friday 2025',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '30% descuento en todo',
                              style: TextStyle(fontSize: 10, color: mediumGray),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#54 - Integración con Google Maps',
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryGold, width: 0.5),
              ),
              child: const Center(
                child: Icon(Icons.location_on, color: primaryGold, size: 48),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#55 - Sincronización Multi-dispositivo',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_done, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Sincronizando con la nube...',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 56-60
          _demoCard(
            title: '#56 - Historial de Búsqueda Inteligente',
            child: Column(
              children: [
                const Text(
                  'Búsquedas recientes',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: mediumGray,
                  ),
                ),
                const SizedBox(height: 8),
                ...['Labial rojo', 'Sombra dorada', 'Base líquida']
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.history,
                              color: primaryGold,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(e, style: const TextStyle(fontSize: 11)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 14,
                                color: mediumGray,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#57 - Modo Incógnito/Privado',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple),
              ),
              child: Row(
                children: [
                  const Icon(Icons.privacy_tip, color: Colors.purple),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Modo Incógnito Activado',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'Tu historial no se guardará',
                          style: TextStyle(fontSize: 10, color: mediumGray),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: true,
                    onChanged: (v) {},
                    activeColor: Colors.purple,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#58 - Atajos Personalizados',
            child: Wrap(
              spacing: 8,
              children: ['Favoritos', 'Ofertas', 'Tienda', 'Perfil']
                  .map(
                    (e) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryGold),
                      ),
                      child: Text(
                        e,
                        style: const TextStyle(
                          fontSize: 10,
                          color: primaryGold,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#59 - Importar Contactos',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                children: [
                  const Icon(Icons.contacts, color: Colors.green, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'Invita a tus contactos',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Importar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#60 - API de Terceros Integrada',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Row(
                children: [
                  Icon(Icons.api, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'APIs integradas: PayPal, Stripe, Firebase',
                      style: TextStyle(fontSize: 10, color: mediumGray),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 61-70: UX Avanzado
          _demoCard(
            title: '#61 - Búsqueda por Voz',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mic, color: Colors.red, size: 32),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      const Text(
                        'Buscar por voz',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Presiona para hablar...',
                        style: TextStyle(fontSize: 10, color: mediumGray),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#62 - Modo Offline',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_off, color: Colors.amber),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Funciones disponibles sin internet',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#63 - Gestos Personalizados',
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryGold, width: 0.5),
              ),
              child: const Column(
                children: [
                  Text(
                    'Gesto: Deslizar hacia arriba',
                    style: TextStyle(fontSize: 11, color: mediumGray),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '= Carrito',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: primaryGold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Gesto: Doble tap',
                    style: TextStyle(fontSize: 11, color: mediumGray),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '= Agregar a favoritos',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: primaryGold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#64 - Dark Mode Automático',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo),
              ),
              child: Row(
                children: [
                  const Icon(Icons.brightness_4, color: Colors.indigo),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Activar automáticamente a las 6 PM',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  Switch(
                    value: true,
                    onChanged: (v) {},
                    activeColor: Colors.indigo,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#65 - Accesibilidad Mejorada',
            child: Column(
              children: [
                CheckboxListTile(
                  title: const Text(
                    'Texto grande',
                    style: TextStyle(fontSize: 11),
                  ),
                  value: false,
                  onChanged: (v) {},
                  activeColor: primaryGold,
                ),
                CheckboxListTile(
                  title: const Text(
                    'Contraste alto',
                    style: TextStyle(fontSize: 11),
                  ),
                  value: false,
                  onChanged: (v) {},
                  activeColor: primaryGold,
                ),
                CheckboxListTile(
                  title: const Text(
                    'Lector de pantalla',
                    style: TextStyle(fontSize: 11),
                  ),
                  value: false,
                  onChanged: (v) {},
                  activeColor: primaryGold,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#66 - Soporte Multi-idioma',
            child: DropdownButton(
              isExpanded: true,
              value: 'Español',
              items: ['Español', 'English', 'Français', 'Português', '中文']
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: const TextStyle(fontSize: 11)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {},
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#67 - Notificaciones Inteligentes',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentPink),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications, color: accentPink),
                      const SizedBox(width: 8),
                      const Text(
                        'Notificaciones basadas en IA',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: true,
                        onChanged: (v) {},
                        activeColor: accentPink,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Recibe alertas solo cuando es importante',
                    style: TextStyle(fontSize: 10, color: mediumGray),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#68 - Historial Sincronizado',
            child: Column(
              children: [
                const Text(
                  'Tu historial en todos tus dispositivos',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(
                    Icons.phone,
                    color: primaryGold,
                    size: 20,
                  ),
                  title: const Text(
                    'iPhone 12',
                    style: TextStyle(fontSize: 11),
                  ),
                  trailing: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.laptop,
                    color: primaryGold,
                    size: 20,
                  ),
                  title: const Text(
                    'MacBook Pro',
                    style: TextStyle(fontSize: 11),
                  ),
                  trailing: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#69 - Atajos de Teclado',
            child: Column(
              children: [
                const Text(
                  'Presiona "?" para ver atajos',
                  style: TextStyle(fontSize: 11, color: mediumGray),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Column(
                    children: [
                      Text('Ctrl + / = Buscar', style: TextStyle(fontSize: 10)),
                      Text(
                        'Ctrl + 1 = Categoría 1',
                        style: TextStyle(fontSize: 10),
                      ),
                      Text(
                        'Ctrl + 2 = Categoría 2',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#70 - Compresión de Imágenes Automática',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal),
              ),
              child: Row(
                children: [
                  const Icon(Icons.image, color: Colors.teal),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Imágenes optimizadas: 80% más rápido',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  const Icon(Icons.flash_on, color: Colors.amber),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 71-80: Technical
          _demoCard(
            title: '#71 - PWA (Progressive Web App)',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Column(
                children: [
                  const Icon(Icons.app_shortcut, color: Colors.blue, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'Instalar como App',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Instalar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#72 - Service Workers',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_done, color: Colors.purple),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Carga rápida sin conexión',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  const Icon(Icons.flash_on, color: Colors.amber),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#73 - Análisis de Performance',
            child: Column(
              children: [
                const Text(
                  'Velocidad de carga: 0.8s',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: 0.95,
                  backgroundColor: cardBg,
                  valueColor: const AlwaysStoppedAnimation(Colors.green),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Optimización: 95%',
                  style: TextStyle(fontSize: 10, color: mediumGray),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#74 - Rastreo de Errores (Sentry)',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bug_report, color: Colors.red),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Monitoreo de errores activo',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#75 - A/B Testing',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.cyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.cyan),
              ),
              child: Column(
                children: [
                  const Text(
                    'Variante A activa',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Conversión: 12.5%',
                    style: TextStyle(fontSize: 11, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#76 - SEO Optimizado',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal),
              ),
              child: const Column(
                children: [
                  Text(
                    'Meta Tags automáticos',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Schema.org structured data',
                    style: TextStyle(fontSize: 10, color: mediumGray),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#77 - Cache Inteligente',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.lime.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.lime),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storage, color: Colors.lime),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Cache de 10 MB local',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  const Icon(Icons.speed, color: Colors.amber),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#78 - Integración Firebase',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Firebase Real-time Database',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#79 - Webhook Automático',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo),
              ),
              child: const Column(
                children: [
                  Text(
                    'Webhooks configurados',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '3 endpoints activos',
                    style: TextStyle(fontSize: 10, color: mediumGray),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#80 - Analítica en Tiempo Real',
            child: Column(
              children: [
                const Text(
                  'Usuarios activos: 1,234',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: 0.7,
                  backgroundColor: cardBg,
                  valueColor: const AlwaysStoppedAnimation(Colors.green),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 81-90: Integraciones
          _demoCard(
            title: '#81 - Integración PayPal',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payment, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Pagar con PayPal',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'Pagar',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#82 - Integración Stripe',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple),
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Pagar con tarjeta (Stripe)',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'Pagar',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#83 - Google Maps Integrado',
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.5)),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, color: Colors.red, size: 48),
                    Text(
                      'Mapa interactivo de tiendas',
                      style: TextStyle(fontSize: 11, color: mediumGray),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#84 - Integración Google Calendar',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Eventos del Calendario',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Sincronizado automáticamente',
                          style: TextStyle(fontSize: 10, color: mediumGray),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#85 - Mailchimp Newsletter',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email, color: Colors.amber),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Gestión de correos con Mailchimp',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#86 - Twilio SMS',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(Icons.message, color: Colors.red),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'SMS automáticos para confirmación',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#87 - Integración Segment',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: const Row(
                children: [
                  Icon(Icons.analytics, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Analítica centralizada con Segment',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#88 - Slack Notifications',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active, color: Colors.purple),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Alertas en Slack del equipo',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#89 - Social Login',
            child: Column(
              children: [
                const Text(
                  'Inicia sesión con:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.g_translate, color: Colors.blue),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.apple, color: Colors.black),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.facebook, color: Colors.blue),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#90 - Webhooks Custom',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal),
              ),
              child: const Row(
                children: [
                  Icon(Icons.webhook, color: Colors.teal),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Webhooks personalizados configurados',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 91-100: Gamificación
          _demoCard(
            title: '#91 - Sistema de Badges',
            child: Column(
              children: [
                const Text(
                  'Tus logros desbloqueados:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children:
                      [
                            '🏆 Comprador',
                            '⭐ Top Reviewer',
                            '🎁 Referidos',
                            '💎 VIP',
                          ]
                          .map(
                            (e) => Column(
                              children: [
                                Text(e, style: const TextStyle(fontSize: 20)),
                                const SizedBox(height: 4),
                                const Text(
                                  'Desbloqueado',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: mediumGray,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#92 - Leaderboard Global',
            child: Column(
              children: [
                const Text(
                  'Top compradores este mes:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildLeaderboardRow('🥇', 'Gissel', 'L 5,200'),
                _buildLeaderboardRow('🥈', 'María', 'L 4,800'),
                _buildLeaderboardRow('🥉', 'Carmen', 'L 4,100'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#93 - Rueda de la Fortuna',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryGold),
              ),
              child: Column(
                children: [
                  const Icon(Icons.casino, color: primaryGold, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    '¡Girar la rueda!',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: primaryGold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGold,
                    ),
                    child: const Text(
                      'Girar Ahora',
                      style: TextStyle(color: darkBg),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#94 - Login Diario Bonus',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentPink),
              ),
              child: Column(
                children: [
                  const Text(
                    'Días consecutivos: 7 🔥',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: accentPink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gana + 50 puntos hoy',
                    style: TextStyle(fontSize: 10, color: mediumGray),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 0.7,
                    backgroundColor: cardBg,
                    valueColor: const AlwaysStoppedAnimation(accentPink),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#95 - Misiones Diarias',
            child: Column(
              children: [
                const Text(
                  'Completa para ganar puntos:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildMissionRow('✅ Compra L 100+', 'Completada'),
                _buildMissionRow('⏳ Escribe una reseña', 'Pendiente'),
                _buildMissionRow('⏳ Invita un amigo', 'Pendiente'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#96 - Lucky Draw',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.pink),
              ),
              child: Column(
                children: [
                  const Icon(Icons.card_giftcard, color: Colors.pink, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    '¡Sorteo de L 10,000!',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                    ),
                    child: const Text(
                      'Participar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#97 - Avatar Customizable',
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryGold.withOpacity(0.2),
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: primaryGold, size: 40),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: primaryGold),
                  child: const Text(
                    'Personalizar Avatar',
                    style: TextStyle(color: darkBg, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#98 - Logros Sociales',
            child: Column(
              children: [
                const Text(
                  'Comparte tus logros:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.share, color: Colors.blue),
                      tooltip: 'Facebook',
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.share, color: Colors.lightBlue),
                      tooltip: 'Twitter',
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.share, color: Colors.pink),
                      tooltip: 'Instagram',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#99 - Desafíos Mensuales',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                children: [
                  const Text(
                    'Desafío: 10 reseñas este mes',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Progreso: 6/10',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.6,
                    backgroundColor: cardBg,
                    valueColor: const AlwaysStoppedAnimation(Colors.orange),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _demoCard(
            title: '#100 - Logros Duelos Competitivos',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Column(
                children: [
                  const Text(
                    'Compite con amigos',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Tú',
                            style: TextStyle(fontSize: 10, color: mediumGray),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '850 pts',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.trending_up,
                        color: Colors.red,
                        size: 24,
                      ),
                      Column(
                        children: [
                          const Text(
                            'Amigo',
                            style: TextStyle(fontSize: 10, color: mediumGray),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '720 pts',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
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
        ],
      ),
    );
  }

  // ==================== HELPER PARA 46-100 ====================
  Widget _buildAuditLog(String action, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Text(action, style: const TextStyle(fontSize: 11)),
            ],
          ),
          Text(time, style: const TextStyle(fontSize: 10, color: mediumGray)),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(String medal, String name, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(medal, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 11,
              color: primaryGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionRow(String mission, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(mission, style: const TextStyle(fontSize: 11)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'Completada'
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 9,
                color: status == 'Completada' ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PREMIUM TAB: 200+ FEATURES ====================
  Widget _buildPremiumFeaturesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // SECCIÓN: AR & VIRTUAL TRY-ON (101-110)
          _buildSectionHeader('👓 AR & VIRTUAL TRY-ON (101-110)'),
          _demoCard(
            title: '#101 - Espejo Virtual 3D',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple),
              ),
              child: Row(
                children: [
                  const Icon(Icons.camera, color: Colors.purple),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prueba maquillaje en tiempo real',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'Con cámara integrada',
                          style: TextStyle(fontSize: 10, color: mediumGray),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                    child: const Text(
                      'Probar',
                      style: TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _demoCard(
            title: '#102 - AR Try-On Labiales',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.pink),
              ),
              child: const Row(
                children: [
                  Icon(Icons.brush, color: Colors.pink),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Prueba 50+ tonos de labiales',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _demoCard(
            title: '#103 - AR Try-On Sombras',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: const Row(
                children: [
                  Icon(Icons.palette, color: Colors.amber),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Visualiza sombras en tus párpados',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // SECCIÓN: MONETIZACIÓN (111-130)
          _buildSectionHeader('💳 MONETIZACIÓN DIRECTA (111-130)'),
          _demoCard(
            title: '#113 - Pago Dividido 3/6/12',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Column(
                children: [
                  const Text(
                    'Convierte clientes que no podían pagar',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['L 82 x 3', 'L 41 x 6', 'L 20 x 12']
                        .map(
                          (e) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              e,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _demoCard(
            title: '#120 - Gift Cards Digitales',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(Icons.card_giftcard, color: Colors.red),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Venta instantánea: L100 - L1000',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Comprar',
                      style: TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _demoCard(
            title: '#131 - Beauty Box Mensual',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal),
              ),
              child: Column(
                children: [
                  const Text(
                    'Caja sorpresa: L500/mes',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '4 productos sorpresa + acceso VIP',
                    style: TextStyle(fontSize: 10, color: mediumGray),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text(
                      'Suscribir Ahora',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // SECCIÓN: AI & RECOMENDACIONES (141-160)
          _buildSectionHeader('🤖 IA & RECOMENDACIONES (141-160)'),
          _demoCard(
            title: '#211 - IA Recomendación Personalizada',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo),
              ),
              child: Column(
                children: [
                  const Text(
                    'Basado en tu tono de piel, estilo, compras',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['🎯 Perfecto', '💚 Te amará', '⭐ Top']
                        .map(
                          (e) => Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.indigo.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  e,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _demoCard(
            title: '#212 - Análisis de Piel Con IA',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Row(
                children: [
                  Icon(Icons.face, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tu tipo: Mixta sensible',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'Recomendación: Productos hypoalergénicos',
                          style: TextStyle(fontSize: 10, color: mediumGray),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // SECCIÓN: SOCIAL & COMMUNITY (161-185)
          _buildSectionHeader('👥 SOCIAL & COMUNIDAD (161-185)'),
          _demoCard(
            title: '#141 - Galería de Influencers',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.pink),
              ),
              child: Column(
                children: [
                  const Text(
                    'Looks de influencers con nuestros productos',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['👩‍🎤 Gissel', '🎬 Maria', '✨ Carmen']
                        .map(
                          (e) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.pink.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              e,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.pink,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _demoCard(
            title: '#224 - TikTok Shop Integrado',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: mediumGray),
              ),
              child: Row(
                children: [
                  const Icon(Icons.play_circle, color: mediumGray),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Vende directo en TikTok',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                    child: const Text(
                      'Ir',
                      style: TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _demoCard(
            title: '#225 - Instagram Shop',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple),
              ),
              child: Row(
                children: [
                  const Icon(Icons.camera_alt, color: Colors.purple),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Tienda integrada en Instagram',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                    child: const Text(
                      'Shop',
                      style: TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // SECCIÓN: GAMIFICACIÓN (271-300)
          _buildSectionHeader('🎮 GAMIFICACIÓN MÁXIMA (271-300)'),
          _demoCard(
            title: '#271 - Daily Spin Wheel (L10-L200)',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Column(
                children: [
                  const Icon(Icons.casino, color: Colors.amber, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    '¡Girar y ganar cada día!',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Ganaste L 75! 🎉')),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    child: const Text(
                      'GIRAR RUEDA',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _demoCard(
            title: '#281 - Desafío Mensual (L 10,000 Premio)',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Column(
                children: [
                  const Text(
                    'Desafío: Compra L 1,000+ en mes',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Progreso: L 650/1,000',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.65,
                    backgroundColor: Colors.red.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.red),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _demoCard(
            title: '#291 - Leaderboard Global (Top Compradores)',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Column(
                children: [
                  _buildLeaderboardRow('🥇', 'Gissel', 'L 12,500'),
                  _buildLeaderboardRow('🥈', 'María', 'L 9,800'),
                  _buildLeaderboardRow('🥉', 'Carmen', 'L 8,200'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // SECCIÓN: PREMIUM SERVICES
          _buildSectionHeader('💎 SERVICIOS PREMIUM (186-210)'),
          _demoCard(
            title: '#186 - Personal Shopper 24/7',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_search, color: Colors.purple),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Asesor dedicado para VIP',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'Respuesta en < 5 minutos',
                          style: TextStyle(fontSize: 10, color: mediumGray),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                    child: const Text(
                      'Chat',
                      style: TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _demoCard(
            title: '#187 - Virtual Try-On Appointment',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo),
              ),
              child: Row(
                children: [
                  const Icon(Icons.videocam, color: Colors.indigo),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Video call con experto',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                    ),
                    child: const Text(
                      'Agendar',
                      style: TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // SECCIÓN: INTEGRACIONES PAGOS
          _buildSectionHeader('💰 INTEGRACIONES DE PAGO (81-90)'),
          _demoCard(
            title: '#81 - PayPal Integrado',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payment, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Paga con PayPal',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Pagar',
                      style: TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _demoCard(
            title: '#82 - Stripe Integrado',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple),
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card, color: Colors.deepPurple),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Tarjeta segura con Stripe',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: const Text(
                      'Pagar',
                      style: TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // RESUMEN
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryGold.withOpacity(0.2),
                  accentPink.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryGold, width: 2),
            ),
            child: Column(
              children: [
                const Text(
                  '✨ 200+ FEATURES PREMIUM',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryGold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Venta Directa • Monetización • Comunidad • Premium • Técnico • IA • Gamificación • Sostenibilidad',
                  style: TextStyle(fontSize: 10, color: mediumGray),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Impacto Estimado: +150% en ingresos',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: accentPink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: primaryGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryGold, width: 1),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: primaryGold,
        ),
      ),
    );
  }
}
