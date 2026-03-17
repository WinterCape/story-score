/// Reason codes for score changes — used in ScoreChange.reasonCode
abstract final class ScoreReasons {
  static const storytellerGoodClue = 'storyteller_good';
  static const correctGuess = 'correct_guess';
  static const fooledBonus = 'fooled_bonus';
  static const allGuessedBonus = 'all_guessed_bonus';
  static const manualAdjustment = 'manual_adjustment';

  static String labelFor(String code) => switch (code) {
    storytellerGoodClue => 'Good clue',
    correctGuess => 'Correct guess',
    fooledBonus => 'Fooled bonus',
    allGuessedBonus => 'Everyone/nobody guessed',
    manualAdjustment => 'Manual adjustment',
    _ => code,
  };
}
