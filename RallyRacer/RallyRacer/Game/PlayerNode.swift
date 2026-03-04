import SpriteKit
import UIKit

class PlayerNode: SKNode {
    private var carSprite: SKSpriteNode?
    private var flameNode: SKShapeNode?
    private var innerFlameNode: SKShapeNode?
    private var exhaustNodes: [SKShapeNode] = []
    private var lightBeamNode: SKShapeNode?
    private var currentConfig: CarConfig?

    let carWidth: CGFloat = GameConstants.playerWidth
    let carHeight: CGFloat = GameConstants.playerHeight

    func configure(with config: CarConfig) {
        guard config != currentConfig else { return }
        currentConfig = config
        rebuildCar(config: config)
    }

    private func rebuildCar(config: CarConfig) {
        // Remove old sprite
        carSprite?.removeFromParent()
        lightBeamNode?.removeFromParent()
        exhaustNodes.forEach { $0.removeFromParent() }
        exhaustNodes.removeAll()

        let w = carWidth
        let h = carHeight

        // Render car body into texture
        let textureSize = CGSize(width: w + 20, height: h + 20)
        let renderer = UIGraphicsImageRenderer(size: textureSize)
        let image = renderer.image { ctx in
            let c = ctx.cgContext
            let cx = textureSize.width / 2
            let cy = textureSize.height / 2

            // Shadow
            c.setFillColor(UIColor.black.withAlphaComponent(0.3).cgColor)
            c.fillEllipse(in: CGRect(
                x: cx - w / 2 + 2,
                y: cy + h / 2 - 4,
                width: w,
                height: 16
            ))

            // Body
            let bodyRect = CGRect(x: cx - w / 2, y: cy - h / 2, width: w, height: h)
            let bodyPath = UIBezierPath(roundedRect: bodyRect, cornerRadius: 6)
            c.setFillColor(UIColor(hex: config.body).cgColor)
            c.addPath(bodyPath.cgPath)
            c.fillPath()

            // Cabin
            let cabinW = w / 2.5
            let cabinRect = CGRect(x: cx - w / 4, y: cy - h / 2 + 4, width: cabinW, height: h - 8)
            let cabinPath = UIBezierPath(roundedRect: cabinRect, cornerRadius: 3)
            c.setFillColor(UIColor(hex: config.cabin).cgColor)
            c.addPath(cabinPath.cgPath)
            c.fillPath()

            // Windshield
            let wsRect = CGRect(x: cx + w / 5, y: cy - h / 2 + 6, width: w / 5, height: h - 12)
            let wsPath = UIBezierPath(roundedRect: wsRect, cornerRadius: 2)
            c.setFillColor(UIColor(red: 0.59, green: 0.78, blue: 1, alpha: 0.7).cgColor)
            c.addPath(wsPath.cgPath)
            c.fillPath()

            // Wheels
            let wheelColor = UIColor(hex: config.wheels)
            c.setFillColor(wheelColor.cgColor)
            let whl: CGFloat = 10, whw: CGFloat = 6
            c.fill(CGRect(x: cx - w / 2 + 3, y: cy - h / 2 - 2, width: whl, height: whw))
            c.fill(CGRect(x: cx - w / 2 + 3, y: cy + h / 2 - whw + 2, width: whl, height: whw))
            c.fill(CGRect(x: cx + w / 2 - whl - 3, y: cy - h / 2 - 2, width: whl, height: whw))
            c.fill(CGRect(x: cx + w / 2 - whl - 3, y: cy + h / 2 - whw + 2, width: whl, height: whw))

            // Headlights
            let lightColor = UIColor(hex: config.lights)
            c.setFillColor(lightColor.cgColor)
            c.fillEllipse(in: CGRect(x: cx + w / 2 - 4, y: cy - h / 4 - 3, width: 8, height: 6))
            c.fillEllipse(in: CGRect(x: cx + w / 2 - 4, y: cy + h / 4 - 3, width: 8, height: 6))
        }

        let texture = SKTexture(image: image)
        let sprite = SKSpriteNode(texture: texture, size: textureSize)
        addChild(sprite)
        carSprite = sprite

        // Light beams (separate node for blending)
        let beamPath = CGMutablePath()
        beamPath.move(to: CGPoint(x: w / 2, y: h / 3))
        beamPath.addLine(to: CGPoint(x: w / 2 + 120, y: h))
        beamPath.addLine(to: CGPoint(x: w / 2 + 120, y: -h))
        beamPath.addLine(to: CGPoint(x: w / 2, y: -h / 3))
        beamPath.closeSubpath()
        let beam = SKShapeNode(path: beamPath)
        beam.fillColor = UIColor(hex: config.lights).withAlphaComponent(0.08)
        beam.strokeColor = .clear
        beam.zPosition = -1
        addChild(beam)
        lightBeamNode = beam

        // Exhaust puffs (created once, visibility toggled)
        for i in 0..<3 {
            let puff = SKShapeNode(circleOfRadius: CGFloat(3 + i * 2))
            puff.fillColor = UIColor(white: 0.78, alpha: CGFloat(0.3) - CGFloat(i) * 0.1)
            puff.strokeColor = .clear
            puff.position = CGPoint(x: -w / 2 - 8 - CGFloat(i) * 10, y: -h / 4)
            puff.isHidden = true
            addChild(puff)
            exhaustNodes.append(puff)
        }

        // Boost flame (initially hidden)
        flameNode?.removeFromParent()
        innerFlameNode?.removeFromParent()
        setupFlame(config: config)
    }

    private func setupFlame(config: CarConfig) {
        let w = carWidth
        let h = carHeight

        let flame = SKShapeNode()
        flame.strokeColor = .clear
        flame.isHidden = true
        flame.zPosition = -1
        addChild(flame)
        flameNode = flame

        let inner = SKShapeNode()
        inner.strokeColor = .clear
        inner.isHidden = true
        inner.zPosition = -1
        addChild(inner)
        innerFlameNode = inner
    }

    func update(gameSpeed: CGFloat, boost: CGFloat, tilt: CGFloat) {
        guard let config = currentConfig else { return }

        // Tilt rotation
        zRotation = -tilt * GameConstants.tiltRotationFactor

        // Exhaust visibility
        let showExhaust = gameSpeed > GameConstants.exhaustMinSpeed
        for (i, puff) in exhaustNodes.enumerated() {
            puff.isHidden = !showExhaust
            if showExhaust {
                puff.position.y = -carHeight / 4 + CGFloat.random(in: -2...2)
            }
        }

        // Flame — always visible while moving, bigger during boost
        let showFlame = gameSpeed > 1
        flameNode?.isHidden = !showFlame
        innerFlameNode?.isHidden = !showFlame

        if showFlame {
            let w = carWidth
            let h = carHeight
            let speedFraction = min(1, gameSpeed / 12)
            let boostExtra: CGFloat = boost > 0 ? 15 : 0
            let flameLen = 10 + speedFraction * 15 + boostExtra + CGFloat.random(in: 0...10)

            let path = CGMutablePath()
            path.move(to: CGPoint(x: -w / 2, y: h / 4))
            path.addLine(to: CGPoint(x: -w / 2 - flameLen, y: CGFloat.random(in: -2...2)))
            path.addLine(to: CGPoint(x: -w / 2, y: -h / 4))
            path.closeSubpath()

            flameNode?.path = path
            flameNode?.fillColor = UIColor(hex: config.flame).withAlphaComponent(0.9)

            let innerPath = CGMutablePath()
            innerPath.move(to: CGPoint(x: -w / 2, y: h / 6))
            innerPath.addLine(to: CGPoint(x: -w / 2 - flameLen * 0.45, y: CGFloat.random(in: -2...2)))
            innerPath.addLine(to: CGPoint(x: -w / 2, y: -h / 6))
            innerPath.closeSubpath()

            innerFlameNode?.path = innerPath
            innerFlameNode?.fillColor = UIColor.white.withAlphaComponent(0.6)
        }
    }
}
