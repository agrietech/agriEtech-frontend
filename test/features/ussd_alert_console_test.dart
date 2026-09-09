import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:EthioFarm/features/analytics/screens/ussd_alert_console_screen.dart';
import 'package:EthioFarm/core/network/dio_client.dart';
import 'package:EthioFarm/core/storage/secure_storage_service.dart';

class FakeSecureStorage extends Fake implements SecureStorageService {
  @override
  Future<String?> getAccessToken() async => 'mock_jwt_token';
}

class MockHttpAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final responsePayload = jsonEncode({
      'success': true,
      'data': {
        'totalSignedUpFarmers': 45,
        'phoneReachableFarmers': 42,
        'reachabilityPercentage': 95,
        'recipientsCount': 42,
        'channels': ['USSD (*212#)', 'SMS'],
      },
    });
    return ResponseBody.fromString(
      responsePayload,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class TestDioClient extends DioClient {
  final Dio mockDio;
  TestDioClient(this.mockDio, SecureStorageService storage) : super(storage);

  @override
  Dio get dio => mockDio;
}

void main() {
  late TestDioClient testClient;

  setUp(() {
    final testDio = Dio()..httpClientAdapter = MockHttpAdapter();
    testClient = TestDioClient(testDio, FakeSecureStorage());
  });

  Widget createWidget() {
    return ProviderScope(
      overrides: [
        dioClientProvider.overrideWithValue(testClient),
      ],
      child: const MaterialApp(
        home: UssdAlertConsoleScreen(),
      ),
    );
  }

  group('UssdAlertConsoleScreen Tests', () {
    testWidgets('renders USSD Simulator and SMS/USSD Broadcast Console tabs', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Verify Screen Title
      expect(find.text('USSD *212# & Multi-Channel Console'), findsOneWidget);

      // Verify Tabs
      expect(find.text('USSD *212# Simulator'), findsOneWidget);
      expect(find.text('SMS Budget Engine'), findsOneWidget);

      // Verify Simulator controls
      expect(find.text('Dial *212# (Launch USSD Session)'), findsOneWidget);
      expect(find.text('Standardized *212# Quick Menus'), findsOneWidget);
    });

    testWidgets('switching to SMS Budget Engine tab displays Farmer Reach and Broadcast controls', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Tap on the SMS Budget Engine tab
      await tester.tap(find.text('SMS Budget Engine'));
      await tester.pumpAndSettle();

      // Verify Farmer Reach section
      expect(find.text('Target Woreda & Farmer Reach'), findsOneWidget);
      expect(find.textContaining('Farmers Reachable'), findsOneWidget);

      // Verify Channels
      expect(find.text('USSD *212# Push'), findsOneWidget);
      expect(find.text('Ethio Telecom SMS'), findsOneWidget);

      // Verify Quick Hazard Templates
      expect(find.text('Quick Hazard Templates:'), findsOneWidget);
      expect(find.text('☀️ Drought / ድርቅ'), findsOneWidget);
      expect(find.text('🌊 Flood / ጎርፍ'), findsOneWidget);

      // Verify Broadcast Action Button
      expect(find.text('📢 Broadcast Alert to Registered Farmers'), findsOneWidget);
    });

    testWidgets('tapping Flood quick hazard template updates alert text and severity', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Switch to Broadcast tab
      await tester.tap(find.text('SMS Budget Engine'));
      await tester.pumpAndSettle();

      // Tap the Flood template chip
      await tester.tap(find.text('🌊 Flood / ጎርፍ'));
      await tester.pumpAndSettle();

      // Verify text updated with Awash flood warning
      expect(find.textContaining('አዋሽ'), findsOneWidget);
      expect(find.text('🔴 Critical'), findsOneWidget);
    });
  });
}
