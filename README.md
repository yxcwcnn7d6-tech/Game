# Dark Defense: Vampires vs Werewolves

A mobile-friendly tower defense game where you defend your castle against waves of vampires and werewolves!

## Game Overview

Similar to Kingdom Guard and Last Z, this is a tower defense game with a dark fantasy theme. Place towers strategically to stop hordes of supernatural creatures from reaching your castle.

## Features

- **4 Unique Tower Types:**
  - **Garlic Cannon** - Cheap and effective against vampires (2x damage bonus)
  - **Silver Bullets** - Powerful against werewolves (2.5x damage bonus)
  - **Holy Water** - Balanced damage against both enemy types (1.5x bonus to both)
  - **UV Tower** - Slows vampires and deals continuous damage

- **4 Enemy Types:**
  - **Vampire** - Fast but fragile, weak to garlic
  - **Werewolf** - Strong and tanky, weak to silver
  - **Vampire Lord** - Elite vampire with high health
  - **Alpha Werewolf** - Powerful werewolf boss

- **Progressive Difficulty:**
  - 10 waves of increasing difficulty
  - More enemies and stronger types appear in later waves
  - Strategic tower placement is key to survival

- **Resource Management:**
  - Earn gold by defeating enemies
  - Spend gold wisely on towers
  - Protect your castle (20 lives)

## How to Play

### Starting the Game

1. Open `index.html` in a web browser (Chrome, Firefox, Safari recommended)
2. Or run a local server:
   ```bash
   npm start
   # or
   python3 -m http.server 8000
   ```
3. Visit `http://localhost:8000` in your browser

### Controls

- **Desktop:** Click to select towers and place them
- **Mobile:** Tap to select towers and tap the grid to place them

### Gameplay Instructions

1. **Select a Tower** - Click/tap one of the tower buttons on the right side
2. **Place the Tower** - Click/tap on the game grid (avoid the dark gray path)
3. **Watch Towers Fight** - Towers automatically target and shoot enemies in range
4. **Earn Gold** - Defeat enemies to earn gold for more towers
5. **Survive Waves** - Defend your castle for 10 waves to win!

### Strategy Tips

- **Place towers at corners** where enemies slow down
- **Mix tower types** for balanced defense against both vampires and werewolves
- **Garlic Cannons** are cheap and great early game against vampires
- **Silver Bullet Towers** are essential for dealing with werewolves
- **UV Towers** are excellent for slowing vampire rushes
- **Holy Water** towers are versatile but expensive
- **Cover all paths** to ensure no enemy slips through
- **Save gold** for later waves when enemies get tougher

## Game Statistics

| Tower Type | Cost | Damage | Range | Fire Rate | Special Ability |
|------------|------|--------|-------|-----------|-----------------|
| Garlic Cannon | 50 | 15 | 120 | 1000ms | 2x vs Vampires |
| Silver Bullets | 75 | 20 | 150 | 800ms | 2.5x vs Werewolves |
| Holy Water | 100 | 25 | 100 | 1200ms | 1.5x vs Both |
| UV Tower | 120 | 10 | 140 | 500ms | Slows Vampires 50% |

| Enemy Type | Health | Speed | Reward | Damage |
|------------|--------|-------|--------|--------|
| Vampire | 50 | 80 | 15 gold | 2 lives |
| Werewolf | 100 | 60 | 25 gold | 3 lives |
| Vampire Lord | 150 | 70 | 50 gold | 4 lives |
| Alpha Werewolf | 200 | 55 | 60 gold | 5 lives |

## Technical Details

- **Framework:** Phaser 3 (v3.60.0)
- **Platform:** HTML5 (works on desktop and mobile browsers)
- **Resolution:** 800x600 (scales to fit screen)
- **No installation required** - just open in a browser!

## File Structure

```
Game/
├── index.html       # Main HTML file
├── game.js          # Game logic and scenes
├── package.json     # Project metadata
└── README.md        # This file
```

## Browser Compatibility

- Chrome/Edge (Recommended)
- Firefox
- Safari
- Mobile browsers (iOS Safari, Chrome Mobile)

## Future Enhancements

Possible additions for future versions:
- Tower upgrade system
- More tower types (Stake Launcher, Moonlight Beam)
- Boss waves with unique enemies
- Special abilities and power-ups
- Sound effects and background music
- Difficulty levels
- Achievement system
- Save/load game progress

## Credits

Inspired by Kingdom Guard and Last Z tower defense games.
Built with Phaser 3 game framework.

## License

MIT License - Feel free to modify and expand!

---

**Enjoy defending your castle from the creatures of the night!** 🧛‍♂️🐺🏰
