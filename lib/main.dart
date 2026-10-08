import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/mock_provider_repository.dart';
import 'domain/repositories/provider_repository.dart';
import 'presentation/providers/category_list_provider.dart';
import 'presentation/providers/provider_list_provider.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(const FixItApp());
}

class FixItApp extends StatelessWidget {
  const FixItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ProviderRepository>(create: (_) => MockProviderRepository()),

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
