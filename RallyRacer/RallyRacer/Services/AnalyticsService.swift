import Foundation
import UIKit
// import AmplitudeSwift // TEMPORARILY REMOVED

class AnalyticsService {
    static let shared = AnalyticsService()

    // private var amplitude: Amplitude? // TEMPORARILY REMOVED

    private init() {}

    func configure() {
        // TEMPORARILY REMOVED - Amplitude SDK
        // amplitude = Amplitude(configuration: Configuration(
        //     apiKey: "320039b4a4d9514044b5ded10958c124",
        //     autocapture: []
        // ))

        let deviceType = UIDevice.current.userInterfaceIdiom == .pad ? "ipad" : "iphone"
        // let identify = Identify()
        // identify.set(property: "Device Type", value: deviceType)
        // amplitude?.identify(identify: identify)

        #if DEBUG
        print("[Analytics] Amplitude DISABLED, Device Type: \(deviceType)")
        #endif
    }

    func track(_ eventName: String, properties: [String: Any]? = nil) {
        #if DEBUG
        if let props = properties {
            print("[Analytics] \(eventName): \(props)")
        } else {
            print("[Analytics] \(eventName)")
        }
        #endif

        // TEMPORARILY REMOVED - Amplitude SDK
        // if let props = properties {
        //     amplitude?.track(eventType: eventName, eventProperties: props)
        // } else {
        //     amplitude?.track(eventType: eventName)
        // }
    }

    func trackPageView(_ page: String) {
        track("page_view", properties: ["page": page])
    }

    func trackButtonClick(_ button: String, page: String) {
        track("button_click", properties: ["button": button, "page": page])
    }

    func setUserId(_ userId: String) {
        // amplitude?.setUserId(userId: userId) // TEMPORARILY REMOVED
        #if DEBUG
        print("[Analytics] setUserId: \(userId)")
        #endif
    }
}
