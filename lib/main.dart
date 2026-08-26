/*
================================================================================
                    TELİF HAKKI VE MÜLKİYET BEYANI
================================================================================
İşbu yazılım ("LifeMetric" uygulaması), veritabanı mimarisi, kaynak kodları, 
arayüz tasarımları, grafik materyalleri, marka kimliği, sloganları ("Fark Et, 
Tasarruf Et, Yaşa.") ve ilgili tüm dokümantasyonun fikri ve sınai mülkiyet hakları, 
geliştirme ve yayılma yetkileri tamamen Kemal ERDAL'a aittir.

Proje Adı         : LifeMetric
Slogan           : Fark Et, Tasarruf Et, Yaşa.
Geliştirici & Mülk Sahibi : Kemal ERDAL
Telif Yılı       : 2026
© 2026 Kemal ERDAL. Tüm Hakları Saklıdır. (All Rights Reserved)
================================================================================
*/

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCtUQEIoAkHitsEYCo-EK218rNqgLC9XDo",
        appId: "1:630275962648:web:654f376e1ad93dec93106d",
        messagingSenderId: "630275962648",
        projectId: "lifemetricapp",
        storageBucket: "lifemetricapp.firebasestorage.app",
        databaseURL: "https://lifemetricapp-default-rtdb.firebaseio.com",
      ),
    );
  } catch (e) {}

  runApp(const LifeMetricApp());
}

class LifeMetricApp extends StatefulWidget {
  const LifeMetricApp({super.key});

  @override
  State<LifeMetricApp> createState() => _LifeMetricAppState();
}

class _LifeMetricAppState extends State<LifeMetricApp> {
  bool _isDarkMode = true;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeMetric',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        primaryColor: const Color(0xFF2563EB),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2563EB),
          secondary: Color(0xFF10B981),
          surface: Colors.white,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
        primaryColor: const Color(0xFF3B82F6),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF161E2E),
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(onToggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({super.key, required this.onToggleTheme, required this.isDarkMode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  late Timer _timer;
  String _currentTime = '';
  String _currentDate = '';
  bool _isWrappedReset = false;

  // Çağrı Kalkanı Listesi
  final List<Map<String, dynamic>> _contactsAnalysis = [
    {
      'name': 'Ayşin Erdal (Eşim)',
      'phone': '+90 532 555 4433',
      'block': false,
      'mask': false,
    },
    {
      'name': 'Abim',
      'phone': '+90 533 222 1100',
      'block': false,
      'mask': false,
    },
  ];

  // Akıllı SMS & Bahis Kalkanı Kuralları
  final List<Map<String, dynamic>> _smsRules = [
    {
      'pattern': '0850',
      'type': 'Numara Öneki (0850)',
      'isActive': true,
      'description': 'Tüm 0850 ile başlayan aramalar ve SMSler engellenir.',
    },
    {
      'pattern': 'bahis',
      'type': 'İçerik Kelimesi',
      'isActive': true,
      'description': 'İçinde "bahis" geçen mesajlar otomatik bloklanır.',
    },
    {
      'pattern': 'casino',
      'type': 'İçerik Kelimesi',
      'isActive': true,
      'description': 'İçinde "casino" veya "slot" geçen mesajlar engellenir.',
    },
    {
      'pattern': 'bonus',
      'type': 'İçerik Kelimesi',
      'isActive': true,
      'description': 'Yatırım/bonus teklif eden dolandırıcılık SMSleri filtrelenir.',
    },
  ];

  // Gelen SMS Kurum / Kaynak İstatistikleri (Günlük Sayaç)
  final List<Map<String, dynamic>> _smsSourceStats = [
    {'source': 'Trendyol', 'count': 4, 'category': 'E-Ticaret', 'icon': Icons.shopping_bag_rounded, 'color': Colors.orange},
    {'source': 'Yapı Kredi', 'count': 3, 'category': 'Bankacılık', 'icon': Icons.account_balance_rounded, 'color': Colors.blue},
    {'source': 'Garanti BBVA', 'count': 2, 'category': 'Bankacılık', 'icon': Icons.credit_card_rounded, 'color': Colors.green},
    {'source': 'Hopi', 'count': 2, 'category': 'Kampanya / Alışveriş', 'icon': Icons.local_offer_rounded, 'color': Colors.purple},
    {'source': 'Getir', 'count': 1, 'category': 'Hızlı Teslimat', 'icon': Icons.delivery_dining_rounded, 'color': Colors.amber},
    {'source': '0850 (Engellenen Spam)', 'count': 6, 'category': 'Spam / Bahis', 'icon': Icons.block_rounded, 'color': Colors.red},
  ];

  // Güvenlik Ağı Listesi
  final List<Map<String, dynamic>> _trackedSecurityNetwork = [
    {
      'name': 'Ayşin Erdal',
      'phone': '+90 532 555 4433',
      'code': '9421',
      'status': 'Güvenlik Ağına Dahil (Onaylandı)',
      'isApproved': true,
      'distance': '350 Metre (Yakın Bölgede - Ev)',
      'location': 'Ev / İstanbul',
      'battery': '%84',
      'requestDate': '24.08.2026',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _updateDateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateDateTime());
    
    _processIncomingUrlApproval();
    _listenToCloudDatabase();
  }

  void _processIncomingUrlApproval() {
    try {
      final Uri uri = Uri.base;
      String? code = uri.queryParameters['onayKodu'];
      if (code != null) {
        FirebaseDatabase.instance.ref('approvals/$code').set({
          'isApproved': true,
          'timestamp': ServerValue.timestamp,
        });
      }
    } catch (e) {}
  }

  void _listenToCloudDatabase() {
    try {
      final ref = FirebaseDatabase.instance.ref('approvals');
      ref.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null && mounted) {
          setState(() {
            data.forEach((codeKey, value) {
              bool approved = value['isApproved'] ?? false;
              if (approved) {
                for (var person in _trackedSecurityNetwork) {
                  if (person['code'] == codeKey && !person['isApproved']) {
                    person['isApproved'] = true;
                    person['status'] = 'Güvenlik Ağına Dahil (Onaylandı)';
                    person['location'] = 'Konum Paylaşılıyor';
                    person['battery'] = '%92';
                    person['distance'] = '95 Metre (Yakında)';
                  }
                }
              }
            });
          });
        }
      });
    } catch (e) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      _currentDate = "${now.day}.${now.month}.${now.year}";
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
        elevation: 4,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LifeMetric', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: isDark ? Colors.white : Colors.black87, letterSpacing: 0.5)),
                Text('Fark Et, Tasarruf Et, Yaşa.', style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600])),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_currentTime, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB))),
                  Text(_currentDate, style: TextStyle(fontSize: 9, color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: isDark ? Colors.amber : Colors.indigo, size: 22),
            onPressed: widget.onToggleTheme,
            tooltip: 'Tema Değiştir (Gece/Gündüz)',
          ),
          IconButton(
            icon: Icon(Icons.verified_user_outlined, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), size: 22),
            onPressed: () => _showCopyrightDialog(),
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB),
          indicatorWeight: 3,
          labelColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB),
          unselectedLabelColor: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600],
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart_rounded, size: 18), text: 'Hayatındaki Sayılar'),
            Tab(icon: Icon(Icons.security_rounded, size: 18), text: 'Çağrı Kalkanı'),
            Tab(icon: Icon(Icons.sms_failed_rounded, size: 18), text: 'Akıllı SMS & Kurum Analitiği'),
            Tab(icon: Icon(Icons.person_search_rounded, size: 18), text: 'Güvenlik Ağı'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLifeWrappedView(isDark),
                _buildCallShieldView(isDark),
                _buildSmsShieldView(isDark),
                _buildTrackedNetworkView(isDark),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111827) : Colors.white,
              border: Border(top: BorderSide(color: isDark ? const Color(0xFF1F2937) : Colors.grey[300]!, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Developed by Kemal ERDAL',
                  style: TextStyle(color: Color(0xFF60A5FA), fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Text(
                  '© 2026 LifeMetric. Tüm Hakları Saklıdır.',
                  style: TextStyle(color: isDark ? const Color(0xFF6B7280) : Colors.grey[600], fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- AKILLI SMS & KURUM ANALİTİĞİ EKRANI ---
  Widget _buildSmsShieldView(bool isDark) {
    int totalSmsToday = _smsSourceStats.fold(0, (sum, item) => sum + (item['count'] as int));

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_rounded, color: Color(0xFF38BDF8), size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gelen SMS & Kurum Analitiği', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    Text('Bugün toplam $totalSmsToday adet mesaj alındı / filtrelendi', style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600], fontSize: 11)),
                  ],
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
              icon: const Icon(Icons.add_chart_rounded, size: 16, color: Colors.white),
              label: const Text('Kurum Ekle', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () => _showAddSmsSourceDialog(isDark),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Özet Kartı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark ? [const Color(0xFF1E3A8A), const Color(0xFF111827)] : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('GÜNLÜK TOPLAM MESAJ', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text('$totalSmsToday Adet', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                ],
              ),
              const Icon(Icons.mark_email_read_rounded, color: Colors.white70, size: 36),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        Text('Kurum / Kaynak Bazlı Günlük Dağılım', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.grey[800])),
        const SizedBox(height: 10),

        ..._smsSourceStats.asMap().entries.map((entry) {
          int index = entry.key;
          var stat = entry.value;
          String sourceName = stat['source'];
          int count = stat['count'];
          String category = stat['category'];
          IconData iconData = stat['icon'];
          Color color = stat['color'];

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161E2E) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.3), width: 1.2),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(iconData, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sourceName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
                      const SizedBox(height: 2),
                      Text(category, style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600], fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count Adet',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 18),
                  onPressed: () {
                    setState(() {
                      _smsSourceStats.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        }).toList(),

        const SizedBox(height: 20),
        const Text('SMS Engelleme Kuralları (Bahis & Spam)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 10),
        ..._smsRules.map((rule) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161E2E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.block, color: Colors.redAccent, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('"${rule['pattern']}" (${rule['type']})', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
                ),
                Text(rule['isActive'] ? 'Aktif' : 'Pasif', style: TextStyle(fontSize: 11, color: rule['isActive'] ? Colors.green : Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  void _showAddSmsSourceDialog(bool isDark) {
    final nameController = TextEditingController();
    final countController = TextEditingController(text: '1');
    final categoryController = TextEditingController(text: 'Genel Kurum');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161E2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Yeni Kurum / SMS Kaynağı Ekle', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(labelText: 'Kurum Adı (Örn: Garanti, Hepsiburada)', labelStyle: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600])),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: countController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(labelText: 'Gelen SMS Adedi', labelStyle: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600])),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: categoryController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(labelText: 'Kategori (Örn: Bankacılık, E-Ticaret)', labelStyle: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600])),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _smsSourceStats.add({
                    'source': nameController.text.trim(),
                    'count': int.tryParse(countController.text) ?? 1,
                    'category': categoryController.text.trim(),
                    'icon': Icons.business_rounded,
                    'color': Colors.indigo,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kurum istatistiği başarıyla eklendi!'),
                    backgroundColor: Color(0xFF10B981),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Listeye Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- DİĞER EKRANLAR (Güvenlik Ağı, Çağrı Kalkanı, Life Wrapped) ---
  Widget _buildTrackedNetworkView(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: Color(0xFF38BDF8), size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Güvenlik Ağı & Mesafe Takibi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    Text('Firebase Bulut Senkronizasyonlu Canlı Takip', style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600], fontSize: 11)),
                  ],
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
              icon: const Icon(Icons.person_add_alt_1, size: 16, color: Colors.white),
              label: const Text('Yeni Kişi Ekle', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () => _showAddTrackedPersonDialog(isDark),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ..._trackedSecurityNetwork.asMap().entries.map((entry) {
          int index = entry.key;
          var person = entry.value;
          bool isApproved = person['isApproved'];
          String code = person['code'] ?? '0000';

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161E2E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isApproved ? const Color(0xFF10B981).withOpacity(0.5) : const Color(0xFFF59E0B).withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: isApproved ? const Color(0xFF10B981).withOpacity(0.2) : const Color(0xFFF59E0B).withOpacity(0.2),
                      child: Icon(
                        isApproved ? Icons.security : Icons.hourglass_top_rounded,
                        color: isApproved ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(person['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
                          const SizedBox(height: 2),
                          Text('${person['phone']} • Kod: $code', style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 22),
                      onPressed: () {
                        setState(() {
                          _trackedSecurityNetwork.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (!isApproved)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF59E0B))),
                        SizedBox(width: 10),
                        Text(
                          '⏳ Karşı Tarafın Onayı Bekleniyor (Bulut Senkronize)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFFF59E0B)),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                Divider(color: isDark ? Colors.white10 : Colors.grey[200], height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.near_me_rounded, size: 16, color: Color(0xFF38BDF8)),
                        const SizedBox(width: 6),
                        Text('Mesafe: ', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600])),
                        Text(person['distance'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                      ],
                    ),
                    if (isApproved)
                      Row(
                        children: [
                          const Icon(Icons.battery_charging_full, size: 16, color: Color(0xFF10B981)),
                          const SizedBox(width: 4),
                          Text(person['battery'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isApproved ? const Color(0xFF10B981).withOpacity(0.15) : const Color(0xFFF59E0B).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        person['status'],
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isApproved ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
                      ),
                    ),
                    Text(isApproved ? 'Konum: ${person['location']}' : 'Talep: ${person['requestDate']}', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600])),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  void _showAddTrackedPersonDialog(bool isDark) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161E2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Güvenlik Ağına Kişi Ekle', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(labelText: 'Kişi Adı', labelStyle: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600])),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(labelText: 'Telefon Numarası (+90 ...)', labelStyle: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600])),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
            onPressed: () async {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                String phone = phoneController.text.trim();
                String personName = nameController.text.trim();
                String randomCode = (1000 + Random().nextInt(9000)).toString();
                
                String message = "LifeMetric Güvenlik Ağı: $personName, davetlisiniz. Onaylamak için tıklayın: https://kemalerdal1980-creator.github.io/lifemetric/?onayKodu=$randomCode";
                final Uri smsUri = Uri.parse('sms:$phone?body=${Uri.encodeComponent(message)}');

                try {
                  if (await canLaunchUrl(smsUri)) {
                    await launchUrl(smsUri);
                  } else {
                    await launchUrl(smsUri, mode: LaunchMode.externalApplication);
                  }
                } catch (e) {}

                setState(() {
                  _trackedSecurityNetwork.add({
                    'name': personName,
                    'phone': phone,
                    'code': randomCode,
                    'status': 'Onay Bekliyor (Bulut Senkronize)',
                    'isApproved': false,
                    'distance': 'Beklemede...',
                    'location': 'Beklemede',
                    'battery': '-',
                    'requestDate': 'Bugün',
                  });
                });

                Navigator.pop(context);
              }
            },
            child: const Text('SMS Uygulamasını Aç & Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCallShieldView(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.shield_rounded, color: Color(0xFF38BDF8), size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gizlilik & Çağrı Kalkanı', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    Text('Rehberden numara seç, engelle veya maskele', style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600], fontSize: 11)),
                  ],
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
              icon: const Icon(Icons.person_add, size: 16, color: Colors.white),
              label: const Text('Rehberden Ekle', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () => _showAddCallShieldContactDialog(isDark),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ..._contactsAnalysis.asMap().entries.map((entry) {
          int index = entry.key;
          var contact = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161E2E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF38BDF8).withOpacity(0.2),
                      child: const Icon(Icons.person, color: Color(0xFF38BDF8)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(contact['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
                          Text(contact['phone'], style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 22),
                      onPressed: () {
                        setState(() {
                          _contactsAnalysis.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
                const Divider(height: 20, color: Colors.white10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: contact['block'],
                          activeColor: Colors.redAccent,
                          onChanged: (bool? value) {
                            setState(() {
                              contact['block'] = value ?? false;
                              if (contact['block']) contact['mask'] = false;
                            });
                          },
                        ),
                        Text('Çağrı Engelleme', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: contact['mask'],
                          activeColor: Colors.amber,
                          onChanged: (bool? value) {
                            setState(() {
                              contact['mask'] = value ?? false;
                              if (contact['mask']) contact['block'] = false;
                            });
                          },
                        ),
                        Text('Maskeli Çağrı', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  void _showAddCallShieldContactDialog(bool isDark) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161E2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Rehberden Kişi Ekle', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(labelText: 'Kişi Adı / Ünvanı', labelStyle: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600])),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(labelText: 'Telefon Numarası (+90 ...)', labelStyle: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600])),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
            onPressed: () {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                setState(() {
                  _contactsAnalysis.add({
                    'name': nameController.text,
                    'phone': phoneController.text,
                    'block': false,
                    'mask': false,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Listeye Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildLifeWrappedView(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hayatındaki Sayılar (Life Wrapped)', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  Text('24 saatlik döngünüz ve yaşam analitiği verileri.', style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFEF4444), side: const BorderSide(color: Color(0xFFEF4444))),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Sıfırla', style: TextStyle(fontSize: 12)),
              onPressed: () {
                setState(() {
                  _isWrappedReset = !_isWrappedReset;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_isWrappedReset)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Text('Tüm veriler sıfırlandı. Yeni verilerin derlenmesi bekleniyor...', style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600], fontStyle: FontStyle.italic)),
          )
        else
          _buildWrappedCard(
            title: 'Günün Özeti (24 Saatlik Zaman Dağılımı)',
            mainStat: '24 Saat / Tam Gün Dağılımı',
            icon: Icons.access_time_filled_rounded,
            color: const Color(0xFF38BDF8),
            isDark: isDark,
            child: Column(
              children: [
                _buildDetailRow(Icons.nightlight_round, 'Uyku', '7.5 Saat (%31)', isDark),
                _buildDetailRow(Icons.phone_in_talk, 'Telefon Görüşmeleri', '45 Dakika (%3)', isDark),
                _buildDetailRow(Icons.chat_bubble, 'WhatsApp & Mesajlaşma', '1.5 Saat (%6)', isDark),
                _buildDetailRow(Icons.public, 'Sosyal Medya (Instagram vb.)', '2 Saat (%8)', isDark),
                _buildDetailRow(Icons.shopping_bag_outlined, 'Alışveriş & Dolap App', '45 Dakika (%3)', isDark),
                _buildDetailRow(Icons.directions_bus, 'Yol & Ulaşım', '1.5 Saat (%6)', isDark),
                _buildDetailRow(Icons.work_outline, 'Çalışma / Ofis & Diğer', '10 Saat (%43)', isDark),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildWrappedCard({required String title, required String mainStat, required IconData icon, required Color color, required bool isDark, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 22, backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color, size: 24)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                    Text(mainStat, style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: isDark ? Colors.white10 : Colors.grey[200], height: 1),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 16, color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600]),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showCopyrightDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? const Color(0xFF161E2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hakkında & Telif Hakları', style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('LifeMetric v2.1.0', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Fark Et, Tasarruf Et, Yaşa.', style: TextStyle(color: widget.isDarkMode ? const Color(0xFF9CA3AF) : Colors.grey[600], fontSize: 12)),
            const Divider(color: Colors.white24, height: 20),
            Text('Geliştirici & Eser Sahibi:', style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.grey[700], fontSize: 12)),
            const Text('Kemal ERDAL', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Text(
              'Bu yazılımın tüm telif, patent, marka ve dağıtım hakları 5846 Sayılı Kanun kapsamında Kemal ERDAL\'a aittir.\n\n© 2026 Kemal ERDAL. Tüm Hakları Saklıdır.',
              style: TextStyle(color: widget.isDarkMode ? const Color(0xFF9CA3AF) : Colors.grey[600], fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat', style: TextStyle(color: Color(0xFF38BDF8))),
          ),
        ],
      ),
    );
  }
}