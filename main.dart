import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:gapro/SpaceGame.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget(
          game: SpaceGame(),
          overlayBuilderMap: {
            'GameOver': (context, game) =>
                GameOverOverlay(game: game as SpaceGame),
            'MainMenu': (context, game) =>
                MainMenuOverlay(game: game as SpaceGame),
            'Shop': (context, game) => ShopOverlay(game: game as SpaceGame),
            'Quests': (context, game) => QuestsOverlay(game: game as SpaceGame),
            'HUD': (context, game) => HUDOverlay(game: game as SpaceGame),
            'PauseMenu': (context, game) =>
                PauseMenuOverlay(game: game as SpaceGame),
          },
        ),
      ),
    ),
  );
}

// ========================
//      Overlay Widgets
// ========================
class GameOverOverlay extends StatelessWidget {
  final SpaceGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.black87, Colors.black54],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('GAME OVER',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 48,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('Score: ${game.score}',
                style: const TextStyle(color: Colors.white, fontSize: 24)),
            Text('Coins: ${game.coinsCollected}',
                style: const TextStyle(color: Colors.yellow, fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: game.restartGame,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child:
                    const Text('Play Again', style: TextStyle(fontSize: 18))),
          ],
        ),
      ),
    );
  }
}

class MainMenuOverlay extends StatelessWidget {
  final SpaceGame game;
  const MainMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.blue[900]!, Colors.blue[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('SPACE ADVENTURE',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _buildButton('Start Game', Colors.green, game.startGame),
            _buildButton('Shop', Colors.orange, game.openShop),
            _buildButton('Quests', Colors.purple, game.openQuests),
            const SizedBox(height: 15),
            Text('Coins: ${game.totalCoins}',
                style: const TextStyle(color: Colors.yellow, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, Function() onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(backgroundColor: color),
          child: Text(text, style: const TextStyle(fontSize: 18))),
    );
  }
}

class ShopOverlay extends StatelessWidget {
  final SpaceGame game;
  const ShopOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.green[900]!, Colors.green[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('UPGRADES',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildUpgradeItem('Speed', game.upgrades['speed']!, 50,
                () => game.purchaseUpgrade('speed')),
            _buildUpgradeItem('Shield', game.upgrades['shield']!, 100,
                () => game.purchaseUpgrade('shield')),
            _buildUpgradeItem('Firepower', game.upgrades['firepower']!, 75,
                () => game.purchaseUpgrade('firepower')),
            const SizedBox(height: 20),
            Text('Coins: ${game.totalCoins}',
                style: const TextStyle(color: Colors.yellow, fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: game.returnToMainMenu,
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                child: const Text('Back', style: TextStyle(fontSize: 18))),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeItem(
      String name, int level, int cost, VoidCallback onUpgrade) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.black38, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$name (Lvl $level)',
              style: const TextStyle(color: Colors.white, fontSize: 18)),
          ElevatedButton(
              onPressed: game.totalCoins >= cost ? onUpgrade : null,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[800],
                  disabledBackgroundColor: Colors.grey),
              child: Text('Upgrade ($cost)',
                  style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}

class QuestsOverlay extends StatelessWidget {
  final SpaceGame game;
  const QuestsOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.orange[900]!, Colors.orange[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('QUESTS',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildQuestItem('Collect 10 Stars',
                game.questProgress['collectStars'] ?? 0, 10),
            _buildQuestItem('Avoid 20 Meteors',
                game.questProgress['avoidMeteors'] ?? 0, 20),
            const SizedBox(height: 20),
            Text('Completed: ${game.completedQuests.length}/2',
                style: const TextStyle(color: Colors.green, fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: game.returnToMainMenu,
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                child: const Text('Back', style: TextStyle(fontSize: 18))),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestItem(String name, int progress, int target) {
    bool completed = progress >= target;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.black38, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name,
                  style: TextStyle(
                      color: completed ? Colors.green : Colors.white,
                      fontSize: 18)),
              Text('$progress/$target',
                  style:
                      TextStyle(color: completed ? Colors.green : Colors.grey)),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            value: progress.clamp(0, target) / target,
            backgroundColor: Colors.grey[700],
            valueColor: AlwaysStoppedAnimation<Color>(
                completed ? Colors.green : Colors.blue),
          ),
        ],
      ),
    );
  }
}

class HUDOverlay extends StatelessWidget {
  final SpaceGame game;
  const HUDOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Score: ${game.score}',
                  style: const TextStyle(color: Colors.white, fontSize: 20)),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.yellow, size: 24),
                  const SizedBox(width: 5),
                  Text('${game.coinsCollected}',
                      style:
                          const TextStyle(color: Colors.yellow, fontSize: 20)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Level: ${game.level}',
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.speed,
                        color: game.fastMovementEnabled
                            ? Colors.green
                            : Colors.white),
                    onPressed: game.toggleFastMovement,
                    tooltip: 'Toggle Boost',
                  ),
                  IconButton(
                    icon: const Icon(Icons.pause, color: Colors.white),
                    onPressed: game.togglePause,
                    tooltip: 'Pause',
                  ),
                ],
              ),
            ],
          ),
          if (game.superPowerActive)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(5)),
              child: Text(
                  'BOOST ACTIVE: ${game.superPowerTimer.toStringAsFixed(1)}s',
                  style: const TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}

class PauseMenuOverlay extends StatelessWidget {
  final SpaceGame game;
  const PauseMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.grey[900]!, Colors.grey[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('PAUSED',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: game.togglePause,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Resume', style: TextStyle(fontSize: 18))),
            const SizedBox(height: 15),
            ElevatedButton(
                onPressed: game.returnToMainMenu,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Quit', style: TextStyle(fontSize: 18))),
          ],
        ),
      ),
    );
  }
}

// ========================
//      Core Game Logic
// ========================

// ========================
//      Game Components
// ========================
