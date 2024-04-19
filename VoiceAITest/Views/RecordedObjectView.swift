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
        HStack(alignment: .firstTextBaseline) {
            recordingInfoView
            Spacer()
            playAudioButtion
        }
    }
    
    @ViewBuilder
    private var recordingInfoView: some View {
        VStack (alignment: .leading) {
            Text(recording.title)
                .font(.title2)
            Text(viewModel.formattedDate)
                .italic()
        }
    }
    
    @ViewBuilder
    private var playAudioButtion: some View {
        Button(action: {
            Task { @MainActor in
                await self.viewModel.playAudio()
            }
        }) {
            Image(systemName: "speaker.3.fill")
                .font(.title2)
        }
    }
}
