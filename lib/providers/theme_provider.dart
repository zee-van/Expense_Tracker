import 'package:expense_tracker/providers/services/theme_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/model/theme_model.dart';

final themeProvider = ChangeNotifierProvider<ThemeProvider>((ref) {
  return ThemeProvider(AppTheme.lightMode);
});
