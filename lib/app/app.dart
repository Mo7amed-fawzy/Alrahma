import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:alrahma/features/splash_trail/splash_view.dart';
import 'package:alrahma/features/home/cubit/theme_cubit.dart';

class Alrahma extends StatelessWidget {
  const Alrahma({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocProvider(
          create: (_) => ThemeCubit(),
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp(
                theme: ThemeData.light(useMaterial3: true),
                darkTheme: ThemeData.dark(useMaterial3: true),
                themeMode: themeMode, // ✅ ربط الثيم بالـ Cubit
                home: const SplashView(),
              );
            },
          ),
        );
      },
    );
  }
}
