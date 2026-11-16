import 'package:flutter_test/flutter_test.dart';
import 'package:go_chef_app/models/kitchen_model.dart';
import 'package:go_chef_app/models/order_model.dart';

void main() {
  group('v2.1.1 New Feature Unit Tests', () {
    test('1. Kitchen Role Matching (matchesRole)', () {
      final certifiedKitchen = KitchenModel(
        id: 101,
        name: 'Master Certified Chef Kitchen',
        cuisineType: 'Certified Professional',
        isOpen: true,
      );

      final foodTruckKitchen = KitchenModel(
        id: 102,
        name: 'Mobile Taco Food Truck',
        cuisineType: 'Food Truck Specials',
        isOpen: true,
      );

      final vettedCookKitchen = KitchenModel(
        id: 103,
        name: 'Home Cook Delight',
        cuisineType: 'Homestyle',
        isVerified: true,
        isOpen: true,
      );

      // Filter: All Chefs
      expect(certifiedKitchen.matchesRole('All Chefs'), isTrue);
      expect(foodTruckKitchen.matchesRole('All Chefs'), isTrue);

      // Filter: Certified Chef
      expect(certifiedKitchen.matchesRole('Certified Chef'), isTrue);
      expect(foodTruckKitchen.matchesRole('Certified Chef'), isFalse);

      // Filter: Food Truck - Birthdays/Events
      expect(foodTruckKitchen.matchesRole('Food Truck - Birthdays/Events'), isTrue);
      expect(certifiedKitchen.matchesRole('Food Truck - Birthdays/Events'), isFalse);

      // Filter: Vetted Cook
      expect(vettedCookKitchen.matchesRole('Vetted Cook'), isTrue);
    });

    test('2. SUPER CHEF Badge Calculation', () {
      final topKitchen = KitchenModel(
        id: 201,
        name: 'Top Gourmet',
        rating: 4.9,
        totalReviews: 12,
        isOpen: true,
      );

      final newKitchen = KitchenModel(
        id: 202,
        name: 'Beginner Spot',
        rating: 4.2,
        totalReviews: 1,
        isOpen: true,
      );

      final wakandaKitchen = KitchenModel(
        id: 203,
        name: 'Wakanda Kitchen Express',
        rating: 4.0,
        totalReviews: 0,
        isOpen: true,
      );

      expect(topKitchen.isSuperChef, isTrue);
      expect(newKitchen.isSuperChef, isFalse);
      expect(wakandaKitchen.isSuperChef, isTrue);
    });

    test('3. Food Allergy Matching & Safety Logic', () {
      final userAllergies = ['Peanuts', 'Dairy', 'Shellfish'];
      final dishWithPeanut = 'Authentic Thai Pad Thai (contains crushed peanuts and lime)';
      final dishSafe = 'Steamed Jasmine Rice with Lemongrass Chicken';

      bool isAllergenPresent(String desc, List<String> allergies) {
        final lower = desc.toLowerCase();
        return allergies.any((a) => lower.contains(a.toLowerCase().replaceAll('s', '')));
      }

      expect(isAllergenPresent(dishWithPeanut, userAllergies), isTrue);
      expect(isAllergenPresent(dishSafe, userAllergies), isFalse);
    });

    test('4. Chef Report CSV Data Structure & Formatting', () {
      final sampleOrder = OrderModel(
        id: 'GC-98214',
        date: 'Nov 16, 2026 - 1:45 PM',
        kitchenName: 'Coronita Kitchen',
        customerName: 'Marcus Sterling',
        avatar: '',
        totalAmount: 24.00,
        itemsCount: 1,
        items: [
          OrderItemModel(
            name: 'Carne Asada Quesadilla',
            options: 'Extra Cheese',
            quantity: 2,
            price: 12.00,
            image: '',
          ),
        ],
        status: 'Delivered',
      );

      expect(sampleOrder.orderNumber, equals('GC-98214'));
      expect(sampleOrder.createdAt, equals('Nov 16, 2026 - 1:45 PM'));
      expect(sampleOrder.totalAmount, equals(24.00));

      final csvRow = '"${sampleOrder.date}","${sampleOrder.orderNumber}","${sampleOrder.customerName}","${sampleOrder.items.map((i) => '${i.quantity}x ${i.name}').join('; ')}","\$${sampleOrder.totalAmount.toStringAsFixed(2)}","${sampleOrder.status}"';
      expect(csvRow, contains('GC-98214'));
      expect(csvRow, contains('\$24.00'));
      expect(csvRow, contains('Marcus Sterling'));
      expect(csvRow, contains('2x Carne Asada Quesadilla'));
    });

    test('5. Chef Resources x Food Flips Economics Verification', () {
      // Quesadilla Payday: 10 orders @ $8 = $80 sales vs $18 ingredient budget
      const orders = 10;
      const pricePerOrder = 8.0;
      const ingredientBudget = 18.0;

      final grossSales = orders * pricePerOrder;
      final estimatedNet = grossSales - ingredientBudget;
      final marginPercent = (estimatedNet / grossSales) * 100;

      expect(grossSales, equals(80.0));
      expect(estimatedNet, equals(62.0));
      expect(marginPercent, closeTo(77.5, 0.1));
    });
  });
}
