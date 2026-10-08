/// SQL condition: the `activity_logs` row aliased [log] counts as done.
///
/// A record counts when something is in it: a recorded time, notes, any
/// value, or its item marked done. An item opened and left empty doesn't.
/// One rule for Insights counts and streaks (ADR-043) and for challenge
/// days (ADR-044), so they never disagree about what was done.
String doneRecordSql(String log) =>
    '($log.duration_ms IS NOT NULL OR $log.notes IS NOT NULL '
    'OR EXISTS (SELECT 1 FROM log_values x WHERE x.log_id = $log.internal_id) '
    'OR EXISTS (SELECT 1 FROM plans cp WHERE cp.internal_id = $log.plan_id '
    "AND cp.status = 'completed'))";
