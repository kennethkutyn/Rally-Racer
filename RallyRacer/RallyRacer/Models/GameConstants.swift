import Foundation
import CoreGraphics

enum GameConstants {
    // MARK: - Player
    static let playerStartX: CGFloat = 150
    static let playerWidth: CGFloat = 80
    static let playerHeight: CGFloat = 40

    // MARK: - Road (fractions of scene height, in SpriteKit coords)
    // Web: roadTop = 25% from top, roadBot = 85% from top
    // SpriteKit: Y is inverted, so roadTop (visually) = 75% of height, roadBot = 15%
    static let roadTopFraction: CGFloat = 0.75
    static let roadBottomFraction: CGFloat = 0.15
    static let laneCount: Int = 4

    static func roadTop(sceneHeight h: CGFloat) -> CGFloat { h * roadTopFraction }
    static func roadBottom(sceneHeight h: CGFloat) -> CGFloat { h * roadBottomFraction }
    static func roadHeight(sceneHeight h: CGFloat) -> CGFloat {
        roadTop(sceneHeight: h) - roadBottom(sceneHeight: h)
    }

    // MARK: - Speed
    static let startSpeed: CGFloat = 3
    static let baseMaxSpeed: CGFloat = 12
    static let difficultyMaxSpeedBonus: CGFloat = 6
    static let boostSpeedAdd: CGFloat = 4
    static let accelerationRate: CGFloat = 0.08
    static let brakeRate: CGFloat = 0.12
    static let coastDeceleration: CGFloat = 0.01
    static let minCoastSpeed: CGFloat = 2
    static let minBrakeSpeed: CGFloat = 1
    static let boostSpeedIncrement: CGFloat = 0.3

    // MARK: - Vertical Movement
    static let maxVerticalSpeed: CGFloat = 5
    static let verticalAcceleration: CGFloat = 0.6
    static let verticalDeceleration: CGFloat = 0.85
    static let maxTilt: CGFloat = 1
    static let tiltAcceleration: CGFloat = 0.15
    static let tiltDeceleration: CGFloat = 0.9
    static let tiltRotationFactor: CGFloat = 0.05

    // MARK: - Scoring & Difficulty
    static let maxDifficultyScore: CGFloat = 41667
    static let speedDisplayMultiplier: CGFloat = 20

    static func difficulty(score: Int) -> CGFloat {
        min(1, CGFloat(score) / maxDifficultyScore)
    }

    static func scorePerFrame(gameSpeed: CGFloat) -> Int {
        Int(gameSpeed * 0.5)
    }

    // MARK: - Spawn
    static let baseSpawnFrames: CGFloat = 58
    static let spawnDifficultyReduction: CGFloat = 34
    static let minSpawnRate: CGFloat = 12
    static let spawnSpeedFactor: CGFloat = 1.8

    // MARK: - Swerve
    static let baseSwerveChance: CGFloat = 0.15
    static let maxSwerveChanceBonus: CGFloat = 0.45
    static let baseSwerveStrength: CGFloat = 0.3
    static let maxSwerveStrengthBonus: CGFloat = 0.8

    // MARK: - Boost
    static let maxBoost: CGFloat = 100
    static let boostConsumption: CGFloat = 0.5
    static let baseBoostRegen: CGFloat = 0.06
    static let difficultyRegenReduction: CGFloat = 0.02

    // MARK: - Trail
    static let trailMaxPoints: Int = 20

    // MARK: - Collision
    static let collisionMarginX: CGFloat = 10
    static let collisionMarginY: CGFloat = 6

    // MARK: - Obstacles
    static let obstacleBaseSpeedMin: CGFloat = 1
    static let obstacleBaseSpeedRange: CGFloat = 2
    static let obstacleDifficultySpeedBonus: CGFloat = 2
    static let obstacleScrollMultiplier: CGFloat = 2
    static let obstacleSpawnX: CGFloat = 100
    static let obstacleSpawnXVariation: CGFloat = 80
    static let obstacleRemoveX: CGFloat = -120
    static let roadMargin: CGFloat = 25

    // MARK: - Cluster
    static let clusterMinDifficulty: CGFloat = 0.15
    static let clusterChanceMultiplier: CGFloat = 0.35
    static let clusterCountMin: Int = 2
    static let clusterCountRange: Int = 2
    static let clusterXSpacing: CGFloat = 60
    static let clusterXVariation: CGFloat = 40

    // MARK: - Touch Controls
    static let joystickRadius: CGFloat = 60
    static let joystickDeadZone: CGFloat = 12
    static let joystickThumbRadius: CGFloat = 26
    static let boostButtonRadius: CGFloat = 48
    static let touchDividerFraction: CGFloat = 0.55
    static let controlBottomOffset: CGFloat = 130
    static let joystickX: CGFloat = 120
    static let boostButtonXOffset: CGFloat = 110

    // MARK: - Death
    static let deathDelaySeconds: TimeInterval = 0.8
    static let deathPlayerParticleCount: Int = 30
    static let deathPlayerSecondaryCount: Int = 20
    static let deathObstacleParticleCount: Int = 15

    // MARK: - Shake
    static let shakeDecay: CGFloat = 0.9
    static let deadShakeDecay: CGFloat = 0.92
    static let shakeAmplitude: CGFloat = 20

    // MARK: - Visual Effects
    static let speedLineThreshold: CGFloat = 8
    static let speedLineOpacityFactor: CGFloat = 0.04
    static let speedLineCount: Int = 5
    static let speedLineBaseLength: CGFloat = 30
    static let speedLineLengthMultiplier: CGFloat = 3
    static let stripeAnimSpeed: CGFloat = 3
    static let stripeDash: CGFloat = 20
    static let stripeGap: CGFloat = 20
    static let roadEdgeHeight: CGFloat = 6
    static let rumbleWidth: CGFloat = 12
    static let rumbleSegmentWidth: CGFloat = 15
    static let rumbleSpacing: CGFloat = 30

    // MARK: - Scenery
    static let sceneryInitialCount: Int = 20
    static let sceneryMinSize: CGFloat = 15
    static let scenerySizeRange: CGFloat = 25
    static let sceneryAboveRoadScrollMultiplier: CGFloat = 1.5
    static let sceneryBelowRoadScrollMultiplier: CGFloat = 2.0

    // MARK: - Exhaust
    static let exhaustMinSpeed: CGFloat = 5

    // MARK: - Obstacle Sizes
    static let carWidth: CGFloat = 70
    static let carHeight: CGFloat = 35
    static let truckWidth: CGFloat = 100
    static let truckHeight: CGFloat = 45

    // MARK: - Spark Particles
    static let sparkVelocityRange: CGFloat = 8
    static let sparkBaseLife: CGFloat = 30
    static let sparkLifeRange: CGFloat = 20
    static let sparkMaxLife: CGFloat = 50
    static let sparkBaseSize: CGFloat = 2
    static let sparkSizeRange: CGFloat = 3
    static let sparkGravity: CGFloat = 0.1
    static let sparkDeadGravity: CGFloat = 0.15
}
