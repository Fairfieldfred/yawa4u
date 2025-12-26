import '../skin_model.dart';

/// Default skin matching the original YAWA4U theme.
///
/// This is the red-accented theme that the app shipped with.
const SkinModel defaultSkinDefinition = SkinModel(
  id: 'default',
  name: 'Default',
  description: 'The original YAWA4U theme - energetic and motivational',
  author: 'YAWA4U',
  version: '1.0.0',
  isPremium: false,
  isBuiltIn: true,
  colors: SkinColors(
    primary: '#E53935',
    primaryDark: '#D32F2F',
    primaryLight: '#EF5350',
    secondary: '#42A5F5',
    success: '#4CAF50',
    warning: '#FFA726',
    error: '#EF5350',
    info: '#42A5F5',
  ),
  lightMode: SkinModeColors(
    scaffoldBackground: '#F2F2F7',
    cardBackground: '#FFFFFF',
    inputBackground: '#F9F9F9',
    divider: '#E0E0E0',
    textPrimary: '#212121',
    textSecondary: '#757575',
    textDisabled: '#BDBDBD',
  ),
  darkMode: SkinModeColors(
    scaffoldBackground: '#1C1C1E',
    cardBackground: '#2C2C2E',
    inputBackground: '#151516',
    divider: '#48484A',
    textPrimary: '#FFFFFF',
    textSecondary: '#9E9E9E',
    textDisabled: '#616161',
  ),
  muscleGroups: SkinMuscleGroupColors(
    upperPush: '#E91E63',
    upperPull: '#00BCD4',
    legs: '#009688',
    coreAndAccessories: '#9C27B0',
  ),
  workoutStatus: SkinWorkoutStatusColors(
    current: '#E53935',
    completed: '#4CAF50',
    skipped: '#757575',
    deload: '#FFA726',
  ),
  components: SkinComponents(
    cardBorderRadius: 12,
    buttonBorderRadius: 8,
    inputBorderRadius: 8,
    cardElevation: 2,
    buttonElevation: 2,
  ),
);
