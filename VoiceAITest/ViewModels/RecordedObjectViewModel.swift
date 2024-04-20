//
//  RecordedObjectViewModel.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/18/24.
//

import SwiftUI
import Media

struct RecordedObjectViewModel {
    let recording: RecordedObjectModel
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: recording.createdDate)
    }
    
    @MainActor
    func playAudio() async {
        do {
            try await AudioPlayer().play(recording.audioData, fileTypeHint: nil)
        } catch {
            print(error)
        }
        
    }
}
