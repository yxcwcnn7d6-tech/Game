// Dark Defense: Vampires vs Werewolves
// A merge-based idle strategy defense game

const gameConfig = {
    type: Phaser.AUTO,
    width: 800,
    height: 600,
    parent: 'game-container',
    backgroundColor: '#1a1a2e',
    scale: {
        mode: Phaser.Scale.FIT,
        autoCenter: Phaser.Scale.CENTER_BOTH
    },
    physics: {
        default: 'arcade',
        arcade: {
            gravity: { y: 0 },
            debug: false
        }
    },
    scene: [MenuScene, GameScene]
};

const game = new Phaser.Game(gameConfig);

// Global game state
let gameState = {
    gold: 100,
    gems: 5,
    lives: 100,
    maxLives: 100,
    level: 1,
    kills: 0,
    goldPerSecond: 0,
    baseHealth: 100,
    baseDamage: 10,
    unitSlots: 12,
    autoSpawnEnabled: false
};

// Unit types with merge progression
const UNIT_TYPES = {
    HUNTER: {
        name: 'Hunter',
        baseCost: 10,
        baseDamage: 10,
        baseAttackSpeed: 1.5,
        color: 0x00FF00,
        icon: '🏹',
        description: 'Basic ranged unit'
    },
    CLERIC: {
        name: 'Cleric',
        baseCost: 15,
        baseDamage: 8,
        baseAttackSpeed: 2.0,
        color: 0xFFFF00,
        icon: '✝️',
        description: 'Holy damage dealer'
    },
    WARRIOR: {
        name: 'Warrior',
        baseCost: 20,
        baseDamage: 15,
        baseAttackSpeed: 1.0,
        color: 0xFF0000,
        icon: '⚔️',
        description: 'High damage melee'
    },
    MAGE: {
        name: 'Mage',
        baseCost: 25,
        baseDamage: 12,
        baseAttackSpeed: 1.8,
        color: 0x9D00FF,
        icon: '🔮',
        description: 'Magic damage'
    }
};

// Heroes with special abilities
const HEROES = {
    VAN_HELSING: {
        name: 'Van Helsing',
        damage: 50,
        attackSpeed: 0.8,
        ability: 'Multi-shot',
        abilityPower: 3,
        cost: 100,
        color: 0xFF6600,
        icon: '🎯',
        unlockLevel: 1
    },
    PRIEST: {
        name: 'High Priest',
        damage: 40,
        attackSpeed: 1.2,
        ability: 'Holy Nova',
        abilityPower: 80,
        cost: 150,
        color: 0xFFD700,
        icon: '⚡',
        unlockLevel: 3
    },
    KNIGHT: {
        name: 'Dark Knight',
        damage: 70,
        attackSpeed: 1.0,
        ability: 'Execute',
        abilityPower: 150,
        cost: 200,
        color: 0x8B00FF,
        icon: '🛡️',
        unlockLevel: 5
    }
};

// Enemy types
const ENEMY_TYPES = {
    VAMPIRE: {
        name: 'Vampire',
        baseHealth: 30,
        speed: 50,
        reward: 5,
        damage: 5,
        color: 0xFF0000
    },
    WEREWOLF: {
        name: 'Werewolf',
        baseHealth: 50,
        speed: 40,
        reward: 8,
        damage: 8,
        color: 0x8B4513
    },
    BAT_SWARM: {
        name: 'Bat Swarm',
        baseHealth: 20,
        speed: 70,
        reward: 3,
        damage: 3,
        color: 0x333333
    },
    VAMPIRE_LORD: {
        name: 'Vampire Lord',
        baseHealth: 200,
        speed: 35,
        reward: 50,
        damage: 20,
        color: 0x8B0000
    }
};

// Menu Scene
class MenuScene extends Phaser.Scene {
    constructor() {
        super({ key: 'MenuScene' });
    }

    create() {
        const { width, height } = this.cameras.main;

        // Title
        this.add.text(width / 2, height / 4, 'DARK DEFENSE', {
            fontSize: '52px',
            fontStyle: 'bold',
            color: '#FF0000',
            stroke: '#000000',
            strokeThickness: 6
        }).setOrigin(0.5);

        this.add.text(width / 2, height / 4 + 50, 'Vampires vs Werewolves', {
            fontSize: '28px',
            color: '#FFFFFF'
        }).setOrigin(0.5);

        // Game type description
        this.add.text(width / 2, height / 2 - 60, 'Merge & Idle Strategy Defense', {
            fontSize: '20px',
            color: '#FFD700',
            fontStyle: 'bold'
        }).setOrigin(0.5);

        // Instructions
        const instructions = [
            'HOW TO PLAY:',
            '',
            '• Buy units and place them on the grid',
            '• Drag and merge same units to level up',
            '• Unlock and deploy powerful heroes',
            '• Upgrade your base for bonuses',
            '• Defend against endless monster waves',
            '',
            'Tap to start your defense!'
        ];

        let yPos = height / 2 - 20;
        instructions.forEach((line, idx) => {
            this.add.text(width / 2, yPos, line, {
                fontSize: idx === 0 ? '16px' : '14px',
                color: idx === 0 ? '#00FF00' : '#CCCCCC',
                fontStyle: idx === 0 ? 'bold' : 'normal',
                align: 'center'
            }).setOrigin(0.5);
            yPos += line === '' ? 10 : 22;
        });

        // Start button
        const startButton = this.add.rectangle(width / 2, height - 80, 220, 60, 0xFF0000)
            .setInteractive()
            .on('pointerdown', () => this.startGame());

        this.add.text(width / 2, height - 80, 'START GAME', {
            fontSize: '26px',
            fontStyle: 'bold',
            color: '#FFFFFF'
        }).setOrigin(0.5);

        startButton.on('pointerover', () => startButton.setFillStyle(0xFF3333));
        startButton.on('pointerout', () => startButton.setFillStyle(0xFF0000));
    }

    startGame() {
        // Reset game state
        gameState = {
            gold: 100,
            gems: 5,
            lives: 100,
            maxLives: 100,
            level: 1,
            kills: 0,
            goldPerSecond: 0,
            baseHealth: 100,
            baseDamage: 10,
            unitSlots: 12,
            autoSpawnEnabled: false
        };
        this.scene.start('GameScene');
    }
}

// Main Game Scene
class GameScene extends Phaser.Scene {
    constructor() {
        super({ key: 'GameScene' });
        this.units = [];
        this.heroes = [];
        this.enemies = [];
        this.projectiles = [];
        this.gridSlots = [];
        this.draggedUnit = null;
        this.spawnTimer = 0;
        this.goldTimer = 0;
        this.difficultyMultiplier = 1.0;
        this.purchasedHeroes = [];
    }

    create() {
        const { width, height } = this.cameras.main;

        // Create game area backgrounds
        this.add.rectangle(0, 0, width, height * 0.7, 0x0a0a1a).setOrigin(0);
        this.add.rectangle(0, height * 0.7, width, height * 0.3, 0x2a2a3a).setOrigin(0);

        // Create unit grid (3x4 grid)
        this.createUnitGrid();

        // Create enemy path
        this.createEnemyPath();

        // Create UI
        this.createUI();

        // Start enemy spawning
        this.startEnemySpawning();

        // Create castle
        this.createCastle();

        // Passive gold generation
        this.time.addEvent({
            delay: 1000,
            callback: () => this.generatePassiveGold(),
            loop: true
        });
    }

    createCastle() {
        const { width, height } = this.cameras.main;

        // Castle at the end of path
        this.castle = this.add.rectangle(width - 50, height * 0.35, 40, 60, 0x654321);
        this.add.rectangle(width - 50, height * 0.35 - 35, 30, 20, 0xFF0000);

        this.castleHealthBar = this.add.rectangle(width - 50, height * 0.35 + 45, 60, 8, 0x00FF00);
        this.castleHealthBarBg = this.add.rectangle(width - 50, height * 0.35 + 45, 60, 8, 0xFF0000);

        this.add.text(width - 50, height * 0.35 + 60, 'CASTLE', {
            fontSize: '10px',
            color: '#FFFFFF'
        }).setOrigin(0.5);
    }

    createUnitGrid() {
        const { height } = this.cameras.main;
        const startX = 60;
        const startY = height * 0.7 + 20;
        const slotSize = 65;
        const cols = 6;
        const rows = 2;

        for (let row = 0; row < rows; row++) {
            for (let col = 0; col < cols; col++) {
                const x = startX + col * slotSize;
                const y = startY + row * slotSize;

                const slot = this.add.rectangle(x, y, 60, 60, 0x333333, 0.5)
                    .setStrokeStyle(2, 0x666666);

                slot.slotData = {
                    x: x,
                    y: y,
                    unit: null,
                    index: row * cols + col
                };

                this.gridSlots.push(slot);
            }
        }
    }

    createEnemyPath() {
        const { width, height } = this.cameras.main;

        // Path from left to castle on right
        this.enemyPath = [
            { x: -50, y: height * 0.35 },
            { x: width - 100, y: height * 0.35 }
        ];

        // Draw path
        const graphics = this.add.graphics();
        graphics.lineStyle(40, 0x1a1a2a, 1);
        graphics.lineBetween(this.enemyPath[0].x, this.enemyPath[0].y,
                            this.enemyPath[1].x, this.enemyPath[1].y);
    }

    createUI() {
        const { width, height } = this.cameras.main;

        // Top bar resources
        const topBarBg = this.add.rectangle(0, 0, width, 50, 0x1a1a2a, 0.9).setOrigin(0);

        this.goldText = this.add.text(15, 15, `💰 Gold: ${gameState.gold}`, {
            fontSize: '18px',
            color: '#FFD700',
            fontStyle: 'bold'
        });

        this.gemsText = this.add.text(15, 35, `💎 Gems: ${gameState.gems}`, {
            fontSize: '14px',
            color: '#00FFFF'
        });

        this.livesText = this.add.text(200, 15, `❤️ Lives: ${gameState.lives}/${gameState.maxLives}`, {
            fontSize: '18px',
            color: '#FF0000',
            fontStyle: 'bold'
        });

        this.levelText = this.add.text(200, 35, `📊 Level: ${gameState.level}`, {
            fontSize: '14px',
            color: '#FFFFFF'
        });

        this.killsText = this.add.text(380, 15, `☠️ Kills: ${gameState.kills}`, {
            fontSize: '16px',
            color: '#FF6600'
        });

        this.gpsText = this.add.text(380, 35, `⚡ Gold/s: ${gameState.goldPerSecond}`, {
            fontSize: '14px',
            color: '#00FF00'
        });

        // Unit shop buttons (right side of bottom area)
        this.createUnitShop();

        // Base upgrade button
        this.createBaseUpgradeButton();

        // Hero shop button
        this.createHeroShopButton();
    }

    createUnitShop() {
        const { width, height } = this.cameras.main;
        const startX = width - 180;
        const startY = height * 0.7 + 20;
        const buttonHeight = 65;

        let yPos = startY;
        Object.entries(UNIT_TYPES).forEach(([key, unit]) => {
            const cost = this.getUnitCost(key, 1);

            const button = this.add.rectangle(startX, yPos, 160, 55, 0x2a2a4a)
                .setStrokeStyle(2, unit.color)
                .setInteractive();

            const nameText = this.add.text(startX, yPos - 15, `${unit.icon} ${unit.name} Lv1`, {
                fontSize: '14px',
                color: '#FFFFFF',
                fontStyle: 'bold'
            }).setOrigin(0.5);

            const costText = this.add.text(startX, yPos + 5, `💰 ${cost}`, {
                fontSize: '13px',
                color: '#FFD700'
            }).setOrigin(0.5);

            const dmgText = this.add.text(startX, yPos + 20, `⚔️ ${unit.baseDamage}`, {
                fontSize: '11px',
                color: '#FF6600'
            }).setOrigin(0.5);

            button.on('pointerdown', () => this.buyUnit(key));

            button.on('pointerover', () => button.setFillStyle(0x3a3a5a));
            button.on('pointerout', () => button.setFillStyle(0x2a2a4a));

            yPos += buttonHeight;
        });
    }

    createBaseUpgradeButton() {
        const { width, height } = this.cameras.main;

        const button = this.add.rectangle(width - 180, height - 80, 160, 35, 0x4a2a2a)
            .setStrokeStyle(2, 0xFF6600)
            .setInteractive();

        this.add.text(width - 180, height - 80, '🏰 Upgrade Base', {
            fontSize: '14px',
            color: '#FFFFFF',
            fontStyle: 'bold'
        }).setOrigin(0.5);

        button.on('pointerdown', () => this.upgradeBase());
        button.on('pointerover', () => button.setFillStyle(0x5a3a3a));
        button.on('pointerout', () => button.setFillStyle(0x4a2a2a));
    }

    createHeroShopButton() {
        const { width, height } = this.cameras.main;

        const button = this.add.rectangle(width - 180, height - 35, 160, 35, 0x2a4a2a)
            .setStrokeStyle(2, 0x00FF00)
            .setInteractive();

        this.add.text(width - 180, height - 35, '⭐ Heroes', {
            fontSize: '14px',
            color: '#FFFFFF',
            fontStyle: 'bold'
        }).setOrigin(0.5);

        button.on('pointerdown', () => this.openHeroShop());
        button.on('pointerover', () => button.setFillStyle(0x3a5a3a));
        button.on('pointerout', () => button.setFillStyle(0x2a4a2a));
    }

    getUnitCost(type, level) {
        const base = UNIT_TYPES[type].baseCost;
        return Math.floor(base * Math.pow(1.5, level - 1));
    }

    buyUnit(type) {
        const cost = this.getUnitCost(type, 1);

        if (gameState.gold < cost) {
            this.showMessage('Not enough gold!', 0xFF0000);
            return;
        }

        // Find empty slot
        const emptySlot = this.gridSlots.find(slot => !slot.slotData.unit);

        if (!emptySlot) {
            this.showMessage('No empty slots!', 0xFF0000);
            return;
        }

        gameState.gold -= cost;
        this.placeUnit(emptySlot, type, 1);
        this.updateUI();
    }

    placeUnit(slot, type, level) {
        const config = UNIT_TYPES[type];
        const damage = Math.floor(config.baseDamage * Math.pow(1.8, level - 1));

        const unit = this.add.circle(slot.slotData.x, slot.slotData.y, 25, config.color);
        unit.setStrokeStyle(3, 0xFFFFFF);

        // Level badge
        const levelBadge = this.add.circle(slot.slotData.x + 18, slot.slotData.y - 18, 10, 0xFFFFFF);
        const levelText = this.add.text(slot.slotData.x + 18, slot.slotData.y - 18, level, {
            fontSize: '12px',
            color: '#000000',
            fontStyle: 'bold'
        }).setOrigin(0.5);

        // Icon
        const icon = this.add.text(slot.slotData.x, slot.slotData.y, config.icon, {
            fontSize: '24px'
        }).setOrigin(0.5);

        unit.unitData = {
            type: type,
            level: level,
            config: config,
            damage: damage,
            attackSpeed: config.baseAttackSpeed,
            lastAttack: 0,
            slot: slot,
            levelBadge: levelBadge,
            levelText: levelText,
            icon: icon
        };

        unit.setInteractive({ draggable: true });

        // Drag events
        this.input.on('drag', (pointer, gameObject, dragX, dragY) => {
            if (gameObject === unit) {
                gameObject.x = dragX;
                gameObject.y = dragY;
                icon.x = dragX;
                icon.y = dragY;
                levelBadge.x = dragX + 18;
                levelBadge.y = dragY - 18;
                levelText.x = dragX + 18;
                levelText.y = dragY - 18;
            }
        });

        this.input.on('dragend', (pointer, gameObject) => {
            if (gameObject === unit) {
                this.handleUnitDrop(unit);
            }
        });

        slot.slotData.unit = unit;
        this.units.push(unit);

        this.updateGoldPerSecond();
    }

    handleUnitDrop(unit) {
        // Find which slot we dropped on
        let targetSlot = null;
        let minDist = 50;

        for (const slot of this.gridSlots) {
            const dist = Phaser.Math.Distance.Between(unit.x, unit.y, slot.slotData.x, slot.slotData.y);
            if (dist < minDist) {
                minDist = dist;
                targetSlot = slot;
            }
        }

        if (!targetSlot) {
            // Return to original slot
            this.resetUnitPosition(unit);
            return;
        }

        // Check if target has a unit
        if (targetSlot.slotData.unit && targetSlot.slotData.unit !== unit) {
            const targetUnit = targetSlot.slotData.unit;

            // Check if can merge (same type and level)
            if (targetUnit.unitData.type === unit.unitData.type &&
                targetUnit.unitData.level === unit.unitData.level) {

                // Merge!
                this.mergeUnits(unit, targetUnit, targetSlot);
                return;
            }
        }

        // Swap or move
        const oldSlot = unit.unitData.slot;

        if (targetSlot.slotData.unit && targetSlot !== oldSlot) {
            // Swap positions
            const otherUnit = targetSlot.slotData.unit;
            oldSlot.slotData.unit = otherUnit;
            otherUnit.unitData.slot = oldSlot;
            this.resetUnitPosition(otherUnit);
        } else {
            oldSlot.slotData.unit = null;
        }

        targetSlot.slotData.unit = unit;
        unit.unitData.slot = targetSlot;
        this.resetUnitPosition(unit);
    }

    mergeUnits(unit1, unit2, targetSlot) {
        const newLevel = unit1.unitData.level + 1;
        const type = unit1.unitData.type;

        // Remove both units
        unit1.unitData.slot.slotData.unit = null;
        this.removeUnit(unit1);
        this.removeUnit(unit2);

        // Create new higher level unit
        this.placeUnit(targetSlot, type, newLevel);

        this.showMessage(`Merged to Level ${newLevel}!`, 0x00FF00);
        this.updateGoldPerSecond();
    }

    removeUnit(unit) {
        unit.unitData.levelBadge.destroy();
        unit.unitData.levelText.destroy();
        unit.unitData.icon.destroy();
        unit.destroy();

        const idx = this.units.indexOf(unit);
        if (idx > -1) this.units.splice(idx, 1);
    }

    resetUnitPosition(unit) {
        const slot = unit.unitData.slot;
        unit.x = slot.slotData.x;
        unit.y = slot.slotData.y;
        unit.unitData.icon.x = slot.slotData.x;
        unit.unitData.icon.y = slot.slotData.y;
        unit.unitData.levelBadge.x = slot.slotData.x + 18;
        unit.unitData.levelBadge.y = slot.slotData.y - 18;
        unit.unitData.levelText.x = slot.slotData.x + 18;
        unit.unitData.levelText.y = slot.slotData.y - 18;
    }

    upgradeBase() {
        const cost = gameState.level * 200;

        if (gameState.gold < cost) {
            this.showMessage(`Need ${cost} gold!`, 0xFF0000);
            return;
        }

        gameState.gold -= cost;
        gameState.level++;
        gameState.maxLives += 20;
        gameState.lives = Math.min(gameState.lives + 20, gameState.maxLives);
        gameState.baseDamage += 5;

        this.showMessage(`Base upgraded to Level ${gameState.level}!`, 0x00FF00);
        this.updateUI();
    }

    openHeroShop() {
        // Simple hero purchase
        const availableHeroes = Object.entries(HEROES).filter(([key, hero]) =>
            hero.unlockLevel <= gameState.level && !this.purchasedHeroes.includes(key)
        );

        if (availableHeroes.length === 0) {
            this.showMessage('No heroes available!', 0xFF0000);
            return;
        }

        const [heroKey, hero] = availableHeroes[0];

        if (gameState.gold < hero.cost) {
            this.showMessage(`Need ${hero.cost} gold for ${hero.name}!`, 0xFF0000);
            return;
        }

        gameState.gold -= hero.cost;
        this.purchasedHeroes.push(heroKey);
        this.deployHero(heroKey);

        this.showMessage(`${hero.name} recruited!`, 0x00FF00);
        this.updateUI();
    }

    deployHero(heroKey) {
        const { height } = this.cameras.main;
        const hero = HEROES[heroKey];

        const heroSprite = this.add.circle(400, height * 0.35 - 60, 20, hero.color);
        heroSprite.setStrokeStyle(3, 0xFFD700);

        const heroIcon = this.add.text(400, height * 0.35 - 60, hero.icon, {
            fontSize: '20px'
        }).setOrigin(0.5);

        const heroName = this.add.text(400, height * 0.35 - 85, hero.name, {
            fontSize: '10px',
            color: '#FFD700',
            fontStyle: 'bold'
        }).setOrigin(0.5);

        heroSprite.heroData = {
            key: heroKey,
            config: hero,
            damage: hero.damage,
            attackSpeed: hero.attackSpeed,
            lastAttack: 0,
            icon: heroIcon,
            nameText: heroName
        };

        this.heroes.push(heroSprite);
    }

    startEnemySpawning() {
        this.time.addEvent({
            delay: 2000,
            callback: () => this.spawnEnemy(),
            loop: true
        });
    }

    spawnEnemy() {
        // Difficulty increases over time
        const types = Object.keys(ENEMY_TYPES);
        let enemyKey;

        const rand = Math.random();
        if (gameState.level < 3) {
            enemyKey = rand < 0.7 ? 'VAMPIRE' : 'WEREWOLF';
        } else if (gameState.level < 6) {
            if (rand < 0.4) enemyKey = 'BAT_SWARM';
            else if (rand < 0.7) enemyKey = 'VAMPIRE';
            else enemyKey = 'WEREWOLF';
        } else {
            if (rand < 0.3) enemyKey = 'BAT_SWARM';
            else if (rand < 0.5) enemyKey = 'VAMPIRE';
            else if (rand < 0.75) enemyKey = 'WEREWOLF';
            else enemyKey = 'VAMPIRE_LORD';
        }

        const config = ENEMY_TYPES[enemyKey];
        const healthMultiplier = 1 + (gameState.level - 1) * 0.3;

        const enemy = this.add.circle(this.enemyPath[0].x, this.enemyPath[0].y, 12, config.color);
        enemy.setStrokeStyle(2, 0x000000);

        enemy.enemyData = {
            type: enemyKey,
            config: config,
            health: config.baseHealth * healthMultiplier,
            maxHealth: config.baseHealth * healthMultiplier,
            speed: config.speed,
            reward: config.reward
        };

        // Health bar
        enemy.healthBar = this.add.rectangle(enemy.x, enemy.y - 20, 24, 3, 0x00FF00);
        enemy.healthBarBg = this.add.rectangle(enemy.x, enemy.y - 20, 24, 3, 0xFF0000);

        this.enemies.push(enemy);
    }

    update(time, delta) {
        this.updateEnemies(delta);
        this.updateUnits(time);
        this.updateHeroes(time);
        this.updateProjectiles(delta);
        this.updateCastleHealthBar();
    }

    updateEnemies(delta) {
        for (let i = this.enemies.length - 1; i >= 0; i--) {
            const enemy = this.enemies[i];
            const data = enemy.enemyData;

            // Move towards castle
            const target = this.enemyPath[1];
            const dx = target.x - enemy.x;
            const dy = target.y - enemy.y;
            const distance = Math.sqrt(dx * dx + dy * dy);

            if (distance < 10) {
                // Reached castle
                gameState.lives -= data.config.damage;
                this.removeEnemy(i);

                if (gameState.lives <= 0) {
                    this.gameOver();
                }
                continue;
            }

            const speed = (data.speed * delta) / 1000;
            enemy.x += (dx / distance) * speed;
            enemy.y += (dy / distance) * speed;

            // Update health bar
            enemy.healthBar.x = enemy.x;
            enemy.healthBar.y = enemy.y - 20;
            enemy.healthBarBg.x = enemy.x;
            enemy.healthBarBg.y = enemy.y - 20;

            const healthPercent = data.health / data.maxHealth;
            enemy.healthBar.scaleX = healthPercent;

            // Check if dead
            if (data.health <= 0) {
                gameState.gold += data.reward;
                gameState.kills++;
                this.removeEnemy(i);
            }
        }
    }

    updateUnits(time) {
        for (const unit of this.units) {
            const data = unit.unitData;

            if (time - data.lastAttack < data.attackSpeed * 1000) continue;

            // Find nearest enemy
            let target = this.findNearestEnemy(unit.x, unit.y);

            if (target) {
                this.fireProjectile(unit.x, unit.y, target, data.damage, 0x00FF00);
                data.lastAttack = time;
            }
        }
    }

    updateHeroes(time) {
        for (const hero of this.heroes) {
            const data = hero.heroData;

            if (time - data.lastAttack < data.attackSpeed * 1000) continue;

            let target = this.findNearestEnemy(hero.x, hero.y);

            if (target) {
                this.fireProjectile(hero.x, hero.y, target, data.damage, 0xFFD700);
                data.lastAttack = time;
            }
        }
    }

    findNearestEnemy(x, y) {
        let nearest = null;
        let minDist = 500;

        for (const enemy of this.enemies) {
            const dist = Phaser.Math.Distance.Between(x, y, enemy.x, enemy.y);
            if (dist < minDist) {
                minDist = dist;
                nearest = enemy;
            }
        }

        return nearest;
    }

    fireProjectile(x, y, target, damage, color) {
        const proj = this.add.circle(x, y, 4, color);

        proj.projectileData = {
            target: target,
            damage: damage,
            speed: 250
        };

        this.projectiles.push(proj);
    }

    updateProjectiles(delta) {
        for (let i = this.projectiles.length - 1; i >= 0; i--) {
            const proj = this.projectiles[i];
            const data = proj.projectileData;

            if (!data.target || !this.enemies.includes(data.target)) {
                proj.destroy();
                this.projectiles.splice(i, 1);
                continue;
            }

            const dx = data.target.x - proj.x;
            const dy = data.target.y - proj.y;
            const distance = Math.sqrt(dx * dx + dy * dy);

            if (distance < 10) {
                data.target.enemyData.health -= data.damage;
                proj.destroy();
                this.projectiles.splice(i, 1);
            } else {
                const speed = (data.speed * delta) / 1000;
                proj.x += (dx / distance) * speed;
                proj.y += (dy / distance) * speed;
            }
        }
    }

    removeEnemy(index) {
        const enemy = this.enemies[index];
        enemy.healthBar.destroy();
        enemy.healthBarBg.destroy();
        enemy.destroy();
        this.enemies.splice(index, 1);
    }

    generatePassiveGold() {
        const goldGain = Math.floor(gameState.goldPerSecond);
        if (goldGain > 0) {
            gameState.gold += goldGain;
            this.updateUI();
        }
    }

    updateGoldPerSecond() {
        let total = 0;
        for (const unit of this.units) {
            total += unit.unitData.level * 0.5;
        }
        gameState.goldPerSecond = Math.floor(total);
    }

    updateCastleHealthBar() {
        const percent = gameState.lives / gameState.maxLives;
        this.castleHealthBar.scaleX = percent;
    }

    updateUI() {
        this.goldText.setText(`💰 Gold: ${gameState.gold}`);
        this.gemsText.setText(`💎 Gems: ${gameState.gems}`);
        this.livesText.setText(`❤️ Lives: ${gameState.lives}/${gameState.maxLives}`);
        this.levelText.setText(`📊 Level: ${gameState.level}`);
        this.killsText.setText(`☠️ Kills: ${gameState.kills}`);
        this.gpsText.setText(`⚡ Gold/s: ${gameState.goldPerSecond}`);
    }

    showMessage(text, color) {
        const { width, height } = this.cameras.main;
        const msg = this.add.text(width / 2, height * 0.35, text, {
            fontSize: '24px',
            color: '#' + color.toString(16).padStart(6, '0'),
            fontStyle: 'bold',
            stroke: '#000000',
            strokeThickness: 4
        }).setOrigin(0.5);

        this.tweens.add({
            targets: msg,
            alpha: 0,
            y: height * 0.35 - 40,
            duration: 1500,
            onComplete: () => msg.destroy()
        });
    }

    gameOver() {
        this.showMessage('GAME OVER!', 0xFF0000);

        this.time.delayedCall(2000, () => {
            this.scene.start('MenuScene');
        });
    }
}
