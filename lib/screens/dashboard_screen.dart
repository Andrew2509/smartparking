import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/dashed_rect_painter.dart';
import 'location_view.dart';
import 'settings_screen.dart';
import 'team_pdf_view.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<ParkingSlot> _slots = [];
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _timer;
  final bool _isAutoRefresh = true;
  final int _refreshInterval = 3; // seconds
  int _currentNavIndex = 0;
  
  // Real-time API metrics
  int? _latencyMs;
  bool _isBackendOnline = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_isAutoRefresh) {
      _timer = Timer.periodic(Duration(seconds: _refreshInterval), (timer) {
        _fetchData(silent: true);
      });
    }
  }

  Future<void> _fetchData({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final stopwatch = Stopwatch()..start();
    try {
      final data = await ApiService.fetchParkingStatus();
      stopwatch.stop();
      if (mounted) {
        setState(() {
          _slots = data;
          _latencyMs = stopwatch.elapsedMilliseconds;
          _isBackendOnline = true;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      stopwatch.stop();
      if (mounted) {
        setState(() {
          _isBackendOnline = false;
          if (!silent) {
            _isLoading = false;
            _errorMessage = e.toString().replaceAll('Exception: ', '');
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  ParkingSlot? _getSlotData(int slotNumber) {
    try {
      return _slots.firstWhere((s) => s.slot == slotNumber);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dynamic Header based on active tab
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: _buildDynamicHeader(),
            ),

            // Dynamic Body
            Expanded(
              child: _buildActiveView(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildDynamicHeader() {
    return _buildTopHeaderForMonitoring();
  }

  Widget _buildActiveView() {
    if (_currentNavIndex == 1) {
      return LocationView(
        slots: _slots,
        latencyMs: _latencyMs,
      );
    } else if (_currentNavIndex == 2) {
      return TeamPdfView(
        activeNodesCount: _slots.length,
        isBackendOnline: _isBackendOnline,
      );
    }

    // Default: Monitoring View (Tab 0)
    int totalSlots = 4;
    int occupiedCount = _slots.where((s) => s.isOccupied).length;
    int availableCount = totalSlots - occupiedCount;

    return _isLoading && _slots.isEmpty
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
            ),
          )
        : _errorMessage != null && _slots.isEmpty
            ? _buildErrorState()
            : RefreshIndicator(
                onRefresh: () => _fetchData(silent: false),
                color: const Color(0xFF4F46E5),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Capacity Card
                        _buildCapacityBanner(),
                        const SizedBox(height: 20),

                        // Stats row (Available & Occupied)
                        _buildSummaryCards(availableCount, occupiedCount),
                        const SizedBox(height: 28),

                        // Parking Map Header
                        _buildParkingMapHeader(),
                        const SizedBox(height: 16),

                        // Parking Map Layout
                        _buildParkingLayoutMap(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              );
  }

  Widget _buildTopHeaderForMonitoring() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
                if (result == true) {
                  _fetchData();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF4F46E5),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ParkSmart v2.0',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'ESP32 NODE-01 ACTIVE',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: const Row(
                children: [
                  Text(
                    'ID',
                    style: TextStyle(
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    ' | ',
                    style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
                  ),
                  Text(
                    'EN',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none, color: Color(0xFF1E293B)),
                onPressed: () {},
                iconSize: 22,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCapacityBanner() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 16,
            bottom: -10,
            child: Opacity(
              opacity: 0.15,
              child: const Icon(
                Icons.directions_car,
                size: 150,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'TOTAL CAPACITY',
                  style: TextStyle(
                    color: Color(0xFFE0E7FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '4 Parking Slots',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sensors,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Simulasi Sensor Aktif',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(int available, int occupied) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.02),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'P',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  available.toString(),
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'AVAILABLE SLOTS',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.02),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.directions_car,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  occupied.toString(),
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'OCCUPIED SLOTS',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParkingMapHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Parking Map',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'Real-time',
            style: TextStyle(
              color: Color(0xFF4F46E5),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParkingLayoutMap() {
    final s1 = _getSlotData(1) ?? ParkingSlot(slot: 1, status: 'Terisi', distance: 12, updatedAt: DateTime.now());
    final s2 = _getSlotData(2) ?? ParkingSlot(slot: 2, status: 'Kosong', distance: 160, updatedAt: DateTime.now());
    final s3 = _getSlotData(3) ?? ParkingSlot(slot: 3, status: 'Kosong', distance: 160, updatedAt: DateTime.now());
    final s4 = _getSlotData(4) ?? ParkingSlot(slot: 4, status: 'Terisi', distance: 22, updatedAt: DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildMapSlot(s1, Alignment.topLeft),
                const SizedBox(height: 24),
                _buildMapSlot(s3, Alignment.bottomLeft),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 300,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          Expanded(
            child: Column(
              children: [
                _buildMapSlot(s2, Alignment.topRight),
                const SizedBox(height: 24),
                _buildMapSlot(s4, Alignment.bottomRight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSlot(ParkingSlot slot, Alignment labelAlignment) {
    final bool isOccupied = slot.isOccupied;
    final Color slotColor = isOccupied ? const Color(0xFFEF4444) : const Color(0xFF10B981);
    
    return AspectRatio(
      aspectRatio: 1.0,
      child: CustomPaint(
        painter: DashedRectPainter(
          color: slotColor,
          strokeWidth: 1.5,
          gap: 6.0,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Stack(
            children: [
              Align(
                alignment: labelAlignment,
                child: Text(
                  'P-0${slot.slot}',
                  style: TextStyle(
                    color: slotColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isOccupied) ...[
                      Icon(
                        Icons.directions_car_outlined,
                        color: slotColor,
                        size: 32,
                      ),
                      const SizedBox(height: 6),
                    ] else ...[
                      Text(
                        'FREE',
                        style: TextStyle(
                          color: slotColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: slotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${slot.distance} cm',
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
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
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4F46E5),
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(
                Icons.assessment_outlined,
                color: _currentNavIndex == 0 ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
              ),
            ),
            label: 'Monitoring',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(
                Icons.map_outlined,
                color: _currentNavIndex == 1 ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
              ),
            ),
            label: 'Location',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(
                Icons.group_outlined,
                color: _currentNavIndex == 2 ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
              ),
            ),
            label: 'Team & PDF',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Color(0xFFEF4444),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Gagal Terhubung ke Backend API',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? 'Terjadi kesalahan jaringan.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _fetchData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E293B),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
                if (result == true) {
                  _fetchData();
                }
              },
              icon: const Icon(Icons.settings),
              label: const Text('Buka Pengaturan API'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4F46E5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
