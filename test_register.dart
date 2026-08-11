import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://astroboomin.co/api/register.php');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'name': 'Test Chef',
      'email': 'testchef123@example.com',
      'password': 'password123',
      'role': 'chef',
      'kitchen_name': 'Test Kitchen',
      'phone': '0812345678',
      'avatar': 'http://example.com/avatar.jpg',
      'kitchen_avatar': 'http://example.com/kitchen.jpg',
      'kitchen_cover': 'http://example.com/cover.jpg'
    })
  );
  print('Status code: \${response.statusCode}');
  print('Body: \${response.body}');
}
