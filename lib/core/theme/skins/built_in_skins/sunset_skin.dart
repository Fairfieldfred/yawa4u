import '../skin_model.dart';

/// Sunset Orange skin - warm and energetic.
const SkinModel sunsetSkinDefinition = SkinModel(
  id: 'sunset_orange',
  name: 'Sunset Orange',
  description: 'A warm, sunset-inspired theme for energetic workouts',
  author: 'YAWA4U',
  version: '1.0.0',
  isPremium: false,
  isBuiltIn: true,
  colors: SkinColors(
    primary: '#F57C00',
    primaryDark: '#E65100',
    primaryLight: '#FF9800',
    secondary: '#FF7043',
    success: '#8BC34A',
    warning: '#FFCA28',
    error: '#EF5350',
    info: '#FFB74D',
  ),
  lightMode: SkinModeColors(
    scaffoldBackground: '#FFF3E0',
    cardBackground: '#FFFFFF',
    inputBackground: '#FFF8E1',
    divider: '#FFE0B2',
    textPrimary: '#E65100',
    textSecondary: '#F57C00',
    textDisabled: '#FFCC80',
  ),
  darkMode: SkinModeColors(
    scaffoldBackground: '#2A1A0A',
    cardBackground: '#3D2814',
    inputBackground: '#2E1E10',
    divider: '#5D3A1A',
    textPrimary: '#FFF3E0',
    textSecondary: '#FFCC80',
    textDisabled: '#6D5040',
  ),
  muscleGroups: SkinMuscleGroupColors(
    upperPush: '#EC407A',
    upperPull: '#29B6F6',
    legs: '#26A69A',
    coreAndAccessories: '#AB47BC',
  ),
  workoutStatus: SkinWorkoutStatusColors(
    current: '#F57C00',
    completed: '#8BC34A',
    skipped: '#9E9E9E',
    deload: '#FFCA28',
  ),
  components: SkinComponents(
    cardBorderRadius: 16,
    buttonBorderRadius: 24,
    inputBorderRadius: 12,
    cardElevation: 3,
    buttonElevation: 2,
  ),
);
