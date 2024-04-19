//
//  RecordingObjectView.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/18/24.
//

import SwiftUI

struct RecordedObjectView: View {
    
    let recording: RecordedObjectModel
    
    private let viewModel: RecordedObjectViewModel
    
    init(recording: RecordedObjectModel) {
        self.recording = recording
        self.viewModel = RecordedObjectViewModel(recording: recording)
    }
    
    var body: some View {
        HStack {
            Text(recording.title)
            Button(action: {
                Task { @MainActor in
                    await self.viewModel.playAudio()
                }
            }) {
                Image(systemName: "speaker.3.fill")
                    .font(.title3)
            }
        }
    }
}
