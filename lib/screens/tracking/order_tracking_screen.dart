import 'package:flutter/material.dart';
import 'package:go_chef_app/theme/app_colors.dart';
import 'package:go_chef_app/theme/app_text_styles.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  bool isDetailsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Order Tracking',
            style: AppTextStyles.headlineMd(color: AppColors.primary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.primary),
            onPressed: () {},
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
        ),
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
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDcGzOXniPvnMMK3nTjw-VwZ7ZMa2U9sGJf7rg_EwCR8a0PCdpeS1sGnJxv5VIlAsZ-Urbap902jWOcN68Oq9arhZ0zk5o31DzTCQXBurzUsUNPAQcukoSZZEJQiambIjZloiLz_eFz_IPTHkBOZUdqtfeVF3kGxoWrWLoDk6iQGV0rtSNU8kSXK4fGPRrWwsklkbEXekFa9Q3_ZmNm9Lh8INxcvAaDx9rQ1AbSYolBBRY81FF1Ievlmw',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D111A).withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE42278).withValues(alpha: 0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE42278).withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ESTIMATED ARRIVAL', style: AppTextStyles.labelMono(color: const Color(0xFFE42278))),
                              Text('12 mins', style: AppTextStyles.displayLgMobile(color: Colors.white).copyWith(fontSize: 32)),
                            ],
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE42278),
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
            
            // Details & Status
            Transform.translate(
              offset: const Offset(0, -16), // pull up slightly
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Driver Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D111A).withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE42278).withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFE42278), width: 2),
                                  image: const DecorationImage(
                                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCciYPVFg6JXnUz02s4EcoZC2o288Wkc53SNNuymiIvdEDYU-vgdA0rU45g2DYKJqsbjlMygGJU6vJ_AfIcGsir1Vt_SVRXP5xUfaltPuv1m_jXA4Tp3CegVw2h0aRRNIJVh8psx7RkP-VRUCSRxLI7xSZnAM7tZomobJ9dJ7p8dVwZ7LdxFF8WLMFI6JqA_TMY2KsjF1Z0gSxmA2Ej2y2uNoHFB6sXVFVQipoeSqCRoe9b-5x0PpCoFg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.background, width: 2),
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
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.message, color: AppColors.primary),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.2),
                                      blurRadius: 10,
                                    )
                                  ],
                                ),
                                child: const Icon(Icons.call, color: AppColors.onPrimary),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
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
                          Text('Order Status', style: AppTextStyles.headlineMd(color: Colors.white)),
                          const SizedBox(height: 32),
                          // Custom timeline implementation
                          _buildTimelineStep(
                            time: '18:42',
                            title: 'Order Confirmed',
                            desc: 'Your gourmet selection is in the queue.',
                            status: 'done',
                          ),
                          _buildTimelineLine(),
                          _buildTimelineStep(
                            time: '18:55',
                            title: 'Chef is Preparing',
                            desc: 'Artisan plating in progress at the kitchen.',
                            status: 'done',
                          ),
                          _buildTimelineLine(),
                          _buildTimelineStep(
                            time: '19:12',
                            title: 'Driver is Heading to You',
                            desc: 'Marcus is 1.2 miles away from your location.',
                            status: 'active',
                          ),
                          _buildTimelineLine(dim: true),
                          _buildTimelineStep(
                            time: 'Expected 19:24',
                            title: 'Delivered',
                            desc: 'Bon appétit!',
                            status: 'upcoming',
                          ),
                        ],
                      ),
                    ),
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
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order #GC-99210', style: AppTextStyles.labelMono(color: AppColors.onSurfaceVariant)),
                              Text('Truffle Risotto & Fine Wine', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 14)),
                            ],
                          ),
                          iconColor: AppColors.primary,
                          collapsedIconColor: AppColors.primary,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1))),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('1x Wild Mushroom Truffle Risotto', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(fontSize: 12)),
                                      Text('\$32.00', style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('1x Cabernet Sauvignon (Glass)', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(fontSize: 12)),
                                      Text('\$14.00', style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Total', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 16)),
                                      Text('\$46.00', style: AppTextStyles.headlineMd(color: const Color(0xFFE42278)).copyWith(fontSize: 16)),
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
                Text(desc, style: AppTextStyles.labelSm(color: isActive ? AppColors.primary : AppColors.onSurfaceVariant)),
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
