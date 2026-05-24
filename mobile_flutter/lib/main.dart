import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_flutter/controllers/auth_controller.dart';
import 'package:mobile_flutter/controllers/kasir_controller.dart';
import 'package:mobile_flutter/controllers/pos_cart_controller.dart';
import 'package:mobile_flutter/controllers/payment_controller.dart';
import 'package:mobile_flutter/controllers/product_controller.dart';
import 'package:mobile_flutter/controllers/promo_controller.dart';
import 'package:mobile_flutter/controllers/report_controller.dart';
import 'package:mobile_flutter/controllers/order_controller.dart';
import 'package:mobile_flutter/controllers/table_controller.dart';
import 'package:mobile_flutter/screens/splash_screen.dart';
import 'package:mobile_flutter/screens/login_screen.dart';
import 'package:mobile_flutter/screens/kasir/kasir_layout.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter/blocs/auth/auth_bloc.dart';
import 'package:mobile_flutter/blocs/auth/auth_event.dart';
import 'package:mobile_flutter/cubits/theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(CheckLoginStatusEvent()),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, bool>(
        builder: (context, isDarkMode) {
          return GetMaterialApp(
            title: 'MenuKu',
            debugShowCheckedModeBanner: false,
            
            // Centralized Bindings: Daftarkan semua controller di sini agar tidak pernah NULL
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
        Get.put(KasirController(), permanent: true);
        Get.put(PosCartController(), permanent: true);
        Get.put(PaymentController(), permanent: true);
        Get.put(ProductController(), permanent: true);
        Get.put(PromoController(), permanent: true);
        Get.put(ReportController(), permanent: true);
        Get.put(OrderController(), permanent: true);
        Get.put(TableController(), permanent: true);
      }),
      
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.background,
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
        scaffoldBackgroundColor: AppColors.background,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => SplashScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/kasir', page: () => KasirLayout()),
      ],
    );
        },
      ),
    );
  }
}
