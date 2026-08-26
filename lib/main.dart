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
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  List<Map<String, dynamic>> _subscriptions = [];
  double _savedAmount = 0.0;
  
  late Timer _timer;
  String _currentTime = '';
  String _currentDate = '';
  bool _isWrappedReset = false;

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
    {
      'name': 'Reklam / Spam Numara',
      'phone': '+90 850 999 8877',
      'block': true,
      'mask': false,
    },
  ];

  final List<Map<String, dynamic>> _trackedSecurityNetwork = [
    {
      'name': 'Ayşin Erdal',
      'phone': '+90 532 555 4433',
      'status': 'Güvenlik Ağına Dahil (Onaylandı)',
      'isApproved': true,
      'distance': '350 Metre (Yakın Bölgede - Ev)',
      'location': 'Ev / İstanbul',
      'battery': '%84',
      'requestDate': '24.08.2026',
    },
    {
      'name': 'Ahmet Güvenilir',
      'phone': '+90 555 123 4567',
      'status': 'Onay Bekliyor (24 Saat İçinde İptal Olur)',
      'isApproved': false,
      'distance': 'Hesaplanıyor...',
      'location': 'Beklemede',
      'battery': '-',
      'requestDate': 'Bugün, 10:15',
    },
  ];

  String _maskName(String fullName) {
    List<String> parts = fullName.split(' ');
    List<String> maskedParts = [];

    for (var part in parts) {
      if (part.length <= 2) {
        maskedParts.add('**');
      } else {
        String first = part.substring(0, 2);
        String last = part.substring(part.length - 1);
        maskedParts.add('$first***$last');
      }
    }
    return maskedParts.join(' ');
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
    _updateDateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateDateTime());
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

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedSubs = prefs.getString('lifemetric_subs');
    final double? savedSavings = prefs.getDouble('lifemetric_savings');

    setState(() {
      _savedAmount = savedSavings ?? 0.0;
      if (savedSubs != null) {
        _subscriptions = List<Map<String, dynamic>>.from(json.decode(savedSubs));
      } else {
        _subscriptions = [
          {
            'id': '1',
            'title': 'Netflix',
            'category': 'Dijital Yayın',
            'cost': 199.99,
            'frequency': 'Hiç Kullanmadım',
            'isGhost': true,
            'period': 'Aylık',
          },
          {
            'id': '2',
            'title': 'Spotify',
            'category': 'Müzik & PodCast',
            'cost': 59.99,
            'frequency': 'Haftada Birkaç Gün',
            'isGhost': false,
            'period': 'Aylık',
          },
        ];
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lifemetric_subs', json.encode(_subscriptions));
    await prefs.setDouble('lifemetric_savings', _savedAmount);
  }

  void _addSubscription(String title, String category, double cost, String frequency, String? commitmentDate) {
    final bool isGhost = frequency == 'Seyrek' || frequency == 'Hiç Kullanmadım';
    final newSub = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'category': category,
      'cost': cost,
      'frequency': frequency,
      'isGhost': isGhost,
      'period': 'Aylık',
      if (commitmentDate != null && commitmentDate.isNotEmpty) 'commitmentWarning': commitmentDate,
    };

    setState(() {
      _subscriptions.add(newSub);
    });
    _saveData();
  }

  void _deleteSubscription(int index) {
    final sub = _subscriptions[index];
    final double annualSavings = (sub['cost'] as double) * 12;

    setState(() {
      _savedAmount += annualSavings;
      _subscriptions.removeAt(index);
    });
    _saveData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${sub['title']} iptal edildi! Yıllık ₺${annualSavings.toStringAsFixed(2)} tasarruf eklendi.'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  double get _totalPotentialSavings {
    double ghostMonthlyTotal = 0.0;
    for (var sub in _subscriptions) {
      if (sub['isGhost'] == true) {
        ghostMonthlyTotal += (sub['cost'] as double);
      }
    }
    return ghostMonthlyTotal * 12;
  }

  int get _ghostCount {
    return _subscriptions.where((sub) => sub['isGhost'] == true).length;
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
          IconButton(
            icon: Icon(Icons.add_circle, color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB), size: 26),
            onPressed: () => _showAddDialog(),
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
            Tab(icon: Icon(Icons.account_balance_wallet_outlined, size: 18), text: 'Abonelikler'),
            Tab(icon: Icon(Icons.bar_chart_rounded, size: 18), text: 'Hayatındaki Sayılar'),
            Tab(icon: Icon(Icons.security_rounded, size: 18), text: 'Çağrı Kalkanı'),
            Tab(icon: Icon(Icons.person_search_rounded, size: 18), text: 'Kişi Takibi & Güvenlik Ağı'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardView(isDark),
                _buildLifeWrappedView(isDark),
                _buildCallShieldView(isDark),
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
                    Text('Anlık konum, mesafe ve onaylı SMS yönetimi', style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600], fontSize: 11)),
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
              boxShadow: isDark ? [] : [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
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
                          Text(person['phone'], style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 22),
                      tooltip: 'Ağdan Çıkar',
                      onPressed: () {
                        setState(() {
                          _trackedSecurityNetwork.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kişi güvenlik ağından çıkarıldı.'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isApproved ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                    Text(
                      isApproved ? 'Konum: ${person['location']}' : 'Talep Tarihi: ${person['requestDate']}',
                      style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600]),
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Gönderilecek Onay SMS Metni:\n"LifeMetric Güvenlik Ağı kapsamında Kemal ERDAL sizi güvenlik ağına eklemek istiyor. Onay vermek için tıklayın: [Güvenli Onay Linki] (Onaylamazsanız bu talep 24 saat içinde otomatik iptal edilir.)"',
                style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Color(0xFF38BDF8)),
              ),
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
                  _trackedSecurityNetwork.add({
                    'name': nameController.text,
                    'phone': phoneController.text,
                    'status': 'Onay Bekliyor (24 Saat İçinde İptal Olur)',
                    'isApproved': false,
                    'distance': 'Hesaplanıyor...',
                    'location': 'Beklemede',
                    'battery': '-',
                    'requestDate': 'Bugün',
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Onay SMS\'i gönderildi! Karşı tarafın onayı bekleniyor.'),
                    backgroundColor: Color(0xFF10B981),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text('Davet Gönder & Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- ÇAĞRI KALKANI & REHBER YÖNETİMİ EKRANI (Ekleme, Silme ve Kutucuklu Yapı) ---
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
        const SizedBox(height: 16),
        const Text(
          'Rehberinizden eklediğiniz kişileri buradan yönetebilirsiniz. Hiçbir kutucuk seçilmezse normal çağrı alınır.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
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
              border: Border.all(
                color: contact['block'] 
                    ? Colors.red.withOpacity(0.5) 
                    : (contact['mask'] ? Colors.amber.withOpacity(0.5) : const Color(0xFF38BDF8).withOpacity(0.3)),
                width: 1.5,
              ),
              boxShadow: isDark ? [] : [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: contact['block'] 
                          ? Colors.red.withOpacity(0.2) 
                          : (contact['mask'] ? Colors.amber.withOpacity(0.2) : const Color(0xFF38BDF8).withOpacity(0.2)),
                      child: Icon(
                        contact['block'] ? Icons.block : (contact['mask'] ? Icons.lock_person : Icons.person),
                        color: contact['block'] ? Colors.red : (contact['mask'] ? Colors.amber : const Color(0xFF38BDF8)),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            contact['phone'],
                            style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // ÇÖP KUTUSU SİLME BUTONU
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 22),
                      tooltip: 'Kişiyi Kaldır',
                      onPressed: () {
                        setState(() {
                          _contactsAnalysis.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kişi çağrı kalkanından silindi.'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const Divider(height: 20, color: Colors.white10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1. Seçenek: Çağrı Engelleme Kutucuğu
                    Row(
                      children: [
                        Checkbox(
                          value: contact['block'],
                          activeColor: Colors.redAccent,
                          onChanged: (bool? value) {
                            setState(() {
                              contact['block'] = value ?? false;
                              if (contact['block']) contact['mask'] = false; // Çakışmayı önle
                            });
                          },
                        ),
                        Text(
                          'Çağrı Engelleme',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    // 2. Seçenek: Maskeli Çağrı Kutucuğu
                    Row(
                      children: [
                        Checkbox(
                          value: contact['mask'],
                          activeColor: Colors.amber,
                          onChanged: (bool? value) {
                            setState(() {
                              contact['mask'] = value ?? false;
                              if (contact['mask']) contact['block'] = false; // Çakışmayı önle
                            });
                          },
                        ),
                        Text(
                          'Maskeli Çağrı',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kişi başarıyla kalkan listesine eklendi!'),
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

  Widget _buildDashboardView(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                ? [const Color(0xFF1E3A8A), const Color(0xFF2563EB), const Color(0xFF1D4ED8)]
                : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('POTANSİYEL YILLIK TASARRUF', style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Text('₺${_totalPotentialSavings.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFFACC15), size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text('$_ghostCount Hayalet Abonelik Tespit Edildi', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              if (_savedAmount > 0) ...[
                const Divider(color: Colors.white24, height: 24),
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Color(0xFF34D399), size: 18),
                    const SizedBox(width: 8),
                    Text('Kazanılan Net Tasarruf: ₺${_savedAmount.toStringAsFixed(2)}',
                        style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Aktif Ödemeler ve Faturalar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 12),
        if (_subscriptions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: Text('Henüz abonelik eklenmedi.', style: TextStyle(color: Color(0xFF64748B)))),
          )
        else
          ..._subscriptions.asMap().entries.map((entry) => _buildSubscriptionTile(entry.value, entry.key, isDark)).toList(),
      ],
    );
  }

  Widget _buildSubscriptionTile(Map<String, dynamic> sub, int index, bool isDark) {
    final bool isGhost = sub['isGhost'] ?? false;
    final String? warning = sub['commitmentWarning'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isGhost ? const Color(0xFFEF4444).withOpacity(0.5) : (isDark ? const Color(0xFF1F2937) : Colors.grey[300]!), width: 1.5),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: isGhost ? const Color(0xFFEF4444).withOpacity(0.2) : (isDark ? const Color(0xFF2563EB).withOpacity(0.2) : Colors.blue.withOpacity(0.1)),
          child: Icon(
            isGhost ? Icons.visibility_off : Icons.receipt_long,
            color: isGhost ? const Color(0xFFEF4444) : (isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB)),
          ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(sub['title'], style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87, fontSize: 15))),
            if (isGhost)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(6)),
                child: const Text('HAYALET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${sub['category']} • Sıklık: ${sub['frequency']}', style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600], fontSize: 12)),
            if (warning != null) ...[
              const SizedBox(height: 2),
              Text('⚠️ Taahhüt: $warning', style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₺${sub['cost']}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                Text(sub['period'], style: TextStyle(color: isDark ? const Color(0xFF6B7280) : Colors.grey[500], fontSize: 11)),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 22),
              onPressed: () => _deleteSubscription(index),
            ),
          ],
        ),
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
                  const SizedBox(height: 2),
                  Text('24 saatlik döngünüz ve yaşam analitiği verileri.', style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFEF4444)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Sıfırla', style: TextStyle(fontSize: 12)),
              onPressed: () {
                setState(() {
                  _isWrappedReset = !_isWrappedReset;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hayatındaki Sayılar verileri başarıyla sıfırlandı/yenilendi!'),
                    backgroundColor: Color(0xFF10B981),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        if (_isWrappedReset)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Text(
              'Tüm veriler sıfırlandı. Yeni verilerin derlenmesi bekleniyor...',
              style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600], fontStyle: FontStyle.italic),
            ),
          )
        else ...[
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
          _buildWrappedCard(
            title: 'Sosyal & İletişim Detayları',
            mainStat: '184 Saat Toplam Etkileşim',
            icon: Icons.forum_rounded,
            color: const Color(0xFF10B981),
            isDark: isDark,
            child: Column(
              children: [
                _buildDetailRow(Icons.phone, 'Telefon Görüşmeleri', '42 Sa (En Çok: Eşim - 412 Arama)', isDark),
                _buildDetailRow(Icons.chat_bubble_outline, 'WhatsApp', '86 Sa (12.450 Mesaj, 32 Grup)', isDark),
                _buildDetailRow(Icons.sms_outlined, 'SMS / Metin Mesajı', '12 Sa (Çoğunluk: Doğrulama Kodu & Banka)', isDark),
                _buildDetailRow(Icons.share, 'Sosyal Medya DM', '44 Sa (Instagram & LinkedIn Mesajları)', isDark),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWrappedCard({
    required String title,
    required String mainStat,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                    const SizedBox(height: 2),
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
            const Text('LifeMetric v1.0.0', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
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

  void _showAddDialog() {
    final titleController = TextEditingController();
    final costController = TextEditingController();
    final commitmentController = TextEditingController();
    String category = 'Dijital Yayın';
    String frequency = 'Haftada Birkaç Gün';
    final isDark = widget.isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF161E2E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Yeni Abonelik / Fatura Ekle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(labelText: 'Servis / Fatura Adı (Örn: Netflix, Elektrik)', labelStyle: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600])),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: category,
                          dropdownColor: isDark ? const Color(0xFF161E2E) : Colors.white,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
                          decoration: InputDecoration(labelText: 'Kategori', labelStyle: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600])),
                          items: ['Dijital Yayın', 'Müşteri & Kurum', 'Temel Faturalar', 'İletişim & Ev', 'Yazılım & Web', 'Diğer']
                              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                              .toList(),
                          onChanged: (val) => setModalState(() => category = val!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: costController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(labelText: 'Aylık Tutar (TL)', labelStyle: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600])),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: frequency,
                    dropdownColor: isDark ? const Color(0xFF161E2E) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
                    decoration: InputDecoration(labelText: 'Kullanım Sıklığı', labelStyle: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600])),
                    items: ['Her Gün', 'Haftada Birkaç Gün', 'Ayda 1-2 Kez', 'Seyrek', 'Hiç Kullanmadım']
                        .map((freq) => DropdownMenuItem(value: freq, child: Text(freq)))
                        .toList(),
                    onChanged: (val) => setModalState(() => frequency = val!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commitmentController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(labelText: 'Taahhüt Uyarısı (Opsiyonel - Örn: 14 Gün Kaldı)', labelStyle: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600])),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                      onPressed: () {
                        if (titleController.text.isNotEmpty && costController.text.isNotEmpty) {
                          double? cost = double.tryParse(costController.text);
                          if (cost != null) {
                            _addSubscription(
                              titleController.text,
                              category,
                              cost,
                              frequency,
                              commitmentController.text,
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: const Text('Aboneliği Kaydet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}