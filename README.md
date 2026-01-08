# Dark Defense: Vampires vs Werewolves

A merge-based idle strategy defense game where you grow your army and defend your castle against endless waves of vampires and werewolves!

## Game Overview

Inspired by Kingdom Guard and Last Z, this is a **merge and idle strategy defense game** with vampires and werewolves. Buy units, merge them to power up, unlock heroes, upgrade your base, and defend against increasingly difficult monster waves!

## Core Gameplay

### 🎯 Merge Mechanics
- **Buy Units** from the shop and place them on your grid
- **Drag & Drop** to merge two units of the same type and level
- **Level Up** - Merging creates a stronger unit (Lv1 + Lv1 = Lv2)
- **Power Scaling** - Higher level units deal exponentially more damage!

### ⚡ Idle Progression
- **Passive Gold** - Units generate gold per second based on their level
- **Continuous Combat** - Units automatically attack nearby enemies
- **Always Growing** - Keep merging and upgrading even during battle

### 🏰 Base Building
- **Upgrade Your Base** - Spend gold to increase your castle level
- **More Lives** - Each base level adds +20 max health to your castle
- **Better Rewards** - Higher levels unlock stronger heroes

### ⭐ Heroes System
- **Recruit Legendary Heroes** - Van Helsing, High Priest, Dark Knight
- **Powerful Abilities** - Heroes deal massive damage automatically
- **Level Requirements** - Unlock new heroes by upgrading your base

## Features

### 4 Unit Types (Each with Unlimited Merge Levels!)

| Unit | Cost | Base Damage | Attack Speed | Icon |
|------|------|-------------|--------------|------|
| **Hunter** | 10 gold | 10 | 1.5s | 🏹 |
| **Cleric** | 15 gold | 8 | 2.0s | ✝️ |
| **Warrior** | 20 gold | 15 | 1.0s | ⚔️ |
| **Mage** | 25 gold | 12 | 1.8s | 🔮 |

**Merge Formula:** Damage = Base × (1.8 ^ Level)
*Example: Level 5 Hunter = 10 × 1.8^4 = 105 damage!*

### 3 Legendary Heroes

| Hero | Cost | Damage | Unlock Level | Ability |
|------|------|--------|--------------|---------|
| **Van Helsing** 🎯 | 100 gold | 50 | Level 1 | Multi-shot |
| **High Priest** ⚡ | 150 gold | 40 | Level 3 | Holy Nova |
| **Dark Knight** 🛡️ | 200 gold | 70 | Level 5 | Execute |

### 4 Enemy Types (Scaling Difficulty)

| Enemy | Health | Speed | Reward | Damage to Castle |
|-------|--------|-------|--------|------------------|
| **Bat Swarm** | 20 | Fast | 3 gold | 3 lives |
| **Vampire** | 30 | Fast | 5 gold | 5 lives |
| **Werewolf** | 50 | Medium | 8 gold | 8 lives |
| **Vampire Lord** | 200 | Slow | 50 gold | 20 lives |

*Enemy health scales +30% per base level!*

## How to Play

### Setup

1. **Open in browser:**
   ```bash
   # Open index.html directly in your browser
   # Or run a local server:
   npm start
   # Or:
   python3 -m http.server 8000
   ```

2. **Visit:** `http://localhost:8000`

### Controls

**Desktop:**
- Click unit shop buttons to buy units
- Click and drag units to merge or rearrange
- Click "Upgrade Base" to level up
- Click "Heroes" to recruit heroes

**Mobile:**
- Tap to buy units
- Drag with your finger to merge
- Tap buttons to upgrade

### Strategy Guide

#### Early Game (Level 1-2)
1. **Buy Hunters** (cheapest, good damage)
2. **Merge to Level 2-3** as soon as possible
3. **Fill your grid** with units
4. **Buy Van Helsing** when you have 100 gold

#### Mid Game (Level 3-5)
1. **Upgrade your base** for more lives and better heroes
2. **Mix unit types** - Warriors for burst, Clerics for sustained
3. **Merge to Level 4-5** for exponential damage
4. **Recruit High Priest** at Level 3

#### Late Game (Level 6+)
1. **Focus on high-level units** (Level 5+)
2. **Keep upgrading base** for survivability
3. **Unlock Dark Knight** at Level 5
4. **Manage your gold/second** for passive income

### Pro Tips

- **Merge Wisely** - Two Level 5 units = One Level 6 (worth 3.2x damage!)
- **Don't overextend** - Save gold for emergency units
- **Grid management** - Keep space for new units and merges
- **Base first** - Upgrade base early for hero unlocks
- **Gold/Second** - Higher level units = more passive income
- **Hero timing** - Heroes are expensive but worth it!

## Game Systems

### Progression
- Start with 100 gold and 100 castle health
- Enemies continuously spawn every 2 seconds
- Earn gold by killing enemies
- Units generate passive gold (0.5 × level) per second
- Base upgrades cost: Level × 200 gold

### Scaling
- **Unit Damage:** Base × 1.8^(Level-1)
- **Unit Cost:** Base × 1.5^(Level-1)
- **Enemy Health:** Base × (1 + 0.3 × BaseLevel)
- **Gold/Second:** Σ(Unit Level × 0.5)

## UI Overview

### Top Bar
- 💰 **Gold** - Currency for buying/upgrading
- 💎 **Gems** - Premium currency (future use)
- ❤️ **Lives** - Castle health
- 📊 **Level** - Base level
- ☠️ **Kills** - Enemies defeated
- ⚡ **Gold/s** - Passive income rate

### Bottom Grid
- **6×2 Grid** - 12 unit slots
- **Drag & drop** interface for merging
- **Level badges** show unit level
- **Unit icons** show unit type

### Right Panel
- **Unit Shop** - Buy Level 1 units
- **Upgrade Base** - Increase castle level
- **Heroes** - Recruit legendary heroes

## Technical Details

- **Framework:** Phaser 3 (v3.60.0)
- **Platform:** HTML5 Canvas
- **Mobile:** Touch-optimized controls
- **Resolution:** 800×600 (auto-scales)
- **No installation required!**

## File Structure

```
Game/
├── index.html       # Main HTML entry point
├── game.js          # Complete game logic
├── package.json     # Project metadata
└── README.md        # This file
```

## Gameplay Loop

```
Buy Units → Place on Grid → Merge Same Units → Power Up!
    ↓                                             ↑
Earn Gold ← Kill Enemies ← Auto-Attack ← High Level Units
    ↓
Upgrade Base → Unlock Heroes → Even More Power!
```

## Future Enhancements

- **Unit Evolution** - Transform at high levels into new types
- **Hero Abilities** - Active skills with cooldowns
- **Artifacts System** - Permanent upgrades
- **Prestige Mode** - Reset for permanent bonuses
- **More Heroes** - Expanded roster with unique abilities
- **Boss Waves** - Special challenge enemies
- **Sound & Music** - Audio feedback
- **Achievements** - Goals and rewards
- **Save System** - Persistent progress
- **Gem Shop** - Special items and boosts

## Game Balance

| Level | Recommended Units | Gold/s | Survival Strategy |
|-------|-------------------|--------|-------------------|
| 1-2 | 6× Lv2-3 | ~10 | Basic merge, buy Van Helsing |
| 3-4 | 8× Lv3-4 | ~25 | Mix units, recruit Priest |
| 5-6 | 10× Lv4-5 | ~45 | High level merges, get Knight |
| 7+ | 12× Lv5+ | ~60+ | Max efficiency, survive! |

## Browser Compatibility

- ✅ Chrome/Edge (Recommended)
- ✅ Firefox
- ✅ Safari
- ✅ Mobile Chrome
- ✅ Mobile Safari

## Credits

Inspired by **Kingdom Guard** and **Last Z** merge defense games.
Built with **Phaser 3** game framework.
Vampire & werewolf theme for dark fantasy fans! 🧛‍♂️🐺

## License

MIT License - Free to play, modify, and share!

---

**Defend your castle, merge your army, and survive the night!** 🏰⚔️🌙
