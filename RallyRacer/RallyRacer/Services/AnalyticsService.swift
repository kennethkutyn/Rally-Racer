import Foundation
import UIKit
import AmplitudeSwift

class AnalyticsService {
    static let shared = AnalyticsService()

    private var amplitude: Amplitude?

    private init() {}

    func configure() {
        amplitude = Amplitude(configuration: Configuration(
            apiKey: "320039b4a4d9514044b5ded10958c124",
            autocapture: []
        ))

        let deviceType = UIDevice.current.userInterfaceIdiom == .pad ? "ipad" : "iphone"
        let identify = Identify()
        identify.set(property: "Device Type", value: deviceType)
        amplitude?.identify(identify: identify)

        #if DEBUG
        print("[Analytics] Amplitude configured, Device Type: \(deviceType)")
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

        if let props = properties {
            amplitude?.track(eventType: eventName, eventProperties: props)
        } else {
            amplitude?.track(eventType: eventName)
        }
    }

    func trackPageView(_ page: String) {
        track("page_view", properties: ["page": page])
    }

    func trackButtonClick(_ button: String, page: String) {
        track("button_click", properties: ["button": button, "page": page])
    }

    func setUserId(_ userId: String) {
        amplitude?.setUserId(userId: userId)
        #if DEBUG
        print("[Analytics] setUserId: \(userId)")
        #endif
    }
}
