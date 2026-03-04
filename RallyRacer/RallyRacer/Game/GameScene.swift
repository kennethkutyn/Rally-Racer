import SpriteKit
import UIKit

class GameScene: SKScene {
    // MARK: - Layers
    private let backgroundLayer = SKNode()
    private let sceneryBackLayer = SKNode()
    private let roadLayer = SKNode()
    private let sceneryFrontLayer = SKNode()
    private let trailLayer = SKNode()
    private let obstacleLayer = SKNode()
    private let playerLayer = SKNode()
    private let effectsLayer = SKNode()
    private let hudLayer = SKNode()
    private let touchControlLayer = SKNode()

    // MARK: - Nodes
    private let backgroundNode = BackgroundNode()
    private let roadNode = RoadNode()
    private let playerNode = PlayerNode()
    private let hudNode = HUDNode()
    private let touchControls = TouchControlNode()

    // MARK: - State
    weak var appState: AppState?

    private var gameSpeed: CGFloat = GameConstants.startSpeed
    private var maxSpeed: CGFloat = GameConstants.baseMaxSpeed
    private var score: Int = 0
    private var playerY: CGFloat = 0
    private var playerVY: CGFloat = 0
    private var playerTilt: CGFloat = 0
    private var playerBoost: CGFloat = 0
    private var isPlaying: Bool = false
    private var isDead: Bool = false
    private var spawnTimer: CGFloat = 0

    // Trail
    private var trailPoints: [CGPoint] = []
    private var trailLineTop: SKShapeNode?
    private var trailLineBot: SKShapeNode?

    // Shake
    private var shakeX: CGFloat = 0
    private var shakeY: CGFloat = 0

    // Scenery
    private var sceneryNodes: [(node: SceneryNode, isAboveRoad: Bool)] = []

    // Obstacles
    private var obstacleNodes: [ObstacleNode] = []

    // Sparks
    private struct Spark {
        var node: SKShapeNode
        var vx: CGFloat
        var vy: CGFloat
        var life: CGFloat
        var maxLife: CGFloat
    }
    private var sparks: [Spark] = []

    // Speed lines
    private var speedLines: [SKShapeNode] = []

    // MARK: - Scene Setup

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hex: "#111111")
        setupLayers()
        setupScene()
    }

    private func setupLayers() {
        let layers: [(SKNode, CGFloat)] = [
            (backgroundLayer, 0),
            (sceneryBackLayer, 1),
            (roadLayer, 2),
            (sceneryFrontLayer, 3),
            (trailLayer, 4),
            (obstacleLayer, 5),
            (playerLayer, 6),
            (effectsLayer, 7),
            (hudLayer, 8),
            (touchControlLayer, 9),
        ]

        for (layer, z) in layers {
            layer.zPosition = z
            addChild(layer)
        }
    }

    private func setupScene() {
        backgroundNode.setup(sceneSize: size)
        backgroundLayer.addChild(backgroundNode)

        roadNode.setup(sceneSize: size)
        roadLayer.addChild(roadNode)

        playerLayer.addChild(playerNode)

        hudNode.layout(sceneSize: size)
        hudLayer.addChild(hudNode)
        hudNode.isHidden = true

        touchControls.layout(sceneSize: size)
        touchControlLayer.addChild(touchControls)
        touchControls.isHidden = true

        // Trail lines
        let topLine = SKShapeNode()
        topLine.strokeColor = UIColor(red: 1, green: 0.59, blue: 0, alpha: 0.15)
        topLine.lineWidth = 3
        trailLayer.addChild(topLine)
        trailLineTop = topLine

        let botLine = SKShapeNode()
        botLine.strokeColor = UIColor(red: 1, green: 0.59, blue: 0, alpha: 0.15)
        botLine.lineWidth = 3
        trailLayer.addChild(botLine)
        trailLineBot = botLine
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard size.width > 0 && size.height > 0 else { return }
        backgroundNode.resize(sceneSize: size)
        roadNode.resize(sceneSize: size)
        hudNode.layout(sceneSize: size)
        touchControls.layout(sceneSize: size)
    }

    // MARK: - Game Lifecycle

    func startGame(carConfig: CarConfig) {
        gameSpeed = GameConstants.startSpeed
        maxSpeed = GameConstants.baseMaxSpeed
        score = 0
        playerVY = 0
        playerTilt = 0
        playerBoost = 0
        isPlaying = true
        isDead = false
        spawnTimer = 0
        shakeX = 0
        shakeY = 0
        trailPoints.removeAll()

        // Clear old nodes
        obstacleNodes.forEach { $0.removeFromParent() }
        obstacleNodes.removeAll()
        sceneryNodes.forEach { $0.node.removeFromParent() }
        sceneryNodes.removeAll()
        sparks.forEach { $0.node.removeFromParent() }
        sparks.removeAll()
        speedLines.forEach { $0.removeFromParent() }
        speedLines.removeAll()

        // Position player
        let roadTop = GameConstants.roadTop(sceneHeight: size.height)
        let roadBot = GameConstants.roadBottom(sceneHeight: size.height)
        playerY = roadBot + (roadTop - roadBot) * 0.5
        playerNode.position = CGPoint(x: GameConstants.playerStartX, y: playerY)
        playerNode.configure(with: carConfig)
        playerNode.isHidden = false
        playerNode.zRotation = 0

        // Pre-populate scenery
        for _ in 0..<GameConstants.sceneryInitialCount {
            spawnScenery(x: CGFloat.random(in: 0...size.width))
        }

        hudNode.isHidden = false
        touchControls.isHidden = false
    }

    // MARK: - Update Loop

    override func update(_ currentTime: TimeInterval) {
        guard isPlaying else {
            // Keep sparks animating after death
            if isDead {
                updateSparks(isDead: true)
                shakeX *= GameConstants.deadShakeDecay
                shakeY *= GameConstants.deadShakeDecay
                applyShake()
            }
            return
        }

        let input = touchControls.input

        // Acceleration / braking
        if input.accelerate {
            gameSpeed = min(maxSpeed, gameSpeed + GameConstants.accelerationRate)
        } else if input.brake {
            gameSpeed = max(GameConstants.minBrakeSpeed, gameSpeed - GameConstants.brakeRate)
        } else {
            gameSpeed = max(GameConstants.minCoastSpeed, gameSpeed - GameConstants.coastDeceleration)
        }

        // Vertical movement
        if input.moveUp {
            playerVY = min(GameConstants.maxVerticalSpeed, playerVY + GameConstants.verticalAcceleration)
            playerTilt = max(-GameConstants.maxTilt, playerTilt - GameConstants.tiltAcceleration)
        } else if input.moveDown {
            playerVY = max(-GameConstants.maxVerticalSpeed, playerVY - GameConstants.verticalAcceleration)
            playerTilt = min(GameConstants.maxTilt, playerTilt + GameConstants.tiltAcceleration)
        } else {
            playerVY *= GameConstants.verticalDeceleration
            playerTilt *= GameConstants.tiltDeceleration
        }

        // Boost
        if input.boostDown && playerBoost > 0 {
            gameSpeed = min(maxSpeed + GameConstants.boostSpeedAdd, gameSpeed + GameConstants.boostSpeedIncrement)
            playerBoost -= GameConstants.boostConsumption
        }

        // Apply vertical movement
        playerY += playerVY
        let roadTop = GameConstants.roadTop(sceneHeight: size.height)
        let roadBot = GameConstants.roadBottom(sceneHeight: size.height)
        let halfH = GameConstants.playerHeight / 2 + 5
        playerY = max(roadBot + halfH, min(roadTop - halfH, playerY))
        playerNode.position = CGPoint(x: GameConstants.playerStartX, y: playerY)

        // Trail
        trailPoints.append(CGPoint(x: GameConstants.playerStartX - GameConstants.playerWidth / 2, y: playerY))
        if trailPoints.count > GameConstants.trailMaxPoints {
            trailPoints.removeFirst()
        }
        updateTrail()

        // Score
        score += GameConstants.scorePerFrame(gameSpeed: gameSpeed)
        let highScore = appState?.highScore ?? 0

        // Difficulty ramp
        let d = GameConstants.difficulty(score: score)
        maxSpeed = GameConstants.baseMaxSpeed + d * GameConstants.difficultyMaxSpeedBonus

        // Boost regen
        playerBoost = min(GameConstants.maxBoost, playerBoost + (GameConstants.baseBoostRegen - d * GameConstants.difficultyRegenReduction))

        // Spawn obstacles
        let baseSpawn = GameConstants.baseSpawnFrames - d * GameConstants.spawnDifficultyReduction
        let spawnRate = max(GameConstants.minSpawnRate, baseSpawn - gameSpeed * GameConstants.spawnSpeedFactor)
        spawnTimer += 1
        if spawnTimer >= spawnRate {
            spawnTimer = 0
            if d > GameConstants.clusterMinDifficulty && CGFloat.random(in: 0...1) < d * GameConstants.clusterChanceMultiplier {
                spawnCluster()
            } else {
                spawnObstacle()
            }
        }

        // Update obstacles
        updateObstacles()

        // Update scenery
        updateScenery()

        // Update road animation
        roadNode.update(gameSpeed: gameSpeed)

        // Update player animation
        playerNode.update(gameSpeed: gameSpeed, boost: input.boostDown ? playerBoost : 0, tilt: playerTilt)

        // Speed lines
        updateSpeedLines()

        // Update sparks
        updateSparks(isDead: false)

        // Shake decay
        shakeX *= GameConstants.shakeDecay
        shakeY *= GameConstants.shakeDecay
        applyShake()

        // Update HUD
        hudNode.update(score: score, speed: gameSpeed, highScore: max(highScore, score), boost: playerBoost)
    }

    // MARK: - Trail

    private func updateTrail() {
        guard trailPoints.count > 1, isPlaying else {
            trailLineTop?.path = nil
            trailLineBot?.path = nil
            return
        }
        let hq = GameConstants.playerHeight / 4

        let topPath = CGMutablePath()
        topPath.move(to: CGPoint(x: trailPoints[0].x, y: trailPoints[0].y + hq))
        for pt in trailPoints {
            topPath.addLine(to: CGPoint(x: pt.x, y: pt.y + hq))
        }
        trailLineTop?.path = topPath

        let botPath = CGMutablePath()
        botPath.move(to: CGPoint(x: trailPoints[0].x, y: trailPoints[0].y - hq))
        for pt in trailPoints {
            botPath.addLine(to: CGPoint(x: pt.x, y: pt.y - hq))
        }
        trailLineBot?.path = botPath
    }

    // MARK: - Obstacles

    private func spawnObstacle() {
        let d = GameConstants.difficulty(score: score)
        let roadTop = GameConstants.roadTop(sceneHeight: size.height)
        let roadBot = GameConstants.roadBottom(sceneHeight: size.height)
        let margin = GameConstants.roadMargin
        let minY = roadBot + margin
        let maxY = roadTop - margin
        let y = CGFloat.random(in: minY...maxY)

        let type = ObstacleType.random
        let baseSpeed = GameConstants.obstacleBaseSpeedMin + CGFloat.random(in: 0...GameConstants.obstacleBaseSpeedRange)
        let speedBonus = d * GameConstants.obstacleDifficultySpeedBonus

        let swerveChance = GameConstants.baseSwerveChance + d * GameConstants.maxSwerveChanceBonus
        let swerveStrength = GameConstants.baseSwerveStrength + d * GameConstants.maxSwerveStrengthBonus
        var swerve: CGFloat = 0
        if CGFloat.random(in: 0...1) < swerveChance {
            swerve = (CGFloat.random(in: 0...1) - 0.5) * swerveStrength
        }

        let state = ObstacleState(type: type, speed: baseSpeed + speedBonus, swerve: swerve)
        let node = ObstacleNode(state: state)
        node.position = CGPoint(
            x: size.width + GameConstants.obstacleSpawnX + CGFloat.random(in: 0...GameConstants.obstacleSpawnXVariation),
            y: y
        )
        obstacleLayer.addChild(node)
        obstacleNodes.append(node)
    }

    private func spawnCluster() {
        let roadTop = GameConstants.roadTop(sceneHeight: size.height)
        let roadBot = GameConstants.roadBottom(sceneHeight: size.height)
        let roadH = roadTop - roadBot
        let baseY = roadBot + 30 + CGFloat.random(in: 0...(roadH - 60))
        let count = GameConstants.clusterCountMin + Int.random(in: 0..<GameConstants.clusterCountRange)
        let laneH = roadH / CGFloat(GameConstants.laneCount)

        for i in 0..<count {
            let d = GameConstants.difficulty(score: score)
            let type = ObstacleType.random
            let baseSpeed = GameConstants.obstacleBaseSpeedMin + CGFloat.random(in: 0...GameConstants.obstacleBaseSpeedRange)
            let speedBonus = d * GameConstants.obstacleDifficultySpeedBonus

            let state = ObstacleState(type: type, speed: baseSpeed + speedBonus, swerve: 0)
            let node = ObstacleNode(state: state)

            let x = size.width + GameConstants.obstacleSpawnX + CGFloat(i) * (GameConstants.clusterXSpacing + CGFloat.random(in: 0...GameConstants.clusterXVariation))
            let yOffset = (CGFloat(i) - 1) * laneH * (0.6 + CGFloat.random(in: 0...0.8))
            let y = max(roadBot + GameConstants.roadMargin, min(roadTop - GameConstants.roadMargin, baseY + yOffset))

            node.position = CGPoint(x: x, y: y)
            obstacleLayer.addChild(node)
            obstacleNodes.append(node)
        }
    }

    private func updateObstacles() {
        let roadTop = GameConstants.roadTop(sceneHeight: size.height)
        let roadBot = GameConstants.roadBottom(sceneHeight: size.height)

        for i in stride(from: obstacleNodes.count - 1, through: 0, by: -1) {
            let node = obstacleNodes[i]
            node.position.x -= gameSpeed * GameConstants.obstacleScrollMultiplier + node.state.speed
            node.position.y += node.state.swerve

            let halfH = node.state.type.size.height / 2
            node.position.y = max(roadBot + halfH, min(roadTop - halfH, node.position.y))

            if node.position.x < GameConstants.obstacleRemoveX {
                node.removeFromParent()
                obstacleNodes.remove(at: i)
                continue
            }

            // Collision detection
            let dx = abs(GameConstants.playerStartX - node.position.x)
            let dy = abs(playerY - node.position.y)
            let hw = (GameConstants.playerWidth + node.state.type.size.width) / 2 - GameConstants.collisionMarginX
            let hh = (GameConstants.playerHeight + node.state.type.size.height) / 2 - GameConstants.collisionMarginY

            if dx < hw && dy < hh {
                die(hitObstacle: node)
                return
            }
        }
    }

    // MARK: - Scenery

    private func spawnScenery(x: CGFloat) {
        let isAboveRoad = Bool.random()
        let roadTop = GameConstants.roadTop(sceneHeight: size.height)
        let roadBot = GameConstants.roadBottom(sceneHeight: size.height)

        let y: CGFloat
        if isAboveRoad {
            y = roadTop + 2 + CGFloat.random(in: 0...22)
        } else {
            y = roadBot - 20 - CGFloat.random(in: 0...80)
        }

        let type = SceneryType.allCases.randomElement()!
        let sz = GameConstants.sceneryMinSize + CGFloat.random(in: 0...GameConstants.scenerySizeRange)
        let state = SceneryState(type: type, size: sz, isAboveRoad: isAboveRoad)
        let node = SceneryNode(state: state)
        node.position = CGPoint(x: x, y: y)

        if isAboveRoad {
            sceneryBackLayer.addChild(node)
        } else {
            sceneryFrontLayer.addChild(node)
        }
        sceneryNodes.append((node: node, isAboveRoad: isAboveRoad))
    }

    private func updateScenery() {
        for i in stride(from: sceneryNodes.count - 1, through: 0, by: -1) {
            let entry = sceneryNodes[i]
            let multiplier = entry.isAboveRoad
                ? GameConstants.sceneryAboveRoadScrollMultiplier
                : GameConstants.sceneryBelowRoadScrollMultiplier
            entry.node.position.x -= gameSpeed * multiplier

            if entry.node.position.x < -50 {
                entry.node.removeFromParent()
                sceneryNodes.remove(at: i)
                spawnScenery(x: size.width + 50 + CGFloat.random(in: 0...100))
            }
        }
    }

    // MARK: - Death

    private func die(hitObstacle: ObstacleNode) {
        isPlaying = false
        isDead = true
        playerNode.isHidden = true
        hudNode.isHidden = true
        touchControls.isHidden = true
        trailLineTop?.path = nil
        trailLineBot?.path = nil

        // Spawn particles
        spawnSparks(at: playerNode.position, count: GameConstants.deathPlayerParticleCount, color: "#ff4400")
        spawnSparks(at: playerNode.position, count: GameConstants.deathPlayerSecondaryCount, color: "#ffcc00")
        spawnSparks(at: hitObstacle.position, count: GameConstants.deathObstacleParticleCount, color: "#ff8800")

        // Screen shake
        shakeX = (CGFloat.random(in: 0...1) - 0.5) * GameConstants.shakeAmplitude
        shakeY = (CGFloat.random(in: 0...1) - 0.5) * GameConstants.shakeAmplitude

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        // Notify AppState
        appState?.endGame(score: score)
    }

    // MARK: - Sparks

    private func spawnSparks(at position: CGPoint, count: Int, color: String) {
        for _ in 0..<count {
            let spark = SKShapeNode(circleOfRadius: GameConstants.sparkBaseSize + CGFloat.random(in: 0...GameConstants.sparkSizeRange))
            spark.fillColor = UIColor(hex: color)
            spark.strokeColor = .clear
            spark.position = position
            effectsLayer.addChild(spark)

            let vx = (CGFloat.random(in: 0...1) - 0.5) * GameConstants.sparkVelocityRange
            let vy = (CGFloat.random(in: 0...1) - 0.5) * GameConstants.sparkVelocityRange
            let life = GameConstants.sparkBaseLife + CGFloat.random(in: 0...GameConstants.sparkLifeRange)

            sparks.append(Spark(node: spark, vx: vx, vy: vy, life: life, maxLife: life))
        }
    }

    private func updateSparks(isDead: Bool) {
        let gravity = isDead ? GameConstants.sparkDeadGravity : GameConstants.sparkGravity
        for i in stride(from: sparks.count - 1, through: 0, by: -1) {
            var s = sparks[i]
            s.node.position.x += s.vx
            s.node.position.y += s.vy
            s.life -= 1
            s.vy -= gravity
            sparks[i] = s

            let alpha = max(0, s.life / s.maxLife)
            s.node.alpha = alpha
            let scale = alpha
            s.node.setScale(scale)

            if s.life <= 0 {
                s.node.removeFromParent()
                sparks.remove(at: i)
            }
        }
    }

    // MARK: - Speed Lines

    private func updateSpeedLines() {
        // Remove old
        speedLines.forEach { $0.removeFromParent() }
        speedLines.removeAll()

        guard gameSpeed > GameConstants.speedLineThreshold, isPlaying else { return }

        let roadTop = GameConstants.roadTop(sceneHeight: size.height)
        let roadBot = GameConstants.roadBottom(sceneHeight: size.height)
        let roadH = roadTop - roadBot
        let alpha = (gameSpeed - GameConstants.speedLineThreshold) * GameConstants.speedLineOpacityFactor

        for _ in 0..<GameConstants.speedLineCount {
            let ly = roadBot + CGFloat.random(in: 0...roadH)
            let lx = CGFloat.random(in: 0...size.width)
            let lineLen = GameConstants.speedLineBaseLength + gameSpeed * GameConstants.speedLineLengthMultiplier

            let path = CGMutablePath()
            path.move(to: CGPoint(x: lx, y: ly))
            path.addLine(to: CGPoint(x: lx - lineLen, y: ly))

            let line = SKShapeNode(path: path)
            line.strokeColor = UIColor.white.withAlphaComponent(min(1, alpha))
            line.lineWidth = 1
            effectsLayer.addChild(line)
            speedLines.append(line)
        }
    }

    // MARK: - Shake

    private func applyShake() {
        let nodes: [SKNode] = [backgroundLayer, sceneryBackLayer, roadLayer, sceneryFrontLayer,
                               trailLayer, obstacleLayer, playerLayer, effectsLayer]
        for node in nodes {
            node.position = CGPoint(x: shakeX, y: shakeY)
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isPlaying else { return }
        for touch in touches {
            let location = touch.location(in: self)
            touchControls.handleTouchBegan(touch, location: location, sceneSize: size)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isPlaying else { return }
        for touch in touches {
            let location = touch.location(in: self)
            touchControls.handleTouchMoved(touch, location: location)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchControls.handleTouchEnded(touch)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchControls.handleTouchEnded(touch)
        }
    }
}
