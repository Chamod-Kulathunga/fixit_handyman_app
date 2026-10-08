import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/repositories/local_booking_repository.dart';
import 'data/repositories/mock_provider_repository.dart';
import 'domain/repositories/booking_repository.dart';
import 'domain/repositories/provider_repository.dart';
import 'presentation/providers/booking_provider.dart';
import 'presentation/providers/category_list_provider.dart';
import 'presentation/providers/provider_list_provider.dart';
import 'presentation/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();

  runApp(FixItApp(preferences: preferences));
}

class FixItApp extends StatelessWidget {
  final SharedPreferences preferences;

  const FixItApp({super.key, required this.preferences});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ProviderRepository>(create: (_) => MockProviderRepository()),

        Provider<BookingRepository>(
          create: (_) => LocalBookingRepository(preferences: preferences),
        ),

        ChangeNotifierProvider<ProviderListProvider>(
          create: (context) => ProviderListProvider(
            repository: context.read<ProviderRepository>(),
          ),
        ),

        ChangeNotifierProvider<CategoryListProvider>(
          create: (context) => CategoryListProvider(
            repository: context.read<ProviderRepository>(),
          ),
        ),

        ChangeNotifierProvider<BookingProvider>(
          create: (context) =>
              BookingProvider(repository: context.read<BookingRepository>()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FixIt',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
