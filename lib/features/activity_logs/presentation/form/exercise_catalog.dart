import '../../../activity_types/domain/activity_type.dart';

/// Common exercise names, offered (after the user's own history) in a text
/// field named like "Exercise", so a workout can be logged without typing
/// every name.
const exerciseCatalog = [
  // Chest
  'Bench press', 'Incline bench press', 'Decline bench press',
  'Dumbbell bench press', 'Incline dumbbell press', 'Chest fly',
  'Cable crossover', 'Pec deck', 'Push-up', 'Chest dip', 'Machine chest press',
  // Back
  'Deadlift', 'Romanian deadlift', 'Pull-up', 'Chin-up', 'Lat pulldown',
  'Barbell row', 'Dumbbell row', 'Seated cable row', 'T-bar row',
  'Face pull', 'Shrug', 'Back extension', 'Rack pull', 'Straight-arm pulldown',
  // Shoulders
  'Overhead press', 'Dumbbell shoulder press', 'Arnold press',
  'Lateral raise', 'Front raise', 'Rear delt fly', 'Upright row',
  'Machine shoulder press',
  // Arms
  'Barbell curl', 'Dumbbell curl', 'Hammer curl', 'Preacher curl',
  'Cable curl', 'Concentration curl', 'Tricep pushdown',
  'Overhead tricep extension', 'Skull crusher', 'Close-grip bench press',
  'Tricep dip', 'Wrist curl',
  // Legs
  'Squat', 'Front squat', 'Goblet squat', 'Hack squat', 'Leg press',
  'Bulgarian split squat', 'Lunge', 'Walking lunge', 'Step-up',
  'Leg extension', 'Leg curl', 'Seated leg curl', 'Hip thrust',
  'Glute bridge', 'Calf raise', 'Seated calf raise', 'Hip abduction',
  'Hip adduction', 'Sumo deadlift', 'Good morning',
  // Core
  'Plank', 'Side plank', 'Crunch', 'Sit-up', 'Hanging leg raise',
  'Cable crunch', 'Russian twist', 'Ab wheel rollout', 'Mountain climber',
  'Dead bug', 'Bicycle crunch',
  // Full body and conditioning
  'Clean and press', 'Power clean', 'Snatch', 'Kettlebell swing',
  'Thruster', 'Burpee', 'Farmer\'s walk', 'Box jump', 'Battle ropes',
  'Sled push', 'Jump rope', 'Rowing machine', 'Treadmill', 'Stationary bike',
  'Elliptical', 'Stair climber',
];

/// Whether [field] names an exercise (gets [exerciseCatalog]).
bool isExerciseField(ActivityField field) =>
    field.name.toLowerCase().contains('exercise');
