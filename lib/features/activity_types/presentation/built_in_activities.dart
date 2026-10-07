import '../../../core/units/unit_registry.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/activity_ids.dart';
import '../domain/activity_type_definition.dart';
import '../domain/field_config.dart';
import '../domain/field_type.dart';
import 'starter_activities.dart';

/// A heading in the list of activities and the built-in ones under it.
class ActivityCategory {
  const ActivityCategory(this.name, this.activities);

  final String name;
  final List<ActivityTypeDefinition> activities;
}

/// Every built-in activity, in category order. Quick add suggests
/// them while typing.
List<ActivityTypeDefinition> builtInActivities(AppLocalizations l10n) => [
  for (final category in activityCategories(l10n)) ...category.activities,
];

/// The built-in activities: everyday life grouped the way time-use surveys
/// group it (personal care, eating, household, caring for others, work,
/// education, sport, leisure, social and community, travel), plus the habits
/// people most often track. Plain data like [starterActivities]: each becomes
/// an ordinary, editable activity once added. No code may treat one
/// specially.
List<ActivityCategory> activityCategories(AppLocalizations l10n) {
  final starters = {for (final t in starterActivities(l10n)) t.name: t};
  ActivityTypeDefinition starter(String name) => starters[name]!;
  return [
    ActivityCategory(l10n.builtInCategorySleepAndSelfCare, [
      starter(l10n.builtInSleep),
      _activity(l10n.builtInNap, 'moon', 'slate', timer: true, [
        _rating(l10n.builtInNapFeltAfter),
      ]),
      _activity(l10n.builtInMorningRoutine, 'coffee', 'sky', [
        _time(l10n.builtInMorningRoutineWokeUpAt),
        _list(
          l10n.builtInMorningRoutineSteps,
          l10n.builtInMorningRoutineStepsItem,
          [
            _text(l10n.builtInMorningRoutineStepsStep, required: true),
            _yesNo(l10n.builtInMorningRoutineStepsDone),
          ],
        ),
        _rating(l10n.builtInMorningRoutineEnergy),
      ]),
      _activity(l10n.builtInEveningRoutine, 'moon', 'lilac', [
        _time(l10n.builtInEveningRoutineLightsOutAt),
        _list(
          l10n.builtInEveningRoutineSteps,
          l10n.builtInEveningRoutineStepsItem,
          [
            _text(l10n.builtInEveningRoutineStepsStep, required: true),
            _yesNo(l10n.builtInEveningRoutineStepsDone),
          ],
        ),
        _yesNo(l10n.builtInEveningRoutineScreensOffAnHourBefore),
      ]),
      _activity(l10n.builtInShower, 'drop', 'sky', [
        _choice(l10n.builtInShowerKind, [
          l10n.builtInShowerKindShower,
          l10n.builtInShowerKindBath,
          l10n.builtInShowerKindColdShower,
        ]),
        _rating(l10n.builtInShowerFeltAfter),
      ]),
      _activity(l10n.builtInSkincare, 'sparkle', 'rose', [
        _multiChoice(l10n.builtInSkincareProducts, [
          l10n.builtInSkincareProductsCleanser,
          l10n.builtInSkincareProductsToner,
          l10n.builtInSkincareProductsSerum,
          l10n.builtInSkincareProductsMoisturizer,
          l10n.builtInSkincareProductsSunscreen,
          l10n.builtInSkincareProductsMask,
        ]),
        _rating(l10n.builtInSkincareSkinToday),
      ]),
      _activity(l10n.builtInOralCare, 'tooth', 'sky', [
        _yesNo(l10n.builtInOralCareBrushed),
        _yesNo(l10n.builtInOralCareFlossed),
        _yesNo(l10n.builtInOralCareMouthwash),
      ]),
      _activity(l10n.builtInGrooming, 'sparkle', 'slate', [
        _multiChoice(l10n.builtInGroomingWhat, [
          l10n.builtInGroomingWhatHaircut,
          l10n.builtInGroomingWhatShave,
          l10n.builtInGroomingWhatBeardTrim,
          l10n.builtInGroomingWhatNails,
          l10n.builtInGroomingWhatHairWash,
        ]),
        _number(l10n.builtInGroomingCost, decimals: 2),
      ]),
      _activity(l10n.builtInAyurvedicMorning, 'leaf', 'teal', [
        _yesNo(l10n.builtInAyurvedicMorningUpBeforeSunrise),
        _multiChoice(l10n.builtInAyurvedicMorningPractices, [
          l10n.builtInAyurvedicMorningPracticesTongueScraping,
          l10n.builtInAyurvedicMorningPracticesOilPulling,
          l10n.builtInAyurvedicMorningPracticesAbhyanga,
          l10n.builtInAyurvedicMorningPracticesWarmWater,
          l10n.builtInAyurvedicMorningPracticesNeti,
        ]),
        _rating(l10n.builtInAyurvedicMorningFeltAfter),
      ]),
      _activity(l10n.builtInHairOiling, 'drop', 'coral', [
        _text(l10n.builtInHairOilingOil, suggest: true),
        _yesNo(l10n.builtInHairOilingLeftOnOvernight),
      ]),
      _activity(l10n.builtInMassageAndSpa, 'sparkle', 'lilac', timer: true, [
        _choice(l10n.builtInMassageAndSpaKind, [
          l10n.builtInMassageAndSpaKindMassage,
          l10n.builtInMassageAndSpaKindSpa,
          l10n.builtInMassageAndSpaKindFacial,
          l10n.builtInMassageAndSpaKindFootMassage,
          l10n.builtInMassageAndSpaKindSelfMassage,
        ]),
        _rating(l10n.builtInMassageAndSpaFeltAfter),
        _number(l10n.builtInMassageAndSpaCost, decimals: 2),
      ]),
      _activity(l10n.builtInSaunaAndColdPlunge, 'drop', 'sky', timer: true, [
        _choice(l10n.builtInSaunaAndColdPlungeKind, [
          l10n.builtInSaunaAndColdPlungeKindSauna,
          l10n.builtInSaunaAndColdPlungeKindColdPlunge,
          l10n.builtInSaunaAndColdPlungeKindSteamRoom,
          l10n.builtInSaunaAndColdPlungeKindContrast,
        ]),
        _number(l10n.builtInSaunaAndColdPlungeRounds),
        _number(
          l10n.builtInSaunaAndColdPlungeTemperature,
          dimension: Dimension.temperature,
          unit: 'celsius',
        ),
      ]),
    ]),
    ActivityCategory(l10n.builtInCategoryHealth, [
      _activity(l10n.builtInMedication, 'pill', 'rose', [
        _text(l10n.builtInMedicationMedicine, suggest: true),
        _text(l10n.builtInMedicationDose),
        _yesNo(l10n.builtInMedicationTaken),
        _text(l10n.builtInMedicationSideEffects),
      ]),
      _activity(l10n.builtInVitaminsAndSupplements, 'pill', 'teal', [
        _list(
          l10n.builtInVitaminsAndSupplementsSupplements,
          l10n.builtInVitaminsAndSupplementsSupplementsItem,
          [
            _text(
              l10n.builtInVitaminsAndSupplementsSupplementsSupplement,
              required: true,
              suggest: true,
            ),
            _yesNo(l10n.builtInVitaminsAndSupplementsSupplementsTaken),
          ],
        ),
      ]),
      _activity(l10n.builtInDoctorVisit, 'first-aid', 'rose', [
        _text(l10n.builtInDoctorVisitDoctorOrClinic, suggest: true),
        _text(l10n.builtInDoctorVisitReason),
        _text(l10n.builtInDoctorVisitWhatTheySaid, multiline: true),
        _date(l10n.builtInDoctorVisitNextVisit),
      ]),
      _activity(l10n.builtInSymptoms, 'first-aid', 'coral', [
        _multiChoice(l10n.builtInSymptomsSymptoms, [
          l10n.builtInSymptomsSymptomsHeadache,
          l10n.builtInSymptomsSymptomsFever,
          l10n.builtInSymptomsSymptomsCough,
          l10n.builtInSymptomsSymptomsSoreThroat,
          l10n.builtInSymptomsSymptomsFatigue,
          l10n.builtInSymptomsSymptomsNausea,
          l10n.builtInSymptomsSymptomsPain,
        ]),
        _rating(l10n.builtInSymptomsSeverity),
        _text(l10n.builtInSymptomsNotes, multiline: true),
      ]),
      _activity(l10n.builtInBloodPressure, 'heart', 'rose', [
        _number(l10n.builtInBloodPressureSystolic),
        _number(l10n.builtInBloodPressureDiastolic),
        _number(l10n.builtInBloodPressurePulse),
      ]),
      _activity(l10n.builtInBloodSugar, 'drop', 'coral', [
        _number(l10n.builtInBloodSugarReading, decimals: 1),
        _choice(l10n.builtInBloodSugarWhen, [
          l10n.builtInBloodSugarWhenFasting,
          l10n.builtInBloodSugarWhenBeforeAMeal,
          l10n.builtInBloodSugarWhenAfterAMeal,
          l10n.builtInBloodSugarWhenBedtime,
        ]),
      ]),
      _activity(l10n.builtInBodyTemperature, 'first-aid', 'coral', [
        _number(
          l10n.builtInBodyTemperatureTemperature,
          dimension: Dimension.temperature,
          unit: 'celsius',
          decimals: 1,
        ),
      ]),
      _activity(l10n.builtInPeriod, 'heart', 'rose', [
        _choice(l10n.builtInPeriodFlow, [
          l10n.builtInPeriodFlowSpotting,
          l10n.builtInPeriodFlowLight,
          l10n.builtInPeriodFlowMedium,
          l10n.builtInPeriodFlowHeavy,
        ]),
        _multiChoice(l10n.builtInPeriodSymptoms, [
          l10n.builtInPeriodSymptomsCramps,
          l10n.builtInPeriodSymptomsBloating,
          l10n.builtInPeriodSymptomsHeadache,
          l10n.builtInPeriodSymptomsMoodSwings,
          l10n.builtInPeriodSymptomsFatigue,
          l10n.builtInPeriodSymptomsCravings,
        ]),
        _text(l10n.builtInPeriodNotes, multiline: true),
      ]),
      _activity(l10n.builtInPhysiotherapy, 'first-aid', 'teal', timer: true, [
        _list(
          l10n.builtInPhysiotherapyExercises,
          l10n.builtInPhysiotherapyExercisesItem,
          [
            _text(l10n.builtInPhysiotherapyExercisesExercise, required: true),
            _yesNo(l10n.builtInPhysiotherapyExercisesDone),
          ],
        ),
        _rating(l10n.builtInPhysiotherapyPainLevel),
      ]),
      _activity(l10n.builtInPain, 'first-aid', 'rose', [
        _multiChoice(l10n.builtInPainWhere, [
          l10n.builtInPainWhereHead,
          l10n.builtInPainWhereNeck,
          l10n.builtInPainWhereBack,
          l10n.builtInPainWhereJoints,
          l10n.builtInPainWhereStomach,
          l10n.builtInPainWhereMuscles,
        ]),
        _rating(l10n.builtInPainLevel),
        _text(l10n.builtInPainPossibleTrigger),
      ]),
      _activity(l10n.builtInDigestion, 'leaf', 'teal', [
        _choice(l10n.builtInDigestionType, [
          l10n.builtInDigestionTypeHard,
          l10n.builtInDigestionTypeNormal,
          l10n.builtInDigestionTypeSoft,
          l10n.builtInDigestionTypeLoose,
        ]),
        _yesNo(l10n.builtInDigestionBloating),
        _text(l10n.builtInDigestionNotes, multiline: true),
      ]),
      _activity(l10n.builtInEnergyCheck, 'lightbulb', 'coral', [
        _rating(l10n.builtInEnergyCheckEnergy),
        _rating(l10n.builtInEnergyCheckFocus),
      ]),
    ]),
    ActivityCategory(l10n.builtInCategoryFoodAndDrink, [
      _activity(l10n.builtInMeal, 'fork-knife', 'coral', [
        _choice(l10n.builtInMealMeal, [
          l10n.builtInMealMealBreakfast,
          l10n.builtInMealMealLunch,
          l10n.builtInMealMealDinner,
          l10n.builtInMealMealSnack,
        ]),
        _text(l10n.builtInMealWhatIAte, multiline: true),
        _number(
          l10n.builtInMealCalories,
          dimension: Dimension.energy,
          unit: 'kcal',
        ),
        _rating(l10n.builtInMealHowHealthy),
        _yesNo(l10n.builtInMealAteOut),
      ]),
      starter(l10n.builtInWater),
      _activity(l10n.builtInCoffeeAndTea, 'coffee', 'coral', [
        _choice(l10n.builtInCoffeeAndTeaDrink, [
          l10n.builtInCoffeeAndTeaDrinkCoffee,
          l10n.builtInCoffeeAndTeaDrinkEspresso,
          l10n.builtInCoffeeAndTeaDrinkTea,
          l10n.builtInCoffeeAndTeaDrinkGreenTea,
          l10n.builtInCoffeeAndTeaDrinkHerbalTea,
        ]),
        _number(l10n.builtInCoffeeAndTeaCups),
      ]),
      starter(l10n.builtInCooking),
      _activity(l10n.builtInFasting, 'timer', 'teal', timer: true, [
        _choice(l10n.builtInFastingPlan, [
          l10n.builtInFastingPlan1212,
          l10n.builtInFastingPlan168,
          l10n.builtInFastingPlan186,
          l10n.builtInFastingPlan204,
          l10n.builtInFastingPlan24Hours,
        ]),
        _time(l10n.builtInFastingBrokeTheFastAt),
        _rating(l10n.builtInFastingHowItFelt),
      ]),
      _activity(l10n.builtInAlcohol, 'drop', 'lilac', [
        _number(l10n.builtInAlcoholDrinks),
        _multiChoice(l10n.builtInAlcoholKind, [
          l10n.builtInAlcoholKindBeer,
          l10n.builtInAlcoholKindWine,
          l10n.builtInAlcoholKindSpirits,
          l10n.builtInAlcoholKindCocktail,
          l10n.builtInAlcoholKindCider,
        ]),
      ]),
      _activity(l10n.builtInMealPrep, 'cooking-pot', 'teal', timer: true, [
        _list(l10n.builtInMealPrepDishes, l10n.builtInMealPrepDishesItem, [
          _text(l10n.builtInMealPrepDishesDish, required: true, suggest: true),
          _number(l10n.builtInMealPrepDishesPortions),
        ]),
      ]),
      _activity(l10n.builtInProtein, 'fork-knife', 'coral', [
        _number(
          l10n.builtInProteinProtein,
          dimension: Dimension.mass,
          unit: 'g',
        ),
      ]),
      _activity(l10n.builtInFruitAndVeg, 'leaf', 'teal', [
        _number(l10n.builtInFruitAndVegPortions),
        _multiChoice(l10n.builtInFruitAndVegColoursEaten, [
          l10n.builtInFruitAndVegColoursEatenGreen,
          l10n.builtInFruitAndVegColoursEatenRed,
          l10n.builtInFruitAndVegColoursEatenOrange,
          l10n.builtInFruitAndVegColoursEatenYellow,
          l10n.builtInFruitAndVegColoursEatenPurple,
          l10n.builtInFruitAndVegColoursEatenWhite,
        ]),
      ]),
      _activity(l10n.builtInPackedLunch, 'fork-knife', 'sky', [
        _text(l10n.builtInPackedLunchFor, suggest: true),
        _text(l10n.builtInPackedLunchWhatWentIn, multiline: true),
        _yesNo(l10n.builtInPackedLunchEaten),
      ]),
    ]),
    ActivityCategory(l10n.builtInCategoryHomeAndChores, [
      _activity(l10n.builtInCleaning, 'broom', 'teal', timer: true, [
        _multiChoice(l10n.builtInCleaningRooms, [
          l10n.builtInCleaningRoomsKitchen,
          l10n.builtInCleaningRoomsBathroom,
          l10n.builtInCleaningRoomsBedroom,
          l10n.builtInCleaningRoomsLivingRoom,
          l10n.builtInCleaningRoomsWholeHome,
        ]),
        _list(l10n.builtInCleaningTasks, l10n.builtInCleaningTasksItem, [
          _text(l10n.builtInCleaningTasksTask, required: true),
          _yesNo(l10n.builtInCleaningTasksDone),
        ]),
      ]),
      _activity(l10n.builtInLaundry, 'house', 'sky', [
        _number(l10n.builtInLaundryLoads),
        _multiChoice(l10n.builtInLaundrySteps, [
          l10n.builtInLaundryStepsWashed,
          l10n.builtInLaundryStepsDried,
          l10n.builtInLaundryStepsFolded,
          l10n.builtInLaundryStepsIroned,
          l10n.builtInLaundryStepsPutAway,
        ]),
      ]),
      _activity(l10n.builtInDishes, 'house', 'sky', [
        _choice(l10n.builtInDishesHow, [
          l10n.builtInDishesHowByHand,
          l10n.builtInDishesHowDishwasher,
        ]),
        _yesNo(l10n.builtInDishesKitchenWiped),
      ]),
      _activity(l10n.builtInGroceries, 'shopping-cart', 'coral', [
        _text(l10n.builtInGroceriesStore, suggest: true),
        _list(
          l10n.builtInGroceriesShoppingList,
          l10n.builtInGroceriesShoppingListItem,
          [
            _text(
              l10n.builtInGroceriesShoppingListItem,
              required: true,
              suggest: true,
            ),
            _yesNo(l10n.builtInGroceriesShoppingListGotIt),
          ],
        ),
        _number(l10n.builtInGroceriesSpent, decimals: 2),
      ]),
      _activity(l10n.builtInGardening, 'plant', 'teal', timer: true, [
        _multiChoice(l10n.builtInGardeningTasks, [
          l10n.builtInGardeningTasksWatering,
          l10n.builtInGardeningTasksPlanting,
          l10n.builtInGardeningTasksWeeding,
          l10n.builtInGardeningTasksPruning,
          l10n.builtInGardeningTasksMowing,
          l10n.builtInGardeningTasksHarvesting,
        ]),
        _text(l10n.builtInGardeningPlants),
      ]),
      _activity(l10n.builtInPlantCare, 'leaf', 'teal', [
        _list(l10n.builtInPlantCarePlants, l10n.builtInPlantCarePlantsItem, [
          _text(
            l10n.builtInPlantCarePlantsPlant,
            required: true,
            suggest: true,
          ),
          _yesNo(l10n.builtInPlantCarePlantsWatered),
          _yesNo(l10n.builtInPlantCarePlantsFed),
        ]),
      ]),
      _activity(l10n.builtInHomeRepair, 'wrench', 'slate', timer: true, [
        _text(l10n.builtInHomeRepairProject, suggest: true),
        _text(l10n.builtInHomeRepairWhatWasDone, multiline: true),
        _number(l10n.builtInHomeRepairCost, decimals: 2),
      ]),
      _activity(l10n.builtInDeclutter, 'broom', 'lilac', [
        _text(l10n.builtInDeclutterArea),
        _number(l10n.builtInDeclutterItemsRemoved),
        _choice(l10n.builtInDeclutterWhereTheyWent, [
          l10n.builtInDeclutterWhereTheyWentDonated,
          l10n.builtInDeclutterWhereTheyWentSold,
          l10n.builtInDeclutterWhereTheyWentRecycled,
          l10n.builtInDeclutterWhereTheyWentThrownAway,
        ]),
      ]),
      _activity(l10n.builtInHouseHelp, 'house', 'teal', [
        _text(l10n.builtInHouseHelpWho, suggest: true),
        _yesNo(l10n.builtInHouseHelpCameToday),
        _multiChoice(l10n.builtInHouseHelpTasks, [
          l10n.builtInHouseHelpTasksSweeping,
          l10n.builtInHouseHelpTasksMopping,
          l10n.builtInHouseHelpTasksDishes,
          l10n.builtInHouseHelpTasksLaundry,
          l10n.builtInHouseHelpTasksCooking,
          l10n.builtInHouseHelpTasksDusting,
        ]),
        _number(l10n.builtInHouseHelpPaid, decimals: 2),
      ]),
      _activity(l10n.builtInCarCare, 'car', 'slate', [
        _multiChoice(l10n.builtInCarCareWhat, [
          l10n.builtInCarCareWhatFuel,
          l10n.builtInCarCareWhatWash,
          l10n.builtInCarCareWhatService,
          l10n.builtInCarCareWhatTyres,
          l10n.builtInCarCareWhatOilChange,
          l10n.builtInCarCareWhatRepair,
        ]),
        _number(
          l10n.builtInCarCareOdometer,
          dimension: Dimension.distance,
          unit: 'km',
        ),
        _number(l10n.builtInCarCareCost, decimals: 2),
      ]),
    ]),
    ActivityCategory(l10n.builtInCategoryMoney, [
      _activity(l10n.builtInBills, 'wallet', 'slate', [
        _list(l10n.builtInBillsBills, l10n.builtInBillsBillsItem, [
          _text(l10n.builtInBillsBillsBill, required: true, suggest: true),
          _number(l10n.builtInBillsBillsAmount, decimals: 2),
          _yesNo(l10n.builtInBillsBillsPaid),
        ]),
      ]),
      _activity(l10n.builtInExpense, 'wallet', 'coral', [
        _number(l10n.builtInExpenseAmount, decimals: 2),
        _choice(l10n.builtInExpenseCategory, [
          l10n.builtInExpenseCategoryFood,
          l10n.builtInExpenseCategoryTransport,
          l10n.builtInExpenseCategoryHome,
          l10n.builtInExpenseCategoryHealth,
          l10n.builtInExpenseCategoryFun,
          l10n.builtInExpenseCategoryShopping,
          l10n.builtInExpenseCategoryBills,
          l10n.builtInExpenseCategoryOther,
        ]),
        _text(l10n.builtInExpenseWhatFor),
      ]),
      _activity(l10n.builtInBudgetReview, 'wallet', 'teal', [
        _number(l10n.builtInBudgetReviewSpentThisWeek, decimals: 2),
        _number(l10n.builtInBudgetReviewSaved, decimals: 2),
        _rating(l10n.builtInBudgetReviewOnTrack),
      ]),
      _activity(l10n.builtInInvesting, 'wallet', 'sky', [
        _text(l10n.builtInInvestingFundOrAsset, suggest: true),
        _choice(l10n.builtInInvestingKind, [
          l10n.builtInInvestingKindBuy,
          l10n.builtInInvestingKindSell,
          l10n.builtInInvestingKindSIP,
          l10n.builtInInvestingKindDeposit,
          l10n.builtInInvestingKindDividend,
        ]),
        _number(l10n.builtInInvestingAmount, decimals: 2),
      ]),
      _activity(l10n.builtInSavings, 'wallet', 'teal', [
        _text(l10n.builtInSavingsGoal, suggest: true),
        _number(l10n.builtInSavingsAdded, decimals: 2),
        _number(l10n.builtInSavingsTotalSoFar, decimals: 2),
      ]),
      _activity(l10n.builtInDonation, 'wallet', 'teal', [
        _text(l10n.builtInDonationCause, suggest: true),
        _number(l10n.builtInDonationAmount, decimals: 2),
      ]),
    ]),
    ActivityCategory(l10n.builtInCategoryFamilyAndCare, [
      _activity(l10n.builtInChildcare, 'baby', 'sky', [
        _text(l10n.builtInChildcareChild, suggest: true),
        _multiChoice(l10n.builtInChildcareWhatWeDid, [
          l10n.builtInChildcareWhatWeDidMeals,
          l10n.builtInChildcareWhatWeDidSchoolRun,
          l10n.builtInChildcareWhatWeDidHomework,
          l10n.builtInChildcareWhatWeDidPlaytime,
          l10n.builtInChildcareWhatWeDidBath,
          l10n.builtInChildcareWhatWeDidBedtime,
        ]),
        _text(l10n.builtInChildcareNotes, multiline: true),
      ]),
      _activity(l10n.builtInBabyFeeding, 'baby', 'rose', [
        _choice(l10n.builtInBabyFeedingKind, [
          l10n.builtInBabyFeedingKindBreastLeft,
          l10n.builtInBabyFeedingKindBreastRight,
          l10n.builtInBabyFeedingKindBottle,
          l10n.builtInBabyFeedingKindSolids,
        ]),
        _number(
          l10n.builtInBabyFeedingAmount,
          dimension: Dimension.volume,
          unit: 'ml',
        ),
        _text(l10n.builtInBabyFeedingNotes, multiline: true),
      ]),
      _activity(l10n.builtInDiaperChange, 'baby', 'sky', [
        _choice(l10n.builtInDiaperChangeKind, [
          l10n.builtInDiaperChangeKindWet,
          l10n.builtInDiaperChangeKindDirty,
          l10n.builtInDiaperChangeKindBoth,
        ]),
      ]),
      _activity(l10n.builtInPetCare, 'dog', 'coral', [
        _text(l10n.builtInPetCarePet, suggest: true),
        _multiChoice(l10n.builtInPetCareCare, [
          l10n.builtInPetCareCareFed,
          l10n.builtInPetCareCareWalked,
          l10n.builtInPetCareCareGroomed,
          l10n.builtInPetCareCarePlayed,
          l10n.builtInPetCareCareMedicine,
          l10n.builtInPetCareCareVetVisit,
        ]),
        _text(l10n.builtInPetCareNotes, multiline: true),
      ]),
      _activity(l10n.builtInDogWalk, 'dog', 'teal', timer: true, [
        _text(l10n.builtInDogWalkDog, suggest: true),
        _number(
          l10n.builtInDogWalkDistance,
          dimension: Dimension.distance,
          unit: 'km',
          decimals: 2,
        ),
      ]),
      _activity(l10n.builtInFamilyTime, 'users-three', 'rose', [
        _text(l10n.builtInFamilyTimeWho),
        _text(l10n.builtInFamilyTimeWhatWeDid, multiline: true),
        _rating(l10n.builtInFamilyTimeHowItFelt),
      ]),
      _activity(l10n.builtInCaringForSomeone, 'heart', 'lilac', [
        _text(l10n.builtInCaringForSomeoneWho, suggest: true),
        _multiChoice(l10n.builtInCaringForSomeoneHelpGiven, [
          l10n.builtInCaringForSomeoneHelpGivenCompany,
          l10n.builtInCaringForSomeoneHelpGivenMeals,
          l10n.builtInCaringForSomeoneHelpGivenErrands,
          l10n.builtInCaringForSomeoneHelpGivenMedicine,
          l10n.builtInCaringForSomeoneHelpGivenAppointments,
        ]),
        _text(l10n.builtInCaringForSomeoneNotes, multiline: true),
      ]),
      _activity(l10n.builtInSchoolRun, 'car', 'sky', [
        _text(l10n.builtInSchoolRunChild, suggest: true),
        _choice(l10n.builtInSchoolRunHow, [
          l10n.builtInSchoolRunHowCar,
          l10n.builtInSchoolRunHowWalk,
          l10n.builtInSchoolRunHowBus,
          l10n.builtInSchoolRunHowBike,
          l10n.builtInSchoolRunHowAuto,
          l10n.builtInSchoolRunHowSchoolVan,
        ]),
        _yesNo(l10n.builtInSchoolRunOnTime),
      ]),
    ]),
    ActivityCategory(l10n.builtInCategoryWork, [
      starter(l10n.builtInFocusedWork),
      starter(l10n.builtInMeeting),
      _activity(l10n.builtInDailyPlanning, 'target', 'teal', [
        _list(
          l10n.builtInDailyPlanningTopPriorities,
          l10n.builtInDailyPlanningTopPrioritiesItem,
          [
            _text(
              l10n.builtInDailyPlanningTopPrioritiesPriority,
              required: true,
            ),
            _yesNo(l10n.builtInDailyPlanningTopPrioritiesDone),
          ],
        ),
        _text(l10n.builtInDailyPlanningNotes, multiline: true),
      ]),
      _activity(l10n.builtInCommute, 'car', 'slate', timer: true, [
        _choice(l10n.builtInCommuteHow, [
          l10n.builtInCommuteHowCar,
          l10n.builtInCommuteHowBus,
          l10n.builtInCommuteHowTrain,
          l10n.builtInCommuteHowBike,
          l10n.builtInCommuteHowWalk,
          l10n.builtInCommuteHowOther,
        ]),
        _number(
          l10n.builtInCommuteDistance,
          dimension: Dimension.distance,
          unit: 'km',
          decimals: 2,
        ),
        _rating(l10n.builtInCommuteHowItWent),
      ]),
      _activity(l10n.builtInEmailAndAdmin, 'envelope', 'sky', timer: true, [
        _number(l10n.builtInEmailAndAdminEmailsHandled),
        _yesNo(l10n.builtInEmailAndAdminInboxZero),
      ]),
      _activity(l10n.builtInCoding, 'code', 'lilac', timer: true, [
        _text(l10n.builtInCodingProject, suggest: true),
        _text(l10n.builtInCodingWhatIBuilt, multiline: true),
        _number(l10n.builtInCodingCommits),
      ]),
      _activity(l10n.builtInSideProject, 'lightbulb', 'coral', timer: true, [
        _text(l10n.builtInSideProjectProject, suggest: true),
        _text(l10n.builtInSideProjectProgress, multiline: true),
        _rating(l10n.builtInSideProjectMomentum),
      ]),
      _activity(l10n.builtInJobSearch, 'briefcase', 'slate', [
        _text(l10n.builtInJobSearchCompany, suggest: true),
        _text(l10n.builtInJobSearchRole),
        _choice(l10n.builtInJobSearchStage, [
          l10n.builtInJobSearchStageApplied,
          l10n.builtInJobSearchStageInterview,
          l10n.builtInJobSearchStageOffer,
          l10n.builtInJobSearchStageRejected,
          l10n.builtInJobSearchStageFollowingUp,
        ]),
        _text(l10n.builtInJobSearchNotes, multiline: true),
      ]),
      _activity(l10n.builtInPresentation, 'presentation-chart', 'lilac', [
        _text(l10n.builtInPresentationTopic),
        _text(l10n.builtInPresentationAudience),
        _rating(l10n.builtInPresentationHowItWent),
      ]),
      _activity(l10n.builtInClientWork, 'briefcase', 'lilac', timer: true, [
        _text(l10n.builtInClientWorkClient, suggest: true),
        _text(l10n.builtInClientWorkTask),
        _yesNo(l10n.builtInClientWorkBillable),
      ]),
      _activity(l10n.builtInShift, 'briefcase', 'slate', timer: true, [
        _choice(l10n.builtInShiftShift, [
          l10n.builtInShiftShiftMorning,
          l10n.builtInShiftShiftDay,
          l10n.builtInShiftShiftEvening,
          l10n.builtInShiftShiftNight,
          l10n.builtInShiftShiftSplit,
        ]),
        _yesNo(l10n.builtInShiftTookABreak),
        _number(l10n.builtInShiftEarned, decimals: 2),
      ]),
      _activity(l10n.builtInGigWork, 'car', 'coral', timer: true, [
        _text(l10n.builtInGigWorkPlatform, suggest: true),
        _number(l10n.builtInGigWorkTripsOrOrders),
        _number(l10n.builtInGigWorkEarned, decimals: 2),
        _number(
          l10n.builtInGigWorkDistance,
          dimension: Dimension.distance,
          unit: 'km',
          decimals: 1,
        ),
      ]),
      _activity(l10n.builtInNetworking, 'users-three', 'sky', [
        _text(l10n.builtInNetworkingPerson, suggest: true),
        _text(l10n.builtInNetworkingWhereWeMet),
        _date(l10n.builtInNetworkingFollowUpOn),
      ]),
      _activity(l10n.builtInWeeklyReview, 'notebook', 'teal', [
        _text(l10n.builtInWeeklyReviewWins, multiline: true),
        _text(l10n.builtInWeeklyReviewLessons, multiline: true),
        _list(
          l10n.builtInWeeklyReviewNextWeek,
          l10n.builtInWeeklyReviewNextWeekItem,
          [
            _text(l10n.builtInWeeklyReviewNextWeekPriority, required: true),
            _yesNo(l10n.builtInWeeklyReviewNextWeekDone),
          ],
        ),
      ]),
      _activity(l10n.builtInGoalCheckIn, 'target', 'coral', [
        _text(l10n.builtInGoalCheckInGoal, suggest: true),
        _rating(l10n.builtInGoalCheckInProgress),
        _text(l10n.builtInGoalCheckInNextStep),
      ]),
    ]),
    ActivityCategory(l10n.builtInCategoryLearning, [
      starter(l10n.builtInStudy),
      starter(l10n.builtInLanguage),
      _activity(l10n.builtInClass, 'graduation-cap', 'lilac', timer: true, [
        _text(l10n.builtInClassCourse, suggest: true),
        _text(l10n.builtInClassTopic),
        _text(l10n.builtInClassNotes, multiline: true),
        _rating(l10n.builtInClassUnderstood),
      ]),
      _activity(l10n.builtInHomework, 'notebook', 'sky', timer: true, [
        _text(l10n.builtInHomeworkSubject, suggest: true),
        _text(l10n.builtInHomeworkTask),
        _yesNo(l10n.builtInHomeworkFinished),
      ]),
      _activity(l10n.builtInOnlineCourse, 'laptop', 'teal', timer: true, [
        _text(l10n.builtInOnlineCourseCourse, suggest: true),
        _number(l10n.builtInOnlineCourseLessonsDone),
        _text(l10n.builtInOnlineCourseTakeaways, multiline: true),
      ]),
      _activity(
        l10n.builtInMusicPractice,
        'music-notes',
        'coral',
        timer: true,
        [
          _choice(l10n.builtInMusicPracticeInstrument, [
            l10n.builtInMusicPracticeInstrumentGuitar,
            l10n.builtInMusicPracticeInstrumentPiano,
            l10n.builtInMusicPracticeInstrumentDrums,
            l10n.builtInMusicPracticeInstrumentViolin,
            l10n.builtInMusicPracticeInstrumentVoice,
            l10n.builtInMusicPracticeInstrumentOther,
          ]),
          _list(
            l10n.builtInMusicPracticePieces,
            l10n.builtInMusicPracticePiecesItem,
            [
              _text(
                l10n.builtInMusicPracticePiecesPiece,
                required: true,
                suggest: true,
              ),
              _number(l10n.builtInMusicPracticePiecesTempoBpm),
            ],
          ),
          _rating(l10n.builtInMusicPracticeHowItWent),
        ],
      ),
      _activity(l10n.builtInSkillPractice, 'target', 'lilac', timer: true, [
        _text(l10n.builtInSkillPracticeSkill, suggest: true),
        _text(l10n.builtInSkillPracticeWhatIPractised, multiline: true),
        _rating(l10n.builtInSkillPracticeProgress),
      ]),
      _activity(l10n.builtInTuition, 'graduation-cap', 'sky', timer: true, [
        _text(l10n.builtInTuitionSubject, suggest: true),
        _text(l10n.builtInTuitionTopic),
        _number(l10n.builtInTuitionTestScore, decimals: 1),
      ]),
      _activity(l10n.builtInExamPrep, 'notebook', 'coral', timer: true, [
        _text(l10n.builtInExamPrepExam, suggest: true),
        _text(l10n.builtInExamPrepTopicsCovered, multiline: true),
        _number(l10n.builtInExamPrepMockTestScore, decimals: 1),
        _rating(l10n.builtInExamPrepConfidence),
      ]),
      _activity(l10n.builtInFlashcards, 'brain', 'lilac', [
        _text(l10n.builtInFlashcardsDeck, suggest: true),
        _number(l10n.builtInFlashcardsCardsReviewed),
        _number(
          l10n.builtInFlashcardsCorrect,
          dimension: Dimension.percentage,
          unit: 'percent',
        ),
      ]),
      _activity(
        l10n.builtInTeaching,
        'presentation-chart',
        'teal',
        timer: true,
        [
          _text(l10n.builtInTeachingTopic),
          _number(l10n.builtInTeachingStudents),
          _rating(l10n.builtInTeachingHowItWent),
        ],
      ),
    ]),
    ActivityCategory(l10n.builtInCategoryExerciseAndSport, [
      starter(l10n.builtInGym),
      starter(l10n.builtInRunning),
      starter(l10n.builtInWalking),
      _activity(l10n.builtInCycling, 'bicycle', 'sky', timer: true, [
        _number(
          l10n.builtInCyclingDistance,
          dimension: Dimension.distance,
          unit: 'km',
          decimals: 2,
        ),
        _text(l10n.builtInCyclingRoute, suggest: true),
        _rating(l10n.builtInCyclingFelt),
      ]),
      _activity(l10n.builtInSwimming, 'swimming-pool', 'sky', timer: true, [
        _number(
          l10n.builtInSwimmingDistance,
          dimension: Dimension.distance,
          unit: 'm',
        ),
        _number(l10n.builtInSwimmingLaps),
        _multiChoice(l10n.builtInSwimmingStrokes, [
          l10n.builtInSwimmingStrokesFreestyle,
          l10n.builtInSwimmingStrokesBreaststroke,
          l10n.builtInSwimmingStrokesBackstroke,
          l10n.builtInSwimmingStrokesButterfly,
        ]),
      ]),
      _activity(l10n.builtInYoga, 'yin-yang', 'teal', timer: true, [
        _choice(l10n.builtInYogaStyle, [
          l10n.builtInYogaStyleHatha,
          l10n.builtInYogaStyleVinyasa,
          l10n.builtInYogaStyleYin,
          l10n.builtInYogaStylePower,
          l10n.builtInYogaStyleRestorative,
        ]),
        _rating(l10n.builtInYogaFeltAfter),
      ]),
      _activity(l10n.builtInStretching, 'flower-lotus', 'lilac', timer: true, [
        _multiChoice(l10n.builtInStretchingAreas, [
          l10n.builtInStretchingAreasNeck,
          l10n.builtInStretchingAreasShoulders,
          l10n.builtInStretchingAreasBack,
          l10n.builtInStretchingAreasHips,
          l10n.builtInStretchingAreasLegs,
          l10n.builtInStretchingAreasFullBody,
        ]),
      ]),
      _activity(l10n.builtInHomeWorkout, 'timer', 'coral', timer: true, [
        _list(
          l10n.builtInHomeWorkoutExercises,
          l10n.builtInHomeWorkoutExercisesItem,
          [
            _text(
              l10n.builtInHomeWorkoutExercisesExercise,
              required: true,
              suggest: true,
            ),
            _number(l10n.builtInHomeWorkoutExercisesReps),
            _number(l10n.builtInHomeWorkoutExercisesRounds),
          ],
        ),
        _rating(l10n.builtInHomeWorkoutEffort),
      ]),
      _activity(l10n.builtInHiking, 'mountains', 'teal', timer: true, [
        _text(l10n.builtInHikingTrail, suggest: true),
        _number(
          l10n.builtInHikingDistance,
          dimension: Dimension.distance,
          unit: 'km',
          decimals: 2,
        ),
        _number(
          l10n.builtInHikingElevationGain,
          dimension: Dimension.distance,
          unit: 'm',
        ),
        _rating(l10n.builtInHikingFelt),
      ]),
      _activity(l10n.builtInTeamSport, 'soccer-ball', 'coral', timer: true, [
        _choice(l10n.builtInTeamSportSport, [
          l10n.builtInTeamSportSportFootball,
          l10n.builtInTeamSportSportBasketball,
          l10n.builtInTeamSportSportCricket,
          l10n.builtInTeamSportSportVolleyball,
          l10n.builtInTeamSportSportHockey,
          l10n.builtInTeamSportSportOther,
        ]),
        _choice(l10n.builtInTeamSportResult, [
          l10n.builtInTeamSportResultWon,
          l10n.builtInTeamSportResultLost,
          l10n.builtInTeamSportResultDraw,
          l10n.builtInTeamSportResultJustPlayed,
        ]),
        _rating(l10n.builtInTeamSportHowIPlayed),
      ]),
      _activity(l10n.builtInRacketSport, 'tennis-ball', 'sky', timer: true, [
        _choice(l10n.builtInRacketSportSport, [
          l10n.builtInRacketSportSportTennis,
          l10n.builtInRacketSportSportBadminton,
          l10n.builtInRacketSportSportSquash,
          l10n.builtInRacketSportSportTableTennis,
          l10n.builtInRacketSportSportPadel,
        ]),
        _text(l10n.builtInRacketSportOpponent, suggest: true),
        _choice(l10n.builtInRacketSportResult, [
          l10n.builtInRacketSportResultWon,
          l10n.builtInRacketSportResultLost,
          l10n.builtInRacketSportResultJustPlayed,
        ]),
      ]),
      _activity(l10n.builtInDance, 'music-notes', 'rose', timer: true, [
        _text(l10n.builtInDanceStyle, suggest: true),
        _rating(l10n.builtInDanceFun),
      ]),
      _activity(l10n.builtInDailySteps, 'person-simple-walk', 'teal', [
        _number(l10n.builtInDailyStepsSteps),
      ]),
      _activity(l10n.builtInSuryaNamaskar, 'yin-yang', 'coral', timer: true, [
        _number(l10n.builtInSuryaNamaskarRounds),
        _rating(l10n.builtInSuryaNamaskarFeltAfter),
      ]),
      _activity(l10n.builtInPilates, 'flower-lotus', 'rose', timer: true, [
        _choice(l10n.builtInPilatesKind, [
          l10n.builtInPilatesKindMat,
          l10n.builtInPilatesKindReformer,
        ]),
        _rating(l10n.builtInPilatesFeltAfter),
      ]),
      _activity(l10n.builtInClimbing, 'mountains', 'coral', timer: true, [
        _choice(l10n.builtInClimbingKind, [
          l10n.builtInClimbingKindBouldering,
          l10n.builtInClimbingKindTopRope,
          l10n.builtInClimbingKindLead,
          l10n.builtInClimbingKindOutdoor,
        ]),
        _number(l10n.builtInClimbingRoutes),
        _text(l10n.builtInClimbingHardestGrade),
      ]),
      _activity(l10n.builtInMartialArts, 'target', 'slate', timer: true, [
        _text(l10n.builtInMartialArtsStyle, suggest: true),
        _text(l10n.builtInMartialArtsTechniques, multiline: true),
        _number(l10n.builtInMartialArtsSparringRounds),
      ]),
      _activity(l10n.builtInGolf, 'target', 'teal', timer: true, [
        _text(l10n.builtInGolfCourse, suggest: true),
        _choice(l10n.builtInGolfHoles, [
          l10n.builtInGolfHoles9,
          l10n.builtInGolfHoles18,
        ]),
        _number(l10n.builtInGolfScore),
      ]),
      _activity(l10n.builtInWinterSports, 'mountains', 'sky', timer: true, [
        _choice(l10n.builtInWinterSportsKind, [
          l10n.builtInWinterSportsKindSkiing,
          l10n.builtInWinterSportsKindSnowboarding,
          l10n.builtInWinterSportsKindIceSkating,
          l10n.builtInWinterSportsKindSledging,
        ]),
        _number(l10n.builtInWinterSportsRuns),
        _text(l10n.builtInWinterSportsWhere, suggest: true),
      ]),
    ]),
    ActivityCategory(l10n.builtInCategoryMindAndWellbeing, [
      starter(l10n.builtInMeditation),
      starter(l10n.builtInMood),
      _activity(l10n.builtInJournal, 'pencil-simple', 'lilac', [
        _text(l10n.builtInJournalEntry, multiline: true),
        _rating(l10n.builtInJournalHowTheDayWas),
      ]),
      _activity(l10n.builtInGratitude, 'heart', 'rose', [
        _list(
          l10n.builtInGratitudeGratefulFor,
          l10n.builtInGratitudeGratefulForItem,
          [_text(l10n.builtInGratitudeGratefulForThing, required: true)],
        ),
      ]),
      _activity(l10n.builtInBreathing, 'leaf', 'teal', timer: true, [
        _choice(l10n.builtInBreathingTechnique, [
          l10n.builtInBreathingTechniqueBoxBreathing,
          l10n.builtInBreathingTechnique478,
          l10n.builtInBreathingTechniqueDeepBelly,
          l10n.builtInBreathingTechniqueAlternateNostril,
        ]),
        _number(l10n.builtInBreathingRounds),
      ]),
      _activity(l10n.builtInTherapySession, 'chat-circle', 'lilac', [
        _text(l10n.builtInTherapySessionWith, suggest: true),
        _text(l10n.builtInTherapySessionTalkedAbout, multiline: true),
        _text(l10n.builtInTherapySessionTakeaways, multiline: true),
        _rating(l10n.builtInTherapySessionFeltAfter),
      ]),
      _activity(l10n.builtInScreenTime, 'phone', 'slate', [
        _duration(l10n.builtInScreenTimeTotal),
        _number(l10n.builtInScreenTimePickups),
        _text(l10n.builtInScreenTimeMostUsedApp, suggest: true),
      ]),
      _activity(l10n.builtInHabitToBreak, 'target', 'coral', [
        _text(l10n.builtInHabitToBreakHabit, suggest: true),
        _yesNo(l10n.builtInHabitToBreakKeptClearToday),
        _number(l10n.builtInHabitToBreakUrges),
        _text(l10n.builtInHabitToBreakNotes, multiline: true),
      ]),
      _activity(l10n.builtInDigitalDetox, 'leaf', 'teal', timer: true, [
        _yesNo(l10n.builtInDigitalDetoxPhoneAway),
        _rating(l10n.builtInDigitalDetoxHowItFelt),
      ]),
      _activity(l10n.builtInAffirmations, 'sparkle', 'rose', [
        _text(l10n.builtInAffirmationsTodaySAffirmation, multiline: true),
        _yesNo(l10n.builtInAffirmationsSaidOutLoud),
      ]),
      _activity(l10n.builtInPranayama, 'leaf', 'teal', timer: true, [
        _choice(l10n.builtInPranayamaTechnique, [
          l10n.builtInPranayamaTechniqueAnulomVilom,
          l10n.builtInPranayamaTechniqueKapalbhati,
          l10n.builtInPranayamaTechniqueBhramari,
          l10n.builtInPranayamaTechniqueBhastrika,
          l10n.builtInPranayamaTechniqueUjjayi,
        ]),
        _number(l10n.builtInPranayamaRounds),
      ]),
      _activity(l10n.builtInTimeOutdoors, 'leaf', 'teal', timer: true, [
        _text(l10n.builtInTimeOutdoorsWhere),
        _yesNo(l10n.builtInTimeOutdoorsMorningSunlight),
        _rating(l10n.builtInTimeOutdoorsFeltAfter),
      ]),
      _activity(l10n.builtInSocialMedia, 'phone', 'lilac', [
        _multiChoice(l10n.builtInSocialMediaApps, [
          l10n.builtInSocialMediaAppsInstagram,
          l10n.builtInSocialMediaAppsYouTube,
          l10n.builtInSocialMediaAppsTikTok,
          l10n.builtInSocialMediaAppsWhatsApp,
          l10n.builtInSocialMediaAppsFacebook,
          l10n.builtInSocialMediaAppsX,
          l10n.builtInSocialMediaAppsReddit,
          l10n.builtInSocialMediaAppsSnapchat,
        ]),
        _duration(l10n.builtInSocialMediaTimeSpent),
        _rating(l10n.builtInSocialMediaFeltAfter),
      ]),
      _activity(l10n.builtInNews, 'globe', 'slate', [
        _text(l10n.builtInNewsSource, suggest: true),
        _text(l10n.builtInNewsWhatStoodOut, multiline: true),
      ]),
      _activity(l10n.builtInKindAct, 'heart', 'rose', [
        _text(l10n.builtInKindActWhatIDid, multiline: true),
        _text(l10n.builtInKindActForWhom),
      ]),
    ]),
    ActivityCategory(l10n.builtInCategoryFaithAndSpirituality, [
      _activity(l10n.builtInPrayerAndWorship, 'star', 'slate', timer: true, [
        _text(l10n.builtInPrayerAndWorshipPracticeOrPlace, suggest: true),
        _text(l10n.builtInPrayerAndWorshipReflection, multiline: true),
      ]),
      _activity(l10n.builtInPuja, 'sparkle', 'coral', [
        _text(l10n.builtInPujaDeityOrOccasion, suggest: true),
        _multiChoice(l10n.builtInPujaOfferings, [
          l10n.builtInPujaOfferingsFlowers,
          l10n.builtInPujaOfferingsDiya,
          l10n.builtInPujaOfferingsIncense,
          l10n.builtInPujaOfferingsPrasad,
          l10n.builtInPujaOfferingsAarti,
        ]),
        _yesNo(l10n.builtInPujaWithFamily),
      ]),
      _activity(l10n.builtInSalah, 'star', 'teal', [
        _multiChoice(l10n.builtInSalahPrayers, [
          l10n.builtInSalahPrayersFajr,
          l10n.builtInSalahPrayersDhuhr,
          l10n.builtInSalahPrayersAsr,
          l10n.builtInSalahPrayersMaghrib,
          l10n.builtInSalahPrayersIsha,
        ]),
        _yesNo(l10n.builtInSalahOnTime),
        _yesNo(l10n.builtInSalahAtTheMosque),
      ]),
      _activity(
        l10n.builtInScriptureReading,
        'book-open',
        'lilac',
        timer: true,
        [
          _text(l10n.builtInScriptureReadingText, suggest: true),
          _text(l10n.builtInScriptureReadingPassage),
          _text(l10n.builtInScriptureReadingReflection, multiline: true),
        ],
      ),
      _activity(l10n.builtInChanting, 'flower-lotus', 'lilac', timer: true, [
        _text(l10n.builtInChantingMantra, suggest: true),
        _number(l10n.builtInChantingMalas),
        _number(l10n.builtInChantingCount),
      ]),
      _activity(l10n.builtInReligiousFast, 'moon', 'slate', [
        _text(l10n.builtInReligiousFastOccasion, suggest: true),
        _choice(l10n.builtInReligiousFastKind, [
          l10n.builtInReligiousFastKindSunriseToSunset,
          l10n.builtInReligiousFastKindWaterOnly,
          l10n.builtInReligiousFastKindFruitAndMilk,
          l10n.builtInReligiousFastKindOneMeal,
          l10n.builtInReligiousFastKindNoWater,
        ]),
        _time(l10n.builtInReligiousFastBrokeTheFastAt),
      ]),
    ]),
    ActivityCategory(l10n.builtInCategoryHobbiesAndFun, [
      starter(l10n.builtInReading),
      _activity(l10n.builtInTVAndMovies, 'star', 'lilac', timer: true, [
        _text(l10n.builtInTVAndMoviesTitle, suggest: true),
        _choice(l10n.builtInTVAndMoviesKind, [
          l10n.builtInTVAndMoviesKindMovie,
          l10n.builtInTVAndMoviesKindSeries,
          l10n.builtInTVAndMoviesKindDocumentary,
          l10n.builtInTVAndMoviesKindShow,
        ]),
        _number(l10n.builtInTVAndMoviesEpisodes),
        _rating(l10n.builtInTVAndMoviesRating),
      ]),
      _activity(l10n.builtInGaming, 'game-controller', 'lilac', timer: true, [
        _text(l10n.builtInGamingGame, suggest: true),
        _choice(l10n.builtInGamingPlatform, [
          l10n.builtInGamingPlatformPC,
          l10n.builtInGamingPlatformConsole,
          l10n.builtInGamingPlatformMobile,
          l10n.builtInGamingPlatformBoardGame,
          l10n.builtInGamingPlatformCards,
        ]),
        _rating(l10n.builtInGamingFun),
      ]),
      _activity(l10n.builtInPodcast, 'microphone', 'coral', timer: true, [
        _text(l10n.builtInPodcastShow, suggest: true),
        _text(l10n.builtInPodcastEpisode),
        _text(l10n.builtInPodcastTakeaways, multiline: true),
      ]),
      _activity(
        l10n.builtInDrawingAndPainting,
        'paint-brush',
        'rose',
        timer: true,
        [
          _choice(l10n.builtInDrawingAndPaintingMedium, [
            l10n.builtInDrawingAndPaintingMediumPencil,
            l10n.builtInDrawingAndPaintingMediumInk,
            l10n.builtInDrawingAndPaintingMediumWatercolor,
            l10n.builtInDrawingAndPaintingMediumAcrylic,
            l10n.builtInDrawingAndPaintingMediumOil,
            l10n.builtInDrawingAndPaintingMediumDigital,
          ]),
          _text(l10n.builtInDrawingAndPaintingPiece),
          _rating(l10n.builtInDrawingAndPaintingHappyWithIt),
        ],
      ),
      _activity(l10n.builtInPhotography, 'camera', 'slate', [
        _text(l10n.builtInPhotographySubject),
        _number(l10n.builtInPhotographyPhotosTaken),
        _number(l10n.builtInPhotographyKeepers),
      ]),
      _activity(l10n.builtInWriting, 'pencil-simple', 'sky', timer: true, [
        _text(l10n.builtInWritingProject, suggest: true),
        _number(l10n.builtInWritingWords),
        _text(l10n.builtInWritingNotes, multiline: true),
      ]),
      _activity(l10n.builtInCrafts, 'paint-brush', 'coral', timer: true, [
        _choice(l10n.builtInCraftsCraft, [
          l10n.builtInCraftsCraftKnitting,
          l10n.builtInCraftsCraftCrochet,
          l10n.builtInCraftsCraftSewing,
          l10n.builtInCraftsCraftWoodwork,
          l10n.builtInCraftsCraftPottery,
          l10n.builtInCraftsCraftOther,
        ]),
        _text(l10n.builtInCraftsProject, suggest: true),
        _rating(l10n.builtInCraftsProgress),
      ]),
      _activity(l10n.builtInPuzzles, 'brain', 'lilac', timer: true, [
        _choice(l10n.builtInPuzzlesGame, [
          l10n.builtInPuzzlesGameSudoku,
          l10n.builtInPuzzlesGameCrossword,
          l10n.builtInPuzzlesGameChess,
          l10n.builtInPuzzlesGameJigsaw,
          l10n.builtInPuzzlesGameWordGame,
          l10n.builtInPuzzlesGameOther,
        ]),
        _yesNo(l10n.builtInPuzzlesSolved),
        _number(l10n.builtInPuzzlesScore),
      ]),
      _activity(l10n.builtInListeningToMusic, 'music-notes', 'sky', [
        _text(l10n.builtInListeningToMusicArtistOrAlbum, suggest: true),
        _rating(l10n.builtInListeningToMusicEnjoyed),
      ]),
      _activity(l10n.builtInWatchingSport, 'soccer-ball', 'coral', [
        _text(l10n.builtInWatchingSportMatch, suggest: true),
        _text(l10n.builtInWatchingSportTeam, suggest: true),
        _choice(l10n.builtInWatchingSportResult, [
          l10n.builtInWatchingSportResultWon,
          l10n.builtInWatchingSportResultLost,
          l10n.builtInWatchingSportResultDraw,
          l10n.builtInWatchingSportResultNoResult,
        ]),
      ]),
      _activity(l10n.builtInFishing, 'drop', 'sky', timer: true, [
        _text(l10n.builtInFishingSpot, suggest: true),
        _list(l10n.builtInFishingCatch, l10n.builtInFishingCatchItem, [
          _text(l10n.builtInFishingCatchFish, required: true, suggest: true),
          _number(
            l10n.builtInFishingCatchWeight,
            dimension: Dimension.mass,
            unit: 'kg',
            decimals: 2,
          ),
        ]),
      ]),
      _activity(l10n.builtInContentCreation, 'camera', 'rose', timer: true, [
        _choice(l10n.builtInContentCreationPlatform, [
          l10n.builtInContentCreationPlatformYouTube,
          l10n.builtInContentCreationPlatformInstagram,
          l10n.builtInContentCreationPlatformTikTok,
          l10n.builtInContentCreationPlatformBlog,
          l10n.builtInContentCreationPlatformPodcast,
          l10n.builtInContentCreationPlatformOther,
        ]),
        _text(l10n.builtInContentCreationPiece),
        _number(l10n.builtInContentCreationViews),
      ]),
    ]),
    ActivityCategory(l10n.builtInCategoryFriendsAndCommunity, [
      _activity(
        l10n.builtInTimeWithFriends,
        'users-three',
        'coral',
        timer: true,
        [
          _text(l10n.builtInTimeWithFriendsWho),
          _text(l10n.builtInTimeWithFriendsWhatWeDid, multiline: true),
          _rating(l10n.builtInTimeWithFriendsHowItFelt),
        ],
      ),
      _activity(l10n.builtInPhoneCall, 'phone', 'sky', [
        _text(l10n.builtInPhoneCallWho, suggest: true),
        _text(l10n.builtInPhoneCallTalkedAbout),
        _yesNo(l10n.builtInPhoneCallFollowUpNeeded),
      ]),
      _activity(l10n.builtInDateNight, 'heart', 'rose', [
        _text(l10n.builtInDateNightWhere),
        _text(l10n.builtInDateNightWhatWeDid, multiline: true),
        _rating(l10n.builtInDateNightRating),
      ]),
      _activity(l10n.builtInEvent, 'star', 'lilac', [
        _text(l10n.builtInEventEvent),
        _text(l10n.builtInEventWhere),
        _rating(l10n.builtInEventHowItWas),
      ]),
      _activity(l10n.builtInVolunteering, 'heart', 'teal', timer: true, [
        _text(l10n.builtInVolunteeringOrganization, suggest: true),
        _text(l10n.builtInVolunteeringWhatIDid, multiline: true),
        _number(l10n.builtInVolunteeringPeopleHelped),
      ]),
    ]),
    ActivityCategory(l10n.builtInCategoryTravelAndErrands, [
      _activity(l10n.builtInErrands, 'car', 'slate', [
        _list(l10n.builtInErrandsErrands, l10n.builtInErrandsErrandsItem, [
          _text(l10n.builtInErrandsErrandsErrand, required: true),
          _yesNo(l10n.builtInErrandsErrandsDone),
        ]),
      ]),
      _activity(l10n.builtInAppointment, 'notebook', 'sky', [
        _text(l10n.builtInAppointmentWith, suggest: true),
        _text(l10n.builtInAppointmentPurpose),
        _date(l10n.builtInAppointmentNextAppointment),
      ]),
      _activity(l10n.builtInDriving, 'car', 'slate', timer: true, [
        _number(
          l10n.builtInDrivingDistance,
          dimension: Dimension.distance,
          unit: 'km',
          decimals: 2,
        ),
        _number(
          l10n.builtInDrivingFuel,
          dimension: Dimension.volume,
          unit: 'l',
          decimals: 2,
        ),
        _text(l10n.builtInDrivingPurpose),
      ]),
      _activity(l10n.builtInTrip, 'airplane', 'sky', [
        _text(l10n.builtInTripDestination, suggest: true),
        _choice(l10n.builtInTripTravelBy, [
          l10n.builtInTripTravelByPlane,
          l10n.builtInTripTravelByTrain,
          l10n.builtInTripTravelByCar,
          l10n.builtInTripTravelByBus,
          l10n.builtInTripTravelByBoat,
        ]),
        _text(l10n.builtInTripHighlights, multiline: true),
      ]),
      _activity(l10n.builtInPacking, 'airplane', 'teal', [
        _list(
          l10n.builtInPackingPackingList,
          l10n.builtInPackingPackingListItem,
          [
            _text(l10n.builtInPackingPackingListItem, required: true),
            _yesNo(l10n.builtInPackingPackingListDone),
          ],
        ),
      ]),
    ]),
  ];
}

ActivityTypeDefinition _activity(
  String name,
  String iconId,
  String colorKey,
  List<FieldDefinition> fields, {
  bool timer = false,
}) => ActivityTypeDefinition(
  name: name,
  iconId: iconId,
  colorKey: colorKey,
  supportsTimer: timer,
  fields: fields,
);

FieldDefinition _text(
  String name, {
  bool multiline = false,
  bool suggest = false,
  bool required = false,
}) => FieldDefinition(
  name: name,
  type: FieldType.text,
  required: required,
  config: TextFieldConfig(multiline: multiline, suggestFromHistory: suggest),
);

FieldDefinition _number(
  String name, {
  Dimension? dimension,
  String? unit,
  int decimals = 0,
}) => FieldDefinition(
  name: name,
  type: FieldType.number,
  dimension: dimension,
  config: NumberFieldConfig(
    decimals: decimals,
    min: dimension == Dimension.temperature ? null : 0,
    defaultUnitCode: unit,
  ),
  measurable: true,
);

FieldDefinition _rating(String name) => FieldDefinition(
  name: name,
  type: FieldType.rating,
  config: const RatingFieldConfig(),
  measurable: true,
);

FieldDefinition _yesNo(String name) => FieldDefinition(
  name: name,
  type: FieldType.boolean,
  config: const BooleanFieldConfig(),
);

FieldDefinition _duration(String name) => FieldDefinition(
  name: name,
  type: FieldType.duration,
  config: const DurationFieldConfig(),
  measurable: true,
);

FieldDefinition _time(String name) => FieldDefinition(
  name: name,
  type: FieldType.time,
  config: const TimeFieldConfig(),
);

FieldDefinition _date(String name) => FieldDefinition(
  name: name,
  type: FieldType.date,
  config: const DateFieldConfig(),
);

FieldDefinition _choice(String name, List<String> options) => FieldDefinition(
  name: name,
  type: FieldType.singleSelect,
  config: _options(options),
);

FieldDefinition _multiChoice(String name, List<String> options) =>
    FieldDefinition(
      name: name,
      type: FieldType.multiSelect,
      config: _options(options),
    );

/// Option IDs are placeholders; installing assigns fresh UUIDv7 IDs.
SelectFieldConfig _options(List<String> labels) => SelectFieldConfig(
  options: [
    for (final (i, label) in labels.indexed)
      SelectOption(id: SelectOptionId('option-$i'), label: label),
  ],
);

FieldDefinition _list(
  String name,
  String itemLabel,
  List<FieldDefinition> subFields,
) => FieldDefinition(
  name: name,
  type: FieldType.repeatingGroup,
  config: RepeatingGroupFieldConfig(itemLabel: itemLabel),
  subFields: subFields,
);
