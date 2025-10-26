//
//  WaterTap_Watch_App_Extension.swift
//  WaterTap Watch App Extension
//
//  Created by Deividson Sabino on 25/10/25.
//

import AppIntents

struct WaterTap_Watch_App_Extension: AppIntent {
    static var title: LocalizedStringResource { "WaterTap Watch App Extension" }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
