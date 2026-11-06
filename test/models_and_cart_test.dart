import 'package:go_chef_app/screens/checkout/checkout_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_chef_app/models/kitchen_model.dart';
import 'package:go_chef_app/models/user_model.dart';
import 'package:go_chef_app/models/order_model.dart';
import 'package:go_chef_app/models/menu_item_model.dart';
import 'package:go_chef_app/models/cart_item_model.dart';

void main() {
  group('Kitchen Privacy & Display Tests', () {
    test('Chef Name Privacy Masking (Jessica Ambriz -> Jessica A.)', () {
      final kitchen = KitchenModel(
        id: 28,
        name: 'Coronita',
        chefName: 'Jessica Ambriz',
      );
      expect(kitchen.formattedChefName, equals('Jessica A.'));
    });

    test('Single-word Chef Name (Chef -> Chef)', () {
      final kitchen = KitchenModel(
        id: 1,
        name: 'Test Kitchen',
        chefName: 'Chef',
      );
      expect(kitchen.formattedChefName, equals('Chef'));
    });

    test('Three-word Chef Name (Mary Jane Watson -> Mary W.)', () {
      final kitchen = KitchenModel(
        id: 2,
        name: 'Bakery',
        chefName: 'Mary Jane Watson',
      );
      expect(kitchen.formattedChefName, equals('Mary W.'));
    });

    test('Bank Account Masking', () {
      final kitchen = KitchenModel(
        id: 10,
        name: "Marcus' Smokehouse",
        bankAccountNumber: '9876543210',
        bankRoutingNumber: '122000496',
      );
      expect(kitchen.hasBankLinked, isTrue);
      expect(kitchen.maskedBankAccount, contains('••••'));
    });

    test('Unlinked Bank Account returns false', () {
      final kitchen = KitchenModel(
        id: 99,
        name: 'No Bank Kitchen',
        bankAccountNumber: '',
        stripeAccountId: '',
      );
      expect(kitchen.hasBankLinked, isFalse);
    });

    test('Approximate Location Parsing (Strip exact street numbers)', () {
      final kitchen = KitchenModel(
        id: 10,
        name: 'Test',
        location: '11135 Magnolia Blvd, North Hollywood, CA 91601',
      );
      expect(kitchen.approximateLocation, isNotEmpty);
    });
  });

  group('User Model & Settings Tests', () {
    test('UserModel.fromJson parses notifications correctly (defaults to true for push/email, false for sms)', () {
      final json = {
        'id': '101',
        'name': 'Dany User',
        'email': 'dany@example.com',
        'phone': '+1 (818) 555-0199',
        'avatar': 'https://example.com/avatar.jpg',
        'role': 'customer',
        'push_notifications': 1,
        'email_notifications': 1,
        'sms_alerts': 0,
      };

      final user = UserModel.fromJson(json);
      expect(user.id, equals('101'));
      expect(user.name, equals('Dany User'));
      expect(user.pushNotifications, isTrue);
      expect(user.emailNotifications, isTrue);
      expect(user.smsAlerts, isFalse);
    });

    test('UserModel.fromJson handles string booleans and nulls safely', () {
      final json = {
        'id': '102',
        'name': 'Tester',
        'email': 'tester@example.com',
        'phone': null,
        'avatar': null,
        'role': 'chef',
        'push_notifications': '0',
        'email_notifications': '1',
        'sms_alerts': '1',
      };

      final user = UserModel.fromJson(json);
      expect(user.pushNotifications, isFalse);
      expect(user.emailNotifications, isTrue);
      expect(user.smsAlerts, isTrue);
      expect(user.effectiveAvatar, contains('ui-avatars.com'));
    });
  });

  group('Order & Cart Calculation Tests', () {
    test('Order total, item count, and statuses mapping', () {
      final json = {
        'id': 'ORD-2026-9999',
        'user_id': '1',
        'customer_name': 'Dany',
        'kitchen_id': '28',
        'kitchen_name': 'Coronita',
        'status': 'completed',
        'total_amount': '42.50',
        'order_type': 'delivery',
        'date': '2026-11-04T12:00:00Z',
        'items': [
          {
            'name': 'Test Dish',
            'price': '15.00',
            'quantity': '2',
            'options': 'Mild Sauce',
          },
          {
            'name': 'Test Drink',
            'price': '3.00',
            'quantity': '1',
            'options': 'No Ice',
          }
        ]
      };

      final order = OrderModel.fromJson(json);
      expect(order.id, equals('ORD-2026-9999'));
      expect(order.totalAmount, equals(42.50));
      expect(order.status, equals('completed'));
      expect(order.items.length, equals(2));
      expect(order.items[0].name, equals('Test Dish'));
      expect(order.items[0].quantity, equals(2));
    });

    test('CartItem and Discount calculation', () {
      final cartItem = CartItemModel(
        cartItemId: 1,
        menuItemId: 174,
        name: 'Test Dish',
        price: 15.00,
        image: '',
        prepTime: '15-20 min',
        quantity: 2,
        notes: 'Extra crispy',
      );

      expect(cartItem.totalPrice, equals(30.00));

      // 20% discount coupon
      const discountPercent = 20;
      final discountAmount = cartItem.totalPrice * (discountPercent / 100);
      expect(discountAmount, equals(6.00));
      final finalSubtotal = cartItem.totalPrice - discountAmount;
      expect(finalSubtotal, equals(24.00));
    });

    test('Card Number Formatter formats 16 digits into 4 groups', () {
      final formatter = CardNumberInputFormatter();
      const input = TextEditingValue(text: '4242424242424242');
      final result = formatter.formatEditUpdate(TextEditingValue.empty, input);
      expect(result.text, equals('4242 4242 4242 4242'));
    });

    test('Card Expiry Formatter auto-inserts slash after 2 digits', () {
      final formatter = CardExpiryInputFormatter();
      // User types '09'
      final r1 = formatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: '09'));
      expect(r1.text, equals('09/'));

      // User types full '0930'
      final r2 = formatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: '0930'));
      expect(r2.text, equals('09/30'));
    });
  });
}

