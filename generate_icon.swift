#!/usr/bin/env swift
// Generates a 1024x1024 app icon for Rally Racer 2000
// Matches the game's visual style: retro sunset sky, road, BungeeShade + RussoOne fonts

import Foundation
import CoreGraphics
import CoreText
import ImageIO
import UniformTypeIdentifiers

let size = 1024
let w = CGFloat(size)
let h = CGFloat(size)

// Register custom fonts
let fontDir = "./RallyRacer/RallyRacer/Resources/Fonts"
let bungeeURL = URL(fileURLWithPath: "\(fontDir)/BungeeShade-Regular.ttf") as CFURL
let russoURL = URL(fileURLWithPath: "\(fontDir)/RussoOne-Regular.ttf") as CFURL
CTFontManagerRegisterFontsForURL(bungeeURL, .process, nil)
CTFontManagerRegisterFontsForURL(russoURL, .process, nil)

// Create bitmap context
let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(
    data: nil,
    width: size,
    height: size,
    bitsPerComponent: 8,
    bytesPerRow: size * 4,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    print("Failed to create context")
    exit(1)
}

// Helper: hex to CGColor
func hexColor(_ hex: String, alpha: CGFloat = 1.0) -> CGColor {
    let h = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
    let scanner = Scanner(string: h)
    var rgb: UInt64 = 0
    scanner.scanHexInt64(&rgb)
    let r = CGFloat((rgb >> 16) & 0xFF) / 255
    let g = CGFloat((rgb >> 8) & 0xFF) / 255
    let b = CGFloat(rgb & 0xFF) / 255
    return CGColor(red: r, green: g, blue: b, alpha: alpha)
}

// === BACKGROUND: Sky gradient (bottom to top) ===
// Match BackgroundNode: #c7442d (bottom) -> #4a1942 (mid) -> #1a0a2e (top)
let skyColors = [
    hexColor("#c7442d"),
    hexColor("#4a1942"),
    hexColor("#1a0a2e")
] as CFArray
let skyLocations: [CGFloat] = [0.0, 0.5, 1.0]
if let gradient = CGGradient(colorsSpace: colorSpace, colors: skyColors, locations: skyLocations) {
    ctx.drawLinearGradient(
        gradient,
        start: CGPoint(x: w / 2, y: 0),
        end: CGPoint(x: w / 2, y: h),
        options: []
    )
}

// === SUN (glow + circle) — upper right area ===
let sunX = w * 0.65
let sunY = h * 0.72
// Radial glow
let glowColors = [
    hexColor("#ffc833", alpha: 0.7),
    hexColor("#ff9733", alpha: 0.25),
    hexColor("#ff6333", alpha: 0.0)
] as CFArray
let glowLocations: [CGFloat] = [0.0, 0.5, 1.0]
if let glowGrad = CGGradient(colorsSpace: colorSpace, colors: glowColors, locations: glowLocations) {
    ctx.drawRadialGradient(
        glowGrad,
        startCenter: CGPoint(x: sunX, y: sunY),
        startRadius: 0,
        endCenter: CGPoint(x: sunX, y: sunY),
        endRadius: 180,
        options: []
    )
}
// Sun disc
ctx.setFillColor(hexColor("#ffcc44"))
ctx.fillEllipse(in: CGRect(x: sunX - 50, y: sunY - 50, width: 100, height: 100))

// === MOUNTAINS ===
let mountainBaseY = h * 0.38
ctx.setFillColor(hexColor("#2a1a3a"))
let mountainPath = CGMutablePath()
mountainPath.move(to: CGPoint(x: 0, y: mountainBaseY))
for x in stride(from: CGFloat(0), through: w, by: 4) {
    let mh = 30 + sin(x * 0.012) * 60 + sin(x * 0.022) * 35
    mountainPath.addLine(to: CGPoint(x: x, y: mountainBaseY + mh))
}
mountainPath.addLine(to: CGPoint(x: w, y: mountainBaseY))
mountainPath.closeSubpath()
ctx.addPath(mountainPath)
ctx.fillPath()

// === ROAD ===
let roadTop = h * 0.38
let roadBot = h * 0.08
let roadH = roadTop - roadBot

// Road surface gradient
let roadColors = [
    hexColor("#444444"),
    hexColor("#555555"),
    hexColor("#444444")
] as CFArray
let roadLocations: [CGFloat] = [0.0, 0.5, 1.0]
ctx.saveGState()
ctx.clip(to: CGRect(x: 0, y: roadBot, width: w, height: roadH))
if let roadGrad = CGGradient(colorsSpace: colorSpace, colors: roadColors, locations: roadLocations) {
    ctx.drawLinearGradient(
        roadGrad,
        start: CGPoint(x: w / 2, y: roadBot),
        end: CGPoint(x: w / 2, y: roadTop),
        options: []
    )
}
ctx.restoreGState()

// Road edge lines (white)
ctx.setFillColor(hexColor("#ffffff"))
ctx.fill(CGRect(x: 0, y: roadTop - 4, width: w, height: 6))
ctx.fill(CGRect(x: 0, y: roadBot, width: w, height: 6))

// Rumble strips (red/white alternating)
let rumbleH: CGFloat = 12
let rumbleW: CGFloat = 20
let rumbleSpacing: CGFloat = 38
for i in 0..<Int(w / rumbleSpacing) + 1 {
    let color = i % 2 == 0 ? hexColor("#ff0000") : hexColor("#ffffff")
    let x = CGFloat(i) * rumbleSpacing
    ctx.setFillColor(color)
    ctx.fill(CGRect(x: x, y: roadTop, width: rumbleW, height: rumbleH))
    ctx.fill(CGRect(x: x, y: roadBot - rumbleH, width: rumbleW, height: rumbleH))
}

// Lane stripes
let laneCount = 4
let laneH = roadH / CGFloat(laneCount)
ctx.setFillColor(hexColor("#ffffff", alpha: 0.85))
let dashW: CGFloat = 30
let dashGap: CGFloat = 25
for lane in 1..<laneCount {
    let y = roadBot + laneH * CGFloat(lane)
    var x: CGFloat = 10
    while x < w {
        ctx.fill(CGRect(x: x, y: y - 2, width: dashW, height: 4))
        x += dashW + dashGap
    }
}

// === GROUND below road ===
ctx.setFillColor(hexColor("#5a4a2a"))
ctx.fill(CGRect(x: 0, y: 0, width: w, height: roadBot))

// === CAR on the road (left side, like in game) ===
let carX: CGFloat = w * 0.22
let carY: CGFloat = roadBot + roadH * 0.55
let carW: CGFloat = 120
let carH: CGFloat = 60

// Car shadow
ctx.setFillColor(hexColor("#000000", alpha: 0.3))
ctx.fillEllipse(in: CGRect(x: carX - carW / 2 + 4, y: carY - carH / 2 - 10, width: carW, height: 20))

// Car body (orange like the stock car)
let bodyRect = CGRect(x: carX - carW / 2, y: carY - carH / 2, width: carW, height: carH)
let bodyPath = CGMutablePath(roundedRect: bodyRect, cornerWidth: 10, cornerHeight: 10, transform: nil)
ctx.setFillColor(hexColor("#ff6600"))
ctx.addPath(bodyPath)
ctx.fillPath()

// Cabin
let cabinW = carW / 2.5
let cabinRect = CGRect(x: carX - carW / 4, y: carY - carH / 2 + 6, width: cabinW, height: carH - 12)
let cabinPath = CGMutablePath(roundedRect: cabinRect, cornerWidth: 5, cornerHeight: 5, transform: nil)
ctx.setFillColor(hexColor("#222222"))
ctx.addPath(cabinPath)
ctx.fillPath()

// Windshield
let wsRect = CGRect(x: carX + carW / 5, y: carY - carH / 2 + 8, width: carW / 5, height: carH - 16)
let wsPath = CGMutablePath(roundedRect: wsRect, cornerWidth: 3, cornerHeight: 3, transform: nil)
ctx.setFillColor(hexColor("#97c7ff", alpha: 0.7))
ctx.addPath(wsPath)
ctx.fillPath()

// Wheels
ctx.setFillColor(hexColor("#333333"))
let whl: CGFloat = 16, whw: CGFloat = 10
ctx.fill(CGRect(x: carX - carW / 2 + 6, y: carY - carH / 2 - 4, width: whl, height: whw))
ctx.fill(CGRect(x: carX - carW / 2 + 6, y: carY + carH / 2 - whw + 4, width: whl, height: whw))
ctx.fill(CGRect(x: carX + carW / 2 - whl - 6, y: carY - carH / 2 - 4, width: whl, height: whw))
ctx.fill(CGRect(x: carX + carW / 2 - whl - 6, y: carY + carH / 2 - whw + 4, width: whl, height: whw))

// Headlights
ctx.setFillColor(hexColor("#ffee88"))
ctx.fillEllipse(in: CGRect(x: carX + carW / 2 - 6, y: carY - carH / 4 - 4, width: 12, height: 8))
ctx.fillEllipse(in: CGRect(x: carX + carW / 2 - 6, y: carY + carH / 4 - 4, width: 12, height: 8))

// Flame exhaust
let flamePath = CGMutablePath()
flamePath.move(to: CGPoint(x: carX - carW / 2, y: carY + carH / 4))
flamePath.addLine(to: CGPoint(x: carX - carW / 2 - 40, y: carY))
flamePath.addLine(to: CGPoint(x: carX - carW / 2, y: carY - carH / 4))
flamePath.closeSubpath()
ctx.setFillColor(hexColor("#ff4400", alpha: 0.85))
ctx.addPath(flamePath)
ctx.fillPath()

// Inner flame
let innerFlamePath = CGMutablePath()
innerFlamePath.move(to: CGPoint(x: carX - carW / 2, y: carY + carH / 6))
innerFlamePath.addLine(to: CGPoint(x: carX - carW / 2 - 18, y: carY))
innerFlamePath.addLine(to: CGPoint(x: carX - carW / 2, y: carY - carH / 6))
innerFlamePath.closeSubpath()
ctx.setFillColor(hexColor("#ffffff", alpha: 0.6))
ctx.addPath(innerFlamePath)
ctx.fillPath()

// === SPEED LINES ===
ctx.setStrokeColor(hexColor("#ffffff", alpha: 0.2))
ctx.setLineWidth(2)
for _ in 0..<8 {
    let ly = roadBot + CGFloat.random(in: 10...(roadH - 10))
    let lx = CGFloat.random(in: (w * 0.4)...w)
    let lineLen = CGFloat.random(in: 60...140)
    ctx.move(to: CGPoint(x: lx, y: ly))
    ctx.addLine(to: CGPoint(x: lx - lineLen, y: ly))
    ctx.strokePath()
}

// === TEXT ===

// Draw text helper with shadow
func drawText(_ text: String, fontName: String, fontSize: CGFloat, color: CGColor,
              centerX: CGFloat, centerY: CGFloat, shadowColor: CGColor? = nil,
              shadowOffset: CGSize = CGSize(width: 4, height: -4),
              tracking: CGFloat = 0) {
    let font = CTFontCreateWithName(fontName as CFString, fontSize, nil)

    var attrs: [CFString: Any] = [
        kCTFontAttributeName: font,
        kCTForegroundColorAttributeName: color
    ]
    if tracking != 0 {
        attrs[kCTKernAttributeName] = tracking
    }

    let attrStr = CFAttributedStringCreate(nil, text as CFString, attrs as CFDictionary)!
    let line = CTLineCreateWithAttributedString(attrStr)
    let bounds = CTLineGetBoundsWithOptions(line, [])

    let tx = centerX - bounds.width / 2
    let ty = centerY - bounds.height / 2

    // Shadow
    if let shadowColor = shadowColor {
        ctx.saveGState()
        ctx.textPosition = CGPoint(x: tx + shadowOffset.width, y: ty + shadowOffset.height)
        var shadowAttrs = attrs
        shadowAttrs[kCTForegroundColorAttributeName] = shadowColor
        let shadowStr = CFAttributedStringCreate(nil, text as CFString, shadowAttrs as CFDictionary)!
        let shadowLine = CTLineCreateWithAttributedString(shadowStr)
        CTLineDraw(shadowLine, ctx)
        ctx.restoreGState()
    }

    // Main text
    ctx.saveGState()
    ctx.textPosition = CGPoint(x: tx, y: ty)
    CTLineDraw(line, ctx)
    ctx.restoreGState()
}

// "RALLY" - large BungeeShade, red with black shadow
drawText("RALLY", fontName: "BungeeShade-Regular", fontSize: 180,
         color: hexColor("#ff4444"),
         centerX: w / 2, centerY: h * 0.82,
         shadowColor: hexColor("#000000", alpha: 0.8),
         shadowOffset: CGSize(width: 6, height: -6))

// "RACER" - large BungeeShade, red with black shadow
drawText("RACER", fontName: "BungeeShade-Regular", fontSize: 180,
         color: hexColor("#ff4444"),
         centerX: w / 2, centerY: h * 0.65,
         shadowColor: hexColor("#000000", alpha: 0.8),
         shadowOffset: CGSize(width: 6, height: -6))

// Orange-yellow gradient divider line
ctx.setFillColor(hexColor("#ff6600"))
let dividerY = h * 0.57
let divW: CGFloat = 500
ctx.fill(CGRect(x: (w - divW) / 2, y: dividerY, width: divW, height: 4))

// "2000" - RussoOne, yellow/gold
drawText("2000", fontName: "RussoOne-Regular", fontSize: 120,
         color: hexColor("#ffcc00"),
         centerX: w / 2, centerY: h * 0.48,
         shadowColor: hexColor("#000000", alpha: 0.7),
         shadowOffset: CGSize(width: 4, height: -4),
         tracking: 8)

// === Red glow overlay on title area ===
let titleGlowColors = [
    hexColor("#ff3c14", alpha: 0.3),
    hexColor("#ff3c14", alpha: 0.0)
] as CFArray
let titleGlowLocations: [CGFloat] = [0.0, 1.0]
if let titleGlow = CGGradient(colorsSpace: colorSpace, colors: titleGlowColors, locations: titleGlowLocations) {
    ctx.drawRadialGradient(
        titleGlow,
        startCenter: CGPoint(x: w / 2, y: h * 0.7),
        startRadius: 0,
        endCenter: CGPoint(x: w / 2, y: h * 0.7),
        endRadius: 350,
        options: []
    )
}

// === SAVE ===
guard let image = ctx.makeImage() else {
    print("Failed to create image")
    exit(1)
}

let outputPath = "./RallyRacer/RallyRacer/Resources/Assets.xcassets/AppIcon.appiconset/RallyRacer_icon_1024.png"
let outputURL = URL(fileURLWithPath: outputPath)

guard let dest = CGImageDestinationCreateWithURL(outputURL as CFURL, "public.png" as CFString, 1, nil) else {
    print("Failed to create image destination")
    exit(1)
}
CGImageDestinationAddImage(dest, image, nil)
if CGImageDestinationFinalize(dest) {
    print("Icon saved to \(outputPath)")
} else {
    print("Failed to save icon")
    exit(1)
}

// Also copy to the imageset
let imagesetPath = "./RallyRacer/RallyRacer/Resources/Assets.xcassets/RallyRacer_icon_1024.imageset/RallyRacer_icon_1024.png"
guard let dest2 = CGImageDestinationCreateWithURL(URL(fileURLWithPath: imagesetPath) as CFURL, "public.png" as CFString, 1, nil) else {
    print("Failed to create imageset destination")
    exit(1)
}
CGImageDestinationAddImage(dest2, image, nil)
if CGImageDestinationFinalize(dest2) {
    print("Icon also saved to \(imagesetPath)")
} else {
    print("Failed to save imageset icon")
}
