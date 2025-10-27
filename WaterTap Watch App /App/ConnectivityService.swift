import Foundation
#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

// MARK: - Notifications used across the app
public extension Notification.Name {
    static let didReceiveGoalUpdate = Notification.Name("didReceiveGoalUpdate")
    static let didReceiveProgressUpdate = Notification.Name("didReceiveProgressUpdate")
    static let didReceiveIntakeUpdate = Notification.Name("didReceiveIntakeUpdate")
}

// MARK: - ConnectivityService
final class ConnectivityService: NSObject {
    static let shared = ConnectivityService()

    private override init() {
        super.init()
        activateSessionIfAvailable()
    }

    // MARK: Activation
    private func activateSessionIfAvailable() {
        #if canImport(WatchConnectivity)
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        #endif
    }

    // MARK: Sending helpers
    func send(goal: Int) {
        guard goal > 0 else { return }
        sendMessage(["goal": goal])
        NotificationCenter.default.post(name: .didReceiveGoalUpdate, object: goal)
    }

    func sendProgress(percentage: Double) {
        guard percentage.isFinite else { return }
        let clamped = max(0, min(1, percentage))
        sendMessage(["progress": clamped])
        NotificationCenter.default.post(name: .didReceiveProgressUpdate, object: clamped)
    }

    func sendIntake(ml: Double) {
        guard ml.isFinite, ml >= 0 else { return }
        sendMessage(["intake": ml])
        NotificationCenter.default.post(name: .didReceiveIntakeUpdate, object: ml)
    }

    // MARK: Low-level message sending
    private func sendMessage(_ message: [String: Any]) {
        #if canImport(WatchConnectivity)
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil, errorHandler: nil)
        } else {
            do {
                try session.updateApplicationContext(message)
            } catch {
                // Swallow errors for now; this is a minimal implementation
            }
        }
        #endif
    }
}

#if canImport(WatchConnectivity)
// MARK: - WCSessionDelegate
extension ConnectivityService: WCSessionDelegate {
    // iOS + watchOS common
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // No-op
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif

    // Receive messages / context updates
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleIncoming(message)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        handleIncoming(applicationContext)
    }

    private func handleIncoming(_ dict: [String: Any]) {
        if let goal = dict["goal"] as? Int, goal > 0 {
            NotificationCenter.default.post(name: .didReceiveGoalUpdate, object: goal)
        }
        if let progress = dict["progress"] as? Double, progress.isFinite {
            let clamped = max(0, min(1, progress))
            NotificationCenter.default.post(name: .didReceiveProgressUpdate, object: clamped)
        }
        if let intake = dict["intake"] as? Double, intake.isFinite, intake >= 0 {
            NotificationCenter.default.post(name: .didReceiveIntakeUpdate, object: intake)
        }
    }
}
#endif
