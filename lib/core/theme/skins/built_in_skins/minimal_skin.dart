import '../skin_model.dart';

/// Minimal Monochrome skin - clean and distraction-free.
const SkinModel minimalSkinDefinition = SkinModel(
  id: 'minimal_mono',
  name: 'Minimal',
  description: 'A clean, monochrome theme for focused training',
  author: 'YAWA4U',
  version: '1.0.0',
  isPremium: false,
  isBuiltIn: true,
  colors: SkinColors(
    primary: '#424242',
    primaryDark: '#212121',
    primaryLight: '#616161',
    secondary: '#757575',
    success: '#66BB6A',
    warning: '#BDBDBD',
    error: '#EF5350',
    info: '#90A4AE',
  ),
  lightMode: SkinModeColors(
    scaffoldBackground: '#FAFAFA',
    cardBackground: '#FFFFFF',
    inputBackground: '#F5F5F5',
    divider: '#E0E0E0',
    textPrimary: '#212121',
    textSecondary: '#616161',
    textDisabled: '#BDBDBD',
  ),
  darkMode: SkinModeColors(
    scaffoldBackground: '#121212',
    cardBackground: '#1E1E1E',
    inputBackground: '#1A1A1A',
    divider: '#2C2C2C',
    textPrimary: '#FFFFFF',
    textSecondary: '#BDBDBD',
    textDisabled: '#616161',
  ),
  muscleGroups: SkinMuscleGroupColors(
    upperPush: '#F48FB1',
    upperPull: '#80DEEA',
    legs: '#80CBC4',
    coreAndAccessories: '#CE93D8',
  ),
  workoutStatus: SkinWorkoutStatusColors(
    current: '#424242',
    completed: '#66BB6A',
    skipped: '#9E9E9E',
    deload: '#BDBDBD',
  ),
  components: SkinComponents(
    cardBorderRadius: 4,
    buttonBorderRadius: 4,
    inputBorderRadius: 4,
    cardElevation: 1,
    buttonElevation: 0,
  ),
);
