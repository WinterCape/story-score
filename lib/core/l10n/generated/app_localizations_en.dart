// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'StoryScore';

  @override
  String get newGame => 'New Game';

  @override
  String get settings => 'Settings';

  @override
  String get startGame => 'Start Game';

  @override
  String get scoreRound => 'Score Round';

  @override
  String get endGame => 'End Game';

  @override
  String get endGameNow => 'End Game Now';

  @override
  String get continuePlaying => 'Continue Playing';

  @override
  String get newRound => 'New Round';

  @override
  String round(int number) {
    return 'Round $number';
  }

  @override
  String playerIsStoryteller(String name) {
    return '$name is the Storyteller';
  }

  @override
  String playerIsStorytelling(String name) {
    return '$name is storytelling';
  }

  @override
  String get whoDidEachPlayerVoteFor => 'Who did each player vote for?';

  @override
  String get allPlayersMustVote => 'All players must vote';

  @override
  String get addPlayer => 'Add Player';

  @override
  String get playerName => 'Player name';

  @override
  String get selectColor => 'Pick a color';

  @override
  String get gameTitle => 'Game Title';

  @override
  String get gameTitleHint => 'e.g. Friday Game Night';

  @override
  String get targetScore => 'Target Score';

  @override
  String get infinite => 'Infinite';

  @override
  String get continuePastTarget => 'Continue Past Target';

  @override
  String get continuePastTargetDescription =>
      'Keep playing after someone reaches the target';

  @override
  String get itsATie => 'It\'s a Tie!';

  @override
  String get winner => 'Winner!';

  @override
  String points(int count) {
    return '$count points';
  }

  @override
  String get finalStandings => 'Final Standings';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get shareResults => 'Share Results';

  @override
  String get activeGames => 'Active Games';

  @override
  String get completedGames => 'Completed Games';

  @override
  String get noGamesYet => 'No games yet';

  @override
  String get startYourFirstGame => 'Start your first game';

  @override
  String get startYourFirstGameDescription =>
      'Start your first game and begin tracking scores for your storytelling card game.';

  @override
  String get undoLastRound => 'Undo Last Round';

  @override
  String get deleteRound => 'Delete Round';

  @override
  String get editRound => 'Edit Round';

  @override
  String get exportGame => 'Export Game';

  @override
  String get exportAsJson => 'Export as JSON';

  @override
  String get exportAsJsonDescription => 'Full game data, can be re-imported';

  @override
  String get exportAsCsv => 'Export as CSV';

  @override
  String get exportAsCsvDescription => 'Spreadsheet-friendly format';

  @override
  String get importGame => 'Import Game';

  @override
  String get supporterPack => 'Supporter Pack';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get theme => 'Theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get hapticFeedbackDescription => 'Vibrate on score events';

  @override
  String get reduceMotion => 'Reduce Motion';

  @override
  String get reduceMotionDescription => 'Minimize animations';

  @override
  String get roundNotes => 'Show Round Notes';

  @override
  String get roundNotesDescription => 'Allow clue notes per round';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get discard => 'Discard';

  @override
  String get discardVotes => 'Discard votes?';

  @override
  String get discardVotesConfirmation =>
      'You have votes in progress. Going back will discard them.';

  @override
  String get confirm => 'Confirm';

  @override
  String get error => 'Error';

  @override
  String get goodClue => 'Good clue';

  @override
  String get badClue => 'Bad clue';

  @override
  String get correctGuess => 'Correct guess';

  @override
  String get fooledBonus => 'Fooled opponent';

  @override
  String reachedTarget(String name, int target) {
    return '$name reached $target points!';
  }

  @override
  String get appearance => 'Appearance';

  @override
  String get gameplay => 'Gameplay';

  @override
  String get support => 'Support';

  @override
  String get about => 'About';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get scoreboard => 'Scoreboard';

  @override
  String get roundTab => 'Round';

  @override
  String get history => 'History';

  @override
  String get roundHistory => 'Round History';

  @override
  String get noRoundsYet => 'No rounds yet';

  @override
  String get noRoundsYetDescription =>
      'Complete your first round and it will appear here.';

  @override
  String get stats => 'Stats';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get players => 'Players';

  @override
  String get gameOver => 'Game Over';

  @override
  String get winCondition => 'Win Condition';

  @override
  String get scoreTarget => 'Score Target';

  @override
  String get roundLimit => 'Round Limit';

  @override
  String get freePlay => 'Free Play';

  @override
  String get minPlayersRequired => 'Min 3 required';

  @override
  String playerCountLabel(int count) {
    return '$count/10';
  }

  @override
  String get quickStart => 'Quick Start';

  @override
  String get quickStartDescription =>
      'Pick a preset to start a game instantly.';

  @override
  String get loadPreset => 'Load Preset';

  @override
  String get saveAsPreset => 'Save as Preset';

  @override
  String get save => 'Save';

  @override
  String get presetName => 'Preset name';

  @override
  String savedPreset(String name) {
    return 'Saved preset \"$name\"';
  }

  @override
  String failedToSavePreset(String error) {
    return 'Failed to save preset: $error';
  }

  @override
  String failedToCreateGame(String error) {
    return 'Failed to create game: $error';
  }

  @override
  String get noPresetsYet => 'No presets saved yet.';

  @override
  String get chooseColor => 'Choose Color';

  @override
  String get avatarStyle => 'Avatar Style';

  @override
  String get initials => 'Initials';

  @override
  String get emoji => 'Emoji';

  @override
  String get add => 'Add';

  @override
  String get bonusEmojiPacks => '3 bonus emoji packs with Supporter Pack';

  @override
  String get sortByScore => 'Sort by score';

  @override
  String get sortBySeat => 'Sort by seat';

  @override
  String get failedToLoadSession => 'Failed to load session';

  @override
  String get sessionNotFound => 'Session not found';

  @override
  String get noPlayersInSession => 'No players in this session';

  @override
  String errorLoadingPlayers(String error) {
    return 'Error loading players: $error';
  }

  @override
  String get chooseStoryteller => 'Choose Storyteller';

  @override
  String get endGameQuestion => 'End Game?';

  @override
  String endGameConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'This will mark the game as completed after $count round$_temp0.';
  }

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String adjustScore(String name) {
    return 'Adjust $name\'s Score';
  }

  @override
  String currentScore(int score) {
    return 'Current: $score';
  }

  @override
  String newScore(int score) {
    return 'New score: $score';
  }

  @override
  String get apply => 'Apply';

  @override
  String get noStorytellerAssigned => 'No storyteller assigned';

  @override
  String get roundNoteHint => 'Round note (optional)';

  @override
  String errorScoringRound(String error) {
    return 'Error scoring round: $error';
  }

  @override
  String get roundDetail => 'Round Detail';

  @override
  String get roundNotFound => 'Round not found';

  @override
  String get votes => 'Votes';

  @override
  String get scoreChanges => 'Score Changes';

  @override
  String get editVotes => 'Edit Votes';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String failedToSaveChanges(String error) {
    return 'Failed to save changes: $error';
  }

  @override
  String get deleteRoundConfirmation =>
      'This will permanently delete this round and revert all score changes. This action cannot be undone.';

  @override
  String failedToDeleteRound(String error) {
    return 'Failed to delete round: $error';
  }

  @override
  String get failedToLoadRound => 'Failed to load round';

  @override
  String storytellerLabel(String name) {
    return 'Storyteller: $name';
  }

  @override
  String get edited => 'Edited';

  @override
  String get votedFor => 'voted for';

  @override
  String get unknown => 'Unknown';

  @override
  String get undoLastRoundConfirmation =>
      'This will delete the most recent round and revert all score changes from that round. This action cannot be undone.';

  @override
  String get undo => 'Undo';

  @override
  String get failedToLoadHistory => 'Failed to load history';

  @override
  String get noPlayersFound => 'No players found';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String importWithWarnings(String warnings) {
    return 'Game imported with warnings: $warnings';
  }

  @override
  String get importSuccess => 'Game imported successfully!';

  @override
  String quickStartFailed(String error) {
    return 'Quick Start failed: $error';
  }

  @override
  String shareFailed(String error) {
    return 'Share failed: $error';
  }

  @override
  String get colorTheme => 'Color Theme';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get soundEffectsDescription => 'Play sounds for celebrations';

  @override
  String get supporterPackFeature => 'Supporter Pack feature';

  @override
  String get defaultTargetMode => 'Default Target Mode';

  @override
  String get score => 'Score';

  @override
  String get free => 'Free';

  @override
  String get playerSortOrder => 'Player Sort Order';

  @override
  String get seatOrder => 'Seat Order';

  @override
  String get scoreHighToLow => 'Score (High to Low)';

  @override
  String get scoreLowToHigh => 'Score (Low to High)';

  @override
  String get name => 'Name';

  @override
  String get playerPresets => 'Player Presets';

  @override
  String get saveAndManageGroups => 'Save and manage player groups';

  @override
  String get premiumThemesAndExtras => 'Premium themes & extras';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get romanian => 'Romanian';

  @override
  String get onboardingTitle1 => 'Track Your Stories';

  @override
  String get onboardingBody1 =>
      'The fastest way to score storytelling card games. No more pen and paper — just tap and play.';

  @override
  String get onboardingTitle2 => 'Score in 3 Taps';

  @override
  String get onboardingBody2 =>
      'Enter votes for each player with a single tap. The app calculates everything automatically.';

  @override
  String get onboardingTitle3 => 'Fully Offline';

  @override
  String get onboardingBody3 =>
      'No account needed. No internet required. Your games stay on your device, always.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get letsPlay => 'Let\'s Play!';

  @override
  String get noPresetsYetTitle => 'No presets yet';

  @override
  String get noPresetsYetDescription =>
      'Create a preset to quickly start games with your usual group.';

  @override
  String get playerPresetsLockedDescription =>
      'Save your favorite player groups for quick game setup. Unlock with the Supporter Pack.';

  @override
  String get unlockSupporterPack => 'Unlock Supporter Pack';

  @override
  String get newPreset => 'New Preset';

  @override
  String get create => 'Create';

  @override
  String get renamePreset => 'Rename Preset';

  @override
  String failedToCreatePreset(String error) {
    return 'Failed to create preset: $error';
  }

  @override
  String deletedPreset(String name) {
    return 'Deleted \"$name\"';
  }

  @override
  String get whatsIncluded => 'What\'s included';

  @override
  String get thankYouForSupport => 'Thank you for your support!';

  @override
  String get supporterPackDescription =>
      'A one-time purchase to unlock premium features and support the development of StoryScore.';

  @override
  String get supporterThankYouDescription =>
      'You have unlocked all supporter features. Your generosity helps keep StoryScore growing.';

  @override
  String oneTimePurchase(String price) {
    return '$price — one-time purchase';
  }

  @override
  String getSupporterPack(String price) {
    return 'Get Supporter Pack — $price';
  }

  @override
  String get loading => 'Loading…';

  @override
  String get supporterPackActive => 'Supporter Pack Active';

  @override
  String get allPremiumUnlocked => 'All premium features are unlocked.';

  @override
  String get clearPurchaseDebug => 'Clear Purchase (Debug)';

  @override
  String get advancedStats => 'Advanced Stats';

  @override
  String get advancedStatsDescription =>
      'Unlock leaderboards, player stats, win streaks, and head-to-head records with the Supporter Pack.';

  @override
  String get unlockWithSupporterPack => 'Unlock with Supporter Pack';

  @override
  String get noLeaderboardYet => 'No leaderboard yet';

  @override
  String get noLeaderboardDescription =>
      'Play at least 3 games with the same players to see stats here.';

  @override
  String get winRate => 'Win Rate';

  @override
  String get rankings => 'Rankings';

  @override
  String get noPlayersYet => 'No players yet';

  @override
  String get noPlayersYetDescription =>
      'Complete some games to see player stats.';

  @override
  String failedToLoadLeaderboard(String error) {
    return 'Failed to load leaderboard: $error';
  }

  @override
  String failedToLoadPlayers(String error) {
    return 'Failed to load players: $error';
  }

  @override
  String playerGamesStats(int games, int wins, int points) {
    return '$games games  |  $wins wins  |  $points pts';
  }

  @override
  String winsSlashGames(int wins, int games) {
    return '${wins}W / ${games}G';
  }

  @override
  String get scoreProgression => 'Score Progression';

  @override
  String playerNotVotedYet(String name) {
    return '$name has not voted yet';
  }

  @override
  String get startNewRound => 'Start new round';

  @override
  String get scoreRoundDisabledHint =>
      'Score round, disabled, all players must vote first';
}
