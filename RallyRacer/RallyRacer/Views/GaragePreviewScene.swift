import SpriteKit

class GaragePreviewScene: SKScene {
    private var carNode: PlayerNode?
    private var frameCount: Int = 0
    private var stripeOffset: CGFloat = 0
    private var dashNodes: [SKSpriteNode] = []
    private var pendingConfig: CarConfig?

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hex: "#1a0a2e")
        setupPreview()
    }

    func setupPreview() {
        removeAllChildren()
        dashNodes.removeAll()

        let roadY = size.height * 0.3
        let roadH = size.height * 0.5

        // Sky gradient
        let skyTex = GradientTextures.linear(
            colors: [
                UIColor(hex: "#c7442d"),
                UIColor(hex: "#4a1942"),
                UIColor(hex: "#1a0a2e")
            ],
            size: CGSize(width: size.width, height: size.height - roadY - roadH)
        )
        let sky = SKSpriteNode(texture: skyTex, size: CGSize(width: size.width, height: size.height - roadY - roadH))
        sky.anchorPoint = CGPoint(x: 0, y: 0)
        sky.position = CGPoint(x: 0, y: roadY + roadH)
        addChild(sky)

        // Road
        let roadTex = GradientTextures.linear(
            colors: [UIColor(hex: "#444"), UIColor(hex: "#555"), UIColor(hex: "#444")],
            size: CGSize(width: size.width, height: roadH)
        )
        let road = SKSpriteNode(texture: roadTex, size: CGSize(width: size.width, height: roadH))
        road.anchorPoint = CGPoint(x: 0, y: 0)
        road.position = CGPoint(x: 0, y: roadY)
        addChild(road)

        // Road edges
        let topEdge = SKSpriteNode(color: .white, size: CGSize(width: size.width, height: 2))
        topEdge.anchorPoint = CGPoint(x: 0, y: 0.5)
        topEdge.position = CGPoint(x: 0, y: roadY + roadH)
        addChild(topEdge)

        let botEdge = SKSpriteNode(color: .white, size: CGSize(width: size.width, height: 2))
        botEdge.anchorPoint = CGPoint(x: 0, y: 0.5)
        botEdge.position = CGPoint(x: 0, y: roadY)
        addChild(botEdge)

        // Lane stripe dashes
        let stripeY = roadY + roadH / 2
        let dashLen: CGFloat = 12
        let gapLen: CGFloat = 12
        let total = dashLen + gapLen
        let count = Int(ceil(size.width / total)) + 2
        for i in 0..<count {
            let dash = SKSpriteNode(
                color: UIColor.white.withAlphaComponent(0.3),
                size: CGSize(width: dashLen, height: 1)
            )
            dash.anchorPoint = CGPoint(x: 0, y: 0.5)
            dash.position = CGPoint(x: CGFloat(i) * total, y: stripeY)
            addChild(dash)
            dashNodes.append(dash)
        }

        // Ground
        let ground = SKSpriteNode(color: UIColor(hex: "#5a4a2a"), size: CGSize(width: size.width, height: roadY))
        ground.anchorPoint = CGPoint(x: 0, y: 0)
        ground.position = .zero
        addChild(ground)

        // Player car
        let player = PlayerNode()
        player.position = CGPoint(x: size.width / 2, y: roadY + roadH / 2)
        player.zPosition = 10
        addChild(player)
        carNode = player

        // Apply pending or default config so car is visible immediately
        if let config = pendingConfig {
            player.configure(with: config)
        }
    }

    func updateCar(config: CarConfig) {
        pendingConfig = config
        carNode?.configure(with: config)
    }

    override func update(_ currentTime: TimeInterval) {
        frameCount += 1

        // Animate stripe dashes
        stripeOffset += 2
        let total: CGFloat = 24
        if stripeOffset > total { stripeOffset -= total }
        for (i, dash) in dashNodes.enumerated() {
            var x = CGFloat(i) * total - stripeOffset
            if x < -12 { x += CGFloat(dashNodes.count) * total }
            dash.position.x = x
        }

        // Animate car (flame always on in preview)
        carNode?.update(gameSpeed: 8, boost: 50, tilt: 0)
    }
}
