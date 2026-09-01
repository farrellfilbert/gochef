import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_chef_app/theme/app_colors.dart';
import 'package:go_chef_app/theme/app_text_styles.dart';
import 'package:go_chef_app/services/api_service.dart';
import 'package:go_chef_app/services/support_helper.dart';
import 'package:go_chef_app/main.dart';
import 'order_review_screen.dart';
import 'dart:html' as html;
import 'package:go_chef_app/models/order_model.dart';
import '../../widgets/rate_order_dialog.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String kitchenId;
  final String kitchenName;
  final double totalAmount;
  final int itemsCount;
  final String kitchenAvatar;
  final bool fromCheckout;
  final String initialStatus;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.kitchenId,
    required this.kitchenName,
    required this.totalAmount,
    required this.itemsCount,
    required this.kitchenAvatar,
    this.fromCheckout = false,
    this.initialStatus = 'Active',
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final MapController _mapController = MapController();
  bool isDetailsExpanded = false;
  late String _currentStatus;
  List<OrderItemModel>? _orderItems;
  bool _isLoadingItems = true;
  String _orderType = 'delivery';
  String _dineInDate = '';
  String _deliveryAddress = '';
  String? _uberTrackingUrl;
  Timer? _timer;

  // Map coordinates
  LatLng _kitchenLocation = const LatLng(34.1722, -118.3765); // North Hollywood / Kitchen
  LatLng _customerLocation = const LatLng(34.1520, -118.4280); // Customer Dropoff
  LatLng _courierLocation = const LatLng(34.1610, -118.4020); // Live Courier point

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.initialStatus;
    _fetchOrderDetails();
    _startPolling();
    _initCoordinates();
  }

  void _initCoordinates() {
    final kId = int.tryParse(widget.kitchenId) ?? 1;
    // Generate deterministic realistic coordinates based on kitchen ID
    final baseLat = 34.1722 + ((kId % 5) * 0.008);
    final baseLng = -118.3765 - ((kId % 4) * 0.009);
    _kitchenLocation = LatLng(baseLat, baseLng);
    _customerLocation = LatLng(baseLat - 0.022, baseLng - 0.035);
    _updateCourierPosition();
  }

  void _updateCourierPosition() {
    final status = _currentStatus.toLowerCase();
    if (status == 'on_the_way') {
      // Courier is moving halfway between kitchen and customer
      _courierLocation = LatLng(
        (_kitchenLocation.latitude * 0.35) + (_customerLocation.latitude * 0.65),
        (_kitchenLocation.longitude * 0.35) + (_customerLocation.longitude * 0.65),
      );
    } else if (status == 'delivered' || status == 'completed') {
      _courierLocation = _customerLocation;
    } else {
      _courierLocation = _kitchenLocation;
    }
  }

  Future<void> _fetchOrderDetails() async {
    try {
      final orders = await ApiService.getOrders();
      final order = orders.firstWhere((o) => o.id == widget.orderId);
      if (mounted) {
        setState(() {
          _orderItems = order.items;
          _orderType = order.orderType;
          _dineInDate = order.dineInDate ?? '';
          _deliveryAddress = order.deliveryAddress ?? '';
          _uberTrackingUrl = order.uberTrackingUrl;
          _isLoadingItems = false;
        });
        _updateCourierPosition();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingItems = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool _isAutoArriveTriggered = false;

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchCurrentStatus();
    });
  }

  Future<void> _fetchCurrentStatus() async {
    try {
      final orders = await ApiService.getOrders();
      final currentOrder = orders.firstWhere((o) => o.id == widget.orderId);
      if (mounted && (_currentStatus != currentOrder.status || _orderType != currentOrder.orderType)) {
        setState(() {
          _currentStatus = currentOrder.status;
          _orderType = currentOrder.orderType;
          _dineInDate = currentOrder.dineInDate ?? '';
          _deliveryAddress = currentOrder.deliveryAddress ?? '';
          _uberTrackingUrl = currentOrder.uberTrackingUrl;
        });
        _updateCourierPosition();
        
        if (_currentStatus == 'Completed' && !_isAutoArriveTriggered) {
          _isAutoArriveTriggered = true;
          Future.delayed(const Duration(seconds: 15), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderReviewScreen(
                    orderId: widget.orderId,
                    kitchenId: widget.kitchenId,
                    kitchenName: widget.kitchenName,
                  ),
                ),
              );
            }
          });
        }
      }
    } catch (e) {
      // ignore errors
    }
  }

  void _fitMapBounds() {
    final centerLat = (_kitchenLocation.latitude + _customerLocation.latitude) / 2;
    final centerLng = (_kitchenLocation.longitude + _customerLocation.longitude) / 2;
    _mapController.move(LatLng(centerLat, centerLng), 13.0);
  }

  @override
  Widget build(BuildContext context) {
    bool isOutForDelivery = ['on_the_way', 'delivered', 'Completed'].contains(_currentStatus);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (widget.fromCheckout) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainNavigation()),
                (Route<dynamic> route) => false,
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text('Track Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent, color: Colors.orangeAccent),
            tooltip: 'Live Chat Support',
            onPressed: () => SupportHelper.openLiveSupportChat(context, orderId: widget.orderId),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _fetchCurrentStatus();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing live status...'), duration: Duration(seconds: 1)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. IN-APP INTERACTIVE DELIVERY MAP VIEW
          SizedBox(
            height: 280,
            width: double.infinity,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      (_kitchenLocation.latitude + _customerLocation.latitude) / 2,
                      (_kitchenLocation.longitude + _customerLocation.longitude) / 2,
                    ),
                    initialZoom: 13.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.drag |
                          InteractiveFlag.pinchZoom |
                          InteractiveFlag.doubleTapZoom,
                    ),
                  ),
                  children: [
                    // Satellite + Road Tiles Layer
                    TileLayer(
                      urlTemplate: 'https://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
                      subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                      userAgentPackageName: 'com.astroboomin.gochef',
                    ),
                    TileLayer(
                      urlTemplate: 'https://{s}.google.com/vt/lyrs=h&x={x}&y={y}&z={z}',
                      subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                      userAgentPackageName: 'com.astroboomin.gochef',
                    ),

                    // Neon Fuchsia Route Polyline
                    PolylineLayer(
                      polylines: [
                        // Glow shadow
                        Polyline(
                          points: [
                            _kitchenLocation,
                            LatLng(
                              (_kitchenLocation.latitude * 0.6) + (_customerLocation.latitude * 0.4),
                              (_kitchenLocation.longitude * 0.4) + (_customerLocation.longitude * 0.6),
                            ),
                            _customerLocation,
                          ],
                          strokeWidth: 7.0,
                          color: const Color(0xFFEB1E8C).withValues(alpha: 0.4),
                        ),
                        // Main path line
                        Polyline(
                          points: [
                            _kitchenLocation,
                            LatLng(
                              (_kitchenLocation.latitude * 0.6) + (_customerLocation.latitude * 0.4),
                              (_kitchenLocation.longitude * 0.4) + (_customerLocation.longitude * 0.6),
                            ),
                            _customerLocation,
                          ],
                          strokeWidth: 4.0,
                          color: const Color(0xFFFF2E93),
                        ),
                      ],
                    ),

                    // Markers (Kitchen, Customer, Live Courier)
                    MarkerLayer(
                      markers: [
                        // 1. Kitchen Marker
                        Marker(
                          point: _kitchenLocation,
                          width: 80,
                          height: 80,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: NetworkImage(widget.kitchenAvatar.isNotEmpty ? widget.kitchenAvatar : 'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=100'),
                                  backgroundColor: AppColors.surfaceContainer,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                                ),
                                child: const Text(
                                  '🍳 Kitchen',
                                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 2. Customer Destination Marker
                        Marker(
                          point: _customerLocation,
                          width: 80,
                          height: 80,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.6),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.home, color: Colors.white, size: 18),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                                ),
                                child: const Text(
                                  '📍 Dropoff',
                                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 3. Live Courier / Driver Marker
                        if (isOutForDelivery)
                          Marker(
                            point: _courierLocation,
                            width: 80,
                            height: 80,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primary.withValues(alpha: 0.35),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF2E93),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.8),
                                            blurRadius: 12,
                                            spreadRadius: 3,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.delivery_dining, color: Colors.white, size: 20),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    '🛵 Marcus (Driver)',
                                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                // Top Left: Live ETA Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOutForDelivery ? 'Est. Arrival: 15-20 mins' : 'Live Tracking Map',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top Right: Optional Uber External Link Button
                if (_uberTrackingUrl != null && _uberTrackingUrl!.isNotEmpty)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (_uberTrackingUrl != null && _uberTrackingUrl!.isNotEmpty) {
                            html.window.open(_uberTrackingUrl!, '_blank');
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Uber Link ↗', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // Bottom Right: Re-center / Fit Route Button
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'recenter_tracking_map',
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.primary,
                    onPressed: _fitMapBounds,
                    child: const Icon(Icons.crop_free, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // 2. SCROLLABLE DETAILS SECTION
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                children: [
                  // Status Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _currentStatus == 'Completed' ? Icons.check_circle
                                        : (isOutForDelivery ? Icons.delivery_dining : Icons.restaurant),
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _currentStatus.toUpperCase(),
                                      style: AppTextStyles.headlineMd(color: AppColors.primary).copyWith(fontSize: 16),
                                    ),
                                    Text(
                                      _currentStatus == 'pending_payment' ? 'Waiting for payment...'
                                      : _currentStatus == 'Active' ? 'Kitchen is preparing your meal.'
                                      : _currentStatus == 'on_the_way' ? 'Courier is delivering your meal.'
                                      : _currentStatus == 'Completed' ? 'Delivered! Enjoy your food.'
                                      : 'Status: $_currentStatus',
                                      style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.orderId,
                                style: AppTextStyles.labelMono(color: Colors.white).copyWith(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Driver Card (When out for delivery)
                  if (isOutForDelivery) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              const CircleAvatar(
                                radius: 26,
                                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 13,
                                  height: 13,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.surface, width: 2),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Marcus (Uber Courier)', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 15)),
                                Row(
                                  children: [
                                    const Icon(Icons.electric_moped, color: AppColors.onSurfaceVariant, size: 15),
                                    const SizedBox(width: 4),
                                    Text('E-Bike • 4.9 ★ (1,240 deliveries)', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                                  ],
                                )
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.phone, color: AppColors.primary),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Calling Courier (+1 555-0199)...')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _currentStatus == 'Completed' ? null : () async {
                          await ApiService.updateOrderStatus(widget.orderId, 'Completed');
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderReviewScreen(
                                  orderId: widget.orderId,
                                  kitchenId: widget.kitchenId,
                                  kitchenName: widget.kitchenName,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentStatus == 'Completed' ? AppColors.surfaceContainerHigh : const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          _currentStatus == 'Completed' ? 'ORDER COMPLETED - THANKS!' : 'MARK AS ARRIVED', 
                          style: AppTextStyles.labelMono(
                            color: Colors.white,
                          ).copyWith(fontSize: 15, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Timeline Details
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order Timeline', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 16)),
                        const SizedBox(height: 24),
                        _buildTimelineStep(
                          time: '',
                          title: 'Order Confirmed',
                          desc: _orderType == 'dine_in' ? 'Booking received by kitchen.' : 'Your gourmet selection is confirmed.',
                          status: _currentStatus == 'Cancelled' ? 'active' : (['Scheduled', 'Preparing', 'Ready', 'on_the_way', 'delivered', 'Completed'].contains(_currentStatus) ? 'done' : 'active'),
                        ),
                        if (_currentStatus != 'Cancelled') ...[
                          if (_orderType == 'dine_in') ...[
                            _buildTimelineLine(dim: !['Active', 'Preparing', 'Ready', 'Completed'].contains(_currentStatus)),
                            _buildTimelineStep(
                              time: '',
                              title: 'Waiting for Schedule',
                              desc: 'Your booking is scheduled.',
                              status: ['Active', 'Preparing', 'Ready', 'on_the_way', 'delivered', 'Completed'].contains(_currentStatus) ? 'done' : (_currentStatus == 'Scheduled' ? 'active' : 'upcoming'),
                            ),
                            _buildTimelineLine(dim: !['Ready', 'on_the_way', 'delivered', 'Completed'].contains(_currentStatus)),
                            _buildTimelineStep(
                              time: '',
                              title: 'Chef is Preparing',
                              desc: 'Chef is preparing your table and meal.',
                              status: ['Ready', 'on_the_way', 'delivered', 'Completed'].contains(_currentStatus) ? 'done' : ((['Active', 'Preparing'].contains(_currentStatus)) ? 'active' : 'upcoming'),
                            ),
                            _buildTimelineLine(dim: !['Completed', 'delivered', 'on_the_way'].contains(_currentStatus)),
                            _buildTimelineStep(
                              time: '',
                              title: 'Ready to Eat',
                              desc: 'Your table and food are ready!',
                              status: ['Completed', 'delivered', 'on_the_way'].contains(_currentStatus) ? 'active' : 'upcoming',
                            ),
                          ] else ...[
                            if (_dineInDate.isNotEmpty) ...[
                              _buildTimelineLine(dim: !['Active', 'Preparing', 'Ready', 'on_the_way', 'delivered', 'Completed'].contains(_currentStatus)),
                              _buildTimelineStep(
                                time: '',
                                title: 'Waiting for Schedule',
                                desc: 'Your delivery is scheduled.',
                                status: ['Active', 'Preparing', 'Ready', 'on_the_way', 'delivered', 'Completed'].contains(_currentStatus) ? 'done' : (_currentStatus == 'Scheduled' ? 'active' : 'upcoming'),
                              ),
                            ],
                            _buildTimelineLine(dim: !['Preparing', 'Ready', 'on_the_way', 'delivered', 'Completed'].contains(_currentStatus)),
                            _buildTimelineStep(
                              time: '',
                              title: 'Chef is Preparing',
                              desc: 'Artisan plating in progress at the kitchen.',
                              status: ['Ready', 'on_the_way', 'delivered', 'Completed'].contains(_currentStatus) ? 'done' : ((['Preparing', 'Active'].contains(_currentStatus) && _currentStatus != 'Scheduled') ? 'active' : 'upcoming'),
                            ),
                            _buildTimelineLine(dim: !['Ready', 'on_the_way', 'delivered', 'Completed'].contains(_currentStatus)),
                            _buildTimelineStep(
                              time: '',
                              title: 'Waiting for Driver',
                              desc: 'Order is ready and waiting for Uber courier pickup.',
                              status: ['on_the_way', 'delivered', 'Completed'].contains(_currentStatus) ? 'done' : (_currentStatus == 'Ready' ? 'active' : 'upcoming'),
                            ),
                            _buildTimelineLine(dim: !['on_the_way', 'delivered', 'Completed'].contains(_currentStatus)),
                            _buildTimelineStep(
                              time: '',
                              title: 'Out for Delivery',
                              desc: 'Your food is on the way with Uber courier!',
                              status: ['on_the_way', 'delivered', 'Completed'].contains(_currentStatus) ? 'active' : 'upcoming',
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),

                  if (['Completed', 'Delivered'].contains(_currentStatus)) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.withValues(alpha: 0.2),
                            Colors.amber.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Enjoyed your meal? ⭐',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Help the chef and foodie community by leaving your rating & review!',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.star, color: Colors.black, size: 20),
                              label: const Text(
                                'Rate Your Experience',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              onPressed: () {
                                RateOrderDialog.show(
                                  context,
                                  orderId: widget.orderId,
                                  kitchenId: int.tryParse(widget.kitchenId),
                                  kitchenName: widget.kitchenName,
                                  kitchenAvatar: widget.kitchenAvatar,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Order Details Summary Accordion
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        onExpansionChanged: (expanded) {
                          setState(() {
                            isDetailsExpanded = expanded;
                          });
                        },
                        leading: const Icon(Icons.receipt_long, color: AppColors.primary),
                        title: Text(
                          'Order #${widget.orderId}\n${widget.kitchenName}',
                          style: AppTextStyles.bodyLg(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('\$${widget.totalAmount.toStringAsFixed(2)}', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 16)),
                            const SizedBox(width: 8),
                            const Icon(Icons.expand_more, color: AppColors.onSurfaceVariant),
                          ],
                        ),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1))),
                            ),
                            child: Column(
                              children: [
                                if (_isLoadingItems)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: CircularProgressIndicator(color: AppColors.primary),
                                  ),
                                if (!_isLoadingItems && _orderItems != null)
                                  ..._orderItems!.map((item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: item.image.isNotEmpty 
                                            ? Image.network(item.image, width: 48, height: 48, fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => _buildFallbackImage())
                                            : _buildFallbackImage(),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('${item.quantity}x ${item.name}', style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                                              if (item.options.isNotEmpty)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Text(item.options, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text('\$${item.price.toStringAsFixed(2)}', style: AppTextStyles.bodyMd(color: Colors.white)),
                                      ],
                                    ),
                                  )),
                                if (!_isLoadingItems && _orderItems == null)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${widget.itemsCount}x Items', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(fontSize: 12)),
                                      Text('\$${widget.totalAmount.toStringAsFixed(2)}', style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontSize: 12)),
                                    ],
                                  ),
                                const SizedBox(height: 12),
                                Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 16)),
                                    Text('\$${widget.totalAmount.toStringAsFixed(2)}', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 16)),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      width: 48, 
      height: 48, 
      color: AppColors.surfaceContainerHighest, 
      child: const Icon(Icons.fastfood, size: 24, color: AppColors.onSurfaceVariant),
    );
  }

  Widget _buildTimelineStep({required String time, required String title, required String desc, required String status}) {
    bool isDone = status == 'done';
    bool isActive = status == 'active';
    bool isUpcoming = status == 'upcoming';
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFFEB1E8C) : (isActive ? AppColors.background : AppColors.surfaceContainer),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDone ? Colors.transparent : (isActive ? const Color(0xFFEB1E8C) : AppColors.outlineVariant),
              width: 2,
            ),
            boxShadow: isDone
                ? [BoxShadow(color: const Color(0xFFEB1E8C).withValues(alpha: 0.2), spreadRadius: 4)]
                : null,
          ),
          child: isDone
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : (isActive ? Center(child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFEB1E8C), shape: BoxShape.circle))) : null),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Opacity(
            opacity: isUpcoming ? 0.4 : 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: AppTextStyles.labelMono(color: isUpcoming ? AppColors.onSurfaceVariant : const Color(0xFFEB1E8C)).copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(title, style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: AppTextStyles.labelSm(
                    color: (isActive || desc.contains('on the way')) ? const Color(0xFFFF80AB) : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildTimelineLine({bool dim = false}) {
    return Container(
      margin: const EdgeInsets.only(left: 11),
      width: 2,
      height: 32,
      color: dim ? const Color(0xFFEB1E8C).withValues(alpha: 0.2) : const Color(0xFFEB1E8C),
    );
  }
}
