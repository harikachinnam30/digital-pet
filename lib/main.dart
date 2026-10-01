import 'dart:async';

import 'package:flutter/material.dart';

import 'pet_game.dart';

void main() {
  runApp(const DigitalPetApp());
}

class DigitalPetApp extends StatelessWidget {
  const DigitalPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Pet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        useMaterial3: true,
      ),
      home: const PetScreen(),
    );
  }
}

class PetScreen extends StatefulWidget {
  final Duration hungerInterval;
  final Duration winDuration;

  const PetScreen({
    super.key,
    this.hungerInterval = const Duration(seconds: 30),
    this.winDuration = const Duration(minutes: 3),
  });

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  final PetGame game = PetGame();

  String petName = 'Pip';

  final TextEditingController nameController =
      TextEditingController(text: 'Pip');

  Timer? hungerTimer;
  Timer? winTimer;

  bool winTimerRunning = false;

  @override
  void initState() {
    super.initState();
    startHungerTimer();
  }

  // --------------------------------------------------
  // MOOD
  // --------------------------------------------------

  String get mood {
    if (game.happiness > 70) {
      return 'Happy';
    } else if (game.happiness >= 30) {
      return 'Neutral';
    } else {
      return 'Unhappy';
    }
  }

  Color get moodColor {
    if (game.happiness > 70) {
      return Colors.green;
    } else if (game.happiness >= 30) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }

  IconData get moodIcon {
    if (game.happiness > 70) {
      return Icons.sentiment_very_satisfied;
    } else if (game.happiness >= 30) {
      return Icons.sentiment_neutral;
    } else {
      return Icons.sentiment_very_dissatisfied;
    }
  }

  // --------------------------------------------------
  // PET MESSAGE
  // --------------------------------------------------

  String get petMessage {
    if (game.status == GameStatus.won) {
      return '$petName is super happy! You won!';
    }

    if (game.status == GameStatus.lost) {
      return '$petName needs more care. Game over!';
    }

    if (game.hunger >= 90) {
      return "I'm really hungry!";
    }

    if (game.happiness < 30) {
      return 'Can we play?';
    }

    if (game.energy < 20) {
      return 'I need some rest!';
    }

    if (game.happiness > 80) {
      return "I'm very happy! Keep it above 80!";
    }

    if (game.happiness > 70) {
      return "I'm having so much fun!";
    }

    return "Hi, I'm $petName!";
  }

  // --------------------------------------------------
  // UPDATE NAME
  // --------------------------------------------------

  void updatePetName() {
    final newName = nameController.text.trim();

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a pet name.'),
        ),
      );
      return;
    }

    setState(() {
      petName = newName;
    });

    FocusScope.of(context).unfocus();
  }

  // --------------------------------------------------
  // AUTOMATIC HUNGER TIMER
  // --------------------------------------------------

  void startHungerTimer() {
    // Cancel first so Reset can never create duplicate timers.
    hungerTimer?.cancel();

    hungerTimer = Timer.periodic(
      widget.hungerInterval,
      (_) {
        if (!mounted || game.isFinished) {
          return;
        }

        setState(() {
          game.hungerTick();
        });

        afterStateChange();
      },
    );
  }

  // --------------------------------------------------
  // FEED
  // --------------------------------------------------

  void feedPet() {
    if (game.isFinished) return;

    setState(() {
      game.feed();
    });

    afterStateChange();
  }

  // --------------------------------------------------
  // PLAY
  // --------------------------------------------------

  void playWithPet() {
    if (game.isFinished) return;

    final success = game.play();

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$petName is too tired to play. Let them rest!',
          ),
        ),
      );
      return;
    }

    setState(() {});

    afterStateChange();
  }

  // --------------------------------------------------
  // RUN
  // --------------------------------------------------

  void runWithPet() {
    if (game.isFinished) return;

    final success = game.run();

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$petName does not have enough energy to run.',
          ),
        ),
      );
      return;
    }

    setState(() {});

    afterStateChange();
  }

  // --------------------------------------------------
  // REST
  // --------------------------------------------------

  void restPet() {
    if (game.isFinished) return;

    setState(() {
      game.rest();
    });

    afterStateChange();
  }

  // --------------------------------------------------
  // SLEEP
  // --------------------------------------------------

  void sleepPet() {
    if (game.isFinished) return;

    setState(() {
      game.sleep();
    });

    afterStateChange();
  }

  // --------------------------------------------------
  // CHECK STATE AFTER EVERY CHANGE
  // --------------------------------------------------

  void afterStateChange() {
    if (!mounted) return;

    // Loss has priority.
    if (game.status == GameStatus.lost) {
      cancelWinTimer();
      hungerTimer?.cancel();

      if (mounted) {
        setState(() {});
      }

      return;
    }

    // Exactly 80 does NOT qualify.
    if (game.happiness > 80) {
      startWinTimerIfNeeded();
    } else {
      cancelWinTimer();
    }
  }

  // --------------------------------------------------
  // CONTINUOUS WIN TIMER
  // --------------------------------------------------

  void startWinTimerIfNeeded() {
    if (winTimerRunning || game.isFinished) {
      return;
    }

    setState(() {
      winTimerRunning = true;
    });

    winTimer = Timer(
      widget.winDuration,
      () {
        if (!mounted || game.isFinished) {
          return;
        }

        // Happiness must still be above 80 when
        // the continuous timer completes.
        if (game.happiness > 80) {
          setState(() {
            game.win();
            winTimerRunning = false;
            winTimer = null;
          });

          hungerTimer?.cancel();
        } else {
          setState(() {
            winTimerRunning = false;
            winTimer = null;
          });
        }
      },
    );
  }

  void cancelWinTimer() {
    winTimer?.cancel();
    winTimer = null;

    if (winTimerRunning) {
      winTimerRunning = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  // --------------------------------------------------
  // RESET
  // --------------------------------------------------

  void resetPet() {
    hungerTimer?.cancel();
    winTimer?.cancel();

    hungerTimer = null;
    winTimer = null;
    winTimerRunning = false;

    setState(() {
      game.reset();

      petName = 'Pip';
      nameController.text = 'Pip';
    });

    // Start exactly one new hunger timer.
    startHungerTimer();

    FocusScope.of(context).unfocus();
  }

  // --------------------------------------------------
  // DISPOSE
  // --------------------------------------------------

  @override
  void dispose() {
    hungerTimer?.cancel();
    winTimer?.cancel();
    nameController.dispose();

    super.dispose();
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.of(context).disableAnimations;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Digital Pet',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 5),

              // PET NAME
              Text(
                petName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // NAME INPUT
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nameController,
                      enabled: !game.isFinished,
                      decoration: const InputDecoration(
                        labelText: 'Pet name',
                        hintText: 'Enter a name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pets),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: game.isFinished
                        ? null
                        : updatePetName,
                    child: const Text('Confirm'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // MOOD TEXT + ICON
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    moodIcon,
                    color: moodColor,
                    size: 30,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mood,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: moodColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // PET IMAGE
              Semantics(
                label: '$petName is $mood',
                child: AnimatedScale(
                  scale:
                      game.happiness > 70 ? 1.08 : 1.0,
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(
                          milliseconds: 400,
                        ),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      moodColor,
                      BlendMode.modulate,
                    ),
                    child: Image.asset(
                      'assets/pet.png',
                      height: 180,
                      width: 180,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // PET MESSAGE
              AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(
                        milliseconds: 300,
                      ),
                child: Container(
                  key: ValueKey(petMessage),
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: moodColor.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: Text(
                    petMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // WIN TIMER MESSAGE
              if (winTimerRunning &&
                  game.status == GameStatus.playing)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Happiness is above 80! Keep it there for 3 minutes to win.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              const SizedBox(height: 15),

              // METERS
              buildMeter(
                label: 'Happiness',
                value: game.happiness,
                icon: Icons.favorite,
                reduceMotion: reduceMotion,
              ),

              buildMeter(
                label: 'Hunger',
                value: game.hunger,
                icon: Icons.restaurant,
                reduceMotion: reduceMotion,
              ),

              buildMeter(
                label: 'Energy',
                value: game.energy,
                icon: Icons.bolt,
                reduceMotion: reduceMotion,
              ),

              const SizedBox(height: 20),

              // CARE ACTIONS
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: game.isFinished
                        ? null
                        : playWithPet,
                    icon: const Icon(
                      Icons.sports_tennis,
                    ),
                    label: const Text('Play'),
                  ),
                  ElevatedButton.icon(
                    onPressed:
                        game.isFinished ? null : feedPet,
                    icon: const Icon(
                      Icons.restaurant,
                    ),
                    label: const Text('Feed'),
                  ),
                  ElevatedButton.icon(
                    onPressed:
                        game.isFinished ? null : restPet,
                    icon: const Icon(
                      Icons.bedtime,
                    ),
                    label: const Text('Rest'),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ACTIVITY SELECTION
              const Text(
                'Activities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed:
                        game.isFinished ? null : runWithPet,
                    icon: const Icon(
                      Icons.directions_run,
                    ),
                    label: const Text('Run'),
                  ),
                  ElevatedButton.icon(
                    onPressed: game.isFinished
                        ? null
                        : sleepPet,
                    icon: const Icon(
                      Icons.nightlight,
                    ),
                    label: const Text('Sleep'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // WIN RESULT
              if (game.status == GameStatus.won)
                gameResultCard(
                  icon: Icons.emoji_events,
                  title: 'YOU WON!',
                  message:
                      '$petName stayed happy for 3 continuous minutes.',
                ),

              // LOSS RESULT
              if (game.status == GameStatus.lost)
                gameResultCard(
                  icon: Icons.sentiment_dissatisfied,
                  title: 'GAME OVER',
                  message:
                      '$petName reached 100 hunger with very low happiness.',
                ),

              const SizedBox(height: 15),

              // RESET / RESTART
              OutlinedButton.icon(
                onPressed: resetPet,
                icon: const Icon(Icons.refresh),
                label: Text(
                  game.isFinished
                      ? 'Restart Game'
                      : 'Reset',
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Tip: Hunger automatically increases every 30 seconds.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // METER WIDGET
  // --------------------------------------------------

  Widget buildMeter({
    required String label,
    required int value,
    required IconData icon,
    required bool reduceMotion,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$value / 100',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0,
              end: value / 100,
            ),
            duration: reduceMotion
                ? Duration.zero
                : const Duration(
                    milliseconds: 350,
                  ),
            builder: (
              context,
              animatedValue,
              child,
            ) {
              return LinearProgressIndicator(
                value: animatedValue,
                minHeight: 12,
                borderRadius:
                    BorderRadius.circular(10),
              );
            },
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // RESULT CARD
  // --------------------------------------------------

  Widget gameResultCard({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(
              icon,
              size: 45,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}