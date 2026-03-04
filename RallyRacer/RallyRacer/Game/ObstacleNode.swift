import SpriteKit
import UIKit

enum ObstacleType: CaseIterable {
    case carRed, carBlue, carGreen, truck

    var size: CGSize {
        switch self {
        case .truck: return CGSize(width: GameConstants.truckWidth, height: GameConstants.truckHeight)
        default: return CGSize(width: GameConstants.carWidth, height: GameConstants.carHeight)
        }
    }

    var colors: (primary: String, secondary: String) {
        switch self {
        case .carRed: return ("#cc2222", "#991111")
        case .carBlue: return ("#2244cc", "#1133aa")
        case .carGreen: return ("#22aa44", "#118833")
        case .truck: return ("#8B4513", "#DAA520")
        }
    }

    static var random: ObstacleType {
        allCases.randomElement()!
    }
}

struct ObstacleState {
    var type: ObstacleType
    var speed: CGFloat
    var swerve: CGFloat
}

class ObstacleNode: SKNode {
    private(set) var state: ObstacleState
    private static var textureCache: [ObstacleType: SKTexture] = [:]

    init(state: ObstacleState) {
        self.state = state
        super.init()

        let texture = ObstacleNode.getTexture(for: state.type)
        let sprite = SKSpriteNode(texture: texture, size: state.type.size + CGSize(width: 20, height: 20))
        addChild(sprite)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private static func getTexture(for type: ObstacleType) -> SKTexture {
        if let cached = textureCache[type] { return cached }
        let texture = renderTexture(for: type)
        textureCache[type] = texture
        return texture
    }

    static func clearCache() {
        textureCache.removeAll()
    }

    private static func renderTexture(for type: ObstacleType) -> SKTexture {
        let size = type.size
        let textureSize = CGSize(width: size.width + 20, height: size.height + 20)
        let renderer = UIGraphicsImageRenderer(size: textureSize)

        let image = renderer.image { ctx in
            let c = ctx.cgContext
            let cx = textureSize.width / 2
            let cy = textureSize.height / 2
            let w = size.width
            let h = size.height
            let (primary, secondary) = type.colors

            if type == .truck {
                renderTruck(c: c, cx: cx, cy: cy, w: w, h: h)
            } else {
                renderCar(c: c, cx: cx, cy: cy, w: w, h: h, primary: primary, secondary: secondary)
            }
        }
        return SKTexture(image: image)
    }

    private static func renderCar(c: CGContext, cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat, primary: String, secondary: String) {
        // Shadow
        c.setFillColor(UIColor.black.withAlphaComponent(0.3).cgColor)
        c.fillEllipse(in: CGRect(x: cx - w / 2 + 2, y: cy + h / 2 - 4, width: w, height: 16))

        // Body
        let bodyRect = CGRect(x: cx - w / 2, y: cy - h / 2, width: w, height: h)
        c.setFillColor(UIColor(hex: primary).cgColor)
        c.addPath(UIBezierPath(roundedRect: bodyRect, cornerRadius: 6).cgPath)
        c.fillPath()

        // Cabin
        let cabinRect = CGRect(x: cx - w / 4, y: cy - h / 2 + 4, width: w / 2.5, height: h - 8)
        c.setFillColor(UIColor(hex: secondary).cgColor)
        c.addPath(UIBezierPath(roundedRect: cabinRect, cornerRadius: 3).cgPath)
        c.fillPath()

        // Windshield
        let wsRect = CGRect(x: cx + w / 5, y: cy - h / 2 + 6, width: w / 5, height: h - 12)
        c.setFillColor(UIColor(red: 0.59, green: 0.78, blue: 1, alpha: 0.7).cgColor)
        c.addPath(UIBezierPath(roundedRect: wsRect, cornerRadius: 2).cgPath)
        c.fillPath()

        // Wheels
        c.setFillColor(UIColor(hex: "#222222").cgColor)
        let whl: CGFloat = 10, whw: CGFloat = 6
        c.fill(CGRect(x: cx - w / 2 + 3, y: cy - h / 2 - 2, width: whl, height: whw))
        c.fill(CGRect(x: cx - w / 2 + 3, y: cy + h / 2 - whw + 2, width: whl, height: whw))
        c.fill(CGRect(x: cx + w / 2 - whl - 3, y: cy - h / 2 - 2, width: whl, height: whw))
        c.fill(CGRect(x: cx + w / 2 - whl - 3, y: cy + h / 2 - whw + 2, width: whl, height: whw))
    }

    private static func renderTruck(c: CGContext, cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) {
        // Shadow
        c.setFillColor(UIColor.black.withAlphaComponent(0.3).cgColor)
        c.fillEllipse(in: CGRect(x: cx - 50 + 2, y: cy + 18, width: 100, height: 16))

        // Cargo body
        let cargoRect = CGRect(x: cx - 50, y: cy - 20, width: 70, height: 40)
        c.setFillColor(UIColor(hex: "#8B4513").cgColor)
        c.addPath(UIBezierPath(roundedRect: cargoRect, cornerRadius: 4).cgPath)
        c.fillPath()

        // Cabin
        let cabRect = CGRect(x: cx + 20, y: cy - 18, width: 30, height: 36)
        c.setFillColor(UIColor(hex: "#DAA520").cgColor)
        c.addPath(UIBezierPath(roundedRect: cabRect, cornerRadius: 4).cgPath)
        c.fillPath()

        // Wheels
        c.setFillColor(UIColor(hex: "#222222").cgColor)
        c.fill(CGRect(x: cx - 45, y: cy - 24, width: 10, height: 6))
        c.fill(CGRect(x: cx - 45, y: cy + 18, width: 10, height: 6))
        c.fill(CGRect(x: cx + 35, y: cy - 24, width: 10, height: 6))
        c.fill(CGRect(x: cx + 35, y: cy + 18, width: 10, height: 6))
    }
}

private extension CGSize {
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}
