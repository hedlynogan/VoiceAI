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
    private let audioPlayer = AudioPlayer()
    
    @MainActor
    func playAudio() {
        Task {
            print(recording.fileURL)
            try await audioPlayer.play(.url(recording.fileURL))
        }
    }
}
