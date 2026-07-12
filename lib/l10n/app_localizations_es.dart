// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'YAWA4U';

  @override
  String get cancel => 'Cancelar';

  @override
  String get cancelUpper => 'CANCELAR';

  @override
  String get save => 'Guardar';

  @override
  String get saveUpper => 'GUARDAR';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteUpper => 'ELIMINAR';

  @override
  String get close => 'Cerrar';

  @override
  String get retry => 'Reintentar';

  @override
  String get undo => 'Deshacer';

  @override
  String get continueButton => 'Continuar';

  @override
  String errorGeneric(Object error) {
    return 'Error: $error';
  }

  @override
  String get noteSaved => 'Nota guardada';

  @override
  String noteSaveError(Object error) {
    return 'Error al guardar la nota: $error';
  }

  @override
  String get toggleThemeTooltip => 'Cambiar tema';

  @override
  String get navSession => 'Sesión';

  @override
  String get navExercises => 'Ejercicios';

  @override
  String get navCalendar => 'Calendario';

  @override
  String get navMore => 'Más';

  @override
  String get trainingCycleStatusDraft => 'Borrador';

  @override
  String get trainingCycleStatusCurrent => 'Actual';

  @override
  String get trainingCycleStatusCompleted => 'Completado';

  @override
  String get workoutStatusIncomplete => 'Incompleto';

  @override
  String get workoutStatusCompleted => 'Completado';

  @override
  String get workoutStatusSkipped => 'Omitido';

  @override
  String get setTypeRegular => 'Normal';

  @override
  String get setTypeMyorep => 'Myorep';

  @override
  String get setTypeMyorepMatch => 'Myorep match';

  @override
  String get setTypeMaxReps => 'Máx. reps';

  @override
  String get setTypeEndWithPartials => 'Terminar con parciales';

  @override
  String get setTypeDropSet => 'Drop set';

  @override
  String get setTypeRegularDesc =>
      'realiza las series normalmente alcanzando el objetivo de repeticiones o el objetivo de RIR semana a semana';

  @override
  String get setTypeMyorepDesc =>
      'haz pausas de 5-15 segundos entre mini-series de repeticiones para alcanzar el objetivo de repeticiones o el objetivo de RIR semana a semana. Registra las repeticiones totales.';

  @override
  String get setTypeMyorepMatchDesc =>
      'haz pausas de 5-15 segundos entre mini-series de repeticiones para igualar las repeticiones de tu primera serie. Registra las repeticiones totales.';

  @override
  String get setTypeMaxRepsDesc => 'realiza tantas repeticiones como sea posible hasta el fallo';

  @override
  String get setTypeEndWithPartialsDesc =>
      'después de llegar al fallo, continúa con repeticiones parciales para fatigar aún más el músculo';

  @override
  String get setTypeDropSetDesc =>
      'reduce el peso de inmediato y continúa las repeticiones sin descanso para extender la serie';

  @override
  String get jointPainNone => 'NINGUNO';

  @override
  String get jointPainLow => 'DOLOR LEVE';

  @override
  String get jointPainModerate => 'DOLOR MODERADO';

  @override
  String get jointPainSevere => 'MUCHO DOLOR';

  @override
  String get musclePumpLow => 'BOMBEO BAJO';

  @override
  String get musclePumpModerate => 'BOMBEO MODERADO';

  @override
  String get musclePumpAmazing => 'BOMBEO INCREÍBLE';

  @override
  String get workloadEasy => 'FÁCIL';

  @override
  String get workloadPrettyGood => 'BASTANTE BIEN';

  @override
  String get workloadPushedLimits => 'AL LÍMITE';

  @override
  String get workloadTooMuch => 'DEMASIADO';

  @override
  String get sorenessNeverGotSore => 'NUNCA TUVE DOLOR';

  @override
  String get sorenessHealedAWhileAgo => 'SE RECUPERÓ HACE RATO';

  @override
  String get sorenessHealedJustOnTime => 'SE RECUPERÓ JUSTO A TIEMPO';

  @override
  String get sorenessStillSore => '¡AÚN TENGO DOLOR!';

  @override
  String get genderMale => 'HOMBRE';

  @override
  String get genderFemale => 'MUJER';

  @override
  String get recoveryPeriodTypeDeload => 'Descarga';

  @override
  String get recoveryPeriodTypeTaper => 'Afinamiento';

  @override
  String get recoveryPeriodTypeRecovery => 'Recuperación';

  @override
  String get recoveryPeriodTypeDeloadDesc => 'Reducir el peso manteniendo el volumen';

  @override
  String get recoveryPeriodTypeTaperDesc => 'Reducir el volumen manteniendo la intensidad';

  @override
  String get recoveryPeriodTypeRecoveryDesc => 'Entrenamiento ligero para favorecer la recuperación activa';

  @override
  String get trainingPhaseBase => 'Base';

  @override
  String get trainingPhaseBuild => 'Construcción';

  @override
  String get trainingPhasePeak => 'Pico';

  @override
  String get trainingPhaseTaper => 'Afinamiento';

  @override
  String get trainingPhaseTransition => 'Transición';

  @override
  String get trainingPhaseBaseDesc => 'Base aeróbica — alto volumen, baja intensidad';

  @override
  String get trainingPhaseBuildDesc => 'Construir condición física — volumen más intensidad dirigida';

  @override
  String get trainingPhasePeakDesc => 'Intensidad específica de competencia, volumen total reducido';

  @override
  String get trainingPhaseTaperDesc => 'Reducir el volumen drásticamente, manteniendo toques de intensidad';

  @override
  String get trainingPhaseTransitionDesc => 'Recuperación activa entre bloques de entrenamiento';

  @override
  String get unitSystemImperial => 'Imperial';

  @override
  String get unitSystemMetric => 'Métrico';

  @override
  String get muscleGroupChest => 'Pecho';

  @override
  String get muscleGroupTriceps => 'Tríceps';

  @override
  String get muscleGroupShoulders => 'Hombros';

  @override
  String get muscleGroupBack => 'Espalda';

  @override
  String get muscleGroupBiceps => 'Bíceps';

  @override
  String get muscleGroupQuads => 'Cuádriceps';

  @override
  String get muscleGroupHamstrings => 'Isquiotibiales';

  @override
  String get muscleGroupGlutes => 'Glúteos';

  @override
  String get muscleGroupCalves => 'Pantorrillas';

  @override
  String get muscleGroupTraps => 'Trapecios';

  @override
  String get muscleGroupForearms => 'Antebrazos';

  @override
  String get muscleGroupAbs => 'Abdominales';

  @override
  String get muscleGroupFullBody => 'Cuerpo completo';

  @override
  String get muscleGroupAdductors => 'Aductores';

  @override
  String get muscleGroupCore => 'Core';

  @override
  String get muscleGroupGrip => 'Agarre';

  @override
  String get muscleGroupObliques => 'Oblicuos';

  @override
  String get equipmentBarbell => 'Barra';

  @override
  String get equipmentBodyweightLoadable => 'Peso corporal con carga';

  @override
  String get equipmentBodyweightOnly => 'Solo peso corporal';

  @override
  String get equipmentCable => 'Polea';

  @override
  String get equipmentDumbbell => 'Mancuerna';

  @override
  String get equipmentFreemotion => 'Freemotion';

  @override
  String get equipmentKettlebell => 'Pesa rusa';

  @override
  String get equipmentMachine => 'Máquina';

  @override
  String get equipmentMachineAssistance => 'Máquina asistida';

  @override
  String get equipmentSmithMachine => 'Máquina Smith';

  @override
  String get equipmentBandAssistance => 'Banda asistida';

  @override
  String get sportStrength => 'Fuerza';

  @override
  String get sportRun => 'Correr';

  @override
  String get sportBike => 'Bici';

  @override
  String get sportSwim => 'Natación';

  @override
  String get sportOther => 'Otro';

  @override
  String get sessionSourcePlanned => 'Planificado';

  @override
  String get sessionSourceLogged => 'Registrado';

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
  String get sessionSourceImported => 'Importado';

  @override
  String get intervalIntentWarmup => 'Calentamiento';

  @override
  String get intervalIntentWork => 'Trabajo';

  @override
  String get intervalIntentRecovery => 'Recuperación';

  @override
  String get intervalIntentCooldown => 'Enfriamiento';

  @override
  String get intervalIntentRest => 'Descanso';

  @override
  String get intervalIntentRepeat => 'Repetir';

  @override
  String get intervalTargetDuration => 'Duración';

  @override
  String get intervalTargetDistance => 'Distancia';

  @override
  String get intervalTargetHrZone => 'Zona de FC';

  @override
  String get intervalTargetPaceZone => 'Zona de ritmo';

  @override
  String get intervalTargetPowerZone => 'Zona de potencia';

  @override
  String get intervalTargetFreeform => 'Libre';

  @override
  String get strokeTypeFreestyle => 'Estilo libre';

  @override
  String get strokeTypeBackstroke => 'Espalda';

  @override
  String get strokeTypeBreaststroke => 'Pecho';

  @override
  String get strokeTypeButterfly => 'Mariposa';

  @override
  String get strokeTypeMixed => 'Combinado';

  @override
  String get strokeTypeDrill => 'Técnica';

  @override
  String get onboardingSportsTitle => 'Tus deportes';

  @override
  String get onboardingSportsHeadline => '¿Qué deportes practicas?';

  @override
  String get onboardingSportsSubtitle => 'Elige todos los que apliquen. Puedes agregar más después en Ajustes.';

  @override
  String get sportDescriptionStrength => 'Levantamiento, hipertrofia, powerlifting';

  @override
  String get sportDescriptionRun => 'Correr, caminadora, trail';

  @override
  String get sportDescriptionBike => 'Ruta, rodillo, MTB, spinning (Peloton)';

  @override
  String get sportDescriptionSwim => 'Piscina o aguas abiertas';

  @override
  String get sportDescriptionOther => 'Otras actividades';

  @override
  String get onboardingTerminologyTitle => 'Terminología';

  @override
  String get onboardingTerminologyHeadline => '¿Cómo llamas a un ciclo de entrenamiento?';

  @override
  String get onboardingTerminologySubtitle =>
      'Elige el término con el que te sientas más cómodo. Lo usaremos en toda la app.';

  @override
  String get getStartedButton => 'Comenzar';

  @override
  String get trainingCycleTermBlock => 'Bloque';

  @override
  String get trainingCycleTermBlockDesc => 'Un bloque de entrenamiento enfocado con objetivos específicos';

  @override
  String get trainingCycleTermMesocycle => 'Mesociclo';

  @override
  String get trainingCycleTermMesocycleDesc =>
      'Un período de entrenamiento estructurado que suele durar de 3 a 6 semanas';

  @override
  String get trainingCycleTermModule => 'Módulo';

  @override
  String get trainingCycleTermModuleDesc => 'Una unidad de entrenamiento modular que se puede apilar';

  @override
  String get trainingCycleTermPhase => 'Fase';

  @override
  String get trainingCycleTermPhaseDesc => 'Una fase de entrenamiento dentro de tu programa general';

  @override
  String get trainingCycleTermWave => 'Onda';

  @override
  String get trainingCycleTermWaveDesc => 'Una onda de intensidad de entrenamiento progresiva';

  @override
  String get onboardingEquipmentTitle => 'Tu equipo';

  @override
  String get onboardingEquipmentHeadline => '¿A qué equipo tienes acceso?';

  @override
  String get onboardingEquipmentSubtitle =>
      'Selecciona todos los que apliquen. Esto nos ayuda a sugerir ejercicios adecuados.';

  @override
  String get onboardingEquipmentSkip => 'Omitir por ahora';

  @override
  String get equipmentDumbbells => 'Mancuernas';

  @override
  String get equipmentHomeGymRack => 'Rack de gimnasio en casa';

  @override
  String get equipmentFunctionalTrainer => 'Entrenador funcional (poleas)';

  @override
  String get equipmentGymMachines => 'Máquinas de gimnasio';

  @override
  String get equipmentBarbells => 'Barras';

  @override
  String get equipmentKettlebells => 'Pesas rusas';

  @override
  String get equipmentResistanceBands => 'Bandas de resistencia';

  @override
  String get equipmentTreadmill => 'Caminadora';

  @override
  String get equipmentExerciseBike => 'Bicicleta estática';

  @override
  String get equipmentRowingMachine => 'Máquina de remo';

  @override
  String get equipmentLapPool => 'Piscina de natación';

  @override
  String get equipmentCrossfitGym => 'Gimnasio de Crossfit';

  @override
  String get equipmentPullUpBar => 'Barra de dominadas';

  @override
  String get equipmentSuspensionTrainer => 'Entrenador en suspensión (TRX)';

  @override
  String get onboardingProfileTitle => 'Sobre ti';

  @override
  String get onboardingProfileHeadline => 'Conozcámonos';

  @override
  String get onboardingProfileSubtitle =>
      'La estatura y el peso nos permiten registrar métricas corporales y mostrar el IMC. La preferencia de ícono es opcional al final.';

  @override
  String get unitsLabel => 'Unidades:';

  @override
  String get imperialLabel => 'Imperial';

  @override
  String get metricLabel => 'Métrico';

  @override
  String get heightLabel => 'Estatura';

  @override
  String get centimetersLabel => 'Centímetros';

  @override
  String get cmSuffix => 'cm';

  @override
  String get feetLabel => 'Pies';

  @override
  String get ftSuffix => 'ft';

  @override
  String get inchesLabel => 'Pulgadas';

  @override
  String get inSuffix => 'in';

  @override
  String get weightLabel => 'Peso';

  @override
  String get kilogramsLabel => 'Kilogramos';

  @override
  String get poundsLabel => 'Libras';

  @override
  String get kgSuffix => 'kg';

  @override
  String get lbsSuffix => 'lbs';

  @override
  String get heightRequiredError => 'Ingresa tu estatura';

  @override
  String get heightInvalidCmError => 'Ingresa una estatura válida (100-250 cm)';

  @override
  String get heightFeetRequiredError => 'Requerido';

  @override
  String get heightInvalidError => 'Inválido';

  @override
  String get weightRequiredError => 'Ingresa tu peso';

  @override
  String get weightInvalidNumberError => 'Ingresa un número válido';

  @override
  String get weightInvalidKgError => 'Ingresa un peso válido (40-180 kg)';

  @override
  String get weightInvalidLbsError => 'Ingresa un peso válido (80-400 lbs)';

  @override
  String get bmiPlaceholder => 'Ingresa estatura y peso para ver el IMC';

  @override
  String bmiValue(Object bmiValue) {
    return 'IMC $bmiValue';
  }

  @override
  String get aboutBmiCategories => 'Acerca de las categorías de IMC';

  @override
  String get bmiCategoryObese => 'Obesidad';

  @override
  String get bmiCategoryOverweight => 'Sobrepeso';

  @override
  String get bmiCategoryNormal => 'Normal';

  @override
  String get bmiCategoryUnderweight => 'Bajo peso';

  @override
  String get bmiCategoriesTitle => 'Categorías de IMC';

  @override
  String get bmiGuidelines => 'Según las directrices de la OMS / CDC';

  @override
  String get dexaScanTitle => 'Resultados de escaneo DEXA';

  @override
  String get dexaSubtitle => 'Opcional - para fisicoculturistas';

  @override
  String get bodyFatLabel => 'Grasa corporal';

  @override
  String get bodyFatSuffix => '%';

  @override
  String get bodyFatInvalidError => 'Inválido (3-60%)';

  @override
  String get leanMassLabel => 'Masa magra';

  @override
  String get appIconTitle => 'Ícono de la app (opcional)';

  @override
  String get appIconSubtitle => 'Tres variantes — toca una para elegir.';

  @override
  String cycleCreateTitle(Object cycleTerm) {
    return 'Crear $cycleTerm';
  }

  @override
  String cycleCreateHeading(Object cycleTerm) {
    return 'Nuevo $cycleTerm';
  }

  @override
  String cycleCreateDescription(Object cycleTerm) {
    return 'Un $cycleTerm es un programa de entrenamiento de varios períodos con sobrecarga progresiva, a menudo seguido de un período de recuperación para permitir que tu cuerpo descanse y se adapte.';
  }

  @override
  String cycleCreateNameLabel(Object cycleTerm) {
    return 'Nombre del $cycleTerm';
  }

  @override
  String get cycleCreateNameHint => 'ej., Hipertrofia Primavera 2025';

  @override
  String get cycleCreateNameRequired => 'Ingresa un nombre';

  @override
  String get cycleCreateNameMinLength => 'El nombre debe tener al menos 3 caracteres';

  @override
  String cycleCreateNameEmptySnackbar(Object cycleTerm) {
    return 'Ingresa un nombre para tu $cycleTerm';
  }

  @override
  String get cycleCreatePrimarySportHeader => 'Deporte principal (opcional)';

  @override
  String get cycleCreatePrimarySportDesc =>
      'Indica en torno a qué deporte está construido el ciclo. No restringe qué sesiones puedes agregar — cada ciclo puede combinar cualquier deporte.';

  @override
  String get cycleCreateDurationHeader => 'Duración';

  @override
  String get cycleCreateTrainingFrequencyHeader => 'Frecuencia de entrenamiento';

  @override
  String get cycleCreateRecoveryHeader => 'Período de recuperación (opcional)';

  @override
  String get cycleCreateTemplateHeader => 'Plantilla (opcional)';

  @override
  String get cycleCreateCreatingButton => 'Creando...';

  @override
  String cycleCreateButton(Object cycleTerm) {
    return 'Crear $cycleTerm';
  }

  @override
  String get cycleCreateTotalPeriods => 'Períodos totales';

  @override
  String cycleCreatePeriodsCount(Object count) {
    return '$count períodos';
  }

  @override
  String get cycleCreatePeriodsRecommendation => 'Recomendado: 4-6 períodos para hipertrofia';

  @override
  String get cycleCreateTrainingDays => 'Días de entrenamiento';

  @override
  String cycleCreateDaysPerPeriod(Object count) {
    return '$count días/período';
  }

  @override
  String cycleCreateDaysLabel(Object count) {
    return '$count días';
  }

  @override
  String get cycleCreateSplit2 => 'Rutina minimalista de cuerpo completo';

  @override
  String get cycleCreateSplit3 => 'Rutina de cuerpo completo o Empuje/Tirón/Pierna';

  @override
  String get cycleCreateSplit4 => 'Superior/Inferior o Empuje/Tirón/Pierna + Superior';

  @override
  String get cycleCreateSplit5 => 'Rutina Empuje/Tirón/Pierna/Superior/Inferior';

  @override
  String get cycleCreateSplit6 => 'Empuje/Tirón/Pierna dos veces por periodo';

  @override
  String get cycleCreateSplit7 => 'Entrenamiento diario (ciclo de 7 días)';

  @override
  String get cycleCreateSplit8 => 'Ciclo de entrenamiento de 8 días con día de descanso';

  @override
  String get cycleCreateSplit9 => 'Ciclo de entrenamiento de 9 días (ej. 3 activos/1 descanso)';

  @override
  String get cycleCreateSplit10 => 'Ciclo de entrenamiento de 10 días';

  @override
  String get cycleCreateSplit11 => 'Ciclo de entrenamiento de 11 días';

  @override
  String get cycleCreateSplit12 => 'Ciclo de entrenamiento de 12 días';

  @override
  String get cycleCreateSplit13 => 'Ciclo de entrenamiento de 13 días';

  @override
  String get cycleCreateSplit14 => 'Ciclo de entrenamiento de 14 días (quincenal)';

  @override
  String cycleCreateSplitGeneric(Object count) {
    return 'Ciclo de entrenamiento de $count días';
  }

  @override
  String get cycleCreateIncludeRecoveryTitle => 'Incluir periodo de recuperación';

  @override
  String get cycleCreateIncludeRecoverySubtitle =>
      'Un periodo más ligero para ayudar a la recuperación y evitar el sobreentrenamiento';

  @override
  String get cycleCreateRecoveryType => 'Tipo de recuperación';

  @override
  String cycleCreateRecoveryOnPeriod(Object recoveryType) {
    return '$recoveryType en el periodo';
  }

  @override
  String cycleCreatePeriodNumber(Object number) {
    return 'Periodo $number';
  }

  @override
  String get cycleCreateRecoveryScheduleHint => 'La mayoría programa esto en el último periodo';

  @override
  String get cycleCreateChooseTemplate => 'Elige una plantilla';

  @override
  String get cycleCreateTemplateNone => 'Ninguna (personalizada)';

  @override
  String get cycleCreateTemplateHint =>
      'Las plantillas ofrecen rutinas de entrenamiento preconfiguradas con ejercicios de fuerza';

  @override
  String cycleCreateErrorLoadingTemplates(Object error) {
    return 'Error al cargar las plantillas: $error';
  }

  @override
  String cycleCreateSuccessSnackbar(Object cycleTerm, Object name) {
    return '¡$cycleTerm \"$name\" creado!';
  }

  @override
  String get cycleCreateMixedChipLabel => 'Mixto';

  @override
  String get cycleListNewButton => 'Nuevo';

  @override
  String cycleListDraftSectionHeader(Object cycleTerm) {
    return '$cycleTerm en borrador';
  }

  @override
  String cycleListCurrentSectionHeader(Object cycleTerm) {
    return '$cycleTerm actual';
  }

  @override
  String cycleListCompletedSectionHeader(Object cycleTermPlural) {
    return '$cycleTermPlural completados';
  }

  @override
  String cycleListErrorLoading(Object error) {
    return 'Error al cargar los ciclos de entrenamiento: $error';
  }

  @override
  String get cycleListCurrentBadge => 'ACTUAL';

  @override
  String cycleListPeriodsCount(Object count) {
    return '$count periodos';
  }

  @override
  String cycleListDaysPerPeriod(Object count) {
    return '$count días/periodo';
  }

  @override
  String get cycleListStartButton => 'Iniciar';

  @override
  String get cycleListEmptyTitle => 'Sin ciclos de entrenamiento';

  @override
  String get cycleListEmptySubtitle => 'Crea tu primer ciclo de entrenamiento para empezar';

  @override
  String get cycleListCreateNew => 'Crear nuevo';

  @override
  String get cycleListStartFromTemplate => 'Empezar desde una plantilla';

  @override
  String get cycleListMenuWriteNote => 'Escribir una nota nueva';

  @override
  String get cycleListMenuRename => 'Renombrar';

  @override
  String cycleListMenuCopy(Object cycleTerm) {
    return 'Copiar el $cycleTerm';
  }

  @override
  String get cycleListMenuSummary => 'Resumen';

  @override
  String cycleListMenuRestart(Object cycleTerm) {
    return 'Reiniciar $cycleTerm';
  }

  @override
  String get cycleListMenuSaveAsTemplate => 'Guardar como plantilla';

  @override
  String get cycleListMenuShareQR => 'Compartir (alojar código QR)';

  @override
  String get cycleListMenuExportDebug => 'Exportar (depuración)';

  @override
  String cycleListMenuDelete(Object cycleTerm) {
    return 'Eliminar $cycleTerm';
  }

  @override
  String cycleListStartDialogTitle(Object cycleTerm) {
    return 'Iniciar $cycleTerm';
  }

  @override
  String cycleListStartDialogNoActive(Object name, Object cycleTerm) {
    return '¿Iniciar \"$name\"? Se establecerá como tu $cycleTerm actual.';
  }

  @override
  String cycleListStartDialogHasActive(Object cycleTerm, Object activeNames, Object name) {
    return 'Tienes un $cycleTerm activo: \"$activeNames\".\n\n¿Cómo quieres iniciar \"$name\"?';
  }

  @override
  String get cycleListReplaceCurrentButton => 'Reemplazar el actual';

  @override
  String get cycleListStackAlongsideButton => 'Agregar en paralelo';

  @override
  String cycleListNoteDialogTitle(Object cycleTerm) {
    return 'Nota de $cycleTerm';
  }

  @override
  String cycleListNoteDialogHint(Object cycleTerm) {
    return 'Escribe una nota para este $cycleTerm...';
  }

  @override
  String cycleListCopyNameSuffix(Object name) {
    return '$name (copia)';
  }

  @override
  String cycleListCopiedSnackbar(Object cycleTerm) {
    return '¡$cycleTerm copiado como borrador!';
  }

  @override
  String cycleListErrorCopying(Object cycleTerm, Object error) {
    return 'Error al copiar $cycleTerm: $error';
  }

  @override
  String cycleListRestartDialogTitle(Object cycleTerm) {
    return 'Reiniciar $cycleTerm';
  }

  @override
  String cycleListRestartDialogContent(Object name, Object cycleTerm) {
    return '¿Reiniciar \"$name\"? Se creará una copia y se establecerá como tu $cycleTerm actual.';
  }

  @override
  String get cycleListRestartButton => 'Reiniciar';

  @override
  String cycleListRestartedSnackbar(Object cycleTerm) {
    return '¡$cycleTerm reiniciado!';
  }

  @override
  String cycleListErrorRestarting(Object cycleTerm, Object error) {
    return 'Error al reiniciar $cycleTerm: $error';
  }

  @override
  String cycleListTemplateSaved(Object name) {
    return '¡Plantilla \"$name\" guardada!';
  }

  @override
  String cycleListErrorSavingTemplate(Object error) {
    return 'Error al guardar la plantilla: $error';
  }

  @override
  String get cycleListPreparingShare => 'Preparando para compartir...';

  @override
  String cycleListSharedFromDescription(Object name) {
    return 'Compartido desde $name';
  }

  @override
  String cycleListErrorPreparingShare(Object error) {
    return 'Error al preparar la plantilla para compartir: $error';
  }

  @override
  String get cycleListTemplateExported => '¡JSON de la plantilla copiado al portapapeles!';

  @override
  String cycleListErrorExporting(Object error) {
    return 'Error al exportar la plantilla: $error';
  }

  @override
  String cycleListRenamedSnackbar(Object name) {
    return 'Renombrado a \"$name\"';
  }

  @override
  String cycleListErrorRenaming(Object error) {
    return 'Error al renombrar el ciclo de entrenamiento: $error';
  }

  @override
  String get cycleListDeleteDialogTitle => 'Eliminar ciclo de entrenamiento en borrador';

  @override
  String cycleListDeleteDialogContent(Object name) {
    return '¿Seguro que deseas eliminar \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String cycleListDeletedSnackbar(Object name) {
    return '\"$name\" eliminado';
  }

  @override
  String cycleListErrorDeleting(Object error) {
    return 'Error al eliminar el ciclo de entrenamiento: $error';
  }

  @override
  String get cycleListMenuComplete => 'Marcar como completado';

  @override
  String cycleListCompleteDialogTitle(Object cycleTerm) {
    return 'Completar $cycleTerm';
  }

  @override
  String cycleListCompleteDialogContent(Object name, Object cycleTerm) {
    return '¿Marcar \"$name\" como completado? Tu historial se conserva y el $cycleTerm pasa a tu lista de completados.';
  }

  @override
  String get cycleListCompleteAction => 'Completar';

  @override
  String cycleListCompletedSnackbar(Object name) {
    return '\"$name\" marcado como completado';
  }

  @override
  String cycleListErrorCompleting(Object error) {
    return 'Error al completar el ciclo de entrenamiento: $error';
  }

  @override
  String get cycleListRenameDialogTitle => 'Renombrar';

  @override
  String get cycleListRenameDialogHint => 'Nombre del ciclo de entrenamiento';

  @override
  String get cycleListSaveTemplateDialogTitle => 'Guardar como plantilla';

  @override
  String get cycleListSaveTemplateNameLabel => 'Nombre de la plantilla';

  @override
  String get cycleListSaveTemplateNameHint => 'ej. \"Rutina Superior Inferior\"';

  @override
  String get cycleListSaveTemplateNameError => 'Ingresa un nombre para la plantilla';

  @override
  String get cycleListSaveTemplateDescLabel => 'Descripción';

  @override
  String get cycleListSaveTemplateDescHint => 'ej. \"Ideal para ganar fuerza y tamaño\"';

  @override
  String get cycleListSaveTemplateDescError => 'Ingresa una descripción';

  @override
  String get templateSelectionTitle => 'Elige un programa';

  @override
  String get templateSelectionNoTemplates => 'No hay plantillas disponibles';

  @override
  String get templateSelectionBrowseCommunity => 'Explorar comunidad';

  @override
  String get templateSelectionBrowseCommunitySubtitle => 'Descarga programas compartidos por otros usuarios';

  @override
  String templateSelectionDaysPerPeriod(Object count) {
    return '$count días/periodo';
  }

  @override
  String templateSelectionPeriodsCount(Object count) {
    return '$count periodos';
  }

  @override
  String templateSelectionSessionsCount(Object count) {
    return '$count sesiones';
  }

  @override
  String get templateSelectionDeleteTitle => '¿Eliminar plantilla?';

  @override
  String templateSelectionDeleteContent(Object name) {
    return '¿Seguro que deseas eliminar \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String templateSelectionDeletedSnackbar(Object name) {
    return 'Plantilla \"$name\" eliminada';
  }

  @override
  String templateSelectionDeleteError(Object error) {
    return 'No se pudo eliminar la plantilla: $error';
  }

  @override
  String get templatePreviewLoadProgram => 'CARGAR PROGRAMA';

  @override
  String templatePreviewErrorCreating(Object error) {
    return 'Error al crear el programa: $error';
  }

  @override
  String get templatePreviewDuration => 'Duración';

  @override
  String get templatePreviewPerPeriod => 'Por periodo';

  @override
  String get templatePreviewRecovery => 'Recuperación';

  @override
  String templatePreviewPeriodHeader(Object number) {
    return 'Periodo $number';
  }

  @override
  String templatePreviewPeriodRecoveryHeader(Object number) {
    return 'Periodo $number (recuperación)';
  }

  @override
  String templatePreviewDayFallback(Object number) {
    return 'Día $number';
  }

  @override
  String sessionDayFallback(Object number) {
    return 'Día $number';
  }

  @override
  String templatePreviewCardioSession(Object sport) {
    return 'Sesión de $sport';
  }

  @override
  String templatePreviewExerciseCount(Object count) {
    return '$count ejercicios';
  }

  @override
  String templatePreviewSetsReps(Object sets, Object reps) {
    return '$sets series × $reps';
  }

  @override
  String templatePreviewDaysCount(Object count) {
    return '$count días';
  }

  @override
  String planCycleTitle(Object cycleTerm) {
    return 'Planificar un $cycleTerm';
  }

  @override
  String get planCycleStartWithTemplate => 'Empezar con una plantilla';

  @override
  String get planCycleStartWithTemplateSubtitle =>
      'Elige una plantilla que se ajuste a tus objetivos y empieza cuanto antes.';

  @override
  String get planCycleStartFromScratch => 'Empezar desde cero';

  @override
  String planCycleStartFromScratchSubtitle(Object cycleTerm) {
    return 'Crea tu propio $cycleTerm desde una página en blanco.';
  }

  @override
  String get workoutSessionTitle => 'Sesión';

  @override
  String workoutPeriodDayTitle(Object period, Object day, Object dayName) {
    return 'PERIODO $period DÍA $day $dayName';
  }

  @override
  String workoutCycleCompletedTitle(Object cycleTerm) {
    return '¡$cycleTerm completado!';
  }

  @override
  String workoutCycleCompletedContent(Object cycleTerm) {
    return '¡Felicidades! Has terminado todos los entrenamientos de este $cycleTerm.';
  }

  @override
  String get workoutCycleCompletedAction => 'GENIAL';

  @override
  String workoutEndCycleTitle(Object cycleTerm) {
    return 'Finalizar $cycleTerm';
  }

  @override
  String workoutEndCycleContent(Object name) {
    return '¿Seguro que deseas finalizar \"$name\"? Se marcará como completado.';
  }

  @override
  String workoutEndCycleAction(Object cycleTerm) {
    return 'FINALIZAR $cycleTerm';
  }

  @override
  String workoutCycleCompleted(Object name) {
    return '\"$name\" completado';
  }

  @override
  String workoutEndCycleError(Object error) {
    return 'Error al finalizar el ciclo de entrenamiento: $error';
  }

  @override
  String get workoutFinishButton => 'TERMINAR ENTRENAMIENTO';

  @override
  String get workoutFinishLabel => 'Terminar entrenamiento';

  @override
  String get workoutSelectDayTooltip => 'Seleccionar día';

  @override
  String get workoutAddSessionTooltip => 'Agregar sesión';

  @override
  String get workoutAppLogoLabel => 'Logo de la app';

  @override
  String workoutSetDeleted(Object setNumber) {
    return 'Serie $setNumber eliminada';
  }

  @override
  String workoutExerciseDeleted(Object exerciseName) {
    return '$exerciseName eliminado';
  }

  @override
  String workoutCardioSessionDeleted(Object label) {
    return '$label eliminado';
  }

  @override
  String workoutRenamedTo(Object name) {
    return 'Renombrado a \"$name\"';
  }

  @override
  String workoutRenameError(Object error) {
    return 'Error al renombrar el ciclo de entrenamiento: $error';
  }

  @override
  String get workoutLabelUpdated => 'Etiqueta actualizada';

  @override
  String workoutLabelUpdatedForAllDays(Object dayNumber) {
    return 'Etiqueta actualizada para todos los entrenamientos del día $dayNumber';
  }

  @override
  String workoutLabelUpdateError(Object error) {
    return 'Error al actualizar la etiqueta: $error';
  }

  @override
  String get workoutAllDayLabelsCleared => 'Se borraron todas las etiquetas de día';

  @override
  String workoutClearLabelsError(Object error) {
    return 'Error al borrar las etiquetas: $error';
  }

  @override
  String get workoutReset => 'Entrenamiento reiniciado';

  @override
  String workoutResetError(Object error) {
    return 'Error al reiniciar el entrenamiento: $error';
  }

  @override
  String get workoutClearDayLabelsTitle => 'Borrar todas las etiquetas de día';

  @override
  String get workoutClearDayLabelsContent =>
      'Esto eliminará todas las etiquetas de día personalizadas de los entrenamientos de este ciclo de entrenamiento. Los nombres de los días se calcularán automáticamente según la fecha de inicio.\n\nEsto no se puede deshacer.';

  @override
  String get workoutClearDayLabelsAction => 'BORRAR TODO';

  @override
  String get workoutResetTitle => '¿Reiniciar entrenamiento?';

  @override
  String get workoutResetContent =>
      'Esto borrará todas las series registradas y los valores ingresados de este entrenamiento. Esta acción no se puede deshacer.';

  @override
  String get workoutResetAction => 'REINICIAR';

  @override
  String get workoutMenuTrainingCycleHeader => 'CICLO DE ENTRENAMIENTO';

  @override
  String get workoutMenuNote => 'Nota';

  @override
  String get workoutMenuSummary => 'Resumen';

  @override
  String get workoutMenuRename => 'Renombrar';

  @override
  String workoutMenuEndCycle(Object cycleTerm) {
    return 'Finalizar $cycleTerm';
  }

  @override
  String get workoutMenuWorkoutHeader => 'ENTRENAMIENTO';

  @override
  String get workoutMenuNewNote => 'Nota nueva';

  @override
  String get workoutMenuRelabel => 'Reetiquetar';

  @override
  String get workoutMenuClearDayLabels => 'Borrar todas las etiquetas de día';

  @override
  String get workoutMenuAddSession => 'Agregar sesión';

  @override
  String get workoutMenuBodyweight => 'Peso corporal';

  @override
  String get workoutMenuReset => 'Reiniciar';

  @override
  String get workoutMenuSkipWorkout => 'Omitir entrenamiento';

  @override
  String get workoutNoActiveCycleTitle => 'Sin ciclo de entrenamiento activo';

  @override
  String get workoutNoActiveCycleMessage => 'Crea e inicia un ciclo de entrenamiento para empezar';

  @override
  String get workoutCycleNotActiveTitle => 'Ciclo de entrenamiento no activo';

  @override
  String get workoutCycleNotActiveMessage =>
      'El ciclo de entrenamiento está programado para una fecha futura o ya terminó';

  @override
  String workoutCycleSectionPeriodDay(Object period, Object day) {
    return 'Periodo $period • Día $day';
  }

  @override
  String get editWorkoutStartButton => 'Iniciar';

  @override
  String get editWorkoutExportTemplateTooltip => 'Exportar plantilla (depuración)';

  @override
  String get editWorkoutAddExerciseButton => 'Agregar ejercicio';

  @override
  String get editWorkoutPeriodLabel => 'Periodo';

  @override
  String get editWorkoutRemovePeriodTooltip => 'Quitar periodo';

  @override
  String get editWorkoutAddPeriodTooltip => 'Agregar periodo';

  @override
  String get editWorkoutMirrorPeriod1Tooltip => 'Reflejar periodo 1';

  @override
  String get editWorkoutDayLabel => 'Día';

  @override
  String editWorkoutDayPrefix(Object number) {
    return 'D$number';
  }

  @override
  String get editWorkoutRemoveDayTooltip => 'Quitar día';

  @override
  String get editWorkoutAddDayTooltip => 'Agregar día';

  @override
  String editWorkoutPeriodAdded(Object number) {
    return 'Periodo $number agregado';
  }

  @override
  String editWorkoutPeriodAddError(Object error) {
    return 'Error al agregar el periodo: $error';
  }

  @override
  String get editWorkoutRecoveryPeriodRemoved => 'Periodo de recuperación eliminado';

  @override
  String editWorkoutPeriodRemoved(Object number) {
    return 'Periodo $number eliminado';
  }

  @override
  String editWorkoutPeriodRemoveError(Object error) {
    return 'Error al quitar el periodo: $error';
  }

  @override
  String editWorkoutRecoveryTypeChanged(Object type) {
    return 'Periodo de recuperación cambiado a $type';
  }

  @override
  String editWorkoutRecoveryTypeError(Object error) {
    return 'Error al actualizar el tipo de recuperación: $error';
  }

  @override
  String editWorkoutDayAdded(Object number) {
    return 'Día $number agregado';
  }

  @override
  String editWorkoutDayAddError(Object error) {
    return 'Error al agregar el día: $error';
  }

  @override
  String editWorkoutDayRemoved(Object number) {
    return 'Día $number eliminado';
  }

  @override
  String editWorkoutDayRemoveError(Object error) {
    return 'Error al quitar el día: $error';
  }

  @override
  String editWorkoutPeriod1Mirrored(Object number) {
    return 'Periodo 1 reflejado en el periodo $number';
  }

  @override
  String editWorkoutMirrorError(Object error) {
    return 'Error al reflejar el periodo: $error';
  }

  @override
  String get editWorkoutTemplateExported => '¡JSON de la plantilla copiado al portapapeles!';

  @override
  String editWorkoutTemplateExportError(Object error) {
    return 'Error al exportar la plantilla: $error';
  }

  @override
  String get editWorkoutRemovePeriodTitle => 'Quitar periodo';

  @override
  String editWorkoutRemovePeriodContent(Object number) {
    return '¿Qué periodo te gustaría quitar?\n\n• Periodo $number (último periodo de entrenamiento)\n• Periodo de recuperación';
  }

  @override
  String get editWorkoutRemoveDeload => 'Quitar descarga';

  @override
  String editWorkoutRemovePeriodAction(Object number) {
    return 'Quitar periodo $number';
  }

  @override
  String get editWorkoutRecoveryTypeTitle => 'Tipo de periodo de recuperación';

  @override
  String get editWorkoutRemoveDayTitle => 'Quitar día';

  @override
  String editWorkoutRemoveDayContent(Object number) {
    return 'El día $number tiene ejercicios asignados. Al quitarlo se eliminarán todos los ejercicios de ese día en todos los periodos.\n\n¿Seguro que deseas quitar el día $number?';
  }

  @override
  String get editWorkoutRemoveDayAction => 'Quitar';

  @override
  String get editWorkoutMirrorTitle => 'Reflejar periodo 1';

  @override
  String editWorkoutMirrorContent(Object number) {
    return '¿Copiar todos los entrenamientos del periodo 1 al periodo $number? Esto reemplazará cualquier entrenamiento existente del periodo $number.';
  }

  @override
  String get editWorkoutMirrorAction => 'Reflejar';

  @override
  String get editWorkoutDeleteExerciseTitle => 'Eliminar ejercicio';

  @override
  String editWorkoutDeleteExerciseContent(Object name) {
    return '¿Seguro que deseas eliminar \"$name\"?';
  }

  @override
  String editWorkoutStartCycleTitle(Object cycleTerm) {
    return 'Iniciar $cycleTerm';
  }

  @override
  String editWorkoutStartCycleContent(Object name, Object cycleTerm) {
    return '¿Iniciar \"$name\"? Se establecerá como tu $cycleTerm actual.';
  }

  @override
  String editWorkoutStartCycleActiveContent(Object cycleTerm, Object activeNames, Object name) {
    return 'Tienes un $cycleTerm activo: \"$activeNames\".\n\n¿Cómo quieres iniciar \"$name\"?';
  }

  @override
  String get editWorkoutStartCycleReplace => 'Reemplazar el actual';

  @override
  String get editWorkoutStartCycleStack => 'Agregar en paralelo';

  @override
  String get editWorkoutSetHeader => 'SERIE';

  @override
  String get editWorkoutRepsHeader => 'REPS';

  @override
  String get editWorkoutRepsHint => 'reps';

  @override
  String get editWorkoutExerciseMenuHeader => 'EJERCICIO';

  @override
  String get editWorkoutNewNote => 'Nota nueva';

  @override
  String get editWorkoutMoveUp => 'Subir';

  @override
  String get editWorkoutMoveDown => 'Bajar';

  @override
  String get editWorkoutReplace => 'Reemplazar';

  @override
  String get editWorkoutAddSet => 'Agregar serie';

  @override
  String get editWorkoutDeleteExercise => 'Eliminar ejercicio';

  @override
  String get editWorkoutSetMenuHeader => 'SERIE';

  @override
  String get editWorkoutAddSetBelow => 'Agregar serie debajo';

  @override
  String get editWorkoutDeleteSet => 'Eliminar serie';

  @override
  String get editWorkoutSetTypeHeader => 'TIPO DE SERIE';

  @override
  String get editWorkoutNoExercisesTitle => 'No hay ejercicios programados';

  @override
  String get editWorkoutNoExercisesSubtitle => 'Agrega ejercicios para este día';

  @override
  String get editWorkoutAddCardioSessionTitle => 'Agregar sesión de cardio';

  @override
  String get editWorkoutAddCardio => 'Agregar cardio';

  @override
  String get editWorkoutInfoButtonLabel => 'i';

  @override
  String get addExerciseTitle => 'Agregar ejercicio';

  @override
  String get addExerciseCreateCustomButton => 'Crear personalizado';

  @override
  String get addExerciseAddButton => 'Agregar';

  @override
  String get addExerciseSearchLabel => 'Buscar ejercicios';

  @override
  String get addExerciseSearchHint => 'Buscar';

  @override
  String get addExerciseClearSearchTooltip => 'Borrar búsqueda';

  @override
  String get addExerciseFilterButton => 'Filtrar';

  @override
  String get addExerciseFilterClearAll => 'BORRAR TODO';

  @override
  String get addExerciseFilterTitle => 'Filtrar';

  @override
  String get addExerciseFilterMuscleGroup => 'Grupo muscular';

  @override
  String get addExerciseFilterEquipmentType => 'Filtrar por tipo de equipo';

  @override
  String get addExerciseFilterEquipmentTypeDesc => 'Filtra temporalmente por tipos de equipo específicos';

  @override
  String get addExerciseFilterApplyButton => 'APLICAR FILTROS';

  @override
  String get addExerciseNoResults => 'No se encontraron ejercicios';

  @override
  String get addExerciseAdjustFilters => 'Intenta ajustar tu búsqueda o filtros';

  @override
  String addExerciseLastPerformed(Object dateStr) {
    return 'Última vez $dateStr';
  }

  @override
  String get addExerciseWorkoutNotFound => 'Error: Workout no encontrado';

  @override
  String addExerciseReplaced(Object oldName, Object newName) {
    return '$oldName reemplazado por $newName';
  }

  @override
  String addExerciseAdded(Object name) {
    return '$name agregado';
  }

  @override
  String get completedWorkoutNotFoundTitle => 'Ciclo de entrenamiento no encontrado';

  @override
  String get completedWorkoutNotFoundBody => 'No se pudo encontrar el ciclo de entrenamiento solicitado.';

  @override
  String get completedWorkoutErrorTitle => 'Error';

  @override
  String completedWorkoutErrorMessage(Object error) {
    return 'Error al cargar el ciclo de entrenamiento: $error';
  }

  @override
  String get completedWorkoutCompletedBadge => 'COMPLETADO';

  @override
  String completedWorkoutWeekDayTitle(Object period, Object day, Object dayName) {
    return 'SEMANA $period DÍA $day $dayName';
  }

  @override
  String get completedWorkoutWeightHeader => 'PESO';

  @override
  String get completedWorkoutRepsHeader => 'REPS';

  @override
  String get completedWorkoutLogHeader => 'REGISTRO';

  @override
  String get completedWorkoutNoExercises => 'No hay ejercicios para este día';

  @override
  String get completedWorkoutWeeksReadOnly => 'SEMANAS (SOLO LECTURA)';

  @override
  String get completedWorkoutDlLabel => 'DL';

  @override
  String completedWorkoutRirLabel(Object rir) {
    return '$rir RIR';
  }

  @override
  String get completedWorkoutUnknownEquipment => 'DESCONOCIDO';

  @override
  String get completedWorkoutEmptyValue => '-';

  @override
  String cardioSessionLogTitle(Object sport) {
    return 'Registrar $sport';
  }

  @override
  String cardioSessionEditTitle(Object sport) {
    return 'Editar $sport';
  }

  @override
  String cardioSessionPlanTitle(Object sport) {
    return 'Planificar $sport';
  }

  @override
  String get cardioSessionEditIntervalsTooltip => 'Editar intervalos';

  @override
  String get cardioSessionImportedChip => 'Importado';

  @override
  String get cardioSessionDateButton => 'Fecha';

  @override
  String get cardioSessionStartFromTemplate => 'Comenzar desde plantilla';

  @override
  String get cardioSessionNameLabel => 'Nombre del entrenamiento';

  @override
  String get cardioSessionNameHint => 'ej., Tempo 30 min';

  @override
  String get cardioSessionNotesLabel => 'Notas';

  @override
  String get cardioSessionNotesHint => 'Algo que valga la pena recordar sobre este entrenamiento…';

  @override
  String get cardioSessionPlanButton => 'Planificar entrenamiento';

  @override
  String get cardioSessionSaveButton => 'Guardar entrenamiento';

  @override
  String get cardioSessionLogButton => 'Registrar entrenamiento';

  @override
  String get cardioSessionUpdateButton => 'Actualizar entrenamiento';

  @override
  String get cardioSessionPlanned => 'Entrenamiento planificado';

  @override
  String get cardioSessionLogged => 'Entrenamiento registrado';

  @override
  String get cardioSessionUpdated => 'Entrenamiento actualizado';

  @override
  String get cardioSessionPerceivedExertion => 'Esfuerzo percibido';

  @override
  String cardioSessionRpeValue(Object value) {
    return 'RPE $value';
  }

  @override
  String get cardioSessionRpeNotSet => 'Sin definir';

  @override
  String cardioSessionPaceAvgSpeed(Object pace, Object speed) {
    return 'Ritmo $pace  •  Velocidad prom. $speed';
  }

  @override
  String cardioSessionAvgSpeed(Object speed) {
    return 'Velocidad prom. $speed';
  }

  @override
  String get intervalBuilderTitle => 'Intervalos';

  @override
  String get intervalBuilderSaveButton => 'Guardar';

  @override
  String get intervalBuilderSessionNotFound => 'Entrenamiento de cardio no encontrado';

  @override
  String intervalBuilderStepsCount(Object count) {
    return '$count pasos';
  }

  @override
  String get intervalBuilderSaved => 'Intervalos guardados';

  @override
  String get intervalBuilderDiscardTitle => '¿Descartar cambios?';

  @override
  String get intervalBuilderDiscardContent => 'Tienes cambios sin guardar en este plan de intervalos.';

  @override
  String get intervalBuilderKeepEditing => 'Seguir editando';

  @override
  String get intervalBuilderDiscard => 'Descartar';

  @override
  String get intervalBuilderAddStep => 'Agregar paso';

  @override
  String get intervalBuilderMoveUpTooltip => 'Mover arriba';

  @override
  String get intervalBuilderMoveDownTooltip => 'Mover abajo';

  @override
  String get intervalBuilderRemoveTooltip => 'Eliminar';

  @override
  String get intervalBuilderAddToRepeat => 'Agregar a repetición';

  @override
  String get intervalBuilderRepeatGroupSubtitle => 'Agrupa varios pasos y ejecútalos N veces';

  @override
  String get intervalBuilderRepeatLabel => 'Repetir';

  @override
  String get intervalBuilderTimesLabel => 'veces';

  @override
  String get intervalBuilderTargetTypeLabel => 'Tipo de objetivo';

  @override
  String get intervalBuilderFieldDuration => 'Duración';

  @override
  String get intervalBuilderFieldDistanceM => 'Distancia (m)';

  @override
  String get intervalBuilderFieldHrZone => 'Zona de FC (1..5)';

  @override
  String get intervalBuilderFieldPaceZone => 'Zona de ritmo (1..5)';

  @override
  String get intervalBuilderFieldPowerZone => 'Zona de potencia (1..5)';

  @override
  String get intervalBuilderFieldFreeform => 'Objetivo (texto libre)';

  @override
  String get intervalBuilderErrorMmSs => 'Usa MM:SS';

  @override
  String get intervalBuilderErrorMeters => 'Ingresa metros';

  @override
  String get intervalBuilderErrorZoneRange => '1..5';

  @override
  String get intervalBuilderEmptyTitle => 'Aún no hay intervalos';

  @override
  String get intervalBuilderEmptySubtitle =>
      'Un plan estructurado se ve así: calentamiento → trabajo → recuperación → enfriamiento. Comienza con un calentamiento.';

  @override
  String get intervalBuilderAddWarmUp => 'Agregar calentamiento';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get calendarShowLegendTooltip => 'Mostrar leyenda';

  @override
  String get calendarNoActiveCycleTitle => 'Sin ciclo de entrenamiento activo';

  @override
  String get calendarNoActiveCycleSubtitle =>
      'Inicia un ciclo de entrenamiento para ver tus entrenamientos en el calendario';

  @override
  String calendarPeriodDayLabel(Object period, Object day) {
    return 'P${period}D$day';
  }

  @override
  String calendarMuscleGroupSets(Object muscleGroup, Object setCount) {
    return '$muscleGroup • $setCount series';
  }

  @override
  String calendarExerciseSetCount(Object name, num setCount) {
    String _temp0 = intl.Intl.pluralLogic(
      setCount,
      locale: localeName,
      other: '$setCount series',
      one: '1 serie',
    );
    return '$name ($_temp0)';
  }

  @override
  String calendarMoreExercises(Object count) {
    return '+$count más';
  }

  @override
  String get calendarRestDay => 'Día de descanso';

  @override
  String get calendarEditButton => 'Editar';

  @override
  String get calendarNoSessionScheduled => 'No hay entrenamiento programado';

  @override
  String get calendarStatusCompleted => 'Completado';

  @override
  String get calendarStatusInProgress => 'En progreso';

  @override
  String get calendarStatusRecovery => 'Recuperación';

  @override
  String get calendarStatusScheduled => 'Programado';

  @override
  String calendarPeriodDayInfo(Object period, Object day) {
    return 'Periodo $period, Día $day';
  }

  @override
  String calendarPeriodDayRecovery(Object period, Object day) {
    return 'Periodo $period, Día $day (Recuperación)';
  }

  @override
  String calendarExercisesMuscleGroups(Object count, Object muscleGroups) {
    return '$count ejercicios • $muscleGroups';
  }

  @override
  String get calendarViewButton => 'Ver';

  @override
  String get calendarGoToWorkoutButton => 'Ir al entrenamiento';

  @override
  String calendarCardioSessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrenamientos de cardio',
      one: '1 entrenamiento de cardio',
    );
    return '$_temp0';
  }

  @override
  String get calendarViewDayButton => 'Ver día';

  @override
  String get calendarSessionStatusDone => 'Hecho';

  @override
  String get calendarSessionStatusSkipped => 'Omitido';

  @override
  String get calendarSessionStatusPlanned => 'Planificado';

  @override
  String calendarMovedExercise(Object exerciseName, Object date) {
    return 'Se movió $exerciseName al $date';
  }

  @override
  String calendarMovedCardio(Object sessionLabel, Object date) {
    return 'Se movió $sessionLabel al $date';
  }

  @override
  String calendarFailedToMove(Object error) {
    return 'Error al mover: $error';
  }

  @override
  String calendarFailedToReorder(Object error) {
    return 'Error al reordenar el ejercicio: $error';
  }

  @override
  String calendarRestDayInserted(Object period, Object day) {
    return 'Día de descanso insertado antes de P${period}D$day';
  }

  @override
  String calendarFailedToInsertDay(Object error) {
    return 'Error al insertar el día: $error';
  }

  @override
  String calendarRestDayRemoved(Object date) {
    return 'Día de descanso eliminado el $date';
  }

  @override
  String calendarFailedToRemoveRestDay(Object error) {
    return 'Error al eliminar el día de descanso: $error';
  }

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsSaveButton => 'Guardar';

  @override
  String get settingsSavedMessage => 'Configuración guardada';

  @override
  String get settingsUnitsHeader => 'Unidades';

  @override
  String get settingsImperialLabel => 'Imperial (lbs)';

  @override
  String get settingsMetricLabel => 'Métrico (kg)';

  @override
  String get settingsLanguageHeader => 'Idioma';

  @override
  String get settingsLanguageDescription => 'Elige el idioma de la aplicación';

  @override
  String get settingsBodyMeasurementsHeader => 'Medidas corporales';

  @override
  String get settingsBodyMeasurementsDesc => 'Actualiza tus medidas para seguir tu IMC a lo largo del tiempo';

  @override
  String get settingsCurrentBmi => 'IMC actual';

  @override
  String get settingsBmiGuidelines => 'Categorías de IMC según las directrices de la OMS';

  @override
  String get settingsTerminologyHeader => 'Terminología del ciclo de entrenamiento';

  @override
  String get settingsTerminologyDesc => 'Elige el término que prefieras para tus ciclos de entrenamiento';

  @override
  String get settingsSportsHeader => 'Deportes que entreno';

  @override
  String get settingsSportsDesc =>
      'Elige los deportes que quieres registrar. La cuadrícula \"Agregar entrenamiento\" de la pestaña Entrenamiento solo muestra estos.';

  @override
  String get settingsSportsMinimumWarning => 'Se requiere al menos un deporte.';

  @override
  String get integrationsTitle => 'Integraciones';

  @override
  String get integrationsHealthPermissionsGranted => 'Permisos de salud concedidos';

  @override
  String get integrationsHealthConnectRequired => 'Se requiere Health Connect';

  @override
  String get integrationsHealthConnectIntro =>
      'Para sincronizar entrenamientos desde Health Connect y Peloton, sigue estos pasos:';

  @override
  String get integrationsHealthConnectStep1 =>
      '1. Descarga e instala Health Connect desde Google Play Store (Android 14+ lo trae integrado).';

  @override
  String get integrationsHealthConnectStep2 => '2. Abre Health Connect y ve a Permisos de aplicaciones.';

  @override
  String get integrationsHealthConnectStep3 =>
      '3. Busca Yawa4u en la lista y permite el acceso a Sesiones de ejercicio, Frecuencia cardíaca, Distancia y Energía activa quemada.';

  @override
  String get integrationsHealthConnectStep4 => '4. Regresa aquí y toca \"Conceder permisos\" de nuevo.';

  @override
  String get integrationsGotIt => 'ENTENDIDO';

  @override
  String integrationsHealthSyncSuccess(
    Object totalPoints,
    Object imported,
    Object skippedDuplicate,
    Object skippedUnsupported,
  ) {
    return 'Se encontraron $totalPoints registros · +$imported importados · $skippedDuplicate duplicados · $skippedUnsupported no compatibles';
  }

  @override
  String integrationsHealthSyncFailed(Object error) {
    return 'Error de sincronización: $error';
  }

  @override
  String get integrationsResetCursorMessage => 'La próxima sincronización revisará los últimos 3 meses.';

  @override
  String get integrationsHealthDiagnosticsTitle => 'Diagnóstico de salud';

  @override
  String get integrationsStravaTitle => 'Strava';

  @override
  String get integrationsStravaUnconfiguredMessage =>
      'Strava requiere credenciales de cliente al compilar. Consulta el README o el documento de traspaso de Bucket 3 para los pasos de configuración.';

  @override
  String get integrationsStravaDescription =>
      'Importa actividades de Strava — carreras, salidas en bici y nados se importan con distancia, duración, FC y elevación.';

  @override
  String integrationsLastSync(Object timestamp) {
    return 'Última sincronización: $timestamp';
  }

  @override
  String get integrationsStravaConnected => 'Conectado a Strava';

  @override
  String get integrationsStravaConnectFailed => 'No se pudo conectar a Strava';

  @override
  String integrationsStravaSyncSuccess(Object imported, Object skippedDuplicate, Object skippedUnsupported) {
    return 'Importados $imported · $skippedDuplicate duplicados · $skippedUnsupported no compatibles';
  }

  @override
  String integrationsStravaSyncFailed(Object error) {
    return 'Error de sincronización: $error';
  }

  @override
  String get integrationsConnectToStrava => 'Conectar a Strava';

  @override
  String get integrationsSyncNow => 'Sincronizar ahora';

  @override
  String get integrationsDisconnect => 'Desconectar';

  @override
  String get integrationsStatusUnconfigured => 'Sin configurar';

  @override
  String get integrationsStatusConnected => 'Conectado';

  @override
  String get integrationsStatusNotConnected => 'No conectado';

  @override
  String get integrationsStatusSyncing => 'Sincronizando…';

  @override
  String get integrationsStatusError => 'Error';

  @override
  String get integrationsStatusUnavailable => 'No disponible';

  @override
  String integrationsHealthDescSupported(Object providerName) {
    return 'Importa entrenamientos completados (carreras, salidas en bici, nados) desde $providerName para que se unan a tu historial de entrenamiento.';
  }

  @override
  String get integrationsHealthDescUnsupported =>
      'Esta integración solo está disponible en dispositivos iOS y Android.';

  @override
  String get integrationsGrantPermissions => 'Conceder permisos';

  @override
  String get integrationsResetCursor => 'Restablecer cursor';

  @override
  String get integrationsDiagnostics => 'Diagnóstico';

  @override
  String get integrationsPelotonTitle => 'Peloton llega por aquí';

  @override
  String integrationsPelotonDescription(Object providerName) {
    return 'Peloton se vincula dentro de la app de Peloton, no en $providerName.\nAbre Peloton → Perfil / Configuración → busca un interruptor de $providerName y actívalo. Tus salidas en bici, carreras y caminatas fluirán hacia la tarjeta de Salud de arriba, y YAWA4U las recogerá en la próxima sincronización. No se necesita un inicio de sesión separado de Peloton aquí.';
  }

  @override
  String get integrationsFutureTitle => 'Más integraciones próximamente';

  @override
  String get integrationsFutureDescription => 'Garmin Connect y Wahoo están en la hoja de ruta.';

  @override
  String get integrationsTimeJustNow => 'ahora mismo';

  @override
  String integrationsTimeMinutesAgo(Object minutes) {
    return 'hace $minutes min';
  }

  @override
  String integrationsTimeHoursAgo(Object hours) {
    return 'hace $hours h';
  }

  @override
  String integrationsTimeDaysAgo(Object days) {
    return 'hace $days d';
  }

  @override
  String get themeEditorEditTitle => 'Editar tema';

  @override
  String get themeEditorCreateTitle => 'Crear tema';

  @override
  String themeEditorErrorLoading(Object error) {
    return 'Error al cargar el tema: $error';
  }

  @override
  String themeEditorErrorPicking(Object error) {
    return 'Error al seleccionar la imagen: $error';
  }

  @override
  String get themeEditorNameRequired => 'Ingresa un nombre para el tema';

  @override
  String get themeEditorUpdated => '¡Tema actualizado!';

  @override
  String get themeEditorCreated => '¡Tema creado!';

  @override
  String themeEditorErrorSaving(Object error) {
    return 'Error al guardar el tema: $error';
  }

  @override
  String get themeEditorStepInfo => 'Información';

  @override
  String get themeEditorStepBackgrounds => 'Fondos';

  @override
  String get themeEditorStepIcon => 'Icono';

  @override
  String get themeEditorStepColors => 'Colores';

  @override
  String get themeEditorThemeInfoTitle => 'Información del tema';

  @override
  String get themeEditorThemeInfoDesc => 'Dale a tu tema un nombre y una descripción.';

  @override
  String get themeEditorNameLabel => 'Nombre del tema';

  @override
  String get themeEditorNameHint => 'Mi tema personalizado';

  @override
  String get themeEditorDescriptionLabel => 'Descripción (opcional)';

  @override
  String get themeEditorDescriptionHint => 'Una breve descripción de tu tema';

  @override
  String get themeEditorBackgroundsTitle => 'Fondos de pantalla';

  @override
  String get themeEditorBackgroundsDesc =>
      'Elige imágenes de fondo para cada pantalla. Toca para agregar, mantén presionado para eliminar.';

  @override
  String get themeEditorWorkoutScreen => 'Pantalla de entrenamiento';

  @override
  String get themeEditorMesocyclesScreen => 'Pantalla de mesociclos';

  @override
  String get themeEditorExercisesScreen => 'Pantalla de ejercicios';

  @override
  String get themeEditorMoreScreen => 'Pantalla de más opciones';

  @override
  String get themeEditorDefaultScreen => 'Predeterminada (Calendario y otras)';

  @override
  String get themeEditorImageHasImage => 'Toca para cambiar, mantén presionado para eliminar';

  @override
  String get themeEditorImageNoImage => 'Toca para agregar imagen';

  @override
  String get themeEditorAppIconTitle => 'Icono de la app';

  @override
  String get themeEditorAppIconDesc =>
      'Elige una imagen para usar como icono de acento de tu app (se muestra en la barra de la app).';

  @override
  String get themeEditorTapToAdd => 'Toca para agregar';

  @override
  String get themeEditorRemove => 'Eliminar';

  @override
  String get themeEditorAccentColorsTitle => 'Colores de acento';

  @override
  String get themeEditorAccentColorsDesc => 'Elige los colores primario y secundario de tu tema.';

  @override
  String get themeEditorSuggestedColors => 'Sugeridos de tus imágenes:';

  @override
  String get themeEditorColorTooltip => 'Toca: Primario\nDoble toque: Secundario';

  @override
  String get themeEditorPrimaryColor => 'Color primario';

  @override
  String get themeEditorSecondaryColor => 'Color secundario';

  @override
  String get themeEditorPreview => 'Vista previa';

  @override
  String get themeEditorThemeNameFallback => 'Nombre del tema';

  @override
  String get themeEditorCustomTheme => 'Tema personalizado';

  @override
  String get themeEditorPrimaryButton => 'Primario';

  @override
  String get themeEditorSecondaryButton => 'Secundario';

  @override
  String get themeEditorBackButton => 'Atrás';

  @override
  String get themeEditorNextButton => 'Siguiente';

  @override
  String get themeEditorSaveThemeButton => 'Guardar tema';

  @override
  String get themeEditorChooseFromGallery => 'Elegir de la galería';

  @override
  String get themeEditorTakePhoto => 'Tomar una foto';

  @override
  String get skinShareTitle => 'Compartir temas';

  @override
  String get skinShareServerError =>
      'No se pudo iniciar el servidor para compartir. Asegúrate de estar conectado a WiFi.';

  @override
  String get skinShareConnectionError =>
      'No se pudo conectar al dispositivo. Asegúrate de que ambos dispositivos estén en la misma red WiFi y de estar escaneando un código QR válido para compartir temas.';

  @override
  String get skinShareNoCustomThemes => 'No hay temas personalizados para compartir';

  @override
  String get skinShareCreateThemeHint => 'Crea un tema personalizado en la configuración de temas para compartirlo.';

  @override
  String get skinShareOrReceiveTitle => 'Compartir o recibir temas';

  @override
  String get skinShareOrReceiveDesc =>
      'Selecciona temas para compartir, o escanea un código QR para recibir temas de otro dispositivo.';

  @override
  String get skinShareScanQrButton => 'Escanear código QR para recibir temas';

  @override
  String get skinShareSelectThemesHeader => 'Selecciona temas para compartir';

  @override
  String get skinShareDeselectAll => 'Deseleccionar todo';

  @override
  String get skinShareSelectAll => 'Seleccionar todos';

  @override
  String get skinShareSelectToShare => 'Selecciona temas para compartir';

  @override
  String get skinShareViaQrCode => 'Compartir por código QR';

  @override
  String get skinShareUploadToCloud => 'Subir a la nube';

  @override
  String get skinShareReadyTitle => 'Listo para compartir';

  @override
  String get skinShareScanPrompt => 'Pídele a la otra persona que escanee este código QR';

  @override
  String skinShareSharingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Compartiendo $count temas',
      one: 'Compartiendo 1 tema',
    );
    return '$_temp0';
  }

  @override
  String get skinShareSharingNote => 'Al escanearlo, estos temas se copiarán al otro dispositivo.';

  @override
  String get skinShareScannerPrompt => 'Apunta la cámara al código QR de compartir temas';

  @override
  String get skinShareCameraError => 'Error de cámara';

  @override
  String get skinShareCameraAccessFailed => 'No se pudo acceder a la cámara';

  @override
  String get skinShareGoBack => 'Volver';

  @override
  String get skinShareConnectedTo => 'Conectado a';

  @override
  String skinShareThemesAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count temas disponibles',
      one: '1 tema disponible',
    );
    return '$_temp0';
  }

  @override
  String get skinShareThemesToReceive => 'Temas por recibir:';

  @override
  String skinShareReceiveButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Recibir $count temas',
      one: 'Recibir 1 tema',
    );
    return '$_temp0';
  }

  @override
  String get skinShareThemesReceived => '¡Temas recibidos!';

  @override
  String get skinShareReceiveFailed => 'No se pudieron recibir los temas';

  @override
  String get templateShareTitle => 'Compartir plantillas';

  @override
  String get templateShareServerError =>
      'No se pudo iniciar el servidor para compartir. Asegúrate de estar conectado a WiFi.';

  @override
  String get templateShareConnectionError =>
      'No se pudo conectar al dispositivo. Asegúrate de que ambos dispositivos estén en la misma red WiFi y de estar escaneando un código QR válido para compartir plantillas.';

  @override
  String get templateShareNoSavedTitle => 'Sin plantillas guardadas';

  @override
  String get templateShareNoSavedDesc =>
      'Guarda primero un ciclo de entrenamiento como plantilla y luego podrás compartirlo aquí.\n\nPara guardar una plantilla, ve a un ciclo de entrenamiento y usa la opción \"Guardar como plantilla\".';

  @override
  String get templateShareScanQrButton => 'Escanear código QR para recibir plantillas';

  @override
  String get templateShareOrReceiveTitle => 'Compartir o recibir plantillas';

  @override
  String get templateShareOrReceiveDesc =>
      'Selecciona plantillas para compartir o escanea un código QR para recibir plantillas de otro dispositivo.';

  @override
  String get templateShareSelectHeader => 'Selecciona plantillas para compartir';

  @override
  String get templateShareDeselectAll => 'Deseleccionar todo';

  @override
  String get templateShareSelectAll => 'Seleccionar todo';

  @override
  String get templateShareSelectToShare => 'Selecciona plantillas para compartir';

  @override
  String get templateShareViaQrCode => 'Compartir por código QR';

  @override
  String get templateShareUploadToCloud => 'Subir a la nube';

  @override
  String templateShareDaysPerPeriod(Object count) {
    return '$count días/período';
  }

  @override
  String templateSharePeriodsCount(Object count) {
    return '$count períodos';
  }

  @override
  String templateShareWorkoutsCount(Object count) {
    return '$count entrenamientos';
  }

  @override
  String get templateShareReadyTitle => 'Listo para compartir';

  @override
  String get templateShareScanPrompt => 'Pídele a la otra persona que escanee este código QR';

  @override
  String templateShareSharingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Compartiendo $count plantillas',
      one: 'Compartiendo 1 plantilla',
    );
    return '$_temp0';
  }

  @override
  String get templateShareSharingNote => 'Al escanearlas, estas plantillas se copiarán al otro dispositivo.';

  @override
  String get templateShareScannerPrompt => 'Apunta la cámara al código QR de compartir plantillas';

  @override
  String get templateShareCameraError => 'Error de cámara';

  @override
  String get templateShareCameraAccessFailed => 'No se pudo acceder a la cámara';

  @override
  String get templateShareGoBack => 'Volver';

  @override
  String get templateShareConnectedTo => 'Conectado a';

  @override
  String templateShareAvailableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plantillas disponibles',
      one: '1 plantilla disponible',
    );
    return '$_temp0';
  }

  @override
  String get templateShareToReceive => 'Plantillas por recibir:';

  @override
  String templateShareReceiveButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Recibir $count plantillas',
      one: 'Recibir 1 plantilla',
    );
    return '$_temp0';
  }

  @override
  String get templateShareReceived => '¡Plantillas recibidas!';

  @override
  String get templateShareReceiveFailed => 'No se pudieron recibir las plantillas';

  @override
  String get syncTitle => 'Sincronizar datos';

  @override
  String get syncServerError =>
      'No se pudo iniciar el servidor de sincronización. Asegúrate de estar conectado a WiFi.';

  @override
  String get syncConnectionError =>
      'No se pudo conectar al dispositivo. Asegúrate de que ambos dispositivos estén en la misma red WiFi.';

  @override
  String get syncComplete => '¡Sincronización completa!';

  @override
  String get syncFailed => 'Falló la sincronización';

  @override
  String get syncFailedToLoad => 'No se pudieron cargar los datos';

  @override
  String get syncYourData => 'Tus datos';

  @override
  String get syncStatTrainingCycles => 'Ciclos de entrenamiento';

  @override
  String get syncStatSessions => 'Sesiones';

  @override
  String get syncStatExercises => 'Ejercicios';

  @override
  String get backupSectionTitle => 'Copia de seguridad';

  @override
  String get backupSectionSubtitle =>
      'Guarda tus datos en un archivo o restaura una copia anterior. Restaurar añade a tus datos existentes; no se elimina nada.';

  @override
  String get backupExportButton => 'Exportar copia de seguridad';

  @override
  String get backupRestoreButton => 'Restaurar desde archivo';

  @override
  String backupExportError(Object error) {
    return 'No se pudo exportar la copia: $error';
  }

  @override
  String get backupRestoreConfirmTitle => '¿Restaurar copia de seguridad?';

  @override
  String get backupRestoreConfirmMessage =>
      'Los elementos de la copia se añadirán a tus datos existentes. No se elimina nada y las entradas que ya existen se conservan sin cambios.';

  @override
  String backupRestoreSuccess(Object count) {
    return 'Copia restaurada — $count elementos añadidos';
  }

  @override
  String backupRestoreError(Object error) {
    return 'No se pudo restaurar la copia: $error';
  }

  @override
  String get syncMergeNote =>
      'La sincronización combina datos: se añaden los elementos del otro dispositivo, no se elimina nada.';

  @override
  String emptyWorkoutCreateCycle(Object cycleTerm) {
    return 'Crear $cycleTerm';
  }

  @override
  String get emptyWorkoutUseTemplate => 'Usar una plantilla';

  @override
  String get communityLibraryTitle => 'Biblioteca de la comunidad';

  @override
  String get communityLibrarySubtitle => 'Explora y descarga plantillas y temas compartidos';

  @override
  String get settingsDefaultUnitsHeader => 'Unidades predeterminadas';

  @override
  String get settingsPerSportUnitsLink => 'Unidades por deporte…';

  @override
  String get settingsDiscardTitle => '¿Descartar cambios?';

  @override
  String get settingsDiscardMessage => 'Tienes cambios sin guardar. ¿Salir sin guardar?';

  @override
  String get settingsDiscardButton => 'Descartar';

  @override
  String get settingsKeepEditingButton => 'Seguir editando';

  @override
  String cycleCreateSummary(Object periods, Object days) {
    return 'Crea $periods períodos × $days días de entrenamiento';
  }

  @override
  String get cycleListMenuNeedsExercisesHint => 'Primero añade ejercicios a cada día de entrenamiento';

  @override
  String cycleListDeleteDialogDetail(Object workoutCount, Object loggedSetCount) {
    return 'Esto elimina permanentemente $workoutCount entrenamientos, incluidas $loggedSetCount series registradas de tu historial.';
  }

  @override
  String get cardioSessionPromoteTitle => '¿Registrar esta sesión?';

  @override
  String get cardioSessionPromoteMessage =>
      'Al guardar, esta sesión planificada se marcará como completada con los valores ingresados.';

  @override
  String get cardioSessionModePlan => 'Planificar';

  @override
  String get cardioSessionModeLog => 'Registrar';

  @override
  String get cardioSessionRpeClearTooltip => 'Borrar valoración de esfuerzo';

  @override
  String get integrationsStravaDisconnectTitle => '¿Desconectar Strava?';

  @override
  String get integrationsStravaDisconnectMessage =>
      'Las nuevas actividades dejarán de sincronizarse. Los entrenamientos ya importados permanecen en este dispositivo.';

  @override
  String get integrationsStravaDisconnectConfirm => 'Desconectar';

  @override
  String get exerciseCardHistoryRetry => 'No se pudo cargar el historial — toca para reintentar';

  @override
  String get cycleComparisonLoadError => 'No se pudieron cargar las estadísticas del ciclo';

  @override
  String calendarDropdownPeriodAdded(Object number) {
    return 'Período $number añadido';
  }

  @override
  String get calendarDropdownCannotRemovePeriod => 'No se puede eliminar: debe haber al menos 1 período';

  @override
  String calendarDropdownPeriodRemoved(Object number) {
    return 'Período $number eliminado';
  }

  @override
  String get integrationsUnknownError => 'Error desconocido';

  @override
  String integrationsLastRunSummary(Object total, Object imported, Object duplicates, Object unsupported) {
    return 'Última ejecución: $total encontrados · $imported importados · $duplicates ya existentes · $unsupported no-cardio omitidos';
  }

  @override
  String get integrationsAppleHealthRequired => 'Se necesita acceso a Apple Health';

  @override
  String get integrationsAppleHealthIntro =>
      'YAWA4U lee entrenamientos de Apple Health. El acceso fue denegado o aún no se ha concedido.';

  @override
  String get integrationsAppleHealthStep1 => '1. Abre Ajustes → Salud → Acceso a datos y dispositivos';

  @override
  String get integrationsAppleHealthStep2 => '2. Elige YAWA4U';

  @override
  String get integrationsAppleHealthStep3 => '3. Activa las categorías de entrenamiento que quieras compartir';

  @override
  String get integrationsOpenSettings => 'Abrir Ajustes';

  @override
  String get communitySignInButton => 'Iniciar sesión';

  @override
  String communityTemplateSaved(Object name) {
    return '\"$name\" guardado — ciclo borrador creado';
  }

  @override
  String get statsNoStrengthTitle => 'Aún no hay entrenamientos registrados';

  @override
  String get statsNoStrengthSubtitle =>
      'Las estadísticas aparecerán aquí cuando registres tu primer entrenamiento de fuerza.';

  @override
  String get syncWithAnotherDevice => 'Sincronizar con otro dispositivo';

  @override
  String get syncWifiRequired => 'Ambos dispositivos deben estar en la misma red WiFi.';

  @override
  String get syncHostButton => 'Alojar sincronización (mostrar código QR)';

  @override
  String get syncScanQrButton => 'Escanear código QR';

  @override
  String get syncWaitingForConnection => 'Esperando conexión...';

  @override
  String get syncScanFromOtherDevice => 'Escanea este código QR desde el otro dispositivo';

  @override
  String get syncScannerPrompt => 'Apunta la cámara al código QR';

  @override
  String get syncCameraError => 'Error de cámara';

  @override
  String get syncCameraAccessFailed => 'No se pudo acceder a la cámara';

  @override
  String get syncGoBack => 'Volver';

  @override
  String get pasteCodeButton => 'Ingresar código manualmente';

  @override
  String get pasteCodeDialogTitle => 'Ingresa el código de conexión';

  @override
  String get pasteCodeDialogHint => 'Pega el código que se muestra en el otro dispositivo';

  @override
  String get pasteCodeDialogConfirm => 'Conectar';

  @override
  String get syncConnectedTo => 'Conectado a';

  @override
  String get syncWhatToDo => '¿Qué te gustaría hacer?';

  @override
  String syncImportFrom(Object deviceName) {
    return 'Importar desde $deviceName';
  }

  @override
  String syncExportTo(Object deviceName) {
    return 'Exportar a $deviceName';
  }

  @override
  String get syncDisconnect => 'Desconectar';

  @override
  String get communityTabPrograms => 'Programas';

  @override
  String get communityTabThemes => 'Temas';

  @override
  String get communityTabMyUploads => 'Mis subidas';

  @override
  String get communityUploadTooltip => 'Subir';

  @override
  String get communityShareProgram => 'Compartir un programa';

  @override
  String get communityShareTheme => 'Compartir un tema';

  @override
  String get communitySortBy => 'Ordenar por:';

  @override
  String get communitySortPopular => 'Populares';

  @override
  String get communitySortRecent => 'Recientes';

  @override
  String get communityNoProgramsTitle => 'Aún no hay programas compartidos';

  @override
  String get communityNoProgramsSubtitle => '¡Sé el primero en compartir un programa!';

  @override
  String get communityCouldNotLoadPrograms => 'No se pudieron cargar los programas de la comunidad';

  @override
  String get communityNoThemesTitle => 'Aún no hay temas compartidos';

  @override
  String get communityNoThemesSubtitle => '¡Sé el primero en compartir un tema!';

  @override
  String get communityCouldNotLoadThemes => 'No se pudieron cargar los temas de la comunidad';

  @override
  String get communitySignInToSeeUploads => 'Inicia sesión para ver tus subidas';

  @override
  String get communityMyPrograms => 'Mis programas';

  @override
  String get communityNoProgramsUploaded => 'Aún no has subido programas.';

  @override
  String get communityFailedToLoadPrograms => 'No se pudieron cargar tus programas';

  @override
  String get communityMyThemes => 'Mis temas';

  @override
  String get communityNoThemesUploaded => 'Aún no has subido temas.';

  @override
  String get communityFailedToLoadThemes => 'No se pudieron cargar tus temas';

  @override
  String get communityDeleteProgramTitle => '¿Eliminar programa?';

  @override
  String communityDeleteProgramContent(Object name) {
    return '¿Quitar \"$name\" de la biblioteca de la comunidad? Esta acción no se puede deshacer.';
  }

  @override
  String get communityDeleteThemeTitle => '¿Eliminar tema?';

  @override
  String communityDeleteThemeContent(Object name) {
    return '¿Quitar \"$name\" de la biblioteca de la comunidad? Esta acción no se puede deshacer.';
  }

  @override
  String communityItemDeleted(Object name) {
    return '\"$name\" eliminado';
  }

  @override
  String communityFailedToDelete(Object error) {
    return 'No se pudo eliminar: $error';
  }

  @override
  String communityDownloadCount(Object count) {
    return '$count descargas';
  }

  @override
  String get communityDeleteTooltip => 'Eliminar';

  @override
  String communityPeriodsCount(Object count) {
    return '$count períodos';
  }

  @override
  String communitySessionsCount(Object count) {
    return '$count sesiones';
  }

  @override
  String get communityColorPreview => 'Vista previa de colores';

  @override
  String get communityNoColorData => 'No hay datos de color disponibles';

  @override
  String get communityColorPreviewUnavailable => 'Vista previa de colores no disponible';

  @override
  String get communityInvalidThemeData => 'Este tema tiene datos no válidos y no se puede descargar';

  @override
  String communitySavedToThemes(Object name) {
    return '\"$name\" guardado en tus temas';
  }

  @override
  String communitySavedToPrograms(Object name) {
    return '\"$name\" guardado en tus programas';
  }

  @override
  String communityDownloadFailed(Object error) {
    return 'Falló la descarga: $error';
  }

  @override
  String get communityDownloadThemeButton => 'DESCARGAR TEMA';

  @override
  String get communityDownloadProgramButton => 'DESCARGAR PROGRAMA';

  @override
  String get communitySavedButton => 'GUARDADO';

  @override
  String get communitySessionsHeader => 'Sesiones';

  @override
  String get communityDurationLabel => 'Duración';

  @override
  String get communityPerPeriodLabel => 'Por período';

  @override
  String get communityRecoveryLabel => 'Recuperación';

  @override
  String communityDaysCount(Object count) {
    return '$count días';
  }

  @override
  String communityPeriodNumber(Object number) {
    return 'Período $number';
  }

  @override
  String communityDayFallback(Object number) {
    return 'Día $number';
  }

  @override
  String communityCardioSession(Object sport) {
    return 'Sesión de $sport';
  }

  @override
  String communityExerciseCount(Object count) {
    return '$count ejercicios';
  }

  @override
  String communitySetsReps(Object sets, Object reps) {
    return '$sets series × $reps';
  }

  @override
  String get uploadShareThemeTitle => 'Compartir un tema';

  @override
  String get uploadShareProgramTitle => 'Compartir un programa';

  @override
  String get uploadSelectThemeDesc => 'Selecciona un tema personalizado para compartir con la comunidad.';

  @override
  String get uploadSelectProgramDesc => 'Selecciona un programa para compartir con la comunidad.';

  @override
  String get uploadThemeLabel => 'Tema';

  @override
  String get uploadProgramLabel => 'Programa';

  @override
  String get uploadNoCustomThemes => 'No hay temas personalizados para compartir.';

  @override
  String get uploadCreateCustomThemeHint => 'Primero crea un tema personalizado en Ajustes.';

  @override
  String get uploadNoSavedPrograms => 'No hay programas guardados para compartir.';

  @override
  String get uploadDisplayNameLabel => 'Tu nombre visible';

  @override
  String get uploadDisplayNameHint => 'Cómo verán los demás tu nombre';

  @override
  String get uploadTagsLabel => 'Etiquetas (opcional)';

  @override
  String get uploadTemplateTagsHint => 'principiante, fuerza, 4 semanas';

  @override
  String get uploadThemeTagsHint => 'oscuro, minimalista, colorido';

  @override
  String get uploadTemplateTagsHelper => 'Etiquetas separadas por comas para que otros encuentren tu programa';

  @override
  String get uploadThemeTagsHelper => 'Etiquetas separadas por comas para que otros encuentren tu tema';

  @override
  String get uploadPublishThemeButton => 'PUBLICAR TEMA';

  @override
  String get uploadPublishProgramButton => 'PUBLICAR PROGRAMA';

  @override
  String get uploadEnterDisplayName => 'Ingresa un nombre visible';

  @override
  String get uploadNotSignedIn => 'No has iniciado sesión. Inténtalo de nuevo.';

  @override
  String uploadPublishedToCommunity(Object name) {
    return '¡\"$name\" publicado en la comunidad!';
  }

  @override
  String uploadFailed(Object error) {
    return 'Falló la subida: $error';
  }

  @override
  String uploadErrorLoadingTemplates(Object error) {
    return 'Error al cargar las plantillas: $error';
  }

  @override
  String uploadTemplateSummary(Object periods, Object days, Object sessions) {
    return '$periods períodos, $days días/período, $sessions sesiones';
  }

  @override
  String get moreScreenTitle => 'YAWA4U';

  @override
  String versionLabel(Object version) {
    return 'Versión $version';
  }

  @override
  String get themeMode => 'Modo de tema';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Oscuro';

  @override
  String get sectionAppearance => 'Apariencia';

  @override
  String get sectionTraining => 'Entrenamiento';

  @override
  String get sectionIntegrationsData => 'Integraciones y datos';

  @override
  String get sectionPreferences => 'Preferencias';

  @override
  String get sectionHelpFeedback => 'Ayuda y comentarios';

  @override
  String get sectionAbout => 'Acerca de';

  @override
  String get sectionDeveloper => 'Desarrollador';

  @override
  String get themeTitle => 'Tema';

  @override
  String get themeSubtitle => 'Elige el tema de la app';

  @override
  String get statisticsTitle => 'Estadísticas';

  @override
  String get statisticsSubtitle => 'Volumen, récords y progreso';

  @override
  String get unitsTitle => 'Unidades';

  @override
  String get unitsSubtitle => 'Métricas o imperiales, por deporte';

  @override
  String get zonesTitle => 'Zonas';

  @override
  String get zonesSubtitle => 'Zonas de frecuencia cardíaca por deporte';

  @override
  String get integrationsSubtitle => 'Apple Health / Health Connect — incluye Peloton';

  @override
  String get syncDataTitle => 'Sincronizar datos';

  @override
  String get syncDataSubtitle => 'Sincroniza con otro dispositivo por WiFi';

  @override
  String get shareTemplateTitle => 'Compartir plantilla';

  @override
  String get shareTemplateSubtitle => 'Comparte plantillas de entrenamiento por WiFi';

  @override
  String get shareAppTitle => 'Compartir app';

  @override
  String get shareAppSubtitle => 'Comparte YAWA4U con amigos';

  @override
  String get shareAppText =>
      '¡Mira YAWA4U, el mejor registro de entrenamientos! https://testflight.apple.com/join/YVQsRjzD';

  @override
  String get settingsSubtitle => 'Terminología, equipo, métricas corporales';

  @override
  String get sendFeedbackTitle => 'Enviar comentarios';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSheetTitle => 'Idioma';

  @override
  String get languageSheetSubtitle => 'Elige el idioma de la app';

  @override
  String get websiteTitle => 'Sitio web';

  @override
  String get privacyPolicyTitle => 'Política de privacidad';

  @override
  String get sentryDebugTitle => 'Depuración de Sentry';

  @override
  String get sentryDebugSubtitle => 'Probar la integración de Sentry';

  @override
  String get exercisesTitle => 'Ejercicios';

  @override
  String get exercisesNoActiveCycleTitle => 'Sin ciclo de entrenamiento activo';

  @override
  String get exercisesNoActiveCycleSubtitle => 'Crea e inicia un ciclo de entrenamiento para comenzar';

  @override
  String get exercisesNoScheduledTitle => 'No hay ejercicios programados';

  @override
  String exercisesNoScheduledSubtitleForDay(Object period, Object day) {
    return 'Agrega ejercicios para el período $period, día $day';
  }

  @override
  String get exercisesNoScheduledSubtitle => 'Agrega ejercicios para este día';

  @override
  String get exercisesAddExercise => 'Agregar ejercicio';

  @override
  String exercisesPeriodDayHeader(Object period, Object day) {
    return 'PERÍODO $period DÍA $day';
  }

  @override
  String exercisesPeriodDayHeaderWithName(Object period, Object day, Object dayName) {
    return 'PERÍODO $period DÍA $day $dayName';
  }

  @override
  String get exercisesSelectDayTooltip => 'Seleccionar día';

  @override
  String get exercisesToggleHistoryTooltip => 'Mostrar/ocultar historial';

  @override
  String get exercisesMenuNote => 'Nota';

  @override
  String get exercisesMenuSummary => 'Resumen';

  @override
  String get exercisesMenuWorkoutHeader => 'ENTRENAMIENTO';

  @override
  String get exercisesMenuAddExercise => 'Agregar ejercicio';

  @override
  String get exercisesMenuReset => 'Reiniciar';

  @override
  String get exercisesFinishWorkout => 'FINALIZAR ENTRENAMIENTO';

  @override
  String get exercisesResetTitle => 'Reiniciar entrenamiento';

  @override
  String get exercisesResetContent =>
      'Esto borrará todas las series registradas y los datos ingresados de este entrenamiento. Esta acción no se puede deshacer.';

  @override
  String get exercisesResetAction => 'REINICIAR';

  @override
  String get exercisesWorkoutReset => 'Entrenamiento reiniciado';

  @override
  String get exercisesHistoryHeader => 'Historial';

  @override
  String get exercisesUnknownCycle => 'Ciclo de entrenamiento desconocido';

  @override
  String exercisesCycleHistoryHeader(Object name, Object periods) {
    return '$name - $periods PERÍODOS';
  }

  @override
  String get exercisesDeloadLabel => 'DESCARGA';

  @override
  String get exercisesUnknownDate => 'Fecha desconocida';

  @override
  String get exercisesHistoryPeriodLabel => 'PERÍODO ';

  @override
  String get exercisesHistoryDayLabel => ' - DÍA ';

  @override
  String get exercisesBodyweightAbbrev => 'PC';

  @override
  String exercisesCycleCompletedTitle(Object cycleTerm) {
    return '¡$cycleTerm completado!';
  }

  @override
  String exercisesCycleCompletedContent(Object cycleTerm) {
    return '¡Felicitaciones! Has terminado todos los entrenamientos de este $cycleTerm.';
  }

  @override
  String get exercisesAwesome => 'GENIAL';

  @override
  String exercisesCycleNoteTitle(Object cycleTerm) {
    return 'Nota del $cycleTerm';
  }

  @override
  String exercisesCycleNoteHint(Object cycleTerm) {
    return 'Ingresa una nota para este $cycleTerm...';
  }

  @override
  String exercisesErrorSavingNote(Object error) {
    return 'Error al guardar la nota: $error';
  }

  @override
  String get exercisesWeightUnitLbs => 'lb';

  @override
  String get statsTitle => 'Estadísticas';

  @override
  String get statsTabOverview => 'Resumen';

  @override
  String get statsTabCardio => 'Cardio';

  @override
  String get statsTabCompare => 'Comparar';

  @override
  String get statsTabBody => 'Cuerpo';

  @override
  String get statsNoCardioTitle => 'Aún no hay cardio registrado';

  @override
  String get statsNoCardioSubtitle =>
      'Registra una carrera, paseo en bici o nado desde la pestaña Más; las estadísticas aparecerán aquí cuando tengas una o dos sesiones registradas.';

  @override
  String get statsWeeklyVolume => 'Volumen semanal — últimas 12 semanas';

  @override
  String get statsBySport => 'Por deporte';

  @override
  String get statsLifetimeTotals => 'Totales históricos';

  @override
  String get statsCardioSessions => 'Sesiones';

  @override
  String get statsCardioHours => 'Horas';

  @override
  String get statsCardioCompleted => 'Completadas';

  @override
  String get statsNoMeasurementsTitle => 'Aún no hay mediciones';

  @override
  String get statsNoMeasurementsSubtitle => 'Agrega mediciones corporales en Ajustes\npara ver tu progreso aquí.';

  @override
  String get statsWeightLabel => 'Peso';

  @override
  String statsWeightValueKg(Object weight) {
    return '$weight kg';
  }

  @override
  String get statsBmiLabel => 'IMC';

  @override
  String get statsEntriesLabel => 'Registros';

  @override
  String get statsWeightProgression => 'Progresión de peso';

  @override
  String get statsBodyComposition => 'Composición corporal';

  @override
  String statsBodyFatEntry(Object fatPercent) {
    return '$fatPercent% de grasa corporal';
  }

  @override
  String statsBodyFatWithLean(Object fatPercent, Object leanMass) {
    return '$fatPercent% de grasa corporal / $leanMass kg magro';
  }

  @override
  String statsErrorLoadingMeasurements(Object error) {
    return 'Error al cargar las mediciones: $error';
  }

  @override
  String get statsVolumeByMuscleGroup => 'Volumen por grupo muscular';

  @override
  String get statsVolumeProgression => 'Progresión de volumen';

  @override
  String get statsMostUsedExercises => 'Ejercicios más usados';

  @override
  String get statsPersonalRecords => 'Récords personales';

  @override
  String get statsSessionsLabel => 'Sesiones';

  @override
  String statsSessionsValue(Object completed, Object total) {
    return '$completed/$total';
  }

  @override
  String get statsCompletionLabel => 'Finalización';

  @override
  String statsCompletionValue(Object percent) {
    return '$percent%';
  }

  @override
  String get statsTotalSetsLabel => 'Series totales';

  @override
  String statsExerciseFrequencyCount(Object count) {
    return '${count}x';
  }

  @override
  String statsPersonalRecordWeight(Object weight) {
    return '$weight lb';
  }

  @override
  String statsActiveCycleLabel(Object cycleName) {
    return '$cycleName (Activo)';
  }

  @override
  String get restTimerDialogTitle => 'Temporizador de descanso';

  @override
  String get restTimerUseDefault => 'Usar predeterminado';

  @override
  String get restTimerBasedOnSetType => 'Según el tipo de serie';

  @override
  String get restTimerDuration => 'Duración';

  @override
  String addSessionPlanSport(Object sport) {
    return 'Planificar $sport';
  }

  @override
  String get addSessionTitle => 'Agregar sesión';

  @override
  String get selectMuscleGroupTitle => 'Selecciona grupo muscular';

  @override
  String get startFromTemplate => 'Empezar desde una plantilla';

  @override
  String planSportButton(Object sport) {
    return 'Planificar $sport';
  }

  @override
  String sessionPlannedSnackbar(Object sport) {
    return 'Sesión de $sport planificada';
  }

  @override
  String failedToSave(Object error) {
    return 'No se pudo guardar: $error';
  }

  @override
  String get createCustomExerciseTitle => 'Crear ejercicio personalizado';

  @override
  String get exerciseNameLabel => 'Nombre del ejercicio';

  @override
  String get exerciseNameHint => 'p. ej., Cruce de poleas para pecho';

  @override
  String get exerciseNameRequired => 'Ingresa el nombre del ejercicio';

  @override
  String get exerciseNameMinLength => 'El nombre debe tener al menos 3 caracteres';

  @override
  String get muscleGroupLabel => 'Grupo muscular';

  @override
  String get secondaryMuscleGroupLabel => 'Grupo muscular secundario (opcional)';

  @override
  String get secondaryMuscleGroupNone => 'Ninguno';

  @override
  String get equipmentTypeLabel => 'Tipo de equipo';

  @override
  String get restTimerOptionalLabel => 'Temporizador de descanso (opcional)';

  @override
  String get restTimerHint => 'p. ej., 90';

  @override
  String get restTimerSuffix => 'segundos';

  @override
  String get restTimerValidation => 'Ingresa un valor entre 0 y 600';

  @override
  String get exerciseNameExists => 'Ya existe un ejercicio con este nombre';

  @override
  String failedToCreateExercise(Object error) {
    return 'No se pudo crear el ejercicio: $error';
  }

  @override
  String get creatingButton => 'Creando...';

  @override
  String get createButton => 'Crear';

  @override
  String get jointPainLabel => 'Dolor articular';

  @override
  String get musclePumpLabel => 'Congestión muscular';

  @override
  String get workloadLabel => 'Carga de trabajo';

  @override
  String get detailTab => 'Detalle';

  @override
  String get historyTab => 'Historial';

  @override
  String get videoAvailable => 'Video disponible';

  @override
  String get watchOnYouTube => 'Ver en YouTube';

  @override
  String get viewOnYouTube => 'Ver en YouTube';

  @override
  String get noVideoAvailable => 'No hay video disponible';

  @override
  String get notesLabel => 'Notas';

  @override
  String get noNotesAdded => 'Aún no hay notas.';

  @override
  String errorLoadingHistory(Object error) {
    return 'Error al cargar el historial: $error';
  }

  @override
  String get noHistoryYet => 'Aún no hay historial';

  @override
  String get noHistoryDescription => 'Completa series para crear tu historial de ejercicios.';

  @override
  String get weightProgressionLabel => 'PROGRESIÓN DE PESO';

  @override
  String get unknownTrainingCycle => 'Ciclo de entrenamiento desconocido';

  @override
  String trainingCyclePeriodsHeader(Object name, Object count) {
    return '$name - $count PERÍODOS';
  }

  @override
  String get unknownDate => 'Fecha desconocida';

  @override
  String get recoveryLabel => 'RECUPERACIÓN';

  @override
  String periodDayLabel(Object period, Object day) {
    return 'PERÍODO $period - DÍA $day';
  }

  @override
  String get bodyweightAbbrev => 'PC';

  @override
  String get setTypesTitle => 'Tipos de serie';

  @override
  String get regularSetBadge => 'REG';

  @override
  String get trainingCycleNoteTitle => 'Nota del ciclo de entrenamiento';

  @override
  String get workoutNoteTitle => 'Nota del entrenamiento';

  @override
  String get exerciseNoteTitle => 'Nota del ejercicio';

  @override
  String get sessionNoteTitle => 'Nota de la sesión';

  @override
  String get trainingCycleNoteHint => 'Escribe una nota para este ciclo de entrenamiento...';

  @override
  String get workoutNoteHint => 'Escribe una nota para este entrenamiento...';

  @override
  String get exerciseNoteHint => 'Escribe una nota para este ejercicio...';

  @override
  String get sessionNoteHint => 'Escribe una nota para esta sesión...';

  @override
  String get pinToExercise => 'Fijar al ejercicio';

  @override
  String get renameTitle => 'Cambiar nombre';

  @override
  String get trainingCycleNameHint => 'Nombre del ciclo de entrenamiento';

  @override
  String get updateDayLabelTitle => 'Actualizar etiqueta del día';

  @override
  String get updateDayLabelDesc => 'Puedes aplicar una etiqueta de día de la semana diferente a este día.';

  @override
  String get mondayLabel => 'Lunes';

  @override
  String get tuesdayLabel => 'Martes';

  @override
  String get wednesdayLabel => 'Miércoles';

  @override
  String get thursdayLabel => 'Jueves';

  @override
  String get fridayLabel => 'Viernes';

  @override
  String get saturdayLabel => 'Sábado';

  @override
  String get sundayLabel => 'Domingo';

  @override
  String get applyToAllDays => 'Aplicar a todos los días en esta posición';

  @override
  String get avgHrLabel => 'FC prom.';

  @override
  String get bpmSuffix => 'lpm';

  @override
  String get logSessionTooltip => 'Registrar sesión';

  @override
  String get logSessionTitle => 'Registrar sesión';

  @override
  String get cardioTargetLabel => 'OBJETIVO';

  @override
  String get cardioNoTargetSet => 'Sin objetivo definido';

  @override
  String cardioIntervalsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count intervalos',
      one: '1 intervalo',
    );
    return '$_temp0';
  }

  @override
  String get cardioCompletedStatus => 'Completada';

  @override
  String get cardioAddFeedback => 'Agregar comentarios';

  @override
  String get cardioLogSession => 'Registrar sesión';

  @override
  String get cardioSessionSkipped => 'Sesión omitida';

  @override
  String get cardioSkippedFooter => 'Omitida';

  @override
  String get cardioSessionMenuHeader => 'SESIÓN';

  @override
  String get cardioNotesMenuItem => 'Notas';

  @override
  String get cardioMoveUpMenuItem => 'Subir';

  @override
  String get cardioMoveDownMenuItem => 'Bajar';

  @override
  String get cardioReplaceMenuItem => 'Reemplazar';

  @override
  String get cardioSkipSessionMenuItem => 'Omitir sesión';

  @override
  String get cardioDeleteSessionMenuItem => 'Eliminar sesión';

  @override
  String get cardioDistanceMetric => 'Distancia';

  @override
  String get cardioDurationMetric => 'Duración';

  @override
  String get cardioSwolfMetric => 'SWOLF';

  @override
  String get cardioPaceMetric => 'Ritmo';

  @override
  String get cardioAvgSpeedMetric => 'Velocidad prom.';

  @override
  String cardioLapsFormat(Object count) {
    return '$count vueltas';
  }

  @override
  String get cardioPoolLabel => 'piscina';

  @override
  String get cardioAvgLabel => 'prom.';

  @override
  String get cardioMaxLabel => 'máx.';

  @override
  String cardioElevationGain(Object meters) {
    return '$meters m';
  }

  @override
  String cardioHrBpm(Object bpm) {
    return '$bpm lpm';
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
  String get distanceLabel => 'Distancia';

  @override
  String get metersSuffix => 'm';

  @override
  String get yardsSuffix => 'yd';

  @override
  String get kilometersSuffix => 'km';

  @override
  String get milesSuffix => 'mi';

  @override
  String get durationLabel => 'Duración';

  @override
  String get durationHint => '00:30:00';

  @override
  String get durationFormatError => 'Usa MM:SS o HH:MM:SS';

  @override
  String get insertColonTooltip => 'Insertar dos puntos';

  @override
  String get readyToTrain => '¿Listo para entrenar?';

  @override
  String get pickSportPrompt => 'Elige un deporte para agregar la sesión de hoy.';

  @override
  String addSportSessionSemantic(Object sport) {
    return 'Agregar una sesión de $sport';
  }

  @override
  String get thisWeekTitle => 'Esta semana';

  @override
  String get nothingLoggedYet => 'Aún no hay nada registrado: tu próxima sesión aparecerá aquí.';

  @override
  String strengthSessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesiones de fuerza',
      one: '1 sesión de fuerza',
    );
    return '$_temp0';
  }

  @override
  String get calendarLegendTitle => 'Leyenda del calendario';

  @override
  String get legendWorkoutStatus => 'Estado del entrenamiento';

  @override
  String get legendCompleted => 'Completado';

  @override
  String get legendCompletedDesc => 'Todas las sesiones del día están hechas';

  @override
  String get legendPartiallyCompleted => 'Parcialmente completado';

  @override
  String get legendPartiallyCompletedDesc => 'Algunas sesiones están hechas';

  @override
  String get legendScheduled => 'Programado';

  @override
  String get legendScheduledDesc => 'Día de sesión aún no completado';

  @override
  String get legendRecoveryPeriod => 'Período de recuperación';

  @override
  String get legendRecoveryPeriodDesc => 'Día de descarga/recuperación';

  @override
  String get legendIndicators => 'Indicadores';

  @override
  String get legendPeriodDay => 'P#D#';

  @override
  String get legendPeriodDayDesc => 'Número de período y día (p. ej., P2D3 = Período 2, Día 3)';

  @override
  String get legendColoredDots => 'Puntos de colores';

  @override
  String get legendColoredDotsDesc => 'Grupos musculares trabajados';

  @override
  String get legendBorderHighlight => 'Borde resaltado';

  @override
  String get legendBorderHighlightDesc => 'Fecha de hoy';

  @override
  String get legendSelectionBorder => 'Borde de selección';

  @override
  String get legendSelectionBorderDesc => 'Fecha seleccionada actualmente';

  @override
  String get legendPeriodColors => 'Colores de período';

  @override
  String get legendPeriodColorsDesc =>
      'Cada período tiene un tono de fondo distinto para ayudar a visualizar los bloques de entrenamiento.';

  @override
  String get moveSessionTitle => 'Mover sesión';

  @override
  String moveFromLabel(Object period, Object day) {
    return 'Desde Período $period, Día $day';
  }

  @override
  String get moveToLabel => 'Mover a:';

  @override
  String get periodDropdownLabel => 'Período';

  @override
  String get dayDropdownLabel => 'Día';

  @override
  String get moveModeLabel => 'Modo de movimiento:';

  @override
  String get shiftSubsequentTitle => 'Desplazar siguientes';

  @override
  String get shiftSubsequentDesc => 'Mover esta sesión y desplazar todas las sesiones posteriores';

  @override
  String get swapTitle => 'Intercambiar';

  @override
  String get swapDesc => 'Intercambiar con la sesión de la fecha de destino';

  @override
  String get singleTitle => 'Individual';

  @override
  String get singleDesc => 'Mover solo esta sesión (puede dejar huecos)';

  @override
  String get moveButton => 'Mover';

  @override
  String get moveUndoneSnackbar => 'Movimiento deshecho';

  @override
  String undoWithDescription(Object description) {
    return 'Deshacer: $description';
  }

  @override
  String get undoLastChange => 'Deshacer: último cambio';

  @override
  String get undoNoRecentChanges => 'Deshacer movimiento (sin cambios recientes)';

  @override
  String get editCalendarTitle => 'Editar calendario';

  @override
  String get editCalendarRestDay => 'Día de descanso';

  @override
  String editCalendarPeriodDay(Object period, Object day) {
    return 'Período $period, Día $day';
  }

  @override
  String get removeRestDayLabel => 'Quitar día de descanso';

  @override
  String get removeRestDayDesc =>
      'Quitar este día de descanso y desplazar hacia atrás todos los entrenamientos futuros';

  @override
  String get insertDayBeforeLabel => 'Insertar día antes';

  @override
  String get insertDayBeforeDesc =>
      'Agregar un día de descanso aquí, desplazando hacia adelante este y todos los entrenamientos futuros';

  @override
  String get changeUndoneSnackbar => 'Cambio deshecho';

  @override
  String get statusDone => 'Hecho';

  @override
  String get statusSkipped => 'Omitido';

  @override
  String get statusPlanned => 'Planificado';

  @override
  String setsProgress(Object completed, Object total) {
    return '$completed/$total';
  }

  @override
  String moreCount(Object count) {
    return '+$count más';
  }

  @override
  String get dropHere => 'Suelta aquí';

  @override
  String exerciseCardWeightSuggestion(Object weight, Object unit) {
    return '↑ Prueba $weight $unit';
  }

  @override
  String get exerciseCardInfoTooltip => 'Información del ejercicio';

  @override
  String exerciseCardOptionsSemantics(Object exerciseName) {
    return 'Opciones del ejercicio para $exerciseName';
  }

  @override
  String get exerciseCardColumnWeight => 'PESO';

  @override
  String get exerciseCardColumnReps => 'REPS';

  @override
  String get exerciseCardColumnLog => 'REGISTRO';

  @override
  String get exerciseCardMenuExercise => 'EJERCICIO';

  @override
  String get exerciseCardMenuNewNote => 'Nueva nota';

  @override
  String get exerciseCardMenuMoveUp => 'Subir';

  @override
  String get exerciseCardMenuMoveDown => 'Bajar';

  @override
  String get exerciseCardMenuReplace => 'Reemplazar';

  @override
  String get exerciseCardMenuJointPain => 'Dolor articular';

  @override
  String exerciseCardMenuRestTimerValue(Object seconds) {
    return 'Descanso: $seconds s';
  }

  @override
  String get exerciseCardMenuSetRestTimer => 'Configurar temporizador de descanso';

  @override
  String get exerciseCardMenuAddSet => 'Agregar serie';

  @override
  String get exerciseCardMenuSkipSets => 'Omitir series';

  @override
  String get exerciseCardMenuDeleteExercise => 'Eliminar ejercicio';

  @override
  String exerciseCardWeightSemantics(Object setNumber) {
    return 'Peso para la serie $setNumber';
  }

  @override
  String exerciseCardRepsSemantics(Object setNumber) {
    return 'Reps para la serie $setNumber';
  }

  @override
  String exerciseCardRepsHintRir(Object rir) {
    return '$rir RIR';
  }

  @override
  String get exerciseCardRepsHint => 'RIR';

  @override
  String exerciseCardSetTypeSemantics(Object setTypeName) {
    return 'Serie $setTypeName';
  }

  @override
  String exerciseCardLogSetSemantics(Object setNumber) {
    return 'Registrar serie $setNumber';
  }

  @override
  String get exerciseCardSetMenuHeader => 'SERIE';

  @override
  String get exerciseCardSetMenuAddBelow => 'Agregar serie debajo';

  @override
  String get exerciseCardSetMenuSkipSet => 'Omitir serie';

  @override
  String get exerciseCardSetMenuUnskipSet => 'No omitir serie';

  @override
  String get exerciseCardSetMenuDeleteSet => 'Eliminar serie';

  @override
  String get exerciseCardSetTypeHeader => 'TIPO DE SERIE';

  @override
  String get weeklyVolumeChartEmpty => 'Aún no hay cardio en este rango';

  @override
  String get cycleComparisonNeedTwo => 'Se necesitan al menos 2 ciclos para comparar';

  @override
  String get cycleComparisonUnlockMessage => 'Completa un ciclo de entrenamiento para desbloquear las comparaciones.';

  @override
  String get cycleComparisonCycleA => 'Ciclo A';

  @override
  String get cycleComparisonCycleB => 'Ciclo B';

  @override
  String get cycleComparisonSelectPrompt => 'Selecciona dos ciclos para comparar';

  @override
  String get cycleComparisonCompletion => 'Finalización';

  @override
  String get cycleComparisonTotalSets => 'Series totales';

  @override
  String get cycleComparisonWorkouts => 'Entrenamientos';

  @override
  String get cycleComparisonSetsByMuscle => 'Series por grupo muscular';

  @override
  String get cycleComparisonPrChanges => 'Cambios en récords personales';

  @override
  String cycleComparisonPrSubtitle(Object weightA, Object weightB) {
    return '$weightA → $weightB lbs';
  }

  @override
  String get volumeBarChartNoData => 'Aún no hay datos';

  @override
  String get volumeLineChartNoData => 'Aún no hay datos de volumen';

  @override
  String get weightChartNoMeasurements => 'Aún no hay mediciones';

  @override
  String get weightChartNeedTwo => 'Se necesitan al menos 2 mediciones para mostrar un gráfico';

  @override
  String get emailLinkVerificationSent => 'Correo de verificación enviado';

  @override
  String get emailLinkSignInTitle => 'Iniciar sesión';

  @override
  String get emailLinkVerifyTitle => 'Verifica para subir';

  @override
  String get emailLinkSignInDesc => 'Inicia sesión con el correo y la contraseña que usaste en tu otro dispositivo.';

  @override
  String get emailLinkVerifyDesc =>
      'Vincula un correo a tu cuenta para compartir contenido con la comunidad. Tus datos anónimos se conservan.';

  @override
  String get emailLinkEmailLabel => 'Correo';

  @override
  String get emailLinkPasswordLabel => 'Contraseña';

  @override
  String get emailLinkEmailEmpty => 'Ingresa tu correo';

  @override
  String get emailLinkEmailInvalid => 'Ingresa un correo válido';

  @override
  String get emailLinkPasswordShort => 'La contraseña debe tener al menos 6 caracteres';

  @override
  String get emailLinkSignInButton => 'INICIAR SESIÓN';

  @override
  String get emailLinkLinkAndVerify => 'VINCULAR CORREO Y VERIFICAR';

  @override
  String get emailLinkCreateAccount => 'CREAR CUENTA NUEVA';

  @override
  String get emailLinkSignInExisting => 'INICIAR SESIÓN CON CUENTA EXISTENTE';

  @override
  String get emailLinkCheckInboxTitle => 'Revisa tu bandeja de entrada';

  @override
  String get emailLinkCheckInboxDesc =>
      'Enviamos un correo de verificación. Abre el enlace del correo, luego vuelve aquí y toca el botón de abajo.';

  @override
  String get emailLinkNotYetVerified =>
      'El correo aún no está verificado. Revisa tu bandeja de entrada y la carpeta de spam.';

  @override
  String get emailLinkVerifiedButton => 'YA VERIFIQUÉ MI CORREO';

  @override
  String get emailLinkResendButton => 'REENVIAR CORREO DE VERIFICACIÓN';

  @override
  String userErrorCouldnt(Object context, Object message) {
    return 'No se pudo $context — $message';
  }

  @override
  String get userErrorNetwork => 'Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get userErrorBadState => 'Algo quedó en un estado incorrecto. Inténtalo de nuevo.';

  @override
  String get userErrorPermission => 'Se denegó el permiso. Abre Ajustes para conceder el acceso.';

  @override
  String get userErrorConflict => 'Ese cambio entra en conflicto con datos existentes.';

  @override
  String get userErrorNotFound => 'No se encontró — puede que se haya eliminado.';

  @override
  String get userErrorGeneric => 'Algo salió mal. Inténtalo de nuevo en un momento.';

  @override
  String get setTypeDialogTitle => 'Tipos de serie';

  @override
  String get setTypeDialogDescription => 'Lleva un registro de cómo realizaste tus series especificando un tipo:';

  @override
  String get regularSetDefinition =>
      'Regular: realiza las series normalmente alcanzando el objetivo de repeticiones o el objetivo de RIR semana a semana';

  @override
  String get myorepSetDefinition =>
      'Myoreps: haz pausas de 5-15 segundos entre miniseries de repeticiones para alcanzar el objetivo de repeticiones o el objetivo de RIR semana a semana. Registra las repeticiones totales.';

  @override
  String get myorepMatchSetDefinition =>
      'Myorep match: haz pausas de 5-15 segundos entre miniseries de repeticiones para igualar las repeticiones de tu primera serie. Registra las repeticiones totales.';

  @override
  String get jointPainTitle => 'DOLOR ARTICULAR';

  @override
  String get musclePumpTitle => 'CONGESTIÓN MUSCULAR';

  @override
  String get workloadTitle => 'CARGA DE TRABAJO';

  @override
  String get sorenessTitle => 'DOLOR MUSCULAR';

  @override
  String jointPainQuestion(Object exerciseName) {
    return '¿Cómo sentiste tus articulaciones durante $exerciseName?';
  }

  @override
  String musclePumpQuestion(Object muscleGroup) {
    return '¿Cuánta congestión lograste hoy en tu $muscleGroup?';
  }

  @override
  String workloadQuestion(Object muscleGroup) {
    return '¿Cómo calificarías la dificultad del trabajo que hiciste para tu $muscleGroup?';
  }

  @override
  String sorenessQuestion(Object muscleGroup) {
    return '¿Qué tan adolorido quedó tu $muscleGroup DESPUÉS de entrenarlo LA ÚLTIMA VEZ?';
  }

  @override
  String get draftBannerText => 'CONTINUAR EDITANDO EL CICLO DE ENTRENAMIENTO BORRADOR';

  @override
  String get noExercisesTitle => 'Sin ejercicios';

  @override
  String get noExercisesMessage => 'Tus ejercicios personalizados aparecerán aquí.';

  @override
  String get noPinnedNotesTitle => 'Sin notas fijadas';

  @override
  String get noPinnedNotesMessage => 'Tus notas de ejercicios fijadas aparecerán aquí.';

  @override
  String get navWorkout => 'Entrenamiento';

  @override
  String get navTrainingCycles => 'Ciclos';

  @override
  String get navExercisesConst => 'Ejercicios';

  @override
  String get navMoreConst => 'Más';

  @override
  String get menuTemplates => 'Plantillas';

  @override
  String get menuDarkTheme => 'Tema oscuro';

  @override
  String get menuExportData => 'Exportar datos';

  @override
  String get menuImportData => 'Importar datos';

  @override
  String get menuShareData => 'Compartir datos';

  @override
  String get menuHelp => 'Ayuda';

  @override
  String get menuLeaveReview => 'Dejar una reseña';

  @override
  String get localeSystem => 'Sistema';

  @override
  String get localeEnglish => 'Inglés';

  @override
  String get localeSpanish => 'Español';

  @override
  String get sportPickerTitle => 'Agregar una sesión';

  @override
  String get sportPickerSubtitle => '¿De qué deporte es esta sesión?';

  @override
  String get cardioTemplatePickerTitle => 'Empezar desde una plantilla';

  @override
  String get cardioTemplatePickerSubtitle =>
      'Elige una sesión predefinida para empezar. Puedes editar los intervalos antes de guardar.';

  @override
  String cardioTemplatePickerLoadError(Object error) {
    return 'No se pudo cargar la biblioteca. $error';
  }

  @override
  String get cardioTemplatePickerNoTemplates => 'Aún no hay plantillas para este deporte.';

  @override
  String get cardioDifficultyBeginner => 'Principiante';

  @override
  String get cardioDifficultyIntermediate => 'Intermedio';

  @override
  String get cardioDifficultyAdvanced => 'Avanzado';

  @override
  String cardioTemplatePickerStepsCount(Object count) {
    return '$count pasos';
  }

  @override
  String get routerErrorTitle => 'Error';

  @override
  String routerPageNotFound(Object location) {
    return 'Página no encontrada: $location';
  }

  @override
  String get routerGoHome => 'Ir al inicio';

  @override
  String cycleSummaryTitle(Object cycleTerm) {
    return 'Resumen de $cycleTerm';
  }

  @override
  String get cycleSummaryWorkoutsSection => 'Entrenamientos';

  @override
  String get cycleSummaryCompleted => 'Completados';

  @override
  String get cycleSummarySkipped => 'Omitidos';

  @override
  String get cycleSummaryIncomplete => 'Incompletos';

  @override
  String get cycleSummaryStatsSection => 'Estadísticas';

  @override
  String get cycleSummaryMuscleGroups => 'Grupos musculares';

  @override
  String get closeUpper => 'CERRAR';

  @override
  String get muscleGroupStatsTitle => 'Estadísticas por grupo muscular';

  @override
  String get muscleGroupStatsNoSessions => 'No se encontraron sesiones para este ciclo de entrenamiento.';

  @override
  String get muscleGroupStatsDeload => 'DC';

  @override
  String muscleGroupStatsPeriod(Object period) {
    return 'pd $period';
  }

  @override
  String muscleGroupStatsAvgSets(Object count) {
    return '$count series promedio';
  }

  @override
  String get skinSelectionTitle => 'Apariencia';

  @override
  String get skinSelectionShare => 'Compartir';

  @override
  String get skinSelectionCurrentTheme => 'Tema actual';

  @override
  String get skinSelectionChooseTheme => 'Elige un tema';

  @override
  String get skinSelectionCreate => 'Crear';

  @override
  String get skinSelectionBrowseCommunity => 'Explorar biblioteca de la comunidad';

  @override
  String get skinSelectionBrowseCommunitySubtitle => 'Descubre temas compartidos por otros usuarios';

  @override
  String get skinSelectionPremium => 'Premium';

  @override
  String get skinSelectionEditTheme => 'Editar tema';

  @override
  String get skinSelectionShareTheme => 'Compartir tema';

  @override
  String get skinSelectionDeleteTheme => 'Eliminar tema';

  @override
  String get skinSelectionDeleteThemeTitle => '¿Eliminar tema?';

  @override
  String skinSelectionDeleteConfirm(Object name) {
    return '¿Seguro que quieres eliminar \"$name\"?';
  }

  @override
  String get unitsResetButton => 'Restablecer';

  @override
  String get unitsDescription =>
      'Elige las unidades por deporte. Una fila que no hayas tocado sigue el valor predeterminado razonable (correr → millas, bici → km, natación → metros), recurriendo a tu configuración principal métrica / imperial.';

  @override
  String get unitsDefaultLabel => '(predeterminado)';

  @override
  String get unitsImperialLabel => 'Imperial';

  @override
  String get unitsMetricLabel => 'Métrico';

  @override
  String unitsStrengthNote(Object system) {
    return 'La fuerza usa tu elección principal métrica/imperial ($system) — cámbiala en Ajustes → Perfil.';
  }

  @override
  String zonesNoZones(Object sport) {
    return 'No hay zonas configuradas para $sport';
  }

  @override
  String get zonesNoZonesSubtitle =>
      'Empieza con la división convencional de cinco zonas y ajusta los números a tus umbrales medidos.';

  @override
  String get zonesSeedDefaults => 'Cargar zonas predeterminadas';

  @override
  String get zonesClear => 'Borrar';

  @override
  String get zonesHrDescription =>
      'Zonas de frecuencia cardíaca en lpm. Toca un valor para editarlo. Los valores predeterminados son un buen punto de partida — ajústalos a tus umbrales medidos.';

  @override
  String zonesZoneLabel(Object number) {
    return 'Zona $number';
  }

  @override
  String get zonesMinLabel => 'Mín';

  @override
  String get zonesMaxLabel => 'Máx';

  @override
  String get zonesBpmSuffix => 'lpm';

  @override
  String get zonesResetToDefaults => 'Restablecer valores predeterminados';

  @override
  String zonesErrorLoading(Object error) {
    return 'Error al cargar las zonas: $error';
  }

  @override
  String get sentryDebugOnlyAvailable =>
      'La pantalla de depuración solo está disponible en compilaciones de depuración';

  @override
  String get sentryRefreshTooltip => 'Actualizar estado';

  @override
  String get sentryTestMessage => 'Mensaje de prueba';

  @override
  String get sentryTestException => 'Excepción de prueba';

  @override
  String get sentryTestFeedback => 'Comentario de prueba';

  @override
  String get sentryTestCrash => 'Fallo de prueba';

  @override
  String restTimerBannerSemantic(Object time) {
    return 'Temporizador de descanso: $time restante';
  }

  @override
  String restTimerRestDisplay(Object time) {
    return 'Descanso: $time';
  }

  @override
  String get restTimerResumeTooltip => 'Reanudar';

  @override
  String get restTimerPauseTooltip => 'Pausar';

  @override
  String get restTimerAddTimeTooltip => 'Agregar 30 segundos';

  @override
  String get restTimerSkipTooltip => 'Omitir descanso';

  @override
  String get filterByAvailableEquipment => 'Filtrar por equipo disponible';

  @override
  String get onlyShowEquipmentExercises => 'Mostrar solo ejercicios para el equipo que tienes';

  @override
  String get selectEquipmentAccess => 'Selecciona el equipo al que tienes acceso';

  @override
  String sportSummarySessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sesiones',
      one: 'sesión',
    );
    return '$_temp0';
  }

  @override
  String sportSummaryBest(Object distance) {
    return 'Mejor $distance';
  }

  @override
  String weeklyVolumeChartTooltipSessions(Object count) {
    return '$count sesiones';
  }

  @override
  String weeklyVolumeChartWeekOf(Object date) {
    return 'Sem del $date';
  }

  @override
  String volumeBarChartSetsTooltip(Object count) {
    return '$count series';
  }

  @override
  String exerciseCardLastPerformance(Object summary, Object date) {
    return 'Última: $summary$date';
  }

  @override
  String get cardioCardTargetLabel => 'OBJETIVO';

  @override
  String get cardioCardNoTarget => 'Sin objetivo definido';

  @override
  String cardioCardIntervalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count intervalos',
      one: '1 intervalo',
    );
    return '$_temp0';
  }

  @override
  String get cardioCardPaceLabel => 'Ritmo';

  @override
  String get cardioCardAvgSpeedLabel => 'Velocidad media';

  @override
  String get cardioCardSwolfLabel => 'SWOLF';

  @override
  String cardioCardLapsValue(Object count) {
    return '$count vueltas';
  }

  @override
  String get cardioCardPoolLabel => 'piscina';

  @override
  String get cardioCardAvgHr => 'prom';

  @override
  String get cardioCardMaxHr => 'máx';

  @override
  String get cardioCardAvgPower => 'prom';

  @override
  String get cardioCardElevationGain => '▲';

  @override
  String get cardioCardAddFeedback => 'Agregar comentario';

  @override
  String get cardioCardLogSession => 'Registrar sesión';

  @override
  String get cardioCardMenuNotes => 'Notas';

  @override
  String get cardioCardMenuMoveUp => 'Subir';

  @override
  String get cardioCardMenuMoveDown => 'Bajar';

  @override
  String get cardioCardMenuReplace => 'Reemplazar';

  @override
  String get cardioCardMenuSkipSession => 'Omitir sesión';

  @override
  String get cardioCardMenuDeleteSession => 'Eliminar sesión';

  @override
  String get quickLogTooltip => 'Registrar sesión';

  @override
  String get quickLogTitle => 'Registrar sesión';

  @override
  String get thisWeekEmpty => 'Aún no hay nada registrado — tu próxima sesión aparecerá aquí.';

  @override
  String thisWeekStrengthSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesiones de fuerza',
      one: '1 sesión de fuerza',
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
      other: 'sesiones',
      one: 'sesión',
    );
    return '$_temp0';
  }

  @override
  String sportSummaryBestLabel(Object distance) {
    return 'Mejor $distance';
  }

  @override
  String weeklyVolumeChartTooltip(Object weekLabel, Object sessions, Object duration) {
    return '$weekLabel\n$sessions sesiones • $duration';
  }

  @override
  String get volumeBarChartEmpty => 'Aún no hay datos';

  @override
  String get exerciseCardExerciseInfo => 'Información del ejercicio';

  @override
  String exerciseCardOptionsLabel(Object name) {
    return 'Opciones de ejercicio para $name';
  }

  @override
  String get exerciseCardWeightHeader => 'PESO';

  @override
  String get exerciseCardRepsHeader => 'REPS';

  @override
  String get exerciseCardLogHeader => 'REGISTRO';

  @override
  String exerciseCardWeightSemantic(Object number) {
    return 'Peso para la serie $number';
  }

  @override
  String exerciseCardRepsSemantic(Object number) {
    return 'Repeticiones para la serie $number';
  }

  @override
  String exerciseCardLogSemantic(Object number) {
    return 'Registrar serie $number';
  }

  @override
  String exerciseCardSetTypeSemantic(Object typeName) {
    return 'Serie $typeName';
  }

  @override
  String get exerciseCardExerciseHeader => 'EJERCICIO';

  @override
  String get exerciseCardNewNote => 'Nueva nota';

  @override
  String get exerciseCardMoveUp => 'Subir';

  @override
  String get exerciseCardMoveDown => 'Bajar';

  @override
  String get exerciseCardReplace => 'Reemplazar';

  @override
  String get exerciseCardJointPain => 'Dolor articular';

  @override
  String exerciseCardRestTimerValue(Object seconds) {
    return 'Descanso: ${seconds}s';
  }

  @override
  String get exerciseCardSetRestTimer => 'Configurar temporizador de descanso';

  @override
  String get exerciseCardAddSet => 'Agregar serie';

  @override
  String get exerciseCardSkipSets => 'Omitir series';

  @override
  String get exerciseCardDeleteExercise => 'Eliminar ejercicio';

  @override
  String get exerciseCardSetHeader => 'SERIE';

  @override
  String get exerciseCardAddSetBelow => 'Agregar serie debajo';

  @override
  String get exerciseCardSkipSet => 'Omitir serie';

  @override
  String get exerciseCardUnskipSet => 'Restaurar serie';

  @override
  String get exerciseCardDeleteSet => 'Eliminar serie';

  @override
  String get exerciseCardPrBadge => 'RP';

  @override
  String get exerciseCardPrBadgeSemantic => 'Récord personal';

  @override
  String get exerciseCardLogHintMissingFields => 'Ingresa peso y repeticiones para registrar esta serie';

  @override
  String workoutActionError(Object error) {
    return 'No se pudieron guardar los cambios: $error';
  }

  @override
  String exerciseCardTryWeight(Object weight, Object unit) {
    return '↑ Prueba $weight $unit';
  }

  @override
  String get exerciseCardRirHint => 'RIR';

  @override
  String exerciseCardRirTargetHint(Object target) {
    return '$target RIR';
  }

  @override
  String get equipmentFilterTitle => 'Filtrar por equipo disponible';

  @override
  String get equipmentFilterSubtitle => 'Mostrar solo ejercicios para el equipo que tienes';

  @override
  String get equipmentFilterSelectPrompt => 'Selecciona el equipo al que tienes acceso';

  @override
  String restTimerSemantic(Object time) {
    return 'Temporizador de descanso: $time restante';
  }

  @override
  String restTimerDisplay(Object time) {
    return 'Descanso: $time';
  }

  @override
  String get restTimerResume => 'Reanudar';

  @override
  String get restTimerPause => 'Pausar';

  @override
  String get restTimerAdd30 => 'Agregar 30 segundos';

  @override
  String get restTimerSubtract30 => 'Restar 30 segundos';

  @override
  String get restTimerSkip => 'Omitir descanso';

  @override
  String get restTimerNotificationTitle => 'Descanso terminado';

  @override
  String get restTimerNotificationBody => 'Hora de tu próxima serie';

  @override
  String get cycleComparisonNeedTwoCycles => 'Se necesitan al menos 2 ciclos para comparar';

  @override
  String get cycleComparisonUnlockHint => 'Completa un ciclo de entrenamiento para desbloquear las comparaciones.';

  @override
  String get cycleComparisonPRChanges => 'Cambios en récords personales';

  @override
  String cycleComparisonWeightChange(Object weightA, Object weightB) {
    return '$weightA → $weightB lbs';
  }

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String get authVerifyToUpload => 'Verifica para subir';

  @override
  String get authSignInBody => 'Inicia sesión con el correo y la contraseña que usaste en tu otro dispositivo.';

  @override
  String get authLinkEmailBody =>
      'Vincula un correo a tu cuenta para compartir contenido con la comunidad. Tus datos anónimos se conservan.';

  @override
  String get authEmailLabel => 'Correo';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String get authEnterEmail => 'Ingresa tu correo';

  @override
  String get authEnterValidEmail => 'Ingresa un correo válido';

  @override
  String get authPasswordMinLength => 'La contraseña debe tener al menos 6 caracteres';

  @override
  String get authSignInUpper => 'INICIAR SESIÓN';

  @override
  String get authLinkEmailUpper => 'VINCULAR CORREO Y VERIFICAR';

  @override
  String get authCreateNewAccount => 'CREAR CUENTA NUEVA';

  @override
  String get authSignInExisting => 'INICIAR SESIÓN CON CUENTA EXISTENTE';

  @override
  String get authCheckInbox => 'Revisa tu bandeja de entrada';

  @override
  String get authCheckInboxBody =>
      'Enviamos un correo de verificación. Abre el enlace del correo, luego vuelve aquí y toca el botón de abajo.';

  @override
  String get authEmailNotVerified =>
      'El correo aún no está verificado. Revisa tu bandeja de entrada y la carpeta de spam.';

  @override
  String get authVerifiedButton => 'YA VERIFIQUÉ MI CORREO';

  @override
  String get authResendEmail => 'REENVIAR CORREO DE VERIFICACIÓN';

  @override
  String get authVerificationSent => 'Correo de verificación enviado';
}
