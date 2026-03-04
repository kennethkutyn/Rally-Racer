import SpriteKit

enum SceneryType: CaseIterable {
    case tree, rock, bush, cactus
}

struct SceneryState {
    var type: SceneryType
    var size: CGFloat
    var isAboveRoad: Bool
}

class SceneryNode: SKNode {
    private(set) var state: SceneryState

    init(state: SceneryState) {
        self.state = state
        super.init()
        buildScenery()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func buildScenery() {
        let sz = state.size
        switch state.type {
        case .tree:
            // Trunk
            let trunk = SKShapeNode(rect: CGRect(x: -3, y: -sz * 0.3, width: 6, height: sz * 0.6))
            trunk.fillColor = UIColor(hex: "#4a2810")
            trunk.strokeColor = .clear
            addChild(trunk)

            // Canopy
            let canopy1 = SKShapeNode(circleOfRadius: sz * 0.5)
            canopy1.fillColor = UIColor(hex: "#2d6e1e")
            canopy1.strokeColor = .clear
            canopy1.position = CGPoint(x: 0, y: sz * 0.3)
            addChild(canopy1)

            let canopy2 = SKShapeNode(circleOfRadius: sz * 0.35)
            canopy2.fillColor = UIColor(hex: "#3a8a28")
            canopy2.strokeColor = .clear
            canopy2.position = CGPoint(x: -3, y: sz * 0.35)
            addChild(canopy2)

        case .rock:
            let rock1 = SKShapeNode(ellipseOf: CGSize(width: sz, height: sz * 0.7))
            rock1.fillColor = UIColor(hex: "#777777")
            rock1.strokeColor = .clear
            addChild(rock1)

            let rock2 = SKShapeNode(ellipseOf: CGSize(width: sz * 0.7, height: sz * 0.5))
            rock2.fillColor = UIColor(hex: "#888888")
            rock2.strokeColor = .clear
            rock2.position = CGPoint(x: -2, y: 2)
            addChild(rock2)

        case .bush:
            let bush1 = SKShapeNode(ellipseOf: CGSize(width: sz, height: sz * 0.7))
            bush1.fillColor = UIColor(hex: "#2a5e16")
            bush1.strokeColor = .clear
            addChild(bush1)

            let bush2 = SKShapeNode(ellipseOf: CGSize(width: sz * 0.6, height: sz * 0.5))
            bush2.fillColor = UIColor(hex: "#3a7e26")
            bush2.strokeColor = .clear
            bush2.position = CGPoint(x: sz * 0.2, y: sz * 0.1)
            addChild(bush2)

        case .cactus:
            let color = UIColor(hex: "#3a7a2a")

            // Main stem
            let stem = SKShapeNode(rect: CGRect(x: -4, y: -sz * 0.5, width: 8, height: sz))
            stem.fillColor = color
            stem.strokeColor = .clear
            addChild(stem)

            // Left arm
            let leftH = SKShapeNode(rect: CGRect(x: -16, y: sz * 0.3 - 3, width: 12, height: 6))
            leftH.fillColor = color
            leftH.strokeColor = .clear
            addChild(leftH)

            let leftV = SKShapeNode(rect: CGRect(x: -16, y: sz * 0.3, width: 6, height: 15))
            leftV.fillColor = color
            leftV.strokeColor = .clear
            addChild(leftV)

            // Right arm
            let rightH = SKShapeNode(rect: CGRect(x: 4, y: sz * 0.1 - 3, width: 10, height: 6))
            rightH.fillColor = color
            rightH.strokeColor = .clear
            addChild(rightH)

            let rightV = SKShapeNode(rect: CGRect(x: 8, y: sz * 0.1, width: 6, height: 12))
            rightV.fillColor = color
            rightV.strokeColor = .clear
            addChild(rightV)
        }
    }
}
