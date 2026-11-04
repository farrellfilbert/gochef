import 'package:flutter_test/flutter_test.dart';
import 'package:go_chef_app/models/kitchen_model.dart';

void main() {
  group('Kitchen Business Hours & Open/Closed Logic Tests', () {
    test('Standard daytime hours (10:00 AM - 5:00 PM) - Closed before open (3:44 AM)', () {
      final kitchen = KitchenModel(
        id: 28,
        name: 'Coronita',
        businessHours: '10:00 AM - 5:00 PM',
        isOpen: true,
      );

      // 3:44 AM Pacific Time -> Must be closed
      final testTime = DateTime.utc(2026, 11, 4, 3, 44);
      expect(kitchen.isCurrentlyOpenAt(testTime), isFalse);
      expect(kitchen.getOpenStatusTextAt(testTime), equals('Closed'));
    });

    test('Standard daytime hours (10:00 AM - 5:00 PM) - Open during business hours (1:30 PM)', () {
      final kitchen = KitchenModel(
        id: 28,
        name: 'Coronita',
        businessHours: '10:00 AM - 5:00 PM',
        isOpen: true,
      );

      // 1:30 PM Pacific Time -> Must be open
      final testTime = DateTime.utc(2026, 11, 4, 13, 30);
      expect(kitchen.isCurrentlyOpenAt(testTime), isTrue);
      expect(kitchen.getOpenStatusTextAt(testTime), equals('Open Now'));
    });

    test('Standard daytime hours (10:00 AM - 5:00 PM) - Exact boundary start (10:00 AM)', () {
      final kitchen = KitchenModel(
        id: 28,
        name: 'Coronita',
        businessHours: '10:00 AM - 5:00 PM',
        isOpen: true,
      );

      final testTime = DateTime.utc(2026, 11, 4, 10, 0);
      expect(kitchen.isCurrentlyOpenAt(testTime), isTrue);
    });

    test('Standard daytime hours (10:00 AM - 5:00 PM) - Exact boundary end (5:00 PM)', () {
      final kitchen = KitchenModel(
        id: 28,
        name: 'Coronita',
        businessHours: '10:00 AM - 5:00 PM',
        isOpen: true,
      );

      final testTime = DateTime.utc(2026, 11, 4, 17, 0);
      expect(kitchen.isCurrentlyOpenAt(testTime), isTrue);
    });

    test('Standard daytime hours (10:00 AM - 5:00 PM) - Closed after closing (5:01 PM)', () {
      final kitchen = KitchenModel(
        id: 28,
        name: 'Coronita',
        businessHours: '10:00 AM - 5:00 PM',
        isOpen: true,
      );

      final testTime = DateTime.utc(2026, 11, 4, 17, 1);
      expect(kitchen.isCurrentlyOpenAt(testTime), isFalse);
      expect(kitchen.getOpenStatusTextAt(testTime), equals('Closed'));
    });

    test('Manual toggle overrides business hours (isOpen = false)', () {
      final kitchen = KitchenModel(
        id: 28,
        name: 'Coronita',
        businessHours: '10:00 AM - 5:00 PM',
        isOpen: false, // Chef manually paused store
      );

      final testTime = DateTime.utc(2026, 11, 4, 12, 0); // Noon
      expect(kitchen.isCurrentlyOpenAt(testTime), isFalse);
      expect(kitchen.getOpenStatusTextAt(testTime), equals('Closed'));
    });

    test('Overnight business hours (6:00 PM - 2:00 AM)', () {
      final kitchen = KitchenModel(
        id: 99,
        name: 'Late Night Diner',
        businessHours: '6:00 PM - 2:00 AM',
        isOpen: true,
      );

      // 8:00 PM -> Open
      expect(kitchen.isCurrentlyOpenAt(DateTime.utc(2026, 11, 4, 20, 0)), isTrue);
      // 1:30 AM -> Open
      expect(kitchen.isCurrentlyOpenAt(DateTime.utc(2026, 11, 4, 1, 30)), isTrue);
      // 2:01 AM -> Closed
      expect(kitchen.isCurrentlyOpenAt(DateTime.utc(2026, 11, 4, 2, 1)), isFalse);
      // 12:00 PM (Noon) -> Closed
      expect(kitchen.isCurrentlyOpenAt(DateTime.utc(2026, 11, 4, 12, 0)), isFalse);
    });

    test('Different format: lowercase without space (10am - 5pm)', () {
      final kitchen = KitchenModel(
        id: 28,
        name: 'Coronita',
        businessHours: '10am - 5pm',
        isOpen: true,
      );

      expect(kitchen.isCurrentlyOpenAt(DateTime.utc(2026, 11, 4, 11, 0)), isTrue);
      expect(kitchen.isCurrentlyOpenAt(DateTime.utc(2026, 11, 4, 6, 0)), isFalse);
    });

    test('Different format: "to" separator (10:00 AM to 5:00 PM)', () {
      final kitchen = KitchenModel(
        id: 28,
        name: 'Coronita',
        businessHours: '10:00 AM to 5:00 PM',
        isOpen: true,
      );

      expect(kitchen.isCurrentlyOpenAt(DateTime.utc(2026, 11, 4, 14, 0)), isTrue);
      expect(kitchen.isCurrentlyOpenAt(DateTime.utc(2026, 11, 4, 21, 0)), isFalse);
    });

    test('Pacific Time Conversion from UTC', () {
      // Nov 4 is Pacific Standard Time (UTC-8)
      final utcNoon = DateTime.utc(2026, 11, 4, 20, 0); // 20:00 UTC
      final pt = KitchenModel.getPacificTime(utcNoon);
      expect(pt.hour, equals(12)); // 20 - 8 = 12:00 PM
    });
  });
}

