import SpriteKit
import UIKit

enum GradientDirection {
    case vertical
    case horizontal
}

enum GradientTextures {
    static func linear(
        colors: [UIColor],
        locations: [CGFloat]? = nil,
        size: CGSize,
        direction: GradientDirection = .vertical
    ) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cgCtx = ctx.cgContext
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let cgColors = colors.map { $0.cgColor } as CFArray
            let locs = locations ?? colors.enumerated().map { CGFloat($0.offset) / CGFloat(colors.count - 1) }

            guard let gradient = CGGradient(
                colorsSpace: colorSpace,
                colors: cgColors,
                locations: locs
            ) else { return }

            let start: CGPoint
            let end: CGPoint
            switch direction {
            case .vertical:
                start = CGPoint(x: size.width / 2, y: 0)
                end = CGPoint(x: size.width / 2, y: size.height)
            case .horizontal:
                start = CGPoint(x: 0, y: size.height / 2)
                end = CGPoint(x: size.width, y: size.height / 2)
            }

            cgCtx.drawLinearGradient(
                gradient,
                start: start,
                end: end,
                options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
            )
        }
        return SKTexture(image: image)
    }

    static func radial(
        colors: [UIColor],
        locations: [CGFloat]? = nil,
        size: CGSize,
        center: CGPoint? = nil,
        radius: CGFloat? = nil
    ) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cgCtx = ctx.cgContext
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let cgColors = colors.map { $0.cgColor } as CFArray
            let locs = locations ?? colors.enumerated().map { CGFloat($0.offset) / CGFloat(colors.count - 1) }

            guard let gradient = CGGradient(
                colorsSpace: colorSpace,
                colors: cgColors,
                locations: locs
            ) else { return }

            let c = center ?? CGPoint(x: size.width / 2, y: size.height / 2)
            let r = radius ?? max(size.width, size.height) / 2

            cgCtx.drawRadialGradient(
                gradient,
                startCenter: c,
                startRadius: 0,
                endCenter: c,
                endRadius: r,
                options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
            )
        }
        return SKTexture(image: image)
    }
}
