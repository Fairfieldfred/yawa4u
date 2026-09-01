import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('es')];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'YAWA4U'**
  String get appTitle;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Cancel button text (uppercase)
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancelUpper;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Save button text (uppercase)
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get saveUpper;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Delete button text (uppercase)
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteUpper;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Undo snackbar action label
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(Object error);

  /// Snackbar confirmation for note saved
  ///
  /// In en, this message translates to:
  /// **'Note saved'**
  String get noteSaved;

  /// Snackbar error when saving note fails
  ///
  /// In en, this message translates to:
  /// **'Error saving note: {error}'**
  String noteSaveError(Object error);

  /// Tooltip for theme toggle button
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get toggleThemeTooltip;

  /// Bottom nav label for workout/session tab
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get navSession;

  /// Bottom nav label for exercises tab
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get navExercises;

  /// Bottom nav label for calendar tab
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// Bottom nav label for more tab
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @trainingCycleStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get trainingCycleStatusDraft;

  /// No description provided for @trainingCycleStatusCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get trainingCycleStatusCurrent;

  /// No description provided for @trainingCycleStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get trainingCycleStatusCompleted;

  /// No description provided for @workoutStatusIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get workoutStatusIncomplete;

  /// No description provided for @workoutStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get workoutStatusCompleted;

  /// No description provided for @workoutStatusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get workoutStatusSkipped;

  /// No description provided for @setTypeRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get setTypeRegular;

  /// No description provided for @setTypeMyorep.
  ///
  /// In en, this message translates to:
  /// **'Myorep'**
  String get setTypeMyorep;

  /// No description provided for @setTypeMyorepMatch.
  ///
  /// In en, this message translates to:
  /// **'Myorep match'**
  String get setTypeMyorepMatch;

  /// No description provided for @setTypeMaxReps.
  ///
  /// In en, this message translates to:
  /// **'Max reps'**
  String get setTypeMaxReps;

  /// No description provided for @setTypeEndWithPartials.
  ///
  /// In en, this message translates to:
  /// **'End with partials'**
  String get setTypeEndWithPartials;

  /// No description provided for @setTypeDropSet.
  ///
  /// In en, this message translates to:
  /// **'Drop set'**
  String get setTypeDropSet;

  /// No description provided for @setTypeRegularDesc.
  ///
  /// In en, this message translates to:
  /// **'perform sets normally by hitting rep target or week over week RIR target'**
  String get setTypeRegularDesc;

  /// No description provided for @setTypeMyorepDesc.
  ///
  /// In en, this message translates to:
  /// **'take 5-15 second pauses between mini-sets of reps to hit rep target or week over week RIR target. Log total reps.'**
  String get setTypeMyorepDesc;

  /// No description provided for @setTypeMyorepMatchDesc.
  ///
  /// In en, this message translates to:
  /// **'take 5-15 second pauses between mini-sets of reps to match reps from your first set. Log total reps.'**
  String get setTypeMyorepMatchDesc;

  /// No description provided for @setTypeMaxRepsDesc.
  ///
  /// In en, this message translates to:
  /// **'perform as many reps as possible until failure'**
  String get setTypeMaxRepsDesc;

  /// No description provided for @setTypeEndWithPartialsDesc.
  ///
  /// In en, this message translates to:
  /// **'after reaching failure, continue with partial reps to further fatigue the muscle'**
  String get setTypeEndWithPartialsDesc;

  /// No description provided for @setTypeDropSetDesc.
  ///
  /// In en, this message translates to:
  /// **'immediately reduce weight and continue reps without rest to extend the set'**
  String get setTypeDropSetDesc;

  /// No description provided for @jointPainNone.
  ///
  /// In en, this message translates to:
  /// **'NONE'**
  String get jointPainNone;

  /// No description provided for @jointPainLow.
  ///
  /// In en, this message translates to:
  /// **'LOW PAIN'**
  String get jointPainLow;

  /// No description provided for @jointPainModerate.
  ///
  /// In en, this message translates to:
  /// **'MODERATE PAIN'**
  String get jointPainModerate;

  /// No description provided for @jointPainSevere.
  ///
  /// In en, this message translates to:
  /// **'A LOT OF PAIN'**
  String get jointPainSevere;

  /// No description provided for @musclePumpLow.
  ///
  /// In en, this message translates to:
  /// **'LOW PUMP'**
  String get musclePumpLow;

  /// No description provided for @musclePumpModerate.
  ///
  /// In en, this message translates to:
  /// **'MODERATE PUMP'**
  String get musclePumpModerate;

  /// No description provided for @musclePumpAmazing.
  ///
  /// In en, this message translates to:
  /// **'AMAZING PUMP'**
  String get musclePumpAmazing;

  /// No description provided for @workloadEasy.
  ///
  /// In en, this message translates to:
  /// **'EASY'**
  String get workloadEasy;

  /// No description provided for @workloadPrettyGood.
  ///
  /// In en, this message translates to:
  /// **'PRETTY GOOD'**
  String get workloadPrettyGood;

  /// No description provided for @workloadPushedLimits.
  ///
  /// In en, this message translates to:
  /// **'PUSHED MY LIMITS'**
  String get workloadPushedLimits;

  /// No description provided for @workloadTooMuch.
  ///
  /// In en, this message translates to:
  /// **'TOO MUCH'**
  String get workloadTooMuch;

  /// No description provided for @sorenessNeverGotSore.
  ///
  /// In en, this message translates to:
  /// **'NEVER GOT SORE'**
  String get sorenessNeverGotSore;

  /// No description provided for @sorenessHealedAWhileAgo.
  ///
  /// In en, this message translates to:
  /// **'HEALED A WHILE AGO'**
  String get sorenessHealedAWhileAgo;

  /// No description provided for @sorenessHealedJustOnTime.
  ///
  /// In en, this message translates to:
  /// **'HEALED JUST ON TIME'**
  String get sorenessHealedJustOnTime;

  /// No description provided for @sorenessStillSore.
  ///
  /// In en, this message translates to:
  /// **'I\'M STILL SORE!'**
  String get sorenessStillSore;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'MALE'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'FEMALE'**
  String get genderFemale;

  /// No description provided for @recoveryPeriodTypeDeload.
  ///
  /// In en, this message translates to:
  /// **'Deload'**
  String get recoveryPeriodTypeDeload;

  /// No description provided for @recoveryPeriodTypeTaper.
  ///
  /// In en, this message translates to:
  /// **'Taper'**
  String get recoveryPeriodTypeTaper;

  /// No description provided for @recoveryPeriodTypeRecovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get recoveryPeriodTypeRecovery;

  /// No description provided for @recoveryPeriodTypeDeloadDesc.
  ///
  /// In en, this message translates to:
  /// **'Reduce weight while maintaining volume'**
  String get recoveryPeriodTypeDeloadDesc;

  /// No description provided for @recoveryPeriodTypeTaperDesc.
  ///
  /// In en, this message translates to:
  /// **'Reduce volume while maintaining intensity'**
  String get recoveryPeriodTypeTaperDesc;

  /// No description provided for @recoveryPeriodTypeRecoveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Light training to promote active recovery'**
  String get recoveryPeriodTypeRecoveryDesc;

  /// No description provided for @trainingPhaseBase.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get trainingPhaseBase;

  /// No description provided for @trainingPhaseBuild.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get trainingPhaseBuild;

  /// No description provided for @trainingPhasePeak.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get trainingPhasePeak;

  /// No description provided for @trainingPhaseTaper.
  ///
  /// In en, this message translates to:
  /// **'Taper'**
  String get trainingPhaseTaper;

  /// No description provided for @trainingPhaseTransition.
  ///
  /// In en, this message translates to:
  /// **'Transition'**
  String get trainingPhaseTransition;

  /// No description provided for @trainingPhaseBaseDesc.
  ///
  /// In en, this message translates to:
  /// **'Aerobic foundation — high volume, low intensity'**
  String get trainingPhaseBaseDesc;

  /// No description provided for @trainingPhaseBuildDesc.
  ///
  /// In en, this message translates to:
  /// **'Build fitness — volume plus targeted intensity'**
  String get trainingPhaseBuildDesc;

  /// No description provided for @trainingPhasePeakDesc.
  ///
  /// In en, this message translates to:
  /// **'Race-specific intensity, reduced total volume'**
  String get trainingPhasePeakDesc;

  /// No description provided for @trainingPhaseTaperDesc.
  ///
  /// In en, this message translates to:
  /// **'Reduce volume sharply, keep touches of intensity'**
  String get trainingPhaseTaperDesc;

  /// No description provided for @trainingPhaseTransitionDesc.
  ///
  /// In en, this message translates to:
  /// **'Active recovery between training blocks'**
  String get trainingPhaseTransitionDesc;

  /// No description provided for @unitSystemImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get unitSystemImperial;

  /// No description provided for @unitSystemMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get unitSystemMetric;

  /// No description provided for @muscleGroupChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get muscleGroupChest;

  /// No description provided for @muscleGroupTriceps.
  ///
  /// In en, this message translates to:
  /// **'Triceps'**
  String get muscleGroupTriceps;

  /// No description provided for @muscleGroupShoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get muscleGroupShoulders;

  /// No description provided for @muscleGroupBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get muscleGroupBack;

  /// No description provided for @muscleGroupBiceps.
  ///
  /// In en, this message translates to:
  /// **'Biceps'**
  String get muscleGroupBiceps;

  /// No description provided for @muscleGroupQuads.
  ///
  /// In en, this message translates to:
  /// **'Quads'**
  String get muscleGroupQuads;

  /// No description provided for @muscleGroupHamstrings.
  ///
  /// In en, this message translates to:
  /// **'Hamstrings'**
  String get muscleGroupHamstrings;

  /// No description provided for @muscleGroupGlutes.
  ///
  /// In en, this message translates to:
  /// **'Glutes'**
  String get muscleGroupGlutes;

  /// No description provided for @muscleGroupCalves.
  ///
  /// In en, this message translates to:
  /// **'Calves'**
  String get muscleGroupCalves;

  /// No description provided for @muscleGroupTraps.
  ///
  /// In en, this message translates to:
  /// **'Traps'**
  String get muscleGroupTraps;

  /// No description provided for @muscleGroupForearms.
  ///
  /// In en, this message translates to:
  /// **'Forearms'**
  String get muscleGroupForearms;

  /// No description provided for @muscleGroupAbs.
  ///
  /// In en, this message translates to:
  /// **'Abs'**
  String get muscleGroupAbs;

  /// No description provided for @muscleGroupFullBody.
  ///
  /// In en, this message translates to:
  /// **'Full Body'**
  String get muscleGroupFullBody;

  /// No description provided for @muscleGroupAdductors.
  ///
  /// In en, this message translates to:
  /// **'Adductors'**
  String get muscleGroupAdductors;

  /// No description provided for @muscleGroupCore.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get muscleGroupCore;

  /// No description provided for @muscleGroupGrip.
  ///
  /// In en, this message translates to:
  /// **'Grip'**
  String get muscleGroupGrip;

  /// No description provided for @muscleGroupObliques.
  ///
  /// In en, this message translates to:
  /// **'Obliques'**
  String get muscleGroupObliques;

  /// No description provided for @equipmentBarbell.
  ///
  /// In en, this message translates to:
  /// **'Barbell'**
  String get equipmentBarbell;

  /// No description provided for @equipmentBodyweightLoadable.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight Loadable'**
  String get equipmentBodyweightLoadable;

  /// No description provided for @equipmentBodyweightOnly.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight Only'**
  String get equipmentBodyweightOnly;

  /// No description provided for @equipmentCable.
  ///
  /// In en, this message translates to:
  /// **'Cable'**
  String get equipmentCable;

  /// No description provided for @equipmentDumbbell.
  ///
  /// In en, this message translates to:
  /// **'Dumbbell'**
  String get equipmentDumbbell;

  /// No description provided for @equipmentFreemotion.
  ///
  /// In en, this message translates to:
  /// **'Freemotion'**
  String get equipmentFreemotion;

  /// No description provided for @equipmentKettlebell.
  ///
  /// In en, this message translates to:
  /// **'Kettlebell'**
  String get equipmentKettlebell;

  /// No description provided for @equipmentMachine.
  ///
  /// In en, this message translates to:
  /// **'Machine'**
  String get equipmentMachine;

  /// No description provided for @equipmentMachineAssistance.
  ///
  /// In en, this message translates to:
  /// **'Machine Assistance'**
  String get equipmentMachineAssistance;

  /// No description provided for @equipmentSmithMachine.
  ///
  /// In en, this message translates to:
  /// **'Smith Machine'**
  String get equipmentSmithMachine;

  /// No description provided for @equipmentBandAssistance.
  ///
  /// In en, this message translates to:
  /// **'Band Assistance'**
  String get equipmentBandAssistance;

  /// No description provided for @sportStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get sportStrength;

  /// No description provided for @sportRun.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get sportRun;

  /// No description provided for @sportBike.
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get sportBike;

  /// No description provided for @sportSwim.
  ///
  /// In en, this message translates to:
  /// **'Swim'**
  String get sportSwim;

  /// No description provided for @sportOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get sportOther;

  /// No description provided for @sessionSourcePlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get sessionSourcePlanned;

  /// No description provided for @sessionSourceLogged.
  ///
  /// In en, this message translates to:
  /// **'Logged'**
  String get sessionSourceLogged;

  /// No description provided for @sessionSourceAppleHealth.
  ///
  /// In en, this message translates to:
  /// **'Apple Health'**
  String get sessionSourceAppleHealth;

  /// No description provided for @sessionSourceHealthConnect.
  ///
  /// In en, this message translates to:
  /// **'Health Connect'**
  String get sessionSourceHealthConnect;

  /// No description provided for @sessionSourcePeloton.
  ///
  /// In en, this message translates to:
  /// **'Peloton'**
  String get sessionSourcePeloton;

  /// No description provided for @sessionSourceStrava.
  ///
  /// In en, this message translates to:
  /// **'Strava'**
  String get sessionSourceStrava;

  /// No description provided for @sessionSourceGarmin.
  ///
  /// In en, this message translates to:
  /// **'Garmin'**
  String get sessionSourceGarmin;

  /// No description provided for @sessionSourceImported.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get sessionSourceImported;

  /// No description provided for @intervalIntentWarmup.
  ///
  /// In en, this message translates to:
  /// **'Warm-up'**
  String get intervalIntentWarmup;

  /// No description provided for @intervalIntentWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get intervalIntentWork;

  /// No description provided for @intervalIntentRecovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get intervalIntentRecovery;

  /// No description provided for @intervalIntentCooldown.
  ///
  /// In en, this message translates to:
  /// **'Cool-down'**
  String get intervalIntentCooldown;

  /// No description provided for @intervalIntentRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get intervalIntentRest;

  /// No description provided for @intervalIntentRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get intervalIntentRepeat;

  /// No description provided for @intervalTargetDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get intervalTargetDuration;

  /// No description provided for @intervalTargetDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get intervalTargetDistance;

  /// No description provided for @intervalTargetHrZone.
  ///
  /// In en, this message translates to:
  /// **'HR zone'**
  String get intervalTargetHrZone;

  /// No description provided for @intervalTargetPaceZone.
  ///
  /// In en, this message translates to:
  /// **'Pace zone'**
  String get intervalTargetPaceZone;

  /// No description provided for @intervalTargetPowerZone.
  ///
  /// In en, this message translates to:
  /// **'Power zone'**
  String get intervalTargetPowerZone;

  /// No description provided for @intervalTargetFreeform.
  ///
  /// In en, this message translates to:
  /// **'Freeform'**
  String get intervalTargetFreeform;

  /// No description provided for @strokeTypeFreestyle.
  ///
  /// In en, this message translates to:
  /// **'Freestyle'**
  String get strokeTypeFreestyle;

  /// No description provided for @strokeTypeBackstroke.
  ///
  /// In en, this message translates to:
  /// **'Backstroke'**
  String get strokeTypeBackstroke;

  /// No description provided for @strokeTypeBreaststroke.
  ///
  /// In en, this message translates to:
  /// **'Breaststroke'**
  String get strokeTypeBreaststroke;

  /// No description provided for @strokeTypeButterfly.
  ///
  /// In en, this message translates to:
  /// **'Butterfly'**
  String get strokeTypeButterfly;

  /// No description provided for @strokeTypeMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get strokeTypeMixed;

  /// No description provided for @strokeTypeDrill.
  ///
  /// In en, this message translates to:
  /// **'Drill'**
  String get strokeTypeDrill;

  /// No description provided for @onboardingSportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your sports'**
  String get onboardingSportsTitle;

  /// No description provided for @onboardingSportsHeadline.
  ///
  /// In en, this message translates to:
  /// **'Which sports do you train?'**
  String get onboardingSportsHeadline;

  /// No description provided for @onboardingSportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick all that apply. You can add more later in Settings.'**
  String get onboardingSportsSubtitle;

  /// No description provided for @sportDescriptionStrength.
  ///
  /// In en, this message translates to:
  /// **'Lifting, hypertrophy, powerlifting'**
  String get sportDescriptionStrength;

  /// No description provided for @sportDescriptionRun.
  ///
  /// In en, this message translates to:
  /// **'Running, treadmill, trail'**
  String get sportDescriptionRun;

  /// No description provided for @sportDescriptionBike.
  ///
  /// In en, this message translates to:
  /// **'Road, trainer, MTB, spin (Peloton)'**
  String get sportDescriptionBike;

  /// No description provided for @sportDescriptionSwim.
  ///
  /// In en, this message translates to:
  /// **'Pool or open water'**
  String get sportDescriptionSwim;

  /// No description provided for @sportDescriptionOther.
  ///
  /// In en, this message translates to:
  /// **'Other activities'**
  String get sportDescriptionOther;

  /// No description provided for @onboardingTerminologyTitle.
  ///
  /// In en, this message translates to:
  /// **'Terminology'**
  String get onboardingTerminologyTitle;

  /// No description provided for @onboardingTerminologyHeadline.
  ///
  /// In en, this message translates to:
  /// **'What do you call a training cycle?'**
  String get onboardingTerminologyHeadline;

  /// No description provided for @onboardingTerminologySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the term you\'re most comfortable with. We\'ll use this throughout the app.'**
  String get onboardingTerminologySubtitle;

  /// No description provided for @getStartedButton.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStartedButton;

  /// No description provided for @trainingCycleTermBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get trainingCycleTermBlock;

  /// No description provided for @trainingCycleTermBlockDesc.
  ///
  /// In en, this message translates to:
  /// **'A focused training block with specific goals'**
  String get trainingCycleTermBlockDesc;

  /// No description provided for @trainingCycleTermMesocycle.
  ///
  /// In en, this message translates to:
  /// **'Mesocycle'**
  String get trainingCycleTermMesocycle;

  /// No description provided for @trainingCycleTermMesocycleDesc.
  ///
  /// In en, this message translates to:
  /// **'A structured training period typically lasting 3-6 weeks'**
  String get trainingCycleTermMesocycleDesc;

  /// No description provided for @trainingCycleTermModule.
  ///
  /// In en, this message translates to:
  /// **'Module'**
  String get trainingCycleTermModule;

  /// No description provided for @trainingCycleTermModuleDesc.
  ///
  /// In en, this message translates to:
  /// **'A modular training unit that can be stacked'**
  String get trainingCycleTermModuleDesc;

  /// No description provided for @trainingCycleTermPhase.
  ///
  /// In en, this message translates to:
  /// **'Phase'**
  String get trainingCycleTermPhase;

  /// No description provided for @trainingCycleTermPhaseDesc.
  ///
  /// In en, this message translates to:
  /// **'A training phase within your overall program'**
  String get trainingCycleTermPhaseDesc;

  /// No description provided for @trainingCycleTermWave.
  ///
  /// In en, this message translates to:
  /// **'Wave'**
  String get trainingCycleTermWave;

  /// No description provided for @trainingCycleTermWaveDesc.
  ///
  /// In en, this message translates to:
  /// **'A wave of progressive training intensity'**
  String get trainingCycleTermWaveDesc;

  /// No description provided for @onboardingEquipmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Your equipment'**
  String get onboardingEquipmentTitle;

  /// No description provided for @onboardingEquipmentHeadline.
  ///
  /// In en, this message translates to:
  /// **'What equipment do you have access to?'**
  String get onboardingEquipmentHeadline;

  /// No description provided for @onboardingEquipmentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply. This helps us suggest appropriate exercises.'**
  String get onboardingEquipmentSubtitle;

  /// No description provided for @onboardingEquipmentSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get onboardingEquipmentSkip;

  /// No description provided for @equipmentDumbbells.
  ///
  /// In en, this message translates to:
  /// **'Dumbbells'**
  String get equipmentDumbbells;

  /// No description provided for @equipmentHomeGymRack.
  ///
  /// In en, this message translates to:
  /// **'Home Gym Rack'**
  String get equipmentHomeGymRack;

  /// No description provided for @equipmentFunctionalTrainer.
  ///
  /// In en, this message translates to:
  /// **'Functional (Cable) Trainer'**
  String get equipmentFunctionalTrainer;

  /// No description provided for @equipmentGymMachines.
  ///
  /// In en, this message translates to:
  /// **'Gym Machines'**
  String get equipmentGymMachines;

  /// No description provided for @equipmentBarbells.
  ///
  /// In en, this message translates to:
  /// **'Barbells'**
  String get equipmentBarbells;

  /// No description provided for @equipmentKettlebells.
  ///
  /// In en, this message translates to:
  /// **'Kettlebells'**
  String get equipmentKettlebells;

  /// No description provided for @equipmentResistanceBands.
  ///
  /// In en, this message translates to:
  /// **'Resistance Bands'**
  String get equipmentResistanceBands;

  /// No description provided for @equipmentTreadmill.
  ///
  /// In en, this message translates to:
  /// **'Treadmill'**
  String get equipmentTreadmill;

  /// No description provided for @equipmentExerciseBike.
  ///
  /// In en, this message translates to:
  /// **'Exercise Bike'**
  String get equipmentExerciseBike;

  /// No description provided for @equipmentRowingMachine.
  ///
  /// In en, this message translates to:
  /// **'Rowing Machine'**
  String get equipmentRowingMachine;

  /// No description provided for @equipmentLapPool.
  ///
  /// In en, this message translates to:
  /// **'Lap Pool'**
  String get equipmentLapPool;

  /// No description provided for @equipmentCrossfitGym.
  ///
  /// In en, this message translates to:
  /// **'Crossfit Gym'**
  String get equipmentCrossfitGym;

  /// No description provided for @equipmentPullUpBar.
  ///
  /// In en, this message translates to:
  /// **'Pull-up Bar'**
  String get equipmentPullUpBar;

  /// No description provided for @equipmentSuspensionTrainer.
  ///
  /// In en, this message translates to:
  /// **'Suspension Trainer (TRX)'**
  String get equipmentSuspensionTrainer;

  /// No description provided for @onboardingProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get onboardingProfileTitle;

  /// No description provided for @onboardingProfileHeadline.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get to know you'**
  String get onboardingProfileHeadline;

  /// No description provided for @onboardingProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Height + weight let us track body metrics and show BMI. Icon preference is optional at the bottom.'**
  String get onboardingProfileSubtitle;

  /// No description provided for @unitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Units:'**
  String get unitsLabel;

  /// No description provided for @imperialLabel.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get imperialLabel;

  /// No description provided for @metricLabel.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get metricLabel;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightLabel;

  /// No description provided for @centimetersLabel.
  ///
  /// In en, this message translates to:
  /// **'Centimeters'**
  String get centimetersLabel;

  /// No description provided for @cmSuffix.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cmSuffix;

  /// No description provided for @feetLabel.
  ///
  /// In en, this message translates to:
  /// **'Feet'**
  String get feetLabel;

  /// No description provided for @ftSuffix.
  ///
  /// In en, this message translates to:
  /// **'ft'**
  String get ftSuffix;

  /// No description provided for @inchesLabel.
  ///
  /// In en, this message translates to:
  /// **'Inches'**
  String get inchesLabel;

  /// No description provided for @inSuffix.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get inSuffix;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightLabel;

  /// No description provided for @kilogramsLabel.
  ///
  /// In en, this message translates to:
  /// **'Kilograms'**
  String get kilogramsLabel;

  /// No description provided for @poundsLabel.
  ///
  /// In en, this message translates to:
  /// **'Pounds'**
  String get poundsLabel;

  /// No description provided for @kgSuffix.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kgSuffix;

  /// No description provided for @lbsSuffix.
  ///
  /// In en, this message translates to:
  /// **'lbs'**
  String get lbsSuffix;

  /// No description provided for @heightRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your height'**
  String get heightRequiredError;

  /// No description provided for @heightInvalidCmError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid height (100-250 cm)'**
  String get heightInvalidCmError;

  /// No description provided for @heightFeetRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get heightFeetRequiredError;

  /// No description provided for @heightInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get heightInvalidError;

  /// No description provided for @weightRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your weight'**
  String get weightRequiredError;

  /// No description provided for @weightInvalidNumberError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get weightInvalidNumberError;

  /// No description provided for @weightInvalidKgError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid weight (40-180 kg)'**
  String get weightInvalidKgError;

  /// No description provided for @weightInvalidLbsError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid weight (80-400 lbs)'**
  String get weightInvalidLbsError;

  /// No description provided for @bmiPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter height and weight to see BMI'**
  String get bmiPlaceholder;

  /// BMI display
  ///
  /// In en, this message translates to:
  /// **'BMI {bmiValue}'**
  String bmiValue(Object bmiValue);

  /// No description provided for @aboutBmiCategories.
  ///
  /// In en, this message translates to:
  /// **'About BMI categories'**
  String get aboutBmiCategories;

  /// No description provided for @bmiCategoryObese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get bmiCategoryObese;

  /// No description provided for @bmiCategoryOverweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get bmiCategoryOverweight;

  /// No description provided for @bmiCategoryNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get bmiCategoryNormal;

  /// No description provided for @bmiCategoryUnderweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get bmiCategoryUnderweight;

  /// No description provided for @bmiCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'BMI categories'**
  String get bmiCategoriesTitle;

  /// No description provided for @bmiGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Based on WHO / CDC guidelines'**
  String get bmiGuidelines;

  /// No description provided for @dexaScanTitle.
  ///
  /// In en, this message translates to:
  /// **'DEXA Scan Results'**
  String get dexaScanTitle;

  /// No description provided for @dexaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional - for bodybuilders'**
  String get dexaSubtitle;

  /// No description provided for @bodyFatLabel.
  ///
  /// In en, this message translates to:
  /// **'Body Fat'**
  String get bodyFatLabel;

  /// No description provided for @bodyFatSuffix.
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get bodyFatSuffix;

  /// No description provided for @bodyFatInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Invalid (3-60%)'**
  String get bodyFatInvalidError;

  /// No description provided for @leanMassLabel.
  ///
  /// In en, this message translates to:
  /// **'Lean Mass'**
  String get leanMassLabel;

  /// No description provided for @appIconTitle.
  ///
  /// In en, this message translates to:
  /// **'App icon (optional)'**
  String get appIconTitle;

  /// No description provided for @appIconSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Three variants — tap one to pick.'**
  String get appIconSubtitle;

  /// AppBar title for create cycle
  ///
  /// In en, this message translates to:
  /// **'Create {cycleTerm}'**
  String cycleCreateTitle(Object cycleTerm);

  /// No description provided for @cycleCreateHeading.
  ///
  /// In en, this message translates to:
  /// **'New {cycleTerm}'**
  String cycleCreateHeading(Object cycleTerm);

  /// No description provided for @cycleCreateDescription.
  ///
  /// In en, this message translates to:
  /// **'A {cycleTerm} is a multi-period training program with progressive overload, often followed by a recovery period to allow your body to rest and adapt.'**
  String cycleCreateDescription(Object cycleTerm);

  /// No description provided for @cycleCreateNameLabel.
  ///
  /// In en, this message translates to:
  /// **'{cycleTerm} Name'**
  String cycleCreateNameLabel(Object cycleTerm);

  /// No description provided for @cycleCreateNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Spring 2025 Hypertrophy'**
  String get cycleCreateNameHint;

  /// No description provided for @cycleCreateNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get cycleCreateNameRequired;

  /// No description provided for @cycleCreateNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get cycleCreateNameMinLength;

  /// No description provided for @cycleCreateNameEmptySnackbar.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name for your {cycleTerm}'**
  String cycleCreateNameEmptySnackbar(Object cycleTerm);

  /// No description provided for @cycleCreatePrimarySportHeader.
  ///
  /// In en, this message translates to:
  /// **'Primary sport (optional)'**
  String get cycleCreatePrimarySportHeader;

  /// No description provided for @cycleCreatePrimarySportDesc.
  ///
  /// In en, this message translates to:
  /// **'Hints which sport the cycle is built around. Does not restrict what sessions you can add — every cycle can mix any sports.'**
  String get cycleCreatePrimarySportDesc;

  /// No description provided for @cycleCreateDurationHeader.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get cycleCreateDurationHeader;

  /// No description provided for @cycleCreateTrainingFrequencyHeader.
  ///
  /// In en, this message translates to:
  /// **'Training Frequency'**
  String get cycleCreateTrainingFrequencyHeader;

  /// No description provided for @cycleCreateRecoveryHeader.
  ///
  /// In en, this message translates to:
  /// **'Recovery Period (Optional)'**
  String get cycleCreateRecoveryHeader;

  /// No description provided for @cycleCreateTemplateHeader.
  ///
  /// In en, this message translates to:
  /// **'Template (Optional)'**
  String get cycleCreateTemplateHeader;

  /// No description provided for @cycleCreateCreatingButton.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get cycleCreateCreatingButton;

  /// No description provided for @cycleCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create {cycleTerm}'**
  String cycleCreateButton(Object cycleTerm);

  /// No description provided for @cycleCreateTotalPeriods.
  ///
  /// In en, this message translates to:
  /// **'Total Periods'**
  String get cycleCreateTotalPeriods;

  /// No description provided for @cycleCreatePeriodsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} periods'**
  String cycleCreatePeriodsCount(Object count);

  /// No description provided for @cycleCreatePeriodsRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Recommended: 4-6 periods for hypertrophy'**
  String get cycleCreatePeriodsRecommendation;

  /// No description provided for @cycleCreateTrainingDays.
  ///
  /// In en, this message translates to:
  /// **'Training Days'**
  String get cycleCreateTrainingDays;

  /// No description provided for @cycleCreateDaysPerPeriod.
  ///
  /// In en, this message translates to:
  /// **'{count} days/period'**
  String cycleCreateDaysPerPeriod(Object count);

  /// No description provided for @cycleCreateDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String cycleCreateDaysLabel(Object count);

  /// No description provided for @cycleCreateSplit2.
  ///
  /// In en, this message translates to:
  /// **'Minimalist full body split'**
  String get cycleCreateSplit2;

  /// No description provided for @cycleCreateSplit3.
  ///
  /// In en, this message translates to:
  /// **'Full body or Push/Pull/Legs split'**
  String get cycleCreateSplit3;

  /// No description provided for @cycleCreateSplit4.
  ///
  /// In en, this message translates to:
  /// **'Upper/Lower or Push/Pull/Legs + Upper'**
  String get cycleCreateSplit4;

  /// No description provided for @cycleCreateSplit5.
  ///
  /// In en, this message translates to:
  /// **'Push/Pull/Legs/Upper/Lower split'**
  String get cycleCreateSplit5;

  /// No description provided for @cycleCreateSplit6.
  ///
  /// In en, this message translates to:
  /// **'Push/Pull/Legs twice per period'**
  String get cycleCreateSplit6;

  /// No description provided for @cycleCreateSplit7.
  ///
  /// In en, this message translates to:
  /// **'Daily training (7-day cycle)'**
  String get cycleCreateSplit7;

  /// No description provided for @cycleCreateSplit8.
  ///
  /// In en, this message translates to:
  /// **'8-day training cycle with rest day'**
  String get cycleCreateSplit8;

  /// No description provided for @cycleCreateSplit9.
  ///
  /// In en, this message translates to:
  /// **'9-day training cycle (e.g., 3-on/1-off)'**
  String get cycleCreateSplit9;

  /// No description provided for @cycleCreateSplit10.
  ///
  /// In en, this message translates to:
  /// **'10-day training cycle'**
  String get cycleCreateSplit10;

  /// No description provided for @cycleCreateSplit11.
  ///
  /// In en, this message translates to:
  /// **'11-day training cycle'**
  String get cycleCreateSplit11;

  /// No description provided for @cycleCreateSplit12.
  ///
  /// In en, this message translates to:
  /// **'12-day training cycle'**
  String get cycleCreateSplit12;

  /// No description provided for @cycleCreateSplit13.
  ///
  /// In en, this message translates to:
  /// **'13-day training cycle'**
  String get cycleCreateSplit13;

  /// No description provided for @cycleCreateSplit14.
  ///
  /// In en, this message translates to:
  /// **'14-day (bi-weekly) training cycle'**
  String get cycleCreateSplit14;

  /// No description provided for @cycleCreateSplitGeneric.
  ///
  /// In en, this message translates to:
  /// **'{count}-day training cycle'**
  String cycleCreateSplitGeneric(Object count);

  /// No description provided for @cycleCreateIncludeRecoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Include Recovery Period'**
  String get cycleCreateIncludeRecoveryTitle;

  /// No description provided for @cycleCreateIncludeRecoverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'A lighter period to aid recovery and prevent overtraining'**
  String get cycleCreateIncludeRecoverySubtitle;

  /// No description provided for @cycleCreateRecoveryType.
  ///
  /// In en, this message translates to:
  /// **'Recovery Type'**
  String get cycleCreateRecoveryType;

  /// No description provided for @cycleCreateRecoveryOnPeriod.
  ///
  /// In en, this message translates to:
  /// **'{recoveryType} on Period'**
  String cycleCreateRecoveryOnPeriod(Object recoveryType);

  /// No description provided for @cycleCreatePeriodNumber.
  ///
  /// In en, this message translates to:
  /// **'Period {number}'**
  String cycleCreatePeriodNumber(Object number);

  /// No description provided for @cycleCreateRecoveryScheduleHint.
  ///
  /// In en, this message translates to:
  /// **'Most people schedule this on the last period'**
  String get cycleCreateRecoveryScheduleHint;

  /// No description provided for @cycleCreateChooseTemplate.
  ///
  /// In en, this message translates to:
  /// **'Choose a Template'**
  String get cycleCreateChooseTemplate;

  /// No description provided for @cycleCreateTemplateNone.
  ///
  /// In en, this message translates to:
  /// **'None (Custom)'**
  String get cycleCreateTemplateNone;

  /// No description provided for @cycleCreateTemplateHint.
  ///
  /// In en, this message translates to:
  /// **'Templates provide pre-configured training splits with strength exercises'**
  String get cycleCreateTemplateHint;

  /// No description provided for @cycleCreateErrorLoadingTemplates.
  ///
  /// In en, this message translates to:
  /// **'Error loading templates: {error}'**
  String cycleCreateErrorLoadingTemplates(Object error);

  /// No description provided for @cycleCreateSuccessSnackbar.
  ///
  /// In en, this message translates to:
  /// **'{cycleTerm} \"{name}\" created!'**
  String cycleCreateSuccessSnackbar(Object cycleTerm, Object name);

  /// No description provided for @cycleCreateMixedChipLabel.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get cycleCreateMixedChipLabel;

  /// No description provided for @cycleListNewButton.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get cycleListNewButton;

  /// No description provided for @cycleListDraftSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Draft {cycleTerm}'**
  String cycleListDraftSectionHeader(Object cycleTerm);

  /// No description provided for @cycleListCurrentSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Current {cycleTerm}'**
  String cycleListCurrentSectionHeader(Object cycleTerm);

  /// No description provided for @cycleListCompletedSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Completed {cycleTermPlural}'**
  String cycleListCompletedSectionHeader(Object cycleTermPlural);

  /// No description provided for @cycleListErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading trainingCycles: {error}'**
  String cycleListErrorLoading(Object error);

  /// No description provided for @cycleListCurrentBadge.
  ///
  /// In en, this message translates to:
  /// **'CURRENT'**
  String get cycleListCurrentBadge;

  /// No description provided for @cycleListPeriodsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} periods'**
  String cycleListPeriodsCount(Object count);

  /// No description provided for @cycleListDaysPerPeriod.
  ///
  /// In en, this message translates to:
  /// **'{count} days/period'**
  String cycleListDaysPerPeriod(Object count);

  /// No description provided for @cycleListStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get cycleListStartButton;

  /// No description provided for @cycleListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No TrainingCycles'**
  String get cycleListEmptyTitle;

  /// No description provided for @cycleListEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first trainingCycle to get started'**
  String get cycleListEmptySubtitle;

  /// No description provided for @cycleListCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create New'**
  String get cycleListCreateNew;

  /// No description provided for @cycleListStartFromTemplate.
  ///
  /// In en, this message translates to:
  /// **'Start from Template'**
  String get cycleListStartFromTemplate;

  /// No description provided for @cycleListMenuWriteNote.
  ///
  /// In en, this message translates to:
  /// **'Write a new note'**
  String get cycleListMenuWriteNote;

  /// No description provided for @cycleListMenuRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get cycleListMenuRename;

  /// No description provided for @cycleListMenuCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy the {cycleTerm}'**
  String cycleListMenuCopy(Object cycleTerm);

  /// No description provided for @cycleListMenuSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get cycleListMenuSummary;

  /// No description provided for @cycleListMenuRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart {cycleTerm}'**
  String cycleListMenuRestart(Object cycleTerm);

  /// No description provided for @cycleListMenuSaveAsTemplate.
  ///
  /// In en, this message translates to:
  /// **'Save as a Template'**
  String get cycleListMenuSaveAsTemplate;

  /// No description provided for @cycleListMenuShareQR.
  ///
  /// In en, this message translates to:
  /// **'Share (Host QR Code)'**
  String get cycleListMenuShareQR;

  /// No description provided for @cycleListMenuExportDebug.
  ///
  /// In en, this message translates to:
  /// **'Export (Debug)'**
  String get cycleListMenuExportDebug;

  /// No description provided for @cycleListMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete {cycleTerm}'**
  String cycleListMenuDelete(Object cycleTerm);

  /// No description provided for @cycleListStartDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Start {cycleTerm}'**
  String cycleListStartDialogTitle(Object cycleTerm);

  /// No description provided for @cycleListStartDialogNoActive.
  ///
  /// In en, this message translates to:
  /// **'Start \"{name}\"? This will set it as your current {cycleTerm}.'**
  String cycleListStartDialogNoActive(Object name, Object cycleTerm);

  /// No description provided for @cycleListStartDialogHasActive.
  ///
  /// In en, this message translates to:
  /// **'You have an active {cycleTerm}: \"{activeNames}\".\n\nHow would you like to start \"{name}\"?'**
  String cycleListStartDialogHasActive(Object cycleTerm, Object activeNames, Object name);

  /// No description provided for @cycleListReplaceCurrentButton.
  ///
  /// In en, this message translates to:
  /// **'Replace current'**
  String get cycleListReplaceCurrentButton;

  /// No description provided for @cycleListStackAlongsideButton.
  ///
  /// In en, this message translates to:
  /// **'Stack alongside'**
  String get cycleListStackAlongsideButton;

  /// No description provided for @cycleListNoteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'{cycleTerm} Note'**
  String cycleListNoteDialogTitle(Object cycleTerm);

  /// No description provided for @cycleListNoteDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Enter note for this {cycleTerm}...'**
  String cycleListNoteDialogHint(Object cycleTerm);

  /// No description provided for @cycleListCopyNameSuffix.
  ///
  /// In en, this message translates to:
  /// **'{name} (Copy)'**
  String cycleListCopyNameSuffix(Object name);

  /// No description provided for @cycleListCopiedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'{cycleTerm} copied as draft!'**
  String cycleListCopiedSnackbar(Object cycleTerm);

  /// No description provided for @cycleListErrorCopying.
  ///
  /// In en, this message translates to:
  /// **'Error copying {cycleTerm}: {error}'**
  String cycleListErrorCopying(Object cycleTerm, Object error);

  /// No description provided for @cycleListRestartDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart {cycleTerm}'**
  String cycleListRestartDialogTitle(Object cycleTerm);

  /// No description provided for @cycleListRestartDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Restart \"{name}\"? This will create a copy and set it as your current {cycleTerm}.'**
  String cycleListRestartDialogContent(Object name, Object cycleTerm);

  /// No description provided for @cycleListRestartButton.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get cycleListRestartButton;

  /// No description provided for @cycleListRestartedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'{cycleTerm} restarted!'**
  String cycleListRestartedSnackbar(Object cycleTerm);

  /// No description provided for @cycleListErrorRestarting.
  ///
  /// In en, this message translates to:
  /// **'Error restarting {cycleTerm}: {error}'**
  String cycleListErrorRestarting(Object cycleTerm, Object error);

  /// No description provided for @cycleListTemplateSaved.
  ///
  /// In en, this message translates to:
  /// **'Template \"{name}\" saved!'**
  String cycleListTemplateSaved(Object name);

  /// No description provided for @cycleListErrorSavingTemplate.
  ///
  /// In en, this message translates to:
  /// **'Error saving template: {error}'**
  String cycleListErrorSavingTemplate(Object error);

  /// No description provided for @cycleListPreparingShare.
  ///
  /// In en, this message translates to:
  /// **'Preparing to share...'**
  String get cycleListPreparingShare;

  /// No description provided for @cycleListSharedFromDescription.
  ///
  /// In en, this message translates to:
  /// **'Shared from {name}'**
  String cycleListSharedFromDescription(Object name);

  /// No description provided for @cycleListErrorPreparingShare.
  ///
  /// In en, this message translates to:
  /// **'Error preparing template for sharing: {error}'**
  String cycleListErrorPreparingShare(Object error);

  /// No description provided for @cycleListTemplateExported.
  ///
  /// In en, this message translates to:
  /// **'Template JSON copied to clipboard!'**
  String get cycleListTemplateExported;

  /// No description provided for @cycleListErrorExporting.
  ///
  /// In en, this message translates to:
  /// **'Error exporting template: {error}'**
  String cycleListErrorExporting(Object error);

  /// No description provided for @cycleListRenamedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Renamed to \"{name}\"'**
  String cycleListRenamedSnackbar(Object name);

  /// No description provided for @cycleListErrorRenaming.
  ///
  /// In en, this message translates to:
  /// **'Error renaming trainingCycle: {error}'**
  String cycleListErrorRenaming(Object error);

  /// No description provided for @cycleListDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Draft TrainingCycle'**
  String get cycleListDeleteDialogTitle;

  /// No description provided for @cycleListDeleteDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String cycleListDeleteDialogContent(Object name);

  /// No description provided for @cycleListDeletedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" deleted'**
  String cycleListDeletedSnackbar(Object name);

  /// No description provided for @cycleListErrorDeleting.
  ///
  /// In en, this message translates to:
  /// **'Error deleting trainingCycle: {error}'**
  String cycleListErrorDeleting(Object error);

  /// No description provided for @cycleListMenuComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get cycleListMenuComplete;

  /// No description provided for @cycleListCompleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete {cycleTerm}'**
  String cycleListCompleteDialogTitle(Object cycleTerm);

  /// No description provided for @cycleListCompleteDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Mark \"{name}\" as completed? Your history is preserved and the {cycleTerm} moves to your completed list.'**
  String cycleListCompleteDialogContent(Object name, Object cycleTerm);

  /// No description provided for @cycleListCompleteAction.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get cycleListCompleteAction;

  /// No description provided for @cycleListCompletedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" marked as completed'**
  String cycleListCompletedSnackbar(Object name);

  /// No description provided for @cycleListErrorCompleting.
  ///
  /// In en, this message translates to:
  /// **'Error completing trainingCycle: {error}'**
  String cycleListErrorCompleting(Object error);

  /// No description provided for @cycleListRenameDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get cycleListRenameDialogTitle;

  /// No description provided for @cycleListRenameDialogHint.
  ///
  /// In en, this message translates to:
  /// **'TrainingCycle name'**
  String get cycleListRenameDialogHint;

  /// No description provided for @cycleListSaveTemplateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save as Template'**
  String get cycleListSaveTemplateDialogTitle;

  /// No description provided for @cycleListSaveTemplateNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Template Name'**
  String get cycleListSaveTemplateNameLabel;

  /// No description provided for @cycleListSaveTemplateNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., \"Upper Lower Split\"'**
  String get cycleListSaveTemplateNameHint;

  /// No description provided for @cycleListSaveTemplateNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a template name'**
  String get cycleListSaveTemplateNameError;

  /// No description provided for @cycleListSaveTemplateDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get cycleListSaveTemplateDescLabel;

  /// No description provided for @cycleListSaveTemplateDescHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., \"Great for building strength and size\"'**
  String get cycleListSaveTemplateDescHint;

  /// No description provided for @cycleListSaveTemplateDescError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get cycleListSaveTemplateDescError;

  /// No description provided for @templateSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a Program'**
  String get templateSelectionTitle;

  /// No description provided for @templateSelectionNoTemplates.
  ///
  /// In en, this message translates to:
  /// **'No templates available'**
  String get templateSelectionNoTemplates;

  /// No description provided for @templateSelectionBrowseCommunity.
  ///
  /// In en, this message translates to:
  /// **'Browse Community'**
  String get templateSelectionBrowseCommunity;

  /// No description provided for @templateSelectionBrowseCommunitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download programs shared by other users'**
  String get templateSelectionBrowseCommunitySubtitle;

  /// No description provided for @templateSelectionDaysPerPeriod.
  ///
  /// In en, this message translates to:
  /// **'{count} Days/Period'**
  String templateSelectionDaysPerPeriod(Object count);

  /// No description provided for @templateSelectionPeriodsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Periods'**
  String templateSelectionPeriodsCount(Object count);

  /// No description provided for @templateSelectionSessionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Sessions'**
  String templateSelectionSessionsCount(Object count);

  /// No description provided for @templateSelectionDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Template?'**
  String get templateSelectionDeleteTitle;

  /// No description provided for @templateSelectionDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String templateSelectionDeleteContent(Object name);

  /// No description provided for @templateSelectionDeletedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Template \"{name}\" deleted'**
  String templateSelectionDeletedSnackbar(Object name);

  /// No description provided for @templateSelectionDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete template: {error}'**
  String templateSelectionDeleteError(Object error);

  /// No description provided for @templatePreviewLoadProgram.
  ///
  /// In en, this message translates to:
  /// **'LOAD PROGRAM'**
  String get templatePreviewLoadProgram;

  /// No description provided for @templatePreviewErrorCreating.
  ///
  /// In en, this message translates to:
  /// **'Error creating program: {error}'**
  String templatePreviewErrorCreating(Object error);

  /// No description provided for @templatePreviewDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get templatePreviewDuration;

  /// No description provided for @templatePreviewPerPeriod.
  ///
  /// In en, this message translates to:
  /// **'Per Period'**
  String get templatePreviewPerPeriod;

  /// No description provided for @templatePreviewRecovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get templatePreviewRecovery;

  /// No description provided for @templatePreviewPeriodHeader.
  ///
  /// In en, this message translates to:
  /// **'Period {number}'**
  String templatePreviewPeriodHeader(Object number);

  /// No description provided for @templatePreviewPeriodRecoveryHeader.
  ///
  /// In en, this message translates to:
  /// **'Period {number} (Recovery)'**
  String templatePreviewPeriodRecoveryHeader(Object number);

  /// No description provided for @templatePreviewDayFallback.
  ///
  /// In en, this message translates to:
  /// **'Day {number}'**
  String templatePreviewDayFallback(Object number);

  /// Generic fallback title for a session without a label or day name
  ///
  /// In en, this message translates to:
  /// **'Day {number}'**
  String sessionDayFallback(Object number);

  /// No description provided for @templatePreviewCardioSession.
  ///
  /// In en, this message translates to:
  /// **'{sport} session'**
  String templatePreviewCardioSession(Object sport);

  /// No description provided for @templatePreviewExerciseCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Exercises'**
  String templatePreviewExerciseCount(Object count);

  /// No description provided for @templatePreviewSetsReps.
  ///
  /// In en, this message translates to:
  /// **'{sets} sets × {reps}'**
  String templatePreviewSetsReps(Object sets, Object reps);

  /// No description provided for @templatePreviewDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Days'**
  String templatePreviewDaysCount(Object count);

  /// No description provided for @planCycleTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan a {cycleTerm}'**
  String planCycleTitle(Object cycleTerm);

  /// No description provided for @planCycleStartWithTemplate.
  ///
  /// In en, this message translates to:
  /// **'Start with a template'**
  String get planCycleStartWithTemplate;

  /// No description provided for @planCycleStartWithTemplateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a template that fits your goals and get started ASAP.'**
  String get planCycleStartWithTemplateSubtitle;

  /// No description provided for @planCycleStartFromScratch.
  ///
  /// In en, this message translates to:
  /// **'Start from scratch'**
  String get planCycleStartFromScratch;

  /// No description provided for @planCycleStartFromScratchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build your own {cycleTerm} from a completely blank slate.'**
  String planCycleStartFromScratchSubtitle(Object cycleTerm);

  /// No description provided for @workoutSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get workoutSessionTitle;

  /// No description provided for @workoutPeriodDayTitle.
  ///
  /// In en, this message translates to:
  /// **'PERIOD {period} DAY {day} {dayName}'**
  String workoutPeriodDayTitle(Object period, Object day, Object dayName);

  /// No description provided for @workoutCycleCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'{cycleTerm} Completed!'**
  String workoutCycleCompletedTitle(Object cycleTerm);

  /// No description provided for @workoutCycleCompletedContent.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You have finished all workouts in this {cycleTerm}.'**
  String workoutCycleCompletedContent(Object cycleTerm);

  /// No description provided for @workoutCycleCompletedAction.
  ///
  /// In en, this message translates to:
  /// **'AWESOME'**
  String get workoutCycleCompletedAction;

  /// No description provided for @workoutEndCycleTitle.
  ///
  /// In en, this message translates to:
  /// **'End {cycleTerm}'**
  String workoutEndCycleTitle(Object cycleTerm);

  /// No description provided for @workoutEndCycleContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to end \"{name}\"? This will mark it as completed.'**
  String workoutEndCycleContent(Object name);

  /// No description provided for @workoutEndCycleAction.
  ///
  /// In en, this message translates to:
  /// **'END {cycleTerm}'**
  String workoutEndCycleAction(Object cycleTerm);

  /// No description provided for @workoutCycleCompleted.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" completed'**
  String workoutCycleCompleted(Object name);

  /// No description provided for @workoutEndCycleError.
  ///
  /// In en, this message translates to:
  /// **'Error ending trainingCycle: {error}'**
  String workoutEndCycleError(Object error);

  /// No description provided for @workoutFinishButton.
  ///
  /// In en, this message translates to:
  /// **'FINISH WORKOUT'**
  String get workoutFinishButton;

  /// No description provided for @workoutFinishLabel.
  ///
  /// In en, this message translates to:
  /// **'Finish workout'**
  String get workoutFinishLabel;

  /// No description provided for @workoutSelectDayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select day'**
  String get workoutSelectDayTooltip;

  /// No description provided for @workoutAddSessionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add session'**
  String get workoutAddSessionTooltip;

  /// No description provided for @workoutAppLogoLabel.
  ///
  /// In en, this message translates to:
  /// **'App logo'**
  String get workoutAppLogoLabel;

  /// No description provided for @workoutSetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Set {setNumber} deleted'**
  String workoutSetDeleted(Object setNumber);

  /// No description provided for @workoutExerciseDeleted.
  ///
  /// In en, this message translates to:
  /// **'{exerciseName} deleted'**
  String workoutExerciseDeleted(Object exerciseName);

  /// No description provided for @workoutCardioSessionDeleted.
  ///
  /// In en, this message translates to:
  /// **'{label} deleted'**
  String workoutCardioSessionDeleted(Object label);

  /// No description provided for @workoutRenamedTo.
  ///
  /// In en, this message translates to:
  /// **'Renamed to \"{name}\"'**
  String workoutRenamedTo(Object name);

  /// No description provided for @workoutRenameError.
  ///
  /// In en, this message translates to:
  /// **'Error renaming trainingCycle: {error}'**
  String workoutRenameError(Object error);

  /// No description provided for @workoutLabelUpdated.
  ///
  /// In en, this message translates to:
  /// **'Label updated'**
  String get workoutLabelUpdated;

  /// No description provided for @workoutLabelUpdatedForAllDays.
  ///
  /// In en, this message translates to:
  /// **'Updated label for all Day {dayNumber} workouts'**
  String workoutLabelUpdatedForAllDays(Object dayNumber);

  /// No description provided for @workoutLabelUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating label: {error}'**
  String workoutLabelUpdateError(Object error);

  /// No description provided for @workoutAllDayLabelsCleared.
  ///
  /// In en, this message translates to:
  /// **'All day labels cleared'**
  String get workoutAllDayLabelsCleared;

  /// No description provided for @workoutClearLabelsError.
  ///
  /// In en, this message translates to:
  /// **'Error clearing labels: {error}'**
  String workoutClearLabelsError(Object error);

  /// No description provided for @workoutReset.
  ///
  /// In en, this message translates to:
  /// **'Workout reset'**
  String get workoutReset;

  /// No description provided for @workoutResetError.
  ///
  /// In en, this message translates to:
  /// **'Error resetting workout: {error}'**
  String workoutResetError(Object error);

  /// No description provided for @workoutClearDayLabelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear All Day Labels'**
  String get workoutClearDayLabelsTitle;

  /// No description provided for @workoutClearDayLabelsContent.
  ///
  /// In en, this message translates to:
  /// **'This will remove all custom day labels from workouts in this trainingCycle. Day names will be calculated automatically based on the start date.\n\nThis cannot be undone.'**
  String get workoutClearDayLabelsContent;

  /// No description provided for @workoutClearDayLabelsAction.
  ///
  /// In en, this message translates to:
  /// **'CLEAR ALL'**
  String get workoutClearDayLabelsAction;

  /// No description provided for @workoutResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Workout?'**
  String get workoutResetTitle;

  /// No description provided for @workoutResetContent.
  ///
  /// In en, this message translates to:
  /// **'This will clear all logged sets and entered values for this workout. This action cannot be undone.'**
  String get workoutResetContent;

  /// No description provided for @workoutResetAction.
  ///
  /// In en, this message translates to:
  /// **'RESET'**
  String get workoutResetAction;

  /// No description provided for @workoutMenuTrainingCycleHeader.
  ///
  /// In en, this message translates to:
  /// **'TRAINING CYCLE'**
  String get workoutMenuTrainingCycleHeader;

  /// No description provided for @workoutMenuNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get workoutMenuNote;

  /// No description provided for @workoutMenuSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get workoutMenuSummary;

  /// No description provided for @workoutMenuRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get workoutMenuRename;

  /// No description provided for @workoutMenuEndCycle.
  ///
  /// In en, this message translates to:
  /// **'End {cycleTerm}'**
  String workoutMenuEndCycle(Object cycleTerm);

  /// No description provided for @workoutMenuWorkoutHeader.
  ///
  /// In en, this message translates to:
  /// **'WORKOUT'**
  String get workoutMenuWorkoutHeader;

  /// No description provided for @workoutMenuNewNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get workoutMenuNewNote;

  /// No description provided for @workoutMenuRelabel.
  ///
  /// In en, this message translates to:
  /// **'Relabel'**
  String get workoutMenuRelabel;

  /// No description provided for @workoutMenuClearDayLabels.
  ///
  /// In en, this message translates to:
  /// **'Clear all day labels'**
  String get workoutMenuClearDayLabels;

  /// No description provided for @workoutMenuAddSession.
  ///
  /// In en, this message translates to:
  /// **'Add session'**
  String get workoutMenuAddSession;

  /// No description provided for @workoutMenuBodyweight.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get workoutMenuBodyweight;

  /// No description provided for @workoutMenuReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get workoutMenuReset;

  /// No description provided for @workoutMenuSkipWorkout.
  ///
  /// In en, this message translates to:
  /// **'Skip workout'**
  String get workoutMenuSkipWorkout;

  /// No description provided for @workoutNoActiveCycleTitle.
  ///
  /// In en, this message translates to:
  /// **'No Active TrainingCycle'**
  String get workoutNoActiveCycleTitle;

  /// No description provided for @workoutNoActiveCycleMessage.
  ///
  /// In en, this message translates to:
  /// **'Create and start a trainingCycle to begin'**
  String get workoutNoActiveCycleMessage;

  /// No description provided for @workoutCycleNotActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'TrainingCycle Not Active'**
  String get workoutCycleNotActiveTitle;

  /// No description provided for @workoutCycleNotActiveMessage.
  ///
  /// In en, this message translates to:
  /// **'The trainingCycle is scheduled for a future date or has ended'**
  String get workoutCycleNotActiveMessage;

  /// No description provided for @workoutCycleSectionPeriodDay.
  ///
  /// In en, this message translates to:
  /// **'Period {period} • Day {day}'**
  String workoutCycleSectionPeriodDay(Object period, Object day);

  /// No description provided for @editWorkoutStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get editWorkoutStartButton;

  /// No description provided for @editWorkoutExportTemplateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export Template (Debug)'**
  String get editWorkoutExportTemplateTooltip;

  /// No description provided for @editWorkoutAddExerciseButton.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get editWorkoutAddExerciseButton;

  /// No description provided for @editWorkoutPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get editWorkoutPeriodLabel;

  /// No description provided for @editWorkoutRemovePeriodTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove Period'**
  String get editWorkoutRemovePeriodTooltip;

  /// No description provided for @editWorkoutAddPeriodTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Period'**
  String get editWorkoutAddPeriodTooltip;

  /// No description provided for @editWorkoutMirrorPeriod1Tooltip.
  ///
  /// In en, this message translates to:
  /// **'Mirror Period 1'**
  String get editWorkoutMirrorPeriod1Tooltip;

  /// No description provided for @editWorkoutDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get editWorkoutDayLabel;

  /// No description provided for @editWorkoutDayPrefix.
  ///
  /// In en, this message translates to:
  /// **'D{number}'**
  String editWorkoutDayPrefix(Object number);

  /// No description provided for @editWorkoutRemoveDayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove Day'**
  String get editWorkoutRemoveDayTooltip;

  /// No description provided for @editWorkoutAddDayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Day'**
  String get editWorkoutAddDayTooltip;

  /// No description provided for @editWorkoutPeriodAdded.
  ///
  /// In en, this message translates to:
  /// **'Period {number} added'**
  String editWorkoutPeriodAdded(Object number);

  /// No description provided for @editWorkoutPeriodAddError.
  ///
  /// In en, this message translates to:
  /// **'Error adding period: {error}'**
  String editWorkoutPeriodAddError(Object error);

  /// No description provided for @editWorkoutRecoveryPeriodRemoved.
  ///
  /// In en, this message translates to:
  /// **'Recovery period removed'**
  String get editWorkoutRecoveryPeriodRemoved;

  /// No description provided for @editWorkoutPeriodRemoved.
  ///
  /// In en, this message translates to:
  /// **'Period {number} removed'**
  String editWorkoutPeriodRemoved(Object number);

  /// No description provided for @editWorkoutPeriodRemoveError.
  ///
  /// In en, this message translates to:
  /// **'Error removing period: {error}'**
  String editWorkoutPeriodRemoveError(Object error);

  /// No description provided for @editWorkoutRecoveryTypeChanged.
  ///
  /// In en, this message translates to:
  /// **'Recovery period changed to {type}'**
  String editWorkoutRecoveryTypeChanged(Object type);

  /// No description provided for @editWorkoutRecoveryTypeError.
  ///
  /// In en, this message translates to:
  /// **'Error updating recovery type: {error}'**
  String editWorkoutRecoveryTypeError(Object error);

  /// No description provided for @editWorkoutDayAdded.
  ///
  /// In en, this message translates to:
  /// **'Day {number} added'**
  String editWorkoutDayAdded(Object number);

  /// No description provided for @editWorkoutDayAddError.
  ///
  /// In en, this message translates to:
  /// **'Error adding day: {error}'**
  String editWorkoutDayAddError(Object error);

  /// No description provided for @editWorkoutDayRemoved.
  ///
  /// In en, this message translates to:
  /// **'Day {number} removed'**
  String editWorkoutDayRemoved(Object number);

  /// No description provided for @editWorkoutDayRemoveError.
  ///
  /// In en, this message translates to:
  /// **'Error removing day: {error}'**
  String editWorkoutDayRemoveError(Object error);

  /// No description provided for @editWorkoutPeriod1Mirrored.
  ///
  /// In en, this message translates to:
  /// **'Period 1 mirrored to Period {number}'**
  String editWorkoutPeriod1Mirrored(Object number);

  /// No description provided for @editWorkoutMirrorError.
  ///
  /// In en, this message translates to:
  /// **'Error mirroring period: {error}'**
  String editWorkoutMirrorError(Object error);

  /// No description provided for @editWorkoutTemplateExported.
  ///
  /// In en, this message translates to:
  /// **'Template JSON copied to clipboard!'**
  String get editWorkoutTemplateExported;

  /// No description provided for @editWorkoutTemplateExportError.
  ///
  /// In en, this message translates to:
  /// **'Error exporting template: {error}'**
  String editWorkoutTemplateExportError(Object error);

  /// No description provided for @editWorkoutRemovePeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Period'**
  String get editWorkoutRemovePeriodTitle;

  /// No description provided for @editWorkoutRemovePeriodContent.
  ///
  /// In en, this message translates to:
  /// **'Which period would you like to remove?\n\n• Period {number} (last training period)\n• Recovery period'**
  String editWorkoutRemovePeriodContent(Object number);

  /// No description provided for @editWorkoutRemoveDeload.
  ///
  /// In en, this message translates to:
  /// **'Remove Deload'**
  String get editWorkoutRemoveDeload;

  /// No description provided for @editWorkoutRemovePeriodAction.
  ///
  /// In en, this message translates to:
  /// **'Remove Period {number}'**
  String editWorkoutRemovePeriodAction(Object number);

  /// No description provided for @editWorkoutRecoveryTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Recovery Period Type'**
  String get editWorkoutRecoveryTypeTitle;

  /// No description provided for @editWorkoutRemoveDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Day'**
  String get editWorkoutRemoveDayTitle;

  /// No description provided for @editWorkoutRemoveDayContent.
  ///
  /// In en, this message translates to:
  /// **'Day {number} has exercises assigned. Removing it will delete all exercises on this day across all periods.\n\nAre you sure you want to remove Day {number}?'**
  String editWorkoutRemoveDayContent(Object number);

  /// No description provided for @editWorkoutRemoveDayAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get editWorkoutRemoveDayAction;

  /// No description provided for @editWorkoutMirrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Mirror Period 1'**
  String get editWorkoutMirrorTitle;

  /// No description provided for @editWorkoutMirrorContent.
  ///
  /// In en, this message translates to:
  /// **'Copy all workouts from Period 1 to Period {number}? This will replace any existing workouts for Period {number}.'**
  String editWorkoutMirrorContent(Object number);

  /// No description provided for @editWorkoutMirrorAction.
  ///
  /// In en, this message translates to:
  /// **'Mirror'**
  String get editWorkoutMirrorAction;

  /// No description provided for @editWorkoutDeleteExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Exercise'**
  String get editWorkoutDeleteExerciseTitle;

  /// No description provided for @editWorkoutDeleteExerciseContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String editWorkoutDeleteExerciseContent(Object name);

  /// No description provided for @editWorkoutStartCycleTitle.
  ///
  /// In en, this message translates to:
  /// **'Start {cycleTerm}'**
  String editWorkoutStartCycleTitle(Object cycleTerm);

  /// No description provided for @editWorkoutStartCycleContent.
  ///
  /// In en, this message translates to:
  /// **'Start \"{name}\"? This will set it as your current {cycleTerm}.'**
  String editWorkoutStartCycleContent(Object name, Object cycleTerm);

  /// No description provided for @editWorkoutStartCycleActiveContent.
  ///
  /// In en, this message translates to:
  /// **'You have an active {cycleTerm}: \"{activeNames}\".\n\nHow would you like to start \"{name}\"?'**
  String editWorkoutStartCycleActiveContent(Object cycleTerm, Object activeNames, Object name);

  /// No description provided for @editWorkoutStartCycleReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace current'**
  String get editWorkoutStartCycleReplace;

  /// No description provided for @editWorkoutStartCycleStack.
  ///
  /// In en, this message translates to:
  /// **'Stack alongside'**
  String get editWorkoutStartCycleStack;

  /// No description provided for @editWorkoutSetHeader.
  ///
  /// In en, this message translates to:
  /// **'SET'**
  String get editWorkoutSetHeader;

  /// No description provided for @editWorkoutRepsHeader.
  ///
  /// In en, this message translates to:
  /// **'REPS'**
  String get editWorkoutRepsHeader;

  /// No description provided for @editWorkoutRepsHint.
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get editWorkoutRepsHint;

  /// No description provided for @editWorkoutExerciseMenuHeader.
  ///
  /// In en, this message translates to:
  /// **'EXERCISE'**
  String get editWorkoutExerciseMenuHeader;

  /// No description provided for @editWorkoutNewNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get editWorkoutNewNote;

  /// No description provided for @editWorkoutMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get editWorkoutMoveUp;

  /// No description provided for @editWorkoutMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get editWorkoutMoveDown;

  /// No description provided for @editWorkoutReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get editWorkoutReplace;

  /// No description provided for @editWorkoutAddSet.
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get editWorkoutAddSet;

  /// No description provided for @editWorkoutDeleteExercise.
  ///
  /// In en, this message translates to:
  /// **'Delete exercise'**
  String get editWorkoutDeleteExercise;

  /// No description provided for @editWorkoutSetMenuHeader.
  ///
  /// In en, this message translates to:
  /// **'SET'**
  String get editWorkoutSetMenuHeader;

  /// No description provided for @editWorkoutAddSetBelow.
  ///
  /// In en, this message translates to:
  /// **'Add set below'**
  String get editWorkoutAddSetBelow;

  /// No description provided for @editWorkoutDeleteSet.
  ///
  /// In en, this message translates to:
  /// **'Delete set'**
  String get editWorkoutDeleteSet;

  /// No description provided for @editWorkoutSetTypeHeader.
  ///
  /// In en, this message translates to:
  /// **'SET TYPE'**
  String get editWorkoutSetTypeHeader;

  /// No description provided for @editWorkoutNoExercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'No exercises scheduled'**
  String get editWorkoutNoExercisesTitle;

  /// No description provided for @editWorkoutNoExercisesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add exercises for this day'**
  String get editWorkoutNoExercisesSubtitle;

  /// No description provided for @editWorkoutAddCardioSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add cardio session'**
  String get editWorkoutAddCardioSessionTitle;

  /// No description provided for @editWorkoutAddCardio.
  ///
  /// In en, this message translates to:
  /// **'Add cardio'**
  String get editWorkoutAddCardio;

  /// No description provided for @editWorkoutInfoButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'i'**
  String get editWorkoutInfoButtonLabel;

  /// No description provided for @addExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get addExerciseTitle;

  /// No description provided for @addExerciseCreateCustomButton.
  ///
  /// In en, this message translates to:
  /// **'Create Custom'**
  String get addExerciseCreateCustomButton;

  /// No description provided for @addExerciseAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addExerciseAddButton;

  /// No description provided for @addExerciseSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search exercises'**
  String get addExerciseSearchLabel;

  /// No description provided for @addExerciseSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get addExerciseSearchHint;

  /// No description provided for @addExerciseClearSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get addExerciseClearSearchTooltip;

  /// No description provided for @addExerciseFilterButton.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get addExerciseFilterButton;

  /// No description provided for @addExerciseFilterClearAll.
  ///
  /// In en, this message translates to:
  /// **'CLEAR ALL'**
  String get addExerciseFilterClearAll;

  /// No description provided for @addExerciseFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get addExerciseFilterTitle;

  /// No description provided for @addExerciseFilterMuscleGroup.
  ///
  /// In en, this message translates to:
  /// **'Muscle Group'**
  String get addExerciseFilterMuscleGroup;

  /// No description provided for @addExerciseFilterEquipmentType.
  ///
  /// In en, this message translates to:
  /// **'Filter by Equipment Type'**
  String get addExerciseFilterEquipmentType;

  /// No description provided for @addExerciseFilterEquipmentTypeDesc.
  ///
  /// In en, this message translates to:
  /// **'Temporarily filter to specific equipment types'**
  String get addExerciseFilterEquipmentTypeDesc;

  /// No description provided for @addExerciseFilterApplyButton.
  ///
  /// In en, this message translates to:
  /// **'APPLY FILTERS'**
  String get addExerciseFilterApplyButton;

  /// No description provided for @addExerciseNoResults.
  ///
  /// In en, this message translates to:
  /// **'No exercises found'**
  String get addExerciseNoResults;

  /// No description provided for @addExerciseAdjustFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get addExerciseAdjustFilters;

  /// No description provided for @addExerciseLastPerformed.
  ///
  /// In en, this message translates to:
  /// **'Last performed {dateStr}'**
  String addExerciseLastPerformed(Object dateStr);

  /// No description provided for @addExerciseWorkoutNotFound.
  ///
  /// In en, this message translates to:
  /// **'Error: Workout not found'**
  String get addExerciseWorkoutNotFound;

  /// No description provided for @addExerciseReplaced.
  ///
  /// In en, this message translates to:
  /// **'{oldName} replaced with {newName}'**
  String addExerciseReplaced(Object oldName, Object newName);

  /// No description provided for @addExerciseAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added'**
  String addExerciseAdded(Object name);

  /// No description provided for @completedWorkoutNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'TrainingCycle Not Found'**
  String get completedWorkoutNotFoundTitle;

  /// No description provided for @completedWorkoutNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'The requested trainingCycle could not be found.'**
  String get completedWorkoutNotFoundBody;

  /// No description provided for @completedWorkoutErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get completedWorkoutErrorTitle;

  /// No description provided for @completedWorkoutErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error loading trainingCycle: {error}'**
  String completedWorkoutErrorMessage(Object error);

  /// No description provided for @completedWorkoutCompletedBadge.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get completedWorkoutCompletedBadge;

  /// No description provided for @completedWorkoutWeekDayTitle.
  ///
  /// In en, this message translates to:
  /// **'WEEK {period} DAY {day} {dayName}'**
  String completedWorkoutWeekDayTitle(Object period, Object day, Object dayName);

  /// No description provided for @completedWorkoutWeightHeader.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT'**
  String get completedWorkoutWeightHeader;

  /// No description provided for @completedWorkoutRepsHeader.
  ///
  /// In en, this message translates to:
  /// **'REPS'**
  String get completedWorkoutRepsHeader;

  /// No description provided for @completedWorkoutLogHeader.
  ///
  /// In en, this message translates to:
  /// **'LOG'**
  String get completedWorkoutLogHeader;

  /// No description provided for @completedWorkoutNoExercises.
  ///
  /// In en, this message translates to:
  /// **'No exercises for this day'**
  String get completedWorkoutNoExercises;

  /// No description provided for @completedWorkoutWeeksReadOnly.
  ///
  /// In en, this message translates to:
  /// **'WEEKS (READ-ONLY)'**
  String get completedWorkoutWeeksReadOnly;

  /// No description provided for @completedWorkoutDlLabel.
  ///
  /// In en, this message translates to:
  /// **'DL'**
  String get completedWorkoutDlLabel;

  /// No description provided for @completedWorkoutRirLabel.
  ///
  /// In en, this message translates to:
  /// **'{rir} RIR'**
  String completedWorkoutRirLabel(Object rir);

  /// No description provided for @completedWorkoutUnknownEquipment.
  ///
  /// In en, this message translates to:
  /// **'UNKNOWN'**
  String get completedWorkoutUnknownEquipment;

  /// No description provided for @completedWorkoutEmptyValue.
  ///
  /// In en, this message translates to:
  /// **'-'**
  String get completedWorkoutEmptyValue;

  /// No description provided for @cardioSessionLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log {sport}'**
  String cardioSessionLogTitle(Object sport);

  /// No description provided for @cardioSessionEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {sport}'**
  String cardioSessionEditTitle(Object sport);

  /// No description provided for @cardioSessionPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan {sport}'**
  String cardioSessionPlanTitle(Object sport);

  /// No description provided for @cardioSessionEditIntervalsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit intervals'**
  String get cardioSessionEditIntervalsTooltip;

  /// No description provided for @cardioSessionImportedChip.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get cardioSessionImportedChip;

  /// No description provided for @cardioSessionDateButton.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get cardioSessionDateButton;

  /// No description provided for @cardioSessionStartFromTemplate.
  ///
  /// In en, this message translates to:
  /// **'Start from template'**
  String get cardioSessionStartFromTemplate;

  /// No description provided for @cardioSessionNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Session name'**
  String get cardioSessionNameLabel;

  /// No description provided for @cardioSessionNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 30 min Tempo'**
  String get cardioSessionNameHint;

  /// No description provided for @cardioSessionNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get cardioSessionNotesLabel;

  /// No description provided for @cardioSessionNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Anything worth remembering about this session…'**
  String get cardioSessionNotesHint;

  /// No description provided for @cardioSessionPlanButton.
  ///
  /// In en, this message translates to:
  /// **'Plan session'**
  String get cardioSessionPlanButton;

  /// No description provided for @cardioSessionSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save session'**
  String get cardioSessionSaveButton;

  /// No description provided for @cardioSessionLogButton.
  ///
  /// In en, this message translates to:
  /// **'Log session'**
  String get cardioSessionLogButton;

  /// No description provided for @cardioSessionUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update session'**
  String get cardioSessionUpdateButton;

  /// No description provided for @cardioSessionPlanned.
  ///
  /// In en, this message translates to:
  /// **'Session planned'**
  String get cardioSessionPlanned;

  /// No description provided for @cardioSessionLogged.
  ///
  /// In en, this message translates to:
  /// **'Session logged'**
  String get cardioSessionLogged;

  /// No description provided for @cardioSessionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Session updated'**
  String get cardioSessionUpdated;

  /// No description provided for @cardioSessionPerceivedExertion.
  ///
  /// In en, this message translates to:
  /// **'Perceived exertion'**
  String get cardioSessionPerceivedExertion;

  /// No description provided for @cardioSessionRpeValue.
  ///
  /// In en, this message translates to:
  /// **'RPE {value}'**
  String cardioSessionRpeValue(Object value);

  /// No description provided for @cardioSessionRpeNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get cardioSessionRpeNotSet;

  /// No description provided for @cardioSessionPaceAvgSpeed.
  ///
  /// In en, this message translates to:
  /// **'Pace {pace}  •  Avg speed {speed}'**
  String cardioSessionPaceAvgSpeed(Object pace, Object speed);

  /// No description provided for @cardioSessionAvgSpeed.
  ///
  /// In en, this message translates to:
  /// **'Avg speed {speed}'**
  String cardioSessionAvgSpeed(Object speed);

  /// No description provided for @intervalBuilderTitle.
  ///
  /// In en, this message translates to:
  /// **'Intervals'**
  String get intervalBuilderTitle;

  /// No description provided for @intervalBuilderSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get intervalBuilderSaveButton;

  /// No description provided for @intervalBuilderSessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Cardio session not found'**
  String get intervalBuilderSessionNotFound;

  /// No description provided for @intervalBuilderStepsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} steps'**
  String intervalBuilderStepsCount(Object count);

  /// No description provided for @intervalBuilderSaved.
  ///
  /// In en, this message translates to:
  /// **'Intervals saved'**
  String get intervalBuilderSaved;

  /// No description provided for @intervalBuilderDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get intervalBuilderDiscardTitle;

  /// No description provided for @intervalBuilderDiscardContent.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes to this interval plan.'**
  String get intervalBuilderDiscardContent;

  /// No description provided for @intervalBuilderKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get intervalBuilderKeepEditing;

  /// No description provided for @intervalBuilderDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get intervalBuilderDiscard;

  /// No description provided for @intervalBuilderAddStep.
  ///
  /// In en, this message translates to:
  /// **'Add step'**
  String get intervalBuilderAddStep;

  /// No description provided for @intervalBuilderMoveUpTooltip.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get intervalBuilderMoveUpTooltip;

  /// No description provided for @intervalBuilderMoveDownTooltip.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get intervalBuilderMoveDownTooltip;

  /// No description provided for @intervalBuilderRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get intervalBuilderRemoveTooltip;

  /// No description provided for @intervalBuilderAddToRepeat.
  ///
  /// In en, this message translates to:
  /// **'Add to repeat'**
  String get intervalBuilderAddToRepeat;

  /// No description provided for @intervalBuilderRepeatGroupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Group several steps and run them N times'**
  String get intervalBuilderRepeatGroupSubtitle;

  /// No description provided for @intervalBuilderRepeatLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get intervalBuilderRepeatLabel;

  /// No description provided for @intervalBuilderTimesLabel.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get intervalBuilderTimesLabel;

  /// No description provided for @intervalBuilderTargetTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Target type'**
  String get intervalBuilderTargetTypeLabel;

  /// No description provided for @intervalBuilderFieldDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get intervalBuilderFieldDuration;

  /// No description provided for @intervalBuilderFieldDistanceM.
  ///
  /// In en, this message translates to:
  /// **'Distance (m)'**
  String get intervalBuilderFieldDistanceM;

  /// No description provided for @intervalBuilderFieldHrZone.
  ///
  /// In en, this message translates to:
  /// **'HR zone (1..5)'**
  String get intervalBuilderFieldHrZone;

  /// No description provided for @intervalBuilderFieldPaceZone.
  ///
  /// In en, this message translates to:
  /// **'Pace zone (1..5)'**
  String get intervalBuilderFieldPaceZone;

  /// No description provided for @intervalBuilderFieldPowerZone.
  ///
  /// In en, this message translates to:
  /// **'Power zone (1..5)'**
  String get intervalBuilderFieldPowerZone;

  /// No description provided for @intervalBuilderFieldFreeform.
  ///
  /// In en, this message translates to:
  /// **'Target (free text)'**
  String get intervalBuilderFieldFreeform;

  /// No description provided for @intervalBuilderErrorMmSs.
  ///
  /// In en, this message translates to:
  /// **'Use MM:SS'**
  String get intervalBuilderErrorMmSs;

  /// No description provided for @intervalBuilderErrorMeters.
  ///
  /// In en, this message translates to:
  /// **'Enter meters'**
  String get intervalBuilderErrorMeters;

  /// No description provided for @intervalBuilderErrorZoneRange.
  ///
  /// In en, this message translates to:
  /// **'1..5'**
  String get intervalBuilderErrorZoneRange;

  /// No description provided for @intervalBuilderEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No intervals yet'**
  String get intervalBuilderEmptyTitle;

  /// No description provided for @intervalBuilderEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'A structured plan looks like warm-up → work → recovery → cooldown. Start with a warm-up.'**
  String get intervalBuilderEmptySubtitle;

  /// No description provided for @intervalBuilderAddWarmUp.
  ///
  /// In en, this message translates to:
  /// **'Add warm-up'**
  String get intervalBuilderAddWarmUp;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @calendarShowLegendTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show legend'**
  String get calendarShowLegendTooltip;

  /// No description provided for @calendarNoActiveCycleTitle.
  ///
  /// In en, this message translates to:
  /// **'No active training cycle'**
  String get calendarNoActiveCycleTitle;

  /// No description provided for @calendarNoActiveCycleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a training cycle to see your workouts on the calendar'**
  String get calendarNoActiveCycleSubtitle;

  /// No description provided for @calendarPeriodDayLabel.
  ///
  /// In en, this message translates to:
  /// **'P{period}D{day}'**
  String calendarPeriodDayLabel(Object period, Object day);

  /// No description provided for @calendarMuscleGroupSets.
  ///
  /// In en, this message translates to:
  /// **'{muscleGroup} • {setCount} sets'**
  String calendarMuscleGroupSets(Object muscleGroup, Object setCount);

  /// Exercise line in the calendar muscle-group tooltip/list
  ///
  /// In en, this message translates to:
  /// **'{name} ({setCount, plural, =1{1 set} other{{setCount} sets}})'**
  String calendarExerciseSetCount(Object name, num setCount);

  /// No description provided for @calendarMoreExercises.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String calendarMoreExercises(Object count);

  /// No description provided for @calendarRestDay.
  ///
  /// In en, this message translates to:
  /// **'Rest Day'**
  String get calendarRestDay;

  /// No description provided for @calendarEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get calendarEditButton;

  /// No description provided for @calendarNoSessionScheduled.
  ///
  /// In en, this message translates to:
  /// **'No session scheduled'**
  String get calendarNoSessionScheduled;

  /// No description provided for @calendarStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get calendarStatusCompleted;

  /// No description provided for @calendarStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get calendarStatusInProgress;

  /// No description provided for @calendarStatusRecovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get calendarStatusRecovery;

  /// No description provided for @calendarStatusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get calendarStatusScheduled;

  /// No description provided for @calendarPeriodDayInfo.
  ///
  /// In en, this message translates to:
  /// **'Period {period}, Day {day}'**
  String calendarPeriodDayInfo(Object period, Object day);

  /// No description provided for @calendarPeriodDayRecovery.
  ///
  /// In en, this message translates to:
  /// **'Period {period}, Day {day} (Recovery)'**
  String calendarPeriodDayRecovery(Object period, Object day);

  /// No description provided for @calendarExercisesMuscleGroups.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises • {muscleGroups}'**
  String calendarExercisesMuscleGroups(Object count, Object muscleGroups);

  /// No description provided for @calendarViewButton.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get calendarViewButton;

  /// No description provided for @calendarGoToWorkoutButton.
  ///
  /// In en, this message translates to:
  /// **'Go to Workout'**
  String get calendarGoToWorkoutButton;

  /// No description provided for @calendarCardioSessionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 cardio session} other{{count} cardio sessions}}'**
  String calendarCardioSessionCount(int count);

  /// No description provided for @calendarViewDayButton.
  ///
  /// In en, this message translates to:
  /// **'View Day'**
  String get calendarViewDayButton;

  /// No description provided for @calendarSessionStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get calendarSessionStatusDone;

  /// No description provided for @calendarSessionStatusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get calendarSessionStatusSkipped;

  /// No description provided for @calendarSessionStatusPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get calendarSessionStatusPlanned;

  /// No description provided for @calendarMovedExercise.
  ///
  /// In en, this message translates to:
  /// **'Moved {exerciseName} to {date}'**
  String calendarMovedExercise(Object exerciseName, Object date);

  /// No description provided for @calendarMovedCardio.
  ///
  /// In en, this message translates to:
  /// **'Moved {sessionLabel} to {date}'**
  String calendarMovedCardio(Object sessionLabel, Object date);

  /// No description provided for @calendarFailedToMove.
  ///
  /// In en, this message translates to:
  /// **'Failed to move: {error}'**
  String calendarFailedToMove(Object error);

  /// No description provided for @calendarFailedToReorder.
  ///
  /// In en, this message translates to:
  /// **'Failed to reorder exercise: {error}'**
  String calendarFailedToReorder(Object error);

  /// No description provided for @calendarRestDayInserted.
  ///
  /// In en, this message translates to:
  /// **'Rest day inserted before P{period}D{day}'**
  String calendarRestDayInserted(Object period, Object day);

  /// No description provided for @calendarFailedToInsertDay.
  ///
  /// In en, this message translates to:
  /// **'Failed to insert day: {error}'**
  String calendarFailedToInsertDay(Object error);

  /// No description provided for @calendarRestDayRemoved.
  ///
  /// In en, this message translates to:
  /// **'Rest day removed on {date}'**
  String calendarRestDayRemoved(Object date);

  /// No description provided for @calendarFailedToRemoveRestDay.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove rest day: {error}'**
  String calendarFailedToRemoveRestDay(Object error);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settingsSaveButton;

  /// No description provided for @settingsSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSavedMessage;

  /// No description provided for @settingsUnitsHeader.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get settingsUnitsHeader;

  /// No description provided for @settingsImperialLabel.
  ///
  /// In en, this message translates to:
  /// **'Imperial (lbs)'**
  String get settingsImperialLabel;

  /// No description provided for @settingsMetricLabel.
  ///
  /// In en, this message translates to:
  /// **'Metric (kg)'**
  String get settingsMetricLabel;

  /// No description provided for @settingsLanguageHeader.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageHeader;

  /// No description provided for @settingsLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the display language for the app'**
  String get settingsLanguageDescription;

  /// No description provided for @settingsBodyMeasurementsHeader.
  ///
  /// In en, this message translates to:
  /// **'Body Measurements'**
  String get settingsBodyMeasurementsHeader;

  /// No description provided for @settingsBodyMeasurementsDesc.
  ///
  /// In en, this message translates to:
  /// **'Update your measurements to track BMI over time'**
  String get settingsBodyMeasurementsDesc;

  /// No description provided for @settingsCurrentBmi.
  ///
  /// In en, this message translates to:
  /// **'Current BMI'**
  String get settingsCurrentBmi;

  /// No description provided for @settingsBmiGuidelines.
  ///
  /// In en, this message translates to:
  /// **'BMI categories based on WHO guidelines'**
  String get settingsBmiGuidelines;

  /// No description provided for @settingsTerminologyHeader.
  ///
  /// In en, this message translates to:
  /// **'Training Cycle Terminology'**
  String get settingsTerminologyHeader;

  /// No description provided for @settingsTerminologyDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose the term you prefer for your trainingCycles'**
  String get settingsTerminologyDesc;

  /// No description provided for @settingsSportsHeader.
  ///
  /// In en, this message translates to:
  /// **'Sports I train'**
  String get settingsSportsHeader;

  /// No description provided for @settingsSportsDesc.
  ///
  /// In en, this message translates to:
  /// **'Pick the sports you want to log. The Workout tab\'s \"Add session\" grid only shows these.'**
  String get settingsSportsDesc;

  /// No description provided for @settingsSportsMinimumWarning.
  ///
  /// In en, this message translates to:
  /// **'At least one sport is required.'**
  String get settingsSportsMinimumWarning;

  /// No description provided for @integrationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get integrationsTitle;

  /// No description provided for @integrationsHealthPermissionsGranted.
  ///
  /// In en, this message translates to:
  /// **'Health permissions granted'**
  String get integrationsHealthPermissionsGranted;

  /// No description provided for @integrationsHealthConnectRequired.
  ///
  /// In en, this message translates to:
  /// **'Health Connect Required'**
  String get integrationsHealthConnectRequired;

  /// No description provided for @integrationsHealthConnectIntro.
  ///
  /// In en, this message translates to:
  /// **'To sync workouts from Health Connect and Peloton, please follow these steps:'**
  String get integrationsHealthConnectIntro;

  /// No description provided for @integrationsHealthConnectStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Download and install Health Connect from the Google Play Store (Android 14+ has it built in).'**
  String get integrationsHealthConnectStep1;

  /// No description provided for @integrationsHealthConnectStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Open Health Connect and go to App permissions.'**
  String get integrationsHealthConnectStep2;

  /// No description provided for @integrationsHealthConnectStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Find Yawa4u in the list and allow access to Exercise sessions, Heart rate, Distance, and Active energy burned.'**
  String get integrationsHealthConnectStep3;

  /// No description provided for @integrationsHealthConnectStep4.
  ///
  /// In en, this message translates to:
  /// **'4. Return here and tap \"Grant permissions\" again.'**
  String get integrationsHealthConnectStep4;

  /// No description provided for @integrationsGotIt.
  ///
  /// In en, this message translates to:
  /// **'GOT IT'**
  String get integrationsGotIt;

  /// No description provided for @integrationsHealthSyncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Found {totalPoints} records · +{imported} imported · {skippedDuplicate} duplicate · {skippedUnsupported} unsupported'**
  String integrationsHealthSyncSuccess(
    Object totalPoints,
    Object imported,
    Object skippedDuplicate,
    Object skippedUnsupported,
  );

  /// No description provided for @integrationsHealthSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String integrationsHealthSyncFailed(Object error);

  /// No description provided for @integrationsResetCursorMessage.
  ///
  /// In en, this message translates to:
  /// **'Next sync will look back 3 months.'**
  String get integrationsResetCursorMessage;

  /// No description provided for @integrationsHealthDiagnosticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Diagnostics'**
  String get integrationsHealthDiagnosticsTitle;

  /// No description provided for @integrationsStravaTitle.
  ///
  /// In en, this message translates to:
  /// **'Strava'**
  String get integrationsStravaTitle;

  /// No description provided for @integrationsStravaUnconfiguredMessage.
  ///
  /// In en, this message translates to:
  /// **'Strava requires client credentials at build time. See the README or the Bucket 3 hand-off doc for setup steps.'**
  String get integrationsStravaUnconfiguredMessage;

  /// No description provided for @integrationsStravaDescription.
  ///
  /// In en, this message translates to:
  /// **'Pull activities from Strava — runs, rides, swims import with distance, duration, HR, and elevation.'**
  String get integrationsStravaDescription;

  /// No description provided for @integrationsLastSync.
  ///
  /// In en, this message translates to:
  /// **'Last sync: {timestamp}'**
  String integrationsLastSync(Object timestamp);

  /// No description provided for @integrationsStravaConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected to Strava'**
  String get integrationsStravaConnected;

  /// No description provided for @integrationsStravaConnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to Strava'**
  String get integrationsStravaConnectFailed;

  /// No description provided for @integrationsStravaSyncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported {imported} · {skippedDuplicate} duplicate · {skippedUnsupported} unsupported'**
  String integrationsStravaSyncSuccess(Object imported, Object skippedDuplicate, Object skippedUnsupported);

  /// No description provided for @integrationsStravaSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String integrationsStravaSyncFailed(Object error);

  /// No description provided for @integrationsConnectToStrava.
  ///
  /// In en, this message translates to:
  /// **'Connect to Strava'**
  String get integrationsConnectToStrava;

  /// No description provided for @integrationsSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get integrationsSyncNow;

  /// No description provided for @integrationsDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get integrationsDisconnect;

  /// No description provided for @integrationsStatusUnconfigured.
  ///
  /// In en, this message translates to:
  /// **'Unconfigured'**
  String get integrationsStatusUnconfigured;

  /// No description provided for @integrationsStatusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get integrationsStatusConnected;

  /// No description provided for @integrationsStatusNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get integrationsStatusNotConnected;

  /// No description provided for @integrationsStatusSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get integrationsStatusSyncing;

  /// No description provided for @integrationsStatusError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get integrationsStatusError;

  /// No description provided for @integrationsStatusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get integrationsStatusUnavailable;

  /// No description provided for @integrationsHealthDescSupported.
  ///
  /// In en, this message translates to:
  /// **'Pull completed workouts (runs, rides, swims) from {providerName} so they join your training history.'**
  String integrationsHealthDescSupported(Object providerName);

  /// No description provided for @integrationsHealthDescUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This integration is only available on iOS and Android devices.'**
  String get integrationsHealthDescUnsupported;

  /// No description provided for @integrationsGrantPermissions.
  ///
  /// In en, this message translates to:
  /// **'Grant permissions'**
  String get integrationsGrantPermissions;

  /// No description provided for @integrationsResetCursor.
  ///
  /// In en, this message translates to:
  /// **'Reset cursor'**
  String get integrationsResetCursor;

  /// No description provided for @integrationsDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get integrationsDiagnostics;

  /// No description provided for @integrationsPelotonTitle.
  ///
  /// In en, this message translates to:
  /// **'Peloton comes through here'**
  String get integrationsPelotonTitle;

  /// No description provided for @integrationsPelotonDescription.
  ///
  /// In en, this message translates to:
  /// **'Peloton is paired inside the Peloton app — not {providerName}.\nOpen Peloton → Profile / Settings → look for a {providerName} toggle and turn it on. Your rides, runs, and treads will then flow into the Health card above, and YAWA4U picks them up on the next sync. No separate Peloton login needed here.'**
  String integrationsPelotonDescription(Object providerName);

  /// No description provided for @integrationsFutureTitle.
  ///
  /// In en, this message translates to:
  /// **'More integrations coming'**
  String get integrationsFutureTitle;

  /// No description provided for @integrationsFutureDescription.
  ///
  /// In en, this message translates to:
  /// **'Garmin Connect and Wahoo are on the roadmap.'**
  String get integrationsFutureDescription;

  /// No description provided for @integrationsTimeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get integrationsTimeJustNow;

  /// No description provided for @integrationsTimeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String integrationsTimeMinutesAgo(Object minutes);

  /// No description provided for @integrationsTimeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String integrationsTimeHoursAgo(Object hours);

  /// No description provided for @integrationsTimeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String integrationsTimeDaysAgo(Object days);

  /// No description provided for @themeEditorEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Theme'**
  String get themeEditorEditTitle;

  /// No description provided for @themeEditorCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Theme'**
  String get themeEditorCreateTitle;

  /// No description provided for @themeEditorErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading theme: {error}'**
  String themeEditorErrorLoading(Object error);

  /// No description provided for @themeEditorErrorPicking.
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String themeEditorErrorPicking(Object error);

  /// No description provided for @themeEditorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a theme name'**
  String get themeEditorNameRequired;

  /// No description provided for @themeEditorUpdated.
  ///
  /// In en, this message translates to:
  /// **'Theme updated!'**
  String get themeEditorUpdated;

  /// No description provided for @themeEditorCreated.
  ///
  /// In en, this message translates to:
  /// **'Theme created!'**
  String get themeEditorCreated;

  /// No description provided for @themeEditorErrorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving theme: {error}'**
  String themeEditorErrorSaving(Object error);

  /// No description provided for @themeEditorStepInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get themeEditorStepInfo;

  /// No description provided for @themeEditorStepBackgrounds.
  ///
  /// In en, this message translates to:
  /// **'Backgrounds'**
  String get themeEditorStepBackgrounds;

  /// No description provided for @themeEditorStepIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get themeEditorStepIcon;

  /// No description provided for @themeEditorStepColors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get themeEditorStepColors;

  /// No description provided for @themeEditorThemeInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Info'**
  String get themeEditorThemeInfoTitle;

  /// No description provided for @themeEditorThemeInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Give your theme a name and description.'**
  String get themeEditorThemeInfoDesc;

  /// No description provided for @themeEditorNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme Name'**
  String get themeEditorNameLabel;

  /// No description provided for @themeEditorNameHint.
  ///
  /// In en, this message translates to:
  /// **'My Custom Theme'**
  String get themeEditorNameHint;

  /// No description provided for @themeEditorDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get themeEditorDescriptionLabel;

  /// No description provided for @themeEditorDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'A brief description of your theme'**
  String get themeEditorDescriptionHint;

  /// No description provided for @themeEditorBackgroundsTitle.
  ///
  /// In en, this message translates to:
  /// **'Screen Backgrounds'**
  String get themeEditorBackgroundsTitle;

  /// No description provided for @themeEditorBackgroundsDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose background images for each screen. Tap to add, long press to remove.'**
  String get themeEditorBackgroundsDesc;

  /// No description provided for @themeEditorWorkoutScreen.
  ///
  /// In en, this message translates to:
  /// **'Workout Screen'**
  String get themeEditorWorkoutScreen;

  /// No description provided for @themeEditorMesocyclesScreen.
  ///
  /// In en, this message translates to:
  /// **'Mesocycles Screen'**
  String get themeEditorMesocyclesScreen;

  /// No description provided for @themeEditorExercisesScreen.
  ///
  /// In en, this message translates to:
  /// **'Exercises Screen'**
  String get themeEditorExercisesScreen;

  /// No description provided for @themeEditorMoreScreen.
  ///
  /// In en, this message translates to:
  /// **'More Screen'**
  String get themeEditorMoreScreen;

  /// No description provided for @themeEditorDefaultScreen.
  ///
  /// In en, this message translates to:
  /// **'Default (Calendar & Others)'**
  String get themeEditorDefaultScreen;

  /// No description provided for @themeEditorImageHasImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to change, hold to remove'**
  String get themeEditorImageHasImage;

  /// No description provided for @themeEditorImageNoImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to add image'**
  String get themeEditorImageNoImage;

  /// No description provided for @themeEditorAppIconTitle.
  ///
  /// In en, this message translates to:
  /// **'App Icon'**
  String get themeEditorAppIconTitle;

  /// No description provided for @themeEditorAppIconDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose an image to use as your app\'s accent icon (displayed in the app bar).'**
  String get themeEditorAppIconDesc;

  /// No description provided for @themeEditorTapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap to add'**
  String get themeEditorTapToAdd;

  /// No description provided for @themeEditorRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get themeEditorRemove;

  /// No description provided for @themeEditorAccentColorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Accent Colors'**
  String get themeEditorAccentColorsTitle;

  /// No description provided for @themeEditorAccentColorsDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose your theme\'s primary and secondary colors.'**
  String get themeEditorAccentColorsDesc;

  /// No description provided for @themeEditorSuggestedColors.
  ///
  /// In en, this message translates to:
  /// **'Suggested from your images:'**
  String get themeEditorSuggestedColors;

  /// No description provided for @themeEditorColorTooltip.
  ///
  /// In en, this message translates to:
  /// **'Tap: Primary\nDouble-tap: Secondary'**
  String get themeEditorColorTooltip;

  /// No description provided for @themeEditorPrimaryColor.
  ///
  /// In en, this message translates to:
  /// **'Primary Color'**
  String get themeEditorPrimaryColor;

  /// No description provided for @themeEditorSecondaryColor.
  ///
  /// In en, this message translates to:
  /// **'Secondary Color'**
  String get themeEditorSecondaryColor;

  /// No description provided for @themeEditorPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get themeEditorPreview;

  /// No description provided for @themeEditorThemeNameFallback.
  ///
  /// In en, this message translates to:
  /// **'Theme Name'**
  String get themeEditorThemeNameFallback;

  /// No description provided for @themeEditorCustomTheme.
  ///
  /// In en, this message translates to:
  /// **'Custom Theme'**
  String get themeEditorCustomTheme;

  /// No description provided for @themeEditorPrimaryButton.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get themeEditorPrimaryButton;

  /// No description provided for @themeEditorSecondaryButton.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get themeEditorSecondaryButton;

  /// No description provided for @themeEditorBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get themeEditorBackButton;

  /// No description provided for @themeEditorNextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get themeEditorNextButton;

  /// No description provided for @themeEditorSaveThemeButton.
  ///
  /// In en, this message translates to:
  /// **'Save Theme'**
  String get themeEditorSaveThemeButton;

  /// No description provided for @themeEditorChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get themeEditorChooseFromGallery;

  /// No description provided for @themeEditorTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get themeEditorTakePhoto;

  /// No description provided for @skinShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Themes'**
  String get skinShareTitle;

  /// No description provided for @skinShareServerError.
  ///
  /// In en, this message translates to:
  /// **'Could not start share server. Make sure you are connected to WiFi.'**
  String get skinShareServerError;

  /// No description provided for @skinShareConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to device. Make sure both devices are on the same WiFi network and you are scanning a valid theme share QR code.'**
  String get skinShareConnectionError;

  /// No description provided for @skinShareNoCustomThemes.
  ///
  /// In en, this message translates to:
  /// **'No custom themes to share'**
  String get skinShareNoCustomThemes;

  /// No description provided for @skinShareCreateThemeHint.
  ///
  /// In en, this message translates to:
  /// **'Create a custom theme in Theme Settings to share it.'**
  String get skinShareCreateThemeHint;

  /// No description provided for @skinShareOrReceiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Share or Receive Themes'**
  String get skinShareOrReceiveTitle;

  /// No description provided for @skinShareOrReceiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Select themes to share, or scan a QR code to receive themes from another device.'**
  String get skinShareOrReceiveDesc;

  /// No description provided for @skinShareScanQrButton.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code to Receive Themes'**
  String get skinShareScanQrButton;

  /// No description provided for @skinShareSelectThemesHeader.
  ///
  /// In en, this message translates to:
  /// **'Select Themes to Share'**
  String get skinShareSelectThemesHeader;

  /// No description provided for @skinShareDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get skinShareDeselectAll;

  /// No description provided for @skinShareSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get skinShareSelectAll;

  /// No description provided for @skinShareSelectToShare.
  ///
  /// In en, this message translates to:
  /// **'Select Themes to Share'**
  String get skinShareSelectToShare;

  /// No description provided for @skinShareViaQrCode.
  ///
  /// In en, this message translates to:
  /// **'Share via QR Code'**
  String get skinShareViaQrCode;

  /// No description provided for @skinShareUploadToCloud.
  ///
  /// In en, this message translates to:
  /// **'Upload to Cloud'**
  String get skinShareUploadToCloud;

  /// No description provided for @skinShareReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to Share'**
  String get skinShareReadyTitle;

  /// No description provided for @skinShareScanPrompt.
  ///
  /// In en, this message translates to:
  /// **'Ask the other person to scan this QR code'**
  String get skinShareScanPrompt;

  /// No description provided for @skinShareSharingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Sharing 1 Theme} other{Sharing {count} Themes}}'**
  String skinShareSharingCount(int count);

  /// No description provided for @skinShareSharingNote.
  ///
  /// In en, this message translates to:
  /// **'When scanned, these themes will be copied to the other device.'**
  String get skinShareSharingNote;

  /// No description provided for @skinShareScannerPrompt.
  ///
  /// In en, this message translates to:
  /// **'Point camera at theme share QR code'**
  String get skinShareScannerPrompt;

  /// No description provided for @skinShareCameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera Error'**
  String get skinShareCameraError;

  /// No description provided for @skinShareCameraAccessFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not access camera'**
  String get skinShareCameraAccessFailed;

  /// No description provided for @skinShareGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get skinShareGoBack;

  /// No description provided for @skinShareConnectedTo.
  ///
  /// In en, this message translates to:
  /// **'Connected to'**
  String get skinShareConnectedTo;

  /// No description provided for @skinShareThemesAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Theme Available} other{{count} Themes Available}}'**
  String skinShareThemesAvailable(int count);

  /// No description provided for @skinShareThemesToReceive.
  ///
  /// In en, this message translates to:
  /// **'Themes to Receive:'**
  String get skinShareThemesToReceive;

  /// No description provided for @skinShareReceiveButton.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Receive 1 Theme} other{Receive {count} Themes}}'**
  String skinShareReceiveButton(int count);

  /// No description provided for @skinShareThemesReceived.
  ///
  /// In en, this message translates to:
  /// **'Themes received!'**
  String get skinShareThemesReceived;

  /// No description provided for @skinShareReceiveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to receive themes'**
  String get skinShareReceiveFailed;

  /// No description provided for @templateShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Templates'**
  String get templateShareTitle;

  /// No description provided for @templateShareServerError.
  ///
  /// In en, this message translates to:
  /// **'Could not start share server. Make sure you are connected to WiFi.'**
  String get templateShareServerError;

  /// No description provided for @templateShareConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to device. Make sure both devices are on the same WiFi network and you are scanning a valid template share QR code.'**
  String get templateShareConnectionError;

  /// No description provided for @templateShareNoSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'No Saved Templates'**
  String get templateShareNoSavedTitle;

  /// No description provided for @templateShareNoSavedDesc.
  ///
  /// In en, this message translates to:
  /// **'Save a Training Cycle as a template first, then you can share it here.\n\nTo save a template, go to a Training Cycle and use the \"Save as Template\" option.'**
  String get templateShareNoSavedDesc;

  /// No description provided for @templateShareScanQrButton.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code to Receive Templates'**
  String get templateShareScanQrButton;

  /// No description provided for @templateShareOrReceiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Share or Receive Templates'**
  String get templateShareOrReceiveTitle;

  /// No description provided for @templateShareOrReceiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Select templates to share, or scan a QR code to receive templates from another device.'**
  String get templateShareOrReceiveDesc;

  /// No description provided for @templateShareSelectHeader.
  ///
  /// In en, this message translates to:
  /// **'Select Templates to Share'**
  String get templateShareSelectHeader;

  /// No description provided for @templateShareDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get templateShareDeselectAll;

  /// No description provided for @templateShareSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get templateShareSelectAll;

  /// No description provided for @templateShareSelectToShare.
  ///
  /// In en, this message translates to:
  /// **'Select Templates to Share'**
  String get templateShareSelectToShare;

  /// No description provided for @templateShareViaQrCode.
  ///
  /// In en, this message translates to:
  /// **'Share via QR Code'**
  String get templateShareViaQrCode;

  /// No description provided for @templateShareUploadToCloud.
  ///
  /// In en, this message translates to:
  /// **'Upload to Cloud'**
  String get templateShareUploadToCloud;

  /// No description provided for @templateShareDaysPerPeriod.
  ///
  /// In en, this message translates to:
  /// **'{count} Days/Period'**
  String templateShareDaysPerPeriod(Object count);

  /// No description provided for @templateSharePeriodsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Periods'**
  String templateSharePeriodsCount(Object count);

  /// No description provided for @templateShareWorkoutsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Workouts'**
  String templateShareWorkoutsCount(Object count);

  /// No description provided for @templateShareReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to Share'**
  String get templateShareReadyTitle;

  /// No description provided for @templateShareScanPrompt.
  ///
  /// In en, this message translates to:
  /// **'Ask the other person to scan this QR code'**
  String get templateShareScanPrompt;

  /// No description provided for @templateShareSharingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Sharing 1 Template} other{Sharing {count} Templates}}'**
  String templateShareSharingCount(int count);

  /// No description provided for @templateShareSharingNote.
  ///
  /// In en, this message translates to:
  /// **'When scanned, these templates will be copied to the other device.'**
  String get templateShareSharingNote;

  /// No description provided for @templateShareScannerPrompt.
  ///
  /// In en, this message translates to:
  /// **'Point camera at template share QR code'**
  String get templateShareScannerPrompt;

  /// No description provided for @templateShareCameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera Error'**
  String get templateShareCameraError;

  /// No description provided for @templateShareCameraAccessFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not access camera'**
  String get templateShareCameraAccessFailed;

  /// No description provided for @templateShareGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get templateShareGoBack;

  /// No description provided for @templateShareConnectedTo.
  ///
  /// In en, this message translates to:
  /// **'Connected to'**
  String get templateShareConnectedTo;

  /// No description provided for @templateShareAvailableCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Template Available} other{{count} Templates Available}}'**
  String templateShareAvailableCount(int count);

  /// No description provided for @templateShareToReceive.
  ///
  /// In en, this message translates to:
  /// **'Templates to Receive:'**
  String get templateShareToReceive;

  /// No description provided for @templateShareReceiveButton.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Receive 1 Template} other{Receive {count} Templates}}'**
  String templateShareReceiveButton(int count);

  /// No description provided for @templateShareReceived.
  ///
  /// In en, this message translates to:
  /// **'Templates received!'**
  String get templateShareReceived;

  /// No description provided for @templateShareReceiveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to receive templates'**
  String get templateShareReceiveFailed;

  /// No description provided for @syncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync Data'**
  String get syncTitle;

  /// No description provided for @syncServerError.
  ///
  /// In en, this message translates to:
  /// **'Could not start sync server. Make sure you are connected to WiFi.'**
  String get syncServerError;

  /// No description provided for @syncConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to device. Make sure both devices are on the same WiFi network.'**
  String get syncConnectionError;

  /// No description provided for @syncComplete.
  ///
  /// In en, this message translates to:
  /// **'Sync complete!'**
  String get syncComplete;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @syncFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get syncFailedToLoad;

  /// No description provided for @syncYourData.
  ///
  /// In en, this message translates to:
  /// **'Your Data'**
  String get syncYourData;

  /// No description provided for @syncStatTrainingCycles.
  ///
  /// In en, this message translates to:
  /// **'TrainingCycles'**
  String get syncStatTrainingCycles;

  /// No description provided for @syncStatSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get syncStatSessions;

  /// No description provided for @syncStatExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get syncStatExercises;

  /// No description provided for @backupSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupSectionTitle;

  /// No description provided for @backupSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your data to a file, or restore from a previous backup. Restoring adds to your existing data — nothing is deleted.'**
  String get backupSectionSubtitle;

  /// No description provided for @backupExportButton.
  ///
  /// In en, this message translates to:
  /// **'Export backup file'**
  String get backupExportButton;

  /// No description provided for @backupRestoreButton.
  ///
  /// In en, this message translates to:
  /// **'Restore from file'**
  String get backupRestoreButton;

  /// No description provided for @backupExportError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t export backup: {error}'**
  String backupExportError(Object error);

  /// No description provided for @backupRestoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup?'**
  String get backupRestoreConfirmTitle;

  /// No description provided for @backupRestoreConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Items from the backup will be added to your existing data. Nothing is deleted, and entries that already exist are kept unchanged.'**
  String get backupRestoreConfirmMessage;

  /// No description provided for @backupRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup restored — {count} items added'**
  String backupRestoreSuccess(Object count);

  /// No description provided for @backupRestoreError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t restore backup: {error}'**
  String backupRestoreError(Object error);

  /// No description provided for @syncMergeNote.
  ///
  /// In en, this message translates to:
  /// **'Syncing merges data — items from the other device are added, nothing is deleted.'**
  String get syncMergeNote;

  /// No description provided for @cloudBackupSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup'**
  String get cloudBackupSectionTitle;

  /// No description provided for @cloudBackupSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep a copy of your data in your account so it survives losing or replacing your device.'**
  String get cloudBackupSectionSubtitle;

  /// No description provided for @cloudBackupOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Back up to the cloud'**
  String get cloudBackupOnboardingTitle;

  /// No description provided for @cloudBackupOnboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your training data safe if you lose or replace your device. Requires a free account with a verified email.'**
  String get cloudBackupOnboardingSubtitle;

  /// No description provided for @cloudBackupEnableTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup'**
  String get cloudBackupEnableTitle;

  /// No description provided for @cloudBackupDisabledNote.
  ///
  /// In en, this message translates to:
  /// **'Turning this off keeps your existing cloud copy.'**
  String get cloudBackupDisabledNote;

  /// No description provided for @cloudBackupAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get cloudBackupAccountLabel;

  /// No description provided for @cloudBackupPendingSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with a verified email to start backing up'**
  String get cloudBackupPendingSignIn;

  /// No description provided for @cloudBackupFinishSignIn.
  ///
  /// In en, this message translates to:
  /// **'Finish sign-in'**
  String get cloudBackupFinishSignIn;

  /// No description provided for @cloudBackupLastBackupLabel.
  ///
  /// In en, this message translates to:
  /// **'Last backup'**
  String get cloudBackupLastBackupLabel;

  /// No description provided for @cloudBackupNever.
  ///
  /// In en, this message translates to:
  /// **'Never backed up'**
  String get cloudBackupNever;

  /// No description provided for @cloudBackupNowButton.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get cloudBackupNowButton;

  /// No description provided for @cloudBackupInProgress.
  ///
  /// In en, this message translates to:
  /// **'Backing up…'**
  String get cloudBackupInProgress;

  /// No description provided for @cloudBackupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backed up to the cloud'**
  String get cloudBackupSuccess;

  /// No description provided for @cloudBackupError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t back up: {error}'**
  String cloudBackupError(Object error);

  /// No description provided for @cloudBackupRestoreButton.
  ///
  /// In en, this message translates to:
  /// **'Restore from cloud'**
  String get cloudBackupRestoreButton;

  /// No description provided for @cloudBackupRestoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore cloud backup?'**
  String get cloudBackupRestoreConfirmTitle;

  /// No description provided for @cloudBackupRestoreConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Items from the cloud backup will be added to your existing data. Nothing is deleted, and entries that already exist are kept unchanged.'**
  String get cloudBackupRestoreConfirmMessage;

  /// No description provided for @cloudBackupRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup restored — {count} items added'**
  String cloudBackupRestoreSuccess(Object count);

  /// No description provided for @cloudBackupRestoreError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t restore: {error}'**
  String cloudBackupRestoreError(Object error);

  /// No description provided for @cloudBackupNoBackupFound.
  ///
  /// In en, this message translates to:
  /// **'No cloud backup found for this account'**
  String get cloudBackupNoBackupFound;

  /// No description provided for @cloudBackupOverwriteEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Overwrite cloud backup?'**
  String get cloudBackupOverwriteEmptyTitle;

  /// No description provided for @cloudBackupOverwriteEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'This device has no data, but your cloud backup does. Backing up now would replace your cloud backup with an empty one. If you\'re setting up a new device, restore from the cloud first.'**
  String get cloudBackupOverwriteEmptyMessage;

  /// No description provided for @cloudBackupDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete cloud backup'**
  String get cloudBackupDeleteButton;

  /// No description provided for @cloudBackupDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete cloud backup?'**
  String get cloudBackupDeleteConfirmTitle;

  /// No description provided for @cloudBackupDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This removes the backup from the cloud. Data on this device is not affected.'**
  String get cloudBackupDeleteConfirmMessage;

  /// No description provided for @cloudBackupDeleted.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup deleted'**
  String get cloudBackupDeleted;

  /// No description provided for @emptyWorkoutCreateCycle.
  ///
  /// In en, this message translates to:
  /// **'Create {cycleTerm}'**
  String emptyWorkoutCreateCycle(Object cycleTerm);

  /// No description provided for @emptyWorkoutUseTemplate.
  ///
  /// In en, this message translates to:
  /// **'Use a template'**
  String get emptyWorkoutUseTemplate;

  /// No description provided for @communityLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Community Library'**
  String get communityLibraryTitle;

  /// No description provided for @communityLibrarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse and download shared templates and themes'**
  String get communityLibrarySubtitle;

  /// No description provided for @settingsDefaultUnitsHeader.
  ///
  /// In en, this message translates to:
  /// **'Default units'**
  String get settingsDefaultUnitsHeader;

  /// No description provided for @settingsPerSportUnitsLink.
  ///
  /// In en, this message translates to:
  /// **'Per-sport units…'**
  String get settingsPerSportUnitsLink;

  /// No description provided for @settingsDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get settingsDiscardTitle;

  /// No description provided for @settingsDiscardMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Leave without saving?'**
  String get settingsDiscardMessage;

  /// No description provided for @settingsDiscardButton.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get settingsDiscardButton;

  /// No description provided for @settingsKeepEditingButton.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get settingsKeepEditingButton;

  /// No description provided for @cycleCreateSummary.
  ///
  /// In en, this message translates to:
  /// **'Creates {periods} periods × {days} training days'**
  String cycleCreateSummary(Object periods, Object days);

  /// No description provided for @cycleListMenuNeedsExercisesHint.
  ///
  /// In en, this message translates to:
  /// **'Add exercises to every training day first'**
  String get cycleListMenuNeedsExercisesHint;

  /// No description provided for @cycleListDeleteDialogDetail.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes {workoutCount} workouts, including {loggedSetCount} logged sets of training history.'**
  String cycleListDeleteDialogDetail(Object workoutCount, Object loggedSetCount);

  /// No description provided for @cardioSessionPromoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Log this session?'**
  String get cardioSessionPromoteTitle;

  /// No description provided for @cardioSessionPromoteMessage.
  ///
  /// In en, this message translates to:
  /// **'Saving marks this planned session as completed with the values entered.'**
  String get cardioSessionPromoteMessage;

  /// No description provided for @cardioSessionModePlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get cardioSessionModePlan;

  /// No description provided for @cardioSessionModeLog.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get cardioSessionModeLog;

  /// No description provided for @cardioSessionRpeClearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear effort rating'**
  String get cardioSessionRpeClearTooltip;

  /// No description provided for @integrationsStravaDisconnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Disconnect Strava?'**
  String get integrationsStravaDisconnectTitle;

  /// No description provided for @integrationsStravaDisconnectMessage.
  ///
  /// In en, this message translates to:
  /// **'New activities will stop syncing. Workouts already imported stay on this device.'**
  String get integrationsStravaDisconnectMessage;

  /// No description provided for @integrationsStravaDisconnectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get integrationsStravaDisconnectConfirm;

  /// No description provided for @exerciseCardHistoryRetry.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load history — tap to retry'**
  String get exerciseCardHistoryRetry;

  /// No description provided for @cycleComparisonLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load cycle statistics'**
  String get cycleComparisonLoadError;

  /// No description provided for @calendarDropdownPeriodAdded.
  ///
  /// In en, this message translates to:
  /// **'Period {number} added'**
  String calendarDropdownPeriodAdded(Object number);

  /// No description provided for @calendarDropdownCannotRemovePeriod.
  ///
  /// In en, this message translates to:
  /// **'Cannot remove: must have at least 1 period'**
  String get calendarDropdownCannotRemovePeriod;

  /// No description provided for @calendarDropdownPeriodRemoved.
  ///
  /// In en, this message translates to:
  /// **'Period {number} removed'**
  String calendarDropdownPeriodRemoved(Object number);

  /// No description provided for @integrationsUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get integrationsUnknownError;

  /// No description provided for @integrationsLastRunSummary.
  ///
  /// In en, this message translates to:
  /// **'Last run: {total} found · {imported} imported · {duplicates} already here · {unsupported} non-cardio skipped'**
  String integrationsLastRunSummary(Object total, Object imported, Object duplicates, Object unsupported);

  /// No description provided for @integrationsAppleHealthRequired.
  ///
  /// In en, this message translates to:
  /// **'Apple Health access needed'**
  String get integrationsAppleHealthRequired;

  /// No description provided for @integrationsAppleHealthIntro.
  ///
  /// In en, this message translates to:
  /// **'YAWA4U reads workouts from Apple Health. Access was denied or hasn\'t been granted yet.'**
  String get integrationsAppleHealthIntro;

  /// No description provided for @integrationsAppleHealthStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Open Settings → Health → Data Access & Devices'**
  String get integrationsAppleHealthStep1;

  /// No description provided for @integrationsAppleHealthStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Choose YAWA4U'**
  String get integrationsAppleHealthStep2;

  /// No description provided for @integrationsAppleHealthStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Turn on the workout categories you want to share'**
  String get integrationsAppleHealthStep3;

  /// No description provided for @integrationsOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get integrationsOpenSettings;

  /// No description provided for @communitySignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get communitySignInButton;

  /// No description provided for @communityTemplateSaved.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" saved — draft cycle created'**
  String communityTemplateSaved(Object name);

  /// No description provided for @statsNoStrengthTitle.
  ///
  /// In en, this message translates to:
  /// **'No workouts logged yet'**
  String get statsNoStrengthTitle;

  /// No description provided for @statsNoStrengthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics appear here after you log your first strength workout.'**
  String get statsNoStrengthSubtitle;

  /// No description provided for @syncWithAnotherDevice.
  ///
  /// In en, this message translates to:
  /// **'Sync with another device'**
  String get syncWithAnotherDevice;

  /// No description provided for @syncWifiRequired.
  ///
  /// In en, this message translates to:
  /// **'Both devices must be on the same WiFi network.'**
  String get syncWifiRequired;

  /// No description provided for @syncHostButton.
  ///
  /// In en, this message translates to:
  /// **'Host Sync (Show QR Code)'**
  String get syncHostButton;

  /// No description provided for @syncScanQrButton.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get syncScanQrButton;

  /// No description provided for @syncWaitingForConnection.
  ///
  /// In en, this message translates to:
  /// **'Waiting for connection...'**
  String get syncWaitingForConnection;

  /// No description provided for @syncScanFromOtherDevice.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code from the other device'**
  String get syncScanFromOtherDevice;

  /// No description provided for @syncScannerPrompt.
  ///
  /// In en, this message translates to:
  /// **'Point camera at QR code'**
  String get syncScannerPrompt;

  /// No description provided for @syncCameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera Error'**
  String get syncCameraError;

  /// No description provided for @syncCameraAccessFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not access camera'**
  String get syncCameraAccessFailed;

  /// No description provided for @syncGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get syncGoBack;

  /// No description provided for @pasteCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Enter Code Manually'**
  String get pasteCodeButton;

  /// No description provided for @pasteCodeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Connection Code'**
  String get pasteCodeDialogTitle;

  /// No description provided for @pasteCodeDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the code shown on the other device'**
  String get pasteCodeDialogHint;

  /// No description provided for @pasteCodeDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get pasteCodeDialogConfirm;

  /// No description provided for @syncConnectedTo.
  ///
  /// In en, this message translates to:
  /// **'Connected to'**
  String get syncConnectedTo;

  /// No description provided for @syncWhatToDo.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get syncWhatToDo;

  /// No description provided for @syncImportFrom.
  ///
  /// In en, this message translates to:
  /// **'Import from {deviceName}'**
  String syncImportFrom(Object deviceName);

  /// No description provided for @syncExportTo.
  ///
  /// In en, this message translates to:
  /// **'Export to {deviceName}'**
  String syncExportTo(Object deviceName);

  /// No description provided for @syncDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get syncDisconnect;

  /// No description provided for @communityTabPrograms.
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get communityTabPrograms;

  /// No description provided for @communityTabThemes.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get communityTabThemes;

  /// No description provided for @communityTabMyUploads.
  ///
  /// In en, this message translates to:
  /// **'My Uploads'**
  String get communityTabMyUploads;

  /// No description provided for @communityUploadTooltip.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get communityUploadTooltip;

  /// No description provided for @communityShareProgram.
  ///
  /// In en, this message translates to:
  /// **'Share a Program'**
  String get communityShareProgram;

  /// No description provided for @communityShareTheme.
  ///
  /// In en, this message translates to:
  /// **'Share a Theme'**
  String get communityShareTheme;

  /// No description provided for @communitySortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by:'**
  String get communitySortBy;

  /// No description provided for @communitySortPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get communitySortPopular;

  /// No description provided for @communitySortRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get communitySortRecent;

  /// No description provided for @communityNoProgramsTitle.
  ///
  /// In en, this message translates to:
  /// **'No programs shared yet'**
  String get communityNoProgramsTitle;

  /// No description provided for @communityNoProgramsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share a program!'**
  String get communityNoProgramsSubtitle;

  /// No description provided for @communityCouldNotLoadPrograms.
  ///
  /// In en, this message translates to:
  /// **'Could not load community programs'**
  String get communityCouldNotLoadPrograms;

  /// No description provided for @communityNoThemesTitle.
  ///
  /// In en, this message translates to:
  /// **'No themes shared yet'**
  String get communityNoThemesTitle;

  /// No description provided for @communityNoThemesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share a theme!'**
  String get communityNoThemesSubtitle;

  /// No description provided for @communityCouldNotLoadThemes.
  ///
  /// In en, this message translates to:
  /// **'Could not load community themes'**
  String get communityCouldNotLoadThemes;

  /// No description provided for @communitySignInToSeeUploads.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your uploads'**
  String get communitySignInToSeeUploads;

  /// No description provided for @communityMyPrograms.
  ///
  /// In en, this message translates to:
  /// **'My Programs'**
  String get communityMyPrograms;

  /// No description provided for @communityNoProgramsUploaded.
  ///
  /// In en, this message translates to:
  /// **'No programs uploaded yet.'**
  String get communityNoProgramsUploaded;

  /// No description provided for @communityFailedToLoadPrograms.
  ///
  /// In en, this message translates to:
  /// **'Failed to load your programs'**
  String get communityFailedToLoadPrograms;

  /// No description provided for @communityMyThemes.
  ///
  /// In en, this message translates to:
  /// **'My Themes'**
  String get communityMyThemes;

  /// No description provided for @communityNoThemesUploaded.
  ///
  /// In en, this message translates to:
  /// **'No themes uploaded yet.'**
  String get communityNoThemesUploaded;

  /// No description provided for @communityFailedToLoadThemes.
  ///
  /// In en, this message translates to:
  /// **'Failed to load your themes'**
  String get communityFailedToLoadThemes;

  /// No description provided for @communityDeleteProgramTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Program?'**
  String get communityDeleteProgramTitle;

  /// No description provided for @communityDeleteProgramContent.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from the community library? This cannot be undone.'**
  String communityDeleteProgramContent(Object name);

  /// No description provided for @communityDeleteThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Theme?'**
  String get communityDeleteThemeTitle;

  /// No description provided for @communityDeleteThemeContent.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from the community library? This cannot be undone.'**
  String communityDeleteThemeContent(Object name);

  /// No description provided for @communityItemDeleted.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" deleted'**
  String communityItemDeleted(Object name);

  /// No description provided for @communityFailedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete: {error}'**
  String communityFailedToDelete(Object error);

  /// No description provided for @communityDownloadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} downloads'**
  String communityDownloadCount(Object count);

  /// No description provided for @communityDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get communityDeleteTooltip;

  /// No description provided for @communityPeriodsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Periods'**
  String communityPeriodsCount(Object count);

  /// No description provided for @communitySessionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Sessions'**
  String communitySessionsCount(Object count);

  /// No description provided for @communityColorPreview.
  ///
  /// In en, this message translates to:
  /// **'Color Preview'**
  String get communityColorPreview;

  /// No description provided for @communityNoColorData.
  ///
  /// In en, this message translates to:
  /// **'No color data available'**
  String get communityNoColorData;

  /// No description provided for @communityColorPreviewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Color preview unavailable'**
  String get communityColorPreviewUnavailable;

  /// No description provided for @communityInvalidThemeData.
  ///
  /// In en, this message translates to:
  /// **'This theme has invalid data and cannot be downloaded'**
  String get communityInvalidThemeData;

  /// No description provided for @communitySavedToThemes.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" saved to your themes'**
  String communitySavedToThemes(Object name);

  /// No description provided for @communitySavedToPrograms.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" saved to your programs'**
  String communitySavedToPrograms(Object name);

  /// No description provided for @communityDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed: {error}'**
  String communityDownloadFailed(Object error);

  /// No description provided for @communityDownloadThemeButton.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD THEME'**
  String get communityDownloadThemeButton;

  /// No description provided for @communityDownloadProgramButton.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD PROGRAM'**
  String get communityDownloadProgramButton;

  /// No description provided for @communitySavedButton.
  ///
  /// In en, this message translates to:
  /// **'SAVED'**
  String get communitySavedButton;

  /// No description provided for @communitySessionsHeader.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get communitySessionsHeader;

  /// No description provided for @communityDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get communityDurationLabel;

  /// No description provided for @communityPerPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Per Period'**
  String get communityPerPeriodLabel;

  /// No description provided for @communityRecoveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get communityRecoveryLabel;

  /// No description provided for @communityDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Days'**
  String communityDaysCount(Object count);

  /// No description provided for @communityPeriodNumber.
  ///
  /// In en, this message translates to:
  /// **'Period {number}'**
  String communityPeriodNumber(Object number);

  /// No description provided for @communityDayFallback.
  ///
  /// In en, this message translates to:
  /// **'Day {number}'**
  String communityDayFallback(Object number);

  /// No description provided for @communityCardioSession.
  ///
  /// In en, this message translates to:
  /// **'{sport} session'**
  String communityCardioSession(Object sport);

  /// No description provided for @communityExerciseCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Exercises'**
  String communityExerciseCount(Object count);

  /// No description provided for @communitySetsReps.
  ///
  /// In en, this message translates to:
  /// **'{sets} sets × {reps}'**
  String communitySetsReps(Object sets, Object reps);

  /// No description provided for @uploadShareThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Share a Theme'**
  String get uploadShareThemeTitle;

  /// No description provided for @uploadShareProgramTitle.
  ///
  /// In en, this message translates to:
  /// **'Share a Program'**
  String get uploadShareProgramTitle;

  /// No description provided for @uploadSelectThemeDesc.
  ///
  /// In en, this message translates to:
  /// **'Select a custom theme to share with the community.'**
  String get uploadSelectThemeDesc;

  /// No description provided for @uploadSelectProgramDesc.
  ///
  /// In en, this message translates to:
  /// **'Select a program to share with the community.'**
  String get uploadSelectProgramDesc;

  /// No description provided for @uploadThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get uploadThemeLabel;

  /// No description provided for @uploadProgramLabel.
  ///
  /// In en, this message translates to:
  /// **'Program'**
  String get uploadProgramLabel;

  /// No description provided for @uploadNoCustomThemes.
  ///
  /// In en, this message translates to:
  /// **'No custom themes to share.'**
  String get uploadNoCustomThemes;

  /// No description provided for @uploadCreateCustomThemeHint.
  ///
  /// In en, this message translates to:
  /// **'Create a custom theme in Settings first.'**
  String get uploadCreateCustomThemeHint;

  /// No description provided for @uploadNoSavedPrograms.
  ///
  /// In en, this message translates to:
  /// **'No saved programs to share.'**
  String get uploadNoSavedPrograms;

  /// No description provided for @uploadDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Display Name'**
  String get uploadDisplayNameLabel;

  /// No description provided for @uploadDisplayNameHint.
  ///
  /// In en, this message translates to:
  /// **'How others will see your name'**
  String get uploadDisplayNameHint;

  /// No description provided for @uploadTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags (optional)'**
  String get uploadTagsLabel;

  /// No description provided for @uploadTemplateTagsHint.
  ///
  /// In en, this message translates to:
  /// **'beginner, strength, 4-week'**
  String get uploadTemplateTagsHint;

  /// No description provided for @uploadThemeTagsHint.
  ///
  /// In en, this message translates to:
  /// **'dark, minimal, colorful'**
  String get uploadThemeTagsHint;

  /// No description provided for @uploadTemplateTagsHelper.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated tags to help others find your program'**
  String get uploadTemplateTagsHelper;

  /// No description provided for @uploadThemeTagsHelper.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated tags to help others find your theme'**
  String get uploadThemeTagsHelper;

  /// No description provided for @uploadPublishThemeButton.
  ///
  /// In en, this message translates to:
  /// **'PUBLISH THEME'**
  String get uploadPublishThemeButton;

  /// No description provided for @uploadPublishProgramButton.
  ///
  /// In en, this message translates to:
  /// **'PUBLISH PROGRAM'**
  String get uploadPublishProgramButton;

  /// No description provided for @uploadEnterDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a display name'**
  String get uploadEnterDisplayName;

  /// No description provided for @uploadNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in. Please try again.'**
  String get uploadNotSignedIn;

  /// No description provided for @uploadPublishedToCommunity.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" published to the community!'**
  String uploadPublishedToCommunity(Object name);

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String uploadFailed(Object error);

  /// No description provided for @uploadErrorLoadingTemplates.
  ///
  /// In en, this message translates to:
  /// **'Error loading templates: {error}'**
  String uploadErrorLoadingTemplates(Object error);

  /// No description provided for @uploadTemplateSummary.
  ///
  /// In en, this message translates to:
  /// **'{periods} periods, {days} days/period, {sessions} sessions'**
  String uploadTemplateSummary(Object periods, Object days, Object sessions);

  /// No description provided for @moreScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'YAWA4U'**
  String get moreScreenTitle;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(Object version);

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themeMode;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @sectionTraining.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get sectionTraining;

  /// No description provided for @sectionIntegrationsData.
  ///
  /// In en, this message translates to:
  /// **'Integrations & data'**
  String get sectionIntegrationsData;

  /// No description provided for @sectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get sectionPreferences;

  /// No description provided for @sectionHelpFeedback.
  ///
  /// In en, this message translates to:
  /// **'Help & feedback'**
  String get sectionHelpFeedback;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @sectionDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get sectionDeveloper;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @themeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your app theme'**
  String get themeSubtitle;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @statisticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Volume, records, and progress'**
  String get statisticsSubtitle;

  /// No description provided for @unitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get unitsTitle;

  /// No description provided for @unitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Metric or imperial — per sport'**
  String get unitsSubtitle;

  /// No description provided for @zonesTitle.
  ///
  /// In en, this message translates to:
  /// **'Zones'**
  String get zonesTitle;

  /// No description provided for @zonesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Heart-rate zones per sport'**
  String get zonesSubtitle;

  /// No description provided for @integrationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Apple Health / Health Connect — includes Peloton'**
  String get integrationsSubtitle;

  /// No description provided for @syncDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync data'**
  String get syncDataTitle;

  /// No description provided for @syncDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sync with another device via WiFi'**
  String get syncDataSubtitle;

  /// No description provided for @shareTemplateTitle.
  ///
  /// In en, this message translates to:
  /// **'Share template'**
  String get shareTemplateTitle;

  /// No description provided for @shareTemplateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share workout templates via WiFi'**
  String get shareTemplateSubtitle;

  /// No description provided for @shareAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Share app'**
  String get shareAppTitle;

  /// No description provided for @shareAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share YAWA4U with friends'**
  String get shareAppSubtitle;

  /// No description provided for @shareAppText.
  ///
  /// In en, this message translates to:
  /// **'Check out YAWA4U - The best workout tracker! https://testflight.apple.com/join/YVQsRjzD'**
  String get shareAppText;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Terminology, equipment, body metrics'**
  String get settingsSubtitle;

  /// No description provided for @sendFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedbackTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSheetTitle;

  /// No description provided for @languageSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the display language for the app'**
  String get languageSheetSubtitle;

  /// No description provided for @websiteTitle.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get websiteTitle;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicyTitle;

  /// No description provided for @sentryDebugTitle.
  ///
  /// In en, this message translates to:
  /// **'Sentry debug'**
  String get sentryDebugTitle;

  /// No description provided for @sentryDebugSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Test Sentry integration'**
  String get sentryDebugSubtitle;

  /// No description provided for @exercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercisesTitle;

  /// No description provided for @exercisesNoActiveCycleTitle.
  ///
  /// In en, this message translates to:
  /// **'No Active TrainingCycle'**
  String get exercisesNoActiveCycleTitle;

  /// No description provided for @exercisesNoActiveCycleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create and start a trainingCycle to begin'**
  String get exercisesNoActiveCycleSubtitle;

  /// No description provided for @exercisesNoScheduledTitle.
  ///
  /// In en, this message translates to:
  /// **'No exercises scheduled'**
  String get exercisesNoScheduledTitle;

  /// No description provided for @exercisesNoScheduledSubtitleForDay.
  ///
  /// In en, this message translates to:
  /// **'Add exercises for Period {period}, Day {day}'**
  String exercisesNoScheduledSubtitleForDay(Object period, Object day);

  /// No description provided for @exercisesNoScheduledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add exercises for this day'**
  String get exercisesNoScheduledSubtitle;

  /// No description provided for @exercisesAddExercise.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get exercisesAddExercise;

  /// No description provided for @exercisesPeriodDayHeader.
  ///
  /// In en, this message translates to:
  /// **'PERIOD {period} DAY {day}'**
  String exercisesPeriodDayHeader(Object period, Object day);

  /// No description provided for @exercisesPeriodDayHeaderWithName.
  ///
  /// In en, this message translates to:
  /// **'PERIOD {period} DAY {day} {dayName}'**
  String exercisesPeriodDayHeaderWithName(Object period, Object day, Object dayName);

  /// No description provided for @exercisesSelectDayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select day'**
  String get exercisesSelectDayTooltip;

  /// No description provided for @exercisesToggleHistoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Toggle history'**
  String get exercisesToggleHistoryTooltip;

  /// No description provided for @exercisesMenuNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get exercisesMenuNote;

  /// No description provided for @exercisesMenuSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get exercisesMenuSummary;

  /// No description provided for @exercisesMenuWorkoutHeader.
  ///
  /// In en, this message translates to:
  /// **'WORKOUT'**
  String get exercisesMenuWorkoutHeader;

  /// No description provided for @exercisesMenuAddExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get exercisesMenuAddExercise;

  /// No description provided for @exercisesMenuReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get exercisesMenuReset;

  /// No description provided for @exercisesFinishWorkout.
  ///
  /// In en, this message translates to:
  /// **'FINISH WORKOUT'**
  String get exercisesFinishWorkout;

  /// No description provided for @exercisesResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Workout'**
  String get exercisesResetTitle;

  /// No description provided for @exercisesResetContent.
  ///
  /// In en, this message translates to:
  /// **'This will clear all logged sets and entered data for this workout. This cannot be undone.'**
  String get exercisesResetContent;

  /// No description provided for @exercisesResetAction.
  ///
  /// In en, this message translates to:
  /// **'RESET'**
  String get exercisesResetAction;

  /// No description provided for @exercisesWorkoutReset.
  ///
  /// In en, this message translates to:
  /// **'Workout reset'**
  String get exercisesWorkoutReset;

  /// No description provided for @exercisesHistoryHeader.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get exercisesHistoryHeader;

  /// No description provided for @exercisesUnknownCycle.
  ///
  /// In en, this message translates to:
  /// **'Unknown TrainingCycle'**
  String get exercisesUnknownCycle;

  /// No description provided for @exercisesCycleHistoryHeader.
  ///
  /// In en, this message translates to:
  /// **'{name} - {periods} PERIODS'**
  String exercisesCycleHistoryHeader(Object name, Object periods);

  /// No description provided for @exercisesDeloadLabel.
  ///
  /// In en, this message translates to:
  /// **'DELOAD'**
  String get exercisesDeloadLabel;

  /// No description provided for @exercisesUnknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get exercisesUnknownDate;

  /// No description provided for @exercisesHistoryPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'PERIOD '**
  String get exercisesHistoryPeriodLabel;

  /// No description provided for @exercisesHistoryDayLabel.
  ///
  /// In en, this message translates to:
  /// **' - DAY '**
  String get exercisesHistoryDayLabel;

  /// No description provided for @exercisesBodyweightAbbrev.
  ///
  /// In en, this message translates to:
  /// **'BW'**
  String get exercisesBodyweightAbbrev;

  /// No description provided for @exercisesCycleCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'{cycleTerm} Completed!'**
  String exercisesCycleCompletedTitle(Object cycleTerm);

  /// No description provided for @exercisesCycleCompletedContent.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You have finished all workouts in this {cycleTerm}.'**
  String exercisesCycleCompletedContent(Object cycleTerm);

  /// No description provided for @exercisesAwesome.
  ///
  /// In en, this message translates to:
  /// **'AWESOME'**
  String get exercisesAwesome;

  /// No description provided for @exercisesCycleNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'{cycleTerm} Note'**
  String exercisesCycleNoteTitle(Object cycleTerm);

  /// No description provided for @exercisesCycleNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Enter note for this {cycleTerm}...'**
  String exercisesCycleNoteHint(Object cycleTerm);

  /// No description provided for @exercisesErrorSavingNote.
  ///
  /// In en, this message translates to:
  /// **'Error saving note: {error}'**
  String exercisesErrorSavingNote(Object error);

  /// No description provided for @exercisesWeightUnitLbs.
  ///
  /// In en, this message translates to:
  /// **'lbs'**
  String get exercisesWeightUnitLbs;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @statsTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get statsTabOverview;

  /// No description provided for @statsTabCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get statsTabCardio;

  /// No description provided for @statsTabCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get statsTabCompare;

  /// No description provided for @statsTabBody.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get statsTabBody;

  /// No description provided for @statsNoCardioTitle.
  ///
  /// In en, this message translates to:
  /// **'No cardio logged yet'**
  String get statsNoCardioTitle;

  /// No description provided for @statsNoCardioSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log a run, bike, or swim from the More tab — stats will show up here once you have a session or two on record.'**
  String get statsNoCardioSubtitle;

  /// No description provided for @statsWeeklyVolume.
  ///
  /// In en, this message translates to:
  /// **'Weekly volume — last 12 weeks'**
  String get statsWeeklyVolume;

  /// No description provided for @statsBySport.
  ///
  /// In en, this message translates to:
  /// **'By sport'**
  String get statsBySport;

  /// No description provided for @statsLifetimeTotals.
  ///
  /// In en, this message translates to:
  /// **'Lifetime totals'**
  String get statsLifetimeTotals;

  /// No description provided for @statsCardioSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get statsCardioSessions;

  /// No description provided for @statsCardioHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get statsCardioHours;

  /// No description provided for @statsCardioCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statsCardioCompleted;

  /// No description provided for @statsNoMeasurementsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Measurements Yet'**
  String get statsNoMeasurementsTitle;

  /// No description provided for @statsNoMeasurementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add body measurements in Settings\nto see your progress here.'**
  String get statsNoMeasurementsSubtitle;

  /// No description provided for @statsWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get statsWeightLabel;

  /// No description provided for @statsWeightValueKg.
  ///
  /// In en, this message translates to:
  /// **'{weight} kg'**
  String statsWeightValueKg(Object weight);

  /// No description provided for @statsBmiLabel.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get statsBmiLabel;

  /// No description provided for @statsEntriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get statsEntriesLabel;

  /// No description provided for @statsWeightProgression.
  ///
  /// In en, this message translates to:
  /// **'Weight Progression'**
  String get statsWeightProgression;

  /// No description provided for @statsBodyComposition.
  ///
  /// In en, this message translates to:
  /// **'Body Composition'**
  String get statsBodyComposition;

  /// No description provided for @statsBodyFatEntry.
  ///
  /// In en, this message translates to:
  /// **'{fatPercent}% body fat'**
  String statsBodyFatEntry(Object fatPercent);

  /// No description provided for @statsBodyFatWithLean.
  ///
  /// In en, this message translates to:
  /// **'{fatPercent}% body fat / {leanMass} kg lean'**
  String statsBodyFatWithLean(Object fatPercent, Object leanMass);

  /// No description provided for @statsErrorLoadingMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Error loading measurements: {error}'**
  String statsErrorLoadingMeasurements(Object error);

  /// No description provided for @statsVolumeByMuscleGroup.
  ///
  /// In en, this message translates to:
  /// **'Volume by Muscle Group'**
  String get statsVolumeByMuscleGroup;

  /// No description provided for @statsVolumeProgression.
  ///
  /// In en, this message translates to:
  /// **'Volume Progression'**
  String get statsVolumeProgression;

  /// No description provided for @statsMostUsedExercises.
  ///
  /// In en, this message translates to:
  /// **'Most Used Exercises'**
  String get statsMostUsedExercises;

  /// No description provided for @statsPersonalRecords.
  ///
  /// In en, this message translates to:
  /// **'Personal Records'**
  String get statsPersonalRecords;

  /// No description provided for @statsSessionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get statsSessionsLabel;

  /// No description provided for @statsSessionsValue.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total}'**
  String statsSessionsValue(Object completed, Object total);

  /// No description provided for @statsCompletionLabel.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get statsCompletionLabel;

  /// No description provided for @statsCompletionValue.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String statsCompletionValue(Object percent);

  /// No description provided for @statsTotalSetsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Sets'**
  String get statsTotalSetsLabel;

  /// No description provided for @statsExerciseFrequencyCount.
  ///
  /// In en, this message translates to:
  /// **'{count}x'**
  String statsExerciseFrequencyCount(Object count);

  /// No description provided for @statsPersonalRecordWeight.
  ///
  /// In en, this message translates to:
  /// **'{weight} lbs'**
  String statsPersonalRecordWeight(Object weight);

  /// No description provided for @statsActiveCycleLabel.
  ///
  /// In en, this message translates to:
  /// **'{cycleName} (Active)'**
  String statsActiveCycleLabel(Object cycleName);

  /// No description provided for @statsAllTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get statsAllTimeLabel;

  /// No description provided for @restTimerDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest Timer'**
  String get restTimerDialogTitle;

  /// No description provided for @restTimerUseDefault.
  ///
  /// In en, this message translates to:
  /// **'Use default'**
  String get restTimerUseDefault;

  /// No description provided for @restTimerBasedOnSetType.
  ///
  /// In en, this message translates to:
  /// **'Based on set type'**
  String get restTimerBasedOnSetType;

  /// No description provided for @restTimerDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get restTimerDuration;

  /// No description provided for @addSessionPlanSport.
  ///
  /// In en, this message translates to:
  /// **'Plan {sport}'**
  String addSessionPlanSport(Object sport);

  /// No description provided for @addSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Session'**
  String get addSessionTitle;

  /// No description provided for @selectMuscleGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Muscle Group'**
  String get selectMuscleGroupTitle;

  /// No description provided for @startFromTemplate.
  ///
  /// In en, this message translates to:
  /// **'Start from template'**
  String get startFromTemplate;

  /// No description provided for @planSportButton.
  ///
  /// In en, this message translates to:
  /// **'Plan {sport}'**
  String planSportButton(Object sport);

  /// No description provided for @sessionPlannedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'{sport} session planned'**
  String sessionPlannedSnackbar(Object sport);

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String failedToSave(Object error);

  /// No description provided for @createCustomExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Custom Exercise'**
  String get createCustomExerciseTitle;

  /// No description provided for @exerciseNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercise Name'**
  String get exerciseNameLabel;

  /// No description provided for @exerciseNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Cable Chest Fly'**
  String get exerciseNameHint;

  /// No description provided for @exerciseNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an exercise name'**
  String get exerciseNameRequired;

  /// No description provided for @exerciseNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get exerciseNameMinLength;

  /// No description provided for @muscleGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Muscle Group'**
  String get muscleGroupLabel;

  /// No description provided for @secondaryMuscleGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Secondary Muscle Group (Optional)'**
  String get secondaryMuscleGroupLabel;

  /// No description provided for @secondaryMuscleGroupNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get secondaryMuscleGroupNone;

  /// No description provided for @equipmentTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Equipment Type'**
  String get equipmentTypeLabel;

  /// No description provided for @restTimerOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest Timer (Optional)'**
  String get restTimerOptionalLabel;

  /// No description provided for @restTimerHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 90'**
  String get restTimerHint;

  /// No description provided for @restTimerSuffix.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get restTimerSuffix;

  /// No description provided for @restTimerValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a value between 0 and 600'**
  String get restTimerValidation;

  /// No description provided for @exerciseNameExists.
  ///
  /// In en, this message translates to:
  /// **'An exercise with this name already exists'**
  String get exerciseNameExists;

  /// No description provided for @failedToCreateExercise.
  ///
  /// In en, this message translates to:
  /// **'Failed to create exercise: {error}'**
  String failedToCreateExercise(Object error);

  /// No description provided for @creatingButton.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creatingButton;

  /// No description provided for @createButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createButton;

  /// No description provided for @jointPainLabel.
  ///
  /// In en, this message translates to:
  /// **'Joint Pain'**
  String get jointPainLabel;

  /// No description provided for @musclePumpLabel.
  ///
  /// In en, this message translates to:
  /// **'Muscle Pump'**
  String get musclePumpLabel;

  /// No description provided for @workloadLabel.
  ///
  /// In en, this message translates to:
  /// **'Workload'**
  String get workloadLabel;

  /// No description provided for @detailTab.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get detailTab;

  /// No description provided for @historyTab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTab;

  /// No description provided for @videoAvailable.
  ///
  /// In en, this message translates to:
  /// **'Video Available'**
  String get videoAvailable;

  /// No description provided for @watchOnYouTube.
  ///
  /// In en, this message translates to:
  /// **'Watch on YouTube'**
  String get watchOnYouTube;

  /// No description provided for @viewOnYouTube.
  ///
  /// In en, this message translates to:
  /// **'View on YouTube'**
  String get viewOnYouTube;

  /// No description provided for @noVideoAvailable.
  ///
  /// In en, this message translates to:
  /// **'No video available'**
  String get noVideoAvailable;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @noNotesAdded.
  ///
  /// In en, this message translates to:
  /// **'No notes added yet.'**
  String get noNotesAdded;

  /// No description provided for @errorLoadingHistory.
  ///
  /// In en, this message translates to:
  /// **'Error loading history: {error}'**
  String errorLoadingHistory(Object error);

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// No description provided for @noHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete sets to build your exercise history.'**
  String get noHistoryDescription;

  /// No description provided for @weightProgressionLabel.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT PROGRESSION'**
  String get weightProgressionLabel;

  /// No description provided for @unknownTrainingCycle.
  ///
  /// In en, this message translates to:
  /// **'Unknown TrainingCycle'**
  String get unknownTrainingCycle;

  /// No description provided for @trainingCyclePeriodsHeader.
  ///
  /// In en, this message translates to:
  /// **'{name} - {count} PERIODS'**
  String trainingCyclePeriodsHeader(Object name, Object count);

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get unknownDate;

  /// No description provided for @recoveryLabel.
  ///
  /// In en, this message translates to:
  /// **'RECOVERY'**
  String get recoveryLabel;

  /// No description provided for @periodDayLabel.
  ///
  /// In en, this message translates to:
  /// **'PERIOD {period} - DAY {day}'**
  String periodDayLabel(Object period, Object day);

  /// No description provided for @bodyweightAbbrev.
  ///
  /// In en, this message translates to:
  /// **'BW'**
  String get bodyweightAbbrev;

  /// No description provided for @setTypesTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Types'**
  String get setTypesTitle;

  /// No description provided for @regularSetBadge.
  ///
  /// In en, this message translates to:
  /// **'REG'**
  String get regularSetBadge;

  /// No description provided for @trainingCycleNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Training Cycle Note'**
  String get trainingCycleNoteTitle;

  /// No description provided for @workoutNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Note'**
  String get workoutNoteTitle;

  /// No description provided for @exerciseNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Note'**
  String get exerciseNoteTitle;

  /// No description provided for @sessionNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Session Note'**
  String get sessionNoteTitle;

  /// No description provided for @trainingCycleNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Enter note for this training cycle...'**
  String get trainingCycleNoteHint;

  /// No description provided for @workoutNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Enter note for this workout...'**
  String get workoutNoteHint;

  /// No description provided for @exerciseNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Enter note for this exercise...'**
  String get exerciseNoteHint;

  /// No description provided for @sessionNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Enter note for this session...'**
  String get sessionNoteHint;

  /// No description provided for @pinToExercise.
  ///
  /// In en, this message translates to:
  /// **'Pin to Exercise'**
  String get pinToExercise;

  /// No description provided for @renameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameTitle;

  /// No description provided for @trainingCycleNameHint.
  ///
  /// In en, this message translates to:
  /// **'TrainingCycle name'**
  String get trainingCycleNameHint;

  /// No description provided for @updateDayLabelTitle.
  ///
  /// In en, this message translates to:
  /// **'Update day label'**
  String get updateDayLabelTitle;

  /// No description provided for @updateDayLabelDesc.
  ///
  /// In en, this message translates to:
  /// **'You can apply a different weekday label to this day.'**
  String get updateDayLabelDesc;

  /// No description provided for @mondayLabel.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get mondayLabel;

  /// No description provided for @tuesdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesdayLabel;

  /// No description provided for @wednesdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesdayLabel;

  /// No description provided for @thursdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursdayLabel;

  /// No description provided for @fridayLabel.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get fridayLabel;

  /// No description provided for @saturdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturdayLabel;

  /// No description provided for @sundayLabel.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sundayLabel;

  /// No description provided for @applyToAllDays.
  ///
  /// In en, this message translates to:
  /// **'Apply to all days in this position'**
  String get applyToAllDays;

  /// No description provided for @avgHrLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg HR'**
  String get avgHrLabel;

  /// No description provided for @bpmSuffix.
  ///
  /// In en, this message translates to:
  /// **'bpm'**
  String get bpmSuffix;

  /// No description provided for @logSessionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Log session'**
  String get logSessionTooltip;

  /// No description provided for @logSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Log session'**
  String get logSessionTitle;

  /// No description provided for @cardioTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'TARGET'**
  String get cardioTargetLabel;

  /// No description provided for @cardioNoTargetSet.
  ///
  /// In en, this message translates to:
  /// **'No target set'**
  String get cardioNoTargetSet;

  /// No description provided for @cardioIntervalsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 interval} other{{count} intervals}}'**
  String cardioIntervalsCount(int count);

  /// No description provided for @cardioCompletedStatus.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get cardioCompletedStatus;

  /// No description provided for @cardioAddFeedback.
  ///
  /// In en, this message translates to:
  /// **'Add feedback'**
  String get cardioAddFeedback;

  /// No description provided for @cardioLogSession.
  ///
  /// In en, this message translates to:
  /// **'Log session'**
  String get cardioLogSession;

  /// No description provided for @cardioSessionSkipped.
  ///
  /// In en, this message translates to:
  /// **'Session skipped'**
  String get cardioSessionSkipped;

  /// No description provided for @cardioSkippedFooter.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get cardioSkippedFooter;

  /// No description provided for @cardioSessionMenuHeader.
  ///
  /// In en, this message translates to:
  /// **'SESSION'**
  String get cardioSessionMenuHeader;

  /// No description provided for @cardioNotesMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get cardioNotesMenuItem;

  /// No description provided for @cardioMoveUpMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get cardioMoveUpMenuItem;

  /// No description provided for @cardioMoveDownMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get cardioMoveDownMenuItem;

  /// No description provided for @cardioReplaceMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get cardioReplaceMenuItem;

  /// No description provided for @cardioSkipSessionMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Skip session'**
  String get cardioSkipSessionMenuItem;

  /// No description provided for @cardioDeleteSessionMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Delete session'**
  String get cardioDeleteSessionMenuItem;

  /// No description provided for @cardioDistanceMetric.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get cardioDistanceMetric;

  /// No description provided for @cardioDurationMetric.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get cardioDurationMetric;

  /// No description provided for @cardioSwolfMetric.
  ///
  /// In en, this message translates to:
  /// **'SWOLF'**
  String get cardioSwolfMetric;

  /// No description provided for @cardioPaceMetric.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get cardioPaceMetric;

  /// No description provided for @cardioAvgSpeedMetric.
  ///
  /// In en, this message translates to:
  /// **'Avg speed'**
  String get cardioAvgSpeedMetric;

  /// No description provided for @cardioLapsFormat.
  ///
  /// In en, this message translates to:
  /// **'{count} laps'**
  String cardioLapsFormat(Object count);

  /// No description provided for @cardioPoolLabel.
  ///
  /// In en, this message translates to:
  /// **'pool'**
  String get cardioPoolLabel;

  /// No description provided for @cardioAvgLabel.
  ///
  /// In en, this message translates to:
  /// **'avg'**
  String get cardioAvgLabel;

  /// No description provided for @cardioMaxLabel.
  ///
  /// In en, this message translates to:
  /// **'max'**
  String get cardioMaxLabel;

  /// No description provided for @cardioElevationGain.
  ///
  /// In en, this message translates to:
  /// **'{meters} m'**
  String cardioElevationGain(Object meters);

  /// No description provided for @cardioHrBpm.
  ///
  /// In en, this message translates to:
  /// **'{bpm} bpm'**
  String cardioHrBpm(Object bpm);

  /// No description provided for @cardioPowerWatts.
  ///
  /// In en, this message translates to:
  /// **'{watts} W'**
  String cardioPowerWatts(Object watts);

  /// No description provided for @cardioRpeFormat.
  ///
  /// In en, this message translates to:
  /// **'RPE {value}'**
  String cardioRpeFormat(Object value);

  /// No description provided for @distanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distanceLabel;

  /// No description provided for @metersSuffix.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get metersSuffix;

  /// No description provided for @yardsSuffix.
  ///
  /// In en, this message translates to:
  /// **'yd'**
  String get yardsSuffix;

  /// No description provided for @kilometersSuffix.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get kilometersSuffix;

  /// No description provided for @milesSuffix.
  ///
  /// In en, this message translates to:
  /// **'mi'**
  String get milesSuffix;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @durationHint.
  ///
  /// In en, this message translates to:
  /// **'00:30:00'**
  String get durationHint;

  /// No description provided for @durationFormatError.
  ///
  /// In en, this message translates to:
  /// **'Use MM:SS or HH:MM:SS'**
  String get durationFormatError;

  /// No description provided for @insertColonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Insert colon'**
  String get insertColonTooltip;

  /// No description provided for @readyToTrain.
  ///
  /// In en, this message translates to:
  /// **'Ready to train?'**
  String get readyToTrain;

  /// No description provided for @pickSportPrompt.
  ///
  /// In en, this message translates to:
  /// **'Pick a sport to add today\'s session.'**
  String get pickSportPrompt;

  /// No description provided for @addSportSessionSemantic.
  ///
  /// In en, this message translates to:
  /// **'Add a {sport} session'**
  String addSportSessionSemantic(Object sport);

  /// No description provided for @thisWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeekTitle;

  /// No description provided for @nothingLoggedYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet — your next session lands here.'**
  String get nothingLoggedYet;

  /// No description provided for @strengthSessionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 strength session} other{{count} strength sessions}}'**
  String strengthSessionCount(int count);

  /// No description provided for @calendarLegendTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar Legend'**
  String get calendarLegendTitle;

  /// No description provided for @legendWorkoutStatus.
  ///
  /// In en, this message translates to:
  /// **'Workout Status'**
  String get legendWorkoutStatus;

  /// No description provided for @legendCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get legendCompleted;

  /// No description provided for @legendCompletedDesc.
  ///
  /// In en, this message translates to:
  /// **'All sessions for the day are done'**
  String get legendCompletedDesc;

  /// No description provided for @legendPartiallyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Partially Completed'**
  String get legendPartiallyCompleted;

  /// No description provided for @legendPartiallyCompletedDesc.
  ///
  /// In en, this message translates to:
  /// **'Some sessions are done'**
  String get legendPartiallyCompletedDesc;

  /// No description provided for @legendScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get legendScheduled;

  /// No description provided for @legendScheduledDesc.
  ///
  /// In en, this message translates to:
  /// **'Session day not yet completed'**
  String get legendScheduledDesc;

  /// No description provided for @legendRecoveryPeriod.
  ///
  /// In en, this message translates to:
  /// **'Recovery Period'**
  String get legendRecoveryPeriod;

  /// No description provided for @legendRecoveryPeriodDesc.
  ///
  /// In en, this message translates to:
  /// **'Deload/recovery day'**
  String get legendRecoveryPeriodDesc;

  /// No description provided for @legendIndicators.
  ///
  /// In en, this message translates to:
  /// **'Indicators'**
  String get legendIndicators;

  /// No description provided for @legendPeriodDay.
  ///
  /// In en, this message translates to:
  /// **'P#D#'**
  String get legendPeriodDay;

  /// No description provided for @legendPeriodDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Period and Day number (e.g., P2D3 = Period 2, Day 3)'**
  String get legendPeriodDayDesc;

  /// No description provided for @legendColoredDots.
  ///
  /// In en, this message translates to:
  /// **'Colored dots'**
  String get legendColoredDots;

  /// No description provided for @legendColoredDotsDesc.
  ///
  /// In en, this message translates to:
  /// **'Muscle groups being worked'**
  String get legendColoredDotsDesc;

  /// No description provided for @legendBorderHighlight.
  ///
  /// In en, this message translates to:
  /// **'Border highlight'**
  String get legendBorderHighlight;

  /// No description provided for @legendBorderHighlightDesc.
  ///
  /// In en, this message translates to:
  /// **'Today\'s date'**
  String get legendBorderHighlightDesc;

  /// No description provided for @legendSelectionBorder.
  ///
  /// In en, this message translates to:
  /// **'Selection border'**
  String get legendSelectionBorder;

  /// No description provided for @legendSelectionBorderDesc.
  ///
  /// In en, this message translates to:
  /// **'Currently selected date'**
  String get legendSelectionBorderDesc;

  /// No description provided for @legendPeriodColors.
  ///
  /// In en, this message translates to:
  /// **'Period Colors'**
  String get legendPeriodColors;

  /// No description provided for @legendPeriodColorsDesc.
  ///
  /// In en, this message translates to:
  /// **'Each period has a distinct background tint to help visualize training blocks.'**
  String get legendPeriodColorsDesc;

  /// No description provided for @moveSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Move Session'**
  String get moveSessionTitle;

  /// No description provided for @moveFromLabel.
  ///
  /// In en, this message translates to:
  /// **'From Period {period}, Day {day}'**
  String moveFromLabel(Object period, Object day);

  /// No description provided for @moveToLabel.
  ///
  /// In en, this message translates to:
  /// **'Move to:'**
  String get moveToLabel;

  /// No description provided for @periodDropdownLabel.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get periodDropdownLabel;

  /// No description provided for @dayDropdownLabel.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dayDropdownLabel;

  /// No description provided for @moveModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Move mode:'**
  String get moveModeLabel;

  /// No description provided for @shiftSubsequentTitle.
  ///
  /// In en, this message translates to:
  /// **'Shift Subsequent'**
  String get shiftSubsequentTitle;

  /// No description provided for @shiftSubsequentDesc.
  ///
  /// In en, this message translates to:
  /// **'Move this session and shift all following sessions'**
  String get shiftSubsequentDesc;

  /// No description provided for @swapTitle.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get swapTitle;

  /// No description provided for @swapDesc.
  ///
  /// In en, this message translates to:
  /// **'Exchange with the session on the target date'**
  String get swapDesc;

  /// No description provided for @singleTitle.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get singleTitle;

  /// No description provided for @singleDesc.
  ///
  /// In en, this message translates to:
  /// **'Move only this session (may create gaps)'**
  String get singleDesc;

  /// No description provided for @moveButton.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get moveButton;

  /// No description provided for @moveUndoneSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Move undone'**
  String get moveUndoneSnackbar;

  /// No description provided for @undoWithDescription.
  ///
  /// In en, this message translates to:
  /// **'Undo: {description}'**
  String undoWithDescription(Object description);

  /// No description provided for @undoLastChange.
  ///
  /// In en, this message translates to:
  /// **'Undo: last change'**
  String get undoLastChange;

  /// No description provided for @undoNoRecentChanges.
  ///
  /// In en, this message translates to:
  /// **'Undo Move (no recent changes)'**
  String get undoNoRecentChanges;

  /// No description provided for @editCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Calendar'**
  String get editCalendarTitle;

  /// No description provided for @editCalendarRestDay.
  ///
  /// In en, this message translates to:
  /// **'Rest Day'**
  String get editCalendarRestDay;

  /// No description provided for @editCalendarPeriodDay.
  ///
  /// In en, this message translates to:
  /// **'Period {period}, Day {day}'**
  String editCalendarPeriodDay(Object period, Object day);

  /// No description provided for @removeRestDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove Rest Day'**
  String get removeRestDayLabel;

  /// No description provided for @removeRestDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove this rest day and shift all future workouts backward'**
  String get removeRestDayDesc;

  /// No description provided for @insertDayBeforeLabel.
  ///
  /// In en, this message translates to:
  /// **'Insert Day Before'**
  String get insertDayBeforeLabel;

  /// No description provided for @insertDayBeforeDesc.
  ///
  /// In en, this message translates to:
  /// **'Add a rest day here, shifting this and all future workouts forward'**
  String get insertDayBeforeDesc;

  /// No description provided for @changeUndoneSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Change undone'**
  String get changeUndoneSnackbar;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @statusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get statusSkipped;

  /// No description provided for @statusPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get statusPlanned;

  /// No description provided for @setsProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total}'**
  String setsProgress(Object completed, Object total);

  /// No description provided for @moreCount.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String moreCount(Object count);

  /// No description provided for @dropHere.
  ///
  /// In en, this message translates to:
  /// **'Drop here'**
  String get dropHere;

  /// No description provided for @exerciseCardWeightSuggestion.
  ///
  /// In en, this message translates to:
  /// **'↑ Try {weight} {unit}'**
  String exerciseCardWeightSuggestion(Object weight, Object unit);

  /// No description provided for @exerciseCardInfoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Exercise info'**
  String get exerciseCardInfoTooltip;

  /// No description provided for @exerciseCardOptionsSemantics.
  ///
  /// In en, this message translates to:
  /// **'Exercise options for {exerciseName}'**
  String exerciseCardOptionsSemantics(Object exerciseName);

  /// No description provided for @exerciseCardColumnWeight.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT'**
  String get exerciseCardColumnWeight;

  /// No description provided for @exerciseCardColumnReps.
  ///
  /// In en, this message translates to:
  /// **'REPS'**
  String get exerciseCardColumnReps;

  /// No description provided for @exerciseCardColumnLog.
  ///
  /// In en, this message translates to:
  /// **'LOG'**
  String get exerciseCardColumnLog;

  /// No description provided for @exerciseCardMenuExercise.
  ///
  /// In en, this message translates to:
  /// **'EXERCISE'**
  String get exerciseCardMenuExercise;

  /// No description provided for @exerciseCardMenuNewNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get exerciseCardMenuNewNote;

  /// No description provided for @exerciseCardMenuMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get exerciseCardMenuMoveUp;

  /// No description provided for @exerciseCardMenuMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get exerciseCardMenuMoveDown;

  /// No description provided for @exerciseCardMenuReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get exerciseCardMenuReplace;

  /// No description provided for @exerciseCardMenuJointPain.
  ///
  /// In en, this message translates to:
  /// **'Joint pain'**
  String get exerciseCardMenuJointPain;

  /// No description provided for @exerciseCardMenuRestTimerValue.
  ///
  /// In en, this message translates to:
  /// **'Rest: {seconds}s'**
  String exerciseCardMenuRestTimerValue(Object seconds);

  /// No description provided for @exerciseCardMenuSetRestTimer.
  ///
  /// In en, this message translates to:
  /// **'Set rest timer'**
  String get exerciseCardMenuSetRestTimer;

  /// No description provided for @exerciseCardMenuAddSet.
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get exerciseCardMenuAddSet;

  /// No description provided for @exerciseCardMenuSkipSets.
  ///
  /// In en, this message translates to:
  /// **'Skip sets'**
  String get exerciseCardMenuSkipSets;

  /// No description provided for @exerciseCardMenuDeleteExercise.
  ///
  /// In en, this message translates to:
  /// **'Delete exercise'**
  String get exerciseCardMenuDeleteExercise;

  /// No description provided for @exerciseCardWeightSemantics.
  ///
  /// In en, this message translates to:
  /// **'Weight for set {setNumber}'**
  String exerciseCardWeightSemantics(Object setNumber);

  /// No description provided for @exerciseCardRepsSemantics.
  ///
  /// In en, this message translates to:
  /// **'Reps for set {setNumber}'**
  String exerciseCardRepsSemantics(Object setNumber);

  /// No description provided for @exerciseCardRepsHintRir.
  ///
  /// In en, this message translates to:
  /// **'{rir} RIR'**
  String exerciseCardRepsHintRir(Object rir);

  /// No description provided for @exerciseCardRepsHint.
  ///
  /// In en, this message translates to:
  /// **'RIR'**
  String get exerciseCardRepsHint;

  /// No description provided for @exerciseCardSetTypeSemantics.
  ///
  /// In en, this message translates to:
  /// **'{setTypeName} set'**
  String exerciseCardSetTypeSemantics(Object setTypeName);

  /// No description provided for @exerciseCardLogSetSemantics.
  ///
  /// In en, this message translates to:
  /// **'Log set {setNumber}'**
  String exerciseCardLogSetSemantics(Object setNumber);

  /// No description provided for @exerciseCardSetMenuHeader.
  ///
  /// In en, this message translates to:
  /// **'SET'**
  String get exerciseCardSetMenuHeader;

  /// No description provided for @exerciseCardSetMenuAddBelow.
  ///
  /// In en, this message translates to:
  /// **'Add set below'**
  String get exerciseCardSetMenuAddBelow;

  /// No description provided for @exerciseCardSetMenuSkipSet.
  ///
  /// In en, this message translates to:
  /// **'Skip set'**
  String get exerciseCardSetMenuSkipSet;

  /// No description provided for @exerciseCardSetMenuUnskipSet.
  ///
  /// In en, this message translates to:
  /// **'Unskip set'**
  String get exerciseCardSetMenuUnskipSet;

  /// No description provided for @exerciseCardSetMenuDeleteSet.
  ///
  /// In en, this message translates to:
  /// **'Delete set'**
  String get exerciseCardSetMenuDeleteSet;

  /// No description provided for @exerciseCardSetTypeHeader.
  ///
  /// In en, this message translates to:
  /// **'SET TYPE'**
  String get exerciseCardSetTypeHeader;

  /// No description provided for @weeklyVolumeChartEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cardio in this range yet'**
  String get weeklyVolumeChartEmpty;

  /// No description provided for @cycleComparisonNeedTwo.
  ///
  /// In en, this message translates to:
  /// **'Need at least 2 cycles to compare'**
  String get cycleComparisonNeedTwo;

  /// No description provided for @cycleComparisonUnlockMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete a training cycle to unlock comparisons.'**
  String get cycleComparisonUnlockMessage;

  /// No description provided for @cycleComparisonCycleA.
  ///
  /// In en, this message translates to:
  /// **'Cycle A'**
  String get cycleComparisonCycleA;

  /// No description provided for @cycleComparisonCycleB.
  ///
  /// In en, this message translates to:
  /// **'Cycle B'**
  String get cycleComparisonCycleB;

  /// No description provided for @cycleComparisonSelectPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select two cycles to compare'**
  String get cycleComparisonSelectPrompt;

  /// No description provided for @cycleComparisonCompletion.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get cycleComparisonCompletion;

  /// No description provided for @cycleComparisonTotalSets.
  ///
  /// In en, this message translates to:
  /// **'Total Sets'**
  String get cycleComparisonTotalSets;

  /// No description provided for @cycleComparisonWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get cycleComparisonWorkouts;

  /// No description provided for @cycleComparisonSetsByMuscle.
  ///
  /// In en, this message translates to:
  /// **'Sets by Muscle Group'**
  String get cycleComparisonSetsByMuscle;

  /// No description provided for @cycleComparisonPrChanges.
  ///
  /// In en, this message translates to:
  /// **'Personal Record Changes'**
  String get cycleComparisonPrChanges;

  /// No description provided for @cycleComparisonPrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{weightA} → {weightB} lbs'**
  String cycleComparisonPrSubtitle(Object weightA, Object weightB);

  /// No description provided for @volumeBarChartNoData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get volumeBarChartNoData;

  /// No description provided for @volumeLineChartNoData.
  ///
  /// In en, this message translates to:
  /// **'No volume data yet'**
  String get volumeLineChartNoData;

  /// No description provided for @weightChartNoMeasurements.
  ///
  /// In en, this message translates to:
  /// **'No measurements yet'**
  String get weightChartNoMeasurements;

  /// No description provided for @weightChartNeedTwo.
  ///
  /// In en, this message translates to:
  /// **'Need at least 2 measurements to show a chart'**
  String get weightChartNeedTwo;

  /// No description provided for @emailLinkVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get emailLinkVerificationSent;

  /// No description provided for @emailLinkSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get emailLinkSignInTitle;

  /// No description provided for @emailLinkVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify to Upload'**
  String get emailLinkVerifyTitle;

  /// No description provided for @emailLinkSignInDesc.
  ///
  /// In en, this message translates to:
  /// **'Sign in with the email and password you used on your other device.'**
  String get emailLinkSignInDesc;

  /// No description provided for @emailLinkVerifyDesc.
  ///
  /// In en, this message translates to:
  /// **'Link an email to your account to share content with the community. Your anonymous data is preserved.'**
  String get emailLinkVerifyDesc;

  /// No description provided for @emailLinkEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLinkEmailLabel;

  /// No description provided for @emailLinkPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get emailLinkPasswordLabel;

  /// No description provided for @emailLinkEmailEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailLinkEmailEmpty;

  /// No description provided for @emailLinkEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailLinkEmailInvalid;

  /// No description provided for @emailLinkPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get emailLinkPasswordShort;

  /// No description provided for @emailLinkSignInButton.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get emailLinkSignInButton;

  /// No description provided for @emailLinkLinkAndVerify.
  ///
  /// In en, this message translates to:
  /// **'LINK EMAIL & VERIFY'**
  String get emailLinkLinkAndVerify;

  /// No description provided for @emailLinkCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'CREATE NEW ACCOUNT'**
  String get emailLinkCreateAccount;

  /// No description provided for @emailLinkSignInExisting.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN WITH EXISTING ACCOUNT'**
  String get emailLinkSignInExisting;

  /// No description provided for @emailLinkCheckInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Check Your Inbox'**
  String get emailLinkCheckInboxTitle;

  /// No description provided for @emailLinkCheckInboxDesc.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification email. Open the link in the email, then come back here and tap the button below.'**
  String get emailLinkCheckInboxDesc;

  /// No description provided for @emailLinkNotYetVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not yet verified. Check your inbox and spam folder.'**
  String get emailLinkNotYetVerified;

  /// No description provided for @emailLinkVerifiedButton.
  ///
  /// In en, this message translates to:
  /// **'I\'VE VERIFIED MY EMAIL'**
  String get emailLinkVerifiedButton;

  /// No description provided for @emailLinkResendButton.
  ///
  /// In en, this message translates to:
  /// **'RESEND VERIFICATION EMAIL'**
  String get emailLinkResendButton;

  /// No description provided for @userErrorCouldnt.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'\'t {context} — {message}'**
  String userErrorCouldnt(Object context, Object message);

  /// No description provided for @userErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get userErrorNetwork;

  /// No description provided for @userErrorBadState.
  ///
  /// In en, this message translates to:
  /// **'Something got into a bad state. Try again.'**
  String get userErrorBadState;

  /// No description provided for @userErrorPermission.
  ///
  /// In en, this message translates to:
  /// **'Permission was denied. Open Settings to grant access.'**
  String get userErrorPermission;

  /// No description provided for @userErrorConflict.
  ///
  /// In en, this message translates to:
  /// **'That change conflicts with existing data.'**
  String get userErrorConflict;

  /// No description provided for @userErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found — it may have been deleted.'**
  String get userErrorNotFound;

  /// No description provided for @userErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again in a moment.'**
  String get userErrorGeneric;

  /// No description provided for @setTypeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Set types'**
  String get setTypeDialogTitle;

  /// No description provided for @setTypeDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep track of how you performed your sets by specifying a type:'**
  String get setTypeDialogDescription;

  /// No description provided for @regularSetDefinition.
  ///
  /// In en, this message translates to:
  /// **'Regular: perform sets normally by hitting rep target or week over week RIR target'**
  String get regularSetDefinition;

  /// No description provided for @myorepSetDefinition.
  ///
  /// In en, this message translates to:
  /// **'Myoreps: take 5-15 second pauses between mini-sets of reps to hit rep target or week over week RIR target. Log total reps.'**
  String get myorepSetDefinition;

  /// No description provided for @myorepMatchSetDefinition.
  ///
  /// In en, this message translates to:
  /// **'Myorep match: take 5-15 second pauses between mini-sets of reps to match reps from your first set. Log total reps.'**
  String get myorepMatchSetDefinition;

  /// No description provided for @jointPainTitle.
  ///
  /// In en, this message translates to:
  /// **'JOINT PAIN'**
  String get jointPainTitle;

  /// No description provided for @musclePumpTitle.
  ///
  /// In en, this message translates to:
  /// **'MUSCLE PUMP'**
  String get musclePumpTitle;

  /// No description provided for @workloadTitle.
  ///
  /// In en, this message translates to:
  /// **'WORKLOAD'**
  String get workloadTitle;

  /// No description provided for @sorenessTitle.
  ///
  /// In en, this message translates to:
  /// **'SORENESS'**
  String get sorenessTitle;

  /// No description provided for @jointPainQuestion.
  ///
  /// In en, this message translates to:
  /// **'How did your joints feel during {exerciseName}?'**
  String jointPainQuestion(Object exerciseName);

  /// No description provided for @musclePumpQuestion.
  ///
  /// In en, this message translates to:
  /// **'How much of a pump did you get today in your {muscleGroup}?'**
  String musclePumpQuestion(Object muscleGroup);

  /// No description provided for @workloadQuestion.
  ///
  /// In en, this message translates to:
  /// **'How would you rate the difficulty of the work you did for your {muscleGroup}?'**
  String workloadQuestion(Object muscleGroup);

  /// No description provided for @sorenessQuestion.
  ///
  /// In en, this message translates to:
  /// **'How sore did you get in your {muscleGroup} AFTER training it LAST TIME?'**
  String sorenessQuestion(Object muscleGroup);

  /// No description provided for @draftBannerText.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE EDITING DRAFT TRAINING CYCLE'**
  String get draftBannerText;

  /// No description provided for @noExercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'No exercises'**
  String get noExercisesTitle;

  /// No description provided for @noExercisesMessage.
  ///
  /// In en, this message translates to:
  /// **'Your custom exercises will appear here.'**
  String get noExercisesMessage;

  /// No description provided for @noPinnedNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'No pinned notes'**
  String get noPinnedNotesTitle;

  /// No description provided for @noPinnedNotesMessage.
  ///
  /// In en, this message translates to:
  /// **'Your pinned exercise notes will appear here.'**
  String get noPinnedNotesMessage;

  /// No description provided for @navWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get navWorkout;

  /// No description provided for @navTrainingCycles.
  ///
  /// In en, this message translates to:
  /// **'TrainingCycles'**
  String get navTrainingCycles;

  /// No description provided for @navExercisesConst.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get navExercisesConst;

  /// No description provided for @navMoreConst.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMoreConst;

  /// No description provided for @menuTemplates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get menuTemplates;

  /// No description provided for @menuDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get menuDarkTheme;

  /// No description provided for @menuExportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get menuExportData;

  /// No description provided for @menuImportData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get menuImportData;

  /// No description provided for @menuShareData.
  ///
  /// In en, this message translates to:
  /// **'Share Data'**
  String get menuShareData;

  /// No description provided for @menuHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get menuHelp;

  /// No description provided for @menuLeaveReview.
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get menuLeaveReview;

  /// No description provided for @localeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get localeSystem;

  /// No description provided for @localeEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get localeEnglish;

  /// No description provided for @localeSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get localeSpanish;

  /// No description provided for @sportPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a session'**
  String get sportPickerTitle;

  /// No description provided for @sportPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Which sport is this session?'**
  String get sportPickerSubtitle;

  /// No description provided for @cardioTemplatePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Start from a template'**
  String get cardioTemplatePickerTitle;

  /// No description provided for @cardioTemplatePickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a pre-built session to start from. You can edit the intervals before saving.'**
  String get cardioTemplatePickerSubtitle;

  /// No description provided for @cardioTemplatePickerLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the library. {error}'**
  String cardioTemplatePickerLoadError(Object error);

  /// No description provided for @cardioTemplatePickerNoTemplates.
  ///
  /// In en, this message translates to:
  /// **'No templates for this sport yet.'**
  String get cardioTemplatePickerNoTemplates;

  /// No description provided for @cardioDifficultyBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get cardioDifficultyBeginner;

  /// No description provided for @cardioDifficultyIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get cardioDifficultyIntermediate;

  /// No description provided for @cardioDifficultyAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get cardioDifficultyAdvanced;

  /// No description provided for @cardioTemplatePickerStepsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} steps'**
  String cardioTemplatePickerStepsCount(Object count);

  /// App bar title on the router error page
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get routerErrorTitle;

  /// Body text shown when a route is not found
  ///
  /// In en, this message translates to:
  /// **'Page not found: {location}'**
  String routerPageNotFound(Object location);

  /// Button text to navigate back to the home screen
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get routerGoHome;

  /// No description provided for @cycleSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'{cycleTerm} summary'**
  String cycleSummaryTitle(Object cycleTerm);

  /// No description provided for @cycleSummaryWorkoutsSection.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get cycleSummaryWorkoutsSection;

  /// No description provided for @cycleSummaryCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get cycleSummaryCompleted;

  /// No description provided for @cycleSummarySkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get cycleSummarySkipped;

  /// No description provided for @cycleSummaryIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get cycleSummaryIncomplete;

  /// No description provided for @cycleSummaryStatsSection.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get cycleSummaryStatsSection;

  /// No description provided for @cycleSummaryMuscleGroups.
  ///
  /// In en, this message translates to:
  /// **'Muscle groups'**
  String get cycleSummaryMuscleGroups;

  /// No description provided for @closeUpper.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get closeUpper;

  /// No description provided for @muscleGroupStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Muscle group stats'**
  String get muscleGroupStatsTitle;

  /// No description provided for @muscleGroupStatsNoSessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions found for this training cycle.'**
  String get muscleGroupStatsNoSessions;

  /// No description provided for @muscleGroupStatsDeload.
  ///
  /// In en, this message translates to:
  /// **'DL'**
  String get muscleGroupStatsDeload;

  /// No description provided for @muscleGroupStatsPeriod.
  ///
  /// In en, this message translates to:
  /// **'pd {period}'**
  String muscleGroupStatsPeriod(Object period);

  /// No description provided for @muscleGroupStatsAvgSets.
  ///
  /// In en, this message translates to:
  /// **'{count} avg sets'**
  String muscleGroupStatsAvgSets(Object count);

  /// No description provided for @skinSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get skinSelectionTitle;

  /// No description provided for @skinSelectionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get skinSelectionShare;

  /// No description provided for @skinSelectionCurrentTheme.
  ///
  /// In en, this message translates to:
  /// **'Current Theme'**
  String get skinSelectionCurrentTheme;

  /// No description provided for @skinSelectionChooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose a Theme'**
  String get skinSelectionChooseTheme;

  /// No description provided for @skinSelectionCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get skinSelectionCreate;

  /// No description provided for @skinSelectionBrowseCommunity.
  ///
  /// In en, this message translates to:
  /// **'Browse Community Library'**
  String get skinSelectionBrowseCommunity;

  /// No description provided for @skinSelectionBrowseCommunitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover themes shared by other users'**
  String get skinSelectionBrowseCommunitySubtitle;

  /// No description provided for @skinSelectionPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get skinSelectionPremium;

  /// No description provided for @skinSelectionEditTheme.
  ///
  /// In en, this message translates to:
  /// **'Edit Theme'**
  String get skinSelectionEditTheme;

  /// No description provided for @skinSelectionShareTheme.
  ///
  /// In en, this message translates to:
  /// **'Share Theme'**
  String get skinSelectionShareTheme;

  /// No description provided for @skinSelectionDeleteTheme.
  ///
  /// In en, this message translates to:
  /// **'Delete Theme'**
  String get skinSelectionDeleteTheme;

  /// No description provided for @skinSelectionDeleteThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Theme?'**
  String get skinSelectionDeleteThemeTitle;

  /// No description provided for @skinSelectionDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String skinSelectionDeleteConfirm(Object name);

  /// No description provided for @unitsResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get unitsResetButton;

  /// No description provided for @unitsDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick units per sport. A row you haven\'t touched follows the sensible default (run → miles, bike → km, swim → meters), falling back to your main metric / imperial setting.'**
  String get unitsDescription;

  /// No description provided for @unitsDefaultLabel.
  ///
  /// In en, this message translates to:
  /// **'(default)'**
  String get unitsDefaultLabel;

  /// No description provided for @unitsImperialLabel.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get unitsImperialLabel;

  /// No description provided for @unitsMetricLabel.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get unitsMetricLabel;

  /// No description provided for @unitsStrengthNote.
  ///
  /// In en, this message translates to:
  /// **'Strength defaults to your main metric/imperial choice ({system}) — change that in Settings → Profile.'**
  String unitsStrengthNote(Object system);

  /// No description provided for @zonesNoZones.
  ///
  /// In en, this message translates to:
  /// **'No zones set for {sport}'**
  String zonesNoZones(Object sport);

  /// No description provided for @zonesNoZonesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start from the conventional five-zone split and tweak the numbers to your tested thresholds.'**
  String get zonesNoZonesSubtitle;

  /// No description provided for @zonesSeedDefaults.
  ///
  /// In en, this message translates to:
  /// **'Seed default zones'**
  String get zonesSeedDefaults;

  /// No description provided for @zonesClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get zonesClear;

  /// No description provided for @zonesHrDescription.
  ///
  /// In en, this message translates to:
  /// **'Heart-rate zones in bpm. Tap a value to edit. Defaults are a sensible starting point — adjust to your tested thresholds.'**
  String get zonesHrDescription;

  /// No description provided for @zonesZoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Zone {number}'**
  String zonesZoneLabel(Object number);

  /// No description provided for @zonesMinLabel.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get zonesMinLabel;

  /// No description provided for @zonesMaxLabel.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get zonesMaxLabel;

  /// No description provided for @zonesBpmSuffix.
  ///
  /// In en, this message translates to:
  /// **'bpm'**
  String get zonesBpmSuffix;

  /// No description provided for @zonesResetToDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults'**
  String get zonesResetToDefaults;

  /// No description provided for @zonesErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading zones: {error}'**
  String zonesErrorLoading(Object error);

  /// No description provided for @sentryDebugOnlyAvailable.
  ///
  /// In en, this message translates to:
  /// **'Debug screen only available in debug builds'**
  String get sentryDebugOnlyAvailable;

  /// No description provided for @sentryRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get sentryRefreshTooltip;

  /// No description provided for @sentryTestMessage.
  ///
  /// In en, this message translates to:
  /// **'Test Message'**
  String get sentryTestMessage;

  /// No description provided for @sentryTestException.
  ///
  /// In en, this message translates to:
  /// **'Test Exception'**
  String get sentryTestException;

  /// No description provided for @sentryTestFeedback.
  ///
  /// In en, this message translates to:
  /// **'Test Feedback'**
  String get sentryTestFeedback;

  /// No description provided for @sentryTestCrash.
  ///
  /// In en, this message translates to:
  /// **'Test Crash'**
  String get sentryTestCrash;

  /// No description provided for @restTimerBannerSemantic.
  ///
  /// In en, this message translates to:
  /// **'Rest timer: {time} remaining'**
  String restTimerBannerSemantic(Object time);

  /// No description provided for @restTimerRestDisplay.
  ///
  /// In en, this message translates to:
  /// **'Rest: {time}'**
  String restTimerRestDisplay(Object time);

  /// No description provided for @restTimerResumeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get restTimerResumeTooltip;

  /// No description provided for @restTimerPauseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get restTimerPauseTooltip;

  /// No description provided for @restTimerAddTimeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add 30 seconds'**
  String get restTimerAddTimeTooltip;

  /// No description provided for @restTimerSkipTooltip.
  ///
  /// In en, this message translates to:
  /// **'Skip rest'**
  String get restTimerSkipTooltip;

  /// No description provided for @filterByAvailableEquipment.
  ///
  /// In en, this message translates to:
  /// **'Filter by Available Equipment'**
  String get filterByAvailableEquipment;

  /// No description provided for @onlyShowEquipmentExercises.
  ///
  /// In en, this message translates to:
  /// **'Only show exercises for equipment you have'**
  String get onlyShowEquipmentExercises;

  /// No description provided for @selectEquipmentAccess.
  ///
  /// In en, this message translates to:
  /// **'Select equipment you have access to'**
  String get selectEquipmentAccess;

  /// No description provided for @sportSummarySessionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{session} other{sessions}}'**
  String sportSummarySessionCount(int count);

  /// No description provided for @sportSummaryBest.
  ///
  /// In en, this message translates to:
  /// **'Best {distance}'**
  String sportSummaryBest(Object distance);

  /// No description provided for @weeklyVolumeChartTooltipSessions.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions'**
  String weeklyVolumeChartTooltipSessions(Object count);

  /// No description provided for @weeklyVolumeChartWeekOf.
  ///
  /// In en, this message translates to:
  /// **'Wk of {date}'**
  String weeklyVolumeChartWeekOf(Object date);

  /// No description provided for @volumeBarChartSetsTooltip.
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String volumeBarChartSetsTooltip(Object count);

  /// No description provided for @exerciseCardLastPerformance.
  ///
  /// In en, this message translates to:
  /// **'Last: {summary}{date}'**
  String exerciseCardLastPerformance(Object summary, Object date);

  /// No description provided for @cardioCardTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'TARGET'**
  String get cardioCardTargetLabel;

  /// No description provided for @cardioCardNoTarget.
  ///
  /// In en, this message translates to:
  /// **'No target set'**
  String get cardioCardNoTarget;

  /// No description provided for @cardioCardIntervalCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 interval} other{{count} intervals}}'**
  String cardioCardIntervalCount(int count);

  /// No description provided for @cardioCardPaceLabel.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get cardioCardPaceLabel;

  /// No description provided for @cardioCardAvgSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg speed'**
  String get cardioCardAvgSpeedLabel;

  /// No description provided for @cardioCardSwolfLabel.
  ///
  /// In en, this message translates to:
  /// **'SWOLF'**
  String get cardioCardSwolfLabel;

  /// No description provided for @cardioCardLapsValue.
  ///
  /// In en, this message translates to:
  /// **'{count} laps'**
  String cardioCardLapsValue(Object count);

  /// No description provided for @cardioCardPoolLabel.
  ///
  /// In en, this message translates to:
  /// **'pool'**
  String get cardioCardPoolLabel;

  /// No description provided for @cardioCardAvgHr.
  ///
  /// In en, this message translates to:
  /// **'avg'**
  String get cardioCardAvgHr;

  /// No description provided for @cardioCardMaxHr.
  ///
  /// In en, this message translates to:
  /// **'max'**
  String get cardioCardMaxHr;

  /// No description provided for @cardioCardAvgPower.
  ///
  /// In en, this message translates to:
  /// **'avg'**
  String get cardioCardAvgPower;

  /// No description provided for @cardioCardElevationGain.
  ///
  /// In en, this message translates to:
  /// **'▲'**
  String get cardioCardElevationGain;

  /// No description provided for @cardioCardAddFeedback.
  ///
  /// In en, this message translates to:
  /// **'Add feedback'**
  String get cardioCardAddFeedback;

  /// No description provided for @cardioCardLogSession.
  ///
  /// In en, this message translates to:
  /// **'Log session'**
  String get cardioCardLogSession;

  /// No description provided for @cardioCardMenuNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get cardioCardMenuNotes;

  /// No description provided for @cardioCardMenuMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get cardioCardMenuMoveUp;

  /// No description provided for @cardioCardMenuMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get cardioCardMenuMoveDown;

  /// No description provided for @cardioCardMenuReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get cardioCardMenuReplace;

  /// No description provided for @cardioCardMenuSkipSession.
  ///
  /// In en, this message translates to:
  /// **'Skip session'**
  String get cardioCardMenuSkipSession;

  /// No description provided for @cardioCardMenuDeleteSession.
  ///
  /// In en, this message translates to:
  /// **'Delete session'**
  String get cardioCardMenuDeleteSession;

  /// No description provided for @quickLogTooltip.
  ///
  /// In en, this message translates to:
  /// **'Log session'**
  String get quickLogTooltip;

  /// No description provided for @quickLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log session'**
  String get quickLogTitle;

  /// No description provided for @thisWeekEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet — your next session lands here.'**
  String get thisWeekEmpty;

  /// No description provided for @thisWeekStrengthSessions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 strength session} other{{count} strength sessions}}'**
  String thisWeekStrengthSessions(int count);

  /// No description provided for @thisWeekSportLine.
  ///
  /// In en, this message translates to:
  /// **'{count} {sport}{countSuffix}'**
  String thisWeekSportLine(Object count, Object sport, Object countSuffix);

  /// No description provided for @sportSummarySessionLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{session} other{sessions}}'**
  String sportSummarySessionLabel(int count);

  /// No description provided for @sportSummaryBestLabel.
  ///
  /// In en, this message translates to:
  /// **'Best {distance}'**
  String sportSummaryBestLabel(Object distance);

  /// No description provided for @weeklyVolumeChartTooltip.
  ///
  /// In en, this message translates to:
  /// **'{weekLabel}\n{sessions} sessions • {duration}'**
  String weeklyVolumeChartTooltip(Object weekLabel, Object sessions, Object duration);

  /// No description provided for @volumeBarChartEmpty.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get volumeBarChartEmpty;

  /// No description provided for @exerciseCardExerciseInfo.
  ///
  /// In en, this message translates to:
  /// **'Exercise info'**
  String get exerciseCardExerciseInfo;

  /// No description provided for @exerciseCardOptionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercise options for {name}'**
  String exerciseCardOptionsLabel(Object name);

  /// No description provided for @exerciseCardWeightHeader.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT'**
  String get exerciseCardWeightHeader;

  /// No description provided for @exerciseCardRepsHeader.
  ///
  /// In en, this message translates to:
  /// **'REPS'**
  String get exerciseCardRepsHeader;

  /// No description provided for @exerciseCardLogHeader.
  ///
  /// In en, this message translates to:
  /// **'LOG'**
  String get exerciseCardLogHeader;

  /// No description provided for @exerciseCardWeightSemantic.
  ///
  /// In en, this message translates to:
  /// **'Weight for set {number}'**
  String exerciseCardWeightSemantic(Object number);

  /// No description provided for @exerciseCardRepsSemantic.
  ///
  /// In en, this message translates to:
  /// **'Reps for set {number}'**
  String exerciseCardRepsSemantic(Object number);

  /// No description provided for @exerciseCardLogSemantic.
  ///
  /// In en, this message translates to:
  /// **'Log set {number}'**
  String exerciseCardLogSemantic(Object number);

  /// No description provided for @exerciseCardSetTypeSemantic.
  ///
  /// In en, this message translates to:
  /// **'{typeName} set'**
  String exerciseCardSetTypeSemantic(Object typeName);

  /// No description provided for @exerciseCardExerciseHeader.
  ///
  /// In en, this message translates to:
  /// **'EXERCISE'**
  String get exerciseCardExerciseHeader;

  /// No description provided for @exerciseCardNewNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get exerciseCardNewNote;

  /// No description provided for @exerciseCardMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get exerciseCardMoveUp;

  /// No description provided for @exerciseCardMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get exerciseCardMoveDown;

  /// No description provided for @exerciseCardReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get exerciseCardReplace;

  /// No description provided for @exerciseCardJointPain.
  ///
  /// In en, this message translates to:
  /// **'Joint pain'**
  String get exerciseCardJointPain;

  /// No description provided for @exerciseCardRestTimerValue.
  ///
  /// In en, this message translates to:
  /// **'Rest: {seconds}s'**
  String exerciseCardRestTimerValue(Object seconds);

  /// No description provided for @exerciseCardSetRestTimer.
  ///
  /// In en, this message translates to:
  /// **'Set rest timer'**
  String get exerciseCardSetRestTimer;

  /// No description provided for @exerciseCardAddSet.
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get exerciseCardAddSet;

  /// No description provided for @exerciseCardSkipSets.
  ///
  /// In en, this message translates to:
  /// **'Skip sets'**
  String get exerciseCardSkipSets;

  /// No description provided for @exerciseCardDeleteExercise.
  ///
  /// In en, this message translates to:
  /// **'Delete exercise'**
  String get exerciseCardDeleteExercise;

  /// No description provided for @exerciseCardSetHeader.
  ///
  /// In en, this message translates to:
  /// **'SET'**
  String get exerciseCardSetHeader;

  /// No description provided for @exerciseCardAddSetBelow.
  ///
  /// In en, this message translates to:
  /// **'Add set below'**
  String get exerciseCardAddSetBelow;

  /// No description provided for @exerciseCardSkipSet.
  ///
  /// In en, this message translates to:
  /// **'Skip set'**
  String get exerciseCardSkipSet;

  /// No description provided for @exerciseCardUnskipSet.
  ///
  /// In en, this message translates to:
  /// **'Unskip set'**
  String get exerciseCardUnskipSet;

  /// No description provided for @exerciseCardDeleteSet.
  ///
  /// In en, this message translates to:
  /// **'Delete set'**
  String get exerciseCardDeleteSet;

  /// No description provided for @exerciseCardPrBadge.
  ///
  /// In en, this message translates to:
  /// **'PR'**
  String get exerciseCardPrBadge;

  /// No description provided for @exerciseCardPrBadgeSemantic.
  ///
  /// In en, this message translates to:
  /// **'Personal record'**
  String get exerciseCardPrBadgeSemantic;

  /// No description provided for @exerciseCardLogHintMissingFields.
  ///
  /// In en, this message translates to:
  /// **'Enter weight and reps to log this set'**
  String get exerciseCardLogHintMissingFields;

  /// No description provided for @workoutActionError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save changes: {error}'**
  String workoutActionError(Object error);

  /// No description provided for @exerciseCardTryWeight.
  ///
  /// In en, this message translates to:
  /// **'↑ Try {weight} {unit}'**
  String exerciseCardTryWeight(Object weight, Object unit);

  /// No description provided for @exerciseCardRirHint.
  ///
  /// In en, this message translates to:
  /// **'RIR'**
  String get exerciseCardRirHint;

  /// No description provided for @exerciseCardRirTargetHint.
  ///
  /// In en, this message translates to:
  /// **'{target} RIR'**
  String exerciseCardRirTargetHint(Object target);

  /// No description provided for @equipmentFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter by Available Equipment'**
  String get equipmentFilterTitle;

  /// No description provided for @equipmentFilterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only show exercises for equipment you have'**
  String get equipmentFilterSubtitle;

  /// No description provided for @equipmentFilterSelectPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select equipment you have access to'**
  String get equipmentFilterSelectPrompt;

  /// No description provided for @restTimerSemantic.
  ///
  /// In en, this message translates to:
  /// **'Rest timer: {time} remaining'**
  String restTimerSemantic(Object time);

  /// No description provided for @restTimerDisplay.
  ///
  /// In en, this message translates to:
  /// **'Rest: {time}'**
  String restTimerDisplay(Object time);

  /// No description provided for @restTimerResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get restTimerResume;

  /// No description provided for @restTimerPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get restTimerPause;

  /// No description provided for @restTimerAdd30.
  ///
  /// In en, this message translates to:
  /// **'Add 30 seconds'**
  String get restTimerAdd30;

  /// No description provided for @restTimerSubtract30.
  ///
  /// In en, this message translates to:
  /// **'Subtract 30 seconds'**
  String get restTimerSubtract30;

  /// No description provided for @restTimerSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip rest'**
  String get restTimerSkip;

  /// No description provided for @restTimerNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest over'**
  String get restTimerNotificationTitle;

  /// No description provided for @restTimerNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Time for your next set'**
  String get restTimerNotificationBody;

  /// Live lock-screen notification body while resting, without a weight/reps target
  ///
  /// In en, this message translates to:
  /// **'Next: set {setNumber} of {totalSets}'**
  String restLiveNextSet(Object setNumber, Object totalSets);

  /// Live lock-screen notification body while resting. target is a pre-formatted string like '80 kg × 8-12'
  ///
  /// In en, this message translates to:
  /// **'Next: set {setNumber} of {totalSets} · {target}'**
  String restLiveNextSetTarget(Object setNumber, Object totalSets, Object target);

  /// No description provided for @restLiveAllSetsDone.
  ///
  /// In en, this message translates to:
  /// **'All sets done — great work!'**
  String get restLiveAllSetsDone;

  /// No description provided for @restLiveActionAdd.
  ///
  /// In en, this message translates to:
  /// **'+30s'**
  String get restLiveActionAdd;

  /// No description provided for @restLiveActionSubtract.
  ///
  /// In en, this message translates to:
  /// **'−30s'**
  String get restLiveActionSubtract;

  /// No description provided for @restLiveActionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get restLiveActionSkip;

  /// No description provided for @cycleComparisonNeedTwoCycles.
  ///
  /// In en, this message translates to:
  /// **'Need at least 2 cycles to compare'**
  String get cycleComparisonNeedTwoCycles;

  /// No description provided for @cycleComparisonUnlockHint.
  ///
  /// In en, this message translates to:
  /// **'Complete a training cycle to unlock comparisons.'**
  String get cycleComparisonUnlockHint;

  /// No description provided for @cycleComparisonPRChanges.
  ///
  /// In en, this message translates to:
  /// **'Personal Record Changes'**
  String get cycleComparisonPRChanges;

  /// No description provided for @cycleComparisonWeightChange.
  ///
  /// In en, this message translates to:
  /// **'{weightA} → {weightB} lbs'**
  String cycleComparisonWeightChange(Object weightA, Object weightB);

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authVerifyToUpload.
  ///
  /// In en, this message translates to:
  /// **'Verify to Upload'**
  String get authVerifyToUpload;

  /// No description provided for @authSignInBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in with the email and password you used on your other device.'**
  String get authSignInBody;

  /// No description provided for @authLinkEmailBody.
  ///
  /// In en, this message translates to:
  /// **'Link an email to your account to share content with the community. Your anonymous data is preserved.'**
  String get authLinkEmailBody;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authEnterEmail;

  /// No description provided for @authEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get authEnterValidEmail;

  /// No description provided for @authPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get authPasswordMinLength;

  /// No description provided for @authSignInUpper.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get authSignInUpper;

  /// No description provided for @authLinkEmailUpper.
  ///
  /// In en, this message translates to:
  /// **'LINK EMAIL & VERIFY'**
  String get authLinkEmailUpper;

  /// No description provided for @authCreateNewAccount.
  ///
  /// In en, this message translates to:
  /// **'CREATE NEW ACCOUNT'**
  String get authCreateNewAccount;

  /// No description provided for @authSignInExisting.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN WITH EXISTING ACCOUNT'**
  String get authSignInExisting;

  /// No description provided for @authCheckInbox.
  ///
  /// In en, this message translates to:
  /// **'Check Your Inbox'**
  String get authCheckInbox;

  /// No description provided for @authCheckInboxBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification email. Open the link in the email, then come back here and tap the button below.'**
  String get authCheckInboxBody;

  /// No description provided for @authEmailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not yet verified. Check your inbox and spam folder.'**
  String get authEmailNotVerified;

  /// No description provided for @authVerifiedButton.
  ///
  /// In en, this message translates to:
  /// **'I\'VE VERIFIED MY EMAIL'**
  String get authVerifiedButton;

  /// No description provided for @authResendEmail.
  ///
  /// In en, this message translates to:
  /// **'RESEND VERIFICATION EMAIL'**
  String get authResendEmail;

  /// No description provided for @authVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get authVerificationSent;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
