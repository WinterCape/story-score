/// Outcome classification for the storyteller's clue in a round.
enum ClueOutcome {
  /// All or no non-storytellers guessed the storyteller's card.
  /// The clue was too obvious or too obscure.
  perfectFail,

  /// Some (but not all) non-storytellers guessed correctly.
  /// The clue was well-crafted.
  goodClue,
}

/// The reason a player earned points in a round.
enum ScoreReason {
  /// Storyteller earns +3 for giving a clue that some (not all) guessed.
  storytellerGoodClue,

  /// A non-storyteller earns +3 for correctly identifying the storyteller's card.
  correctGuess,

  /// A non-storyteller earns +1 per vote their card received from other players.
  fooledBonus,

  /// Every non-storyteller earns +2 when the storyteller's clue was a perfect fail.
  allGuessedBonus,
}

/// Human-readable labels for [ScoreReason] values.
extension ScoreReasonLabel on ScoreReason {
  String get label {
    switch (this) {
      case ScoreReason.storytellerGoodClue:
        return 'Good clue';
      case ScoreReason.correctGuess:
        return 'Correct guess';
      case ScoreReason.fooledBonus:
        return 'Fooled opponent';
      case ScoreReason.allGuessedBonus:
        return 'Bad clue bonus';
    }
  }
}
