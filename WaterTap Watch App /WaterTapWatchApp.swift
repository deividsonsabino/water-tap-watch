//
//  WaterTapApp.swift
//  WaterTap Watch App
//
//  Created by Deividson Sabino on 25/10/25.
//

import SwiftUI

@main
struct WaterTapWatchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    let granted = await NotificationManager.requestAuthorization()
                    if granted {
                        await NotificationManager.scheduleEndOfDaySummary(atHour: 21, minute: 0)
                    }
                }
        }
    }
}

