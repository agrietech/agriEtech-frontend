import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:EthioFarm/core/models/user_model.dart';
import 'package:EthioFarm/features/auth/providers/auth_provider.dart';
import 'package:EthioFarm/features/auth/screens/login_screen.dart';
import 'package:EthioFarm/features/auth/screens/register_screen.dart';
import 'package:EthioFarm/features/auth/screens/profile_screen.dart';
import 'package:EthioFarm/features/auth/screens/role_application_screen.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Widget createTestWidget(Widget child, {List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('LoginScreen Standardization Tests', () {
    testWidgets('Renders dual tabs (Password and SMS OTP) and demo roles button', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Agricultural Command Access'), findsOneWidget);
      expect(find.byKey(const Key('tab_password_login')), findsOneWidget);
      expect(find.byKey(const Key('tab_otp_login')), findsOneWidget);
      expect(find.byKey(const Key('demo_accounts_button')), findsOneWidget);
      expect(find.byKey(const Key('phone_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('sign_in_button')), findsOneWidget);
    });

    testWidgets('Switching to SMS OTP tab displays Send SMS Login Code button', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tab_otp_login')));
      await tester.pumpAndSettle();

      expect(find.text('Send SMS Login Code'), findsOneWidget);
    });

    testWidgets('Tapping Demo Roles button displays modal sheet with verified roles', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('demo_accounts_button')));
      await tester.pumpAndSettle();

      expect(find.text('Select Enterprise Role for Testing'), findsOneWidget);
      expect(find.text('Smallholder Farmer (አርሶ አደር)'), findsOneWidget);
      expect(find.text('Development Agent (የልማት ጣቢያ)'), findsOneWidget);
      expect(find.text('Woreda Agronomy Officer (የወረዳ መኮንን)'), findsOneWidget);
    });

    testWidgets('Typing Ethio Telecom number detects and shows carrier badge', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('phone_field')), '0911223344');
      await tester.pumpAndSettle();

      expect(find.text('Ethio Telecom (ኢትዮ ቴሌኮም)'), findsOneWidget);
    });
  });

  group('RegisterScreen Guided Stepper Tests', () {
    testWidgets('Renders 3-step progress bar and Identity step initially', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const RegisterScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Register Account'), findsOneWidget);
      expect(find.text('Step 1 of 3: Identity & Security'), findsOneWidget);
      expect(find.textContaining('Full Name'), findsOneWidget);
      expect(find.textContaining('Ethiopian Mobile Phone'), findsOneWidget);
      expect(find.textContaining('Create Password'), findsOneWidget);
    });

    testWidgets('Can select role card and view role description in Step 2', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const RegisterScreen()));
      await tester.pumpAndSettle();

      // Enter valid step 0 fields
      await tester.enterText(find.widgetWithText(TextFormField, 'e.g. Abebe Balcha (አበበ ባልቻ)'), 'Abebe Balcha');
      await tester.enterText(find.widgetWithText(TextFormField, '911 234 567'), '0911223344');
      await tester.enterText(find.widgetWithText(TextFormField, 'Minimum 8 chars with uppercase & number'), 'Password123!');
      await tester.enterText(find.widgetWithText(TextFormField, 'Re-enter your password'), 'Password123!');
      await tester.pumpAndSettle();

      // Tap Continue
      await tester.tap(find.byKey(const Key('stepper_continue_button')));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 3: Role & Mandate Selection'), findsOneWidget);
      expect(find.byKey(const Key('role_card_FARMER')), findsOneWidget);
      expect(find.byKey(const Key('role_card_DEVELOPMENT_AGENT')), findsOneWidget);
      expect(find.byKey(const Key('role_card_WOREDA_OFFICER')), findsOneWidget);

      // Select Woreda Officer role
      await tester.tap(find.byKey(const Key('role_card_WOREDA_OFFICER')));
      await tester.pumpAndSettle();

      // Should show Institutional verification requirements
      expect(find.text('Institutional Mandate Verification'), findsOneWidget);
      expect(find.textContaining('Organization / Agricultural Bureau'), findsOneWidget);
    });
  });

  group('RoleApplicationScreen Standardization Tests', () {
    testWidgets('Renders current role card, governance hierarchy, and available roles', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const RoleApplicationScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Role & Governance Elevation'), findsOneWidget);
      expect(find.text('National Agricultural Governance Progression:'), findsOneWidget);
      expect(find.text('1. Select Desired Institutional Role'), findsOneWidget);
      expect(find.text('2. Target Operational Jurisdiction'), findsOneWidget);
      expect(find.text('3. Official Verification Credentials'), findsOneWidget);
    });
  });

  group('ProfileScreen Standardization Tests', () {
    testWidgets('Renders executive identity card, edit button, and contact details', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const dummyUser = UserModel(
        id: 'usr_farmer_01',
        phone: '0911223344',
        email: 'abebe@ethiofarm.et',
        fullName: 'Abebe Balcha',
        role: UserRole.farmer,
        kebeleName: 'Dobi Korme',
        isPhoneVerified: true,
      );

      await tester.pumpWidget(createTestWidget(
        const ProfileScreen(),
        overrides: [
          currentUserProvider.overrideWithValue(dummyUser),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Abebe Balcha'), findsOneWidget);
      expect(find.text('0911223344'), findsOneWidget);
      expect(find.text('abebe@ethiofarm.et'), findsOneWidget);
      expect(find.byKey(const Key('edit_profile_button')), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
    });

    testWidgets('Tapping Edit Profile button opens bottom sheet with editable fields', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const dummyUser = UserModel(
        id: 'usr_farmer_01',
        phone: '0911223344',
        fullName: 'Abebe Balcha',
        role: UserRole.farmer,
      );

      await tester.pumpWidget(createTestWidget(
        const ProfileScreen(),
        overrides: [
          currentUserProvider.overrideWithValue(dummyUser),
        ],
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('edit_profile_button')));
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile Information'), findsOneWidget);
      expect(find.byKey(const Key('save_profile_button')), findsOneWidget);
    });
  });
}
