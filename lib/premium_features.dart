import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// ==================== MODELOS DE DATOS ====================
class ProductReview {
  final String id;
  final String userId;
  final String userName;
  final String productName;
  final int rating;
  final String text;
  final DateTime createdAt;
  final DateTime? editedAt;
  final String? userAvatar; // Base64 encoded image or null

  ProductReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.productName,
    required this.rating,
    required this.text,
    required this.createdAt,
    this.editedAt,
    this.userAvatar,
  });

  // Convertir a JSON para almacenar
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'productName': productName,
    'rating': rating,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
    'editedAt': editedAt?.toIso8601String(),
    'userAvatar': userAvatar,
  };

  // Crear desde JSON
  factory ProductReview.fromJson(Map<String, dynamic> json) => ProductReview(
    id: json['id'],
    userId: json['userId'],
    userName: json['userName'],
    productName: json['productName'],
    rating: json['rating'],
    text: json['text'],
    createdAt: DateTime.parse(json['createdAt']),
    editedAt: json['editedAt'] != null
        ? DateTime.parse(json['editedAt'])
        : null,
    userAvatar: json['userAvatar'],
  );
}

// CONSTANTES DE COLORES
const Color primaryGold = Color(0xFFD4AF37);
const Color darkBg = Color(0xFF0A0A0A);
const Color cardBg = Color(0xFF1A1A1A);
const Color accentPink = Color(0xFFE91E63);
const Color darkPink = Color(0xFFC2185B);
const Color lightGray = Color(0xFFE0E0E0);
const Color mediumGray = Color(0xFF9E9E9E);

// ==================== THEME NOTIFIER ====================
class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = true;
  late SharedPreferences _prefs;

  bool get isDarkMode => _isDarkMode;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool('isDarkMode') ?? true;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  ThemeData getTheme() {
    if (_isDarkMode) {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        primaryColor: primaryGold,
        colorScheme: ColorScheme.dark(
          primary: primaryGold,
          secondary: accentPink,
          surface: cardBg,
          background: darkBg,
        ),
      );
    } else {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: lightGray,
        primaryColor: primaryGold,
        colorScheme: ColorScheme.light(
          primary: primaryGold,
          secondary: accentPink,
          surface: Colors.white,
          background: lightGray,
        ),
      );
    }
  }
}

// ==================== PAGE WRAPPER WITH BOTTOM NAV ====================
class PageWithBottomNav extends StatelessWidget {
  final Widget child;
  final String title;
  final bool showBackButton;

  const PageWithBottomNav({
    required this.child,
    required this.title,
    this.showBackButton = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: cardBg,
        elevation: 0,
        leading: showBackButton
            ? BackButton(onPressed: () => Navigator.pop(context))
            : null,
      ),
      body: child,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: const Border(top: BorderSide(color: primaryGold, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: primaryGold.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: darkBg,
        selectedItemColor: primaryGold,
        unselectedItemColor: mediumGray,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Compras',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info'),
        ],
      ),
    );
  }
}

// ==================== PRODUCT REVIEWS PAGE ====================
class ProductReviewsPage extends StatefulWidget {
  const ProductReviewsPage({Key? key}) : super(key: key);

  @override
  State<ProductReviewsPage> createState() => _ProductReviewsPageState();
}

class _ProductReviewsPageState extends State<ProductReviewsPage> {
  late TextEditingController _reviewController;
  late TextEditingController _userNameController;
  int _selectedRating = 5;
  String _selectedProduct = 'Labial Rojo Pasión';
  List<ProductReview> _reviews = [];
  late SharedPreferences _prefs;
  String _currentUserId = '';
  String? _userAvatarBase64; // Avatar del usuario actual

  // Lista de productos disponibles
  final List<String> _availableProducts = [
    'Labial Rojo Pasión',
    'Labial Nude Clásico',
    'Labial Rosa Suave',
    'Base Matificante',
    'Base Luminosa',
    'Polvo Compacto',
    'Rubor Rosa',
    'Rubor Durazno',
    'Rubor Frambuesa',
    'Sombra Dorada',
    'Sombra Plateada',
    'Sombra Negra',
    'Rímel Profesional',
    'Delineador Líquido',
    'Delineador Lápiz',
    'Corrector',
    'Iluminador',
    'Contorno',
    'Brillo Labial',
    'Otro Producto',
  ];

  static const String _storageKey = 'product_reviews';
  static const String _userIdKey = 'user_id_reviews';
  static const String _userAvatarKey = 'user_avatar_reviews';
  static const String _userNameKey = 'user_name_reviews';

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController();
    _userNameController = TextEditingController();
    _loadData();
  }

  Future<void> _loadData() async {
    _prefs = await SharedPreferences.getInstance();

    // Obtener o crear ID de usuario
    _currentUserId = _prefs.getString(_userIdKey) ?? '';
    if (_currentUserId.isEmpty) {
      _currentUserId = DateTime.now().millisecondsSinceEpoch.toString();
      await _prefs.setString(_userIdKey, _currentUserId);
    }

    // Cargar avatar y nombre del usuario
    _userAvatarBase64 = _prefs.getString(_userAvatarKey);
    final savedName = _prefs.getString(_userNameKey);
    _userNameController.text = savedName ?? '';

    // Cargar reseñas
    final reviewsJson = _prefs.getStringList(_storageKey) ?? [];
    setState(() {
      _reviews = reviewsJson
          .map((json) => ProductReview.fromJson(jsonDecode(json)))
          .toList();
      _reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  Future<void> _saveReviews() async {
    final reviewsJson = _reviews
        .map((review) => jsonEncode(review.toJson()))
        .toList();
    await _prefs.setStringList(_storageKey, reviewsJson);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);

      setState(() {
        _userAvatarBase64 = base64String;
      });

      await _prefs.setString(_userAvatarKey, base64String);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil actualizada')),
      );
    }
  }

  void _addReview() {
    if (_reviewController.text.isEmpty || _userNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    // Guardar nombre del usuario
    _prefs.setString(_userNameKey, _userNameController.text);

    final review = ProductReview(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUserId,
      userName: _userNameController.text,
      productName: _selectedProduct,
      rating: _selectedRating,
      text: _reviewController.text,
      createdAt: DateTime.now(),
      userAvatar: _userAvatarBase64,
    );

    setState(() {
      _reviews.insert(0, review);
    });

    _saveReviews();
    _reviewController.clear();
    _selectedRating = 5;
    _selectedProduct = 'Labial Rojo Pasión';

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Reseña publicada exitosamente!')),
    );
  }

  void _editReview(ProductReview review) {
    if (review.userId != _currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo puedes editar tus propias reseñas')),
      );
      return;
    }

    _reviewController.text = review.text;
    _selectedProduct = review.productName;
    _userNameController.text = review.userName;
    _selectedRating = review.rating;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        title: const Text(
          'Editar Reseña',
          style: TextStyle(color: primaryGold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _userNameController,
                style: const TextStyle(color: lightGray),
                decoration: InputDecoration(
                  hintText: 'Tu nombre',
                  hintStyle: const TextStyle(color: mediumGray),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: primaryGold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButton<String>(
                value: _selectedProduct,
                dropdownColor: cardBg,
                isExpanded: true,
                items: _availableProducts
                    .map(
                      (product) => DropdownMenuItem(
                        value: product,
                        child: Text(
                          product,
                          style: const TextStyle(color: primaryGold),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(
                    () => _selectedProduct = value ?? 'Labial Rojo Pasión',
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Rating:', style: TextStyle(color: primaryGold)),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: _selectedRating,
                    dropdownColor: cardBg,
                    items: List.generate(5, (i) => i + 1)
                        .map(
                          (rating) => DropdownMenuItem(
                            value: rating,
                            child: Text(
                              '⭐ $rating',
                              style: const TextStyle(color: primaryGold),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedRating = value ?? 5);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reviewController,
                style: const TextStyle(color: lightGray),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tu reseña...',
                  hintStyle: const TextStyle(color: mediumGray),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: primaryGold),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: primaryGold)),
          ),
          TextButton(
            onPressed: () {
              final index = _reviews.indexWhere((r) => r.id == review.id);
              if (index != -1) {
                setState(() {
                  _reviews[index] = ProductReview(
                    id: review.id,
                    userId: review.userId,
                    userName: _userNameController.text,
                    productName: _selectedProduct,
                    rating: _selectedRating,
                    text: _reviewController.text,
                    createdAt: review.createdAt,
                    editedAt: DateTime.now(),
                    userAvatar: review.userAvatar,
                  );
                });
              }
              _saveReviews();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reseña actualizada')),
              );
            },
            child: const Text('Guardar', style: TextStyle(color: primaryGold)),
          ),
        ],
      ),
    );
  }

  void _deleteReview(ProductReview review) {
    if (review.userId != _currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo puedes eliminar tus propias reseñas'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        title: const Text(
          'Eliminar Reseña',
          style: TextStyle(color: primaryGold),
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta reseña?',
          style: TextStyle(color: lightGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: primaryGold)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _reviews.removeWhere((r) => r.id == review.id);
              });
              _saveReviews();
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Reseña eliminada')));
            },
            child: const Text('Eliminar', style: TextStyle(color: accentPink)),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWidget(String? avatarBase64, {double size = 40}) {
    if (avatarBase64 != null && avatarBase64.isNotEmpty) {
      try {
        final imageBytes = base64Decode(avatarBase64);
        return CircleAvatar(
          radius: size / 2,
          backgroundImage: MemoryImage(imageBytes),
          backgroundColor: primaryGold.withOpacity(0.3),
        );
      } catch (e) {
        return _buildDefaultAvatar(size);
      }
    }
    return _buildDefaultAvatar(size);
  }

  Widget _buildDefaultAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: primaryGold, width: 2),
        color: primaryGold.withOpacity(0.1),
      ),
      child: const Icon(Icons.person, color: primaryGold),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: const Text('⭐ Reseñas de Productos'),
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
        titleTextStyle: const TextStyle(
          color: primaryGold,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: Column(
        children: [
          // Formulario para agregar reseña
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: primaryGold, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Deja tu Reseña',
                          style: TextStyle(
                            color: primaryGold,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Column(
                            children: [
                              _buildAvatarWidget(_userAvatarBase64, size: 48),
                              const SizedBox(height: 4),
                              const Text(
                                'Foto',
                                style: TextStyle(
                                  color: primaryGold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _userNameController,
                      style: const TextStyle(color: lightGray),
                      decoration: InputDecoration(
                        hintText: 'Tu nombre',
                        hintStyle: const TextStyle(color: mediumGray),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: primaryGold,
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: _selectedProduct,
                      dropdownColor: cardBg,
                      isExpanded: true,
                      items: _availableProducts
                          .map(
                            (product) => DropdownMenuItem(
                              value: product,
                              child: Text(
                                product,
                                style: const TextStyle(color: primaryGold),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(
                          () =>
                              _selectedProduct = value ?? 'Labial Rojo Pasión',
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          'Rating:',
                          style: TextStyle(color: primaryGold),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<int>(
                          value: _selectedRating,
                          dropdownColor: cardBg,
                          items: List.generate(5, (i) => i + 1)
                              .map(
                                (rating) => DropdownMenuItem(
                                  value: rating,
                                  child: Text(
                                    '⭐ $rating / 5',
                                    style: const TextStyle(color: primaryGold),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedRating = value ?? 5);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _reviewController,
                      style: const TextStyle(color: lightGray),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Cuéntanos tu experiencia...',
                        hintStyle: const TextStyle(color: mediumGray),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: primaryGold,
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGold,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Publicar Reseña',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Lista de reseñas
          Expanded(
            child: _reviews.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        const Text(
                          'Sin reseñas aún',
                          style: TextStyle(color: primaryGold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '¡Sé el primero en dejar una reseña!',
                          style: TextStyle(color: mediumGray, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _reviews.length,
                    itemBuilder: (context, index) {
                      final review = _reviews[index];
                      final isOwner = review.userId == _currentUserId;

                      return Card(
                        color: cardBg,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isOwner
                                ? primaryGold
                                : primaryGold.withOpacity(0.3),
                            width: isOwner ? 1.5 : 0.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header con avatar, nombre, rating y acciones
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildAvatarWidget(
                                    review.userAvatar,
                                    size: 48,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review.userName,
                                          style: const TextStyle(
                                            color: primaryGold,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${List.filled(review.rating, '⭐').join()} • ${review.productName}',
                                          style: const TextStyle(
                                            color: mediumGray,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isOwner)
                                    PopupMenuButton(
                                      color: cardBg,
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          onTap: () => _editReview(review),
                                          child: const Text(
                                            '✏️ Editar',
                                            style: TextStyle(
                                              color: primaryGold,
                                            ),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          onTap: () => _deleteReview(review),
                                          child: const Text(
                                            '🗑️ Eliminar',
                                            style: TextStyle(color: accentPink),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Texto de la reseña
                              Text(
                                review.text,
                                style: const TextStyle(
                                  color: lightGray,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Fecha y estado de edición
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDate(review.createdAt),
                                    style: const TextStyle(
                                      color: mediumGray,
                                      fontSize: 10,
                                    ),
                                  ),
                                  if (review.editedAt != null)
                                    Text(
                                      'Editado',
                                      style: TextStyle(
                                        color: primaryGold.withOpacity(0.7),
                                        fontSize: 10,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Hace unos segundos';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _userNameController.dispose();
    super.dispose();
  }
}

// ==================== USER PROFILE PAGE ====================
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String? _profileAvatarBase64;
  late SharedPreferences _prefs;

  static const String _profileAvatarKey = 'user_profile_avatar';
  static const String _profileNameKey = 'user_profile_name';
  static const String _profileEmailKey = 'user_profile_email';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    _prefs = await SharedPreferences.getInstance();
    _profileAvatarBase64 = _prefs.getString(_profileAvatarKey);
    final name = _prefs.getString(_profileNameKey) ?? 'Usuario';
    final email = _prefs.getString(_profileEmailKey) ?? '';

    setState(() {
      _nameController.text = name;
      _emailController.text = email;
    });
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);

      setState(() {
        _profileAvatarBase64 = base64String;
      });

      await _prefs.setString(_profileAvatarKey, base64String);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil actualizada')),
      );
    }
  }

  Future<void> _saveProfileChanges() async {
    await _prefs.setString(_profileNameKey, _nameController.text);
    await _prefs.setString(_profileEmailKey, _emailController.text);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
  }

  Widget _buildProfileAvatar() {
    if (_profileAvatarBase64 != null && _profileAvatarBase64!.isNotEmpty) {
      try {
        final imageBytes = base64Decode(_profileAvatarBase64!);
        return CircleAvatar(
          radius: 60,
          backgroundImage: MemoryImage(imageBytes),
          backgroundColor: primaryGold.withOpacity(0.3),
        );
      } catch (e) {
        return _buildDefaultProfileAvatar();
      }
    }
    return _buildDefaultProfileAvatar();
  }

  Widget _buildDefaultProfileAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: primaryGold, width: 3),
        color: primaryGold.withOpacity(0.1),
      ),
      child: const Icon(Icons.person, color: primaryGold, size: 60),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: const Text('👤 Mi Perfil'),
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
        titleTextStyle: const TextStyle(
          color: primaryGold,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    _buildProfileAvatar(),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryGold,
                        border: Border.all(color: darkBg, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Nombre
              TextField(
                controller: _nameController,
                style: const TextStyle(color: lightGray),
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: const TextStyle(color: primaryGold),
                  prefixIcon: const Icon(Icons.person, color: primaryGold),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryGold),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryGold.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryGold, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Email
              TextField(
                controller: _emailController,
                style: const TextStyle(color: lightGray),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: primaryGold),
                  prefixIcon: const Icon(Icons.email, color: primaryGold),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryGold),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryGold.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryGold, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfileChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGold,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Guardar Cambios',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

// ==================== CHAT MESSAGE CLASS ====================
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// ==================== LIVE CHAT PAGE ====================
class LiveChatPage extends StatefulWidget {
  const LiveChatPage({Key? key}) : super(key: key);

  @override
  State<LiveChatPage> createState() => _LiveChatPageState();
}

class _LiveChatPageState extends State<LiveChatPage> {
  late TextEditingController _messageController;
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: '¡Hola! ¿Cómo te podemos ayudar hoy? 😊',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: _messageController.text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _messageController.clear();

      // Simular respuesta del soporte
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add(
            ChatMessage(
              text:
                  'Gracias por tu mensaje. Un especialista te responderá en breve 🎀',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: const Text('💬 Chat en Vivo'),
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
        titleTextStyle: const TextStyle(
          color: primaryGold,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildChatBubble(message);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: darkBg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: _sendMessage,
                  backgroundColor: primaryGold,
                  child: const Icon(Icons.send, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isUser ? primaryGold : cardBg,
          borderRadius: BorderRadius.circular(12),
          border: message.isUser
              ? null
              : Border.all(color: primaryGold.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.black : lightGray,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: message.isUser ? Colors.black54 : mediumGray,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
