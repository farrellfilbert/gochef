import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String initialUrl;
  final String? successUrlPattern;
  final String? cancelUrlPattern;

  const PaymentWebViewScreen({
    super.key,
    required this.initialUrl,
    this.successUrlPattern,
    this.cancelUrlPattern,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setUserAgent('Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1')
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _progress = progress / 100.0;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
            _checkUrl(url);
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
            _checkUrl(url);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Payment WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            _checkUrl(request.url);
            if (request.url.startsWith('http://') || request.url.startsWith('https://')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  void _checkUrl(String url) {
    if (!mounted) return;
    final lower = url.toLowerCase();
    if (lower.contains('success') ||
        lower.contains('complete') ||
        lower.contains('paid') ||
        lower.contains('thank') ||
        lower.contains('finish') ||
        lower.contains('return') ||
        lower.contains('approved') ||
        lower.contains('status=1') ||
        lower.contains('session_id')) {
      Navigator.pop(context, true);
    } else if (lower.contains('cancel') || lower.contains('declined') || lower.contains('failed')) {
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Secure Payment', style: AppTextStyles.headlineMd(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Text(
                'Done',
                style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _isLoading
              ? LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  backgroundColor: Colors.transparent,
                  color: AppColors.primary,
                )
              : const SizedBox(height: 3),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
