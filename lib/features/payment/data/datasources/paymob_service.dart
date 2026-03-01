import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymobService {
  final String _baseUrl = 'https://accept.paymob.com/api';
  final String apiKey;
  final String integrationId;
  final String iframeId;

  PaymobService({
    required this.apiKey,
    required this.integrationId,
    required this.iframeId,
  });

  Future<String> getPaymentKey({
    required double amount,
    required String currency,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
  }) async {
    // 1. Authentication Request
    final authResponse = await http.post(
      Uri.parse('$_baseUrl/auth/tokens'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'api_key': apiKey}),
    );
    final authToken = jsonDecode(authResponse.body)['token'];

    // 2. Order Registration
    final orderResponse = await http.post(
      Uri.parse('$_baseUrl/ecommerce/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'auth_token': authToken,
        'delivery_needed': 'false',
        'amount_cents': (amount * 100).toInt().toString(),
        'currency': currency,
        'items': [],
      }),
    );
    final orderId = jsonDecode(orderResponse.body)['id'];

    // 3. Payment Key Request
    final keyResponse = await http.post(
      Uri.parse('$_baseUrl/acceptance/payment_keys'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'auth_token': authToken,
        'amount_cents': (amount * 100).toInt().toString(),
        'expiration': 3600,
        'order_id': orderId,
        'billing_data': {
          'apartment': 'NA',
          'email': email,
          'floor': 'NA',
          'first_name': firstName,
          'street': 'NA',
          'building': 'NA',
          'phone_number': phoneNumber,
          'shipping_method': 'NA',
          'postal_code': 'NA',
          'city': 'NA',
          'country': 'EG',
          'last_name': lastName,
          'state': 'NA'
        },
        'currency': currency,
        'integration_id': integrationId,
      }),
    );
    return jsonDecode(keyResponse.body)['token'];
  }

  String getIframeUrl(String paymentKey) {
    return 'https://accept.paymob.com/api/acceptance/iframes/$iframeId?payment_token=$paymentKey';
  }
}
