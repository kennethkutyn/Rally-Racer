import SpriteKit

struct TouchInput {
    var stickDx: CGFloat = 0
    var stickDy: CGFloat = 0
    var stickActive: Bool = false
    var boostDown: Bool = false

    var moveUp: Bool { stickDy > GameConstants.joystickDeadZone }
    var moveDown: Bool { stickDy < -GameConstants.joystickDeadZone }
    var accelerate: Bool { stickDx > GameConstants.joystickDeadZone }
    var brake: Bool { stickDx < -GameConstants.joystickDeadZone }
}

class TouchControlNode: SKNode {
    private let joystickBase = SKShapeNode()
    private let joystickThumb = SKShapeNode()
    private let boostButton = SKShapeNode()
    private let boostRing = SKShapeNode()
    private let boostText = SKLabelNode()

    private var joystickCenter: CGPoint = .zero
    private var boostCenter: CGPoint = .zero

    private var joystickTouchID: UITouch?
    private var boostTouchID: UITouch?

    private(set) var input = TouchInput()

    override init() {
        super.init()
        isUserInteractionEnabled = false
        buildJoystick()
        buildBoostButton()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func buildJoystick() {
        let radius = GameConstants.joystickRadius

        // Base circle
        let base = SKShapeNode(circleOfRadius: radius)
        base.fillColor = UIColor(white: 1, alpha: 0.2)
        base.strokeColor = UIColor(white: 1, alpha: 0.35)
        base.lineWidth = 2
        joystickBase.addChild(base)
        addChild(joystickBase)

        // Thumb circle
        let thumb = SKShapeNode(circleOfRadius: GameConstants.joystickThumbRadius)
        thumb.fillColor = UIColor(white: 1, alpha: 0.45)
        thumb.strokeColor = .clear
        joystickThumb.addChild(thumb)
        addChild(joystickThumb)
    }

    private func buildBoostButton() {
        let radius = GameConstants.boostButtonRadius

        // Fill
        let fill = SKShapeNode(circleOfRadius: radius)
        fill.fillColor = UIColor(white: 1, alpha: 0.2)
        fill.strokeColor = .clear
        boostButton.addChild(fill)
        addChild(boostButton)

        // Ring
        let ring = SKShapeNode(circleOfRadius: radius)
        ring.fillColor = .clear
        ring.strokeColor = UIColor(white: 1, alpha: 0.35)
        ring.lineWidth = 2
        boostRing.addChild(ring)
        addChild(boostRing)

        // Label
        boostText.fontName = "RussoOne-Regular"
        boostText.fontSize = 14
        boostText.fontColor = UIColor(white: 1, alpha: 0.5)
        boostText.horizontalAlignmentMode = .center
        boostText.verticalAlignmentMode = .center
        boostText.text = "BOOST"
        addChild(boostText)
    }

    func layout(sceneSize: CGSize) {
        let bottomY = GameConstants.controlBottomOffset
        joystickCenter = CGPoint(x: GameConstants.joystickX, y: bottomY)
        boostCenter = CGPoint(x: sceneSize.width - GameConstants.boostButtonXOffset, y: bottomY)

        joystickBase.position = joystickCenter
        joystickThumb.position = joystickCenter
        boostButton.position = boostCenter
        boostRing.position = boostCenter
        boostText.position = boostCenter
    }

    // MARK: - Touch handling (called from GameScene)

    func handleTouchBegan(_ touch: UITouch, location: CGPoint, sceneSize: CGSize) {
        let divider = sceneSize.width * GameConstants.touchDividerFraction

        if location.x < divider {
            // Joystick area
            joystickTouchID = touch
            input.stickActive = true
            updateJoystick(location: location)
        } else {
            // Boost area
            let dist = hypot(location.x - boostCenter.x, location.y - boostCenter.y)
            if dist < GameConstants.boostButtonRadius * 1.5 {
                boostTouchID = touch
                input.boostDown = true
                updateBoostVisual()
            }
        }
    }

    func handleTouchMoved(_ touch: UITouch, location: CGPoint) {
        if touch === joystickTouchID {
            updateJoystick(location: location)
        }
    }

    func handleTouchEnded(_ touch: UITouch) {
        if touch === joystickTouchID {
            joystickTouchID = nil
            input.stickActive = false
            input.stickDx = 0
            input.stickDy = 0
            joystickThumb.position = joystickCenter
        }
        if touch === boostTouchID {
            boostTouchID = nil
            input.boostDown = false
            updateBoostVisual()
        }
    }

    private func updateJoystick(location: CGPoint) {
        let dx = location.x - joystickCenter.x
        let dy = location.y - joystickCenter.y
        let dist = hypot(dx, dy)
        let maxDist = GameConstants.joystickRadius

        if dist > maxDist {
            let scale = maxDist / dist
            input.stickDx = dx * scale
            input.stickDy = dy * scale
        } else {
            input.stickDx = dx
            input.stickDy = dy
        }

        joystickThumb.position = CGPoint(
            x: joystickCenter.x + input.stickDx,
            y: joystickCenter.y + input.stickDy
        )
    }

    private func updateBoostVisual() {
        if input.boostDown {
            boostButton.children.first?.run(SKAction.fadeAlpha(to: 0.4, duration: 0.05))
            if let fill = boostButton.children.first as? SKShapeNode {
                fill.fillColor = UIColor(hex: "#ff8800").withAlphaComponent(0.4)
            }
            boostRing.children.first?.run(SKAction.fadeAlpha(to: 0.6, duration: 0.05))
            if let ring = boostRing.children.first as? SKShapeNode {
                ring.strokeColor = UIColor(hex: "#ffcc00").withAlphaComponent(0.6)
            }
            boostText.alpha = 0.9
        } else {
            if let fill = boostButton.children.first as? SKShapeNode {
                fill.fillColor = UIColor(white: 1, alpha: 0.2)
            }
            boostButton.children.first?.alpha = 1
            if let ring = boostRing.children.first as? SKShapeNode {
                ring.strokeColor = UIColor(white: 1, alpha: 0.35)
            }
            boostRing.children.first?.alpha = 1
            boostText.alpha = 0.5
        }
    }
}
