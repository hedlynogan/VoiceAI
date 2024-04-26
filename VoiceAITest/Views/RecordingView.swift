//
//  RecordingObjectView.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/18/24.
//

import SwiftUI

struct RecordingView: View {
    
    let recording: Recording
    
    @StateObject private var viewModel: RecordingViewModel
    
    init(recording: Recording) {
        self.recording = recording
        _viewModel = StateObject(wrappedValue: RecordingViewModel(recording: recording))
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            recordingInfoView
            Spacer()
            toggleAudioButton
        }
    }
    
    @ViewBuilder
    private var recordingInfoView: some View {
        VStack (alignment: .leading) {
            if recording.isTranscribed == false || recording.isAnalyzed == false {
                Text("Processing...")
                    .italic()
            }
            Text(recording.title)
                .font(.title2)
            Text(viewModel.formattedDate)
                .italic()
        }
    }
    
    @ViewBuilder
    private var toggleAudioButton: some View {
        if viewModel.isPlaying {
            stopButton
        } else {
            playButton
        }
    }
    
    
    @ViewBuilder
    private var playButton: some View {
        Button(action: {
            Task { @MainActor in
                await viewModel.playAudio()
            }
        }) {
            Image(systemName: "speaker.3.fill")
                .font(.title2)
                .frame(width: 44, height: 44, alignment: .center)
            
        }
    }
    
    @ViewBuilder
    private var stopButton: some View {
        Button(action: {
            Task { @MainActor in
                await viewModel.stopAudio()
            }
        }) {
            Image(systemName: "stop.fill")
                .font(.title2)
                .foregroundColor(.red)
                .frame(width: 44, height: 44, alignment: .center)
        }
    }
}
