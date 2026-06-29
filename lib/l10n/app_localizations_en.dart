// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'YAWA4U';

  @override
  String get cancel => 'Cancel';

  @override
  String get cancelUpper => 'CANCEL';

  @override
  String get save => 'Save';

  @override
  String get saveUpper => 'SAVE';

  @override
  String get delete => 'Delete';

  @override
  String get deleteUpper => 'DELETE';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get undo => 'Undo';

  @override
  String get continueButton => 'Continue';

  @override
  String errorGeneric(Object error) {
    return 'Error: $error';
  }

  @override
  String get noteSaved => 'Note saved';

  @override
  String noteSaveError(Object error) {
    return 'Error saving note: $error';
  }

  @override
  String get toggleThemeTooltip => 'Toggle theme';

  @override
  String get navSession => 'Session';

  @override
  String get navExercises => 'Exercises';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navMore => 'More';

  @override
  String get trainingCycleStatusDraft => 'Draft';

  @override
  String get trainingCycleStatusCurrent => 'Current';

  @override
  String get trainingCycleStatusCompleted => 'Completed';

  @override
  String get workoutStatusIncomplete => 'Incomplete';

  @override
  String get workoutStatusCompleted => 'Completed';

  @override
  String get workoutStatusSkipped => 'Skipped';

  @override
  String get setTypeRegular => 'Regular';

  @override
  String get setTypeMyorep => 'Myorep';

  @override
  String get setTypeMyorepMatch => 'Myorep match';

  @override
  String get setTypeMaxReps => 'Max reps';

  @override
  String get setTypeEndWithPartials => 'End with partials';

  @override
  String get setTypeDropSet => 'Drop set';

  @override
  String get setTypeRegularDesc => 'perform sets normally by hitting rep target or week over week RIR target';

  @override
  String get setTypeMyorepDesc =>
      'take 5-15 second pauses between mini-sets of reps to hit rep target or week over week RIR target. Log total reps.';

  @override
  String get setTypeMyorepMatchDesc =>
      'take 5-15 second pauses between mini-sets of reps to match reps from your first set. Log total reps.';

  @override
  String get setTypeMaxRepsDesc => 'perform as many reps as possible until failure';

  @override
  String get setTypeEndWithPartialsDesc =>
      'after reaching failure, continue with partial reps to further fatigue the muscle';

  @override
  String get setTypeDropSetDesc => 'immediately reduce weight and continue reps without rest to extend the set';

  @override
  String get jointPainNone => 'NONE';

  @override
  String get jointPainLow => 'LOW PAIN';

  @override
  String get jointPainModerate => 'MODERATE PAIN';

  @override
  String get jointPainSevere => 'A LOT OF PAIN';

  @override
  String get musclePumpLow => 'LOW PUMP';

  @override
  String get musclePumpModerate => 'MODERATE PUMP';

  @override
  String get musclePumpAmazing => 'AMAZING PUMP';

  @override
  String get workloadEasy => 'EASY';

  @override
  String get workloadPrettyGood => 'PRETTY GOOD';

  @override
  String get workloadPushedLimits => 'PUSHED MY LIMITS';

  @override
  String get workloadTooMuch => 'TOO MUCH';

  @override
  String get sorenessNeverGotSore => 'NEVER GOT SORE';

  @override
  String get sorenessHealedAWhileAgo => 'HEALED A WHILE AGO';

  @override
  String get sorenessHealedJustOnTime => 'HEALED JUST ON TIME';

  @override
  String get sorenessStillSore => 'I\'M STILL SORE!';

  @override
  String get genderMale => 'MALE';

  @override
  String get genderFemale => 'FEMALE';

  @override
  String get recoveryPeriodTypeDeload => 'Deload';

  @override
  String get recoveryPeriodTypeTaper => 'Taper';

  @override
  String get recoveryPeriodTypeRecovery => 'Recovery';

  @override
  String get recoveryPeriodTypeDeloadDesc => 'Reduce weight while maintaining volume';

  @override
  String get recoveryPeriodTypeTaperDesc => 'Reduce volume while maintaining intensity';

  @override
  String get recoveryPeriodTypeRecoveryDesc => 'Light training to promote active recovery';

  @override
  String get trainingPhaseBase => 'Base';

  @override
  String get trainingPhaseBuild => 'Build';

  @override
  String get trainingPhasePeak => 'Peak';

  @override
  String get trainingPhaseTaper => 'Taper';

  @override
  String get trainingPhaseTransition => 'Transition';

  @override
  String get trainingPhaseBaseDesc => 'Aerobic foundation — high volume, low intensity';

  @override
  String get trainingPhaseBuildDesc => 'Build fitness — volume plus targeted intensity';

  @override
  String get trainingPhasePeakDesc => 'Race-specific intensity, reduced total volume';

  @override
  String get trainingPhaseTaperDesc => 'Reduce volume sharply, keep touches of intensity';

  @override
  String get trainingPhaseTransitionDesc => 'Active recovery between training blocks';

  @override
  String get unitSystemImperial => 'Imperial';

  @override
  String get unitSystemMetric => 'Metric';

  @override
  String get muscleGroupChest => 'Chest';

  @override
  String get muscleGroupTriceps => 'Triceps';

  @override
  String get muscleGroupShoulders => 'Shoulders';

  @override
  String get muscleGroupBack => 'Back';

  @override
  String get muscleGroupBiceps => 'Biceps';

  @override
  String get muscleGroupQuads => 'Quads';

  @override
  String get muscleGroupHamstrings => 'Hamstrings';

  @override
  String get muscleGroupGlutes => 'Glutes';

  @override
  String get muscleGroupCalves => 'Calves';

  @override
  String get muscleGroupTraps => 'Traps';

  @override
  String get muscleGroupForearms => 'Forearms';

  @override
  String get muscleGroupAbs => 'Abs';

  @override
  String get muscleGroupFullBody => 'Full Body';

  @override
  String get muscleGroupAdductors => 'Adductors';

  @override
  String get muscleGroupCore => 'Core';

  @override
  String get muscleGroupGrip => 'Grip';

  @override
  String get muscleGroupObliques => 'Obliques';

  @override
  String get equipmentBarbell => 'Barbell';

  @override
  String get equipmentBodyweightLoadable => 'Bodyweight Loadable';

  @override
  String get equipmentBodyweightOnly => 'Bodyweight Only';

  @override
  String get equipmentCable => 'Cable';

  @override
  String get equipmentDumbbell => 'Dumbbell';

  @override
  String get equipmentFreemotion => 'Freemotion';

  @override
  String get equipmentKettlebell => 'Kettlebell';

  @override
  String get equipmentMachine => 'Machine';

  @override
  String get equipmentMachineAssistance => 'Machine Assistance';

  @override
  String get equipmentSmithMachine => 'Smith Machine';

  @override
  String get equipmentBandAssistance => 'Band Assistance';

  @override
  String get sportStrength => 'Strength';

  @override
  String get sportRun => 'Run';

  @override
  String get sportBike => 'Bike';

  @override
  String get sportSwim => 'Swim';

  @override
  String get sportOther => 'Other';

  @override
  String get sessionSourcePlanned => 'Planned';

  @override
  String get sessionSourceLogged => 'Logged';

  @override
  String get sessionSourceAppleHealth => 'Apple Health';

  @override
  String get sessionSourceHealthConnect => 'Health Connect';

  @override
  String get sessionSourcePeloton => 'Peloton';

  @override
  String get sessionSourceStrava => 'Strava';

  @override
  String get sessionSourceGarmin => 'Garmin';

  @override
  String get sessionSourceImported => 'Imported';

  @override
  String get intervalIntentWarmup => 'Warm-up';

  @override
  String get intervalIntentWork => 'Work';

  @override
  String get intervalIntentRecovery => 'Recovery';

  @override
  String get intervalIntentCooldown => 'Cool-down';

  @override
  String get intervalIntentRest => 'Rest';

  @override
  String get intervalIntentRepeat => 'Repeat';

  @override
  String get intervalTargetDuration => 'Duration';

  @override
  String get intervalTargetDistance => 'Distance';

  @override
  String get intervalTargetHrZone => 'HR zone';

  @override
  String get intervalTargetPaceZone => 'Pace zone';

  @override
  String get intervalTargetPowerZone => 'Power zone';

  @override
  String get intervalTargetFreeform => 'Freeform';

  @override
  String get strokeTypeFreestyle => 'Freestyle';

  @override
  String get strokeTypeBackstroke => 'Backstroke';

  @override
  String get strokeTypeBreaststroke => 'Breaststroke';

  @override
  String get strokeTypeButterfly => 'Butterfly';

  @override
  String get strokeTypeMixed => 'Mixed';

  @override
  String get strokeTypeDrill => 'Drill';

  @override
  String get onboardingSportsTitle => 'Your sports';

  @override
  String get onboardingSportsHeadline => 'Which sports do you train?';

  @override
  String get onboardingSportsSubtitle => 'Pick all that apply. You can add more later in Settings.';

  @override
  String get sportDescriptionStrength => 'Lifting, hypertrophy, powerlifting';

  @override
  String get sportDescriptionRun => 'Running, treadmill, trail';

  @override
  String get sportDescriptionBike => 'Road, trainer, MTB, spin (Peloton)';

  @override
  String get sportDescriptionSwim => 'Pool or open water';

  @override
  String get sportDescriptionOther => 'Other activities';

  @override
  String get onboardingTerminologyTitle => 'Terminology';

  @override
  String get onboardingTerminologyHeadline => 'What do you call a training cycle?';

  @override
  String get onboardingTerminologySubtitle =>
      'Choose the term you\'re most comfortable with. We\'ll use this throughout the app.';

  @override
  String get getStartedButton => 'Get Started';

  @override
  String get trainingCycleTermBlock => 'Block';

  @override
  String get trainingCycleTermBlockDesc => 'A focused training block with specific goals';

  @override
  String get trainingCycleTermMesocycle => 'Mesocycle';

  @override
  String get trainingCycleTermMesocycleDesc => 'A structured training period typically lasting 3-6 weeks';

  @override
  String get trainingCycleTermModule => 'Module';

  @override
  String get trainingCycleTermModuleDesc => 'A modular training unit that can be stacked';

  @override
  String get trainingCycleTermPhase => 'Phase';

  @override
  String get trainingCycleTermPhaseDesc => 'A training phase within your overall program';

  @override
  String get trainingCycleTermWave => 'Wave';

  @override
  String get trainingCycleTermWaveDesc => 'A wave of progressive training intensity';

  @override
  String get onboardingEquipmentTitle => 'Your equipment';

  @override
  String get onboardingEquipmentHeadline => 'What equipment do you have access to?';

  @override
  String get onboardingEquipmentSubtitle => 'Select all that apply. This helps us suggest appropriate exercises.';

  @override
  String get onboardingEquipmentSkip => 'Skip for now';

  @override
  String get equipmentDumbbells => 'Dumbbells';

  @override
  String get equipmentHomeGymRack => 'Home Gym Rack';

  @override
  String get equipmentFunctionalTrainer => 'Functional (Cable) Trainer';

  @override
  String get equipmentGymMachines => 'Gym Machines';

  @override
  String get equipmentBarbells => 'Barbells';

  @override
  String get equipmentKettlebells => 'Kettlebells';

  @override
  String get equipmentResistanceBands => 'Resistance Bands';

  @override
  String get equipmentTreadmill => 'Treadmill';

  @override
  String get equipmentExerciseBike => 'Exercise Bike';

  @override
  String get equipmentRowingMachine => 'Rowing Machine';

  @override
  String get equipmentLapPool => 'Lap Pool';

  @override
  String get equipmentCrossfitGym => 'Crossfit Gym';

  @override
  String get equipmentPullUpBar => 'Pull-up Bar';

  @override
  String get equipmentSuspensionTrainer => 'Suspension Trainer (TRX)';

  @override
  String get onboardingProfileTitle => 'About you';

  @override
  String get onboardingProfileHeadline => 'Let\'s get to know you';

  @override
  String get onboardingProfileSubtitle =>
      'Height + weight let us track body metrics and show BMI. Icon preference is optional at the bottom.';

  @override
  String get unitsLabel => 'Units:';

  @override
  String get imperialLabel => 'Imperial';

  @override
  String get metricLabel => 'Metric';

  @override
  String get heightLabel => 'Height';

  @override
  String get centimetersLabel => 'Centimeters';

  @override
  String get cmSuffix => 'cm';

  @override
  String get feetLabel => 'Feet';

  @override
  String get ftSuffix => 'ft';

  @override
  String get inchesLabel => 'Inches';

  @override
  String get inSuffix => 'in';

  @override
  String get weightLabel => 'Weight';

  @override
  String get kilogramsLabel => 'Kilograms';

  @override
  String get poundsLabel => 'Pounds';

  @override
  String get kgSuffix => 'kg';

  @override
  String get lbsSuffix => 'lbs';

  @override
  String get heightRequiredError => 'Please enter your height';

  @override
  String get heightInvalidCmError => 'Please enter a valid height (100-250 cm)';

  @override
  String get heightFeetRequiredError => 'Required';

  @override
  String get heightInvalidError => 'Invalid';

  @override
  String get weightRequiredError => 'Please enter your weight';

  @override
  String get weightInvalidNumberError => 'Please enter a valid number';

  @override
  String get weightInvalidKgError => 'Please enter a valid weight (40-180 kg)';

  @override
  String get weightInvalidLbsError => 'Please enter a valid weight (80-400 lbs)';

  @override
  String get bmiPlaceholder => 'Enter height and weight to see BMI';

  @override
  String bmiValue(Object bmiValue) {
    return 'BMI $bmiValue';
  }

  @override
  String get aboutBmiCategories => 'About BMI categories';

  @override
  String get bmiCategoryObese => 'Obese';

  @override
  String get bmiCategoryOverweight => 'Overweight';

  @override
  String get bmiCategoryNormal => 'Normal';

  @override
  String get bmiCategoryUnderweight => 'Underweight';

  @override
  String get bmiCategoriesTitle => 'BMI categories';

  @override
  String get bmiGuidelines => 'Based on WHO / CDC guidelines';

  @override
  String get dexaScanTitle => 'DEXA Scan Results';

  @override
  String get dexaSubtitle => 'Optional - for bodybuilders';

  @override
  String get bodyFatLabel => 'Body Fat';

  @override
  String get bodyFatSuffix => '%';

  @override
  String get bodyFatInvalidError => 'Invalid (3-60%)';

  @override
  String get leanMassLabel => 'Lean Mass';

  @override
  String get appIconTitle => 'App icon (optional)';

  @override
  String get appIconSubtitle => 'Three variants — tap one to pick.';

  @override
  String cycleCreateTitle(Object cycleTerm) {
    return 'Create $cycleTerm';
  }

  @override
  String cycleCreateHeading(Object cycleTerm) {
    return 'New $cycleTerm';
  }

  @override
  String cycleCreateDescription(Object cycleTerm) {
    return 'A $cycleTerm is a multi-period training program with progressive overload, often followed by a recovery period to allow your body to rest and adapt.';
  }

  @override
  String cycleCreateNameLabel(Object cycleTerm) {
    return '$cycleTerm Name';
  }

  @override
  String get cycleCreateNameHint => 'e.g., Spring 2025 Hypertrophy';

  @override
  String get cycleCreateNameRequired => 'Please enter a name';

  @override
  String get cycleCreateNameMinLength => 'Name must be at least 3 characters';

  @override
  String cycleCreateNameEmptySnackbar(Object cycleTerm) {
    return 'Please enter a name for your $cycleTerm';
  }

  @override
  String get cycleCreatePrimarySportHeader => 'Primary sport (optional)';

  @override
  String get cycleCreatePrimarySportDesc =>
      'Hints which sport the cycle is built around. Does not restrict what sessions you can add — every cycle can mix any sports.';

  @override
  String get cycleCreateDurationHeader => 'Duration';

  @override
  String get cycleCreateTrainingFrequencyHeader => 'Training Frequency';

  @override
  String get cycleCreateRecoveryHeader => 'Recovery Period (Optional)';

  @override
  String get cycleCreateTemplateHeader => 'Template (Optional)';

  @override
  String get cycleCreateCreatingButton => 'Creating...';

  @override
  String cycleCreateButton(Object cycleTerm) {
    return 'Create $cycleTerm';
  }

  @override
  String get cycleCreateTotalPeriods => 'Total Periods';

  @override
  String cycleCreatePeriodsCount(Object count) {
    return '$count periods';
  }

  @override
  String get cycleCreatePeriodsRecommendation => 'Recommended: 4-6 periods for hypertrophy';

  @override
  String get cycleCreateTrainingDays => 'Training Days';

  @override
  String cycleCreateDaysPerPeriod(Object count) {
    return '$count days/period';
  }

  @override
  String cycleCreateDaysLabel(Object count) {
    return '$count days';
  }

  @override
  String get cycleCreateSplit2 => 'Minimalist full body split';

  @override
  String get cycleCreateSplit3 => 'Full body or Push/Pull/Legs split';

  @override
  String get cycleCreateSplit4 => 'Upper/Lower or Push/Pull/Legs + Upper';

  @override
  String get cycleCreateSplit5 => 'Push/Pull/Legs/Upper/Lower split';

  @override
  String get cycleCreateSplit6 => 'Push/Pull/Legs twice per period';

  @override
  String get cycleCreateSplit7 => 'Daily training (7-day cycle)';

  @override
  String get cycleCreateSplit8 => '8-day training cycle with rest day';

  @override
  String get cycleCreateSplit9 => '9-day training cycle (e.g., 3-on/1-off)';

  @override
  String get cycleCreateSplit10 => '10-day training cycle';

  @override
  String get cycleCreateSplit11 => '11-day training cycle';

  @override
  String get cycleCreateSplit12 => '12-day training cycle';

  @override
  String get cycleCreateSplit13 => '13-day training cycle';

  @override
  String get cycleCreateSplit14 => '14-day (bi-weekly) training cycle';

  @override
  String cycleCreateSplitGeneric(Object count) {
    return '$count-day training cycle';
  }

  @override
  String get cycleCreateIncludeRecoveryTitle => 'Include Recovery Period';

  @override
  String get cycleCreateIncludeRecoverySubtitle => 'A lighter period to aid recovery and prevent overtraining';

  @override
  String get cycleCreateRecoveryType => 'Recovery Type';

  @override
  String cycleCreateRecoveryOnPeriod(Object recoveryType) {
    return '$recoveryType on Period';
  }

  @override
  String cycleCreatePeriodNumber(Object number) {
    return 'Period $number';
  }

  @override
  String get cycleCreateRecoveryScheduleHint => 'Most people schedule this on the last period';

  @override
  String get cycleCreateChooseTemplate => 'Choose a Template';

  @override
  String get cycleCreateTemplateNone => 'None (Custom)';

  @override
  String get cycleCreateTemplateHint => 'Templates provide pre-configured training splits with strength exercises';

  @override
  String cycleCreateErrorLoadingTemplates(Object error) {
    return 'Error loading templates: $error';
  }

  @override
  String cycleCreateSuccessSnackbar(Object cycleTerm, Object name) {
    return '$cycleTerm \"$name\" created!';
  }

  @override
  String get cycleCreateMixedChipLabel => 'Mixed';

  @override
  String get cycleListNewButton => 'New';

  @override
  String cycleListDraftSectionHeader(Object cycleTerm) {
    return 'Draft $cycleTerm';
  }

  @override
  String cycleListCurrentSectionHeader(Object cycleTerm) {
    return 'Current $cycleTerm';
  }

  @override
  String cycleListCompletedSectionHeader(Object cycleTermPlural) {
    return 'Completed $cycleTermPlural';
  }

  @override
  String cycleListErrorLoading(Object error) {
    return 'Error loading trainingCycles: $error';
  }

  @override
  String get cycleListCurrentBadge => 'CURRENT';

  @override
  String cycleListPeriodsCount(Object count) {
    return '$count periods';
  }

  @override
  String cycleListDaysPerPeriod(Object count) {
    return '$count days/period';
  }

  @override
  String get cycleListStartButton => 'Start';

  @override
  String get cycleListEmptyTitle => 'No TrainingCycles';

  @override
  String get cycleListEmptySubtitle => 'Create your first trainingCycle to get started';

  @override
  String get cycleListCreateNew => 'Create New';

  @override
  String get cycleListStartFromTemplate => 'Start from Template';

  @override
  String get cycleListMenuWriteNote => 'Write a new note';

  @override
  String get cycleListMenuRename => 'Rename';

  @override
  String cycleListMenuCopy(Object cycleTerm) {
    return 'Copy the $cycleTerm';
  }

  @override
  String get cycleListMenuSummary => 'Summary';

  @override
  String cycleListMenuRestart(Object cycleTerm) {
    return 'Restart $cycleTerm';
  }

  @override
  String get cycleListMenuSaveAsTemplate => 'Save as a Template';

  @override
  String get cycleListMenuShareQR => 'Share (Host QR Code)';

  @override
  String get cycleListMenuExportDebug => 'Export (Debug)';

  @override
  String cycleListMenuDelete(Object cycleTerm) {
    return 'Delete $cycleTerm';
  }

  @override
  String cycleListStartDialogTitle(Object cycleTerm) {
    return 'Start $cycleTerm';
  }

  @override
  String cycleListStartDialogNoActive(Object name, Object cycleTerm) {
    return 'Start \"$name\"? This will set it as your current $cycleTerm.';
  }

  @override
  String cycleListStartDialogHasActive(Object cycleTerm, Object activeNames, Object name) {
    return 'You have an active $cycleTerm: \"$activeNames\".\n\nHow would you like to start \"$name\"?';
  }

  @override
  String get cycleListReplaceCurrentButton => 'Replace current';

  @override
  String get cycleListStackAlongsideButton => 'Stack alongside';

  @override
  String cycleListNoteDialogTitle(Object cycleTerm) {
    return '$cycleTerm Note';
  }

  @override
  String cycleListNoteDialogHint(Object cycleTerm) {
    return 'Enter note for this $cycleTerm...';
  }

  @override
  String cycleListCopyNameSuffix(Object name) {
    return '$name (Copy)';
  }

  @override
  String cycleListCopiedSnackbar(Object cycleTerm) {
    return '$cycleTerm copied as draft!';
  }

  @override
  String cycleListErrorCopying(Object cycleTerm, Object error) {
    return 'Error copying $cycleTerm: $error';
  }

  @override
  String cycleListRestartDialogTitle(Object cycleTerm) {
    return 'Restart $cycleTerm';
  }

  @override
  String cycleListRestartDialogContent(Object name, Object cycleTerm) {
    return 'Restart \"$name\"? This will create a copy and set it as your current $cycleTerm.';
  }

  @override
  String get cycleListRestartButton => 'Restart';

  @override
  String cycleListRestartedSnackbar(Object cycleTerm) {
    return '$cycleTerm restarted!';
  }

  @override
  String cycleListErrorRestarting(Object cycleTerm, Object error) {
    return 'Error restarting $cycleTerm: $error';
  }

  @override
  String cycleListTemplateSaved(Object name) {
    return 'Template \"$name\" saved!';
  }

  @override
  String cycleListErrorSavingTemplate(Object error) {
    return 'Error saving template: $error';
  }

  @override
  String get cycleListPreparingShare => 'Preparing to share...';

  @override
  String cycleListSharedFromDescription(Object name) {
    return 'Shared from $name';
  }

  @override
  String cycleListErrorPreparingShare(Object error) {
    return 'Error preparing template for sharing: $error';
  }

  @override
  String get cycleListTemplateExported => 'Template JSON copied to clipboard!';

  @override
  String cycleListErrorExporting(Object error) {
    return 'Error exporting template: $error';
  }

  @override
  String cycleListRenamedSnackbar(Object name) {
    return 'Renamed to \"$name\"';
  }

  @override
  String cycleListErrorRenaming(Object error) {
    return 'Error renaming trainingCycle: $error';
  }

  @override
  String get cycleListDeleteDialogTitle => 'Delete Draft TrainingCycle';

  @override
  String cycleListDeleteDialogContent(Object name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String cycleListDeletedSnackbar(Object name) {
    return '\"$name\" deleted';
  }

  @override
  String cycleListErrorDeleting(Object error) {
    return 'Error deleting trainingCycle: $error';
  }

  @override
  String get cycleListMenuComplete => 'Mark as completed';

  @override
  String cycleListCompleteDialogTitle(Object cycleTerm) {
    return 'Complete $cycleTerm';
  }

  @override
  String cycleListCompleteDialogContent(Object name, Object cycleTerm) {
    return 'Mark \"$name\" as completed? Your history is preserved and the $cycleTerm moves to your completed list.';
  }

  @override
  String get cycleListCompleteAction => 'Complete';

  @override
  String cycleListCompletedSnackbar(Object name) {
    return '\"$name\" marked as completed';
  }

  @override
  String cycleListErrorCompleting(Object error) {
    return 'Error completing trainingCycle: $error';
  }

  @override
  String get cycleListRenameDialogTitle => 'Rename';

  @override
  String get cycleListRenameDialogHint => 'TrainingCycle name';

  @override
  String get cycleListSaveTemplateDialogTitle => 'Save as Template';

  @override
  String get cycleListSaveTemplateNameLabel => 'Template Name';

  @override
  String get cycleListSaveTemplateNameHint => 'e.g., \"Upper Lower Split\"';

  @override
  String get cycleListSaveTemplateNameError => 'Please enter a template name';

  @override
  String get cycleListSaveTemplateDescLabel => 'Description';

  @override
  String get cycleListSaveTemplateDescHint => 'e.g., \"Great for building strength and size\"';

  @override
  String get cycleListSaveTemplateDescError => 'Please enter a description';

  @override
  String get templateSelectionTitle => 'Choose a Program';

  @override
  String get templateSelectionNoTemplates => 'No templates available';

  @override
  String get templateSelectionBrowseCommunity => 'Browse Community';

  @override
  String get templateSelectionBrowseCommunitySubtitle => 'Download programs shared by other users';

  @override
  String templateSelectionDaysPerPeriod(Object count) {
    return '$count Days/Period';
  }

  @override
  String templateSelectionPeriodsCount(Object count) {
    return '$count Periods';
  }

  @override
  String templateSelectionSessionsCount(Object count) {
    return '$count Sessions';
  }

  @override
  String get templateSelectionDeleteTitle => 'Delete Template?';

  @override
  String templateSelectionDeleteContent(Object name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String templateSelectionDeletedSnackbar(Object name) {
    return 'Template \"$name\" deleted';
  }

  @override
  String templateSelectionDeleteError(Object error) {
    return 'Failed to delete template: $error';
  }

  @override
  String get templatePreviewLoadProgram => 'LOAD PROGRAM';

  @override
  String templatePreviewErrorCreating(Object error) {
    return 'Error creating program: $error';
  }

  @override
  String get templatePreviewDuration => 'Duration';

  @override
  String get templatePreviewPerPeriod => 'Per Period';

  @override
  String get templatePreviewRecovery => 'Recovery';

  @override
  String templatePreviewPeriodHeader(Object number) {
    return 'Period $number';
  }

  @override
  String templatePreviewPeriodRecoveryHeader(Object number) {
    return 'Period $number (Recovery)';
  }

  @override
  String templatePreviewDayFallback(Object number) {
    return 'Day $number';
  }

  @override
  String templatePreviewCardioSession(Object sport) {
    return '$sport session';
  }

  @override
  String templatePreviewExerciseCount(Object count) {
    return '$count Exercises';
  }

  @override
  String templatePreviewSetsReps(Object sets, Object reps) {
    return '$sets sets × $reps';
  }

  @override
  String templatePreviewDaysCount(Object count) {
    return '$count Days';
  }

  @override
  String planCycleTitle(Object cycleTerm) {
    return 'Plan a $cycleTerm';
  }

  @override
  String get planCycleStartWithTemplate => 'Start with a template';

  @override
  String get planCycleStartWithTemplateSubtitle => 'Pick a template that fits your goals and get started ASAP.';

  @override
  String get planCycleStartFromScratch => 'Start from scratch';

  @override
  String planCycleStartFromScratchSubtitle(Object cycleTerm) {
    return 'Build your own $cycleTerm from a completely blank slate.';
  }

  @override
  String get workoutSessionTitle => 'Session';

  @override
  String workoutPeriodDayTitle(Object period, Object day, Object dayName) {
    return 'PERIOD $period DAY $day $dayName';
  }

  @override
  String workoutCycleCompletedTitle(Object cycleTerm) {
    return '$cycleTerm Completed!';
  }

  @override
  String workoutCycleCompletedContent(Object cycleTerm) {
    return 'Congratulations! You have finished all workouts in this $cycleTerm.';
  }

  @override
  String get workoutCycleCompletedAction => 'AWESOME';

  @override
  String workoutEndCycleTitle(Object cycleTerm) {
    return 'End $cycleTerm';
  }

  @override
  String workoutEndCycleContent(Object name) {
    return 'Are you sure you want to end \"$name\"? This will mark it as completed.';
  }

  @override
  String workoutEndCycleAction(Object cycleTerm) {
    return 'END $cycleTerm';
  }

  @override
  String workoutCycleCompleted(Object name) {
    return '\"$name\" completed';
  }

  @override
  String workoutEndCycleError(Object error) {
    return 'Error ending trainingCycle: $error';
  }

  @override
  String get workoutFinishButton => 'FINISH WORKOUT';

  @override
  String get workoutFinishLabel => 'Finish workout';

  @override
  String get workoutSelectDayTooltip => 'Select day';

  @override
  String get workoutAddSessionTooltip => 'Add session';

  @override
  String get workoutAppLogoLabel => 'App logo';

  @override
  String workoutSetDeleted(Object setNumber) {
    return 'Set $setNumber deleted';
  }

  @override
  String workoutExerciseDeleted(Object exerciseName) {
    return '$exerciseName deleted';
  }

  @override
  String workoutCardioSessionDeleted(Object label) {
    return '$label deleted';
  }

  @override
  String workoutRenamedTo(Object name) {
    return 'Renamed to \"$name\"';
  }

  @override
  String workoutRenameError(Object error) {
    return 'Error renaming trainingCycle: $error';
  }

  @override
  String get workoutLabelUpdated => 'Label updated';

  @override
  String workoutLabelUpdatedForAllDays(Object dayNumber) {
    return 'Updated label for all Day $dayNumber workouts';
  }

  @override
  String workoutLabelUpdateError(Object error) {
    return 'Error updating label: $error';
  }

  @override
  String get workoutAllDayLabelsCleared => 'All day labels cleared';

  @override
  String workoutClearLabelsError(Object error) {
    return 'Error clearing labels: $error';
  }

  @override
  String get workoutReset => 'Workout reset';

  @override
  String workoutResetError(Object error) {
    return 'Error resetting workout: $error';
  }

  @override
  String get workoutClearDayLabelsTitle => 'Clear All Day Labels';

  @override
  String get workoutClearDayLabelsContent =>
      'This will remove all custom day labels from workouts in this trainingCycle. Day names will be calculated automatically based on the start date.\n\nThis cannot be undone.';

  @override
  String get workoutClearDayLabelsAction => 'CLEAR ALL';

  @override
  String get workoutResetTitle => 'Reset Workout?';

  @override
  String get workoutResetContent =>
      'This will clear all logged sets and entered values for this workout. This action cannot be undone.';

  @override
  String get workoutResetAction => 'RESET';

  @override
  String get workoutMenuTrainingCycleHeader => 'TRAINING CYCLE';

  @override
  String get workoutMenuNote => 'Note';

  @override
  String get workoutMenuSummary => 'Summary';

  @override
  String get workoutMenuRename => 'Rename';

  @override
  String workoutMenuEndCycle(Object cycleTerm) {
    return 'End $cycleTerm';
  }

  @override
  String get workoutMenuWorkoutHeader => 'WORKOUT';

  @override
  String get workoutMenuNewNote => 'New note';

  @override
  String get workoutMenuRelabel => 'Relabel';

  @override
  String get workoutMenuClearDayLabels => 'Clear all day labels';

  @override
  String get workoutMenuAddSession => 'Add session';

  @override
  String get workoutMenuBodyweight => 'Bodyweight';

  @override
  String get workoutMenuReset => 'Reset';

  @override
  String get workoutMenuSkipWorkout => 'Skip workout';

  @override
  String get workoutNoActiveCycleTitle => 'No Active TrainingCycle';

  @override
  String get workoutNoActiveCycleMessage => 'Create and start a trainingCycle to begin';

  @override
  String get workoutCycleNotActiveTitle => 'TrainingCycle Not Active';

  @override
  String get workoutCycleNotActiveMessage => 'The trainingCycle is scheduled for a future date or has ended';

  @override
  String workoutCycleSectionPeriodDay(Object period, Object day) {
    return 'Period $period • Day $day';
  }

  @override
  String get editWorkoutStartButton => 'Start';

  @override
  String get editWorkoutExportTemplateTooltip => 'Export Template (Debug)';

  @override
  String get editWorkoutAddExerciseButton => 'Add Exercise';

  @override
  String get editWorkoutPeriodLabel => 'Period';

  @override
  String get editWorkoutRemovePeriodTooltip => 'Remove Period';

  @override
  String get editWorkoutAddPeriodTooltip => 'Add Period';

  @override
  String get editWorkoutMirrorPeriod1Tooltip => 'Mirror Period 1';

  @override
  String get editWorkoutDayLabel => 'Day';

  @override
  String editWorkoutDayPrefix(Object number) {
    return 'D$number';
  }

  @override
  String get editWorkoutRemoveDayTooltip => 'Remove Day';

  @override
  String get editWorkoutAddDayTooltip => 'Add Day';

  @override
  String editWorkoutPeriodAdded(Object number) {
    return 'Period $number added';
  }

  @override
  String editWorkoutPeriodAddError(Object error) {
    return 'Error adding period: $error';
  }

  @override
  String get editWorkoutRecoveryPeriodRemoved => 'Recovery period removed';

  @override
  String editWorkoutPeriodRemoved(Object number) {
    return 'Period $number removed';
  }

  @override
  String editWorkoutPeriodRemoveError(Object error) {
    return 'Error removing period: $error';
  }

  @override
  String editWorkoutRecoveryTypeChanged(Object type) {
    return 'Recovery period changed to $type';
  }

  @override
  String editWorkoutRecoveryTypeError(Object error) {
    return 'Error updating recovery type: $error';
  }

  @override
  String editWorkoutDayAdded(Object number) {
    return 'Day $number added';
  }

  @override
  String editWorkoutDayAddError(Object error) {
    return 'Error adding day: $error';
  }

  @override
  String editWorkoutDayRemoved(Object number) {
    return 'Day $number removed';
  }

  @override
  String editWorkoutDayRemoveError(Object error) {
    return 'Error removing day: $error';
  }

  @override
  String editWorkoutPeriod1Mirrored(Object number) {
    return 'Period 1 mirrored to Period $number';
  }

  @override
  String editWorkoutMirrorError(Object error) {
    return 'Error mirroring period: $error';
  }

  @override
  String get editWorkoutTemplateExported => 'Template JSON copied to clipboard!';

  @override
  String editWorkoutTemplateExportError(Object error) {
    return 'Error exporting template: $error';
  }

  @override
  String get editWorkoutRemovePeriodTitle => 'Remove Period';

  @override
  String editWorkoutRemovePeriodContent(Object number) {
    return 'Which period would you like to remove?\n\n• Period $number (last training period)\n• Recovery period';
  }

  @override
  String get editWorkoutRemoveDeload => 'Remove Deload';

  @override
  String editWorkoutRemovePeriodAction(Object number) {
    return 'Remove Period $number';
  }

  @override
  String get editWorkoutRecoveryTypeTitle => 'Recovery Period Type';

  @override
  String get editWorkoutRemoveDayTitle => 'Remove Day';

  @override
  String editWorkoutRemoveDayContent(Object number) {
    return 'Day $number has exercises assigned. Removing it will delete all exercises on this day across all periods.\n\nAre you sure you want to remove Day $number?';
  }

  @override
  String get editWorkoutRemoveDayAction => 'Remove';

  @override
  String get editWorkoutMirrorTitle => 'Mirror Period 1';

  @override
  String editWorkoutMirrorContent(Object number) {
    return 'Copy all workouts from Period 1 to Period $number? This will replace any existing workouts for Period $number.';
  }

  @override
  String get editWorkoutMirrorAction => 'Mirror';

  @override
  String get editWorkoutDeleteExerciseTitle => 'Delete Exercise';

  @override
  String editWorkoutDeleteExerciseContent(Object name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String editWorkoutStartCycleTitle(Object cycleTerm) {
    return 'Start $cycleTerm';
  }

  @override
  String editWorkoutStartCycleContent(Object name, Object cycleTerm) {
    return 'Start \"$name\"? This will set it as your current $cycleTerm.';
  }

  @override
  String editWorkoutStartCycleActiveContent(Object cycleTerm, Object activeNames, Object name) {
    return 'You have an active $cycleTerm: \"$activeNames\".\n\nHow would you like to start \"$name\"?';
  }

  @override
  String get editWorkoutStartCycleReplace => 'Replace current';

  @override
  String get editWorkoutStartCycleStack => 'Stack alongside';

  @override
  String get editWorkoutSetHeader => 'SET';

  @override
  String get editWorkoutRepsHeader => 'REPS';

  @override
  String get editWorkoutRepsHint => 'reps';

  @override
  String get editWorkoutExerciseMenuHeader => 'EXERCISE';

  @override
  String get editWorkoutNewNote => 'New note';

  @override
  String get editWorkoutMoveUp => 'Move up';

  @override
  String get editWorkoutMoveDown => 'Move down';

  @override
  String get editWorkoutReplace => 'Replace';

  @override
  String get editWorkoutAddSet => 'Add set';

  @override
  String get editWorkoutDeleteExercise => 'Delete exercise';

  @override
  String get editWorkoutSetMenuHeader => 'SET';

  @override
  String get editWorkoutAddSetBelow => 'Add set below';

  @override
  String get editWorkoutDeleteSet => 'Delete set';

  @override
  String get editWorkoutSetTypeHeader => 'SET TYPE';

  @override
  String get editWorkoutNoExercisesTitle => 'No exercises scheduled';

  @override
  String get editWorkoutNoExercisesSubtitle => 'Add exercises for this day';

  @override
  String get editWorkoutAddCardioSessionTitle => 'Add cardio session';

  @override
  String get editWorkoutAddCardio => 'Add cardio';

  @override
  String get editWorkoutInfoButtonLabel => 'i';

  @override
  String get addExerciseTitle => 'Add exercise';

  @override
  String get addExerciseCreateCustomButton => 'Create Custom';

  @override
  String get addExerciseAddButton => 'Add';

  @override
  String get addExerciseSearchLabel => 'Search exercises';

  @override
  String get addExerciseSearchHint => 'Search';

  @override
  String get addExerciseClearSearchTooltip => 'Clear search';

  @override
  String get addExerciseFilterButton => 'Filter';

  @override
  String get addExerciseFilterClearAll => 'CLEAR ALL';

  @override
  String get addExerciseFilterTitle => 'Filter';

  @override
  String get addExerciseFilterMuscleGroup => 'Muscle Group';

  @override
  String get addExerciseFilterEquipmentType => 'Filter by Equipment Type';

  @override
  String get addExerciseFilterEquipmentTypeDesc => 'Temporarily filter to specific equipment types';

  @override
  String get addExerciseFilterApplyButton => 'APPLY FILTERS';

  @override
  String get addExerciseNoResults => 'No exercises found';

  @override
  String get addExerciseAdjustFilters => 'Try adjusting your search or filters';

  @override
  String addExerciseLastPerformed(Object dateStr) {
    return 'Last performed $dateStr';
  }

  @override
  String get addExerciseWorkoutNotFound => 'Error: Workout not found';

  @override
  String addExerciseReplaced(Object oldName, Object newName) {
    return '$oldName replaced with $newName';
  }

  @override
  String addExerciseAdded(Object name) {
    return '$name added';
  }

  @override
  String get completedWorkoutNotFoundTitle => 'TrainingCycle Not Found';

  @override
  String get completedWorkoutNotFoundBody => 'The requested trainingCycle could not be found.';

  @override
  String get completedWorkoutErrorTitle => 'Error';

  @override
  String completedWorkoutErrorMessage(Object error) {
    return 'Error loading trainingCycle: $error';
  }

  @override
  String get completedWorkoutCompletedBadge => 'COMPLETED';

  @override
  String completedWorkoutWeekDayTitle(Object period, Object day, Object dayName) {
    return 'WEEK $period DAY $day $dayName';
  }

  @override
  String get completedWorkoutWeightHeader => 'WEIGHT';

  @override
  String get completedWorkoutRepsHeader => 'REPS';

  @override
  String get completedWorkoutLogHeader => 'LOG';

  @override
  String get completedWorkoutNoExercises => 'No exercises for this day';

  @override
  String get completedWorkoutWeeksReadOnly => 'WEEKS (READ-ONLY)';

  @override
  String get completedWorkoutDlLabel => 'DL';

  @override
  String completedWorkoutRirLabel(Object rir) {
    return '$rir RIR';
  }

  @override
  String get completedWorkoutUnknownEquipment => 'UNKNOWN';

  @override
  String get completedWorkoutEmptyValue => '-';

  @override
  String cardioSessionLogTitle(Object sport) {
    return 'Log $sport';
  }

  @override
  String cardioSessionEditTitle(Object sport) {
    return 'Edit $sport';
  }

  @override
  String cardioSessionPlanTitle(Object sport) {
    return 'Plan $sport';
  }

  @override
  String get cardioSessionEditIntervalsTooltip => 'Edit intervals';

  @override
  String get cardioSessionImportedChip => 'Imported';

  @override
  String get cardioSessionDateButton => 'Date';

  @override
  String get cardioSessionStartFromTemplate => 'Start from template';

  @override
  String get cardioSessionNameLabel => 'Session name';

  @override
  String get cardioSessionNameHint => 'e.g., 30 min Tempo';

  @override
  String get cardioSessionNotesLabel => 'Notes';

  @override
  String get cardioSessionNotesHint => 'Anything worth remembering about this session…';

  @override
  String get cardioSessionPlanButton => 'Plan session';

  @override
  String get cardioSessionSaveButton => 'Save session';

  @override
  String get cardioSessionLogButton => 'Log session';

  @override
  String get cardioSessionUpdateButton => 'Update session';

  @override
  String get cardioSessionPlanned => 'Session planned';

  @override
  String get cardioSessionLogged => 'Session logged';

  @override
  String get cardioSessionUpdated => 'Session updated';

  @override
  String get cardioSessionPerceivedExertion => 'Perceived exertion';

  @override
  String cardioSessionRpeValue(Object value) {
    return 'RPE $value';
  }

  @override
  String get cardioSessionRpeNotSet => 'Not set';

  @override
  String cardioSessionPaceAvgSpeed(Object pace, Object speed) {
    return 'Pace $pace  •  Avg speed $speed';
  }

  @override
  String cardioSessionAvgSpeed(Object speed) {
    return 'Avg speed $speed';
  }

  @override
  String get intervalBuilderTitle => 'Intervals';

  @override
  String get intervalBuilderSaveButton => 'Save';

  @override
  String get intervalBuilderSessionNotFound => 'Cardio session not found';

  @override
  String intervalBuilderStepsCount(Object count) {
    return '$count steps';
  }

  @override
  String get intervalBuilderSaved => 'Intervals saved';

  @override
  String get intervalBuilderDiscardTitle => 'Discard changes?';

  @override
  String get intervalBuilderDiscardContent => 'You have unsaved changes to this interval plan.';

  @override
  String get intervalBuilderKeepEditing => 'Keep editing';

  @override
  String get intervalBuilderDiscard => 'Discard';

  @override
  String get intervalBuilderAddStep => 'Add step';

  @override
  String get intervalBuilderMoveUpTooltip => 'Move up';

  @override
  String get intervalBuilderMoveDownTooltip => 'Move down';

  @override
  String get intervalBuilderRemoveTooltip => 'Remove';

  @override
  String get intervalBuilderAddToRepeat => 'Add to repeat';

  @override
  String get intervalBuilderRepeatGroupSubtitle => 'Group several steps and run them N times';

  @override
  String get intervalBuilderRepeatLabel => 'Repeat';

  @override
  String get intervalBuilderTimesLabel => 'times';

  @override
  String get intervalBuilderTargetTypeLabel => 'Target type';

  @override
  String get intervalBuilderFieldDuration => 'Duration';

  @override
  String get intervalBuilderFieldDistanceM => 'Distance (m)';

  @override
  String get intervalBuilderFieldHrZone => 'HR zone (1..5)';

  @override
  String get intervalBuilderFieldPaceZone => 'Pace zone (1..5)';

  @override
  String get intervalBuilderFieldPowerZone => 'Power zone (1..5)';

  @override
  String get intervalBuilderFieldFreeform => 'Target (free text)';

  @override
  String get intervalBuilderErrorMmSs => 'Use MM:SS';

  @override
  String get intervalBuilderErrorMeters => 'Enter meters';

  @override
  String get intervalBuilderErrorZoneRange => '1..5';

  @override
  String get intervalBuilderEmptyTitle => 'No intervals yet';

  @override
  String get intervalBuilderEmptySubtitle =>
      'A structured plan looks like warm-up → work → recovery → cooldown. Start with a warm-up.';

  @override
  String get intervalBuilderAddWarmUp => 'Add warm-up';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarShowLegendTooltip => 'Show legend';

  @override
  String get calendarNoActiveCycleTitle => 'No active training cycle';

  @override
  String get calendarNoActiveCycleSubtitle => 'Start a training cycle to see your workouts on the calendar';

  @override
  String calendarPeriodDayLabel(Object period, Object day) {
    return 'P${period}D$day';
  }

  @override
  String calendarMuscleGroupSets(Object muscleGroup, Object setCount) {
    return '$muscleGroup • $setCount sets';
  }

  @override
  String calendarMoreExercises(Object count) {
    return '+$count more';
  }

  @override
  String get calendarRestDay => 'Rest Day';

  @override
  String get calendarEditButton => 'Edit';

  @override
  String get calendarNoSessionScheduled => 'No session scheduled';

  @override
  String get calendarStatusCompleted => 'Completed';

  @override
  String get calendarStatusInProgress => 'In Progress';

  @override
  String get calendarStatusRecovery => 'Recovery';

  @override
  String get calendarStatusScheduled => 'Scheduled';

  @override
  String calendarPeriodDayInfo(Object period, Object day) {
    return 'Period $period, Day $day';
  }

  @override
  String calendarPeriodDayRecovery(Object period, Object day) {
    return 'Period $period, Day $day (Recovery)';
  }

  @override
  String calendarExercisesMuscleGroups(Object count, Object muscleGroups) {
    return '$count exercises • $muscleGroups';
  }

  @override
  String get calendarViewButton => 'View';

  @override
  String get calendarGoToWorkoutButton => 'Go to Workout';

  @override
  String calendarCardioSessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cardio sessions',
      one: '1 cardio session',
    );
    return '$_temp0';
  }

  @override
  String get calendarViewDayButton => 'View Day';

  @override
  String get calendarSessionStatusDone => 'Done';

  @override
  String get calendarSessionStatusSkipped => 'Skipped';

  @override
  String get calendarSessionStatusPlanned => 'Planned';

  @override
  String calendarMovedExercise(Object exerciseName, Object date) {
    return 'Moved $exerciseName to $date';
  }

  @override
  String calendarMovedCardio(Object sessionLabel, Object date) {
    return 'Moved $sessionLabel to $date';
  }

  @override
  String calendarFailedToMove(Object error) {
    return 'Failed to move: $error';
  }

  @override
  String calendarFailedToReorder(Object error) {
    return 'Failed to reorder exercise: $error';
  }

  @override
  String calendarRestDayInserted(Object period, Object day) {
    return 'Rest day inserted before P${period}D$day';
  }

  @override
  String calendarFailedToInsertDay(Object error) {
    return 'Failed to insert day: $error';
  }

  @override
  String calendarRestDayRemoved(Object date) {
    return 'Rest day removed on $date';
  }

  @override
  String calendarFailedToRemoveRestDay(Object error) {
    return 'Failed to remove rest day: $error';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSaveButton => 'Save';

  @override
  String get settingsSavedMessage => 'Settings saved';

  @override
  String get settingsUnitsHeader => 'Units';

  @override
  String get settingsImperialLabel => 'Imperial (lbs)';

  @override
  String get settingsMetricLabel => 'Metric (kg)';

  @override
  String get settingsLanguageHeader => 'Language';

  @override
  String get settingsLanguageDescription => 'Choose the display language for the app';

  @override
  String get settingsBodyMeasurementsHeader => 'Body Measurements';

  @override
  String get settingsBodyMeasurementsDesc => 'Update your measurements to track BMI over time';

  @override
  String get settingsCurrentBmi => 'Current BMI';

  @override
  String get settingsBmiGuidelines => 'BMI categories based on WHO guidelines';

  @override
  String get settingsTerminologyHeader => 'Training Cycle Terminology';

  @override
  String get settingsTerminologyDesc => 'Choose the term you prefer for your trainingCycles';

  @override
  String get settingsSportsHeader => 'Sports I train';

  @override
  String get settingsSportsDesc =>
      'Pick the sports you want to log. The Workout tab\'s \"Add session\" grid only shows these.';

  @override
  String get settingsSportsMinimumWarning => 'At least one sport is required.';

  @override
  String get integrationsTitle => 'Integrations';

  @override
  String get integrationsHealthPermissionsGranted => 'Health permissions granted';

  @override
  String get integrationsHealthConnectRequired => 'Health Connect Required';

  @override
  String get integrationsHealthConnectIntro =>
      'To sync workouts from Health Connect and Peloton, please follow these steps:';

  @override
  String get integrationsHealthConnectStep1 =>
      '1. Download and install Health Connect from the Google Play Store (Android 14+ has it built in).';

  @override
  String get integrationsHealthConnectStep2 => '2. Open Health Connect and go to App permissions.';

  @override
  String get integrationsHealthConnectStep3 =>
      '3. Find Yawa4u in the list and allow access to Exercise sessions, Heart rate, Distance, and Active energy burned.';

  @override
  String get integrationsHealthConnectStep4 => '4. Return here and tap \"Grant permissions\" again.';

  @override
  String get integrationsGotIt => 'GOT IT';

  @override
  String integrationsHealthSyncSuccess(
    Object totalPoints,
    Object imported,
    Object skippedDuplicate,
    Object skippedUnsupported,
  ) {
    return 'Found $totalPoints records · +$imported imported · $skippedDuplicate duplicate · $skippedUnsupported unsupported';
  }

  @override
  String integrationsHealthSyncFailed(Object error) {
    return 'Sync failed: $error';
  }

  @override
  String get integrationsResetCursorMessage => 'Next sync will look back 3 months.';

  @override
  String get integrationsHealthDiagnosticsTitle => 'Health Diagnostics';

  @override
  String get integrationsStravaTitle => 'Strava';

  @override
  String get integrationsStravaUnconfiguredMessage =>
      'Strava requires client credentials at build time. See the README or the Bucket 3 hand-off doc for setup steps.';

  @override
  String get integrationsStravaDescription =>
      'Pull activities from Strava — runs, rides, swims import with distance, duration, HR, and elevation.';

  @override
  String integrationsLastSync(Object timestamp) {
    return 'Last sync: $timestamp';
  }

  @override
  String get integrationsStravaConnected => 'Connected to Strava';

  @override
  String get integrationsStravaConnectFailed => 'Could not connect to Strava';

  @override
  String integrationsStravaSyncSuccess(Object imported, Object skippedDuplicate, Object skippedUnsupported) {
    return 'Imported $imported · $skippedDuplicate duplicate · $skippedUnsupported unsupported';
  }

  @override
  String integrationsStravaSyncFailed(Object error) {
    return 'Sync failed: $error';
  }

  @override
  String get integrationsConnectToStrava => 'Connect to Strava';

  @override
  String get integrationsSyncNow => 'Sync now';

  @override
  String get integrationsDisconnect => 'Disconnect';

  @override
  String get integrationsStatusUnconfigured => 'Unconfigured';

  @override
  String get integrationsStatusConnected => 'Connected';

  @override
  String get integrationsStatusNotConnected => 'Not connected';

  @override
  String get integrationsStatusSyncing => 'Syncing…';

  @override
  String get integrationsStatusError => 'Error';

  @override
  String get integrationsStatusUnavailable => 'Unavailable';

  @override
  String integrationsHealthDescSupported(Object providerName) {
    return 'Pull completed workouts (runs, rides, swims) from $providerName so they join your training history.';
  }

  @override
  String get integrationsHealthDescUnsupported => 'This integration is only available on iOS and Android devices.';

  @override
  String get integrationsGrantPermissions => 'Grant permissions';

  @override
  String get integrationsResetCursor => 'Reset cursor';

  @override
  String get integrationsDiagnostics => 'Diagnostics';

  @override
  String get integrationsPelotonTitle => 'Peloton comes through here';

  @override
  String integrationsPelotonDescription(Object providerName) {
    return 'Peloton is paired inside the Peloton app — not $providerName.\nOpen Peloton → Profile / Settings → look for a $providerName toggle and turn it on. Your rides, runs, and treads will then flow into the Health card above, and YAWA4U picks them up on the next sync. No separate Peloton login needed here.';
  }

  @override
  String get integrationsFutureTitle => 'More integrations coming';

  @override
  String get integrationsFutureDescription => 'Garmin Connect and Wahoo are on the roadmap.';

  @override
  String get integrationsTimeJustNow => 'just now';

  @override
  String integrationsTimeMinutesAgo(Object minutes) {
    return '${minutes}m ago';
  }

  @override
  String integrationsTimeHoursAgo(Object hours) {
    return '${hours}h ago';
  }

  @override
  String integrationsTimeDaysAgo(Object days) {
    return '${days}d ago';
  }

  @override
  String get themeEditorEditTitle => 'Edit Theme';

  @override
  String get themeEditorCreateTitle => 'Create Theme';

  @override
  String themeEditorErrorLoading(Object error) {
    return 'Error loading theme: $error';
  }

  @override
  String themeEditorErrorPicking(Object error) {
    return 'Error picking image: $error';
  }

  @override
  String get themeEditorNameRequired => 'Please enter a theme name';

  @override
  String get themeEditorUpdated => 'Theme updated!';

  @override
  String get themeEditorCreated => 'Theme created!';

  @override
  String themeEditorErrorSaving(Object error) {
    return 'Error saving theme: $error';
  }

  @override
  String get themeEditorStepInfo => 'Info';

  @override
  String get themeEditorStepBackgrounds => 'Backgrounds';

  @override
  String get themeEditorStepIcon => 'Icon';

  @override
  String get themeEditorStepColors => 'Colors';

  @override
  String get themeEditorThemeInfoTitle => 'Theme Info';

  @override
  String get themeEditorThemeInfoDesc => 'Give your theme a name and description.';

  @override
  String get themeEditorNameLabel => 'Theme Name';

  @override
  String get themeEditorNameHint => 'My Custom Theme';

  @override
  String get themeEditorDescriptionLabel => 'Description (optional)';

  @override
  String get themeEditorDescriptionHint => 'A brief description of your theme';

  @override
  String get themeEditorBackgroundsTitle => 'Screen Backgrounds';

  @override
  String get themeEditorBackgroundsDesc =>
      'Choose background images for each screen. Tap to add, long press to remove.';

  @override
  String get themeEditorWorkoutScreen => 'Workout Screen';

  @override
  String get themeEditorMesocyclesScreen => 'Mesocycles Screen';

  @override
  String get themeEditorExercisesScreen => 'Exercises Screen';

  @override
  String get themeEditorMoreScreen => 'More Screen';

  @override
  String get themeEditorDefaultScreen => 'Default (Calendar & Others)';

  @override
  String get themeEditorImageHasImage => 'Tap to change, hold to remove';

  @override
  String get themeEditorImageNoImage => 'Tap to add image';

  @override
  String get themeEditorAppIconTitle => 'App Icon';

  @override
  String get themeEditorAppIconDesc => 'Choose an image to use as your app\'s accent icon (displayed in the app bar).';

  @override
  String get themeEditorTapToAdd => 'Tap to add';

  @override
  String get themeEditorRemove => 'Remove';

  @override
  String get themeEditorAccentColorsTitle => 'Accent Colors';

  @override
  String get themeEditorAccentColorsDesc => 'Choose your theme\'s primary and secondary colors.';

  @override
  String get themeEditorSuggestedColors => 'Suggested from your images:';

  @override
  String get themeEditorColorTooltip => 'Tap: Primary\nDouble-tap: Secondary';

  @override
  String get themeEditorPrimaryColor => 'Primary Color';

  @override
  String get themeEditorSecondaryColor => 'Secondary Color';

  @override
  String get themeEditorPreview => 'Preview';

  @override
  String get themeEditorThemeNameFallback => 'Theme Name';

  @override
  String get themeEditorCustomTheme => 'Custom Theme';

  @override
  String get themeEditorPrimaryButton => 'Primary';

  @override
  String get themeEditorSecondaryButton => 'Secondary';

  @override
  String get themeEditorBackButton => 'Back';

  @override
  String get themeEditorNextButton => 'Next';

  @override
  String get themeEditorSaveThemeButton => 'Save Theme';

  @override
  String get themeEditorChooseFromGallery => 'Choose from Gallery';

  @override
  String get themeEditorTakePhoto => 'Take a Photo';

  @override
  String get skinShareTitle => 'Share Themes';

  @override
  String get skinShareServerError => 'Could not start share server. Make sure you are connected to WiFi.';

  @override
  String get skinShareConnectionError =>
      'Could not connect to device. Make sure both devices are on the same WiFi network and you are scanning a valid theme share QR code.';

  @override
  String get skinShareNoCustomThemes => 'No custom themes to share';

  @override
  String get skinShareCreateThemeHint => 'Create a custom theme in Theme Settings to share it.';

  @override
  String get skinShareOrReceiveTitle => 'Share or Receive Themes';

  @override
  String get skinShareOrReceiveDesc =>
      'Select themes to share, or scan a QR code to receive themes from another device.';

  @override
  String get skinShareScanQrButton => 'Scan QR Code to Receive Themes';

  @override
  String get skinShareSelectThemesHeader => 'Select Themes to Share';

  @override
  String get skinShareDeselectAll => 'Deselect All';

  @override
  String get skinShareSelectAll => 'Select All';

  @override
  String get skinShareSelectToShare => 'Select Themes to Share';

  @override
  String get skinShareViaQrCode => 'Share via QR Code';

  @override
  String get skinShareUploadToCloud => 'Upload to Cloud';

  @override
  String get skinShareReadyTitle => 'Ready to Share';

  @override
  String get skinShareScanPrompt => 'Ask the other person to scan this QR code';

  @override
  String skinShareSharingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sharing $count Themes',
      one: 'Sharing 1 Theme',
    );
    return '$_temp0';
  }

  @override
  String get skinShareSharingNote => 'When scanned, these themes will be copied to the other device.';

  @override
  String get skinShareScannerPrompt => 'Point camera at theme share QR code';

  @override
  String get skinShareCameraError => 'Camera Error';

  @override
  String get skinShareCameraAccessFailed => 'Could not access camera';

  @override
  String get skinShareGoBack => 'Go Back';

  @override
  String get skinShareConnectedTo => 'Connected to';

  @override
  String skinShareThemesAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Themes Available',
      one: '1 Theme Available',
    );
    return '$_temp0';
  }

  @override
  String get skinShareThemesToReceive => 'Themes to Receive:';

  @override
  String skinShareReceiveButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Receive $count Themes',
      one: 'Receive 1 Theme',
    );
    return '$_temp0';
  }

  @override
  String get skinShareThemesReceived => 'Themes received!';

  @override
  String get skinShareReceiveFailed => 'Failed to receive themes';

  @override
  String get templateShareTitle => 'Share Templates';

  @override
  String get templateShareServerError => 'Could not start share server. Make sure you are connected to WiFi.';

  @override
  String get templateShareConnectionError =>
      'Could not connect to device. Make sure both devices are on the same WiFi network and you are scanning a valid template share QR code.';

  @override
  String get templateShareNoSavedTitle => 'No Saved Templates';

  @override
  String get templateShareNoSavedDesc =>
      'Save a Training Cycle as a template first, then you can share it here.\n\nTo save a template, go to a Training Cycle and use the \"Save as Template\" option.';

  @override
  String get templateShareScanQrButton => 'Scan QR Code to Receive Templates';

  @override
  String get templateShareOrReceiveTitle => 'Share or Receive Templates';

  @override
  String get templateShareOrReceiveDesc =>
      'Select templates to share, or scan a QR code to receive templates from another device.';

  @override
  String get templateShareSelectHeader => 'Select Templates to Share';

  @override
  String get templateShareDeselectAll => 'Deselect All';

  @override
  String get templateShareSelectAll => 'Select All';

  @override
  String get templateShareSelectToShare => 'Select Templates to Share';

  @override
  String get templateShareViaQrCode => 'Share via QR Code';

  @override
  String get templateShareUploadToCloud => 'Upload to Cloud';

  @override
  String templateShareDaysPerPeriod(Object count) {
    return '$count Days/Period';
  }

  @override
  String templateSharePeriodsCount(Object count) {
    return '$count Periods';
  }

  @override
  String templateShareWorkoutsCount(Object count) {
    return '$count Workouts';
  }

  @override
  String get templateShareReadyTitle => 'Ready to Share';

  @override
  String get templateShareScanPrompt => 'Ask the other person to scan this QR code';

  @override
  String templateShareSharingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sharing $count Templates',
      one: 'Sharing 1 Template',
    );
    return '$_temp0';
  }

  @override
  String get templateShareSharingNote => 'When scanned, these templates will be copied to the other device.';

  @override
  String get templateShareScannerPrompt => 'Point camera at template share QR code';

  @override
  String get templateShareCameraError => 'Camera Error';

  @override
  String get templateShareCameraAccessFailed => 'Could not access camera';

  @override
  String get templateShareGoBack => 'Go Back';

  @override
  String get templateShareConnectedTo => 'Connected to';

  @override
  String templateShareAvailableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Templates Available',
      one: '1 Template Available',
    );
    return '$_temp0';
  }

  @override
  String get templateShareToReceive => 'Templates to Receive:';

  @override
  String templateShareReceiveButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Receive $count Templates',
      one: 'Receive 1 Template',
    );
    return '$_temp0';
  }

  @override
  String get templateShareReceived => 'Templates received!';

  @override
  String get templateShareReceiveFailed => 'Failed to receive templates';

  @override
  String get syncTitle => 'Sync Data';

  @override
  String get syncServerError => 'Could not start sync server. Make sure you are connected to WiFi.';

  @override
  String get syncConnectionError => 'Could not connect to device. Make sure both devices are on the same WiFi network.';

  @override
  String get syncComplete => 'Sync complete!';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get syncFailedToLoad => 'Failed to load data';

  @override
  String get syncYourData => 'Your Data';

  @override
  String get syncStatTrainingCycles => 'TrainingCycles';

  @override
  String get syncStatSessions => 'Sessions';

  @override
  String get syncStatExercises => 'Exercises';

  @override
  String get syncWithAnotherDevice => 'Sync with another device';

  @override
  String get syncWifiRequired => 'Both devices must be on the same WiFi network.';

  @override
  String get syncHostButton => 'Host Sync (Show QR Code)';

  @override
  String get syncScanQrButton => 'Scan QR Code';

  @override
  String get syncWaitingForConnection => 'Waiting for connection...';

  @override
  String get syncScanFromOtherDevice => 'Scan this QR code from the other device';

  @override
  String get syncScannerPrompt => 'Point camera at QR code';

  @override
  String get syncCameraError => 'Camera Error';

  @override
  String get syncCameraAccessFailed => 'Could not access camera';

  @override
  String get syncGoBack => 'Go Back';

  @override
  String get pasteCodeButton => 'Enter Code Manually';

  @override
  String get pasteCodeDialogTitle => 'Enter Connection Code';

  @override
  String get pasteCodeDialogHint => 'Paste the code shown on the other device';

  @override
  String get pasteCodeDialogConfirm => 'Connect';

  @override
  String get syncConnectedTo => 'Connected to';

  @override
  String get syncWhatToDo => 'What would you like to do?';

  @override
  String syncImportFrom(Object deviceName) {
    return 'Import from $deviceName';
  }

  @override
  String syncExportTo(Object deviceName) {
    return 'Export to $deviceName';
  }

  @override
  String get syncDisconnect => 'Disconnect';

  @override
  String get communityLibraryTitle => 'Community Library';

  @override
  String get communityTabPrograms => 'Programs';

  @override
  String get communityTabThemes => 'Themes';

  @override
  String get communityTabMyUploads => 'My Uploads';

  @override
  String get communityUploadTooltip => 'Upload';

  @override
  String get communityShareProgram => 'Share a Program';

  @override
  String get communityShareTheme => 'Share a Theme';

  @override
  String get communitySortBy => 'Sort by:';

  @override
  String get communitySortPopular => 'Popular';

  @override
  String get communitySortRecent => 'Recent';

  @override
  String get communityNoProgramsTitle => 'No programs shared yet';

  @override
  String get communityNoProgramsSubtitle => 'Be the first to share a program!';

  @override
  String get communityCouldNotLoadPrograms => 'Could not load community programs';

  @override
  String get communityNoThemesTitle => 'No themes shared yet';

  @override
  String get communityNoThemesSubtitle => 'Be the first to share a theme!';

  @override
  String get communityCouldNotLoadThemes => 'Could not load community themes';

  @override
  String get communitySignInToSeeUploads => 'Sign in to see your uploads';

  @override
  String get communityMyPrograms => 'My Programs';

  @override
  String get communityNoProgramsUploaded => 'No programs uploaded yet.';

  @override
  String get communityFailedToLoadPrograms => 'Failed to load your programs';

  @override
  String get communityMyThemes => 'My Themes';

  @override
  String get communityNoThemesUploaded => 'No themes uploaded yet.';

  @override
  String get communityFailedToLoadThemes => 'Failed to load your themes';

  @override
  String get communityDeleteProgramTitle => 'Delete Program?';

  @override
  String communityDeleteProgramContent(Object name) {
    return 'Remove \"$name\" from the community library? This cannot be undone.';
  }

  @override
  String get communityDeleteThemeTitle => 'Delete Theme?';

  @override
  String communityDeleteThemeContent(Object name) {
    return 'Remove \"$name\" from the community library? This cannot be undone.';
  }

  @override
  String communityItemDeleted(Object name) {
    return '\"$name\" deleted';
  }

  @override
  String communityFailedToDelete(Object error) {
    return 'Failed to delete: $error';
  }

  @override
  String communityDownloadCount(Object count) {
    return '$count downloads';
  }

  @override
  String get communityDeleteTooltip => 'Delete';

  @override
  String communityPeriodsCount(Object count) {
    return '$count Periods';
  }

  @override
  String communitySessionsCount(Object count) {
    return '$count Sessions';
  }

  @override
  String get communityColorPreview => 'Color Preview';

  @override
  String get communityNoColorData => 'No color data available';

  @override
  String get communityColorPreviewUnavailable => 'Color preview unavailable';

  @override
  String get communityInvalidThemeData => 'This theme has invalid data and cannot be downloaded';

  @override
  String communitySavedToThemes(Object name) {
    return '\"$name\" saved to your themes';
  }

  @override
  String communitySavedToPrograms(Object name) {
    return '\"$name\" saved to your programs';
  }

  @override
  String communityDownloadFailed(Object error) {
    return 'Download failed: $error';
  }

  @override
  String get communityDownloadThemeButton => 'DOWNLOAD THEME';

  @override
  String get communityDownloadProgramButton => 'DOWNLOAD PROGRAM';

  @override
  String get communitySavedButton => 'SAVED';

  @override
  String get communitySessionsHeader => 'Sessions';

  @override
  String get communityDurationLabel => 'Duration';

  @override
  String get communityPerPeriodLabel => 'Per Period';

  @override
  String get communityRecoveryLabel => 'Recovery';

  @override
  String communityDaysCount(Object count) {
    return '$count Days';
  }

  @override
  String communityPeriodNumber(Object number) {
    return 'Period $number';
  }

  @override
  String communityDayFallback(Object number) {
    return 'Day $number';
  }

  @override
  String communityCardioSession(Object sport) {
    return '$sport session';
  }

  @override
  String communityExerciseCount(Object count) {
    return '$count Exercises';
  }

  @override
  String communitySetsReps(Object sets, Object reps) {
    return '$sets sets × $reps';
  }

  @override
  String get uploadShareThemeTitle => 'Share a Theme';

  @override
  String get uploadShareProgramTitle => 'Share a Program';

  @override
  String get uploadSelectThemeDesc => 'Select a custom theme to share with the community.';

  @override
  String get uploadSelectProgramDesc => 'Select a program to share with the community.';

  @override
  String get uploadThemeLabel => 'Theme';

  @override
  String get uploadProgramLabel => 'Program';

  @override
  String get uploadNoCustomThemes => 'No custom themes to share.';

  @override
  String get uploadCreateCustomThemeHint => 'Create a custom theme in Settings first.';

  @override
  String get uploadNoSavedPrograms => 'No saved programs to share.';

  @override
  String get uploadDisplayNameLabel => 'Your Display Name';

  @override
  String get uploadDisplayNameHint => 'How others will see your name';

  @override
  String get uploadTagsLabel => 'Tags (optional)';

  @override
  String get uploadTemplateTagsHint => 'beginner, strength, 4-week';

  @override
  String get uploadThemeTagsHint => 'dark, minimal, colorful';

  @override
  String get uploadTemplateTagsHelper => 'Comma-separated tags to help others find your program';

  @override
  String get uploadThemeTagsHelper => 'Comma-separated tags to help others find your theme';

  @override
  String get uploadPublishThemeButton => 'PUBLISH THEME';

  @override
  String get uploadPublishProgramButton => 'PUBLISH PROGRAM';

  @override
  String get uploadEnterDisplayName => 'Please enter a display name';

  @override
  String get uploadNotSignedIn => 'Not signed in. Please try again.';

  @override
  String uploadPublishedToCommunity(Object name) {
    return '\"$name\" published to the community!';
  }

  @override
  String uploadFailed(Object error) {
    return 'Upload failed: $error';
  }

  @override
  String uploadErrorLoadingTemplates(Object error) {
    return 'Error loading templates: $error';
  }

  @override
  String uploadTemplateSummary(Object periods, Object days, Object sessions) {
    return '$periods periods, $days days/period, $sessions sessions';
  }

  @override
  String get moreScreenTitle => 'YAWA4U';

  @override
  String versionLabel(Object version) {
    return 'Version $version';
  }

  @override
  String get themeMode => 'Theme mode';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get sectionTraining => 'Training';

  @override
  String get sectionIntegrationsData => 'Integrations & data';

  @override
  String get sectionPreferences => 'Preferences';

  @override
  String get sectionHelpFeedback => 'Help & feedback';

  @override
  String get sectionAbout => 'About';

  @override
  String get sectionDeveloper => 'Developer';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeSubtitle => 'Choose your app theme';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get statisticsSubtitle => 'Volume, records, and progress';

  @override
  String get unitsTitle => 'Units';

  @override
  String get unitsSubtitle => 'Metric or imperial — per sport';

  @override
  String get zonesTitle => 'Zones';

  @override
  String get zonesSubtitle => 'Heart-rate zones per sport';

  @override
  String get integrationsSubtitle => 'Apple Health / Health Connect — includes Peloton';

  @override
  String get syncDataTitle => 'Sync data';

  @override
  String get syncDataSubtitle => 'Sync with another device via WiFi';

  @override
  String get shareTemplateTitle => 'Share template';

  @override
  String get shareTemplateSubtitle => 'Share workout templates via WiFi';

  @override
  String get shareAppTitle => 'Share app';

  @override
  String get shareAppSubtitle => 'Share YAWA4U with friends';

  @override
  String get shareAppText => 'Check out YAWA4U - The best workout tracker! https://testflight.apple.com/join/YVQsRjzD';

  @override
  String get settingsSubtitle => 'Terminology, equipment, body metrics';

  @override
  String get sendFeedbackTitle => 'Send feedback';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSheetTitle => 'Language';

  @override
  String get languageSheetSubtitle => 'Choose the display language for the app';

  @override
  String get websiteTitle => 'Website';

  @override
  String get privacyPolicyTitle => 'Privacy policy';

  @override
  String get sentryDebugTitle => 'Sentry debug';

  @override
  String get sentryDebugSubtitle => 'Test Sentry integration';

  @override
  String get exercisesTitle => 'Exercises';

  @override
  String get exercisesNoActiveCycleTitle => 'No Active TrainingCycle';

  @override
  String get exercisesNoActiveCycleSubtitle => 'Create and start a trainingCycle to begin';

  @override
  String get exercisesNoScheduledTitle => 'No exercises scheduled';

  @override
  String exercisesNoScheduledSubtitleForDay(Object period, Object day) {
    return 'Add exercises for Period $period, Day $day';
  }

  @override
  String get exercisesNoScheduledSubtitle => 'Add exercises for this day';

  @override
  String get exercisesAddExercise => 'Add Exercise';

  @override
  String exercisesPeriodDayHeader(Object period, Object day) {
    return 'PERIOD $period DAY $day';
  }

  @override
  String exercisesPeriodDayHeaderWithName(Object period, Object day, Object dayName) {
    return 'PERIOD $period DAY $day $dayName';
  }

  @override
  String get exercisesSelectDayTooltip => 'Select day';

  @override
  String get exercisesToggleHistoryTooltip => 'Toggle history';

  @override
  String get exercisesMenuNote => 'Note';

  @override
  String get exercisesMenuSummary => 'Summary';

  @override
  String get exercisesMenuWorkoutHeader => 'WORKOUT';

  @override
  String get exercisesMenuAddExercise => 'Add exercise';

  @override
  String get exercisesMenuReset => 'Reset';

  @override
  String get exercisesFinishWorkout => 'FINISH WORKOUT';

  @override
  String get exercisesResetTitle => 'Reset Workout';

  @override
  String get exercisesResetContent =>
      'This will clear all logged sets and entered data for this workout. This cannot be undone.';

  @override
  String get exercisesResetAction => 'RESET';

  @override
  String get exercisesWorkoutReset => 'Workout reset';

  @override
  String get exercisesHistoryHeader => 'History';

  @override
  String get exercisesUnknownCycle => 'Unknown TrainingCycle';

  @override
  String exercisesCycleHistoryHeader(Object name, Object periods) {
    return '$name - $periods PERIODS';
  }

  @override
  String get exercisesDeloadLabel => 'DELOAD';

  @override
  String get exercisesUnknownDate => 'Unknown date';

  @override
  String get exercisesHistoryPeriodLabel => 'PERIOD ';

  @override
  String get exercisesHistoryDayLabel => ' - DAY ';

  @override
  String get exercisesBodyweightAbbrev => 'BW';

  @override
  String exercisesCycleCompletedTitle(Object cycleTerm) {
    return '$cycleTerm Completed!';
  }

  @override
  String exercisesCycleCompletedContent(Object cycleTerm) {
    return 'Congratulations! You have finished all workouts in this $cycleTerm.';
  }

  @override
  String get exercisesAwesome => 'AWESOME';

  @override
  String exercisesCycleNoteTitle(Object cycleTerm) {
    return '$cycleTerm Note';
  }

  @override
  String exercisesCycleNoteHint(Object cycleTerm) {
    return 'Enter note for this $cycleTerm...';
  }

  @override
  String exercisesErrorSavingNote(Object error) {
    return 'Error saving note: $error';
  }

  @override
  String get exercisesWeightUnitLbs => 'lbs';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsTabOverview => 'Overview';

  @override
  String get statsTabCardio => 'Cardio';

  @override
  String get statsTabCompare => 'Compare';

  @override
  String get statsTabBody => 'Body';

  @override
  String get statsNoCardioTitle => 'No cardio logged yet';

  @override
  String get statsNoCardioSubtitle =>
      'Log a run, bike, or swim from the More tab — stats will show up here once you have a session or two on record.';

  @override
  String get statsWeeklyVolume => 'Weekly volume — last 12 weeks';

  @override
  String get statsBySport => 'By sport';

  @override
  String get statsLifetimeTotals => 'Lifetime totals';

  @override
  String get statsCardioSessions => 'Sessions';

  @override
  String get statsCardioHours => 'Hours';

  @override
  String get statsCardioCompleted => 'Completed';

  @override
  String get statsNoMeasurementsTitle => 'No Measurements Yet';

  @override
  String get statsNoMeasurementsSubtitle => 'Add body measurements in Settings\nto see your progress here.';

  @override
  String get statsWeightLabel => 'Weight';

  @override
  String statsWeightValueKg(Object weight) {
    return '$weight kg';
  }

  @override
  String get statsBmiLabel => 'BMI';

  @override
  String get statsEntriesLabel => 'Entries';

  @override
  String get statsWeightProgression => 'Weight Progression';

  @override
  String get statsBodyComposition => 'Body Composition';

  @override
  String statsBodyFatEntry(Object fatPercent) {
    return '$fatPercent% body fat';
  }

  @override
  String statsBodyFatWithLean(Object fatPercent, Object leanMass) {
    return '$fatPercent% body fat / $leanMass kg lean';
  }

  @override
  String statsErrorLoadingMeasurements(Object error) {
    return 'Error loading measurements: $error';
  }

  @override
  String get statsVolumeByMuscleGroup => 'Volume by Muscle Group';

  @override
  String get statsVolumeProgression => 'Volume Progression';

  @override
  String get statsMostUsedExercises => 'Most Used Exercises';

  @override
  String get statsPersonalRecords => 'Personal Records';

  @override
  String get statsSessionsLabel => 'Sessions';

  @override
  String statsSessionsValue(Object completed, Object total) {
    return '$completed/$total';
  }

  @override
  String get statsCompletionLabel => 'Completion';

  @override
  String statsCompletionValue(Object percent) {
    return '$percent%';
  }

  @override
  String get statsTotalSetsLabel => 'Total Sets';

  @override
  String statsExerciseFrequencyCount(Object count) {
    return '${count}x';
  }

  @override
  String statsPersonalRecordWeight(Object weight) {
    return '$weight lbs';
  }

  @override
  String statsActiveCycleLabel(Object cycleName) {
    return '$cycleName (Active)';
  }

  @override
  String get restTimerDialogTitle => 'Rest Timer';

  @override
  String get restTimerUseDefault => 'Use default';

  @override
  String get restTimerBasedOnSetType => 'Based on set type';

  @override
  String get restTimerDuration => 'Duration';

  @override
  String addSessionPlanSport(Object sport) {
    return 'Plan $sport';
  }

  @override
  String get addSessionTitle => 'Add Session';

  @override
  String get selectMuscleGroupTitle => 'Select Muscle Group';

  @override
  String get startFromTemplate => 'Start from template';

  @override
  String planSportButton(Object sport) {
    return 'Plan $sport';
  }

  @override
  String sessionPlannedSnackbar(Object sport) {
    return '$sport session planned';
  }

  @override
  String failedToSave(Object error) {
    return 'Failed to save: $error';
  }

  @override
  String get createCustomExerciseTitle => 'Create Custom Exercise';

  @override
  String get exerciseNameLabel => 'Exercise Name';

  @override
  String get exerciseNameHint => 'e.g., Cable Chest Fly';

  @override
  String get exerciseNameRequired => 'Please enter an exercise name';

  @override
  String get exerciseNameMinLength => 'Name must be at least 3 characters';

  @override
  String get muscleGroupLabel => 'Muscle Group';

  @override
  String get secondaryMuscleGroupLabel => 'Secondary Muscle Group (Optional)';

  @override
  String get secondaryMuscleGroupNone => 'None';

  @override
  String get equipmentTypeLabel => 'Equipment Type';

  @override
  String get restTimerOptionalLabel => 'Rest Timer (Optional)';

  @override
  String get restTimerHint => 'e.g., 90';

  @override
  String get restTimerSuffix => 'seconds';

  @override
  String get restTimerValidation => 'Enter a value between 0 and 600';

  @override
  String get exerciseNameExists => 'An exercise with this name already exists';

  @override
  String failedToCreateExercise(Object error) {
    return 'Failed to create exercise: $error';
  }

  @override
  String get creatingButton => 'Creating...';

  @override
  String get createButton => 'Create';

  @override
  String get jointPainLabel => 'Joint Pain';

  @override
  String get musclePumpLabel => 'Muscle Pump';

  @override
  String get workloadLabel => 'Workload';

  @override
  String get detailTab => 'Detail';

  @override
  String get historyTab => 'History';

  @override
  String get videoAvailable => 'Video Available';

  @override
  String get watchOnYouTube => 'Watch on YouTube';

  @override
  String get viewOnYouTube => 'View on YouTube';

  @override
  String get noVideoAvailable => 'No video available';

  @override
  String get notesLabel => 'Notes';

  @override
  String get noNotesAdded => 'No notes added yet.';

  @override
  String errorLoadingHistory(Object error) {
    return 'Error loading history: $error';
  }

  @override
  String get noHistoryYet => 'No history yet';

  @override
  String get noHistoryDescription => 'Complete sets to build your exercise history.';

  @override
  String get weightProgressionLabel => 'WEIGHT PROGRESSION';

  @override
  String get unknownTrainingCycle => 'Unknown TrainingCycle';

  @override
  String trainingCyclePeriodsHeader(Object name, Object count) {
    return '$name - $count PERIODS';
  }

  @override
  String get unknownDate => 'Unknown date';

  @override
  String get recoveryLabel => 'RECOVERY';

  @override
  String periodDayLabel(Object period, Object day) {
    return 'PERIOD $period - DAY $day';
  }

  @override
  String get bodyweightAbbrev => 'BW';

  @override
  String get setTypesTitle => 'Set Types';

  @override
  String get regularSetBadge => 'REG';

  @override
  String get trainingCycleNoteTitle => 'Training Cycle Note';

  @override
  String get workoutNoteTitle => 'Workout Note';

  @override
  String get exerciseNoteTitle => 'Exercise Note';

  @override
  String get sessionNoteTitle => 'Session Note';

  @override
  String get trainingCycleNoteHint => 'Enter note for this training cycle...';

  @override
  String get workoutNoteHint => 'Enter note for this workout...';

  @override
  String get exerciseNoteHint => 'Enter note for this exercise...';

  @override
  String get sessionNoteHint => 'Enter note for this session...';

  @override
  String get pinToExercise => 'Pin to Exercise';

  @override
  String get renameTitle => 'Rename';

  @override
  String get trainingCycleNameHint => 'TrainingCycle name';

  @override
  String get updateDayLabelTitle => 'Update day label';

  @override
  String get updateDayLabelDesc => 'You can apply a different weekday label to this day.';

  @override
  String get mondayLabel => 'Monday';

  @override
  String get tuesdayLabel => 'Tuesday';

  @override
  String get wednesdayLabel => 'Wednesday';

  @override
  String get thursdayLabel => 'Thursday';

  @override
  String get fridayLabel => 'Friday';

  @override
  String get saturdayLabel => 'Saturday';

  @override
  String get sundayLabel => 'Sunday';

  @override
  String get applyToAllDays => 'Apply to all days in this position';

  @override
  String get avgHrLabel => 'Avg HR';

  @override
  String get bpmSuffix => 'bpm';

  @override
  String get logSessionTooltip => 'Log session';

  @override
  String get logSessionTitle => 'Log session';

  @override
  String get cardioTargetLabel => 'TARGET';

  @override
  String get cardioNoTargetSet => 'No target set';

  @override
  String cardioIntervalsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count intervals',
      one: '1 interval',
    );
    return '$_temp0';
  }

  @override
  String get cardioCompletedStatus => 'Completed';

  @override
  String get cardioAddFeedback => 'Add feedback';

  @override
  String get cardioLogSession => 'Log session';

  @override
  String get cardioSessionSkipped => 'Session skipped';

  @override
  String get cardioSkippedFooter => 'Skipped';

  @override
  String get cardioSessionMenuHeader => 'SESSION';

  @override
  String get cardioNotesMenuItem => 'Notes';

  @override
  String get cardioMoveUpMenuItem => 'Move up';

  @override
  String get cardioMoveDownMenuItem => 'Move down';

  @override
  String get cardioReplaceMenuItem => 'Replace';

  @override
  String get cardioSkipSessionMenuItem => 'Skip session';

  @override
  String get cardioDeleteSessionMenuItem => 'Delete session';

  @override
  String get cardioDistanceMetric => 'Distance';

  @override
  String get cardioDurationMetric => 'Duration';

  @override
  String get cardioSwolfMetric => 'SWOLF';

  @override
  String get cardioPaceMetric => 'Pace';

  @override
  String get cardioAvgSpeedMetric => 'Avg speed';

  @override
  String cardioLapsFormat(Object count) {
    return '$count laps';
  }

  @override
  String get cardioPoolLabel => 'pool';

  @override
  String get cardioAvgLabel => 'avg';

  @override
  String get cardioMaxLabel => 'max';

  @override
  String cardioElevationGain(Object meters) {
    return '$meters m';
  }

  @override
  String cardioHrBpm(Object bpm) {
    return '$bpm bpm';
  }

  @override
  String cardioPowerWatts(Object watts) {
    return '$watts W';
  }

  @override
  String cardioRpeFormat(Object value) {
    return 'RPE $value';
  }

  @override
  String get distanceLabel => 'Distance';

  @override
  String get metersSuffix => 'm';

  @override
  String get yardsSuffix => 'yd';

  @override
  String get kilometersSuffix => 'km';

  @override
  String get milesSuffix => 'mi';

  @override
  String get durationLabel => 'Duration';

  @override
  String get durationHint => '00:30:00';

  @override
  String get durationFormatError => 'Use MM:SS or HH:MM:SS';

  @override
  String get insertColonTooltip => 'Insert colon';

  @override
  String get readyToTrain => 'Ready to train?';

  @override
  String get pickSportPrompt => 'Pick a sport to add today\'s session.';

  @override
  String addSportSessionSemantic(Object sport) {
    return 'Add a $sport session';
  }

  @override
  String get thisWeekTitle => 'This week';

  @override
  String get nothingLoggedYet => 'Nothing logged yet — your next session lands here.';

  @override
  String strengthSessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count strength sessions',
      one: '1 strength session',
    );
    return '$_temp0';
  }

  @override
  String get calendarLegendTitle => 'Calendar Legend';

  @override
  String get legendWorkoutStatus => 'Workout Status';

  @override
  String get legendCompleted => 'Completed';

  @override
  String get legendCompletedDesc => 'All sessions for the day are done';

  @override
  String get legendPartiallyCompleted => 'Partially Completed';

  @override
  String get legendPartiallyCompletedDesc => 'Some sessions are done';

  @override
  String get legendScheduled => 'Scheduled';

  @override
  String get legendScheduledDesc => 'Session day not yet completed';

  @override
  String get legendRecoveryPeriod => 'Recovery Period';

  @override
  String get legendRecoveryPeriodDesc => 'Deload/recovery day';

  @override
  String get legendIndicators => 'Indicators';

  @override
  String get legendPeriodDay => 'P#D#';

  @override
  String get legendPeriodDayDesc => 'Period and Day number (e.g., P2D3 = Period 2, Day 3)';

  @override
  String get legendColoredDots => 'Colored dots';

  @override
  String get legendColoredDotsDesc => 'Muscle groups being worked';

  @override
  String get legendBorderHighlight => 'Border highlight';

  @override
  String get legendBorderHighlightDesc => 'Today\'s date';

  @override
  String get legendSelectionBorder => 'Selection border';

  @override
  String get legendSelectionBorderDesc => 'Currently selected date';

  @override
  String get legendPeriodColors => 'Period Colors';

  @override
  String get legendPeriodColorsDesc => 'Each period has a distinct background tint to help visualize training blocks.';

  @override
  String get moveSessionTitle => 'Move Session';

  @override
  String moveFromLabel(Object period, Object day) {
    return 'From Period $period, Day $day';
  }

  @override
  String get moveToLabel => 'Move to:';

  @override
  String get periodDropdownLabel => 'Period';

  @override
  String get dayDropdownLabel => 'Day';

  @override
  String get moveModeLabel => 'Move mode:';

  @override
  String get shiftSubsequentTitle => 'Shift Subsequent';

  @override
  String get shiftSubsequentDesc => 'Move this session and shift all following sessions';

  @override
  String get swapTitle => 'Swap';

  @override
  String get swapDesc => 'Exchange with the session on the target date';

  @override
  String get singleTitle => 'Single';

  @override
  String get singleDesc => 'Move only this session (may create gaps)';

  @override
  String get moveButton => 'Move';

  @override
  String get moveUndoneSnackbar => 'Move undone';

  @override
  String undoWithDescription(Object description) {
    return 'Undo: $description';
  }

  @override
  String get undoLastChange => 'Undo: last change';

  @override
  String get undoNoRecentChanges => 'Undo Move (no recent changes)';

  @override
  String get editCalendarTitle => 'Edit Calendar';

  @override
  String get editCalendarRestDay => 'Rest Day';

  @override
  String editCalendarPeriodDay(Object period, Object day) {
    return 'Period $period, Day $day';
  }

  @override
  String get removeRestDayLabel => 'Remove Rest Day';

  @override
  String get removeRestDayDesc => 'Remove this rest day and shift all future workouts backward';

  @override
  String get insertDayBeforeLabel => 'Insert Day Before';

  @override
  String get insertDayBeforeDesc => 'Add a rest day here, shifting this and all future workouts forward';

  @override
  String get changeUndoneSnackbar => 'Change undone';

  @override
  String get statusDone => 'Done';

  @override
  String get statusSkipped => 'Skipped';

  @override
  String get statusPlanned => 'Planned';

  @override
  String setsProgress(Object completed, Object total) {
    return '$completed/$total';
  }

  @override
  String moreCount(Object count) {
    return '+$count more';
  }

  @override
  String get dropHere => 'Drop here';

  @override
  String exerciseCardWeightSuggestion(Object weight, Object unit) {
    return '↑ Try $weight $unit';
  }

  @override
  String get exerciseCardInfoTooltip => 'Exercise info';

  @override
  String exerciseCardOptionsSemantics(Object exerciseName) {
    return 'Exercise options for $exerciseName';
  }

  @override
  String get exerciseCardColumnWeight => 'WEIGHT';

  @override
  String get exerciseCardColumnReps => 'REPS';

  @override
  String get exerciseCardColumnLog => 'LOG';

  @override
  String get exerciseCardMenuExercise => 'EXERCISE';

  @override
  String get exerciseCardMenuNewNote => 'New note';

  @override
  String get exerciseCardMenuMoveUp => 'Move up';

  @override
  String get exerciseCardMenuMoveDown => 'Move down';

  @override
  String get exerciseCardMenuReplace => 'Replace';

  @override
  String get exerciseCardMenuJointPain => 'Joint pain';

  @override
  String exerciseCardMenuRestTimerValue(Object seconds) {
    return 'Rest: ${seconds}s';
  }

  @override
  String get exerciseCardMenuSetRestTimer => 'Set rest timer';

  @override
  String get exerciseCardMenuAddSet => 'Add set';

  @override
  String get exerciseCardMenuSkipSets => 'Skip sets';

  @override
  String get exerciseCardMenuDeleteExercise => 'Delete exercise';

  @override
  String exerciseCardWeightSemantics(Object setNumber) {
    return 'Weight for set $setNumber';
  }

  @override
  String exerciseCardRepsSemantics(Object setNumber) {
    return 'Reps for set $setNumber';
  }

  @override
  String exerciseCardRepsHintRir(Object rir) {
    return '$rir RIR';
  }

  @override
  String get exerciseCardRepsHint => 'RIR';

  @override
  String exerciseCardSetTypeSemantics(Object setTypeName) {
    return '$setTypeName set';
  }

  @override
  String exerciseCardLogSetSemantics(Object setNumber) {
    return 'Log set $setNumber';
  }

  @override
  String get exerciseCardSetMenuHeader => 'SET';

  @override
  String get exerciseCardSetMenuAddBelow => 'Add set below';

  @override
  String get exerciseCardSetMenuSkipSet => 'Skip set';

  @override
  String get exerciseCardSetMenuUnskipSet => 'Unskip set';

  @override
  String get exerciseCardSetMenuDeleteSet => 'Delete set';

  @override
  String get exerciseCardSetTypeHeader => 'SET TYPE';

  @override
  String get weeklyVolumeChartEmpty => 'No cardio in this range yet';

  @override
  String get cycleComparisonNeedTwo => 'Need at least 2 cycles to compare';

  @override
  String get cycleComparisonUnlockMessage => 'Complete a training cycle to unlock comparisons.';

  @override
  String get cycleComparisonCycleA => 'Cycle A';

  @override
  String get cycleComparisonCycleB => 'Cycle B';

  @override
  String get cycleComparisonSelectPrompt => 'Select two cycles to compare';

  @override
  String get cycleComparisonCompletion => 'Completion';

  @override
  String get cycleComparisonTotalSets => 'Total Sets';

  @override
  String get cycleComparisonWorkouts => 'Workouts';

  @override
  String get cycleComparisonSetsByMuscle => 'Sets by Muscle Group';

  @override
  String get cycleComparisonPrChanges => 'Personal Record Changes';

  @override
  String cycleComparisonPrSubtitle(Object weightA, Object weightB) {
    return '$weightA → $weightB lbs';
  }

  @override
  String get volumeBarChartNoData => 'No data yet';

  @override
  String get volumeLineChartNoData => 'No volume data yet';

  @override
  String get weightChartNoMeasurements => 'No measurements yet';

  @override
  String get weightChartNeedTwo => 'Need at least 2 measurements to show a chart';

  @override
  String get emailLinkVerificationSent => 'Verification email sent';

  @override
  String get emailLinkSignInTitle => 'Sign In';

  @override
  String get emailLinkVerifyTitle => 'Verify to Upload';

  @override
  String get emailLinkSignInDesc => 'Sign in with the email and password you used on your other device.';

  @override
  String get emailLinkVerifyDesc =>
      'Link an email to your account to share content with the community. Your anonymous data is preserved.';

  @override
  String get emailLinkEmailLabel => 'Email';

  @override
  String get emailLinkPasswordLabel => 'Password';

  @override
  String get emailLinkEmailEmpty => 'Enter your email';

  @override
  String get emailLinkEmailInvalid => 'Enter a valid email';

  @override
  String get emailLinkPasswordShort => 'Password must be at least 6 characters';

  @override
  String get emailLinkSignInButton => 'SIGN IN';

  @override
  String get emailLinkLinkAndVerify => 'LINK EMAIL & VERIFY';

  @override
  String get emailLinkCreateAccount => 'CREATE NEW ACCOUNT';

  @override
  String get emailLinkSignInExisting => 'SIGN IN WITH EXISTING ACCOUNT';

  @override
  String get emailLinkCheckInboxTitle => 'Check Your Inbox';

  @override
  String get emailLinkCheckInboxDesc =>
      'We sent a verification email. Open the link in the email, then come back here and tap the button below.';

  @override
  String get emailLinkNotYetVerified => 'Email not yet verified. Check your inbox and spam folder.';

  @override
  String get emailLinkVerifiedButton => 'I\'VE VERIFIED MY EMAIL';

  @override
  String get emailLinkResendButton => 'RESEND VERIFICATION EMAIL';

  @override
  String userErrorCouldnt(Object context, Object message) {
    return 'Couldn\'\'t $context — $message';
  }

  @override
  String get userErrorNetwork => 'Check your connection and try again.';

  @override
  String get userErrorBadState => 'Something got into a bad state. Try again.';

  @override
  String get userErrorPermission => 'Permission was denied. Open Settings to grant access.';

  @override
  String get userErrorConflict => 'That change conflicts with existing data.';

  @override
  String get userErrorNotFound => 'Not found — it may have been deleted.';

  @override
  String get userErrorGeneric => 'Something went wrong. Try again in a moment.';

  @override
  String get setTypeDialogTitle => 'Set types';

  @override
  String get setTypeDialogDescription => 'Keep track of how you performed your sets by specifying a type:';

  @override
  String get regularSetDefinition =>
      'Regular: perform sets normally by hitting rep target or week over week RIR target';

  @override
  String get myorepSetDefinition =>
      'Myoreps: take 5-15 second pauses between mini-sets of reps to hit rep target or week over week RIR target. Log total reps.';

  @override
  String get myorepMatchSetDefinition =>
      'Myorep match: take 5-15 second pauses between mini-sets of reps to match reps from your first set. Log total reps.';

  @override
  String get jointPainTitle => 'JOINT PAIN';

  @override
  String get musclePumpTitle => 'MUSCLE PUMP';

  @override
  String get workloadTitle => 'WORKLOAD';

  @override
  String get sorenessTitle => 'SORENESS';

  @override
  String jointPainQuestion(Object exerciseName) {
    return 'How did your joints feel during $exerciseName?';
  }

  @override
  String musclePumpQuestion(Object muscleGroup) {
    return 'How much of a pump did you get today in your $muscleGroup?';
  }

  @override
  String workloadQuestion(Object muscleGroup) {
    return 'How would you rate the difficulty of the work you did for your $muscleGroup?';
  }

  @override
  String sorenessQuestion(Object muscleGroup) {
    return 'How sore did you get in your $muscleGroup AFTER training it LAST TIME?';
  }

  @override
  String get draftBannerText => 'CONTINUE EDITING DRAFT TRAINING CYCLE';

  @override
  String get noExercisesTitle => 'No exercises';

  @override
  String get noExercisesMessage => 'Your custom exercises will appear here.';

  @override
  String get noPinnedNotesTitle => 'No pinned notes';

  @override
  String get noPinnedNotesMessage => 'Your pinned exercise notes will appear here.';

  @override
  String get navWorkout => 'Workout';

  @override
  String get navTrainingCycles => 'TrainingCycles';

  @override
  String get navExercisesConst => 'Exercises';

  @override
  String get navMoreConst => 'More';

  @override
  String get menuTemplates => 'Templates';

  @override
  String get menuDarkTheme => 'Dark Theme';

  @override
  String get menuExportData => 'Export Data';

  @override
  String get menuImportData => 'Import Data';

  @override
  String get menuShareData => 'Share Data';

  @override
  String get menuHelp => 'Help';

  @override
  String get menuLeaveReview => 'Leave a review';

  @override
  String get localeSystem => 'System';

  @override
  String get localeEnglish => 'English';

  @override
  String get sportPickerTitle => 'Add a session';

  @override
  String get sportPickerSubtitle => 'Which sport is this session?';

  @override
  String get cardioTemplatePickerTitle => 'Start from a template';

  @override
  String get cardioTemplatePickerSubtitle =>
      'Pick a pre-built session to start from. You can edit the intervals before saving.';

  @override
  String cardioTemplatePickerLoadError(Object error) {
    return 'Could not load the library. $error';
  }

  @override
  String get cardioTemplatePickerNoTemplates => 'No templates for this sport yet.';

  @override
  String cardioTemplatePickerStepsCount(Object count) {
    return '$count steps';
  }

  @override
  String get routerErrorTitle => 'Error';

  @override
  String routerPageNotFound(Object location) {
    return 'Page not found: $location';
  }

  @override
  String get routerGoHome => 'Go Home';

  @override
  String cycleSummaryTitle(Object cycleTerm) {
    return '$cycleTerm summary';
  }

  @override
  String get cycleSummaryWorkoutsSection => 'Workouts';

  @override
  String get cycleSummaryCompleted => 'Completed';

  @override
  String get cycleSummarySkipped => 'Skipped';

  @override
  String get cycleSummaryIncomplete => 'Incomplete';

  @override
  String get cycleSummaryStatsSection => 'Stats';

  @override
  String get cycleSummaryMuscleGroups => 'Muscle groups';

  @override
  String get closeUpper => 'CLOSE';

  @override
  String get muscleGroupStatsTitle => 'Muscle group stats';

  @override
  String get muscleGroupStatsNoSessions => 'No sessions found for this training cycle.';

  @override
  String get muscleGroupStatsDeload => 'DL';

  @override
  String muscleGroupStatsPeriod(Object period) {
    return 'pd $period';
  }

  @override
  String muscleGroupStatsAvgSets(Object count) {
    return '$count avg sets';
  }

  @override
  String get skinSelectionTitle => 'Appearance';

  @override
  String get skinSelectionShare => 'Share';

  @override
  String get skinSelectionCurrentTheme => 'Current Theme';

  @override
  String get skinSelectionChooseTheme => 'Choose a Theme';

  @override
  String get skinSelectionCreate => 'Create';

  @override
  String get skinSelectionBrowseCommunity => 'Browse Community Library';

  @override
  String get skinSelectionBrowseCommunitySubtitle => 'Discover themes shared by other users';

  @override
  String get skinSelectionPremium => 'Premium';

  @override
  String get skinSelectionEditTheme => 'Edit Theme';

  @override
  String get skinSelectionShareTheme => 'Share Theme';

  @override
  String get skinSelectionDeleteTheme => 'Delete Theme';

  @override
  String get skinSelectionDeleteThemeTitle => 'Delete Theme?';

  @override
  String skinSelectionDeleteConfirm(Object name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get unitsResetButton => 'Reset';

  @override
  String get unitsDescription =>
      'Pick units per sport. A row you haven\'t touched follows the sensible default (run → miles, bike → km, swim → meters), falling back to your main metric / imperial setting.';

  @override
  String get unitsDefaultLabel => '(default)';

  @override
  String get unitsImperialLabel => 'Imperial';

  @override
  String get unitsMetricLabel => 'Metric';

  @override
  String unitsStrengthNote(Object system) {
    return 'Strength defaults to your main metric/imperial choice ($system) — change that in Settings → Profile.';
  }

  @override
  String zonesNoZones(Object sport) {
    return 'No zones set for $sport';
  }

  @override
  String get zonesNoZonesSubtitle =>
      'Start from the conventional five-zone split and tweak the numbers to your tested thresholds.';

  @override
  String get zonesSeedDefaults => 'Seed default zones';

  @override
  String get zonesClear => 'Clear';

  @override
  String get zonesHrDescription =>
      'Heart-rate zones in bpm. Tap a value to edit. Defaults are a sensible starting point — adjust to your tested thresholds.';

  @override
  String zonesZoneLabel(Object number) {
    return 'Zone $number';
  }

  @override
  String get zonesMinLabel => 'Min';

  @override
  String get zonesMaxLabel => 'Max';

  @override
  String get zonesBpmSuffix => 'bpm';

  @override
  String get zonesResetToDefaults => 'Reset to defaults';

  @override
  String zonesErrorLoading(Object error) {
    return 'Error loading zones: $error';
  }

  @override
  String get sentryDebugOnlyAvailable => 'Debug screen only available in debug builds';

  @override
  String get sentryRefreshTooltip => 'Refresh status';

  @override
  String get sentryTestMessage => 'Test Message';

  @override
  String get sentryTestException => 'Test Exception';

  @override
  String get sentryTestFeedback => 'Test Feedback';

  @override
  String get sentryTestCrash => 'Test Crash';

  @override
  String restTimerBannerSemantic(Object time) {
    return 'Rest timer: $time remaining';
  }

  @override
  String restTimerRestDisplay(Object time) {
    return 'Rest: $time';
  }

  @override
  String get restTimerResumeTooltip => 'Resume';

  @override
  String get restTimerPauseTooltip => 'Pause';

  @override
  String get restTimerAddTimeTooltip => 'Add 30 seconds';

  @override
  String get restTimerSkipTooltip => 'Skip rest';

  @override
  String get filterByAvailableEquipment => 'Filter by Available Equipment';

  @override
  String get onlyShowEquipmentExercises => 'Only show exercises for equipment you have';

  @override
  String get selectEquipmentAccess => 'Select equipment you have access to';

  @override
  String sportSummarySessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sessions',
      one: 'session',
    );
    return '$_temp0';
  }

  @override
  String sportSummaryBest(Object distance) {
    return 'Best $distance';
  }

  @override
  String weeklyVolumeChartTooltipSessions(Object count) {
    return '$count sessions';
  }

  @override
  String weeklyVolumeChartWeekOf(Object date) {
    return 'Wk of $date';
  }

  @override
  String volumeBarChartSetsTooltip(Object count) {
    return '$count sets';
  }

  @override
  String exerciseCardLastPerformance(Object summary, Object date) {
    return 'Last: $summary$date';
  }

  @override
  String get cardioCardTargetLabel => 'TARGET';

  @override
  String get cardioCardNoTarget => 'No target set';

  @override
  String cardioCardIntervalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count intervals',
      one: '1 interval',
    );
    return '$_temp0';
  }

  @override
  String get cardioCardPaceLabel => 'Pace';

  @override
  String get cardioCardAvgSpeedLabel => 'Avg speed';

  @override
  String get cardioCardSwolfLabel => 'SWOLF';

  @override
  String cardioCardLapsValue(Object count) {
    return '$count laps';
  }

  @override
  String get cardioCardPoolLabel => 'pool';

  @override
  String get cardioCardAvgHr => 'avg';

  @override
  String get cardioCardMaxHr => 'max';

  @override
  String get cardioCardAvgPower => 'avg';

  @override
  String get cardioCardElevationGain => '▲';

  @override
  String get cardioCardAddFeedback => 'Add feedback';

  @override
  String get cardioCardLogSession => 'Log session';

  @override
  String get cardioCardMenuNotes => 'Notes';

  @override
  String get cardioCardMenuMoveUp => 'Move up';

  @override
  String get cardioCardMenuMoveDown => 'Move down';

  @override
  String get cardioCardMenuReplace => 'Replace';

  @override
  String get cardioCardMenuSkipSession => 'Skip session';

  @override
  String get cardioCardMenuDeleteSession => 'Delete session';

  @override
  String get quickLogTooltip => 'Log session';

  @override
  String get quickLogTitle => 'Log session';

  @override
  String get thisWeekEmpty => 'Nothing logged yet — your next session lands here.';

  @override
  String thisWeekStrengthSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count strength sessions',
      one: '1 strength session',
    );
    return '$_temp0';
  }

  @override
  String thisWeekSportLine(Object count, Object sport, Object countSuffix) {
    return '$count $sport$countSuffix';
  }

  @override
  String sportSummarySessionLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sessions',
      one: 'session',
    );
    return '$_temp0';
  }

  @override
  String sportSummaryBestLabel(Object distance) {
    return 'Best $distance';
  }

  @override
  String weeklyVolumeChartTooltip(Object weekLabel, Object sessions, Object duration) {
    return '$weekLabel\n$sessions sessions • $duration';
  }

  @override
  String get volumeBarChartEmpty => 'No data yet';

  @override
  String get exerciseCardExerciseInfo => 'Exercise info';

  @override
  String exerciseCardOptionsLabel(Object name) {
    return 'Exercise options for $name';
  }

  @override
  String get exerciseCardWeightHeader => 'WEIGHT';

  @override
  String get exerciseCardRepsHeader => 'REPS';

  @override
  String get exerciseCardLogHeader => 'LOG';

  @override
  String exerciseCardWeightSemantic(Object number) {
    return 'Weight for set $number';
  }

  @override
  String exerciseCardRepsSemantic(Object number) {
    return 'Reps for set $number';
  }

  @override
  String exerciseCardLogSemantic(Object number) {
    return 'Log set $number';
  }

  @override
  String exerciseCardSetTypeSemantic(Object typeName) {
    return '$typeName set';
  }

  @override
  String get exerciseCardExerciseHeader => 'EXERCISE';

  @override
  String get exerciseCardNewNote => 'New note';

  @override
  String get exerciseCardMoveUp => 'Move up';

  @override
  String get exerciseCardMoveDown => 'Move down';

  @override
  String get exerciseCardReplace => 'Replace';

  @override
  String get exerciseCardJointPain => 'Joint pain';

  @override
  String exerciseCardRestTimerValue(Object seconds) {
    return 'Rest: ${seconds}s';
  }

  @override
  String get exerciseCardSetRestTimer => 'Set rest timer';

  @override
  String get exerciseCardAddSet => 'Add set';

  @override
  String get exerciseCardSkipSets => 'Skip sets';

  @override
  String get exerciseCardDeleteExercise => 'Delete exercise';

  @override
  String get exerciseCardSetHeader => 'SET';

  @override
  String get exerciseCardAddSetBelow => 'Add set below';

  @override
  String get exerciseCardSkipSet => 'Skip set';

  @override
  String get exerciseCardUnskipSet => 'Unskip set';

  @override
  String get exerciseCardDeleteSet => 'Delete set';

  @override
  String exerciseCardTryWeight(Object weight, Object unit) {
    return '↑ Try $weight $unit';
  }

  @override
  String get exerciseCardRirHint => 'RIR';

  @override
  String exerciseCardRirTargetHint(Object target) {
    return '$target RIR';
  }

  @override
  String get equipmentFilterTitle => 'Filter by Available Equipment';

  @override
  String get equipmentFilterSubtitle => 'Only show exercises for equipment you have';

  @override
  String get equipmentFilterSelectPrompt => 'Select equipment you have access to';

  @override
  String restTimerSemantic(Object time) {
    return 'Rest timer: $time remaining';
  }

  @override
  String restTimerDisplay(Object time) {
    return 'Rest: $time';
  }

  @override
  String get restTimerResume => 'Resume';

  @override
  String get restTimerPause => 'Pause';

  @override
  String get restTimerAdd30 => 'Add 30 seconds';

  @override
  String get restTimerSkip => 'Skip rest';

  @override
  String get cycleComparisonNeedTwoCycles => 'Need at least 2 cycles to compare';

  @override
  String get cycleComparisonUnlockHint => 'Complete a training cycle to unlock comparisons.';

  @override
  String get cycleComparisonPRChanges => 'Personal Record Changes';

  @override
  String cycleComparisonWeightChange(Object weightA, Object weightB) {
    return '$weightA → $weightB lbs';
  }

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authVerifyToUpload => 'Verify to Upload';

  @override
  String get authSignInBody => 'Sign in with the email and password you used on your other device.';

  @override
  String get authLinkEmailBody =>
      'Link an email to your account to share content with the community. Your anonymous data is preserved.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authEnterEmail => 'Enter your email';

  @override
  String get authEnterValidEmail => 'Enter a valid email';

  @override
  String get authPasswordMinLength => 'Password must be at least 6 characters';

  @override
  String get authSignInUpper => 'SIGN IN';

  @override
  String get authLinkEmailUpper => 'LINK EMAIL & VERIFY';

  @override
  String get authCreateNewAccount => 'CREATE NEW ACCOUNT';

  @override
  String get authSignInExisting => 'SIGN IN WITH EXISTING ACCOUNT';

  @override
  String get authCheckInbox => 'Check Your Inbox';

  @override
  String get authCheckInboxBody =>
      'We sent a verification email. Open the link in the email, then come back here and tap the button below.';

  @override
  String get authEmailNotVerified => 'Email not yet verified. Check your inbox and spam folder.';

  @override
  String get authVerifiedButton => 'I\'VE VERIFIED MY EMAIL';

  @override
  String get authResendEmail => 'RESEND VERIFICATION EMAIL';

  @override
  String get authVerificationSent => 'Verification email sent';
}
