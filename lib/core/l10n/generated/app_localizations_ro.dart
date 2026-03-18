// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'StoryScore';

  @override
  String get newGame => 'Joc Nou';

  @override
  String get settings => 'Setări';

  @override
  String get startGame => 'Începe Jocul';

  @override
  String get scoreRound => 'Scor Rundă';

  @override
  String get endGame => 'Termină Jocul';

  @override
  String get endGameNow => 'Termină Acum';

  @override
  String get continuePlaying => 'Continuă Jocul';

  @override
  String get newRound => 'Rundă Nouă';

  @override
  String round(int number) {
    return 'Runda $number';
  }

  @override
  String playerIsStoryteller(String name) {
    return '$name este Povestitorul';
  }

  @override
  String playerIsStorytelling(String name) {
    return '$name povestește';
  }

  @override
  String get whoDidEachPlayerVoteFor => 'Pentru cine a votat fiecare jucător?';

  @override
  String get allPlayersMustVote => 'Toți jucătorii trebuie să voteze';

  @override
  String get addPlayer => 'Adaugă Jucător';

  @override
  String get playerName => 'Numele jucătorului';

  @override
  String get selectColor => 'Alege o culoare';

  @override
  String get gameTitle => 'Titlul Jocului';

  @override
  String get gameTitleHint => 'ex. Seara de Vineri';

  @override
  String get targetScore => 'Scor Țintă';

  @override
  String get infinite => 'Infinit';

  @override
  String get continuePastTarget => 'Continuă După Țintă';

  @override
  String get continuePastTargetDescription =>
      'Continuă jocul după ce cineva atinge ținta';

  @override
  String get itsATie => 'Egalitate!';

  @override
  String get winner => 'Câștigător!';

  @override
  String points(int count) {
    return '$count puncte';
  }

  @override
  String get finalStandings => 'Clasament Final';

  @override
  String get backToHome => 'Înapoi Acasă';

  @override
  String get shareResults => 'Distribuie Rezultatele';

  @override
  String get activeGames => 'Jocuri Active';

  @override
  String get completedGames => 'Jocuri Finalizate';

  @override
  String get noGamesYet => 'Niciun joc încă';

  @override
  String get startYourFirstGame => 'Începe primul joc';

  @override
  String get startYourFirstGameDescription =>
      'Începe primul joc și urmărește scorurile pentru jocul tău de cărți cu povești.';

  @override
  String get undoLastRound => 'Anulează Ultima Rundă';

  @override
  String get deleteRound => 'Șterge Runda';

  @override
  String get editRound => 'Editează Runda';

  @override
  String get exportGame => 'Exportă Jocul';

  @override
  String get exportAsJson => 'Exportă ca JSON';

  @override
  String get exportAsJsonDescription => 'Date complete, pot fi reimportate';

  @override
  String get exportAsCsv => 'Exportă ca CSV';

  @override
  String get exportAsCsvDescription => 'Format compatibil cu foi de calcul';

  @override
  String get importGame => 'Importă Joc';

  @override
  String get supporterPack => 'Pachet Susținător';

  @override
  String get restorePurchases => 'Restaurează Achizițiile';

  @override
  String get theme => 'Temă';

  @override
  String get system => 'Sistem';

  @override
  String get light => 'Luminos';

  @override
  String get dark => 'Întunecat';

  @override
  String get hapticFeedback => 'Vibrații';

  @override
  String get hapticFeedbackDescription => 'Vibrează la schimbarea scorului';

  @override
  String get reduceMotion => 'Reduce Mișcarea';

  @override
  String get reduceMotionDescription => 'Minimizează animațiile';

  @override
  String get roundNotes => 'Notițe de Rundă';

  @override
  String get roundNotesDescription => 'Permite notițe pentru fiecare rundă';

  @override
  String get cancel => 'Anulează';

  @override
  String get delete => 'Șterge';

  @override
  String get confirm => 'Confirmă';

  @override
  String get error => 'Eroare';

  @override
  String get goodClue => 'Indiciu bun';

  @override
  String get badClue => 'Indiciu slab';

  @override
  String get correctGuess => 'Ghicire corectă';

  @override
  String get fooledBonus => 'A păcălit adversarul';

  @override
  String reachedTarget(String name, int target) {
    return '$name a atins $target puncte!';
  }

  @override
  String get appearance => 'Aspect';

  @override
  String get gameplay => 'Joc';

  @override
  String get support => 'Suport';

  @override
  String get about => 'Despre';

  @override
  String version(String version) {
    return 'Versiunea $version';
  }

  @override
  String get scoreboard => 'Clasament';

  @override
  String get roundTab => 'Rundă';

  @override
  String get history => 'Istoric';

  @override
  String get roundHistory => 'Istoric Runde';

  @override
  String get noRoundsYet => 'Nicio rundă încă';

  @override
  String get noRoundsYetDescription =>
      'Finalizează prima rundă și va apărea aici.';

  @override
  String get stats => 'Statistici';

  @override
  String get leaderboard => 'Clasament General';

  @override
  String get players => 'Jucători';

  @override
  String get gameOver => 'Joc Terminat';

  @override
  String get winCondition => 'Condiție de Câștig';

  @override
  String get scoreTarget => 'Scor Țintă';

  @override
  String get roundLimit => 'Limită de Runde';

  @override
  String get freePlay => 'Joc Liber';

  @override
  String get minPlayersRequired => 'Minim 3 necesari';

  @override
  String playerCountLabel(int count) {
    return '$count/10';
  }

  @override
  String get quickStart => 'Start Rapid';

  @override
  String get quickStartDescription =>
      'Alege un șablon pentru a începe un joc instant.';

  @override
  String get loadPreset => 'Încarcă Șablon';

  @override
  String get saveAsPreset => 'Salvează ca Șablon';

  @override
  String get save => 'Salvează';

  @override
  String get presetName => 'Numele șablonului';

  @override
  String savedPreset(String name) {
    return 'Șablon salvat „$name”';
  }

  @override
  String failedToSavePreset(String error) {
    return 'Salvarea șablonului a eșuat: $error';
  }

  @override
  String failedToCreateGame(String error) {
    return 'Crearea jocului a eșuat: $error';
  }

  @override
  String get noPresetsYet => 'Niciun șablon salvat.';

  @override
  String get chooseColor => 'Alege Culoarea';

  @override
  String get avatarStyle => 'Stil Avatar';

  @override
  String get initials => 'Inițiale';

  @override
  String get emoji => 'Emoji';

  @override
  String get add => 'Adaugă';

  @override
  String get bonusEmojiPacks => '3 pachete emoji bonus cu Pachetul Susținător';

  @override
  String get sortByScore => 'Sortează după scor';

  @override
  String get sortBySeat => 'Sortează după loc';

  @override
  String get failedToLoadSession => 'Sesiunea nu a putut fi încărcată';

  @override
  String get sessionNotFound => 'Sesiunea nu a fost găsită';

  @override
  String get noPlayersInSession => 'Niciun jucător în această sesiune';

  @override
  String errorLoadingPlayers(String error) {
    return 'Eroare la încărcarea jucătorilor: $error';
  }

  @override
  String get chooseStoryteller => 'Alege Povestitorul';

  @override
  String get endGameQuestion => 'Termini jocul?';

  @override
  String endGameConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'runde',
      one: 'rundă',
    );
    return 'Jocul va fi marcat ca finalizat după $count $_temp0.';
  }

  @override
  String exportFailed(String error) {
    return 'Exportul a eșuat: $error';
  }

  @override
  String adjustScore(String name) {
    return 'Ajustează scorul lui $name';
  }

  @override
  String currentScore(int score) {
    return 'Actual: $score';
  }

  @override
  String newScore(int score) {
    return 'Scor nou: $score';
  }

  @override
  String get apply => 'Aplică';

  @override
  String get noStorytellerAssigned => 'Niciun povestitor desemnat';

  @override
  String get roundNoteHint => 'Notiță de rundă (opțional)';

  @override
  String errorScoringRound(String error) {
    return 'Eroare la calcularea scorului: $error';
  }

  @override
  String get roundDetail => 'Detalii Rundă';

  @override
  String get roundNotFound => 'Runda nu a fost găsită';

  @override
  String get votes => 'Voturi';

  @override
  String get scoreChanges => 'Modificări Scor';

  @override
  String get editVotes => 'Editează Voturile';

  @override
  String get saveChanges => 'Salvează Modificările';

  @override
  String failedToSaveChanges(String error) {
    return 'Salvarea a eșuat: $error';
  }

  @override
  String get deleteRoundConfirmation =>
      'Această rundă va fi ștearsă definitiv și toate modificările de scor vor fi anulate. Acțiunea nu poate fi anulată.';

  @override
  String failedToDeleteRound(String error) {
    return 'Ștergerea rundei a eșuat: $error';
  }

  @override
  String get failedToLoadRound => 'Runda nu a putut fi încărcată';

  @override
  String storytellerLabel(String name) {
    return 'Povestitor: $name';
  }

  @override
  String get edited => 'Editat';

  @override
  String get votedFor => 'a votat pentru';

  @override
  String get unknown => 'Necunoscut';

  @override
  String get undoLastRoundConfirmation =>
      'Ultima rundă va fi ștearsă și toate modificările de scor vor fi anulate. Acțiunea nu poate fi anulată.';

  @override
  String get undo => 'Anulează';

  @override
  String get failedToLoadHistory => 'Istoricul nu a putut fi încărcat';

  @override
  String get noPlayersFound => 'Niciun jucător găsit';

  @override
  String get somethingWentWrong => 'Ceva nu a funcționat';

  @override
  String importFailed(String error) {
    return 'Importul a eșuat: $error';
  }

  @override
  String importWithWarnings(String warnings) {
    return 'Joc importat cu avertismente: $warnings';
  }

  @override
  String get importSuccess => 'Jocul a fost importat cu succes!';

  @override
  String quickStartFailed(String error) {
    return 'Startul rapid a eșuat: $error';
  }

  @override
  String shareFailed(String error) {
    return 'Distribuirea a eșuat: $error';
  }

  @override
  String get colorTheme => 'Temă Culori';

  @override
  String get soundEffects => 'Efecte Sonore';

  @override
  String get soundEffectsDescription => 'Redă sunete la celebrări';

  @override
  String get supporterPackFeature => 'Funcție Pachet Susținător';

  @override
  String get defaultTargetMode => 'Mod Țintă Implicit';

  @override
  String get score => 'Scor';

  @override
  String get free => 'Liber';

  @override
  String get playerSortOrder => 'Ordinea Jucătorilor';

  @override
  String get seatOrder => 'Ordinea Locurilor';

  @override
  String get scoreHighToLow => 'Scor (Descrescător)';

  @override
  String get scoreLowToHigh => 'Scor (Crescător)';

  @override
  String get name => 'Nume';

  @override
  String get playerPresets => 'Șabloane Jucători';

  @override
  String get saveAndManageGroups =>
      'Salvează și gestionează grupuri de jucători';

  @override
  String get premiumThemesAndExtras => 'Teme premium și extra';

  @override
  String get language => 'Limbă';

  @override
  String get english => 'Engleză';

  @override
  String get romanian => 'Română';

  @override
  String get onboardingTitle1 => 'Urmărește Poveștile';

  @override
  String get onboardingBody1 =>
      'Cel mai rapid mod de a ține scorul la jocurile de cărți cu povești. Fără hârtie și pix — doar apasă și joacă.';

  @override
  String get onboardingTitle2 => 'Scor în 3 Apăsări';

  @override
  String get onboardingBody2 =>
      'Introdu voturile fiecărui jucător cu o singură apăsare. Aplicația calculează totul automat.';

  @override
  String get onboardingTitle3 => 'Complet Offline';

  @override
  String get onboardingBody3 =>
      'Nu ai nevoie de cont. Nu ai nevoie de internet. Jocurile tale rămân pe dispozitiv, mereu.';

  @override
  String get skip => 'Sari';

  @override
  String get next => 'Următorul';

  @override
  String get letsPlay => 'Hai la joc!';

  @override
  String get noPresetsYetTitle => 'Niciun șablon încă';

  @override
  String get noPresetsYetDescription =>
      'Creează un șablon pentru a începe rapid jocuri cu grupul tău obișnuit.';

  @override
  String get playerPresetsLockedDescription =>
      'Salvează grupurile tale preferate de jucători pentru configurare rapidă. Deblochează cu Pachetul Susținător.';

  @override
  String get unlockSupporterPack => 'Deblochează Pachetul Susținător';

  @override
  String get newPreset => 'Șablon Nou';

  @override
  String get create => 'Creează';

  @override
  String get renamePreset => 'Redenumește Șablon';

  @override
  String failedToCreatePreset(String error) {
    return 'Crearea șablonului a eșuat: $error';
  }

  @override
  String deletedPreset(String name) {
    return 'Șablonul „$name” a fost șters';
  }

  @override
  String get whatsIncluded => 'Ce include';

  @override
  String get thankYouForSupport => 'Mulțumim pentru susținere!';

  @override
  String get supporterPackDescription =>
      'O achiziție unică pentru a debloca funcții premium și a susține dezvoltarea StoryScore.';

  @override
  String get supporterThankYouDescription =>
      'Ai deblocat toate funcțiile de susținător. Generozitatea ta ajută StoryScore să crească.';

  @override
  String oneTimePurchase(String price) {
    return '$price — achiziție unică';
  }

  @override
  String getSupporterPack(String price) {
    return 'Pachet Susținător — $price';
  }

  @override
  String get loading => 'Se încarcă…';

  @override
  String get supporterPackActive => 'Pachet Susținător Activ';

  @override
  String get allPremiumUnlocked => 'Toate funcțiile premium sunt deblocate.';

  @override
  String get clearPurchaseDebug => 'Șterge Achiziția (Debug)';

  @override
  String get advancedStats => 'Statistici Avansate';

  @override
  String get advancedStatsDescription =>
      'Deblochează clasamente, statistici de jucători, serii de victorii și rezultate directe cu Pachetul Susținător.';

  @override
  String get unlockWithSupporterPack => 'Deblochează cu Pachetul Susținător';

  @override
  String get noLeaderboardYet => 'Niciun clasament încă';

  @override
  String get noLeaderboardDescription =>
      'Joacă cel puțin 3 jocuri cu aceiași jucători pentru a vedea statistici aici.';

  @override
  String get winRate => 'Rată Victorii';

  @override
  String get rankings => 'Clasament';

  @override
  String get noPlayersYet => 'Niciun jucător încă';

  @override
  String get noPlayersYetDescription =>
      'Finalizează câteva jocuri pentru a vedea statisticile jucătorilor.';

  @override
  String failedToLoadLeaderboard(String error) {
    return 'Clasamentul nu a putut fi încărcat: $error';
  }

  @override
  String failedToLoadPlayers(String error) {
    return 'Jucătorii nu au putut fi încărcați: $error';
  }

  @override
  String playerGamesStats(int games, int wins, int points) {
    return '$games jocuri  |  $wins victorii  |  $points pct';
  }

  @override
  String winsSlashGames(int wins, int games) {
    return '${wins}V / ${games}J';
  }

  @override
  String get scoreProgression => 'Progresul Scorului';

  @override
  String playerNotVotedYet(String name) {
    return '$name nu a votat încă';
  }

  @override
  String get startNewRound => 'Începe o rundă nouă';

  @override
  String get scoreRoundDisabledHint =>
      'Scor rundă, dezactivat, toți jucătorii trebuie să voteze mai întâi';
}
