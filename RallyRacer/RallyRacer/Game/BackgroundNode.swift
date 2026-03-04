import SpriteKit

class BackgroundNode: SKNode {
    private var skySprite: SKSpriteNode?
    private var sunNode: SKShapeNode?
    private var sunGlowSprite: SKSpriteNode?
    private var mountainShape: SKShapeNode?
    private var groundSprite: SKSpriteNode?

    func setup(sceneSize: CGSize) {
        removeAllChildren()
        let roadTop = GameConstants.roadTop(sceneHeight: sceneSize.height)

        // Sky gradient (from roadTop to top of screen)
        let skyHeight = sceneSize.height - roadTop
        let skyTexture = GradientTextures.linear(
            colors: [
                UIColor(hex: "#c7442d"),  // bottom of sky (near road)
                UIColor(hex: "#4a1942"),  // middle
                UIColor(hex: "#1a0a2e")   // top
            ],
            size: CGSize(width: sceneSize.width, height: skyHeight)
        )
        let sky = SKSpriteNode(texture: skyTexture, size: CGSize(width: sceneSize.width, height: skyHeight))
        sky.anchorPoint = CGPoint(x: 0, y: 0)
        sky.position = CGPoint(x: 0, y: roadTop)
        addChild(sky)
        skySprite = sky

        // Sun
        let sunX = sceneSize.width * 0.75
        let sunY = roadTop + skyHeight * 0.5

        let glowSize = CGSize(width: 240, height: 240)
        let glowTexture = GradientTextures.radial(
            colors: [
                UIColor(red: 1, green: 0.78, blue: 0.2, alpha: 0.8),
                UIColor(red: 1, green: 0.59, blue: 0.2, alpha: 0.3),
                UIColor(red: 1, green: 0.39, blue: 0.2, alpha: 0)
            ],
            size: glowSize
        )
        let glow = SKSpriteNode(texture: glowTexture, size: glowSize)
        glow.position = CGPoint(x: sunX, y: sunY)
        glow.blendMode = .add
        addChild(glow)
        sunGlowSprite = glow

        let sun = SKShapeNode(circleOfRadius: 30)
        sun.fillColor = UIColor(hex: "#ffcc44")
        sun.strokeColor = .clear
        sun.position = CGPoint(x: sunX, y: sunY)
        addChild(sun)
        sunNode = sun

        // Mountains
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: roadTop))
        for x in stride(from: 0, through: sceneSize.width, by: 10) {
            let mh = 20 + sin(x * 0.008) * 40 + sin(x * 0.015) * 25
            path.addLine(to: CGPoint(x: x, y: roadTop + mh))
        }
        path.addLine(to: CGPoint(x: sceneSize.width, y: roadTop))
        path.closeSubpath()

        let mountain = SKShapeNode(path: path)
        mountain.fillColor = UIColor(hex: "#2a1a3a")
        mountain.strokeColor = .clear
        addChild(mountain)
        mountainShape = mountain

        // Ground below road
        let roadBottom = GameConstants.roadBottom(sceneHeight: sceneSize.height)
        let ground = SKSpriteNode(
            color: UIColor(hex: "#5a4a2a"),
            size: CGSize(width: sceneSize.width, height: roadBottom)
        )
        ground.anchorPoint = CGPoint(x: 0, y: 0)
        ground.position = CGPoint(x: 0, y: 0)
        addChild(ground)
        groundSprite = ground
    }

    func resize(sceneSize: CGSize) {
        setup(sceneSize: sceneSize)
    }
}
