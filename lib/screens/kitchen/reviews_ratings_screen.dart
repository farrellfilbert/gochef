import 'package:flutter/material.dart';
import 'package:go_chef_app/theme/app_colors.dart';
import 'package:go_chef_app/theme/app_text_styles.dart';

class ReviewsRatingsScreen extends StatefulWidget {
  const ReviewsRatingsScreen({super.key});

  @override
  State<ReviewsRatingsScreen> createState() => _ReviewsRatingsScreenState();
}

class _ReviewsRatingsScreenState extends State<ReviewsRatingsScreen> {
  int selectedFilter = 0;
  final List<String> filters = ['All', 'Most Recent', 'Highest Rated', 'With Photos'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F131C).withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Reviews & Ratings',
            style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.outlineVariant.withValues(alpha: 0.3), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Overall Rating
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Text('4.9', style: AppTextStyles.displayLgMobile(color: AppColors.onSurface)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => const Icon(Icons.star, color: Color(0xFFE42278), size: 32),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('BASED ON 1.2K REVIEWS', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(letterSpacing: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Filters
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  bool isSelected = selectedFilter == index;
                  return GestureDetector(
                    onTap: () => setState(() => selectedFilter = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xFFE42278), Color(0xFFdb6c9b)],
                              )
                            : null,
                        color: isSelected ? null : AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(32),
                        border: isSelected ? null : Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                        boxShadow: isSelected
                            ? [BoxShadow(color: const Color(0xFFE42278).withValues(alpha: 0.2), blurRadius: 10)]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        filters[index],
                        style: AppTextStyles.labelMono(color: isSelected ? Colors.white : AppColors.onSurface),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Review 1
            _buildReviewCard(
              name: 'Julianne Thorne',
              time: '2 days ago',
              avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCBKazEINZsYS8-Tq6q1Sn1Oy--ufgJ4hEEm2AifjQeB1yOCF1l0QPFqT3CtE5NuOXPNQjdD7aYTlQ-0DudYM0fZ6aJsnNXZZ-yheG08F3stjipFJl4OYn4km9TED9HVpc0vLxGYNtCAv6nIabZT6dRFvyW9JA-vbb3s9vYSHZCXuyysVNFJQWIa5t2s_URRiN0B64lBB_AfEEMoOeje4OOjFCZjLT45HaxAeMVNsVIbsVlKYYU52fioQ',
              rating: 5,
              text: '"The Wild Mushroom Tagliatelle was life-changing. Chef Elena is a master of flavor."',
              isItalic: true,
              orderedItem: 'Wild Mushroom Tagliatelle',
              helpfulCount: 24,
            ),
            const SizedBox(height: 24),

            // Review 2 (with response)
            _buildReviewCard(
              name: 'Marcus Chen',
              time: '5 days ago',
              avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAyiJOJSCdX3A_3Ht-yEH_mr-XI9IfX6WA-iA7Uqui9Yp2rvOhBnF9XUj_rD7K55-UhwhAFi_71ZWpVgxjrr4bhmR_TQmxAsIhjQme6nB0bcjDjlRujSW9h7jAnYCDyarSyzaAlueMaPl8TZyum1jqsOaEqIPW8KXNV89C-a6edCD80L4ZiSVdwC5LPuS2hnSUboxSNdRZv7SxEfEPbU9QfZujA_r1jTXervaYkqs_rf7iFakpbYef7Lw',
              rating: 4,
              text: 'The presentation was museum-quality. The truffles were a bit subtle for my taste, but the texture of the pasta was absolutely perfect.',
              orderedItem: 'Truffle Risotto',
              helpfulCount: 8,
              chefResponse: '"Thank you for the detailed feedback, Marcus! I\'ll look into intensifying the truffle oil infusion for future orders. So glad you enjoyed the texture."',
              isHighlighted: true,
            ),
            const SizedBox(height: 24),

            // Review 3 (with photos)
            _buildReviewCard(
              name: 'Sarah Jenkins',
              time: '1 week ago',
              avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD3WAJm7lkCIhxG7aCVrYVuxgVnVP3HtPYd9gFhJCmfqWSG24oIOuHr4oziS_b0trIqBmaQumBZRW8LCBW8kBOTXoH0OWALBT-T7Mz6jZqi4yIpxT2avq51HHk7HpAm-1cw5LIHOYMPXNpOUSaU7R1WSD0VpniB7d3WEKBzLmKi-Q8Je_4PMcM-MZG1o8P8V42VwjPeCN5HqoS1op_VDkHOypvv4Rv-PwqOuqXOC1qGKQhMGwUk0e31xQ',
              rating: 5,
              text: 'Absolutely stunning. Best private chef experience in the city.',
              orderedItem: null,
              helpfulCount: 42,
              photos: [
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAvtdmSuqgg0D4lcsbbLsoFSB6WijJqpfV1j6cmtOFx25TKL96y6HnauhVT-_mtt-rMxf_8DoArilql7BKWZtLHg43dL9PQmKY7FgDOUGIAm3dqYebUp5EJ0TxiX_TFtTTOqNxv4Cqko2qI44HGm6jSWS2oie_XGI0eIZL9gOTG--G_Nu1DhexRbaBy8Z0xY4CewCMwJJHo-jkIgKgNH2BtE6nw7E32idEis0c2levKYLh0Wh5dTEQPmA',
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBb3FA2uCPeAP6-IQ_A9nICIM40vY6akviu6QHS1HicZW4pt0EJjpBky-8DhRQXqSCOeqfhvg6SuVdlm6zLYWoZeC50ZF937zksMubE3UNk5hS2DcEAMkzNHY02PEpxJoYg-foltnsgg6wFeDwelFOnndbXdL2toM6rrUlTfoHqevd9MzYRtKyoAOBcopGybrpJ8EFeAJMNxGmUZihoaya0rVOdhDgqQwdUGgUwNZVnFKZGBwEiVGvflw',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard({
    required String name,
    required String time,
    required String avatar,
    required int rating,
    required String text,
    bool isItalic = false,
    String? orderedItem,
    required int helpfulCount,
    String? chefResponse,
    bool isHighlighted = false,
    List<String>? photos,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF31353F).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: isHighlighted ? const BorderSide(color: Color(0xFFE42278), width: 4) : BorderSide.none,
          top: isHighlighted ? BorderSide.none : BorderSide(color: const Color(0xFFA98890).withValues(alpha: 0.15)),
          right: isHighlighted ? BorderSide.none : BorderSide(color: const Color(0xFFA98890).withValues(alpha: 0.15)),
          bottom: isHighlighted ? BorderSide.none : BorderSide(color: const Color(0xFFA98890).withValues(alpha: 0.15)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                      image: DecorationImage(image: NetworkImage(avatar), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                      Text(time, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: index < rating ? const Color(0xFFE42278) : AppColors.onSurfaceVariant,
                    size: 18,
                  );
                }),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: AppTextStyles.bodyLg(color: AppColors.onSurface).copyWith(fontStyle: isItalic ? FontStyle.italic : FontStyle.normal),
          ),
          if (orderedItem != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.restaurant, color: AppColors.primary, size: 14),
                  const SizedBox(width: 8),
                  Text('Ordered: $orderedItem', style: AppTextStyles.labelMono(color: AppColors.primary)),
                ],
              ),
            )
          ],
          if (photos != null && photos.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: photos.map((photoUrl) {
                return Expanded(
                  child: Container(
                    height: 160,
                    margin: EdgeInsets.only(right: photoUrl == photos.last ? 0 : 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                      image: DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (chefResponse != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFE42278), shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('CHEF\'S RESPONSE', style: AppTextStyles.labelMono(color: const Color(0xFFE42278)).copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(chefResponse, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(fontStyle: FontStyle.italic)),
                ],
              ),
            )
          ],
          const SizedBox(height: 12),
          Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.thumb_up, color: AppColors.onSurfaceVariant, size: 20),
                  const SizedBox(width: 8),
                  Text('Helpful ($helpfulCount)', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                ],
              ),
              const Icon(Icons.more_horiz, color: AppColors.onSurfaceVariant),
            ],
          )
        ],
      ),
    );
  }
}
