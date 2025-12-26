import '../skin_model.dart';

/// Ocean Blue skin - calm and focused.
const SkinModel oceanSkinDefinition = SkinModel(
  id: 'ocean_blue',
  name: 'Ocean Blue',
  description: 'A calm, ocean-inspired theme for focused training',
  author: 'YAWA4U',
  version: '1.0.0',
  isPremium: false,
  isBuiltIn: true,
  colors: SkinColors(
    primary: '#0288D1',
    primaryDark: '#01579B',
    primaryLight: '#03A9F4',
    secondary: '#00ACC1',
    success: '#00C853',
    warning: '#FFB300',
    error: '#FF5252',
    info: '#40C4FF',
  ),
  lightMode: SkinModeColors(
    scaffoldBackground: '#E3F2FD',
    cardBackground: '#FFFFFF',
    inputBackground: '#F5F5F5',
    divider: '#BBDEFB',
    textPrimary: '#0D47A1',
    textSecondary: '#1976D2',
    textDisabled: '#90CAF9',
  ),
  darkMode: SkinModeColors(
    scaffoldBackground: '#0D1B2A',
    cardBackground: '#1B2838',
    inputBackground: '#152238',
    divider: '#1E3A5F',
    textPrimary: '#E3F2FD',
    textSecondary: '#90CAF9',
    textDisabled: '#546E7A',
  ),
  muscleGroups: SkinMuscleGroupColors(
    upperPush: '#EC407A',
    upperPull: '#26C6DA',
    legs: '#26A69A',
    coreAndAccessories: '#AB47BC',
  ),
  workoutStatus: SkinWorkoutStatusColors(
    current: '#0288D1',
    completed: '#00C853',
    skipped: '#78909C',
    deload: '#FFB300',
  ),
  components: SkinComponents(
    cardBorderRadius: 16,
    buttonBorderRadius: 12,
    inputBorderRadius: 12,
    cardElevation: 1,
    buttonElevation: 1,
  ),
);
