import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ro.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ro'),
  ];

  /// App title shown in app bar and about section
  ///
  /// In en, this message translates to:
  /// **'StoryScore'**
  String get appTitle;

  /// Button/label to create a new game
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// Settings screen title and tooltip
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Button to start a new game
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  /// Button to submit and score the current round
  ///
  /// In en, this message translates to:
  /// **'Score Round'**
  String get scoreRound;

  /// Menu item to end game
  ///
  /// In en, this message translates to:
  /// **'End Game'**
  String get endGame;

  /// Button to end game immediately
  ///
  /// In en, this message translates to:
  /// **'End Game Now'**
  String get endGameNow;

  /// Button to continue playing after target reached
  ///
  /// In en, this message translates to:
  /// **'Continue Playing'**
  String get continuePlaying;

  /// FAB label for starting a new round
  ///
  /// In en, this message translates to:
  /// **'New Round'**
  String get newRound;

  /// No description provided for @round.
  ///
  /// In en, this message translates to:
  /// **'Round {number}'**
  String round(int number);

  /// No description provided for @playerIsStoryteller.
  ///
  /// In en, this message translates to:
  /// **'{name} is the Storyteller'**
  String playerIsStoryteller(String name);

  /// No description provided for @playerIsStorytelling.
  ///
  /// In en, this message translates to:
  /// **'{name} is storytelling'**
  String playerIsStorytelling(String name);

  /// Instruction on round screen
  ///
  /// In en, this message translates to:
  /// **'Who did each player vote for?'**
  String get whoDidEachPlayerVoteFor;

  /// Message when not all votes are cast
  ///
  /// In en, this message translates to:
  /// **'All players must vote'**
  String get allPlayersMustVote;

  /// Button to add a player
  ///
  /// In en, this message translates to:
  /// **'Add Player'**
  String get addPlayer;

  /// Hint text for player name field
  ///
  /// In en, this message translates to:
  /// **'Player name'**
  String get playerName;

  /// Label for color picker
  ///
  /// In en, this message translates to:
  /// **'Pick a color'**
  String get selectColor;

  /// Label for game title field
  ///
  /// In en, this message translates to:
  /// **'Game Title'**
  String get gameTitle;

  /// Hint text for game title field
  ///
  /// In en, this message translates to:
  /// **'e.g. Friday Game Night'**
  String get gameTitleHint;

  /// Label for target score field
  ///
  /// In en, this message translates to:
  /// **'Target Score'**
  String get targetScore;

  /// Label for infinite/freeplay mode
  ///
  /// In en, this message translates to:
  /// **'Infinite'**
  String get infinite;

  /// Toggle label for continuing past target score
  ///
  /// In en, this message translates to:
  /// **'Continue Past Target'**
  String get continuePastTarget;

  /// Description for continue past target toggle
  ///
  /// In en, this message translates to:
  /// **'Keep playing after someone reaches the target'**
  String get continuePastTargetDescription;

  /// Headline when game ends in a tie
  ///
  /// In en, this message translates to:
  /// **'It\'s a Tie!'**
  String get itsATie;

  /// Headline when there is a single winner
  ///
  /// In en, this message translates to:
  /// **'Winner!'**
  String get winner;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'{count} points'**
  String points(int count);

  /// Section title on endgame screen
  ///
  /// In en, this message translates to:
  /// **'Final Standings'**
  String get finalStandings;

  /// Button to return to home screen
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// Button to share game results
  ///
  /// In en, this message translates to:
  /// **'Share Results'**
  String get shareResults;

  /// Section header for active games
  ///
  /// In en, this message translates to:
  /// **'Active Games'**
  String get activeGames;

  /// Section header for completed games
  ///
  /// In en, this message translates to:
  /// **'Completed Games'**
  String get completedGames;

  /// Empty state title when no games exist
  ///
  /// In en, this message translates to:
  /// **'No games yet'**
  String get noGamesYet;

  /// Empty state action button
  ///
  /// In en, this message translates to:
  /// **'Start your first game'**
  String get startYourFirstGame;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Start your first game and begin tracking scores for your storytelling card game.'**
  String get startYourFirstGameDescription;

  /// Button to undo the last round
  ///
  /// In en, this message translates to:
  /// **'Undo Last Round'**
  String get undoLastRound;

  /// Button to delete a round
  ///
  /// In en, this message translates to:
  /// **'Delete Round'**
  String get deleteRound;

  /// Button to edit a round
  ///
  /// In en, this message translates to:
  /// **'Edit Round'**
  String get editRound;

  /// Menu item for exporting game
  ///
  /// In en, this message translates to:
  /// **'Export Game'**
  String get exportGame;

  /// Option to export as JSON
  ///
  /// In en, this message translates to:
  /// **'Export as JSON'**
  String get exportAsJson;

  /// JSON export description
  ///
  /// In en, this message translates to:
  /// **'Full game data, can be re-imported'**
  String get exportAsJsonDescription;

  /// Option to export as CSV
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get exportAsCsv;

  /// CSV export description
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet-friendly format'**
  String get exportAsCsvDescription;

  /// Button to import a game
  ///
  /// In en, this message translates to:
  /// **'Import Game'**
  String get importGame;

  /// Premium feature name
  ///
  /// In en, this message translates to:
  /// **'Supporter Pack'**
  String get supporterPack;

  /// Button to restore purchases
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// Theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// System theme mode label
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Light theme mode label
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme mode label
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Haptic feedback setting label
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// Haptic feedback description
  ///
  /// In en, this message translates to:
  /// **'Vibrate on score events'**
  String get hapticFeedbackDescription;

  /// Reduce motion setting label
  ///
  /// In en, this message translates to:
  /// **'Reduce Motion'**
  String get reduceMotion;

  /// Reduce motion description
  ///
  /// In en, this message translates to:
  /// **'Minimize animations'**
  String get reduceMotionDescription;

  /// Show round notes setting label
  ///
  /// In en, this message translates to:
  /// **'Show Round Notes'**
  String get roundNotes;

  /// Show round notes description
  ///
  /// In en, this message translates to:
  /// **'Allow clue notes per round'**
  String get roundNotesDescription;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Discard button label
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// Title for discard votes confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Discard votes?'**
  String get discardVotes;

  /// Body text for discard votes confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'You have votes in progress. Going back will discard them.'**
  String get discardVotesConfirmation;

  /// Confirm button label
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Generic error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Label when storyteller gave a good clue
  ///
  /// In en, this message translates to:
  /// **'Good clue'**
  String get goodClue;

  /// Label when storyteller gave a bad clue
  ///
  /// In en, this message translates to:
  /// **'Bad clue'**
  String get badClue;

  /// Score reason label
  ///
  /// In en, this message translates to:
  /// **'Correct guess'**
  String get correctGuess;

  /// Score reason label
  ///
  /// In en, this message translates to:
  /// **'Fooled opponent'**
  String get fooledBonus;

  /// No description provided for @reachedTarget.
  ///
  /// In en, this message translates to:
  /// **'{name} reached {target} points!'**
  String reachedTarget(String name, int target);

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Gameplay'**
  String get gameplay;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// Tab label and screen title
  ///
  /// In en, this message translates to:
  /// **'Scoreboard'**
  String get scoreboard;

  /// Tab label for round tab
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get roundTab;

  /// Tab label and screen title
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// History screen title
  ///
  /// In en, this message translates to:
  /// **'Round History'**
  String get roundHistory;

  /// Empty state title when no rounds exist
  ///
  /// In en, this message translates to:
  /// **'No rounds yet'**
  String get noRoundsYet;

  /// Empty state description for rounds
  ///
  /// In en, this message translates to:
  /// **'Complete your first round and it will appear here.'**
  String get noRoundsYetDescription;

  /// Stats screen title and tooltip
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// Leaderboard tab label
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// Players tab label and section header
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// Endgame screen app bar title
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// Label for win condition selector
  ///
  /// In en, this message translates to:
  /// **'Win Condition'**
  String get winCondition;

  /// Score target win condition label
  ///
  /// In en, this message translates to:
  /// **'Score Target'**
  String get scoreTarget;

  /// Round limit win condition label
  ///
  /// In en, this message translates to:
  /// **'Round Limit'**
  String get roundLimit;

  /// Free play win condition label
  ///
  /// In en, this message translates to:
  /// **'Free Play'**
  String get freePlay;

  /// Warning when fewer than 3 players
  ///
  /// In en, this message translates to:
  /// **'Min 3 required'**
  String get minPlayersRequired;

  /// No description provided for @playerCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count}/10'**
  String playerCountLabel(int count);

  /// Quick start button label
  ///
  /// In en, this message translates to:
  /// **'Quick Start'**
  String get quickStart;

  /// Quick start sheet description
  ///
  /// In en, this message translates to:
  /// **'Pick a preset to start a game instantly.'**
  String get quickStartDescription;

  /// Button to load a player preset
  ///
  /// In en, this message translates to:
  /// **'Load Preset'**
  String get loadPreset;

  /// Button to save current players as preset
  ///
  /// In en, this message translates to:
  /// **'Save as Preset'**
  String get saveAsPreset;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Hint text for preset name field
  ///
  /// In en, this message translates to:
  /// **'Preset name'**
  String get presetName;

  /// No description provided for @savedPreset.
  ///
  /// In en, this message translates to:
  /// **'Saved preset \"{name}\"'**
  String savedPreset(String name);

  /// No description provided for @failedToSavePreset.
  ///
  /// In en, this message translates to:
  /// **'Failed to save preset: {error}'**
  String failedToSavePreset(String error);

  /// No description provided for @failedToCreateGame.
  ///
  /// In en, this message translates to:
  /// **'Failed to create game: {error}'**
  String failedToCreateGame(String error);

  /// Empty state in load preset sheet
  ///
  /// In en, this message translates to:
  /// **'No presets saved yet.'**
  String get noPresetsYet;

  /// Label for color picker in add player sheet
  ///
  /// In en, this message translates to:
  /// **'Choose Color'**
  String get chooseColor;

  /// Label for avatar style selector
  ///
  /// In en, this message translates to:
  /// **'Avatar Style'**
  String get avatarStyle;

  /// Avatar style option for initials
  ///
  /// In en, this message translates to:
  /// **'Initials'**
  String get initials;

  /// Avatar style option for emoji
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get emoji;

  /// Add button label
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Premium upsell for emoji packs
  ///
  /// In en, this message translates to:
  /// **'3 bonus emoji packs with Supporter Pack'**
  String get bonusEmojiPacks;

  /// Tooltip for sort by score button
  ///
  /// In en, this message translates to:
  /// **'Sort by score'**
  String get sortByScore;

  /// Tooltip for sort by seat button
  ///
  /// In en, this message translates to:
  /// **'Sort by seat'**
  String get sortBySeat;

  /// Error message when session fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load session'**
  String get failedToLoadSession;

  /// Message when session is not found
  ///
  /// In en, this message translates to:
  /// **'Session not found'**
  String get sessionNotFound;

  /// Message when no players exist
  ///
  /// In en, this message translates to:
  /// **'No players in this session'**
  String get noPlayersInSession;

  /// No description provided for @errorLoadingPlayers.
  ///
  /// In en, this message translates to:
  /// **'Error loading players: {error}'**
  String errorLoadingPlayers(String error);

  /// Title for storyteller picker sheet
  ///
  /// In en, this message translates to:
  /// **'Choose Storyteller'**
  String get chooseStoryteller;

  /// Title for end game confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'End Game?'**
  String get endGameQuestion;

  /// No description provided for @endGameConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will mark the game as completed after {count} round{count, plural, =1{} other{s}}.'**
  String endGameConfirmation(int count);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @adjustScore.
  ///
  /// In en, this message translates to:
  /// **'Adjust {name}\'s Score'**
  String adjustScore(String name);

  /// No description provided for @currentScore.
  ///
  /// In en, this message translates to:
  /// **'Current: {score}'**
  String currentScore(int score);

  /// No description provided for @newScore.
  ///
  /// In en, this message translates to:
  /// **'New score: {score}'**
  String newScore(int score);

  /// Apply button label
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Message when no storyteller is assigned
  ///
  /// In en, this message translates to:
  /// **'No storyteller assigned'**
  String get noStorytellerAssigned;

  /// Hint text for round note field
  ///
  /// In en, this message translates to:
  /// **'Round note (optional)'**
  String get roundNoteHint;

  /// No description provided for @errorScoringRound.
  ///
  /// In en, this message translates to:
  /// **'Error scoring round: {error}'**
  String errorScoringRound(String error);

  /// Round detail screen title
  ///
  /// In en, this message translates to:
  /// **'Round Detail'**
  String get roundDetail;

  /// Message when round is not found
  ///
  /// In en, this message translates to:
  /// **'Round not found'**
  String get roundNotFound;

  /// Section title for votes
  ///
  /// In en, this message translates to:
  /// **'Votes'**
  String get votes;

  /// Section title for score changes
  ///
  /// In en, this message translates to:
  /// **'Score Changes'**
  String get scoreChanges;

  /// Section title for editing votes
  ///
  /// In en, this message translates to:
  /// **'Edit Votes'**
  String get editVotes;

  /// Button to save edited changes
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @failedToSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Failed to save changes: {error}'**
  String failedToSaveChanges(String error);

  /// Confirmation message for deleting a round
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this round and revert all score changes. This action cannot be undone.'**
  String get deleteRoundConfirmation;

  /// No description provided for @failedToDeleteRound.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete round: {error}'**
  String failedToDeleteRound(String error);

  /// Error message when round fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load round'**
  String get failedToLoadRound;

  /// No description provided for @storytellerLabel.
  ///
  /// In en, this message translates to:
  /// **'Storyteller: {name}'**
  String storytellerLabel(String name);

  /// Tooltip for edited indicator
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get edited;

  /// Text between voter name and votee name
  ///
  /// In en, this message translates to:
  /// **'voted for'**
  String get votedFor;

  /// Fallback name for unknown player
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Confirmation message for undoing last round
  ///
  /// In en, this message translates to:
  /// **'This will delete the most recent round and revert all score changes from that round. This action cannot be undone.'**
  String get undoLastRoundConfirmation;

  /// Undo button label
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Error message when history fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load history'**
  String get failedToLoadHistory;

  /// Message when no players found in endgame
  ///
  /// In en, this message translates to:
  /// **'No players found'**
  String get noPlayersFound;

  /// Generic error title
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(String error);

  /// No description provided for @importWithWarnings.
  ///
  /// In en, this message translates to:
  /// **'Game imported with warnings: {warnings}'**
  String importWithWarnings(String warnings);

  /// Success message after importing a game
  ///
  /// In en, this message translates to:
  /// **'Game imported successfully!'**
  String get importSuccess;

  /// No description provided for @quickStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Quick Start failed: {error}'**
  String quickStartFailed(String error);

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Share failed: {error}'**
  String shareFailed(String error);

  /// Label for color theme picker
  ///
  /// In en, this message translates to:
  /// **'Color Theme'**
  String get colorTheme;

  /// Sound effects setting label
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// Sound effects description for supporters
  ///
  /// In en, this message translates to:
  /// **'Play sounds for celebrations'**
  String get soundEffectsDescription;

  /// Sound effects description for non-supporters
  ///
  /// In en, this message translates to:
  /// **'Supporter Pack feature'**
  String get supporterPackFeature;

  /// Setting label for default target mode
  ///
  /// In en, this message translates to:
  /// **'Default Target Mode'**
  String get defaultTargetMode;

  /// Score target type label for segmented button
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// Free play target type label for segmented button
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// Setting label for player sort order
  ///
  /// In en, this message translates to:
  /// **'Player Sort Order'**
  String get playerSortOrder;

  /// Sort order option
  ///
  /// In en, this message translates to:
  /// **'Seat Order'**
  String get seatOrder;

  /// Sort order option
  ///
  /// In en, this message translates to:
  /// **'Score (High to Low)'**
  String get scoreHighToLow;

  /// Sort order option
  ///
  /// In en, this message translates to:
  /// **'Score (Low to High)'**
  String get scoreLowToHigh;

  /// Sort order option for alphabetical
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Section header and screen title
  ///
  /// In en, this message translates to:
  /// **'Player Presets'**
  String get playerPresets;

  /// Subtitle for player presets tile
  ///
  /// In en, this message translates to:
  /// **'Save and manage player groups'**
  String get saveAndManageGroups;

  /// Subtitle for supporter pack tile
  ///
  /// In en, this message translates to:
  /// **'Premium themes & extras'**
  String get premiumThemesAndExtras;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Romanian language name
  ///
  /// In en, this message translates to:
  /// **'Romanian'**
  String get romanian;

  /// Onboarding page 1 title
  ///
  /// In en, this message translates to:
  /// **'Track Your Stories'**
  String get onboardingTitle1;

  /// Onboarding page 1 body
  ///
  /// In en, this message translates to:
  /// **'The fastest way to score storytelling card games. No more pen and paper — just tap and play.'**
  String get onboardingBody1;

  /// Onboarding page 2 title
  ///
  /// In en, this message translates to:
  /// **'Score in 3 Taps'**
  String get onboardingTitle2;

  /// Onboarding page 2 body
  ///
  /// In en, this message translates to:
  /// **'Enter votes for each player with a single tap. The app calculates everything automatically.'**
  String get onboardingBody2;

  /// Onboarding page 3 title
  ///
  /// In en, this message translates to:
  /// **'Fully Offline'**
  String get onboardingTitle3;

  /// Onboarding page 3 body
  ///
  /// In en, this message translates to:
  /// **'No account needed. No internet required. Your games stay on your device, always.'**
  String get onboardingBody3;

  /// Skip button on onboarding
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Next button on onboarding
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Final onboarding button
  ///
  /// In en, this message translates to:
  /// **'Let\'s Play!'**
  String get letsPlay;

  /// Empty state title for presets
  ///
  /// In en, this message translates to:
  /// **'No presets yet'**
  String get noPresetsYetTitle;

  /// Empty state description for presets
  ///
  /// In en, this message translates to:
  /// **'Create a preset to quickly start games with your usual group.'**
  String get noPresetsYetDescription;

  /// Description when presets are locked
  ///
  /// In en, this message translates to:
  /// **'Save your favorite player groups for quick game setup. Unlock with the Supporter Pack.'**
  String get playerPresetsLockedDescription;

  /// CTA button for supporter pack
  ///
  /// In en, this message translates to:
  /// **'Unlock Supporter Pack'**
  String get unlockSupporterPack;

  /// Dialog title for creating a preset
  ///
  /// In en, this message translates to:
  /// **'New Preset'**
  String get newPreset;

  /// Create button label
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Dialog title for renaming a preset
  ///
  /// In en, this message translates to:
  /// **'Rename Preset'**
  String get renamePreset;

  /// No description provided for @failedToCreatePreset.
  ///
  /// In en, this message translates to:
  /// **'Failed to create preset: {error}'**
  String failedToCreatePreset(String error);

  /// No description provided for @deletedPreset.
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{name}\"'**
  String deletedPreset(String name);

  /// Section title on premium screen
  ///
  /// In en, this message translates to:
  /// **'What\'s included'**
  String get whatsIncluded;

  /// Title for existing supporters
  ///
  /// In en, this message translates to:
  /// **'Thank you for your support!'**
  String get thankYouForSupport;

  /// Description for non-supporters
  ///
  /// In en, this message translates to:
  /// **'A one-time purchase to unlock premium features and support the development of StoryScore.'**
  String get supporterPackDescription;

  /// Description for existing supporters
  ///
  /// In en, this message translates to:
  /// **'You have unlocked all supporter features. Your generosity helps keep StoryScore growing.'**
  String get supporterThankYouDescription;

  /// No description provided for @oneTimePurchase.
  ///
  /// In en, this message translates to:
  /// **'{price} — one-time purchase'**
  String oneTimePurchase(String price);

  /// No description provided for @getSupporterPack.
  ///
  /// In en, this message translates to:
  /// **'Get Supporter Pack — {price}'**
  String getSupporterPack(String price);

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// Banner title for active supporters
  ///
  /// In en, this message translates to:
  /// **'Supporter Pack Active'**
  String get supporterPackActive;

  /// Banner description for active supporters
  ///
  /// In en, this message translates to:
  /// **'All premium features are unlocked.'**
  String get allPremiumUnlocked;

  /// Debug button to clear purchase
  ///
  /// In en, this message translates to:
  /// **'Clear Purchase (Debug)'**
  String get clearPurchaseDebug;

  /// Title for premium stats gate
  ///
  /// In en, this message translates to:
  /// **'Advanced Stats'**
  String get advancedStats;

  /// Description for premium stats gate
  ///
  /// In en, this message translates to:
  /// **'Unlock leaderboards, player stats, win streaks, and head-to-head records with the Supporter Pack.'**
  String get advancedStatsDescription;

  /// CTA on premium gate overlay
  ///
  /// In en, this message translates to:
  /// **'Unlock with Supporter Pack'**
  String get unlockWithSupporterPack;

  /// Empty state title for leaderboard
  ///
  /// In en, this message translates to:
  /// **'No leaderboard yet'**
  String get noLeaderboardYet;

  /// Empty state description for leaderboard
  ///
  /// In en, this message translates to:
  /// **'Play at least 3 games with the same players to see stats here.'**
  String get noLeaderboardDescription;

  /// Win rate chart title
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get winRate;

  /// Rankings section title
  ///
  /// In en, this message translates to:
  /// **'Rankings'**
  String get rankings;

  /// Empty state title for players tab
  ///
  /// In en, this message translates to:
  /// **'No players yet'**
  String get noPlayersYet;

  /// Empty state description for players tab
  ///
  /// In en, this message translates to:
  /// **'Complete some games to see player stats.'**
  String get noPlayersYetDescription;

  /// No description provided for @failedToLoadLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Failed to load leaderboard: {error}'**
  String failedToLoadLeaderboard(String error);

  /// No description provided for @failedToLoadPlayers.
  ///
  /// In en, this message translates to:
  /// **'Failed to load players: {error}'**
  String failedToLoadPlayers(String error);

  /// No description provided for @playerGamesStats.
  ///
  /// In en, this message translates to:
  /// **'{games} games  |  {wins} wins  |  {points} pts'**
  String playerGamesStats(int games, int wins, int points);

  /// No description provided for @winsSlashGames.
  ///
  /// In en, this message translates to:
  /// **'{wins}W / {games}G'**
  String winsSlashGames(int wins, int games);

  /// Chart title on endgame screen
  ///
  /// In en, this message translates to:
  /// **'Score Progression'**
  String get scoreProgression;

  /// No description provided for @playerNotVotedYet.
  ///
  /// In en, this message translates to:
  /// **'{name} has not voted yet'**
  String playerNotVotedYet(String name);

  /// Accessibility label for new round FAB
  ///
  /// In en, this message translates to:
  /// **'Start new round'**
  String get startNewRound;

  /// Accessibility label for disabled score round button
  ///
  /// In en, this message translates to:
  /// **'Score round, disabled, all players must vote first'**
  String get scoreRoundDisabledHint;

  /// Bottom sheet header for theme mode picker
  ///
  /// In en, this message translates to:
  /// **'CHOOSE THEME'**
  String get chooseTheme;

  /// Bottom sheet header for color theme picker
  ///
  /// In en, this message translates to:
  /// **'COLOR THEME'**
  String get colorThemeHeader;

  /// Bottom sheet header for language picker
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get languageHeader;

  /// System theme mode option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// Light theme mode option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// Dark theme mode option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// System theme description
  ///
  /// In en, this message translates to:
  /// **'Follow device settings'**
  String get followDeviceSettings;

  /// Light theme description
  ///
  /// In en, this message translates to:
  /// **'Warm parchment theme'**
  String get warmParchmentTheme;

  /// Dark theme description
  ///
  /// In en, this message translates to:
  /// **'Enchanted night theme'**
  String get enchantedNightTheme;

  /// System language description
  ///
  /// In en, this message translates to:
  /// **'Follow device language'**
  String get followDeviceLanguage;

  /// Default color theme name
  ///
  /// In en, this message translates to:
  /// **'Storybook Gold'**
  String get storybookGold;

  /// Default color theme description
  ///
  /// In en, this message translates to:
  /// **'Default warm enchanted theme'**
  String get storybookGoldDescription;

  /// Ocean color theme name
  ///
  /// In en, this message translates to:
  /// **'Ocean Depths'**
  String get oceanDepths;

  /// Ocean color theme description
  ///
  /// In en, this message translates to:
  /// **'Deep blue ocean theme'**
  String get oceanDepthsDescription;

  /// Ember color theme name
  ///
  /// In en, this message translates to:
  /// **'Ember'**
  String get emberTheme;

  /// Ember color theme description
  ///
  /// In en, this message translates to:
  /// **'Warm fire theme'**
  String get emberThemeDescription;

  /// Frost color theme name
  ///
  /// In en, this message translates to:
  /// **'Frost'**
  String get frostTheme;

  /// Frost color theme description
  ///
  /// In en, this message translates to:
  /// **'Cool ice theme'**
  String get frostThemeDescription;

  /// Forest color theme name
  ///
  /// In en, this message translates to:
  /// **'Enchanted Forest'**
  String get enchantedForest;

  /// Forest color theme description
  ///
  /// In en, this message translates to:
  /// **'Mystical green theme'**
  String get enchantedForestDescription;

  /// Settings row label for data export/import
  ///
  /// In en, this message translates to:
  /// **'Export / Import'**
  String get exportImport;

  /// Settings row trailing text for export/import
  ///
  /// In en, this message translates to:
  /// **'Manage data'**
  String get manageData;

  /// Supporter pack teaser text in settings
  ///
  /// In en, this message translates to:
  /// **'Unlock more magic'**
  String get unlockMoreMagic;

  /// Settings row label for privacy/support links
  ///
  /// In en, this message translates to:
  /// **'Privacy & Support'**
  String get privacyAndSupport;

  /// Settings row trailing text for privacy/support
  ///
  /// In en, this message translates to:
  /// **'View links'**
  String get viewLinks;

  /// Trailing text showing number of saved presets
  ///
  /// In en, this message translates to:
  /// **'{count} saved'**
  String nSaved(int count);

  /// Settings section header for data
  ///
  /// In en, this message translates to:
  /// **'DATA'**
  String get dataSection;

  /// Settings section header for premium
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get premiumSection;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ro'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ro':
      return AppLocalizationsRo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
