import 'package:flutter/material.dart';
import '../constants/app_strings.dart';

abstract class LocaleBase extends StatefulWidget {
  const LocaleBase({super.key});

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('pl'),
    Locale('de'),
    Locale('es'),
    Locale('it'),
  ];
}

abstract class LocaleBaseState<T extends LocaleBase> extends State<T> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Automatically update the AppStrings locale whenever system dependencies change
    final Locale locale = Localizations.localeOf(context);
    AppStrings.setLocale(locale.languageCode);
  }
}
