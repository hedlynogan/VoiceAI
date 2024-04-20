//
//  RecordingObjectView.swift
//  VoiceAITest
//
//  Created by Natasha Murashev on 4/18/24.
//

import SwiftUI

struct RecordedObjectView: View {
    
    let recording: RecordedObjectModel
    
    @StateObject private var viewModel: RecordedObjectViewModel
    
    init(recording: RecordedObjectModel) {
        self.recording = recording
        _viewModel = StateObject(wrappedValue:RecordedObjectViewModel(recording: recording))
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
