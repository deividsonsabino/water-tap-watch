// ConnectivityService.swift
// Unified iOS/watchOS connectivity using WatchConnectivity.

import Foundation
import WatchConnectivity

public extension Notification.Name {
    static let didReceiveGoalUpdate = Notification.Name("didReceiveGoalUpdate")
    static let didReceiveProgressUpdate = Notification.Name("didReceiveProgressUpdate")
    static let didReceiveIntakeUpdate = Notification.Name("didReceiveIntakeUpdate")
}

final class ConnectivityService: NSObject {
    static let shared = ConnectivityService()

    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil

    private override init() {
        super.init()
        activate()
    }

    // MARK: - Activation
    private func activate() {
        guard let session = session else { return }
        session.delegate = self
        session.activate()
    }

    // MARK: - Send API (common)
    func send(goal: Int) {
        guard let session = session else { return }
        let payload: [String: Any] = ["dailyGoal": goal]

        // Prefer realtime message when reachable; otherwise fallback to background delivery
        if session.isReachable {
            session.sendMessage(payload, replyHandler: nil, errorHandler: { _ in
                _ = session.transferUserInfo(payload)
            })
        } else {
            // Use the most reliable background option available on both platforms
            _ = session.transferUserInfo(payload)
            // Optionally also try applicationContext for latest-state semantics
            do { try session.updateApplicationContext(payload) } catch { }
        }
    }

    // MARK: - Send progress percentage (0.0 ... 1.0)
    func sendProgress(percentage: Double) {
        guard let session = session else { return }
        let clamped = max(0.0, min(1.0, percentage))
        let payload: [String: Any] = ["waterProgress": clamped]
        if session.isReachable {
            session.sendMessage(payload, replyHandler: nil, errorHandler: { _ in
                _ = session.transferUserInfo(payload)
            })
        } else {
            _ = session.transferUserInfo(payload)
            do { try session.updateApplicationContext(payload) } catch { }
        }
    }
    
    // MARK: - Send intake in milliliters
    func sendIntake(ml: Double) {
        guard let session = session else { return }
        let nonNegative = max(0.0, ml)
        let payload: [String: Any] = ["waterIntakeML": nonNegative]
        if session.isReachable {
            session.sendMessage(payload, replyHandler: nil, errorHandler: { _ in
                _ = session.transferUserInfo(payload)
            })
        } else {
            _ = session.transferUserInfo(payload)
            do { try session.updateApplicationContext(payload) } catch { }
        }
    }
}

// MARK: - WCSessionDelegate
extension ConnectivityService: WCSessionDelegate {
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    #endif

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // No-op
    }

    // Realtime message from counterpart
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleIncoming(message)
    }

    // Background deliveries
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        handleIncoming(userInfo)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        handleIncoming(applicationContext)
    }

    private func handleIncoming(_ dict: [String: Any]) {
        var handled = false
        if let goal = dict["dailyGoal"] as? Int, goal > 0 {
            NotificationCenter.default.post(name: .didReceiveGoalUpdate, object: goal)
            handled = true
        }
        if let progress = dict["waterProgress"] as? Double, progress >= 0, progress <= 1 {
            NotificationCenter.default.post(name: .didReceiveProgressUpdate, object: progress)
            handled = true
        }
        if let intakeML = dict["waterIntakeML"] as? Double, intakeML >= 0 {
            NotificationCenter.default.post(name: .didReceiveIntakeUpdate, object: intakeML)
            handled = true
        }
        _ = handled
    }
}
