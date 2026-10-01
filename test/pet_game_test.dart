import 'package:flutter_test/flutter_test.dart';
import 'package:digital_pet/pet_game.dart';

void main() {
  group('Digital Pet game model', () {
    test('starts with correct initial values', () {
      final game = PetGame();

      expect(game.happiness, 50);
      expect(game.hunger, 50);
      expect(game.energy, 70);
      expect(game.status, GameStatus.playing);
    });

    test('feeding normally increases happiness', () {
      final game = PetGame(
        happiness: 50,
        hunger: 60,
      );

      game.feed();

      expect(game.hunger, 50);
      expect(game.happiness, 60);
      expect(game.energy, 75);
    });

    test('feeding uses resulting hunger value', () {
      final game = PetGame(
        happiness: 50,
        hunger: 35,
      );

      game.feed();

      // 35 - 10 = 25.
      expect(game.hunger, 25);

      // Resulting hunger is below 30,
      // therefore happiness decreases by 20.
      expect(game.happiness, 30);
    });

    test('hunger tick 95 to 100 does not hurt happiness', () {
      final game = PetGame(
        happiness: 50,
        hunger: 95,
      );

      game.hungerTick();

      expect(game.hunger, 100);
      expect(game.happiness, 50);
    });

    test('overflow tick at 100 reduces happiness by 20', () {
      final game = PetGame(
        happiness: 50,
        hunger: 100,
      );

      game.hungerTick();

      expect(game.hunger, 100);
      expect(game.happiness, 30);
    });

    test('loss happens at hunger 100 and happiness 10', () {
      final game = PetGame(
        happiness: 30,
        hunger: 100,
      );

      game.hungerTick();

      expect(game.happiness, 10);
      expect(game.hunger, 100);
      expect(game.status, GameStatus.lost);
    });

    test('does not lose when happiness remains above 10', () {
      final game = PetGame(
        happiness: 40,
        hunger: 100,
      );

      game.hungerTick();

      expect(game.happiness, 20);
      expect(game.status, GameStatus.playing);
    });

    test('exactly 80 happiness does not qualify for win', () {
      final game = PetGame(
        happiness: 80,
      );

      game.win();

      expect(game.status, GameStatus.playing);
    });

    test('happiness above 80 can qualify for win', () {
      final game = PetGame(
        happiness: 81,
      );

      game.win();

      expect(game.status, GameStatus.won);
    });

    test('meters remain between 0 and 100', () {
      final game = PetGame(
        happiness: 95,
        hunger: 95,
        energy: 95,
      );

      game.run();

      expect(
        game.happiness,
        inInclusiveRange(0, 100),
      );

      expect(
        game.hunger,
        inInclusiveRange(0, 100),
      );

      expect(
        game.energy,
        inInclusiveRange(0, 100),
      );
    });

    test('reset restores the initial game state', () {
      final game = PetGame(
        happiness: 100,
        hunger: 100,
        energy: 5,
        status: GameStatus.won,
      );

      game.reset();

      expect(game.happiness, 50);
      expect(game.hunger, 50);
      expect(game.energy, 70);
      expect(game.status, GameStatus.playing);
    });
  });
}