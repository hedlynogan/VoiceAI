//
//  VoiceAITestApp.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/15/24.
//

import SwiftUI
import SwiftData

@main
struct VoiceAITestApp: App {
    
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Recording.self,
            RecordingSegment.self,
            RecordingKeyPoint.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            RecorderView(modelContainer: sharedModelContainer)
        }.modelContainer(sharedModelContainer)
    }
}
