import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/premium/glass_card.dart';

class MenuPreviewScreen extends StatefulWidget {
  const MenuPreviewScreen({super.key});

  @override
  State<MenuPreviewScreen> createState() => _MenuPreviewScreenState();
}

class _MenuPreviewScreenState extends State<MenuPreviewScreen> {
  String dishName = '';
  String dishPrice = '';
  String dishDesc = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Become a Chef', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppTheme.fuchsiaPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressBar(),
            const SizedBox(height: 32),
            _buildForm(),
            const SizedBox(height: 48),
            _buildLivePreview(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Your Signature Dish', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary)),
            Text('Step 3 of 6', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 6,
          decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(3)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.5,
            child: Container(decoration: BoxDecoration(color: AppTheme.fuchsiaPrimary, borderRadius: BorderRadius.circular(3))),
          ),
        ),
        const SizedBox(height: 12),
        Text('Showcase the dish that defines your kitchen. This will be the first thing Foodies see when visiting your profile.', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dish Photo', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.5), style: BorderStyle.solid),
            image: const DecorationImage(
              image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBwPQxeugKtF2EICc1pANmi2PGbjCbM89HKBrTpmuYUk_vx8PTQwCExueaerILkjGWGydHY4i_XmSNXQ2TkUboFDdtU8rYLt5QsHAvICimgA29EwXkXzQzk-k-CjUJA6BHOz2Qim8P2S-bpIrNfcwQxVrdRRaESgWGGr9qDLAFgDk9zA_9cEf0fivLOPDyXT7qYNhdazYQtJQhPEEnV7TYbOiRKuygSLHLpOCNHKzWj_DI7K5iaCprtHrGaXRPHJN6-sH1D-4Rty7YI'),
              fit: BoxFit.cover,
              opacity: 0.3,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_a_photo, size: 48, color: AppTheme.fuchsiaPrimary),
              const SizedBox(height: 8),
              Text('Click to upload photo', style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
              Text('Recommended: 1200 x 900px', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField('Dish Name', 'e.g., Midnight Saffron Risotto', (val) => setState(() => dishName = val)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField('Price (USD)', '24.00', (val) => setState(() => dishPrice = val), prefix: '\$')),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prep Time', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.surfaceLight)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        dropdownColor: AppTheme.surfaceDark,
                        value: '30-45 mins',
                        style: GoogleFonts.inter(color: AppTheme.textPrimary),
                        items: ['30-45 mins', '45-60 mins', '1-2 hours', 'Pre-order only'].map((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value));
                        }).toList(),
                        onChanged: (_) {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField('Description', 'Describe the flavors, origins, and special ingredients...', (val) => setState(() => dishDesc = val), maxLines: 4),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, Function(String) onChanged, {String? prefix, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          maxLines: maxLines,
          style: GoogleFonts.inter(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
            prefixText: prefix,
            prefixStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.surfaceDark,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.surfaceLight)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.fuchsiaPrimary)),
          ),
        ),
      ],
    );
  }

  Widget _buildLivePreview() {
    final previewName = dishName.isEmpty ? 'Your Dish Name' : dishName;
    final previewPrice = dishPrice.isEmpty ? '0.00' : dishPrice;
    final previewDescText = dishDesc.isEmpty ? 'Describe your signature creation here...' : dishDesc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.visibility, color: Colors.greenAccent),
            const SizedBox(width: 8),
            Text('Live Foodie Preview', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                  image: DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBM43Urduy2ptjM4lcXjL6C9hf2_ZRzhd9UTn5F1bXPEMpecN6lpPA_hApTARB3eX_GUWnYbA0PktP243facJDdYi-3j_nNfCXRGZdEGdPV4yLRgdAU2jUhAeoSHm3ICKBVvQzuLVIhNDd1jg0w0PMy0SptoZSh-q3eCC5axEPidw_puC-9gEfrEmiU6dOHNRV-stfsR9LrLD1-QZoa-arkxf6Fo5li3OzecR-IxxRW8KDRCr3xeUVQVKpc_7Z4eZVtSWDsoqfBwAVX'),
                    fit: BoxFit.cover,
                  ),
                ),
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                const Icon(Icons.timer, size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text('45 MIN', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppTheme.fuchsiaPrimary, borderRadius: BorderRadius.circular(12)),
                            child: Text('TOP CHOICE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(previewName, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text('New Chef • 0.4 miles away', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(previewDescText, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Price per serving', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                            Text('\$$previewPrice', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary)),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.fuchsiaPrimary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Order Now'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified, color: Colors.greenAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Verified Kitchen Status', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                    const SizedBox(height: 4),
                    Text('All signature dishes are reviewed for safety and quality standards before appearing on the public map.', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark.withValues(alpha: 0.9),
        border: const Border(top: BorderSide(color: AppTheme.surfaceLight)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save, color: AppTheme.textSecondary),
              label: Text('Save Draft', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.fuchsiaPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Next: Verification', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
