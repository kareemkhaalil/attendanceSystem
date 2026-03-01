import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart'; 
// Note: Requires webview_flutter package

class PaymobWebViewScreen extends StatefulWidget {
  final String url;
  const PaymobWebViewScreen({super.key, required this.url});

  @override
  State<PaymobWebViewScreen> createState() => _PaymobWebViewScreenState();
}

class _PaymobWebViewScreenState extends State<PaymobWebViewScreen> {
  // late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    /*
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (url.contains('callback') || url.contains('success')) {
               // Handle Success callback
               Navigator.pop(context, true);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paymob Payment'),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          'WebView will be here.\n(Please add webview_flutter package)',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
      ),
      /*
      body: WebViewWidget(controller: _controller),
      */
    );
  }
}
