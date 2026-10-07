import '../../../core/units/unit_registry.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/activity_ids.dart';
import '../domain/activity_type_definition.dart';
import '../domain/field_config.dart';
import '../domain/field_type.dart';
import 'activity_templates.dart';

/// A heading in the template gallery and the templates under it.
class TemplateCategory {
  const TemplateCategory(this.name, this.templates);

  final String name;
  final List<ActivityTypeDefinition> templates;
}

/// Every template in the gallery, in category order. Quick add suggests
/// them while typing.
List<ActivityTypeDefinition> activityTemplates(AppLocalizations l10n) => [
  for (final category in templateCategories(l10n)) ...category.templates,
];

/// The template gallery: everyday life grouped the way time-use surveys
/// group it (personal care, eating, household, caring for others, work,
/// education, sport, leisure, social and community, travel), plus the habits
/// people most often track. Plain data like [starterTemplates]: each becomes
/// an ordinary, editable activity once added. No code may treat one
/// specially.
List<TemplateCategory> templateCategories(AppLocalizations l10n) {
  final starters = {for (final t in starterTemplates(l10n)) t.name: t};
  ActivityTypeDefinition starter(String name) => starters[name]!;
  return [
    TemplateCategory(l10n.templateCategorySleepAndSelfCare, [
      starter(l10n.templateSleep),
      _template(l10n.templateNap, 'moon', 'slate', timer: true, [
        _rating(l10n.templateNapFeltAfter),
      ]),
      _template(l10n.templateMorningRoutine, 'coffee', 'sky', [
        _time(l10n.templateMorningRoutineWokeUpAt),
        _list(
          l10n.templateMorningRoutineSteps,
          l10n.templateMorningRoutineStepsItem,
          [
            _text(l10n.templateMorningRoutineStepsStep, required: true),
            _yesNo(l10n.templateMorningRoutineStepsDone),
          ],
        ),
        _rating(l10n.templateMorningRoutineEnergy),
      ]),
      _template(l10n.templateEveningRoutine, 'moon', 'lilac', [
        _time(l10n.templateEveningRoutineLightsOutAt),
        _list(
          l10n.templateEveningRoutineSteps,
          l10n.templateEveningRoutineStepsItem,
          [
            _text(l10n.templateEveningRoutineStepsStep, required: true),
            _yesNo(l10n.templateEveningRoutineStepsDone),
          ],
        ),
        _yesNo(l10n.templateEveningRoutineScreensOffAnHourBefore),
      ]),
      _template(l10n.templateShower, 'drop', 'sky', [
        _choice(l10n.templateShowerKind, [
          l10n.templateShowerKindShower,
          l10n.templateShowerKindBath,
          l10n.templateShowerKindColdShower,
        ]),
        _rating(l10n.templateShowerFeltAfter),
      ]),
      _template(l10n.templateSkincare, 'sparkle', 'rose', [
        _multiChoice(l10n.templateSkincareProducts, [
          l10n.templateSkincareProductsCleanser,
          l10n.templateSkincareProductsToner,
          l10n.templateSkincareProductsSerum,
          l10n.templateSkincareProductsMoisturizer,
          l10n.templateSkincareProductsSunscreen,
          l10n.templateSkincareProductsMask,
        ]),
        _rating(l10n.templateSkincareSkinToday),
      ]),
      _template(l10n.templateOralCare, 'tooth', 'sky', [
        _yesNo(l10n.templateOralCareBrushed),
        _yesNo(l10n.templateOralCareFlossed),
        _yesNo(l10n.templateOralCareMouthwash),
      ]),
      _template(l10n.templateGrooming, 'sparkle', 'slate', [
        _multiChoice(l10n.templateGroomingWhat, [
          l10n.templateGroomingWhatHaircut,
          l10n.templateGroomingWhatShave,
          l10n.templateGroomingWhatBeardTrim,
          l10n.templateGroomingWhatNails,
          l10n.templateGroomingWhatHairWash,
        ]),
        _number(l10n.templateGroomingCost, decimals: 2),
      ]),
      _template(l10n.templateAyurvedicMorning, 'leaf', 'teal', [
        _yesNo(l10n.templateAyurvedicMorningUpBeforeSunrise),
        _multiChoice(l10n.templateAyurvedicMorningPractices, [
          l10n.templateAyurvedicMorningPracticesTongueScraping,
          l10n.templateAyurvedicMorningPracticesOilPulling,
          l10n.templateAyurvedicMorningPracticesAbhyanga,
          l10n.templateAyurvedicMorningPracticesWarmWater,
          l10n.templateAyurvedicMorningPracticesNeti,
        ]),
        _rating(l10n.templateAyurvedicMorningFeltAfter),
      ]),
      _template(l10n.templateHairOiling, 'drop', 'coral', [
        _text(l10n.templateHairOilingOil, suggest: true),
        _yesNo(l10n.templateHairOilingLeftOnOvernight),
      ]),
      _template(l10n.templateMassageAndSpa, 'sparkle', 'lilac', timer: true, [
        _choice(l10n.templateMassageAndSpaKind, [
          l10n.templateMassageAndSpaKindMassage,
          l10n.templateMassageAndSpaKindSpa,
          l10n.templateMassageAndSpaKindFacial,
          l10n.templateMassageAndSpaKindFootMassage,
          l10n.templateMassageAndSpaKindSelfMassage,
        ]),
        _rating(l10n.templateMassageAndSpaFeltAfter),
        _number(l10n.templateMassageAndSpaCost, decimals: 2),
      ]),
      _template(l10n.templateSaunaAndColdPlunge, 'drop', 'sky', timer: true, [
        _choice(l10n.templateSaunaAndColdPlungeKind, [
          l10n.templateSaunaAndColdPlungeKindSauna,
          l10n.templateSaunaAndColdPlungeKindColdPlunge,
          l10n.templateSaunaAndColdPlungeKindSteamRoom,
          l10n.templateSaunaAndColdPlungeKindContrast,
        ]),
        _number(l10n.templateSaunaAndColdPlungeRounds),
        _number(
          l10n.templateSaunaAndColdPlungeTemperature,
          dimension: Dimension.temperature,
          unit: 'celsius',
        ),
      ]),
    ]),
    TemplateCategory(l10n.templateCategoryHealth, [
      _template(l10n.templateMedication, 'pill', 'rose', [
        _text(l10n.templateMedicationMedicine, suggest: true),
        _text(l10n.templateMedicationDose),
        _yesNo(l10n.templateMedicationTaken),
        _text(l10n.templateMedicationSideEffects),
      ]),
      _template(l10n.templateVitaminsAndSupplements, 'pill', 'teal', [
        _list(
          l10n.templateVitaminsAndSupplementsSupplements,
          l10n.templateVitaminsAndSupplementsSupplementsItem,
          [
            _text(
              l10n.templateVitaminsAndSupplementsSupplementsSupplement,
              required: true,
              suggest: true,
            ),
            _yesNo(l10n.templateVitaminsAndSupplementsSupplementsTaken),
          ],
        ),
      ]),
      _template(l10n.templateDoctorVisit, 'first-aid', 'rose', [
        _text(l10n.templateDoctorVisitDoctorOrClinic, suggest: true),
        _text(l10n.templateDoctorVisitReason),
        _text(l10n.templateDoctorVisitWhatTheySaid, multiline: true),
        _date(l10n.templateDoctorVisitNextVisit),
      ]),
      _template(l10n.templateSymptoms, 'first-aid', 'coral', [
        _multiChoice(l10n.templateSymptomsSymptoms, [
          l10n.templateSymptomsSymptomsHeadache,
          l10n.templateSymptomsSymptomsFever,
          l10n.templateSymptomsSymptomsCough,
          l10n.templateSymptomsSymptomsSoreThroat,
          l10n.templateSymptomsSymptomsFatigue,
          l10n.templateSymptomsSymptomsNausea,
          l10n.templateSymptomsSymptomsPain,
        ]),
        _rating(l10n.templateSymptomsSeverity),
        _text(l10n.templateSymptomsNotes, multiline: true),
      ]),
      _template(l10n.templateBloodPressure, 'heart', 'rose', [
        _number(l10n.templateBloodPressureSystolic),
        _number(l10n.templateBloodPressureDiastolic),
        _number(l10n.templateBloodPressurePulse),
      ]),
      _template(l10n.templateBloodSugar, 'drop', 'coral', [
        _number(l10n.templateBloodSugarReading, decimals: 1),
        _choice(l10n.templateBloodSugarWhen, [
          l10n.templateBloodSugarWhenFasting,
          l10n.templateBloodSugarWhenBeforeAMeal,
          l10n.templateBloodSugarWhenAfterAMeal,
          l10n.templateBloodSugarWhenBedtime,
        ]),
      ]),
      _template(l10n.templateBodyTemperature, 'first-aid', 'coral', [
        _number(
          l10n.templateBodyTemperatureTemperature,
          dimension: Dimension.temperature,
          unit: 'celsius',
          decimals: 1,
        ),
      ]),
      _template(l10n.templatePeriod, 'heart', 'rose', [
        _choice(l10n.templatePeriodFlow, [
          l10n.templatePeriodFlowSpotting,
          l10n.templatePeriodFlowLight,
          l10n.templatePeriodFlowMedium,
          l10n.templatePeriodFlowHeavy,
        ]),
        _multiChoice(l10n.templatePeriodSymptoms, [
          l10n.templatePeriodSymptomsCramps,
          l10n.templatePeriodSymptomsBloating,
          l10n.templatePeriodSymptomsHeadache,
          l10n.templatePeriodSymptomsMoodSwings,
          l10n.templatePeriodSymptomsFatigue,
          l10n.templatePeriodSymptomsCravings,
        ]),
        _text(l10n.templatePeriodNotes, multiline: true),
      ]),
      _template(l10n.templatePhysiotherapy, 'first-aid', 'teal', timer: true, [
        _list(
          l10n.templatePhysiotherapyExercises,
          l10n.templatePhysiotherapyExercisesItem,
          [
            _text(l10n.templatePhysiotherapyExercisesExercise, required: true),
            _yesNo(l10n.templatePhysiotherapyExercisesDone),
          ],
        ),
        _rating(l10n.templatePhysiotherapyPainLevel),
      ]),
      _template(l10n.templatePain, 'first-aid', 'rose', [
        _multiChoice(l10n.templatePainWhere, [
          l10n.templatePainWhereHead,
          l10n.templatePainWhereNeck,
          l10n.templatePainWhereBack,
          l10n.templatePainWhereJoints,
          l10n.templatePainWhereStomach,
          l10n.templatePainWhereMuscles,
        ]),
        _rating(l10n.templatePainLevel),
        _text(l10n.templatePainPossibleTrigger),
      ]),
      _template(l10n.templateDigestion, 'leaf', 'teal', [
        _choice(l10n.templateDigestionType, [
          l10n.templateDigestionTypeHard,
          l10n.templateDigestionTypeNormal,
          l10n.templateDigestionTypeSoft,
          l10n.templateDigestionTypeLoose,
        ]),
        _yesNo(l10n.templateDigestionBloating),
        _text(l10n.templateDigestionNotes, multiline: true),
      ]),
      _template(l10n.templateEnergyCheck, 'lightbulb', 'coral', [
        _rating(l10n.templateEnergyCheckEnergy),
        _rating(l10n.templateEnergyCheckFocus),
      ]),
    ]),
    TemplateCategory(l10n.templateCategoryFoodAndDrink, [
      _template(l10n.templateMeal, 'fork-knife', 'coral', [
        _choice(l10n.templateMealMeal, [
          l10n.templateMealMealBreakfast,
          l10n.templateMealMealLunch,
          l10n.templateMealMealDinner,
          l10n.templateMealMealSnack,
        ]),
        _text(l10n.templateMealWhatIAte, multiline: true),
        _number(
          l10n.templateMealCalories,
          dimension: Dimension.energy,
          unit: 'kcal',
        ),
        _rating(l10n.templateMealHowHealthy),
        _yesNo(l10n.templateMealAteOut),
      ]),
      starter(l10n.templateWater),
      _template(l10n.templateCoffeeAndTea, 'coffee', 'coral', [
        _choice(l10n.templateCoffeeAndTeaDrink, [
          l10n.templateCoffeeAndTeaDrinkCoffee,
          l10n.templateCoffeeAndTeaDrinkEspresso,
          l10n.templateCoffeeAndTeaDrinkTea,
          l10n.templateCoffeeAndTeaDrinkGreenTea,
          l10n.templateCoffeeAndTeaDrinkHerbalTea,
        ]),
        _number(l10n.templateCoffeeAndTeaCups),
      ]),
      starter(l10n.templateCooking),
      _template(l10n.templateFasting, 'timer', 'teal', timer: true, [
        _choice(l10n.templateFastingPlan, [
          l10n.templateFastingPlan1212,
          l10n.templateFastingPlan168,
          l10n.templateFastingPlan186,
          l10n.templateFastingPlan204,
          l10n.templateFastingPlan24Hours,
        ]),
        _time(l10n.templateFastingBrokeTheFastAt),
        _rating(l10n.templateFastingHowItFelt),
      ]),
      _template(l10n.templateAlcohol, 'drop', 'lilac', [
        _number(l10n.templateAlcoholDrinks),
        _multiChoice(l10n.templateAlcoholKind, [
          l10n.templateAlcoholKindBeer,
          l10n.templateAlcoholKindWine,
          l10n.templateAlcoholKindSpirits,
          l10n.templateAlcoholKindCocktail,
          l10n.templateAlcoholKindCider,
        ]),
      ]),
      _template(l10n.templateMealPrep, 'cooking-pot', 'teal', timer: true, [
        _list(l10n.templateMealPrepDishes, l10n.templateMealPrepDishesItem, [
          _text(l10n.templateMealPrepDishesDish, required: true, suggest: true),
          _number(l10n.templateMealPrepDishesPortions),
        ]),
      ]),
      _template(l10n.templateProtein, 'fork-knife', 'coral', [
        _number(
          l10n.templateProteinProtein,
          dimension: Dimension.mass,
          unit: 'g',
        ),
      ]),
      _template(l10n.templateFruitAndVeg, 'leaf', 'teal', [
        _number(l10n.templateFruitAndVegPortions),
        _multiChoice(l10n.templateFruitAndVegColoursEaten, [
          l10n.templateFruitAndVegColoursEatenGreen,
          l10n.templateFruitAndVegColoursEatenRed,
          l10n.templateFruitAndVegColoursEatenOrange,
          l10n.templateFruitAndVegColoursEatenYellow,
          l10n.templateFruitAndVegColoursEatenPurple,
          l10n.templateFruitAndVegColoursEatenWhite,
        ]),
      ]),
      _template(l10n.templatePackedLunch, 'fork-knife', 'sky', [
        _text(l10n.templatePackedLunchFor, suggest: true),
        _text(l10n.templatePackedLunchWhatWentIn, multiline: true),
        _yesNo(l10n.templatePackedLunchEaten),
      ]),
    ]),
    TemplateCategory(l10n.templateCategoryHomeAndChores, [
      _template(l10n.templateCleaning, 'broom', 'teal', timer: true, [
        _multiChoice(l10n.templateCleaningRooms, [
          l10n.templateCleaningRoomsKitchen,
          l10n.templateCleaningRoomsBathroom,
          l10n.templateCleaningRoomsBedroom,
          l10n.templateCleaningRoomsLivingRoom,
          l10n.templateCleaningRoomsWholeHome,
        ]),
        _list(l10n.templateCleaningTasks, l10n.templateCleaningTasksItem, [
          _text(l10n.templateCleaningTasksTask, required: true),
          _yesNo(l10n.templateCleaningTasksDone),
        ]),
      ]),
      _template(l10n.templateLaundry, 'house', 'sky', [
        _number(l10n.templateLaundryLoads),
        _multiChoice(l10n.templateLaundrySteps, [
          l10n.templateLaundryStepsWashed,
          l10n.templateLaundryStepsDried,
          l10n.templateLaundryStepsFolded,
          l10n.templateLaundryStepsIroned,
          l10n.templateLaundryStepsPutAway,
        ]),
      ]),
      _template(l10n.templateDishes, 'house', 'sky', [
        _choice(l10n.templateDishesHow, [
          l10n.templateDishesHowByHand,
          l10n.templateDishesHowDishwasher,
        ]),
        _yesNo(l10n.templateDishesKitchenWiped),
      ]),
      _template(l10n.templateGroceries, 'shopping-cart', 'coral', [
        _text(l10n.templateGroceriesStore, suggest: true),
        _list(
          l10n.templateGroceriesShoppingList,
          l10n.templateGroceriesShoppingListItem,
          [
            _text(
              l10n.templateGroceriesShoppingListItem,
              required: true,
              suggest: true,
            ),
            _yesNo(l10n.templateGroceriesShoppingListGotIt),
          ],
        ),
        _number(l10n.templateGroceriesSpent, decimals: 2),
      ]),
      _template(l10n.templateGardening, 'plant', 'teal', timer: true, [
        _multiChoice(l10n.templateGardeningTasks, [
          l10n.templateGardeningTasksWatering,
          l10n.templateGardeningTasksPlanting,
          l10n.templateGardeningTasksWeeding,
          l10n.templateGardeningTasksPruning,
          l10n.templateGardeningTasksMowing,
          l10n.templateGardeningTasksHarvesting,
        ]),
        _text(l10n.templateGardeningPlants),
      ]),
      _template(l10n.templatePlantCare, 'leaf', 'teal', [
        _list(l10n.templatePlantCarePlants, l10n.templatePlantCarePlantsItem, [
          _text(
            l10n.templatePlantCarePlantsPlant,
            required: true,
            suggest: true,
          ),
          _yesNo(l10n.templatePlantCarePlantsWatered),
          _yesNo(l10n.templatePlantCarePlantsFed),
        ]),
      ]),
      _template(l10n.templateHomeRepair, 'wrench', 'slate', timer: true, [
        _text(l10n.templateHomeRepairProject, suggest: true),
        _text(l10n.templateHomeRepairWhatWasDone, multiline: true),
        _number(l10n.templateHomeRepairCost, decimals: 2),
      ]),
      _template(l10n.templateDeclutter, 'broom', 'lilac', [
        _text(l10n.templateDeclutterArea),
        _number(l10n.templateDeclutterItemsRemoved),
        _choice(l10n.templateDeclutterWhereTheyWent, [
          l10n.templateDeclutterWhereTheyWentDonated,
          l10n.templateDeclutterWhereTheyWentSold,
          l10n.templateDeclutterWhereTheyWentRecycled,
          l10n.templateDeclutterWhereTheyWentThrownAway,
        ]),
      ]),
      _template(l10n.templateHouseHelp, 'house', 'teal', [
        _text(l10n.templateHouseHelpWho, suggest: true),
        _yesNo(l10n.templateHouseHelpCameToday),
        _multiChoice(l10n.templateHouseHelpTasks, [
          l10n.templateHouseHelpTasksSweeping,
          l10n.templateHouseHelpTasksMopping,
          l10n.templateHouseHelpTasksDishes,
          l10n.templateHouseHelpTasksLaundry,
          l10n.templateHouseHelpTasksCooking,
          l10n.templateHouseHelpTasksDusting,
        ]),
        _number(l10n.templateHouseHelpPaid, decimals: 2),
      ]),
      _template(l10n.templateCarCare, 'car', 'slate', [
        _multiChoice(l10n.templateCarCareWhat, [
          l10n.templateCarCareWhatFuel,
          l10n.templateCarCareWhatWash,
          l10n.templateCarCareWhatService,
          l10n.templateCarCareWhatTyres,
          l10n.templateCarCareWhatOilChange,
          l10n.templateCarCareWhatRepair,
        ]),
        _number(
          l10n.templateCarCareOdometer,
          dimension: Dimension.distance,
          unit: 'km',
        ),
        _number(l10n.templateCarCareCost, decimals: 2),
      ]),
    ]),
    TemplateCategory(l10n.templateCategoryMoney, [
      _template(l10n.templateBills, 'wallet', 'slate', [
        _list(l10n.templateBillsBills, l10n.templateBillsBillsItem, [
          _text(l10n.templateBillsBillsBill, required: true, suggest: true),
          _number(l10n.templateBillsBillsAmount, decimals: 2),
          _yesNo(l10n.templateBillsBillsPaid),
        ]),
      ]),
      _template(l10n.templateExpense, 'wallet', 'coral', [
        _number(l10n.templateExpenseAmount, decimals: 2),
        _choice(l10n.templateExpenseCategory, [
          l10n.templateExpenseCategoryFood,
          l10n.templateExpenseCategoryTransport,
          l10n.templateExpenseCategoryHome,
          l10n.templateExpenseCategoryHealth,
          l10n.templateExpenseCategoryFun,
          l10n.templateExpenseCategoryShopping,
          l10n.templateExpenseCategoryBills,
          l10n.templateExpenseCategoryOther,
        ]),
        _text(l10n.templateExpenseWhatFor),
      ]),
      _template(l10n.templateBudgetReview, 'wallet', 'teal', [
        _number(l10n.templateBudgetReviewSpentThisWeek, decimals: 2),
        _number(l10n.templateBudgetReviewSaved, decimals: 2),
        _rating(l10n.templateBudgetReviewOnTrack),
      ]),
      _template(l10n.templateInvesting, 'wallet', 'sky', [
        _text(l10n.templateInvestingFundOrAsset, suggest: true),
        _choice(l10n.templateInvestingKind, [
          l10n.templateInvestingKindBuy,
          l10n.templateInvestingKindSell,
          l10n.templateInvestingKindSIP,
          l10n.templateInvestingKindDeposit,
          l10n.templateInvestingKindDividend,
        ]),
        _number(l10n.templateInvestingAmount, decimals: 2),
      ]),
      _template(l10n.templateSavings, 'wallet', 'teal', [
        _text(l10n.templateSavingsGoal, suggest: true),
        _number(l10n.templateSavingsAdded, decimals: 2),
        _number(l10n.templateSavingsTotalSoFar, decimals: 2),
      ]),
      _template(l10n.templateDonation, 'wallet', 'teal', [
        _text(l10n.templateDonationCause, suggest: true),
        _number(l10n.templateDonationAmount, decimals: 2),
      ]),
    ]),
    TemplateCategory(l10n.templateCategoryFamilyAndCare, [
      _template(l10n.templateChildcare, 'baby', 'sky', [
        _text(l10n.templateChildcareChild, suggest: true),
        _multiChoice(l10n.templateChildcareWhatWeDid, [
          l10n.templateChildcareWhatWeDidMeals,
          l10n.templateChildcareWhatWeDidSchoolRun,
          l10n.templateChildcareWhatWeDidHomework,
          l10n.templateChildcareWhatWeDidPlaytime,
          l10n.templateChildcareWhatWeDidBath,
          l10n.templateChildcareWhatWeDidBedtime,
        ]),
        _text(l10n.templateChildcareNotes, multiline: true),
      ]),
      _template(l10n.templateBabyFeeding, 'baby', 'rose', [
        _choice(l10n.templateBabyFeedingKind, [
          l10n.templateBabyFeedingKindBreastLeft,
          l10n.templateBabyFeedingKindBreastRight,
          l10n.templateBabyFeedingKindBottle,
          l10n.templateBabyFeedingKindSolids,
        ]),
        _number(
          l10n.templateBabyFeedingAmount,
          dimension: Dimension.volume,
          unit: 'ml',
        ),
        _text(l10n.templateBabyFeedingNotes, multiline: true),
      ]),
      _template(l10n.templateDiaperChange, 'baby', 'sky', [
        _choice(l10n.templateDiaperChangeKind, [
          l10n.templateDiaperChangeKindWet,
          l10n.templateDiaperChangeKindDirty,
          l10n.templateDiaperChangeKindBoth,
        ]),
      ]),
      _template(l10n.templatePetCare, 'dog', 'coral', [
        _text(l10n.templatePetCarePet, suggest: true),
        _multiChoice(l10n.templatePetCareCare, [
          l10n.templatePetCareCareFed,
          l10n.templatePetCareCareWalked,
          l10n.templatePetCareCareGroomed,
          l10n.templatePetCareCarePlayed,
          l10n.templatePetCareCareMedicine,
          l10n.templatePetCareCareVetVisit,
        ]),
        _text(l10n.templatePetCareNotes, multiline: true),
      ]),
      _template(l10n.templateDogWalk, 'dog', 'teal', timer: true, [
        _text(l10n.templateDogWalkDog, suggest: true),
        _number(
          l10n.templateDogWalkDistance,
          dimension: Dimension.distance,
          unit: 'km',
          decimals: 2,
        ),
      ]),
      _template(l10n.templateFamilyTime, 'users-three', 'rose', [
        _text(l10n.templateFamilyTimeWho),
        _text(l10n.templateFamilyTimeWhatWeDid, multiline: true),
        _rating(l10n.templateFamilyTimeHowItFelt),
      ]),
      _template(l10n.templateCaringForSomeone, 'heart', 'lilac', [
        _text(l10n.templateCaringForSomeoneWho, suggest: true),
        _multiChoice(l10n.templateCaringForSomeoneHelpGiven, [
          l10n.templateCaringForSomeoneHelpGivenCompany,
          l10n.templateCaringForSomeoneHelpGivenMeals,
          l10n.templateCaringForSomeoneHelpGivenErrands,
          l10n.templateCaringForSomeoneHelpGivenMedicine,
          l10n.templateCaringForSomeoneHelpGivenAppointments,
        ]),
        _text(l10n.templateCaringForSomeoneNotes, multiline: true),
      ]),
      _template(l10n.templateSchoolRun, 'car', 'sky', [
        _text(l10n.templateSchoolRunChild, suggest: true),
        _choice(l10n.templateSchoolRunHow, [
          l10n.templateSchoolRunHowCar,
          l10n.templateSchoolRunHowWalk,
          l10n.templateSchoolRunHowBus,
          l10n.templateSchoolRunHowBike,
          l10n.templateSchoolRunHowAuto,
          l10n.templateSchoolRunHowSchoolVan,
        ]),
        _yesNo(l10n.templateSchoolRunOnTime),
      ]),
    ]),
    TemplateCategory(l10n.templateCategoryWork, [
      starter(l10n.templateFocusedWork),
      starter(l10n.templateMeeting),
      _template(l10n.templateDailyPlanning, 'target', 'teal', [
        _list(
          l10n.templateDailyPlanningTopPriorities,
          l10n.templateDailyPlanningTopPrioritiesItem,
          [
            _text(
              l10n.templateDailyPlanningTopPrioritiesPriority,
              required: true,
            ),
            _yesNo(l10n.templateDailyPlanningTopPrioritiesDone),
          ],
        ),
        _text(l10n.templateDailyPlanningNotes, multiline: true),
      ]),
      _template(l10n.templateCommute, 'car', 'slate', timer: true, [
        _choice(l10n.templateCommuteHow, [
          l10n.templateCommuteHowCar,
          l10n.templateCommuteHowBus,
          l10n.templateCommuteHowTrain,
          l10n.templateCommuteHowBike,
          l10n.templateCommuteHowWalk,
          l10n.templateCommuteHowOther,
        ]),
        _number(
          l10n.templateCommuteDistance,
          dimension: Dimension.distance,
          unit: 'km',
          decimals: 2,
        ),
        _rating(l10n.templateCommuteHowItWent),
      ]),
      _template(l10n.templateEmailAndAdmin, 'envelope', 'sky', timer: true, [
        _number(l10n.templateEmailAndAdminEmailsHandled),
        _yesNo(l10n.templateEmailAndAdminInboxZero),
      ]),
      _template(l10n.templateCoding, 'code', 'lilac', timer: true, [
        _text(l10n.templateCodingProject, suggest: true),
        _text(l10n.templateCodingWhatIBuilt, multiline: true),
        _number(l10n.templateCodingCommits),
      ]),
      _template(l10n.templateSideProject, 'lightbulb', 'coral', timer: true, [
        _text(l10n.templateSideProjectProject, suggest: true),
        _text(l10n.templateSideProjectProgress, multiline: true),
        _rating(l10n.templateSideProjectMomentum),
      ]),
      _template(l10n.templateJobSearch, 'briefcase', 'slate', [
        _text(l10n.templateJobSearchCompany, suggest: true),
        _text(l10n.templateJobSearchRole),
        _choice(l10n.templateJobSearchStage, [
          l10n.templateJobSearchStageApplied,
          l10n.templateJobSearchStageInterview,
          l10n.templateJobSearchStageOffer,
          l10n.templateJobSearchStageRejected,
          l10n.templateJobSearchStageFollowingUp,
        ]),
        _text(l10n.templateJobSearchNotes, multiline: true),
      ]),
      _template(l10n.templatePresentation, 'presentation-chart', 'lilac', [
        _text(l10n.templatePresentationTopic),
        _text(l10n.templatePresentationAudience),
        _rating(l10n.templatePresentationHowItWent),
      ]),
      _template(l10n.templateClientWork, 'briefcase', 'lilac', timer: true, [
        _text(l10n.templateClientWorkClient, suggest: true),
        _text(l10n.templateClientWorkTask),
        _yesNo(l10n.templateClientWorkBillable),
      ]),
      _template(l10n.templateShift, 'briefcase', 'slate', timer: true, [
        _choice(l10n.templateShiftShift, [
          l10n.templateShiftShiftMorning,
          l10n.templateShiftShiftDay,
          l10n.templateShiftShiftEvening,
          l10n.templateShiftShiftNight,
          l10n.templateShiftShiftSplit,
        ]),
        _yesNo(l10n.templateShiftTookABreak),
        _number(l10n.templateShiftEarned, decimals: 2),
      ]),
      _template(l10n.templateGigWork, 'car', 'coral', timer: true, [
        _text(l10n.templateGigWorkPlatform, suggest: true),
        _number(l10n.templateGigWorkTripsOrOrders),
        _number(l10n.templateGigWorkEarned, decimals: 2),
        _number(
          l10n.templateGigWorkDistance,
          dimension: Dimension.distance,
          unit: 'km',
          decimals: 1,
        ),
      ]),
      _template(l10n.templateNetworking, 'users-three', 'sky', [
        _text(l10n.templateNetworkingPerson, suggest: true),
        _text(l10n.templateNetworkingWhereWeMet),
        _date(l10n.templateNetworkingFollowUpOn),
      ]),
      _template(l10n.templateWeeklyReview, 'notebook', 'teal', [
        _text(l10n.templateWeeklyReviewWins, multiline: true),
        _text(l10n.templateWeeklyReviewLessons, multiline: true),
        _list(
          l10n.templateWeeklyReviewNextWeek,
          l10n.templateWeeklyReviewNextWeekItem,
          [
            _text(l10n.templateWeeklyReviewNextWeekPriority, required: true),
            _yesNo(l10n.templateWeeklyReviewNextWeekDone),
          ],
        ),
      ]),
      _template(l10n.templateGoalCheckIn, 'target', 'coral', [
        _text(l10n.templateGoalCheckInGoal, suggest: true),
        _rating(l10n.templateGoalCheckInProgress),
        _text(l10n.templateGoalCheckInNextStep),
      ]),
    ]),
    TemplateCategory(l10n.templateCategoryLearning, [
      starter(l10n.templateStudy),
      starter(l10n.templateLanguage),
      _template(l10n.templateClass, 'graduation-cap', 'lilac', timer: true, [
        _text(l10n.templateClassCourse, suggest: true),
        _text(l10n.templateClassTopic),
        _text(l10n.templateClassNotes, multiline: true),
        _rating(l10n.templateClassUnderstood),
      ]),
      _template(l10n.templateHomework, 'notebook', 'sky', timer: true, [
        _text(l10n.templateHomeworkSubject, suggest: true),
        _text(l10n.templateHomeworkTask),
        _yesNo(l10n.templateHomeworkFinished),
      ]),
      _template(l10n.templateOnlineCourse, 'laptop', 'teal', timer: true, [
        _text(l10n.templateOnlineCourseCourse, suggest: true),
        _number(l10n.templateOnlineCourseLessonsDone),
        _text(l10n.templateOnlineCourseTakeaways, multiline: true),
      ]),
      _template(
        l10n.templateMusicPractice,
        'music-notes',
        'coral',
        timer: true,
        [
          _choice(l10n.templateMusicPracticeInstrument, [
            l10n.templateMusicPracticeInstrumentGuitar,
            l10n.templateMusicPracticeInstrumentPiano,
            l10n.templateMusicPracticeInstrumentDrums,
            l10n.templateMusicPracticeInstrumentViolin,
            l10n.templateMusicPracticeInstrumentVoice,
            l10n.templateMusicPracticeInstrumentOther,
          ]),
          _list(
            l10n.templateMusicPracticePieces,
            l10n.templateMusicPracticePiecesItem,
            [
              _text(
                l10n.templateMusicPracticePiecesPiece,
                required: true,
                suggest: true,
              ),
              _number(l10n.templateMusicPracticePiecesTempoBpm),
            ],
          ),
          _rating(l10n.templateMusicPracticeHowItWent),
        ],
      ),
      _template(l10n.templateSkillPractice, 'target', 'lilac', timer: true, [
        _text(l10n.templateSkillPracticeSkill, suggest: true),
        _text(l10n.templateSkillPracticeWhatIPractised, multiline: true),
        _rating(l10n.templateSkillPracticeProgress),
      ]),
      _template(l10n.templateTuition, 'graduation-cap', 'sky', timer: true, [
        _text(l10n.templateTuitionSubject, suggest: true),
        _text(l10n.templateTuitionTopic),
        _number(l10n.templateTuitionTestScore, decimals: 1),
      ]),
      _template(l10n.templateExamPrep, 'notebook', 'coral', timer: true, [
        _text(l10n.templateExamPrepExam, suggest: true),
        _text(l10n.templateExamPrepTopicsCovered, multiline: true),
        _number(l10n.templateExamPrepMockTestScore, decimals: 1),
        _rating(l10n.templateExamPrepConfidence),
      ]),
      _template(l10n.templateFlashcards, 'brain', 'lilac', [
        _text(l10n.templateFlashcardsDeck, suggest: true),
        _number(l10n.templateFlashcardsCardsReviewed),
        _number(
          l10n.templateFlashcardsCorrect,
          dimension: Dimension.percentage,
          unit: 'percent',
        ),
      ]),
      _template(
        l10n.templateTeaching,
        'presentation-chart',
        'teal',
        timer: true,
        [
          _text(l10n.templateTeachingTopic),
          _number(l10n.templateTeachingStudents),
          _rating(l10n.templateTeachingHowItWent),
        ],
      ),
    ]),
    TemplateCategory(l10n.templateCategoryExerciseAndSport, [
      starter(l10n.templateGym),
      starter(l10n.templateRunning),
      starter(l10n.templateWalking),
      _template(l10n.templateCycling, 'bicycle', 'sky', timer: true, [
        _number(
          l10n.templateCyclingDistance,
          dimension: Dimension.distance,
          unit: 'km',
          decimals: 2,
        ),
        _text(l10n.templateCyclingRoute, suggest: true),
        _rating(l10n.templateCyclingFelt),
      ]),
      _template(l10n.templateSwimming, 'swimming-pool', 'sky', timer: true, [
        _number(
          l10n.templateSwimmingDistance,
          dimension: Dimension.distance,
          unit: 'm',
        ),
        _number(l10n.templateSwimmingLaps),
        _multiChoice(l10n.templateSwimmingStrokes, [
          l10n.templateSwimmingStrokesFreestyle,
          l10n.templateSwimmingStrokesBreaststroke,
          l10n.templateSwimmingStrokesBackstroke,
          l10n.templateSwimmingStrokesButterfly,
        ]),
      ]),
      _template(l10n.templateYoga, 'yin-yang', 'teal', timer: true, [
        _choice(l10n.templateYogaStyle, [
          l10n.templateYogaStyleHatha,
          l10n.templateYogaStyleVinyasa,
          l10n.templateYogaStyleYin,
          l10n.templateYogaStylePower,
          l10n.templateYogaStyleRestorative,
        ]),
        _rating(l10n.templateYogaFeltAfter),
      ]),
      _template(l10n.templateStretching, 'flower-lotus', 'lilac', timer: true, [
        _multiChoice(l10n.templateStretchingAreas, [
          l10n.templateStretchingAreasNeck,
          l10n.templateStretchingAreasShoulders,
          l10n.templateStretchingAreasBack,
          l10n.templateStretchingAreasHips,
          l10n.templateStretchingAreasLegs,
          l10n.templateStretchingAreasFullBody,
        ]),
      ]),
      _template(l10n.templateHomeWorkout, 'timer', 'coral', timer: true, [
        _list(
          l10n.templateHomeWorkoutExercises,
          l10n.templateHomeWorkoutExercisesItem,
          [
            _text(
              l10n.templateHomeWorkoutExercisesExercise,
              required: true,
              suggest: true,
            ),
            _number(l10n.templateHomeWorkoutExercisesReps),
            _number(l10n.templateHomeWorkoutExercisesRounds),
          ],
        ),
        _rating(l10n.templateHomeWorkoutEffort),
      ]),
      _template(l10n.templateHiking, 'mountains', 'teal', timer: true, [
        _text(l10n.templateHikingTrail, suggest: true),
        _number(
          l10n.templateHikingDistance,
          dimension: Dimension.distance,
          unit: 'km',
          decimals: 2,
        ),
        _number(
          l10n.templateHikingElevationGain,
          dimension: Dimension.distance,
          unit: 'm',
        ),
        _rating(l10n.templateHikingFelt),
      ]),
      _template(l10n.templateTeamSport, 'soccer-ball', 'coral', timer: true, [
        _choice(l10n.templateTeamSportSport, [
          l10n.templateTeamSportSportFootball,
          l10n.templateTeamSportSportBasketball,
          l10n.templateTeamSportSportCricket,
          l10n.templateTeamSportSportVolleyball,
          l10n.templateTeamSportSportHockey,
          l10n.templateTeamSportSportOther,
        ]),
        _choice(l10n.templateTeamSportResult, [
          l10n.templateTeamSportResultWon,
          l10n.templateTeamSportResultLost,
          l10n.templateTeamSportResultDraw,
          l10n.templateTeamSportResultJustPlayed,
        ]),
        _rating(l10n.templateTeamSportHowIPlayed),
      ]),
      _template(l10n.templateRacketSport, 'tennis-ball', 'sky', timer: true, [
        _choice(l10n.templateRacketSportSport, [
          l10n.templateRacketSportSportTennis,
          l10n.templateRacketSportSportBadminton,
          l10n.templateRacketSportSportSquash,
          l10n.templateRacketSportSportTableTennis,
          l10n.templateRacketSportSportPadel,
        ]),
        _text(l10n.templateRacketSportOpponent, suggest: true),
        _choice(l10n.templateRacketSportResult, [
          l10n.templateRacketSportResultWon,
          l10n.templateRacketSportResultLost,
          l10n.templateRacketSportResultJustPlayed,
        ]),
      ]),
      _template(l10n.templateDance, 'music-notes', 'rose', timer: true, [
        _text(l10n.templateDanceStyle, suggest: true),
        _rating(l10n.templateDanceFun),
      ]),
      _template(l10n.templateDailySteps, 'person-simple-walk', 'teal', [
        _number(l10n.templateDailyStepsSteps),
      ]),
      _template(l10n.templateSuryaNamaskar, 'yin-yang', 'coral', timer: true, [
        _number(l10n.templateSuryaNamaskarRounds),
        _rating(l10n.templateSuryaNamaskarFeltAfter),
      ]),
      _template(l10n.templatePilates, 'flower-lotus', 'rose', timer: true, [
        _choice(l10n.templatePilatesKind, [
          l10n.templatePilatesKindMat,
          l10n.templatePilatesKindReformer,
        ]),
        _rating(l10n.templatePilatesFeltAfter),
      ]),
      _template(l10n.templateClimbing, 'mountains', 'coral', timer: true, [
        _choice(l10n.templateClimbingKind, [
          l10n.templateClimbingKindBouldering,
          l10n.templateClimbingKindTopRope,
          l10n.templateClimbingKindLead,
          l10n.templateClimbingKindOutdoor,
        ]),
        _number(l10n.templateClimbingRoutes),
        _text(l10n.templateClimbingHardestGrade),
      ]),
      _template(l10n.templateMartialArts, 'target', 'slate', timer: true, [
        _text(l10n.templateMartialArtsStyle, suggest: true),
        _text(l10n.templateMartialArtsTechniques, multiline: true),
        _number(l10n.templateMartialArtsSparringRounds),
      ]),
      _template(l10n.templateGolf, 'target', 'teal', timer: true, [
        _text(l10n.templateGolfCourse, suggest: true),
        _choice(l10n.templateGolfHoles, [
          l10n.templateGolfHoles9,
          l10n.templateGolfHoles18,
        ]),
        _number(l10n.templateGolfScore),
      ]),
      _template(l10n.templateWinterSports, 'mountains', 'sky', timer: true, [
        _choice(l10n.templateWinterSportsKind, [
          l10n.templateWinterSportsKindSkiing,
          l10n.templateWinterSportsKindSnowboarding,
          l10n.templateWinterSportsKindIceSkating,
          l10n.templateWinterSportsKindSledging,
        ]),
        _number(l10n.templateWinterSportsRuns),
        _text(l10n.templateWinterSportsWhere, suggest: true),
      ]),
    ]),
    TemplateCategory(l10n.templateCategoryMindAndWellbeing, [
      starter(l10n.templateMeditation),
      starter(l10n.templateMood),
      _template(l10n.templateJournal, 'pencil-simple', 'lilac', [
        _text(l10n.templateJournalEntry, multiline: true),
        _rating(l10n.templateJournalHowTheDayWas),
      ]),
      _template(l10n.templateGratitude, 'heart', 'rose', [
        _list(
          l10n.templateGratitudeGratefulFor,
          l10n.templateGratitudeGratefulForItem,
          [_text(l10n.templateGratitudeGratefulForThing, required: true)],
        ),
      ]),
      _template(l10n.templateBreathing, 'leaf', 'teal', timer: true, [
        _choice(l10n.templateBreathingTechnique, [
          l10n.templateBreathingTechniqueBoxBreathing,
          l10n.templateBreathingTechnique478,
          l10n.templateBreathingTechniqueDeepBelly,
          l10n.templateBreathingTechniqueAlternateNostril,
        ]),
        _number(l10n.templateBreathingRounds),
      ]),
      _template(l10n.templateTherapySession, 'chat-circle', 'lilac', [
        _text(l10n.templateTherapySessionWith, suggest: true),
        _text(l10n.templateTherapySessionTalkedAbout, multiline: true),
        _text(l10n.templateTherapySessionTakeaways, multiline: true),
        _rating(l10n.templateTherapySessionFeltAfter),
      ]),
      _template(l10n.templateScreenTime, 'phone', 'slate', [
        _duration(l10n.templateScreenTimeTotal),
        _number(l10n.templateScreenTimePickups),
        _text(l10n.templateScreenTimeMostUsedApp, suggest: true),
      ]),
      _template(l10n.templateHabitToBreak, 'target', 'coral', [
        _text(l10n.templateHabitToBreakHabit, suggest: true),
        _yesNo(l10n.templateHabitToBreakKeptClearToday),
        _number(l10n.templateHabitToBreakUrges),
        _text(l10n.templateHabitToBreakNotes, multiline: true),
      ]),
      _template(l10n.templateDigitalDetox, 'leaf', 'teal', timer: true, [
        _yesNo(l10n.templateDigitalDetoxPhoneAway),
        _rating(l10n.templateDigitalDetoxHowItFelt),
      ]),
      _template(l10n.templateAffirmations, 'sparkle', 'rose', [
        _text(l10n.templateAffirmationsTodaySAffirmation, multiline: true),
        _yesNo(l10n.templateAffirmationsSaidOutLoud),
      ]),
      _template(l10n.templatePranayama, 'leaf', 'teal', timer: true, [
        _choice(l10n.templatePranayamaTechnique, [
          l10n.templatePranayamaTechniqueAnulomVilom,
          l10n.templatePranayamaTechniqueKapalbhati,
          l10n.templatePranayamaTechniqueBhramari,
          l10n.templatePranayamaTechniqueBhastrika,
          l10n.templatePranayamaTechniqueUjjayi,
        ]),
        _number(l10n.templatePranayamaRounds),
      ]),
      _template(l10n.templateTimeOutdoors, 'leaf', 'teal', timer: true, [
        _text(l10n.templateTimeOutdoorsWhere),
        _yesNo(l10n.templateTimeOutdoorsMorningSunlight),
        _rating(l10n.templateTimeOutdoorsFeltAfter),
      ]),
      _template(l10n.templateSocialMedia, 'phone', 'lilac', [
        _multiChoice(l10n.templateSocialMediaApps, [
          l10n.templateSocialMediaAppsInstagram,
          l10n.templateSocialMediaAppsYouTube,
          l10n.templateSocialMediaAppsTikTok,
          l10n.templateSocialMediaAppsWhatsApp,
          l10n.templateSocialMediaAppsFacebook,
          l10n.templateSocialMediaAppsX,
          l10n.templateSocialMediaAppsReddit,
          l10n.templateSocialMediaAppsSnapchat,
        ]),
        _duration(l10n.templateSocialMediaTimeSpent),
        _rating(l10n.templateSocialMediaFeltAfter),
      ]),
      _template(l10n.templateNews, 'globe', 'slate', [
        _text(l10n.templateNewsSource, suggest: true),
        _text(l10n.templateNewsWhatStoodOut, multiline: true),
      ]),
      _template(l10n.templateKindAct, 'heart', 'rose', [
        _text(l10n.templateKindActWhatIDid, multiline: true),
        _text(l10n.templateKindActForWhom),
      ]),
    ]),
    TemplateCategory(l10n.templateCategoryFaithAndSpirituality, [
      _template(l10n.templatePrayerAndWorship, 'star', 'slate', timer: true, [
        _text(l10n.templatePrayerAndWorshipPracticeOrPlace, suggest: true),
        _text(l10n.templatePrayerAndWorshipReflection, multiline: true),
      ]),
      _template(l10n.templatePuja, 'sparkle', 'coral', [
        _text(l10n.templatePujaDeityOrOccasion, suggest: true),
        _multiChoice(l10n.templatePujaOfferings, [
          l10n.templatePujaOfferingsFlowers,
          l10n.templatePujaOfferingsDiya,
          l10n.templatePujaOfferingsIncense,
          l10n.templatePujaOfferingsPrasad,
          l10n.templatePujaOfferingsAarti,
        ]),
        _yesNo(l10n.templatePujaWithFamily),
      ]),
      _template(l10n.templateSalah, 'star', 'teal', [
        _multiChoice(l10n.templateSalahPrayers, [
          l10n.templateSalahPrayersFajr,
          l10n.templateSalahPrayersDhuhr,
          l10n.templateSalahPrayersAsr,
          l10n.templateSalahPrayersMaghrib,
          l10n.templateSalahPrayersIsha,
        ]),
        _yesNo(l10n.templateSalahOnTime),
        _yesNo(l10n.templateSalahAtTheMosque),
      ]),
      _template(
        l10n.templateScriptureReading,
        'book-open',
        'lilac',
        timer: true,
        [
          _text(l10n.templateScriptureReadingText, suggest: true),
          _text(l10n.templateScriptureReadingPassage),
          _text(l10n.templateScriptureReadingReflection, multiline: true),
        ],
      ),
      _template(l10n.templateChanting, 'flower-lotus', 'lilac', timer: true, [
        _text(l10n.templateChantingMantra, suggest: true),
        _number(l10n.templateChantingMalas),
        _number(l10n.templateChantingCount),
      ]),
      _template(l10n.templateReligiousFast, 'moon', 'slate', [
        _text(l10n.templateReligiousFastOccasion, suggest: true),
        _choice(l10n.templateReligiousFastKind, [
          l10n.templateReligiousFastKindSunriseToSunset,
          l10n.templateReligiousFastKindWaterOnly,
          l10n.templateReligiousFastKindFruitAndMilk,
          l10n.templateReligiousFastKindOneMeal,
          l10n.templateReligiousFastKindNoWater,
        ]),
        _time(l10n.templateReligiousFastBrokeTheFastAt),
      ]),
    ]),
    TemplateCategory(l10n.templateCategoryHobbiesAndFun, [
      starter(l10n.templateReading),
      _template(l10n.templateTVAndMovies, 'star', 'lilac', timer: true, [
        _text(l10n.templateTVAndMoviesTitle, suggest: true),
        _choice(l10n.templateTVAndMoviesKind, [
          l10n.templateTVAndMoviesKindMovie,
          l10n.templateTVAndMoviesKindSeries,
          l10n.templateTVAndMoviesKindDocumentary,
          l10n.templateTVAndMoviesKindShow,
        ]),
        _number(l10n.templateTVAndMoviesEpisodes),
        _rating(l10n.templateTVAndMoviesRating),
      ]),
      _template(l10n.templateGaming, 'game-controller', 'lilac', timer: true, [
        _text(l10n.templateGamingGame, suggest: true),
        _choice(l10n.templateGamingPlatform, [
          l10n.templateGamingPlatformPC,
          l10n.templateGamingPlatformConsole,
          l10n.templateGamingPlatformMobile,
          l10n.templateGamingPlatformBoardGame,
          l10n.templateGamingPlatformCards,
        ]),
        _rating(l10n.templateGamingFun),
      ]),
      _template(l10n.templatePodcast, 'microphone', 'coral', timer: true, [
        _text(l10n.templatePodcastShow, suggest: true),
        _text(l10n.templatePodcastEpisode),
        _text(l10n.templatePodcastTakeaways, multiline: true),
      ]),
      _template(
        l10n.templateDrawingAndPainting,
        'paint-brush',
        'rose',
        timer: true,
        [
          _choice(l10n.templateDrawingAndPaintingMedium, [
            l10n.templateDrawingAndPaintingMediumPencil,
            l10n.templateDrawingAndPaintingMediumInk,
            l10n.templateDrawingAndPaintingMediumWatercolor,
            l10n.templateDrawingAndPaintingMediumAcrylic,
            l10n.templateDrawingAndPaintingMediumOil,
            l10n.templateDrawingAndPaintingMediumDigital,
          ]),
          _text(l10n.templateDrawingAndPaintingPiece),
          _rating(l10n.templateDrawingAndPaintingHappyWithIt),
        ],
      ),
      _template(l10n.templatePhotography, 'camera', 'slate', [
        _text(l10n.templatePhotographySubject),
        _number(l10n.templatePhotographyPhotosTaken),
        _number(l10n.templatePhotographyKeepers),
      ]),
      _template(l10n.templateWriting, 'pencil-simple', 'sky', timer: true, [
        _text(l10n.templateWritingProject, suggest: true),
        _number(l10n.templateWritingWords),
        _text(l10n.templateWritingNotes, multiline: true),
      ]),
      _template(l10n.templateCrafts, 'paint-brush', 'coral', timer: true, [
        _choice(l10n.templateCraftsCraft, [
          l10n.templateCraftsCraftKnitting,
          l10n.templateCraftsCraftCrochet,
          l10n.templateCraftsCraftSewing,
          l10n.templateCraftsCraftWoodwork,
          l10n.templateCraftsCraftPottery,
          l10n.templateCraftsCraftOther,
        ]),
        _text(l10n.templateCraftsProject, suggest: true),
        _rating(l10n.templateCraftsProgress),
      ]),
      _template(l10n.templatePuzzles, 'brain', 'lilac', timer: true, [
        _choice(l10n.templatePuzzlesGame, [
          l10n.templatePuzzlesGameSudoku,
          l10n.templatePuzzlesGameCrossword,
          l10n.templatePuzzlesGameChess,
          l10n.templatePuzzlesGameJigsaw,
          l10n.templatePuzzlesGameWordGame,
          l10n.templatePuzzlesGameOther,
        ]),
        _yesNo(l10n.templatePuzzlesSolved),
        _number(l10n.templatePuzzlesScore),
      ]),
      _template(l10n.templateListeningToMusic, 'music-notes', 'sky', [
        _text(l10n.templateListeningToMusicArtistOrAlbum, suggest: true),
        _rating(l10n.templateListeningToMusicEnjoyed),
      ]),
      _template(l10n.templateWatchingSport, 'soccer-ball', 'coral', [
        _text(l10n.templateWatchingSportMatch, suggest: true),
        _text(l10n.templateWatchingSportTeam, suggest: true),
        _choice(l10n.templateWatchingSportResult, [
          l10n.templateWatchingSportResultWon,
          l10n.templateWatchingSportResultLost,
          l10n.templateWatchingSportResultDraw,
          l10n.templateWatchingSportResultNoResult,
        ]),
      ]),
      _template(l10n.templateFishing, 'drop', 'sky', timer: true, [
        _text(l10n.templateFishingSpot, suggest: true),
        _list(l10n.templateFishingCatch, l10n.templateFishingCatchItem, [
          _text(l10n.templateFishingCatchFish, required: true, suggest: true),
          _number(
            l10n.templateFishingCatchWeight,
            dimension: Dimension.mass,
            unit: 'kg',
            decimals: 2,
          ),
        ]),
      ]),
      _template(l10n.templateContentCreation, 'camera', 'rose', timer: true, [
        _choice(l10n.templateContentCreationPlatform, [
          l10n.templateContentCreationPlatformYouTube,
          l10n.templateContentCreationPlatformInstagram,
          l10n.templateContentCreationPlatformTikTok,
          l10n.templateContentCreationPlatformBlog,
          l10n.templateContentCreationPlatformPodcast,
          l10n.templateContentCreationPlatformOther,
        ]),
        _text(l10n.templateContentCreationPiece),
        _number(l10n.templateContentCreationViews),
      ]),
    ]),
    TemplateCategory(l10n.templateCategoryFriendsAndCommunity, [
      _template(
        l10n.templateTimeWithFriends,
        'users-three',
        'coral',
        timer: true,
        [
          _text(l10n.templateTimeWithFriendsWho),
          _text(l10n.templateTimeWithFriendsWhatWeDid, multiline: true),
          _rating(l10n.templateTimeWithFriendsHowItFelt),
        ],
      ),
      _template(l10n.templatePhoneCall, 'phone', 'sky', [
        _text(l10n.templatePhoneCallWho, suggest: true),
        _text(l10n.templatePhoneCallTalkedAbout),
        _yesNo(l10n.templatePhoneCallFollowUpNeeded),
      ]),
      _template(l10n.templateDateNight, 'heart', 'rose', [
        _text(l10n.templateDateNightWhere),
        _text(l10n.templateDateNightWhatWeDid, multiline: true),
        _rating(l10n.templateDateNightRating),
      ]),
      _template(l10n.templateEvent, 'star', 'lilac', [
        _text(l10n.templateEventEvent),
        _text(l10n.templateEventWhere),
        _rating(l10n.templateEventHowItWas),
      ]),
      _template(l10n.templateVolunteering, 'heart', 'teal', timer: true, [
        _text(l10n.templateVolunteeringOrganization, suggest: true),
        _text(l10n.templateVolunteeringWhatIDid, multiline: true),
        _number(l10n.templateVolunteeringPeopleHelped),
      ]),
    ]),
    TemplateCategory(l10n.templateCategoryTravelAndErrands, [
      _template(l10n.templateErrands, 'car', 'slate', [
        _list(l10n.templateErrandsErrands, l10n.templateErrandsErrandsItem, [
          _text(l10n.templateErrandsErrandsErrand, required: true),
          _yesNo(l10n.templateErrandsErrandsDone),
        ]),
      ]),
      _template(l10n.templateAppointment, 'notebook', 'sky', [
        _text(l10n.templateAppointmentWith, suggest: true),
        _text(l10n.templateAppointmentPurpose),
        _date(l10n.templateAppointmentNextAppointment),
      ]),
      _template(l10n.templateDriving, 'car', 'slate', timer: true, [
        _number(
          l10n.templateDrivingDistance,
          dimension: Dimension.distance,
          unit: 'km',
          decimals: 2,
        ),
        _number(
          l10n.templateDrivingFuel,
          dimension: Dimension.volume,
          unit: 'l',
          decimals: 2,
        ),
        _text(l10n.templateDrivingPurpose),
      ]),
      _template(l10n.templateTrip, 'airplane', 'sky', [
        _text(l10n.templateTripDestination, suggest: true),
        _choice(l10n.templateTripTravelBy, [
          l10n.templateTripTravelByPlane,
          l10n.templateTripTravelByTrain,
          l10n.templateTripTravelByCar,
          l10n.templateTripTravelByBus,
          l10n.templateTripTravelByBoat,
        ]),
        _text(l10n.templateTripHighlights, multiline: true),
      ]),
      _template(l10n.templatePacking, 'airplane', 'teal', [
        _list(
          l10n.templatePackingPackingList,
          l10n.templatePackingPackingListItem,
          [
            _text(l10n.templatePackingPackingListItem, required: true),
            _yesNo(l10n.templatePackingPackingListDone),
          ],
        ),
      ]),
    ]),
  ];
}

ActivityTypeDefinition _template(
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
      SelectOption(id: SelectOptionId('template-option-$i'), label: label),
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
