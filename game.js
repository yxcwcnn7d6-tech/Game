// Dark Defense: Vampires vs Werewolves
// A tower defense game for mobile

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
    scene: [MenuScene, GameScene, GameOverScene, VictoryScene]
};

const game = new Phaser.Game(gameConfig);

// Global game state
let gameState = {
    gold: 150,
    lives: 20,
    wave: 0,
    score: 0,
    selectedTowerType: null
};

// Tower types configuration
const TOWER_TYPES = {
    GARLIC: {
        name: 'Garlic Cannon',
        cost: 50,
        damage: 15,
        range: 120,
        fireRate: 1000,
        color: 0xFFFFFF,
        bonus: { vampire: 2.0 },
        description: '2x damage to vampires'
    },
    SILVER: {
        name: 'Silver Bullets',
        cost: 75,
        damage: 20,
        range: 150,
        fireRate: 800,
        color: 0xC0C0C0,
        bonus: { werewolf: 2.5 },
        description: '2.5x damage to werewolves'
    },
    HOLY_WATER: {
        name: 'Holy Water',
        cost: 100,
        damage: 25,
        range: 100,
        fireRate: 1200,
        color: 0x00FFFF,
        bonus: { vampire: 1.5, werewolf: 1.5 },
        description: 'Good vs both'
    },
    UV_LIGHT: {
        name: 'UV Tower',
        cost: 120,
        damage: 10,
        range: 140,
        fireRate: 500,
        color: 0x9D00FF,
        bonus: { vampire: 1.8 },
        slow: 0.5,
        description: 'Slows vampires'
    }
};

// Enemy types configuration
const ENEMY_TYPES = {
    VAMPIRE: {
        name: 'Vampire',
        health: 50,
        speed: 80,
        reward: 15,
        color: 0xFF0000,
        damage: 2
    },
    WEREWOLF: {
        name: 'Werewolf',
        health: 100,
        speed: 60,
        reward: 25,
        color: 0x8B4513,
        damage: 3
    },
    VAMPIRE_LORD: {
        name: 'Vampire Lord',
        health: 150,
        speed: 70,
        reward: 50,
        color: 0x8B0000,
        damage: 4
    },
    ALPHA_WEREWOLF: {
        name: 'Alpha Werewolf',
        health: 200,
        speed: 55,
        reward: 60,
        color: 0x654321,
        damage: 5
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
            fontSize: '48px',
            fontStyle: 'bold',
            color: '#FF0000',
            stroke: '#000000',
            strokeThickness: 6
        }).setOrigin(0.5);

        this.add.text(width / 2, height / 4 + 50, 'Vampires vs Werewolves', {
            fontSize: '24px',
            color: '#FFFFFF'
        }).setOrigin(0.5);

        // Instructions
        const instructions = [
            'Defend your castle from waves of',
            'vampires and werewolves!',
            '',
            'Place towers to stop the monsters',
            'Each tower has unique strengths',
            '',
            'Tap to play!'
        ];

        let yPos = height / 2;
        instructions.forEach(line => {
            this.add.text(width / 2, yPos, line, {
                fontSize: '18px',
                color: '#CCCCCC',
                align: 'center'
            }).setOrigin(0.5);
            yPos += 25;
        });

        // Start button
        const startButton = this.add.rectangle(width / 2, height - 100, 200, 60, 0xFF0000)
            .setInteractive()
            .on('pointerdown', () => this.startGame());

        this.add.text(width / 2, height - 100, 'START GAME', {
            fontSize: '24px',
            fontStyle: 'bold',
            color: '#FFFFFF'
        }).setOrigin(0.5);

        // Hover effect
        startButton.on('pointerover', () => startButton.setFillStyle(0xFF3333));
        startButton.on('pointerout', () => startButton.setFillStyle(0xFF0000));
    }

    startGame() {
        gameState.gold = 150;
        gameState.lives = 20;
        gameState.wave = 0;
        gameState.score = 0;
        this.scene.start('GameScene');
    }
}

// Main Game Scene
class GameScene extends Phaser.Scene {
    constructor() {
        super({ key: 'GameScene' });
        this.towers = [];
        this.enemies = [];
        this.projectiles = [];
        this.path = [];
        this.waveActive = false;
        this.enemiesSpawned = 0;
        this.enemiesTotal = 0;
    }

    create() {
        const { width, height } = this.cameras.main;

        // Create path for enemies
        this.createPath();

        // Create grid for tower placement
        this.createGrid();

        // UI
        this.createUI();

        // Start first wave
        this.time.delayedCall(1000, () => this.startNextWave());
    }

    createPath() {
        const { width, height } = this.cameras.main;

        // Define path points (serpentine path)
        this.path = [
            { x: -50, y: height / 2 - 100 },
            { x: 200, y: height / 2 - 100 },
            { x: 200, y: height / 2 + 100 },
            { x: 600, y: height / 2 + 100 },
            { x: 600, y: height / 2 - 100 },
            { x: width + 50, y: height / 2 - 100 }
        ];

        // Draw path
        const graphics = this.add.graphics();
        graphics.lineStyle(60, 0x444444, 1);
        graphics.beginPath();
        graphics.moveTo(this.path[0].x, this.path[0].y);
        for (let i = 1; i < this.path.length; i++) {
            graphics.lineTo(this.path[i].x, this.path[i].y);
        }
        graphics.strokePath();

        // Draw castle at the end
        const castleX = this.path[this.path.length - 1].x - 80;
        const castleY = this.path[this.path.length - 1].y;

        this.castle = this.add.rectangle(castleX, castleY, 60, 80, 0x654321);
        this.add.rectangle(castleX, castleY - 50, 40, 30, 0xFF0000);
        this.add.text(castleX, castleY + 60, 'CASTLE', {
            fontSize: '12px',
            color: '#FFFFFF'
        }).setOrigin(0.5);
    }

    createGrid() {
        const { width, height } = this.cameras.main;
        this.gridGraphics = this.add.graphics();
        this.gridGraphics.lineStyle(1, 0x333333, 0.3);

        const gridSize = 60;
        for (let x = 0; x < width; x += gridSize) {
            this.gridGraphics.lineBetween(x, 0, x, height);
        }
        for (let y = 0; y < height; y += gridSize) {
            this.gridGraphics.lineBetween(0, y, width, y);
        }

        // Add click handler for tower placement
        this.input.on('pointerdown', (pointer) => this.handleTowerPlacement(pointer));
    }

    createUI() {
        const { width } = this.cameras.main;
        const uiY = 20;

        // Resources display
        this.goldText = this.add.text(20, uiY, `Gold: ${gameState.gold}`, {
            fontSize: '20px',
            color: '#FFD700',
            fontStyle: 'bold'
        });

        this.livesText = this.add.text(20, uiY + 30, `Lives: ${gameState.lives}`, {
            fontSize: '20px',
            color: '#FF0000',
            fontStyle: 'bold'
        });

        this.waveText = this.add.text(20, uiY + 60, `Wave: ${gameState.wave}`, {
            fontSize: '20px',
            color: '#FFFFFF',
            fontStyle: 'bold'
        });

        this.scoreText = this.add.text(20, uiY + 90, `Score: ${gameState.score}`, {
            fontSize: '20px',
            color: '#00FF00',
            fontStyle: 'bold'
        });

        // Tower selection buttons
        this.createTowerButtons();
    }

    createTowerButtons() {
        const { width } = this.cameras.main;
        const buttonWidth = 180;
        const buttonHeight = 70;
        const startX = width - 200;
        let startY = 20;

        Object.entries(TOWER_TYPES).forEach(([key, tower]) => {
            const button = this.add.rectangle(startX, startY, buttonWidth, buttonHeight, 0x333333)
                .setStrokeStyle(2, tower.color)
                .setInteractive();

            const text = this.add.text(startX, startY - 15, tower.name, {
                fontSize: '14px',
                color: '#FFFFFF',
                fontStyle: 'bold'
            }).setOrigin(0.5);

            const cost = this.add.text(startX, startY + 5, `Cost: ${tower.cost}`, {
                fontSize: '12px',
                color: '#FFD700'
            }).setOrigin(0.5);

            const desc = this.add.text(startX, startY + 20, tower.description, {
                fontSize: '10px',
                color: '#CCCCCC'
            }).setOrigin(0.5);

            button.on('pointerdown', () => {
                gameState.selectedTowerType = key;
                // Highlight selected
                this.children.list.forEach(child => {
                    if (child.type === 'Rectangle' && child.width === buttonWidth) {
                        child.setFillStyle(0x333333);
                    }
                });
                button.setFillStyle(0x555555);
            });

            button.on('pointerover', () => {
                if (gameState.selectedTowerType !== key) {
                    button.setFillStyle(0x444444);
                }
            });

            button.on('pointerout', () => {
                if (gameState.selectedTowerType !== key) {
                    button.setFillStyle(0x333333);
                }
            });

            startY += buttonHeight + 10;
        });
    }

    handleTowerPlacement(pointer) {
        if (!gameState.selectedTowerType) return;

        const towerConfig = TOWER_TYPES[gameState.selectedTowerType];

        if (gameState.gold < towerConfig.cost) {
            this.showMessage('Not enough gold!', 0xFF0000);
            return;
        }

        // Check if position is valid (not on path, not too close to other towers)
        if (this.isValidTowerPosition(pointer.x, pointer.y)) {
            this.placeTower(pointer.x, pointer.y, gameState.selectedTowerType);
            gameState.gold -= towerConfig.cost;
            this.updateUI();
        } else {
            this.showMessage('Invalid position!', 0xFF0000);
        }
    }

    isValidTowerPosition(x, y) {
        // Check if too close to path
        for (let i = 0; i < this.path.length - 1; i++) {
            const p1 = this.path[i];
            const p2 = this.path[i + 1];
            const dist = this.distanceToSegment(x, y, p1.x, p1.y, p2.x, p2.y);
            if (dist < 80) return false;
        }

        // Check if too close to other towers
        for (const tower of this.towers) {
            const dist = Phaser.Math.Distance.Between(x, y, tower.x, tower.y);
            if (dist < 50) return false;
        }

        return true;
    }

    distanceToSegment(px, py, x1, y1, x2, y2) {
        const dx = x2 - x1;
        const dy = y2 - y1;
        const t = Math.max(0, Math.min(1, ((px - x1) * dx + (py - y1) * dy) / (dx * dx + dy * dy)));
        const nearestX = x1 + t * dx;
        const nearestY = y1 + t * dy;
        return Math.sqrt((px - nearestX) ** 2 + (py - nearestY) ** 2);
    }

    placeTower(x, y, type) {
        const config = TOWER_TYPES[type];

        const tower = this.add.circle(x, y, 20, config.color);
        tower.setStrokeStyle(3, 0x000000);

        // Add range indicator
        const rangeCircle = this.add.circle(x, y, config.range, config.color, 0.1);
        rangeCircle.setStrokeStyle(1, config.color, 0.3);

        tower.towerData = {
            type: type,
            config: config,
            lastFired: 0,
            rangeCircle: rangeCircle,
            level: 1
        };

        this.towers.push(tower);

        // Add tower label
        this.add.text(x, y + 35, config.name.split(' ')[0], {
            fontSize: '10px',
            color: '#FFFFFF'
        }).setOrigin(0.5);
    }

    startNextWave() {
        gameState.wave++;
        this.waveActive = true;
        this.enemiesSpawned = 0;

        // Calculate wave difficulty
        this.enemiesTotal = 5 + gameState.wave * 3;

        this.showMessage(`Wave ${gameState.wave} incoming!`, 0xFFFF00);
        this.updateUI();

        // Spawn enemies over time
        this.spawnTimer = this.time.addEvent({
            delay: 1500,
            callback: () => this.spawnEnemy(),
            repeat: this.enemiesTotal - 1
        });
    }

    spawnEnemy() {
        this.enemiesSpawned++;

        // Determine enemy type based on wave
        let enemyType;
        const rand = Math.random();

        if (gameState.wave < 3) {
            enemyType = rand < 0.6 ? 'VAMPIRE' : 'WEREWOLF';
        } else if (gameState.wave < 6) {
            if (rand < 0.4) enemyType = 'VAMPIRE';
            else if (rand < 0.7) enemyType = 'WEREWOLF';
            else enemyType = 'VAMPIRE_LORD';
        } else {
            if (rand < 0.3) enemyType = 'VAMPIRE';
            else if (rand < 0.5) enemyType = 'WEREWOLF';
            else if (rand < 0.75) enemyType = 'VAMPIRE_LORD';
            else enemyType = 'ALPHA_WEREWOLF';
        }

        const config = ENEMY_TYPES[enemyType];

        const enemy = this.add.circle(this.path[0].x, this.path[0].y, 15, config.color);
        enemy.setStrokeStyle(2, 0x000000);

        enemy.enemyData = {
            type: enemyType,
            config: config,
            health: config.health,
            maxHealth: config.health,
            speed: config.speed,
            pathIndex: 0,
            slowEffect: 1.0
        };

        // Health bar
        enemy.healthBar = this.add.rectangle(enemy.x, enemy.y - 25, 30, 4, 0x00FF00);
        enemy.healthBarBg = this.add.rectangle(enemy.x, enemy.y - 25, 30, 4, 0xFF0000);

        this.enemies.push(enemy);
    }

    update(time, delta) {
        // Update enemies
        this.updateEnemies(delta);

        // Update towers
        this.updateTowers(time);

        // Update projectiles
        this.updateProjectiles(delta);

        // Check wave completion
        if (this.waveActive && this.enemiesSpawned >= this.enemiesTotal && this.enemies.length === 0) {
            this.waveActive = false;
            gameState.gold += 50;
            this.showMessage('Wave cleared! +50 gold', 0x00FF00);
            this.updateUI();

            if (gameState.wave >= 10) {
                this.scene.start('VictoryScene');
            } else {
                this.time.delayedCall(3000, () => this.startNextWave());
            }
        }

        // Update UI
        this.updateUI();
    }

    updateEnemies(delta) {
        for (let i = this.enemies.length - 1; i >= 0; i--) {
            const enemy = this.enemies[i];
            const data = enemy.enemyData;

            // Move along path
            const currentPoint = this.path[data.pathIndex];
            const nextPoint = this.path[data.pathIndex + 1];

            if (!nextPoint) {
                // Reached castle
                gameState.lives -= data.config.damage;
                this.removeEnemy(i);

                if (gameState.lives <= 0) {
                    this.scene.start('GameOverScene');
                }
                continue;
            }

            const dx = nextPoint.x - enemy.x;
            const dy = nextPoint.y - enemy.y;
            const distance = Math.sqrt(dx * dx + dy * dy);

            if (distance < 5) {
                data.pathIndex++;
            } else {
                const speed = (data.speed * data.slowEffect * delta) / 1000;
                enemy.x += (dx / distance) * speed;
                enemy.y += (dy / distance) * speed;
            }

            // Reset slow effect
            data.slowEffect = Math.min(1.0, data.slowEffect + delta / 1000);

            // Update health bar
            enemy.healthBar.x = enemy.x;
            enemy.healthBar.y = enemy.y - 25;
            enemy.healthBarBg.x = enemy.x;
            enemy.healthBarBg.y = enemy.y - 25;

            const healthPercent = data.health / data.maxHealth;
            enemy.healthBar.scaleX = healthPercent;

            // Check if dead
            if (data.health <= 0) {
                gameState.gold += data.config.reward;
                gameState.score += data.config.reward * 10;
                this.removeEnemy(i);
            }
        }
    }

    updateTowers(time) {
        for (const tower of this.towers) {
            const data = tower.towerData;

            if (time - data.lastFired < data.config.fireRate) continue;

            // Find target
            let target = null;
            let closestDist = data.config.range;

            for (const enemy of this.enemies) {
                const dist = Phaser.Math.Distance.Between(tower.x, tower.y, enemy.x, enemy.y);
                if (dist < closestDist) {
                    closestDist = dist;
                    target = enemy;
                }
            }

            if (target) {
                this.fireTower(tower, target);
                data.lastFired = time;
            }
        }
    }

    fireTower(tower, target) {
        const data = tower.towerData;

        // Create projectile
        const projectile = this.add.circle(tower.x, tower.y, 5, data.config.color);

        projectile.projectileData = {
            target: target,
            damage: data.config.damage,
            bonus: data.config.bonus || {},
            slow: data.config.slow || 0,
            speed: 300
        };

        this.projectiles.push(projectile);
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
                // Hit target
                const enemyType = data.target.enemyData.type.toLowerCase().includes('vampire') ? 'vampire' : 'werewolf';
                let damage = data.damage;

                if (data.bonus[enemyType]) {
                    damage *= data.bonus[enemyType];
                }

                data.target.enemyData.health -= damage;

                if (data.slow) {
                    data.target.enemyData.slowEffect = data.slow;
                }

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

    updateUI() {
        this.goldText.setText(`Gold: ${gameState.gold}`);
        this.livesText.setText(`Lives: ${gameState.lives}`);
        this.waveText.setText(`Wave: ${gameState.wave}`);
        this.scoreText.setText(`Score: ${gameState.score}`);
    }

    showMessage(text, color) {
        const { width, height } = this.cameras.main;
        const msg = this.add.text(width / 2, height / 2, text, {
            fontSize: '32px',
            color: '#' + color.toString(16).padStart(6, '0'),
            fontStyle: 'bold',
            stroke: '#000000',
            strokeThickness: 4
        }).setOrigin(0.5);

        this.tweens.add({
            targets: msg,
            alpha: 0,
            y: height / 2 - 50,
            duration: 2000,
            onComplete: () => msg.destroy()
        });
    }
}

// Game Over Scene
class GameOverScene extends Phaser.Scene {
    constructor() {
        super({ key: 'GameOverScene' });
    }

    create() {
        const { width, height } = this.cameras.main;

        this.add.text(width / 2, height / 3, 'GAME OVER', {
            fontSize: '64px',
            fontStyle: 'bold',
            color: '#FF0000',
            stroke: '#000000',
            strokeThickness: 6
        }).setOrigin(0.5);

        this.add.text(width / 2, height / 2, `Final Score: ${gameState.score}`, {
            fontSize: '32px',
            color: '#FFFFFF'
        }).setOrigin(0.5);

        this.add.text(width / 2, height / 2 + 50, `Waves Survived: ${gameState.wave}`, {
            fontSize: '24px',
            color: '#CCCCCC'
        }).setOrigin(0.5);

        const retryButton = this.add.rectangle(width / 2, height - 100, 200, 60, 0xFF0000)
            .setInteractive()
            .on('pointerdown', () => this.scene.start('MenuScene'));

        this.add.text(width / 2, height - 100, 'RETRY', {
            fontSize: '24px',
            fontStyle: 'bold',
            color: '#FFFFFF'
        }).setOrigin(0.5);

        retryButton.on('pointerover', () => retryButton.setFillStyle(0xFF3333));
        retryButton.on('pointerout', () => retryButton.setFillStyle(0xFF0000));
    }
}

// Victory Scene
class VictoryScene extends Phaser.Scene {
    constructor() {
        super({ key: 'VictoryScene' });
    }

    create() {
        const { width, height } = this.cameras.main;

        this.add.text(width / 2, height / 3, 'VICTORY!', {
            fontSize: '64px',
            fontStyle: 'bold',
            color: '#00FF00',
            stroke: '#000000',
            strokeThickness: 6
        }).setOrigin(0.5);

        this.add.text(width / 2, height / 2 - 30, 'You defended the castle!', {
            fontSize: '28px',
            color: '#FFFFFF'
        }).setOrigin(0.5);

        this.add.text(width / 2, height / 2 + 20, `Final Score: ${gameState.score}`, {
            fontSize: '32px',
            color: '#FFD700'
        }).setOrigin(0.5);

        this.add.text(width / 2, height / 2 + 60, `Lives Remaining: ${gameState.lives}`, {
            fontSize: '24px',
            color: '#CCCCCC'
        }).setOrigin(0.5);

        const menuButton = this.add.rectangle(width / 2, height - 100, 200, 60, 0x00FF00)
            .setInteractive()
            .on('pointerdown', () => this.scene.start('MenuScene'));

        this.add.text(width / 2, height - 100, 'MENU', {
            fontSize: '24px',
            fontStyle: 'bold',
            color: '#000000'
        }).setOrigin(0.5);

        menuButton.on('pointerover', () => menuButton.setFillStyle(0x33FF33));
        menuButton.on('pointerout', () => menuButton.setFillStyle(0x00FF00));
    }
}
