import SpriteKit

class RoadNode: SKNode {
    private var roadSurface: SKSpriteNode?
    private var topEdge: SKSpriteNode?
    private var bottomEdge: SKSpriteNode?
    private var stripeDashNodes: [[SKSpriteNode]] = []  // One array of dash segments per lane
    private var rumbleNodes: [SKSpriteNode] = []
    private var stripeOffset: CGFloat = 0
    private var sceneSize: CGSize = .zero

    func setup(sceneSize: CGSize) {
        removeAllChildren()
        self.sceneSize = sceneSize

        let roadTop = GameConstants.roadTop(sceneHeight: sceneSize.height)
        let roadBot = GameConstants.roadBottom(sceneHeight: sceneSize.height)
        let roadH = roadTop - roadBot

        // Road surface gradient
        let roadTexture = GradientTextures.linear(
            colors: [
                UIColor(hex: "#444444"),
                UIColor(hex: "#555555"),
                UIColor(hex: "#444444")
            ],
            size: CGSize(width: sceneSize.width, height: roadH)
        )
        let surface = SKSpriteNode(texture: roadTexture, size: CGSize(width: sceneSize.width, height: roadH))
        surface.anchorPoint = CGPoint(x: 0, y: 0)
        surface.position = CGPoint(x: 0, y: roadBot)
        surface.zPosition = 0
        addChild(surface)
        roadSurface = surface

        // Edge lines
        let edgeH = GameConstants.roadEdgeHeight
        let top = SKSpriteNode(color: .white, size: CGSize(width: sceneSize.width, height: edgeH))
        top.anchorPoint = CGPoint(x: 0, y: 0.5)
        top.position = CGPoint(x: 0, y: roadTop)
        top.zPosition = 2
        addChild(top)
        topEdge = top

        let bot = SKSpriteNode(color: .white, size: CGSize(width: sceneSize.width, height: edgeH))
        bot.anchorPoint = CGPoint(x: 0, y: 0.5)
        bot.position = CGPoint(x: 0, y: roadBot)
        bot.zPosition = 2
        addChild(bot)
        bottomEdge = bot

        // Lane stripes (animated dash segments)
        stripeDashNodes.removeAll()
        let laneH = roadH / CGFloat(GameConstants.laneCount)
        let totalDash = GameConstants.stripeDash + GameConstants.stripeGap
        let dashCount = Int(ceil(sceneSize.width / totalDash)) + 2

        for i in 1..<GameConstants.laneCount {
            let y = roadBot + laneH * CGFloat(i)
            var laneDashes: [SKSpriteNode] = []
            for d in 0..<dashCount {
                let dash = SKSpriteNode(
                    color: UIColor.white.withAlphaComponent(0.9),
                    size: CGSize(width: GameConstants.stripeDash, height: 4)
                )
                dash.anchorPoint = CGPoint(x: 0, y: 0.5)
                dash.position = CGPoint(x: CGFloat(d) * totalDash, y: y)
                dash.zPosition = 1
                addChild(dash)
                laneDashes.append(dash)
            }
            stripeDashNodes.append(laneDashes)
        }

        // Pre-create rumble strip nodes
        setupRumbleStrips()
    }

    private func setupRumbleStrips() {
        rumbleNodes.forEach { $0.removeFromParent() }
        rumbleNodes.removeAll()

        let roadTop = GameConstants.roadTop(sceneHeight: sceneSize.height)
        let roadBot = GameConstants.roadBottom(sceneHeight: sceneSize.height)
        let count = Int(ceil(sceneSize.width / GameConstants.rumbleSpacing)) + 2

        for i in 0..<count {
            let color: UIColor = i % 2 == 0 ? UIColor(hex: "#ff0000") : .white

            // Top rumble
            let topRumble = SKSpriteNode(
                color: color,
                size: CGSize(width: GameConstants.rumbleSegmentWidth, height: GameConstants.rumbleWidth)
            )
            topRumble.anchorPoint = CGPoint(x: 0, y: 0)
            topRumble.position = CGPoint(x: CGFloat(i) * GameConstants.rumbleSpacing, y: roadTop)
            addChild(topRumble)
            rumbleNodes.append(topRumble)

            // Bottom rumble
            let botRumble = SKSpriteNode(
                color: color,
                size: CGSize(width: GameConstants.rumbleSegmentWidth, height: GameConstants.rumbleWidth)
            )
            botRumble.anchorPoint = CGPoint(x: 0, y: 1)
            botRumble.position = CGPoint(x: CGFloat(i) * GameConstants.rumbleSpacing, y: roadBot)
            addChild(botRumble)
            rumbleNodes.append(botRumble)
        }
    }

    func update(gameSpeed: CGFloat) {
        // Animate stripe dash offset
        stripeOffset += gameSpeed * GameConstants.stripeAnimSpeed
        let totalDash = GameConstants.stripeDash + GameConstants.stripeGap
        if stripeOffset > totalDash { stripeOffset -= totalDash }

        for laneDashes in stripeDashNodes {
            for (d, dash) in laneDashes.enumerated() {
                var x = CGFloat(d) * totalDash - stripeOffset
                if x < -GameConstants.stripeDash {
                    x += CGFloat(laneDashes.count) * totalDash
                }
                dash.position.x = x
            }
        }

        // Animate rumble strips
        let rumbleOffset = stripeOffset * 0.75
        let roadTop = GameConstants.roadTop(sceneHeight: sceneSize.height)
        let roadBot = GameConstants.roadBottom(sceneHeight: sceneSize.height)

        for (i, node) in rumbleNodes.enumerated() {
            let pairIndex = i / 2
            let isTop = i % 2 == 0
            var x = (CGFloat(pairIndex) * GameConstants.rumbleSpacing - rumbleOffset)
                .truncatingRemainder(dividingBy: (sceneSize.width + GameConstants.rumbleSpacing))
            if x < -GameConstants.rumbleSegmentWidth {
                x += sceneSize.width + GameConstants.rumbleSpacing
            }
            node.position.x = x
            node.position.y = isTop ? roadTop : roadBot
        }
    }

    func resize(sceneSize: CGSize) {
        setup(sceneSize: sceneSize)
    }
}
