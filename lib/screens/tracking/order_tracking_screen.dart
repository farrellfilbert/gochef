import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_chef_app/theme/app_colors.dart';
import 'package:go_chef_app/theme/app_text_styles.dart';
import 'package:go_chef_app/services/api_service.dart';
import 'package:go_chef_app/services/support_helper.dart';
import 'package:go_chef_app/main.dart';
import 'order_review_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';
import 'package:go_chef_app/models/order_model.dart';
import '../../widgets/rate_order_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool isDetailsExpanded = false;
  late String _currentStatus;
  List<OrderItemModel>? _orderItems;
  bool _isLoadingItems = true;
  String _orderType = 'delivery';
  String _dineInDate = '';
  String? _uberTrackingUrl;
  Timer? _timer;
  
// Add these variables:
  final MapController _mapController = MapController();
  final LatLng _kitchenLocation = const LatLng(-6.3687, 106.8329); // Dummy kitchen loc
  LatLng _driverLocation = const LatLng(-6.3687, 106.8329); // Starts at kitchen

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.initialStatus;
    _fetchOrderDetails();
    _startPolling();
    _startDriverSimulation();
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
          _uberTrackingUrl = order.uberTrackingUrl;
          _isLoadingItems = false;
        });
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
          _uberTrackingUrl = currentOrder.uberTrackingUrl;
        });
        
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

  void _startDriverSimulation() {
    // Dummy simulation: driver moves slightly every second if status is Completed
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_currentStatus == 'Completed') {
        setState(() {
          _driverLocation = LatLng(
            _driverLocation.latitude + (Random().nextDouble() - 0.5) * 0.0005,
            _driverLocation.longitude + (Random().nextDouble() - 0.5) * 0.0005,
          );
        });
      }
    });
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
              // Return to the main navigation (Foodie Home)
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainNavigation()),
                (Route<dynamic> route) => false,
              );
            } else {
              // Return to previous screen (Order History)
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
                const SnackBar(content: Text('Refreshing status...'), duration: Duration(seconds: 1)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            // Live Map Section
            SizedBox(
              height: 397,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _kitchenLocation,
                        initialZoom: 15.0,
                        minZoom: 3.0,
                        maxZoom: 19.0,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.drag |
                              InteractiveFlag.pinchZoom |
                              InteractiveFlag.scrollWheelZoom |
                              InteractiveFlag.doubleTapZoom,
                        ),
                      ),
                      children: [
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
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _kitchenLocation,
                              width: 40,
                              height: 40,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.restaurant, color: Colors.white, size: 20),
                              ),
                            ),
                            if (isOutForDelivery)
                              Marker(
                                point: _driverLocation,
                                width: 40,
                                height: 40,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.electric_moped, color: Colors.white, size: 20),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Floating Zoom In / Zoom Out Controls
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D111A).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              onTap: () {
                                final currentZoom = _mapController.camera.zoom;
                                if (currentZoom < 19.0) {
                                  _mapController.move(_mapController.camera.center, (currentZoom + 1).clamp(3.0, 19.0));
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.add, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                          Container(width: 28, height: 1, color: Colors.white12),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                              onTap: () {
                                final currentZoom = _mapController.camera.zoom;
                                if (currentZoom > 3.0) {
                                  _mapController.move(_mapController.camera.center, (currentZoom - 1).clamp(3.0, 19.0));
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.remove, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isOutForDelivery)
                    Positioned(
                      bottom: 24,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D111A).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ESTIMATED ARRIVAL', style: AppTextStyles.labelMono(color: const Color(0xFFFF80AB))),
                                Text('12 mins', style: AppTextStyles.displayLgMobile(color: Colors.white).copyWith(fontSize: 32)),
                              ],
                            ),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.delivery_dining, color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Driver & Order Status Details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Driver Card
                    if (isOutForDelivery) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                const CircleAvatar(
                                  radius: 28,
                                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.surface, width: 2),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Marcus', style: AppTextStyles.headlineMd(color: Colors.white)),
                                Row(
                                  children: [
                                    const Icon(Icons.electric_moped, color: AppColors.onSurfaceVariant, size: 16),
                                    const SizedBox(width: 4),
                                    Text('E-Bike • 4.9 ★', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              if (_uberTrackingUrl != null && _uberTrackingUrl!.isNotEmpty)
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final Uri url = Uri.parse(_uberTrackingUrl!);
                                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Could not open Uber Tracking URL')),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  icon: const Icon(Icons.map, size: 16),
                                  label: const Text('Live Track'),
                                ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _currentStatus == 'Completed' ? null : () async {
                          // Mark as completed in backend
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
                          backgroundColor: _currentStatus == 'Completed' ? AppColors.surfaceContainerHigh : Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          _currentStatus == 'Completed' ? 'ORDER COMPLETED - THANKS!' : 'MARK AS ARRIVED', 
                          style: AppTextStyles.labelMono(
                            color: Colors.white,
                          ).copyWith(fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Status Timeline
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Order Status', style: AppTextStyles.headlineMd(color: Colors.white)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _currentStatus == 'Cancelled' ? Colors.red.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _currentStatus.toUpperCase(),
                                style: AppTextStyles.labelMono(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Custom timeline implementation
                        _buildTimelineStep(
                          time: '',
                          title: 'Order Confirmed',
                          desc: _orderType == 'dine_in' ? 'Booking received by kitchen.' : 'Your gourmet selection is in the queue.',
                          status: _currentStatus == 'Cancelled' ? 'active' : (['Scheduled', 'Preparing', 'Ready', 'on_the_way', 'delivered', 'Completed'].contains(_currentStatus) ? 'done' : 'active'),
                        ),
                        if (_currentStatus != 'Cancelled') ...[
                          if (_orderType == 'dine_in') ...[
                            _buildTimelineLine(dim: !['Active', 'Preparing', 'Ready', 'Completed'].contains(_currentStatus)),
                            _buildTimelineStep(
                              time: '',
                              title: 'Waiting for Schedule',
                              desc: 'Your booking is scheduled and waiting for the time.',
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
                                desc: 'Your delivery is scheduled and waiting for the time.',
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
                              desc: 'Order is ready and waiting to be picked up.',
                              status: ['on_the_way', 'delivered', 'Completed'].contains(_currentStatus) ? 'done' : (_currentStatus == 'Ready' ? 'active' : 'upcoming'),
                            ),
                            _buildTimelineLine(dim: !['on_the_way', 'delivered', 'Completed'].contains(_currentStatus)),
                            _buildTimelineStep(
                              time: '',
                              title: 'Out for Delivery',
                              desc: 'Your food is on the way!',
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

                  const SizedBox(height: 24),
                  
                  // Order Details Summary
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
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
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
            color: isDone ? const Color(0xFFE42278) : (isActive ? AppColors.background : AppColors.surfaceContainer),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDone ? Colors.transparent : (isActive ? const Color(0xFFE42278) : AppColors.outlineVariant),
              width: 2,
            ),
            boxShadow: isDone
                ? [BoxShadow(color: const Color(0xFFE42278).withValues(alpha: 0.2), spreadRadius: 4)]
                : null,
          ),
          child: isDone
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : (isActive ? Center(child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFE42278), shape: BoxShape.circle))) : null),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Opacity(
            opacity: isUpcoming ? 0.4 : 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: AppTextStyles.labelMono(color: isUpcoming ? AppColors.onSurfaceVariant : const Color(0xFFE42278)).copyWith(fontWeight: FontWeight.bold)),
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
      margin: const EdgeInsets.only(left: 11), // Center with the 24px icon
      width: 2,
      height: 32,
      color: dim ? const Color(0xFFE42278).withValues(alpha: 0.2) : const Color(0xFFE42278),
    );
  }
}
