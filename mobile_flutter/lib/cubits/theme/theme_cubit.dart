import 'package:flutter_bloc/flutter_bloc.dart';

// Example Cubit as requested by the user
class ThemeCubit extends Cubit<bool> {
  // state == true means dark mode, false means light mode
  ThemeCubit() : super(false);

  void toggleTheme() => emit(!state);
}
