import SpriteKit

class HUDNode: SKNode {
    private let scoreLabel = SKLabelNode()
    private let speedLabel = SKLabelNode()
    private let highScoreLabel = SKLabelNode()
    private let boostBackground = SKShapeNode()
    private let boostFill = SKSpriteNode()
    private let boostLabel = SKLabelNode()

    private var boostMeterWidth: CGFloat = 150

    override init() {
        super.init()
        setupLabels()
        setupBoostMeter()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func setupLabels() {
        let fontName = "RussoOne-Regular"
        let fontSize: CGFloat = 18

        scoreLabel.fontName = fontName
        scoreLabel.fontSize = fontSize
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.text = "SCORE: 0"
        addChild(scoreLabel)

        speedLabel.fontName = fontName
        speedLabel.fontSize = fontSize
        speedLabel.fontColor = .white
        speedLabel.horizontalAlignmentMode = .center
        speedLabel.verticalAlignmentMode = .top
        speedLabel.text = "SPEED: 60 km/h"
        addChild(speedLabel)

        highScoreLabel.fontName = fontName
        highScoreLabel.fontSize = fontSize
        highScoreLabel.fontColor = .white
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.verticalAlignmentMode = .top
        highScoreLabel.text = "HIGH SCORE: 0"
        addChild(highScoreLabel)
    }

    private func setupBoostMeter() {
        // Background bar
        let bgRect = CGRect(x: 0, y: 0, width: boostMeterWidth + 4, height: 20)
        let bgShape = SKShapeNode(rect: bgRect, cornerRadius: 4)
        bgShape.fillColor = UIColor(white: 0, alpha: 0.5)
        bgShape.strokeColor = .clear
        boostBackground.addChild(bgShape)
        addChild(boostBackground)

        // Fill bar (will be resized each frame)
        boostFill.anchorPoint = CGPoint(x: 0, y: 0)
        boostFill.size = CGSize(width: boostMeterWidth, height: 16)
        boostFill.position = CGPoint(x: 2, y: 2)
        boostBackground.addChild(boostFill)
        updateBoostTexture(pct: 1.0)

        // Label above bar
        boostLabel.fontName = "Courier"
        boostLabel.fontSize = 11
        boostLabel.fontColor = .white
        boostLabel.horizontalAlignmentMode = .left
        boostLabel.verticalAlignmentMode = .bottom
        boostLabel.text = "BOOST"
        addChild(boostLabel)
    }

    private func updateBoostTexture(pct: CGFloat) {
        let width = max(1, boostMeterWidth * pct)
        let size = CGSize(width: width, height: 16)
        let tex = GradientTextures.linear(
            colors: [UIColor(hex: "#ff6600"), UIColor(hex: "#ffcc00")],
            size: size,
            direction: .horizontal
        )
        boostFill.texture = tex
        boostFill.size = size
    }

    func layout(sceneSize: CGSize) {
        let pad: CGFloat = 20
        let topY = sceneSize.height - pad

        // Score (top-left)
        scoreLabel.position = CGPoint(x: pad + 50, y: topY)

        // Speed (top-center)
        speedLabel.position = CGPoint(x: sceneSize.width / 2, y: topY)

        // High score (top-right)
        highScoreLabel.position = CGPoint(x: sceneSize.width - pad - 10, y: topY)

        // Boost meter (bottom-left)
        boostBackground.position = CGPoint(x: pad, y: pad + 18)
        boostLabel.position = CGPoint(x: pad, y: pad + 42)
    }

    func update(score: Int, speed: CGFloat, highScore: Int, boost: CGFloat) {
        scoreLabel.text = "SCORE: \(formatNumber(score))"
        speedLabel.text = "SPEED: \(Int(speed * GameConstants.speedDisplayMultiplier)) km/h"
        highScoreLabel.text = "High Score: \(formatNumber(highScore))"

        let pct = max(0, min(1, boost / GameConstants.maxBoost))
        updateBoostTexture(pct: pct)
    }

    private func formatNumber(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: n)) ?? "\(n)"
    }
}
